library(data.table)
library(ggplot2)

projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"

load(file = paste0(projectPath,"/data/filtered_id.RData"))

setkey(rtPeptide, modified_sequence)
rtPepUnique <- unique(rtPeptide)[,list(sequence, modified_sequence)]

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

setkey(rtPepUnique, sequence, modified_sequence)
setkey(rtPeptide, sequence, modified_sequence)
rtPeptide <- rtPepUnique[rtPeptide]

# rtPeptide <- rtPeptide[mod1=="" | mod1=="K<prop>" | mod1=="K<propC13>"]
rtPeptide <- rtPeptide[mod1=="" & modN=="NH2-" & modC=="-COOH"]
rtPeptide <- rtPeptide[(mod1=="M<Mox*>" | mod1=="" | mod1=="C<Cmm*>" | mod1=="K<c13>" | mod1=="R<C13>" | mod1=="Q<Pyr>") &
                         modN=="NH2-" & mod2!="M<Mox>" & mod3!="M<Mox>" & mod4!="M<Mox>"]

table(test[, mod1])

rtPeptide[substr(modified_sequence, 1, 4) == "Ace-", elude_sequence := paste0(substr(modified_sequence, 5,5),"[Ace]",substr(modified_sequence, 6, nchar(modified_sequence)))]
rtPeptide[substr(modified_sequence, 1, 4) == "NH2-", elude_sequence := paste0(substr(modified_sequence, 5,5),"",substr(modified_sequence, 6, nchar(modified_sequence)))]
rtPeptide[substr(modified_sequence, 1, 5) == "prop-", elude_sequence := paste0(substr(modified_sequence, 6,6),"[prop]",substr(modified_sequence, 7, nchar(modified_sequence)))]
rtPeptide[substr(modified_sequence, 1, 7) == "propC13-", elude_sequence := paste0(substr(modified_sequence, 8,8),"[prop]",substr(modified_sequence, 9, nchar(modified_sequence)))]

rtPeptide[, elude_sequence := gsub("<","[",elude_sequence)]
rtPeptide[, elude_sequence := gsub(">","]",elude_sequence)]
rtPeptide[, elude_sequence := sub("-COOH", "", elude_sequence)]
rtPeptide <- rtPeptide[!is.na(elude_sequence)]
# Sometimes there is a modification at the N-terminal and at the first amino acide : not sure if ELUDE can handle that.
# This is very uncommon but for now we'll just remove those cases.
rtPeptide[, error := grepl("\\]\\[", elude_sequence)]
rtPeptide <- rtPeptide[error == FALSE]

# To exclude redundant peptides
rtPeptide <- rtPeptide[index_rt2 <2]
# The filter on rt makes median too compact at the end
# Also, better to filter out the very beginning
rtPeptide <- rtPeptide[q50_5 > 750 & q50_5 < 1750]

setkey(rtPeptide, elude_sequence)
rtPeptideUnique <- unique(rtPeptide)[, list(elude_sequence,q50_3,q50_5)]
rtPeptideUnique <- rtPeptideUnique[!grepl("[BJOUXZ]",elude_sequence)]

# Stratified sampling : we want to have  more peptides selected at early and late retention times, less in the middle
early <- as.character(7:10)
late <- as.character(18:24)
middle <- as.character(11:17)
earlyCoefficient <- 1
lateCoefficient <- 1
middleCoefficient <- 1
threshold <- 0.03

breaks <- (7:25)*100
rtPeptideUnique[, rtCent := cut(x=q50_5, breaks=((7:25)*100), labels=7:24)]
rtPeptideUnique[, rtCent := as.character(rtCent)]
# We generate a random number between 0 and 1 to decide if we include the peptide or not in the training sample
rtPeptideUnique[, trainRand := runif(NROW(rtPeptideUnique))]

setkey(rtPeptideUnique, rtCent)
rtPeptideUnique[, train := FALSE]
rtPeptideUnique[early, train := (trainRand < (threshold * earlyCoefficient))]
rtPeptideUnique[middle, train := (trainRand < (threshold * middleCoefficient))]
rtPeptideUnique[late, train := (trainRand < (threshold * lateCoefficient))]

# ggplot(rtPeptideUnique[train==TRUE], aes(rtCent)) + geom_histogram()

rtPeptideTrain <- rtPeptideUnique[train==TRUE, list(elude_sequence, q50_5)]
# modified_sequence is included because it's the key, but I suspect this kind of behavior to change, so check.
# We want to assess the performance of the algorithm on the actual retention time observed, not the median.
setkey(rtPeptide, elude_sequence)
rtPeptideTest <- rtPeptide[rtPeptideUnique[train == FALSE, elude_sequence], corrected_RT]

setkey(rtPeptideUnique, elude_sequence)
setkey(rtPeptide, elude_sequence)
rtPeptideTestMedian  <- unique(rtPeptide[rtPeptideUnique[train == FALSE, elude_sequence]])[, list(elude_sequence,q50_5)][1]

write.table(rtPeptideTrain, file=paste0(projectPath, "/data/rtPeptideTrain.txt"), quote = FALSE, sep="\t", row.names = FALSE, col.names = FALSE)
write.table(rtPeptideTest, file=paste0(projectPath, "/data/rtPeptideTest.txt"), quote = FALSE, , sep="\t", row.names = FALSE, col.names = FALSE)
write.table(rtPeptideTestMedian, file=paste0(projectPath, "/data/rtPeptideTestMedian.txt"), quote = FALSE, , sep="\t", row.names = FALSE, col.names = FALSE)

# Calling ELUDE from R using the command shell, does it work ?

projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"
trainData <- "/data/rtPeptideTrain.txt"
testData <- "/data/rtPeptideTestMedian.txt"
saveModel <- "/data/modelHydrophil.model"
saveIndex <- "/data/retentionIndexHydrophil.index"
savePredict <- "/data/predictions.out"

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
                     savePredictFlag, savePredict, testRTFlag, ignoreNewTestPTMFlag)

# elude -v 4 -t "C:\Users\Nicolas Housset\Documents\RetentionTimeAnalysis\data\rtPeptideTrain.txt" -e "C:\Users\Nicolas Housset\Documents\RetentionTimeAnalysis\data\rtPeptideTest.txt" -s "C:\Users\Nicolas Housset\Documents\RetentionTimeAnalysis\data\modelTest" -r "C:\Users\Nicolas Housset\Documents\RetentionTimeAnalysis\data\retentionIndexTest" -o "C:\Users\Nicolas Housset\Documents\RetentionTimeAnalysis\data\predictions.out" -g -p

# Alright, the trick is to change the working directory to ELUDE's
shell(strCommand, translate = TRUE, wait = TRUE)


rtPeptideTestMedian  <- unique(rtPeptide[rtPeptideUnique[train == FALSE, elude_sequence]])[, list(elude_sequence,q50_5)]
write.table(rtPeptideTestMedian, file=paste0(projectPath, "/data/rtPeptideTestMedian.txt"), quote = FALSE, , sep="\t", row.names = FALSE, col.names = FALSE)
testData <- "/data/rtPeptideTestMedian.txt"
testData <- shQuote(paste0(projectPath, testData))

savePredict <- "/data/predictionsTestMedian.out"
savePredict <- shQuote(paste0(projectPath, savePredict))

loadModelFlag <- " -l "

# This time we apply the model on the testing data, but using the median
eludePath <- "C:/Program Files (x86)/Elude"
strCommand <- paste0("cd ",shQuote(eludePath), " && elude ", verbFlag, verbLevel, testFlag,
                     testData, loadModelFlag, saveModel,
                     savePredictFlag, savePredict, testRTFlag, ignoreNewTestPTMFlag)
shell(strCommand, translate = TRUE, wait = TRUE)


results <- data.table(read.table(file=paste0(projectPath, "/data/predictionsTestMedian.out"), header = TRUE, sep = "\t"))
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


for(i in 400:(NROW(results))){
  results[i, movq975 := results[(i-399):i, quantile(diff, probs = 0.975)]]
  results[i, movq025 := results[(i-399):i, quantile(diff, probs = 0.025)]]
  results[i, movq500 := results[(i-399):i, quantile(diff, probs = 0.500)]]
  results[i, movq250 := results[(i-399):i, quantile(diff, probs = 0.250)]]
  results[i, movq750 := results[(i-399):i, quantile(diff, probs = 0.750)]]
}

graphDS <- melt(data = results, 
                id.vars = c("Peptide", "Observed_RT","Predicted_RT"), 
                measure.vars = c("movq025","movq250","movq500","movq750","movq975"),
                variable.name = "quantile",
                value.name = "error")

ggplot(graphDS, aes(Observed_RT, error, colour = quantile)) + geom_point(alpha=(1/2)) + xlim(750,1750)+ ylim(-300,160)
ggplot(results, aes(Observed_RT, movq975 - movq025)) + geom_point(alpha=(1/2)) + xlim(750,1750)

save(graphDS, file = paste0(projectPath,"/plot/graphLow.RData"), compression_level = 1)

ggplot(rtPeptideUnique, aes(q50_5)) + xlim(700,1900) + geom_histogram(aes(y = ..density..), binwidth = 10)
