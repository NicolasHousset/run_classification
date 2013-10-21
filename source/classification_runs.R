# Starting project : 2065
# Ending project : ???

# We restrict ourselves to Vanessa
# Classification in Low/High/Very high retention times
# The latter one is to put apart some weird experiments

projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"


load(file = paste0(projectPath,"/data/identified_protocol.RData"))

setkey(identified_subs, l_projectid)
test <- identified_subs[l_protocolid == "11"][, list(l_projectid, l_lcrunid, index, sequence, modified_sequence, index_rt2, l_protocolid, rtsec, q50_2)]

setkey(test, l_projectid, l_lcrunid, index)
list_runs <- unique(test)[,list(l_projectid, l_lcrunid, index)]

setkey(list_runs, l_projectid)

# Classification put in commentary will be based on the local index, which I hope is more reliable than lcrunid, at least locally

list_runs[as.character(2065:2079), group_run := 1L] # 10409:10416 : oleh ; 10435:10439 : ohel
list_runs[as.character(2104), group_run := 2L] # All low, but I would be cautious
list_runs[as.character(2127:2142), group_run := 3L] # ohel, very confident
list_runs[as.character(2143), group_run := 4L] # very high, test 90 min from Jonathan
list_runs[as.character(2150:2151), group_run := 5L] # ohel
list_runs[as.character(2154:2157), group_run := 6L] # ohel
list_runs[as.character(2169:2172), group_run := 6L] # repeat of 2154:2157 ; exclude 11363, oleh
list_runs[as.character(2181:2189), group_run := 7L] # 11352:11355 low ; 11356:11360 high. Unusual indeed.
list_runs[as.character(2196:2197), group_run := 8L] # exclude everything, there is not much stuff anyway
list_runs[as.character(2210:2212), group_run := 9L] # all low
list_runs[as.character(2229:2243), group_run := 10L] # oleh (thanks to contaminants)
list_runs[as.character(2247:2252), group_run := 11L] # 11555:11557 low ; 12793 and 12795 low, 12794 high
list_runs[as.character(2253), group_run := 12L] # ohel
list_runs[as.character(2263), group_run := 13L] # This one is a "very high"
list_runs[as.character(2264:2278), group_run := 14L] # ohel
list_runs[as.character(2281:2283), group_run := 15L] # Jonathan having fun, discard
list_runs[as.character(2287:2290), group_run := 16L] # oleh
list_runs[as.character(2315:2316), group_run := 17L] # oleh
list_runs[as.character(c(2319,2321,2323,2325,2326,2327,2329,2331,2333,2334,2337,2338,2339,2340)), group_run := 18L] # oleh
list_runs[as.character(c(2364,2370)), group_run := 19L] # Jonathan having fun, discard
list_runs[as.character(2369), group_run := 20L] # oleh
list_runs[as.character(2381:2386), group_run := 21L] # ohel
list_runs[as.character(2389:2390), group_run := 22L] # Jonathan having fun, discard
list_runs[as.character(2405:2406), group_run := 23L] # ohel
list_runs[as.character(2414:2415), group_run := 24L] # oleh
list_runs[as.character(2446:2447), group_run := 25L] # Very high, Jonathan having fun, discard
list_runs[as.character(2458:2461), group_run := 26L] # 13252/253 low ; 13251 high ; 13254 very high
list_runs[as.character(2477), group_run := 27L] # ohel
list_runs[as.character(2479:2480), group_run := 28L] # research on older runs, exclude
list_runs[as.character(2481:2482), group_run := 29L] # An runs, probably different solvent, but ohel
list_runs[as.character(2511:2514), group_run := 30L] # ohel
list_runs[as.character(2520:2525), group_run := 31L] # ohel
list_runs[as.character(2532), group_run := 32L] # oleh
list_runs[as.character(2535), group_run := 33L] # oleh
list_runs[as.character(2537:2538), group_run := 34L] # both runs are low
list_runs[as.character(2544:2548), group_run := 35L] # Exclude 2545 (Kevin having fun :p), rest is low
list_runs[as.character(2558:2559), group_run := 36L] # oleh 13752:13771 and 13774:13793 ; high 13890:13893
list_runs[as.character(2560:2563), group_run := 37L] # oleh
list_runs[as.character(2570:2571), group_run := 38L] # oleh
list_runs[as.character(2572), group_run := 39L] # oleh
list_runs[as.character(2578:2583), group_run := 40L] # oleh
list_runs[as.character(2600), group_run := 41L] # ohel
list_runs[as.character(2607:2609), group_run := 42L] # Jonathan having fun, discard
list_runs[as.character(2610), group_run := 43L] # Jonathan having fun, discard
list_runs[as.character(2614:2615), group_run := 44L] # ohel
list_runs[as.character(2633), group_run := 45L] # ohel
list_runs[as.character(2637), group_run := 46L] # ohel



