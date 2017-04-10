rm(list = ls())
library(swfscMisc)
library(strataG)
library(parallel)
library(tidyverse)

folder <- "v2.sim.data"

for(f in dir(folder, pattern = ".gtypes.", full.names = TRUE)) {
  cat(f)
  load(f)
  f <- gsub(".gtypes.", ".smry.", f)
  if(file.exists(f)) next

  smry <- mclapply(rms.list, function(g) {
    st.g <- strataSplit(g)
    list(
      ovl.maf = maf(g),
      pop.maf = sapply(st.g, maf),
      ovl.het = obsvdHet(g),
      pop.het = sapply(st.g, obsvdHet),
      ovl.theta = theta(g),
      pop.theta = sapply(st.g, theta),
      est.ne = ldNe(g, maf.threshold = 0.05),
      est.fst = statFst(g)$result["estimate"],
      est.fst.prime = statFstPrime(g)$result["estimate"],
      est.gst = statGst(g)$result["estimate"],
      est.gst.prime = statGstPrime(g)$result["estimate"],
      est.gst.dbl.prime = statGstDblPrime(g)$result["estimate"],
      est.d = statJostD(g)$result["estimate"]
    )
  }, mc.cores = 3)
  attr(smry, "params") <- attr(rms.list, "params")

  save(smry, file = f)
  cat("\n")
}


fnames <- dir(folder, pattern = ".smry.", full.names = TRUE)

pop.loc.df <- bind_rows(lapply(fnames, function(f) {
  load(f)
  params <- attr(smry, "params")
  params$mig.mat <- NULL
  cbind(
    bind_rows(params),
    bind_rows(lapply(smry, function(x) {
      if(is.null(x)) return(NULL)
      obs.maf <- as.data.frame(x$pop.maf) %>%
        mutate(locus = rownames(.)) %>%
        gather(pop, value, -locus) %>%
        mutate(variable = "maf")
      obs.het <- as.data.frame(x$pop.het) %>%
        mutate(locus = rownames(.)) %>%
        gather(pop, value, -locus) %>%
        mutate(variable = "het")
      obs.theta <- as.data.frame(x$pop.theta) %>%
        mutate(locus = rownames(.)) %>%
        gather(pop, value, -locus) %>%
        mutate(variable = "theta")
      bind_rows(obs.maf, obs.het, obs.theta)
    }))
  )
}))

ovl.loc.df <- bind_rows(lapply(fnames, function(f) {
  load(f)
  params <- attr(smry, "params")
  params$mig.mat <- NULL
  cbind(
    bind_rows(params),
    bind_rows(lapply(smry, function(x) {
      if(is.null(x)) return(NULL)
      data.frame(
        maf = unlist(x$ovl.maf),
        het = unlist(x$ovl.het),
        theta = unlist(x$ovl.theta)
      ) %>%
        mutate(locus = rownames(.)) %>%
        gather(metric, estimate, -locus)
    }))
  )
}))

ne.df <- bind_rows(lapply(fnames, function(f) {
  load(f)
  params <- attr(smry, "params")
  params$mig.mat <- NULL
  df <- bind_rows(lapply(smry, function(x) {
    if(is.null(x$est.ne)) return(NULL)
    x$est.ne %>%
      as.data.frame %>%
      gather %>%
      rename(variable = key)
  }))
  if(nrow(df) == 0) return(NULL)
  cbind(bind_rows(params), df)
}))

pop.struct.df <- bind_rows(lapply(fnames, function(f) {
  load(f)
  params <- attr(smry, "params")
  params$mig.mat <- NULL
  cbind(
    bind_rows(params),
    bind_rows(lapply(smry, function(x) {
      data.frame(
        est.fst = x$est.fst,
        est.fst.prime = x$est.fst.prime,
        est.gst = x$est.gst,
        est.gst.prime = x$est.gst.prime,
        est.gst.dbl.prime = x$est.gst.dbl.prime,
        est.d = x$est.d
      )
    })) %>%
      gather(metric, estimate)
  )
}))

fname <- gsub(".sim.data", ".summaries.rdata", folder)
save(ovl.loc.df, pop.loc.df, ne.df, pop.struct.df, file = fname)