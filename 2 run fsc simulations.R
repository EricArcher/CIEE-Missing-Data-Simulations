rm(list = ls())
library(strataG)

load("v4.params.rdata")
num.reps <- 10

label <- attr(params, "label")
folder <- paste0(label, ".sim.data")
if(!dir.exists(folder)) dir.create(folder)

for(i in 1:nrow(params)) {
  f <- file.path(folder, paste(label, "fsc", i, "rdata", sep = "."))
  if(file.exists(f)) next

  sc <- as.list(params[i, ])
  fsc.list <- with(sc, {
    n <- num.pops
    pi <- fscPopInfo(pop.size = rep(Ne, n), sample.size = rep(Ne, n))
    lp <- fscLocusParams(locus.type = "snp", num.loci = num.loci, mut.rate = mut.rate)
    he <- fscHistEv(num.gen = rep(div.time, n - 1), source.deme = 1:(n - 1))

    lapply(1:num.reps, function(rep) {
      lbl <- paste0("scenario_", i, ".replicate_", rep)
      fastsimcoal(
        pi, lp, mig.rates = mig.mat[[1]], hist.ev = he,
        label = lbl, num.cores = 3, quiet = FALSE
      )
    })
  })
  attr(fsc.list, "params") <- params[i, ]
  attr(fsc.list, "label") <- label

  save(fsc.list, file = f)
}