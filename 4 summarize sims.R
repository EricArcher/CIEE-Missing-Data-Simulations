rm(list = ls())
library(swfscMisc)
library(strataG)

folder <- "v4.sim.data"

for(f in dir(folder, pattern = ".rms.", full.names = TRUE)) {
  cat(f, "\n")
  load(f)
  sc <- attr(rms.list, "params")
  f <- gsub(".rms.", ".smry.", f)
  if(file.exists(f)) next

  smry <- sapply(rms.list, function(g){
    c(
      ne = harmonic.mean(ldNe(g)[, "Ne"]),
      fst = statFst(g)$result["estimate"],
      obsv.het = median(obsvdHet(g)),
      theta = median(theta(g)),
      maf = median(maf(g))
    )
  })
  attr(smry, "params") <- sc

  save(smry, file = f)
}
