# Purpose : on runs classified on low and high columns, the average shift seems to change


library(data.table)
library(ggplot2)

projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"


load(file = paste0(projectPath,"/data/annotated_id.RData"))
rtPeptide <- annotated_id[, list(l_projectid, l_lcrunid, index, sequence, modified_sequence, index_rt2, l_protocolid, classification, rtsec, q50_3)]

setkey(rtPeptide, classification)
rtPeptide <- rtPeptide[c("low","high")]

# To exclude redundant peptides
rtPeptide <- rtPeptide[index_rt2 <2] 

table(rtPeptide[, index])
setkey(rtPeptide, index)

rtPeptide[, group := NULL]
rtPeptide[as.character(10409:10773), group := "01"] # 
rtPeptide[as.character(10858:11088), group := "02"] # 
rtPeptide[as.character(11487:12020), group := "03"] # 
rtPeptide[as.character(12713:13157), group := "04"] # 
rtPeptide[as.character(13320:13468), group := "05"] # 
rtPeptide[as.character(13589:13893), group := "06"] # 
rtPeptide[as.character(14004:14874), group := "07"] #
rtPeptide[as.character(14932:15135), group := "08"] # 

table(rtPeptide[,group])

rtPeptide <- rtPeptide[, list(l_projectid, l_lcrunid, index, sequence, modified_sequence, index_rt2, l_protocolid, classification, rtsec, q50_3,group)]

# First get all the different columns
rtPeptide[, classification.f := factor(paste0(classification,group))]

# Retention times measured very late are likely to not be interesting, because they are linked to the cleaning of the column
rtPeptide[, TS_clean := quantile(rtsec, probs = 0.97), by = c("classification.f")]
rtPeptide <- rtPeptide[rtsec < TS_clean]
# Important: computing the median by group
setkey(rtPeptide, classification.f, modified_sequence)
rtPeptide[, q50_4 := quantile(rtsec, probs = 0.50), by = c("classification.f","modified_sequence")]

list_classification <- levels(unique(rtPeptide[,classification.f]))


setkey(rtPeptide, index, modified_sequence)
countsPerProject <- unique(rtPeptide)[, list(index,modified_sequence, classification.f)]
countsPerProject[, modified_sequence.f := factor(modified_sequence)]
setkey(countsPerProject, classification.f)
# Tip : factor of modified_sequence has been computed with all the protocols.
# When summarizing it per protocol, peptides not present will still be here but with a counting of 0
# The order of summary(modified_sequence.f) will be the same (alphabetical)

nbProjPerPeptide <- summary(countsPerProject[, modified_sequence.f], maxsum = 1000000)
id_peptide <- 1:NROW(nbProjPerPeptide)
dt <- data.table(id_peptide)
dt[, modified_sequence := labels(nbProjPerPeptide)]

for (i in 1:NROW(list_classification)){
  protocolSummary <- summary(countsPerProject[list_classification[i]][, modified_sequence.f], maxsum = 1000000)
  stringExpression <- paste0("dt[, nbProjPepProtocol",list_classification[i]," := -protocolSummary]")
  print(stringExpression)
  eval(parse(text=stringExpression))
}

for(i in 1:NROW(list_classification)){
  # Ordering peptides by descending frequency in one given column
  eval(parse(text=paste0("setkey(dt, nbProjPepProtocol",list_classification[i],")")))
  # Saving the order in the current setting
  eval(parse(text=paste0("dt[, rank_peptideProtocol",list_classification[i]," := 1:NROW(nbProjPerPeptide)]")))
  # If peptide is not counted in one given column, set the rank to 0
  eval(parse(text=paste0("dt[nbProjPepProtocol",list_classification[i],"==0, rank_peptideProtocol",list_classification[i]," := 0L]")))
  # Returning the number of projects to a positive value
  eval(parse(text=paste0("dt[, nbProjPepProtocol", list_classification[i]," := -nbProjPepProtocol", list_classification[i],"]")))
}  

setkey(dt, modified_sequence)
setkey(rtPeptide, modified_sequence)
rtPeptide <- rtPeptide[dt]

save(rtPeptide, file = paste0(projectPath,"/data/corrected_id.RData"), compression_level=1)
write.csv(rtPeptide, file = paste0(projectPath,"/data/corrected_id.csv"))

#####
setkey(rtPeptide, classification.f, modified_sequence)
rtPeptideColumn <- unique(rtPeptide[c("high07","low07")])[nbProjPepProtocolhigh07 > 0 & nbProjPepProtocollow07 > 0,
                                                          list(modified_sequence, classification.f, q50_4)]

setkey(rtPeptideColumn, classification.f)
diffColumns <- rtPeptideColumn["low07"]
diffColumns[, q50_4_low := q50_4]
diffColumns[, q50_4 := NULL]

dt <- rtPeptideColumn["high07"]
setkey(diffColumns, modified_sequence)
setkey(dt, modified_sequence)

diffColumns <- diffColumns[dt]
diffColumns[, q50_4_high := q50_4]
diffColumns[, q50_4 := NULL]

diffColumns[, diff := q50_4_high - q50_4_low]

ggplot(diffColumns, aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)


#####
setkey(rtPeptide, classification.f, modified_sequence)
rtPeptideColumn <- unique(rtPeptide[c("low01","low07")])[nbProjPepProtocollow01 > 0 & nbProjPepProtocollow07 > 0,
                                                          list(modified_sequence, classification.f, q50_4)]

setkey(rtPeptideColumn, classification.f)
diffColumns <- rtPeptideColumn["low01"]
diffColumns[, q50_4_low := q50_4]
diffColumns[, q50_4 := NULL]

dt <- rtPeptideColumn["low07"]
setkey(diffColumns, modified_sequence)
setkey(dt, modified_sequence)

diffColumns <- diffColumns[dt]
diffColumns[, q50_4_high := q50_4]
diffColumns[, q50_4 := NULL]

diffColumns[, diff := q50_4_high - q50_4_low]

ggplot(diffColumns, aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)

quartiles <- quantile(diffColumns[,q50_4_low], probs = c(0.25,0.5,0.75))
quantile(diffColumns[q50_4_low <= quartiles[[1]]][, diff], probs = 0.5)
quantile(diffColumns[q50_4_low > quartiles[[1]] & q50_4_low <= quartiles[[2]]][, diff], probs = 0.5)
quantile(diffColumns[q50_4_low > quartiles[[2]] & q50_4_low <= quartiles[[3]]][, diff], probs = 0.5)
quantile(diffColumns[q50_4_low > quartiles[[3]]][, diff], probs = 0.5)

ggplot(diffColumns[q50_4_low <= quartiles[[1]]], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_low > quartiles[[1]] & q50_4_low <= quartiles[[2]]], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_low > quartiles[[2]] & q50_4_low <= quartiles[[3]]], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_low > quartiles[[3]]], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)


diffByQuartile <- function(group_ref, group_id){
  setkey(rtPeptide, classification.f, modified_sequence)
  eval(parse(text=paste0(
    "rtPeptideColumn <- rtPeptide[c(\"", group_id, "\",\"", group_ref,
    "\")][nbProjPepProtocol", group_id, " > 0 & nbProjPepProtocol", group_ref," > 0,
    list(classification.f, modified_sequence, q50_4)]")))
  
  setkey(rtPeptideColumn, classification.f, modified_sequence)
  rtPeptideColumn <- unique(rtPeptideColumn)
  
  setkey(rtPeptideColumn, classification.f)
  eval(parse(text=paste0("diffColumns <- rtPeptideColumn[\"", group_ref, "\"]")))
  diffColumns[, q50_4_ref := q50_4]
  diffColumns[, q50_4 := NULL]
  
  eval(parse(text=paste0("dt <- rtPeptideColumn[\"", group_id, "\"]")))
  setkey(diffColumns, modified_sequence)
  setkey(dt, modified_sequence)
  
  diffColumns <- diffColumns[dt]
  diffColumns[, q50_4_id := q50_4]
  diffColumns[, q50_4 := NULL]
  
  diffColumns[, diff := q50_4_ref - q50_4_id]
  
  quartiles <- quantile(diffColumns[,q50_4_id], probs = c(0.01,0.25,0.5,0.75,1.0))
  
  list_corrections <- vector("numeric",4)
  dt <- data.table(quartiles)
  dt[1, correction := 0.0]
  temp <- quantile(diffColumns[q50_4_id <= quartiles[[2]]][, diff], probs = 0.5)
  dt[2, correction := as.numeric(temp)]
  temp <- quantile(diffColumns[q50_4_id > quartiles[[2]] & q50_4_id <= quartiles[[3]]][, diff], probs = 0.5)
  dt[3, correction := as.numeric(temp)]
  temp <- quantile(diffColumns[q50_4_id > quartiles[[3]] & q50_4_id <= quartiles[[4]]][, diff], probs = 0.5)
  dt[4, correction := as.numeric(temp)]
  temp <- quantile(diffColumns[q50_4_id > quartiles[[4]]][, diff], probs = 0.5)
  dt[5, correction := as.numeric(temp)]
  return(dt)
}



#####
setkey(rtPeptide, classification.f, modified_sequence)
rtPeptideColumn <- unique(rtPeptide[c("high01","high07")])[nbProjPepProtocolhigh01 > 0 & nbProjPepProtocolhigh07 > 0,
                                                          list(modified_sequence, classification.f, q50_4)]

setkey(rtPeptideColumn, classification.f)
diffColumns <- rtPeptideColumn["high01"]
diffColumns[, q50_4_low := q50_4]
diffColumns[, q50_4 := NULL]

dt <- rtPeptideColumn["high07"]
setkey(diffColumns, modified_sequence)
setkey(dt, modified_sequence)

diffColumns <- diffColumns[dt]
diffColumns[, q50_4_high := q50_4]
diffColumns[, q50_4 := NULL]

diffColumns[, diff := q50_4_high - q50_4_low]

ggplot(diffColumns, aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)

quartiles <- quantile(diffColumns[,q50_4_low], probs = c(0.25,0.5,0.75))
quantile(diffColumns[q50_4_low <= quartiles[[1]]][, diff], probs = 0.5)
quantile(diffColumns[q50_4_low > quartiles[[1]] & q50_4_low <= quartiles[[2]]][, diff], probs = 0.5)
quantile(diffColumns[q50_4_low > quartiles[[2]] & q50_4_low <= quartiles[[3]]][, diff], probs = 0.5)
quantile(diffColumns[q50_4_low > quartiles[[3]]][, diff], probs = 0.5)

ggplot(diffColumns[q50_4_low <= quartiles[[1]]], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_low > quartiles[[1]] & q50_4_low <= quartiles[[2]]], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_low > quartiles[[2]] & q50_4_low <= quartiles[[3]]], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_low > quartiles[[3]]], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)



#####
setkey(rtPeptide, classification.f, modified_sequence)
rtPeptideColumn <- unique(rtPeptide[c("low01","low02", "low05")])[nbProjPepProtocollow01 > 0 & nbProjPepProtocollow02 > 0 &
                                                                    nbProjPepProtocollow05 > 0,
                                                         list(modified_sequence, classification.f, q50_4)]

setkey(rtPeptideColumn, classification.f)
diffColumns <- rtPeptideColumn["low01"]
diffColumns[, q50_4_low := q50_4]
diffColumns[, q50_4 := NULL]

dt <- rtPeptideColumn["low02"]
setkey(diffColumns, modified_sequence)
setkey(dt, modified_sequence)

diffColumns <- diffColumns[dt]
diffColumns[, q50_4_high := q50_4]
diffColumns[, q50_4 := NULL]

dt <- rtPeptideColumn["low05"]
setkey(diffColumns, modified_sequence)
setkey(dt, modified_sequence)

diffColumns <- diffColumns[dt]
diffColumns[, q50_4_test := q50_4]
diffColumns[, q50_4 := NULL]


diffColumns[, diff := q50_4_high - q50_4_low]

ggplot(diffColumns[diff > 50], aes(q50_4_test - q50_4_low)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
