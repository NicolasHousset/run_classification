# Training ELUDE on data coming from two different columns
# Peptides should be pretty similar

library(data.table)
library(ggplot2)

projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"


load(file = paste0(projectPath,"/data/annotated_id.RData"))
setkey(annotated_id, modified_sequence)
rtPeptide <- annotated_id[, list(l_projectid, l_lcrunid, index, sequence, modified_sequence, index_rt2, l_protocolid, classification, rtsec, q50_3)]
setkey(rtPeptide, classification)
rtPeptide <- rtPeptide[c("low","high")]
setkey(rtPeptide, modified_sequence, classification)
rtPepUnique <- unique(rtPeptide)[,list(sequence, modified_sequence, classification)]


# Yes, I want to get the modifications. And this is complicated.

mod_pep <- rtPepUnique[, modified_sequence]
modif <- gregexpr("[ACDEFGHIKLMNPQRSTVWY]{1}<[ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789]+[*]*>", mod_pep, ignore.case = TRUE)
modifN <- gregexpr("^[ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789]+[-]", mod_pep, ignore.case = TRUE)
modifC <- gregexpr("[-][ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789]+$", mod_pep, ignore.case = TRUE)

listmod <- vector("list", NROW(modif))
for (i in (1:NROW(modif))){
  listmod[[i]] <- vector("character",4)
  for (j in (1:NROW(modif[[i]]))){
    if(modif[[i]][[j]] > -1){
      listmod[[i]][[j]] <- substr(mod_pep[[i]], modif[[i]][[j]], modif[[i]][[j]]+attr(modif[[i]],"match.length")[[j]]-1)
    }
  }
}

listmodN <- vector("list", NROW(modifN))
for (i in (1:NROW(modifN))){
  listmodN[[i]] <- vector("character",1)
  for (j in (1:NROW(modifN[[i]]))){
    if(modifN[[i]][[j]] > -1){
      listmodN[[i]][[j]] <- substr(mod_pep[[i]], modifN[[i]][[j]], modifN[[i]][[j]]+attr(modifN[[i]],"match.length")[[j]]-1)
    }
  }
}

listmodC <- vector("list", NROW(modifC))
for (i in (1:NROW(modifC))){
  listmodC[[i]] <- vector("character",1)
  for (j in (1:NROW(modifC[[i]]))){
    if(modifC[[i]][[j]] > -1){
      listmodC[[i]][[j]] <- substr(mod_pep[[i]], modifC[[i]][[j]], modifC[[i]][[j]]+attr(modifC[[i]],"match.length")[[j]]-1)
    }
  }
}

rtPepUnique[, listMod := listmod]
rtPepUnique[, mod1 := as.character(lapply(listmod, "[[", 1))]
rtPepUnique[, mod2 := as.character(lapply(listmod, "[[", 2))]
rtPepUnique[, mod3 := as.character(lapply(listmod, "[[", 3))]
rtPepUnique[, mod4 := as.character(lapply(listmod, "[[", 4))]
rtPepUnique[, modN := as.character(lapply(listmodN, "[[", 1))]
rtPepUnique[, modC := as.character(lapply(listmodC, "[[", 1))]

setkey(rtPepUnique, sequence, modified_sequence, classification)
setkey(rtPeptide, sequence, modified_sequence, classification)
rtPeptide <- rtPepUnique[rtPeptide]

# Set some condition
rtPeptide <- rtPeptide[mod1=="" & modN=="NH2-" & modC=="-COOH"]
# rtPeptide <- rtPeptide[mod1=="" | mod1=="K<prop>" | mod1=="K<propC13>"]
# rtPeptide <- rtPeptide[(mod1=="M<Mox*>" | mod1=="") & modN=="NH2-"]

rtPeptide[substr(modified_sequence, 1, 4) == "Ace-", elude_sequence := paste0(substr(modified_sequence, 5,5),"[Ace]",substr(modified_sequence, 6, nchar(modified_sequence)))]
rtPeptide[substr(modified_sequence, 1, 4) == "NH2-", elude_sequence := paste0(substr(modified_sequence, 5,5),"",substr(modified_sequence, 6, nchar(modified_sequence)))]
rtPeptide[substr(modified_sequence, 1, 5) == "prop-", elude_sequence := paste0(substr(modified_sequence, 6,6),"[prop]",substr(modified_sequence, 7, nchar(modified_sequence)))]
rtPeptide[substr(modified_sequence, 1, 7) == "propC13-", elude_sequence := paste0(substr(modified_sequence, 8,8),"[prop]",substr(modified_sequence, 9, nchar(modified_sequence)))]

rtPeptide[, elude_sequence := sub("<","[",elude_sequence)]
rtPeptide[, elude_sequence := sub(">","]",elude_sequence)]
rtPeptide[, elude_sequence := sub("-COOH", "", elude_sequence)]
rtPeptide <- rtPeptide[!is.na(elude_sequence)]
# Sometimes there is a modification at the N-terminal and at the first amino acide : not sure if ELUDE can handle that.
# This is very uncommon but for now we'll just remove those cases.
rtPeptide[, error := grepl("\\]\\[", elude_sequence)]
rtPeptide <- rtPeptide[error == FALSE]

# To exclude redundant peptides
rtPeptide <- rtPeptide[index_rt2 <2] 


# First get all the different columns
rtPeptide[, classification.f := factor(classification)]
list_classification <- levels(unique(rtPeptide[,classification.f]))


######
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

setkey(rtPeptide, elude_sequence)
rtPeptideUnique <- unique(rtPeptide)[, list(elude_sequence,q50_3)]

# Stratified sampling : we want to have  more peptides selected at early and late retention times, less in the middle
early <- as.character(7:10)
late <- as.character(18:24)
middle <- as.character(11:17)
earlyCoefficient <- 1
lateCoefficient <- 1
middleCoefficient <- 1
threshold <- 0.07

breaks <- (7:25)*100
rtPeptideUnique[, rtCent := cut(x=q50_3, breaks=((7:25)*100), labels=7:24)]
rtPeptideUnique[, rtCent := as.character(rtCent)]
# We generate a random number between 0 and 1 to decide if we include the peptide or not in the training sample
rtPeptideUnique[, trainRand := runif(NROW(rtPeptideUnique))]

setkey(rtPeptideUnique, rtCent)
rtPeptideUnique[, train := FALSE]
rtPeptideUnique[early, train := (trainRand < (threshold * earlyCoefficient))]
rtPeptideUnique[middle, train := (trainRand < (threshold * middleCoefficient))]
rtPeptideUnique[late, train := (trainRand < (threshold * lateCoefficient))]
rtPeptideUnique[, q50_3 := NULL]
rtPeptideUnique[, test := !train]

setkey(rtPeptide, elude_sequence, classification)
rtPeptideColumn <- unique(rtPeptide)[,list(elude_sequence, classification, nbProjPepProtocolhigh, nbProjPepProtocollow, q50_3)]
setkey(rtPeptideColumn, elude_sequence)
setkey(rtPeptideUnique, elude_sequence)
rtPeptideColumn <- rtPeptideColumn[rtPeptideUnique]

# Condition: peptide appear in both columns (might increase performance because of more reliable identification)
rtPeptideColumn[nbProjPepProtocolhigh == 0 | nbProjPepProtocollow == 0, train := FALSE]
rtPeptideColumn[nbProjPepProtocolhigh == 0 | nbProjPepProtocollow == 0, test := FALSE]

rtPeptideTrain <- rtPeptideColumn[train == TRUE, list(elude_sequence, classification,q50_3)]
rtPeptideTrainLow <- rtPeptideTrain[classification=="low", list(elude_sequence, q50_3)]
rtPeptideTrainHigh <- rtPeptideTrain[classification=="high", list(elude_sequence, q50_3)]


rtPeptideTest <- rtPeptideColumn[test==TRUE, list(elude_sequence, classification, q50_3)]
rtPeptideTestLow <- rtPeptideTest[classification=="low", list(elude_sequence, q50_3)]
rtPeptideTestHigh <- rtPeptideTest[classification=="high", list(elude_sequence, q50_3)]


write.table(rtPeptideTrainLow, file=paste0(projectPath, "/data/rtPeptideTrainLow.txt"), quote = FALSE, sep="\t", row.names = FALSE, col.names = FALSE)
write.table(rtPeptideTestLow, file=paste0(projectPath, "/data/rtPeptideTestLow.txt"), quote = FALSE, , sep="\t", row.names = FALSE, col.names = FALSE)
write.table(rtPeptideTrainHigh, file=paste0(projectPath, "/data/rtPeptideTrainHigh.txt"), quote = FALSE, sep="\t", row.names = FALSE, col.names = FALSE)
write.table(rtPeptideTestHigh, file=paste0(projectPath, "/data/rtPeptideTestHigh.txt"), quote = FALSE, , sep="\t", row.names = FALSE, col.names = FALSE)

# Calling ELUDE from R using the command shell, does it work ?

projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"
trainData <- "/data/rtPeptideTrainLow.txt"
testData <- "/data/rtPeptideTestLow.txt"
saveModel <- "/data/modelLow.model"
saveIndex <- "/data/retentionIndexLow.index"
savePredict <- "/data/predictionsLow.out"

trainData <- shQuote(paste0(projectPath, trainData))
testData <- shQuote(paste0(projectPath, testData))
saveModel <- shQuote(paste0(projectPath, saveModel))
saveIndex <- shQuote(paste0(projectPath, saveIndex))
savePredict <- shQuote(paste0(projectPath, savePredict))

verbFlag <- " -v "
trainFlag <- " -t "
testFlag <- " -e "
saveModelFlag <- " -s "
saveIndexFlag <- " -r "
savePredictFlag <- " -o "
testRTFlag <- " -g "
noInSourceFlag <- " -y "
ignoreNewTestPTMFlag <- " -p "
verbLevel <- " 5"

eludePath <- "C:/Program Files (x86)/Elude"
strCommand <- paste0("cd ",shQuote(eludePath), " && elude ", verbFlag, verbLevel, trainFlag, trainData, testFlag,
                     testData, saveModelFlag, saveModel, saveIndexFlag, saveIndex,
                     savePredictFlag, savePredict, testRTFlag, noInSourceFlag, ignoreNewTestPTMFlag)

shell(strCommand, translate = TRUE, wait = TRUE)


results <- data.table(read.table(file=paste0(projectPath, "/data/predictionsLow.out"), header = TRUE, sep = "\t"))
results[, diff := Predicted_RT - Observed_RT]
setkey(results, Observed_RT)

# View by centile. Quick, but moving average is way better
results[, centile := 1:NROW(results)]
results[, centile := ceiling(100 * centile / NROW(results))]
results[, meanError := mean(diff), by = centile]
results[, q95_pred := quantile(diff, probs = 0.975) - quantile(diff, probs = 0.025), by = centile]
results[, q90_pred := quantile(diff, probs = 0.95) - quantile(diff, probs = 0.05), by = centile]
ggplot(results, aes(centile, meanError)) + geom_point(alpha=(1/2))
ggplot(results, aes(centile, q95_pred)) + geom_point(alpha=(1/2))
ggplot(results, aes(centile, q90_pred)) + geom_point(alpha=(1/2))


for(i in 200:(NROW(results))){
  results[i, movq975 := results[(i-199):i, quantile(diff, probs = 0.975)]]
  results[i, movq025 := results[(i-199):i, quantile(diff, probs = 0.025)]]
  results[i, movq500 := results[(i-199):i, quantile(diff, probs = 0.500)]]
  results[i, movq250 := results[(i-199):i, quantile(diff, probs = 0.250)]]
  results[i, movq750 := results[(i-199):i, quantile(diff, probs = 0.750)]]
}

graphDS <- melt(data = results, 
                id.vars = c("Peptide", "Observed_RT","Predicted_RT"), 
                measure.vars = c("movq025","movq250","movq500","movq750","movq975"),
                variable.name = "quantile",
                value.name = "error")

ggplot(graphDS, aes(Observed_RT, error, colour = quantile)) + geom_point(alpha=(1/2)) + xlim(750,2500)+ ylim(-420,200)

save(graphDS, file = paste0(projectPath,"/plot/graphLow.RData"), compression_level = 1)

trainData <- "/data/rtPeptideTrainHigh.txt"
testData <- "/data/rtPeptideTestHigh.txt"
saveModel <- "/data/modelHigh.model"
saveIndex <- "/data/retentionIndexHigh.index"
savePredict <- "/data/predictionsHigh.out"

trainData <- shQuote(paste0(projectPath, trainData))
testData <- shQuote(paste0(projectPath, testData))
saveModel <- shQuote(paste0(projectPath, saveModel))
saveIndex <- shQuote(paste0(projectPath, saveIndex))
savePredict <- shQuote(paste0(projectPath, savePredict))

strCommand <- paste0("cd ",shQuote(eludePath), " && elude ", verbFlag, verbLevel, trainFlag, trainData, testFlag,
                     testData, saveModelFlag, saveModel, saveIndexFlag, saveIndex,
                     savePredictFlag, savePredict, testRTFlag, noInSourceFlag, ignoreNewTestPTMFlag)

shell(strCommand, translate = TRUE, wait = TRUE)

results <- data.table(read.table(file=paste0(projectPath, "/data/predictionsHigh.out"), header = TRUE, sep = "\t"))
results[, diff := Predicted_RT - Observed_RT]
setkey(results, Observed_RT)

# View by centile. Quick, but moving average is way better
results[, centile := 1:NROW(results)]
results[, centile := ceiling(100 * centile / NROW(results))]
results[, meanError := mean(diff), by = centile]
results[, q95_pred := quantile(diff, probs = 0.975) - quantile(diff, probs = 0.025), by = centile]
results[, q90_pred := quantile(diff, probs = 0.95) - quantile(diff, probs = 0.05), by = centile]



for(i in 200:(NROW(results))){
  results[i, movq975 := results[(i-199):i, quantile(diff, probs = 0.975)]]
  results[i, movq025 := results[(i-199):i, quantile(diff, probs = 0.025)]]
  results[i, movq500 := results[(i-199):i, quantile(diff, probs = 0.500)]]
  results[i, movq250 := results[(i-199):i, quantile(diff, probs = 0.250)]]
  results[i, movq750 := results[(i-199):i, quantile(diff, probs = 0.750)]]
}

graphDS <- melt(data = results, 
                id.vars = c("Peptide", "Observed_RT","Predicted_RT"), 
                measure.vars = c("movq025","movq250","movq500","movq750","movq975"),
                variable.name = "quantile",
                value.name = "error")

ggplot(graphDS, aes(Observed_RT, error, colour = quantile)) + geom_point(alpha=(1/2)) + xlim(750,2500)+ ylim(-420,200)

save(graphDS, file = paste0(projectPath,"/plot/graphHigh.RData"), compression_level = 1)

load(file = paste0(projectPath,"/plot/graphLow.RData"))
write.csv(graphDS, file = paste0(projectPath,"/plot/graphLow.csv"))
load(file = paste0(projectPath,"/plot/graphHigh.RData"))
write.csv(graphDS, file = paste0(projectPath,"/plot/graphHigh.csv"))



diffColumns <- rtPeptideTestLow
diffColumns[, q50_3_low := q50_3]
diffColumns[, q50_3 := NULL]

setkey(diffColumns, elude_sequence)
setkey(rtPeptideTestHigh, elude_sequence)

diffColumns <- diffColumns[rtPeptideTestHigh]
diffColumns[, q50_3_high := q50_3]
diffColumns[, q50_3 := NULL]

diffColumns[, diff := q50_3_high - q50_3_low]
setkey(diffColumns, diff)
diffColumns[, index := 1:NROW(diffColumns)]

ggplot(diffColumns, aes(index, diff)) + geom_point() + ylim(-100,200)

setkey(diffColumns, q50_3_high)

for(i in 500:(NROW(diffColumns))){
  diffColumns[i, movq975 := diffColumns[(i-199):i, quantile(diff, probs = 0.975)]]
  diffColumns[i, movq025 := diffColumns[(i-199):i, quantile(diff, probs = 0.025)]]
  diffColumns[i, movq500 := diffColumns[(i-199):i, quantile(diff, probs = 0.500)]]
  diffColumns[i, movq250 := diffColumns[(i-199):i, quantile(diff, probs = 0.250)]]
  diffColumns[i, movq750 := diffColumns[(i-199):i, quantile(diff, probs = 0.750)]]
}

graphDS <- melt(data = diffColumns, 
                id.vars = c("index", "q50_3_low","q50_3_high"), 
                measure.vars = c("movq025","movq250","movq500","movq750","movq975"),
                variable.name = "quantile",
                value.name = "error")

ggplot(graphDS, aes(q50_3_high, error, colour = quantile)) + geom_point(alpha=(1/2)) + xlim(750,2500)+ ylim(-100,200)


ggplot(diffColumns, aes(diff)) + xlim(-100,200)+ geom_histogram(aes(y = ..density..), binwidth = 5)

ggplot(diffColumns[q50_3_low > 700 & q50_3_low < 800], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 800 & q50_3_low < 900], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 900 & q50_3_low < 1000], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 1000 & q50_3_low < 1100], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 1100 & q50_3_low < 1200], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 1200 & q50_3_low < 1300], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 1300 & q50_3_low < 1400], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 1400 & q50_3_low < 1500], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 1500 & q50_3_low < 1600], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_low > 1600 & q50_3_low < 1700], aes(diff)) + xlim(-100,240) + geom_density()

ggplot(diffColumns[q50_3_high > 700 & q50_3_high < 800], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 800 & q50_3_high < 900], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 900 & q50_3_high < 1000], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 1000 & q50_3_high < 1100], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 1100 & q50_3_high < 1200], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 1200 & q50_3_high < 1300], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 1300 & q50_3_high < 1400], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 1400 & q50_3_high < 1500], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 1500 & q50_3_high < 1600], aes(diff)) + xlim(-100,240) + geom_density()
ggplot(diffColumns[q50_3_high > 1600 & q50_3_high < 1700], aes(diff)) + xlim(-100,240) + geom_density()