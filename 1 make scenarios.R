rm(list = ls())

source("v4.params.R")

# create scenario data.frame
params <- expand.grid(
  Ne = Ne, Nm = Nm, theta = theta,
  mig.type = mig.type, num.loci = num.loci,
  num.pops = num.pops, div.time = div.time,
  stringsAsFactors = FALSE
)
params$mig.rate <- params$Nm / params$Ne
params$mig.mat <- lapply(1:nrow(params), function(i) {
  num.pops <- params$num.pops[i]
  mig.rate <- params$mig.rate[i]
  switch(
    params$mig.type[i],
    island = {
      per.pop.mig.rate <- mig.rate / (num.pops - 1)
      mat <- matrix(rep(per.pop.mig.rate, num.pops ^ 2), nrow = num.pops)
      diag(mat) <- 1 - mig.rate
      mat
    },
    stepping.stone = {
      per.pop.mig.rate <- mig.rate / 2
      mat <- matrix(0, nrow = num.pops, ncol = num.pops)
      for(k in 1:(num.pops - 1)) {
        mat[k, k + 1] <- mat[k + 1, k] <- per.pop.mig.rate
      }
      mat[1, num.pops] <- mat[num.pops, 1] <- per.pop.mig.rate
      diag(mat) <- 1 - mig.rate
      mat
    }
  )
})
params$mut.rate <- params$theta / (4 * params$Ne)
params$Fst <- 1 / ((4 * params$Nm) + 1)
params <- cbind(scenario = 1:nrow(params), params)
attr(params, "label") <- label

save(params, file = paste0(label, ".params.rdata"))