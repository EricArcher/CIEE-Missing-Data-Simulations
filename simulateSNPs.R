simulateSNPs <- function(
  num.pops = 5,
  num.loci = 1000,
  div.time = 25000,
  Ne = c(50, 500),
  Nm = c(0, 0.1, 0.5, 1, 5),
  theta = 0.2,
  mig.type = c("island", "stepping.stone"),
  num.reps = 10,
  num.rms.gens = 5,
  label = NULL
) {
  if(is.null(label)) {
    label <- paste0("sim.results.", format(Sys.time(), "%Y%m%d.%H%M"))
  }
  if(!dir.exists(label)) dir.create(label)

  # create scenario data.frame
  sc.df <- expand.grid(
    Ne = Ne, Nm = Nm, theta = theta,
    mig.type = mig.type, num.loci = num.loci,
    num.pops = num.pops, div.time = div.time,
    stringsAsFactors = FALSE
  )
  sc.df <- cbind(scenario = 1:nrow(sc.df), sc.df)
  sc.df$mut.rate <- sc.df$theta / (4 * sc.df$Ne)
  sc.df$mig.rate <- sc.df$Nm / sc.df$Ne
  sc.df$mig.mat <- lapply(1:nrow(sc.df), function(i) {
    num.pops <- sc.df$num.pops[i]
    mig.rate <- sc.df$mig.rate[i]
    switch(
      sc.df$mig.type[i],
      island = {
        m <- mig.rate / (num.pops - 1)
        mat <- matrix(rep(m, num.pops ^ 2), nrow = num.pops)
        diag(mat) <- 1 - mig.rate
        mat
      },
      stepping.stone = {
        mat <- matrix(0, nrow = num.pops, ncol = num.pops)
        m <- mig.rate / 2
        for(k in 1:(num.pops - 1)) {
          mat[k, k + 1] <- mat[k + 1, k] <- m
        }
        mat[1, num.pops] <- mat[num.pops, 1] <- m
        diag(mat) <- 1 - mig.rate
        mat
      }
    )
  })
  attr(sc.df, "label") <- label
  save(sc.df, file = paste0(label, ".scenarios.rdata"))

  # run scenarios
  sapply(1:nrow(sc.df), function(i) {
    fname <- file.path(label, paste("gtypes", i, "rdata", sep = "."))
    if(file.exists(fname)) next

    sc <- as.list(sc.df[i, ])
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
      rl <- loadLandscape(sc, af, num.rms.gens)
      for(g in 1:num.rms.gens) {
        rl <- landscape.simulate(rl, 1)
        rl <- killExcess(rl, sc$Ne)
      }
      landscape2gtypes(rl)
    })

    attr(rms.list, "scenario") <- attr(fsc.list, "scenario") <- sc.df[i, ]
    attr(rms.list, "label") <- attr(fsc.list, "label") <- label

    # save both fastsimcoal and rmetasim results to same workspace file
    save(fsc.list, rms.list, file = fname)
    fname
  })

  label
}