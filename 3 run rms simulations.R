rm(list = ls())
library(rmetasim)
library(strataG)
source("rms funcs.R")
load("v3.params.rdata")

num.gens <- 5

label <- attr(params, "label")
folder <- paste0(label, ".sim.data")
fnames <- dir(folder, pattern = ".fsc.", full.names = TRUE)

for(f in fnames) {
  load(f)
  cat(f, "\n")
  sc <- attr(sim.list, "params")

  rms.list <- lapply(1:length(sim.list), function(i) {
    af <- alleleFreqs(sim.list[[i]], by.strata = T)
    rl <- loadLandscape(sc, af, num.gens)
    for(g in 1:num.gens) {
      rl <- landscape.simulate(rl, 1)
      rl <- killExcess(rl, sc$Ne)
    }
    landscape2gtypes(rl)
  })

  attr(rms.list, "params") <- sc
  f <- paste(label, sc$mig.type, "rms", sc$scenario, "rdata", sep = ".")
  save(sim.list, rms.list, file = file.path(folder, f))
}


fnames <- dir("v3.sim.data", pattern = ".rms.", full.names = TRUE)

for(f in fnames) {
  cat(f, "\n")
  load(f)
  sc <- attr(rms.list, "params")
  f <- gsub(".rms.", ".gtypes.", f)
  if(file.exists(f)) next
  sim.gtypes <- rms.list
  attr(sim.gtypes, "params") <- sc
  save(sim.gtypes, file = f)
}