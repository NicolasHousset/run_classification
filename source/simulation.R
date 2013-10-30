simulation <- data.table(1:10000)

sdRT <- 25
shift <- 80
simulation[, lowColumn := rnorm(10000,0,1)]
simulation[, highColumn := rnorm(10000, shift, sdRT)]

simulation[1:5000, diff := rnorm(5000, 25,sdRT)]
simulation[5001:10000, diff := rnorm(5000, 70,sdRT)]

ggplot(simulation, aes(lowColumn)) + xlim(-5,5)+ geom_histogram(aes(y = ..density..), binwidth = 0.1)
ggplot(simulation, aes(diff)) + xlim(-100,240) + geom_density()
