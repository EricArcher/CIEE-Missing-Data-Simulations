rm(list = ls())
library(rmetasim)
library(strataG)
source("rms funcs.R")

load("v2.params.rdata")

num.reps <- 10
num.gens <- 3

label <- attr(params, "label")
folder <- paste0(label, ".sim.data")
if(!dir.exists(folder)) dir.create(folder)

for(i in 1:nrow(params)) {
  f <- file.path(folder, paste(label, "gtypes", i, "rdata", sep = "."))
  if(file.exists(f)) next

  sc <- as.list(params[i, ])
  sc$mig.mat <- sc$mig.mat[[1]]

  # run fastsimcoal
  fsc.list <- with(sc, {
    n <- num.pops
    pi <- fscPopInfo(pop.size = rep(Ne, n), sample.size = rep(Ne, n))
    lp <- fscLocusParams(locus.type = "snp", num.loci = num.loci, mut.rate = mut.rate)
    he <- fscHistEv(num.gen = rep(div.time, n - 1), source.deme = 1:(n - 1))

    lapply(1:num.reps, function(rep) {
      lbl <- paste0("scenario_", i, ".replicate_", rep)
      fastsimcoal(
        pi, lp, mig.rates = mig.mat, hist.ev = he,
        label = lbl, num.cores = 3, quiet = FALSE
      )
    })
  })

  # run rmetasim for 'num.gens' generations using fastsimcoal runs as initialization
  rms.list <- lapply(1:length(fsc.list), function(i) {
    af <- alleleFreqs(fsc.list[[i]], by.strata = T)
    rl <- loadLandscape(sc, af, num.gens)
    for(g in 1:num.gens) {
      rl <- landscape.simulate(rl, 1)
      rl <- killExcess(rl, sc$Ne)
    }
    landscape2gtypes(rl)
  })

  attr(rms.list, "params") <- attr(fsc.list, "params") <- params[i, ]
  attr(rms.list, "label") <- attr(fsc.list, "label") <- label

  # save both fastsimcoal and rmetasim results to same workspace file
  save(fsc.list, rms.list, file = f)
}

source("3 summarize sims.R")