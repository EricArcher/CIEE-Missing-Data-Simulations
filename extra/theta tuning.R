rm(list = ls())
set.seed(1)

Ne <- 500
num.loci <- 1000
theta <- c(0.1, 0.15, 0.2, 0.8)

scenarios <- expand.grid(Ne = Ne, theta = theta, num.loci = num.loci)
scenarios$mut.rate <- scenarios$theta / (4 * scenarios$Ne)
scenarios <- cbind(scenario = 1:nrow(scenarios), scenarios)

sim.data <- lapply(1:nrow(scenarios), function(sc) {

  pi <- fscPopInfo(
    pop.size = scenarios$Ne[sc],
    sample.size = scenarios$Ne[sc]
  )

  lp <- fscLocusParams(
    locus.type = "snp",
    num.loci = scenarios$num.loci[sc],
    mut.rate = scenarios$mut.rate[sc]
  )

  label <- paste0("scenario.", sc)
  fastsimcoal(pi, lp, label = label)

})

save.image("theta tuning sims.rdata")

library(reshape2)
library(ggplot2)
maf.dist <- t(sapply(sim.data, maf))
maf.dist <- cbind(theta = theta, maf.dist)
maf.df <- melt(maf.dist)
maf.df$Var1 <- factor(theta[maf.df$Var1])
colnames(maf.df) <- c("theta", "locus", "MAF")

ggplot(maf.df, aes(MAF)) + geom_density(aes(fill = theta), alpha = 0.3)
