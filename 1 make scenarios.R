rm(list = ls())

source("v3.params.R")

# create scenario data.frame
params <- expand.grid(Ne = Ne, Nm = Nm, theta = theta, num.loci = num.loci)
params$mig.rate <- params$Nm / params$Ne
params$mut.rate <- params$theta / (4 * params$Ne)
params$Fst <- 1 / ((4 * params$Nm) + 1)
params$div.time <- div.time
params$num.pops <- num.pops
params <- cbind(scenario = 1:nrow(params), params)

# island model migration matrices
params$island <- lapply(1:nrow(params), function(i) {
  mat <- matrix(rep(params$mig.rate[i], num.pops ^ 2), nrow = num.pops)
  diag(mat) <- 1 - colSums(mat)
  mat
})

# stepping stone model migration matrices
params$stepping.stone <- lapply(1:nrow(params), function(i) {
  mat <- matrix(0, nrow = num.pops, ncol = num.pops)
  for(k in 1:(num.pops - 1)) {
    mat[k, k + 1] <- mat[k + 1, k] <- params$mig.rate[i]
  }
  diag(mat) <- 1 - colSums(mat)
  mat
})

attr(params, "label") <- label

save(params, file = paste0(label, ".params.rdata"))