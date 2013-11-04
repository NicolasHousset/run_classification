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
rtPeptide[as.character(10409:10439), group := "00"] # 
rtPeptide[as.character(10750:10773), group := "01"] # 
rtPeptide[as.character(10858:11088), group := "02"] # Shift around 70 seconds
rtPeptide[as.character(11487:13157), group := "03"] # Shift around 30 seconds
rtPeptide[as.character(13320:13468), group := "04"] # 
rtPeptide[as.character(13589:14874), group := "05"] # Shift around 70 seconds
rtPeptide[as.character(14932:15135), group := "06"] # Shift around 25 seconds


table(rtPeptide[,group])
rtPeptide[, q50_4 := quantile(rtsec, probs = 0.50), by = c("modified_sequence","classification", "group")]

rtPeptide <- rtPeptide[, list(l_projectid, l_lcrunid, index, sequence, modified_sequence, index_rt2, l_protocolid, classification, rtsec, q50_3,q50_4,group)]

# First get all the different columns
rtPeptide[, classification.f := factor(paste0(classification,group))]
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
rtPeptideColumn <- unique(rtPeptide[c("high04","low04")])[nbProjPepProtocolhigh04 > 0 & nbProjPepProtocollow04 > 0,
                                                          list(modified_sequence, classification.f, q50_4)]

setkey(rtPeptideColumn, classification.f)
diffColumns <- rtPeptideColumn["low04"]
diffColumns[, q50_4_low := q50_4]
diffColumns[, q50_4 := NULL]

dt <- rtPeptideColumn["high04"]
setkey(diffColumns, modified_sequence)
setkey(dt, modified_sequence)

diffColumns <- diffColumns[dt]
diffColumns[, q50_4_high := q50_4]
diffColumns[, q50_4 := NULL]

diffColumns[, diff := q50_4_high - q50_4_low]

ggplot(diffColumns, aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)


#####
setkey(rtPeptide, classification.f, modified_sequence)
rtPeptideColumn <- unique(rtPeptide[c("low01","low02")])[nbProjPepProtocollow01 > 0 & nbProjPepProtocollow02 > 0,
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

diffColumns[, diff := q50_4_high - q50_4_low]

ggplot(diffColumns, aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)

quantile(diffColumns[, diff], probs = 0.5)
ggplot(diffColumns[q50_4_low>1250], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_low<1250], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)


#####
setkey(rtPeptide, classification.f, modified_sequence)
rtPeptideColumn <- unique(rtPeptide[c("high01","high02")])[nbProjPepProtocolhigh01 > 0 & nbProjPepProtocolhigh02 > 0,
                                                          list(modified_sequence, classification.f, q50_4)]

setkey(rtPeptideColumn, classification.f)
diffColumns <- rtPeptideColumn["high01"]
diffColumns[, q50_4_low := q50_4]
diffColumns[, q50_4 := NULL]

dt <- rtPeptideColumn["high02"]
setkey(diffColumns, modified_sequence)
setkey(dt, modified_sequence)

diffColumns <- diffColumns[dt]
diffColumns[, q50_4_high := q50_4]
diffColumns[, q50_4 := NULL]

diffColumns[, diff := q50_4_high - q50_4_low]

ggplot(diffColumns, aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_low > 1250], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)
ggplot(diffColumns[q50_4_high < 1250], aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)



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
