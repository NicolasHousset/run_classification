# First processing of the ms_lims data (project 2000 to 3200, Vanessa instrument (id = 10)


library(data.table)
library(ggplot2)

projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"
load(file = paste0(projectPath,"/data/identified.RData"))

# identified <- identified[l_instrumentid == 10]

# To filter out experiments with very high retention times 
# Also, to extract the internal index instrument-specific
identified[, l_projectid := as.character(l_projectid)]
rowNumbers <- identified[,j=list(.I[which.max(rtsec)]), by=name][,j=V1]
maxRTperProject <- identified[rowNumbers, list(name,rtsec)]


listName <- gregexpr("V[0123456789]+_", maxRTperProject[, name], ignore.case = TRUE)

listIndex <- vector("list", NROW(listName))
for (i in (1:NROW(listName))){
  if(listName[[i]] > -1){
    listIndex[[i]] <- substr(maxRTperProject[i, name], listName[[i]], listName[[i]]+attr(listName[[i]],"match.length")-1)
  }
}

maxRTperProject[, name_2 := listIndex]
maxRTperProject[nchar(name_2)==6, index := paste0("0",substr(name_2,2,5))]
maxRTperProject[nchar(name_2)==7, index := substr(name_2, 2,6)]
maxRTperProject[nchar(name_2)==4, index := "99999"]
maxRTperProject[nchar(name_2)==11, index := substr(name_2, 2,6)]

maxRTperProject[, rtsecMax := rtsec]
maxRTperProject[, rtsec := NULL]
maxRTperProject[, name_2 := NULL]


setkey(maxRTperProject, name)
setkey(identified, name)
identified <- identified[maxRTperProject]

identified[, grp_protocol := l_protocolid]
identified[l_protocolid == 5, grp_protocol := 8]
identified[l_protocolid == 11, grp_protocol := 8]

# Most common peptide notion depends on the protocol

# First get all the different protocols
identified[, l_protocolid.f := factor(l_protocolid)]
list_protocol <- levels(unique(identified[,l_protocolid.f]))


######
setkey(identified, index, modified_sequence)
countsPerProject <- unique(identified)[, list(index,modified_sequence, l_protocolid.f)]
countsPerProject[, modified_sequence.f := factor(modified_sequence)]
setkey(countsPerProject, l_protocolid.f)
# Tip : factor of modified_sequence has been computed with all the protocols.
# When summarizing it per protocol, peptides not present will still be here but with a counting of 0
# The order of summary(modified_sequence.f) will be the same (alphabetical)

nbProjPerPeptide <- summary(countsPerProject[, modified_sequence.f], maxsum = 1000000)
id_peptide <- 1:NROW(nbProjPerPeptide)
dt <- data.table(id_peptide)
dt[, modified_sequence := labels(nbProjPerPeptide)]

for (i in 1:NROW(list_protocol)){
  protocolSummary <- summary(countsPerProject[list_protocol[i]][, modified_sequence.f], maxsum = 1000000)
  stringExpression <- paste0("dt[, nbProjPepProtocol",list_protocol[i]," := -protocolSummary]")
  print(stringExpression)
  eval(parse(text=stringExpression))
}

for(i in 1:NROW(list_protocol)){
  # Ordering peptides by descending frequency in one given protocol
  eval(parse(text=paste0("setkey(dt, nbProjPepProtocol",list_protocol[i],")")))
  # Saving the order in the current setting
  eval(parse(text=paste0("dt[, rank_peptideProtocol",list_protocol[i]," := 1:NROW(nbProjPerPeptide)]")))
  # If peptide is not counted in one given protocol, set the rank to 0
  eval(parse(text=paste0("dt[nbProjPepProtocol",list_protocol[i],"==0, rank_peptideProtocol",list_protocol[i]," := 0L]")))
  # Returning the number of projects to a positive value
  eval(parse(text=paste0("dt[, nbProjPepProtocol", list_protocol[i]," := -nbProjPepProtocol", list_protocol[i],"]")))
}  

setkey(dt, modified_sequence)
setkey(identified, modified_sequence)
identified <- identified[dt]


setkey(identified, l_lcrunid, modified_sequence, rtsec)
# To remove rt that have been identified more than once (otherwise, index are altered)
identified_subs <- unique(identified)
convenient_vector <- 1:4000

# Add an index : 1 for the first time a peptide is encountered in a LC-run, 2 the second time, etc...
# convenient_vector is automatically shrinked to the appropriate size : that is very convenient :)
identified_subs[, index_rt1 := convenient_vector, by = c("l_lcrunid","modified_sequence")]
# Slightly different index : number of times the peptide is identified in the LC-run.
identified_subs[, size_rt := .N, by = c("l_lcrunid", "modified_sequence")]

identified_subs[,total_spectrum_intensity := -total_spectrum_intensity]
setkey(identified_subs, l_lcrunid, modified_sequence, total_spectrum_intensity)
identified_subs[, index_rt2 := convenient_vector, by = c("l_lcrunid","modified_sequence")]
identified_subs[,total_spectrum_intensity := -total_spectrum_intensity]

# Statistics computed on rt measurements where index_rt2 < 5 : 4 most intense spectrum of the peptide per LC-run

identified_subs[index_rt2 <3, q50_2 := quantile(rtsec, probs = 0.50), by = c("l_instrumentid", "modified_sequence", "l_protocolid")]

save(identified_subs, file = paste0(projectPath,"/data/identified_protocol.RData"), compression_level=1)
write.csv(identified_subs, file = paste0(projectPath,"/data/identified_protocol.csv"))

