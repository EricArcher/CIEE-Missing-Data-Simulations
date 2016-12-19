rm(list = ls())
library(strataG)
source("sim funcs.R")
load("v2.params.rdata")

num.reps <- 5
time.vec <- c(50, 100, 500, 1000, 5000, 10000, 50000, 100000)

folder <- "v2.equilibrium.test"
if(!dir.exists(folder)) dir.create(folder)

for(i in 1:nrow(params)) {
  eq.file <- paste0("eq.test.", i, ".rdata")
  eq.file <- file.path(folder, eq.file)
  if(!file.exists(eq.file)) {
    sc <- as.list(params[i, ])
    sc$mig.type <- "stepping.stone"
    sc$mig.mat <- params[i, "stepping.stone"][[1]]
    time.sim.list <- lapply(time.vec, function(div.time) {
      cat(div.time, "\n")
      sc$div.time <- div.time
      run.sim(sc, num.reps)
    })
    save(time.vec, time.sim.list, file = eq.file)
  }

  load(eq.file)
  smry.file <- paste0("eq.test.smry.", i, ".rdata")
  smry.file <- file.path(folder, smry.file)
  if(!file.exists(smry.file)) {
    eq.smry <- do.call(rbind, lapply(1:length(time.sim.list), function(i) {
      cat(time.vec[i], "\n")
      time.g <- time.sim.list[[i]]
      result <- t(sapply(time.g, function(g) {
        c(
          fst = statFst(g)$result["estimate"],
          het = mean(sapply(strataSplit(g), function(g.st) mean(obsvdHet(g.st)))),
          theta = mean(sapply(strataSplit(g), function(g.st) mean(theta(g.st))))
        )
      }))
      cbind(time = time.vec[i], result)
    }))
    eq.smry <- data.frame(eq.smry)
    save(eq.smry, i, file = smry.file)
  }
}


library(ggplot2)
library(gridExtra)
library(reshape2)
pdf(file.path(folder, "equlibrium test.pdf"))
for(f in dir(folder, pattern = "eq.test.smry.", full.names = TRUE)) {
  load(f)
  title <- paste("Scenario", i)
  colnames(eq.smry) <- c("time", "Fst", "Observed Heterozygosity", "Theta")
  df <- melt(eq.smry, id.vars = "time")
  df$time <- factor(df$time)
  gpl <- ggplot(df, aes(time, value)) +
    geom_point(alpha = 0.5) +
    facet_grid(variable ~ ., scales = "free_y") +
    ggtitle(title) + labs(x = "Divergence time")
  print(gpl)
}
dev.off()