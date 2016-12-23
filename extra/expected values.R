exp.theta <- function(Ne, mut.rate, num.pops, ploidy = 2, mig.rate = NULL, Nm = NULL) {
  if(is.null(Nm)) Nm <- Ne * mig.rate
  term.1 <- 2 * ploidy * Ne * mut.rate
  term.2 <- 2 * ploidy * Nm * num.pops / (num.pops - 1)
  1 / (1 + term.1 + term.2)
}

exp.gst <- function(Ne, num.pops, ploidy = 2, mig.rate = NULL, Nm = NULL) {
  exp.theta(Ne, 0, num.pops, ploidy, mig.rate, Nm)
}