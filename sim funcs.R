makeMigMat <- function(ne, nm, pop.groups) {
  num.pops <- length(pop.groups)
  mat <- matrix(0, ncol = num.pops, nrow = num.pops)

  pop.pairs <- t(combn(num.pops, 2))
  colnames(pop.pairs) <- c("pop1", "pop2")
  mig <- apply(pop.pairs, 1, function(p) {
    if(pop.groups[p[1]] == pop.groups[p[2]]) nm else 2 * nm
  })

  for(i in 1:nrow(pop.pairs)) {
    p1 <- pop.pairs[i, 1]
    p2 <- pop.pairs[i, 2]
    mat[p1, p2] <- mat[p2, p1] <- if(mig[i] == 0) 0 else nm / mig[i]
  }

  mat
}


gammaMutRate <- function(n, mean, sd) {
  scale <- (sd ^ 2) / mean
  shape <- (mean / sd) ^ 2
  mut.rate <- rgamma(n, scale = scale, shape = shape)
  hist(log10(mut.rate))
  mut.rate
}

run.sim <- function(sc, num.reps) {
  with(sc, {
    n <- num.pops
    pi <- fscPopInfo(pop.size = rep(Ne, n), sample.size = rep(Ne, n))
    lp <- fscLocusParams(locus.type = "snp", num.loci = num.loci, mut.rate = mut.rate)
    he <- fscHistEv(num.gen = rep(div.time, n - 1), source.deme = 1:(n - 1))

    label <- paste0(mig.type, ".", i)
    sim.list <- lapply(1:num.reps, function(rep) {
      lbl <- paste0(label, ".", rep)
      fastsimcoal(pi, lp, mig.rates = mig.mat, hist.ev = he, label = lbl, num.cores = 3, quiet = FALSE)
    })
    attr(sim.list, "params") <- sc
    sim.list
  })
}