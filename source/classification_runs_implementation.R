
list_runs[, group_run := as.character(group_run)]
setkey(list_runs, group_run, index)

list_runs[as.character(9)]

list_runs[list(as.character(1),as.character((5204:5207)*2+1)), classification := "low"]
list_runs[list(as.character(1),as.character((5205:5208)*2)), classification := "high"]
list_runs[list(as.character(1),as.character((5217:5219)*2+1)), classification := "high"]
list_runs[list(as.character(1),as.character((5218:5219)*2)), classification := "low"]

list_runs[list(as.character(2),as.character((10750:10773))), classification := "low"]

list_runs[list(as.character(3),as.character((5429:5436)*2+1)), classification := "high"]
list_runs[list(as.character(3),as.character((5429:5436)*2)), classification := "low"]

list_runs[list(as.character(4),as.character(10728:10729)), classification := "very high"]

list_runs[list(as.character(5),as.character((5518:5543)*2+1)), classification := "high"]
list_runs[list(as.character(5),as.character((5519:5544)*2)), classification := "low"]

list_runs[list(as.character(6),as.character((5514:5515)*2+1)), classification := "high"]
list_runs[list(as.character(6),as.character((5515:5516)*2)), classification := "low"]
list_runs[list(as.character(6),as.character(11363)), classification := "exclude"]
list_runs[list(as.character(6),as.character(11365)), classification := "low"]
list_runs[list(as.character(6),as.character(c(11364,11366))), classification := "high"]

list_runs[list(as.character(7),as.character(11352:11355)), classification := "low"]
list_runs[list(as.character(7),as.character(11356:11360)), classification := "high"]

list_runs[list(as.character(8),as.character(11543:11544)), classification := "exclude"]

list_runs[list(as.character(9),as.character(11538:11540)), classification := "low"]

list_runs[list(as.character(10),as.character((5743:5756)*2+1)), classification := "low"]
list_runs[list(as.character(10),as.character((5744:5756)*2)), classification := "high"]

list_runs[list(as.character(11),as.character(11555:11557)), classification := "low"]
list_runs[list(as.character(11),as.character(c(12793,12795))), classification := "low"]
list_runs[list(as.character(11),as.character(c(12794))), classification := "high"]

list_runs[list(as.character(12),as.character((5858:5868)*2-1)), classification := "high"]
list_runs[list(as.character(12),as.character((5858:5868)*2)), classification := "low"]

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

list_runs[list(as.character(20),as.character((6243:6245)*2+1)), classification := "low"]
list_runs[list(as.character(20),as.character((6243:6246)*2)), classification := "high"]

list_runs[list(as.character(21),as.character((6357:6359)*2-1)), classification := "high"]
list_runs[list(as.character(21),as.character((6357:6359)*2)), classification := "low"]

list_runs[list(as.character(22),as.character(12719:12720)), classification := "exclude"]

list_runs[list(as.character(23),as.character(c(((6547:6558)*2+1),((6567:6578)*2+1)))), classification := "high"]
list_runs[list(as.character(23),as.character(c(((6547:6558)*2),((6567:6578)*2)))), classification := "low"]

list_runs[list(as.character(24),as.character((6489)*2-1)), classification := "low"]
list_runs[list(as.character(24),as.character((6489)*2)), classification := "high"]
