rm(list = ls())
library(swfscMisc)
library(strataG)
library(parallel)

folder <- "v15.sim.data"

for(f in dir(folder, pattern = ".fsc.", full.names = TRUE)) {
  cat(f)
  load(f)
  f <- gsub(".fsc.", ".fsc.smry.", f)
  if(file.exists(f)) next

  smry <- lapply(fsc.list, function(g) {
    maf.g <- maf(g)
    mclapply(seq(0, 0.3, by = 0.05), function(maf.thresh) {
      to.keep <- which(maf.g >= maf.thresh)
      if(length(to.keep) < 2) return(NULL)
      sub.g <- g[, to.keep, ]
      st.g <- strataSplit(sub.g)
      list(
        maf.thresh = maf.thresh,
        ovl.maf = maf(sub.g),
        pop.maf = sapply(st.g, maf),
        ovl.het = obsvdHet(sub.g),
        pop.het = sapply(st.g, obsvdHet),
        ovl.theta = theta(sub.g),
        pop.theta = sapply(st.g, theta),
        est.ne = ldNe(sub.g),
        est.fst = statFst(sub.g)$result["estimate"],
        est.fst.prime = statFstPrime(sub.g)$result["estimate"],
        est.gst = statGst(sub.g)$result["estimate"],
        est.gst.prime = statGstPrime(sub.g)$result["estimate"],
        est.d = statJostD(sub.g)$result["estimate"]
      )
    }, mc.cores = 3)
  })
  attr(smry, "params") <- attr(fsc.list, "params")

  save(smry, file = f)
  cat("\n")
}
