
list_runs[, group_run := as.character(group_run)]
setkey(list_runs, group_run, index)

list_runs[list(as.character(0)), classification := "exclude"]

list_runs[list(as.character(1),as.character((5204:5207)*2+1)), classification := "low"]
list_runs[list(as.character(1),as.character((5205:5208)*2)), classification := "high"]
list_runs[list(as.character(1),as.character((5217:5219)*2+1)), classification := "high"]
list_runs[list(as.character(1),as.character((5218:5219)*2)), classification := "low"]

list_runs[list(as.character(2),as.character((5375:5386)*2+1)), classification := "high"]
list_runs[list(as.character(2),as.character((5735:5386)*2)), classification := "low"]

list_runs[list(as.character(3),as.character((5429:5436)*2+1)), classification := "high"]
list_runs[list(as.character(3),as.character((5429:5436)*2)), classification := "low"]

list_runs[list(as.character(4),as.character(10728:10729)), classification := "very high"]

list_runs[list(as.character(5),as.character((5518:5543)*2+1)), classification := "high"]
list_runs[list(as.character(5),as.character((5519:5544)*2)), classification := "low"]

list_runs[list(as.character(6),as.character((5514:5515)*2+1)), classification := "exclude"]
list_runs[list(as.character(6),as.character((5515:5516)*2)), classification := "exclude"]
list_runs[list(as.character(6),as.character(11363)), classification := "exclude"]
list_runs[list(as.character(6),as.character(11365)), classification := "exclude"]
list_runs[list(as.character(6),as.character(c(11364,11366))), classification := "exclude"]

list_runs[list(as.character(7),as.character(11352:11355)), classification := "exclude"]
list_runs[list(as.character(7),as.character(11356:11360)), classification := "exclude"]

list_runs[list(as.character(8),as.character(11543:11544)), classification := "exclude"]

list_runs[list(as.character(9),as.character(11538:11540)), classification := "low"]

list_runs[list(as.character(10),as.character((5743:5756)*2+1)), classification := "low"]
list_runs[list(as.character(10),as.character((5744:5756)*2)), classification := "high"]

list_runs[list(as.character(11),as.character(11555:11557)), classification := "low"]
list_runs[list(as.character(11),as.character(c(12793,12795))), classification := "low"]
list_runs[list(as.character(11),as.character(c(12794))), classification := "high"]

list_runs[list(as.character(12),as.character((5858:5868)*2-1)), classification := "high_AceProp"]
list_runs[list(as.character(12),as.character((5858:5868)*2)), classification := "low_AceProp"]

list_runs[list(as.character(13),as.character(99999)), classification := "very high"]

list_runs[list(as.character(14),as.character((5803:5813)*2-1)), classification := "high"]
list_runs[list(as.character(14),as.character((5803:5816)*2)), classification := "low"]

list_runs[list(as.character(15),as.character(c((12239:12260),(12287:12308),(12560:12580)))), classification := "exclude"]

list_runs[list(as.character(16),as.character((5967:5968)*2-1)), classification := "low"]
list_runs[list(as.character(16),as.character((5967:5968)*2)), classification := "high"]

list_runs[list(as.character(17),as.character((5932)*2-1)), classification := "low"]
list_runs[list(as.character(17),as.character((5932)*2)), classification := "high"]

list_runs[list(as.character(18),as.character((5933:5940)*2-1)), classification := "low"]
list_runs[list(as.character(18),as.character((5933:5940)*2)), classification := "high"]

list_runs[list(as.character(19),as.character(c((12353:12372),(12499)))), classification := "exclude"]

list_runs[list(as.character(20),as.character((6243:6245)*2+1)), classification := "low_AceProp"]
list_runs[list(as.character(20),as.character((6243:6246)*2)), classification := "high_AceProp"]

list_runs[list(as.character(21),as.character((6357:6359)*2-1)), classification := "high"]
list_runs[list(as.character(21),as.character((6357:6359)*2)), classification := "low"]

list_runs[list(as.character(22),as.character(12719:12720)), classification := "exclude"]

list_runs[list(as.character(23),as.character(c(((6547:6558)*2+1),((6567:6578)*2+1)))), classification := "high"]
list_runs[list(as.character(23),as.character(c(((6547:6558)*2),((6567:6578)*2)))), classification := "low"]

list_runs[list(as.character(24),as.character((6489)*2-1)), classification := "low"]
list_runs[list(as.character(24),as.character((6489)*2)), classification := "high"]

list_runs[list(as.character(25),as.character(13276:13317)), classification := "exclude"]

list_runs[list(as.character(26),as.character(c(13251,13253))), classification := "very high"]
list_runs[list(as.character(26),as.character(13252)), classification := "very high"]
list_runs[list(as.character(26),as.character(13254:13258)), classification := "very high"]

list_runs[list(as.character(27),as.character((6991:7000)*2+1)), classification := "high_AceProp"]
list_runs[list(as.character(27),as.character((6991:7000)*2)), classification := "low_AceProp"]

list_runs[list(as.character(28),c("03816","03817","03818","03819","03820","03821","03822","09636","09642")), classification := "exclude"]

list_runs[list(as.character(29),as.character(13545:13586)), classification := "exclude"]

list_runs[list(as.character(30),as.character((6660:6691)*2+1)), classification := "high"]
list_runs[list(as.character(30),as.character((6660:6691)*2)), classification := "low"]

list_runs[list(as.character(31),as.character((6732:6734)*2-1)), classification := "high"]
list_runs[list(as.character(31),as.character((6732:6734)*2)), classification := "low"]

list_runs[list(as.character(32),as.character((6914:6925)*2+1)), classification := "low"]
list_runs[list(as.character(32),as.character((6914:6925)*2)), classification := "high"]

list_runs[list(as.character(33),as.character((6803:6812)*2+1)), classification := "low"]
list_runs[list(as.character(33),as.character((6803:6812)*2)), classification := "high"]

list_runs[list(as.character(34),as.character(c(13589,13591))), classification := "low"]

list_runs[list(as.character(35),as.character(c(13595,13597,13599,13601))), classification := "low"]
list_runs[list(as.character(35),as.character(c(13603))), classification := "exclude"]

list_runs[list(as.character(36),as.character((6876:6896)*2+1)), classification := "low"]
list_runs[list(as.character(36),as.character((6876:6896)*2)), classification := "high"]
list_runs[list(as.character(36),as.character(13890:13893)), classification := "high"]

list_runs[list(as.character(37),as.character((6909:6910)*2+1)), classification := "low"]
list_runs[list(as.character(37),as.character((6909:6910)*2)), classification := "high"]

list_runs[list(as.character(38),as.character((6939)*2-1)), classification := "low"]
list_runs[list(as.character(38),as.character((6939)*2)), classification := "high"]

list_runs[list(as.character(39),as.character((6936)*2+1)), classification := "low_AceProp"]
list_runs[list(as.character(39),as.character((6936:6937)*2)), classification := "high_AceProp"]

list_runs[list(as.character(40),as.character((6905:6907)*2+1)), classification := "low"]
list_runs[list(as.character(40),as.character((6905:6907)*2)), classification := "high"]

list_runs[list(as.character(41),as.character((7002:7021)*2+1)), classification := "high"]
list_runs[list(as.character(41),as.character((7002:7021)*2)), classification := "low"]

list_runs[list(as.character(42),as.character(14077:14079)), classification := "exclude"]

list_runs[list(as.character(43),as.character(13896:13898)), classification := "exclude"]

list_runs[list(as.character(44),as.character(14166)), classification := "low"]
list_runs[list(as.character(44),as.character(14167)), classification := "high"]

list_runs[list(as.character(45),as.character((7558:7567)*2+1)), classification := "high"]
list_runs[list(as.character(45),as.character((7558:7567)*2)), classification := "low"]

list_runs[list(as.character(46),as.character((7208:7227)*2+1)), classification := "high"]
list_runs[list(as.character(46),as.character((7208:7227)*2)), classification := "low"]

list_runs[list(as.character(47),as.character(c(((7569:7578)*2+1),((7594:7603)*2+1)))), classification := "high_AceProp"]
list_runs[list(as.character(47),as.character(c(((7569:7578)*2),((7594:7603)*2)))), classification := "low_AceProp"]

# At first I thought ohel, but vizualising into Spotfire it's clearly oleh. Everyone makes mistakes hey !
list_runs[list(as.character(48),as.character(c(((7195:7204)*2-1),((7233:7238)*2+1)))), classification := "low"]
list_runs[list(as.character(48),as.character(c(((7195:7204)*2),((7233:7238)*2)))), classification := "high"]

list_runs[list(as.character(49),as.character(c(((7285:7286)*2-1),((7298:7299)*2-1)))), classification := "high"]
list_runs[list(as.character(49),as.character(c(((7285:7286)*2),((7298:7299)*2)))), classification := "low"]

list_runs[list(as.character(50),as.character(14633:14636)), classification := "exclude"]

list_runs[list(as.character(51),as.character(c(14649,14651))), classification := "low"]

list_runs[list(as.character(52),as.character((7406:7426)*2-1)), classification := "low"]
list_runs[list(as.character(52),as.character((7406:7426)*2)), classification := "high"]

list_runs[list(as.character(53),as.character((7428:7437)*2+1)), classification := "low"]
list_runs[list(as.character(53),as.character((7428:7437)*2)), classification := "high"]
list_runs[list(as.character(53),as.character((7466:7467)*2+1)), classification := "high"]
list_runs[list(as.character(53),as.character((7466:7467)*2)), classification := "low"]

# I get mostly modified peptides in this kind of experient, need to ask An about that.
list_runs[list(as.character(54),as.character(c((14881:14922),(15026:15067)))), classification := "exclude_propAce"]

list_runs[list(as.character(55),as.character((15048:15067))), classification := "exclude_propAce"]

list_runs[list(as.character(56),as.character(c(((7354:7369)*2-1),((7392:7396)*2-1)))), classification := "low"]
list_runs[list(as.character(56),as.character(c(((7354:7369)*2),((7392:7396)*2)))), classification := "high"]

list_runs[list(as.character(57),as.character((7469:7489)*2+1)), classification := "high"]
list_runs[list(as.character(57),as.character((7469:7489)*2)), classification := "low"]

list_runs[list(as.character(58),as.character((7396:7398)*2+1)), classification := "low"]
list_runs[list(as.character(58),as.character((7396:7398)*2)), classification := "high"]

list_runs[list(as.character(59),as.character((15070:15089))), classification := "exclude_propAce"]

# Need to review this classification eventually
list_runs[list(as.character(60),as.character((7491:7503)*2+1)), classification := "high"]
list_runs[list(as.character(60),as.character((7491:7503)*2)), classification := "low"]
list_runs[list(as.character(60),as.character((7504:7510)*2+1)), classification := "low"]
list_runs[list(as.character(60),as.character((7504:7510)*2)), classification := "high"]

list_runs[list(as.character(61),as.character((15245:15308))), classification := "exclude_propAce"]

list_runs[list(as.character(62),as.character((15030:15045))), classification := "exclude_virotrap"]

list_runs[list(as.character(63),as.character((7656:7665)*2-1)), classification := "low_AceProp"]
list_runs[list(as.character(63),as.character((7656:7665)*2)), classification := "high_AceProp"]

list_runs[list(as.character(64),as.character((7678:7687)*2-1)), classification := "high_AceProp"]
list_runs[list(as.character(64),as.character((7678:7687)*2)), classification := "low_AceProp"]
list_runs[list(as.character(64),as.character(c(15361,15363,15365))), classification := "exclude"]

list_runs[list(as.character(65),as.character((15415:15500))), classification := "exclude_propAce"]

list_runs[list(as.character(66),as.character(c((15629:15648),(15673:15692)))), classification := "exclude_propAce"]

list_runs[list(as.character(67),as.character((15771:15790))), classification := "exclude_propAce"]

list_runs[list(as.character(68),as.character((15651:15670))), classification := "exclude_propAce"]

list_runs[list(as.character(69),as.character((15793:15834))), classification := "exclude_propAce"]
list_runs[list(as.character(69),as.character((15910:15929))), classification := "exclude_propAce"]

list_runs[list(as.character(70),as.character((16013:16016))), classification := "exclude"]

list_runs[list(as.character(71),as.character((8071:8074)*2+1)), classification := "exclude"]
list_runs[list(as.character(71),as.character((8071:8074)*2)), classification := "exclude"]
list_runs[list(as.character(71),as.character(c(16142,16149))), classification := "exclude"]

list_runs[list(as.character(72),as.character((6008:6010)*2-1)), classification := "high"]
list_runs[list(as.character(72),as.character((6008:6010)*2)), classification := "low"]
list_runs[list(as.character(72),as.character(c(12856))), classification := "exclude"]


setkey(list_runs, l_projectid, l_lcrunid, index)
setkey(identified_subs, l_projectid, l_lcrunid, index)
# Adding the column information and deciding to include if this run will be included in the retention time calculation
# may be considered as annotating. Took some time, I hope it's worth it. Let's visualize in Spotfire !
annotated_id <- identified_subs[list_runs]

# Statistics computed on rt measurements where index_rt2 < 5 : 4 most intense spectrum of the peptide per LC-run

annotated_id[index_rt2 <3, q50_3 := quantile(rtsec, probs = 0.50), by = c("classification","modified_sequence")]

save(annotated_id, file = paste0(projectPath,"/data/annotated_id.RData"), compression_level=1)
write.csv(annotated_id, file = paste0(projectPath,"/data/annotated_id.csv"))
 