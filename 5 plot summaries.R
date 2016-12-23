rm(list = ls())
library(reshape2)
library(ggplot2)
library(strataG)

folder <- rev(dir(pattern = ".sim.data"))[1]
fnames <- dir(folder, pattern = ".smry.", full.names = TRUE)

smry.df <- do.call(rbind, lapply(fnames, function(f) {
  load(f)
  sc <- attr(smry, "params")
  sc$mig.mat <- NULL

  df <- data.frame(t(smry))
  colnames(df) <- c("est.Ne", "est.Fst", "obs.Het", "est.Theta", "MAF")
  cbind(as.data.frame(sc), df)
}))
smry.df$Ne <- factor(smry.df$Ne)
smry.df$Nm <- factor(smry.df$Nm)
smry.df$theta <- factor(smry.df$theta)
smry.df$mig.type <- factor(smry.df$mig.type)

pdf(file.path(folder, "sim.summary.pdf"))
for(p in c("est.Ne", "est.Fst", "obs.Het", "est.Theta", "MAF")) {
  g <- ggplot(smry.df, aes_string(x = "mig.type", y = p)) +
    geom_jitter(aes(color = Ne), alpha = 0.7) +
    facet_grid(Nm ~ theta, scales = "free_y", labeller = label_both)
  print(g)
}
dev.off()
