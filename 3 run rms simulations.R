rm(list = ls())
library(rmetasim)
library(strataG)
source("rms funcs.R")

load("v5.params.rdata")
num.gens <- 5

label <- attr(params, "label")
folder <- paste0(label, ".sim.data")

# run rmetasim for 'num.gens' generations using fastsimcoal runs as initialization
for(f in dir(folder, pattern = ".fsc.", full.names = TRUE)) {
  load(f)
  cat(f, "\n")
  sc <- as.list(attr(fsc.list, "params"))
  sc$mig.mat <- sc$mig.mat[[1]]

  rms.list <- lapply(1:length(fsc.list), function(i) {
    af <- alleleFreqs(fsc.list[[i]], by.strata = T)
    rl <- loadLandscape(sc, af, num.gens)
    for(g in 1:num.gens) {
      rl <- landscape.simulate(rl, 1)
      rl <- killExcess(rl, sc$Ne)
    }
    landscape2gtypes(rl)
  })
  attr(rms.list, "params") <- sc

  # save both fastsimcoal and rmetasim results to same workspace file
  rms.f <- paste(label, "rms", sc$scenario, "rdata", sep = ".")
  save(fsc.list, rms.list, file = file.path(folder, rms.f))
}


# create .rdata files that have only rmetasim gtypes data
for(f in dir("v3.sim.data", pattern = ".rms.", full.names = TRUE)) {
  cat(f, "\n")
  load(f)
  sc <- attr(rms.list, "params")
  f <- gsub(".rms.", ".gtypes.", f)
  if(file.exists(f)) next
  sim.gtypes <- rms.list
  attr(sim.gtypes, "params") <- sc
  save(sim.gtypes, file = f)
}