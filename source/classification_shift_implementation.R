

# Finally, the awaited correction of the shift...
setkey(rtPeptide, classification.f)

rtPeptide["low01", corrected_RT := rtsec]
rtPeptide["low02", corrected_RT := rtsec - 20]
rtPeptide["low03", corrected_RT := rtsec - 50]
rtPeptide["low04", corrected_RT := rtsec - 100]
rtPeptide["high01", corrected_RT := rtsec - 70]
rtPeptide["high02", corrected_RT := rtsec - 50]
rtPeptide["high03", corrected_RT := rtsec - 120]
rtPeptide["high04", corrected_RT := rtsec - 120]

setkey(rtPeptide, modified_sequence)
rtPeptide[, q50_5 := quantile(corrected_RT, probs = 0.50), by = c("modified_sequence")]

setkey(rtPeptide, index, modified_sequence)
countsPerProject <- unique(rtPeptide)[, list(index,modified_sequence, classification.f)]
countsPerProject[, modified_sequence.f := factor(modified_sequence)]

nbProjPerPeptide <- summary(countsPerProject[, modified_sequence.f], maxsum = 1000000)
id_peptide <- 1:NROW(nbProjPerPeptide)
dt <- data.table(id_peptide)
dt[, modified_sequence := labels(nbProjPerPeptide)]
dt[, nbProjPep := -nbProjPerPeptide]
# This ordering makes most common peptides appear first
setkey(dt, nbProjPep)
# We save the rank
dt[, rank_peptide := 1:NROW(nbProjPerPeptide)]
# Number of projects is brought back to a positive number
dt[, nbProjPep := -nbProjPep]

setkey(dt, modified_sequence)
setkey(rtPeptide, modified_sequence)
rtPeptide <- rtPeptide[dt]

save(rtPeptide, file = paste0(projectPath,"/data/corrected_id.RData"), compression_level=1)
write.csv(rtPeptide, file = paste0(projectPath,"/data/corrected_id.csv"))

rtPeptide <- rtPeptide[corrected_RT > 600]

rtPeptide[,rank_peptide := as.character(rank_peptide)]
setkey(rtPeptide, rank_peptide)
rtPeptide[, sdRawRT := sd(rtsec), by = rank_peptide]
rtPeptide[, sdNewRT := sd(corrected_RT), by = rank_peptide]
rtPeptide[, sdReduction := sdRawRT - sdNewRT]
rtPeptide[, sdDrop := (1- (sdReduction / sdRawRT))*100]

unique(rtPeptide)[as.character(3001:3100)][, list(modified_sequence, sdRawRT, sdNewRT, sdReduction, sdDrop, nbProjPep)]

ggplot(rtPeptide["2"], aes(rtsec)) + xlim(1300,1800) + ylim(0,0.02) + geom_histogram(aes(y = ..density..), binwidth = 10)
ggplot(rtPeptide["2"], aes(corrected_RT)) + xlim(1300,1800) + ylim(0,0.02) + geom_histogram(aes(y = ..density..), binwidth = 10)

ggplot(rtPeptide[nbProjPep <= 8], aes(sdReduction)) + geom_histogram(aes(y = ..density..), binwidth = 3)

ggplot(rtPeptide[nbProjPep > 1], aes(sdRawRT)) + xlim(0,120) + ylim(0,0.04) + geom_histogram(aes(y = ..density..), binwidth = 3)
ggplot(rtPeptide[nbProjPep > 1], aes(sdNewRT)) + xlim(0,120) + ylim(0,0.04) + geom_histogram(aes(y = ..density..), binwidth = 3)