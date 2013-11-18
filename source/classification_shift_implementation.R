projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"
load(file = paste0(projectPath,"/data/corrected_id.RData"))

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

# A cross-product, to interpolate the correction on a precise point (to avoid "border effects")
compute_correction <- function(raw_rt,quartile, ...){
  return(list_correction[quartile, correction] + ((raw_rt- list_correction[quartile, quartiles])/(list_correction[quartile+1, quartiles]-list_correction[quartile, quartiles])) * (list_correction[quartile+1,correction] - list_correction[quartile,correction]))
}

# Initializing the database of corrections applied
dt_correction <- data.table(1:5)
dt_correction[, quartiles := 1:5]
dt_correction[, correction := 0.0]
dt_correction[, group := "high07"]
dt_correction[, V1 := NULL]

# The group chosen as reference is obviously not included
list_group <- list("low01","low02","low03","low04","low05","low06","low07","low08",
                   "high01","high02","high03","high04","high05","high06", "high08")
# Getting common peptides for each reference/non-reference pair and applying the correction
for(i in 1:15){
  list_correction <- diffByQuartile("high07",list_group[[i]])
  list_correction[1, correction := list_correction[2, correction]*2 - list_correction[3, correction]]
  list_correction[, group := list_group[[i]]]
  dt_correction <- rbind(dt_correction, list_correction)
  
  rtPeptide[rtsec <= list_correction[2, quartiles], group_quartile := as.character(1)]
  rtPeptide[rtsec > list_correction[2, quartiles] &
              rtsec <= list_correction[3, quartiles], group_quartile := as.character(2)]
  rtPeptide[rtsec > list_correction[3, quartiles] &
              rtsec <= list_correction[4, quartiles], group_quartile := as.character(3)]
  rtPeptide[rtsec > list_correction[4, quartiles], group_quartile := as.character(4)]
  
  setkey(rtPeptide, classification.f, group_quartile)
  
  rtPeptide[c(list_group[[i]],"1"), corrected_RT := rtsec + compute_correction(rtsec,1)]
  rtPeptide[c(list_group[[i]],"2"), corrected_RT := rtsec + compute_correction(rtsec, 2)]
  rtPeptide[c(list_group[[i]],"3"), corrected_RT := rtsec + compute_correction(rtsec, 3)]
  rtPeptide[c(list_group[[i]],"4"), corrected_RT := rtsec + compute_correction(rtsec,4)]
}

rtPeptide["high07", corrected_RT := rtsec]

setkey(rtPeptide, modified_sequence)
# ggplot(rtPeptide, aes(rtsec)) + xlim(600,2400)+ geom_histogram(aes(y = ..density..), binwidth = 20)
# ggplot(rtPeptide, aes(corrected_RT)) + xlim(600,2400)+ geom_histogram(aes(y = ..density..), binwidth = 20)

rtPeptide <- rtPeptide[corrected_RT > 700 & corrected_RT < 1860]
# Filter for non linearly correted rt
# rtPeptide <- rtPeptide[corrected_RT > 700 & corrected_RT < 1810]
rtPeptide[, raw_corrected_RT := corrected_RT]
# rtPeptide[, corrected_RT := raw_corrected_RT]
rtPeptide[raw_corrected_RT <= 1170, corrected_RT := 320 + 0.77778 * raw_corrected_RT]
rtPeptide[raw_corrected_RT > 1170, corrected_RT := 320 + 0.77778 * raw_corrected_RT]

# To exclude redundant peptides
rtPeptide <- rtPeptide[index_rt2 <2]

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

save(rtPeptide, file = paste0(projectPath,"/data/filtered_id.RData"), compression_level=1)
write.csv(rtPeptide, file = paste0(projectPath,"/data/filtered_id.csv"))




####

rtPeptide[,rank_peptide := as.character(rank_peptide)]
setkey(rtPeptide, rank_peptide)
rtPeptide[, sdRawRT := sd(rtsec), by = rank_peptide]
rtPeptide[, sdNewRT := sd(corrected_RT), by = rank_peptide]
rtPeptide[, sdReduction := sdRawRT - sdNewRT]
rtPeptide[, sdDrop := ((sdReduction / sdRawRT))*100]

unique(rtPeptide)[as.character(3001:3100)][, list(modified_sequence, sdRawRT, sdNewRT, sdReduction, sdDrop, nbProjPep)]

ggplot(rtPeptide["2"], aes(rtsec)) + xlim(800,2000) + ylim(0,0.02) + geom_histogram(aes(y = ..density..), binwidth = 10)
ggplot(rtPeptide["2"], aes(corrected_RT)) + xlim(800,2000) + ylim(0,0.02) + geom_histogram(aes(y = ..density..), binwidth = 10)

ggplot(rtPeptide[nbProjPep <= 8], aes(sdReduction)) + geom_histogram(aes(y = ..density..), binwidth = 3)
ggplot(rtPeptide[nbProjPep > 2], aes(sdDrop)) + xlim(-30, 100)+ geom_histogram(aes(y = ..density..), binwidth = 5)

ggplot(rtPeptide[nbProjPep > 1], aes(sdRawRT)) + xlim(0,120) + ylim(0,0.05) + geom_histogram(aes(y = ..density..), binwidth = 3) + theme(text = element_text(size = 30), panel.background = element_blank(), panel.grid = element_blank())
ggplot(rtPeptide[nbProjPep > 1], aes(sdNewRT)) + xlim(0,120) + ylim(0,0.05) + geom_histogram(aes(y = ..density..), binwidth = 3)+ theme(text = element_text(size = 30), panel.background = element_blank(), panel.grid = element_blank())