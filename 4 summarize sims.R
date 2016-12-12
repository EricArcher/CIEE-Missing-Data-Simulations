rm(list = ls())
library(strataG)

folder <- "v3.sim.data"

fnames <- dir(folder, pattern = ".rms.", full.names = TRUE)

for(f in fnames) {
  cat(f, "\n")
  load(f)
  sc <- attr(rms.list, "params")
  f <- gsub(".rms.", ".smry.", f)
  if(file.exists(f)) next

  smry <- sapply(rms.list, function(g){
    c(
      ne = median(ldNe(g)[, "Ne"]),
      fst = statFst(g)$result["estimate"],
      obsv.het = median(obsvdHet(g)),
      theta = median(theta(g)),
      maf = median(maf(g))
    )
  })
  attr(smry, "params") <- sc

  save(smry, file = f)
}
