rm(list = ls())
library(strataG)
source("sim funcs.R")
load("v3.params.rdata")

num.reps <- 10

label <- attr(params, "label")
folder <- paste0(label, ".sim.data")
if(!dir.exists(folder)) dir.create(folder)

for(mig in c("island", "stepping.stone")) {
  for(i in 1:nrow(params)) {
    f <- file.path(folder, paste(label, mig, "fsc", i, "rdata", sep = "."))
    if(file.exists(f)) next
    sc <- as.list(params[i, ])
    sc$mig.type <- mig
    sc$mig.mat <- params[i, mig][[1]]
    sim.list <- run.sim(sc, num.reps)
    save(sim.list, file = f)
  }
}
