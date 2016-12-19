rm(list = ls())
library(rmetasim)
library(strataG)
source("rms funcs.R")

num.gens <- 5

fname <- dir("sim.data", pattern = "rms test", full.names = T)[1]
load(fname)

sc <- attr(sim.list, "params")

af <- alleleFreqs(sim.list[[1]], by.strata = T)
rl <- loadLandscape(sc, af, num.gens)
x <- sapply(1:num.gens, function(i) {
  rl <- landscape.simulate(rl, i)
  rl <- killExcess(rl, 50)
  g <- landscape2gtypes(rl)
  ld <- ldNe(g)
  print(ld)
  ld[, "Ne"]
})
