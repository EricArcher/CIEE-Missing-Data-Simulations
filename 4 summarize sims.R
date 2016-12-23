rm(list = ls())
library(swfscMisc)
library(strataG)

folder <- rev(dir(pattern = ".sim.data"))[1]

for(f in dir(folder, pattern = ".rms.", full.names = TRUE)) {
  cat(f, "\n")
  load(f)
  sc <- attr(rms.list, "params")
  f <- gsub(".rms.", ".smry.", f)
  if(file.exists(f)) next

  smry <- sapply(rms.list, function(g){
    st.g <- strataSplit(g)
    c(
      est.ne = harmonic.mean(ldNe(g)[, "Ne"]),
      est.fst = statFst(g)$result["estimate"],
      est.het = mean(unlist(lapply(st.g, obsvdHet))),
      est.theta = mean(unlist(lapply(st.g, theta))),
      est.maf = mean(unlist(lapply(st.g, maf)))
    )
  })
  attr(smry, "params") <- sc

  save(smry, file = f)
}
