rm(list = ls())
library(tidyverse)
library(swfscMisc)

load("eqbm.test.summaries.rdata")
load("eqbm.test.params.rdata")
fname <- "eqbm test summaries.pdf"

my.theme <- theme(axis.text.x = element_text(angle = 45, hjust = 1))

pop.struct.df %>%
  filter(metric == "est.fst") %>%
  mutate(ratio = log10(estimate / (1 / (4 * Nm + 1)))) %>%
  ggplot(aes(factor(div.time), ratio)) +
  geom_hline(yintercept = 0, color = "red") +
  geom_boxplot() +
  facet_grid(Nm + mig.type ~ theta, labeller = label_both)

ne.df %>%
  filter(variable == "Ne") %>%
  mutate(ratio = log10(value / Ne)) %>%
  ggplot(aes(factor(div.time), ratio)) +
  geom_hline(yintercept = 0, color = "red") +
  geom_boxplot() +
  facet_grid(Nm + mig.type ~ theta, labeller = label_both)


pop.loc.df %>%
  filter(variable == "maf" & mig.type == "island") %>%
  ggplot(aes(value)) +
  geom_histogram() +
  facet_grid(Nm ~ theta, labeller = label_both)


locVarPlot <- function(df, v, xlab, title) {
  vline <- df %>%
    filter(maf.thresh == 0 & variable == v) %>%
    group_by(Nm, theta) %>%
    summarize(smry = median(value))
  p <- df %>%
    filter(variable == v) %>%
    ggplot(aes(value)) +
      geom_histogram(bins = 30) +
      geom_vline(aes(xintercept = smry), data = vline, linetype = 2, color = "red") +
      labs(x = xlab, title = title) +
      facet_grid(Nm ~ theta, labeller = label_both) +
      my.theme
  print(p)
}

propLociFixed <- function(df, title) {
  p <- df %>%
    filter(maf.thresh == 0 & variable == "maf") %>%
    group_by(Nm, theta, mig.type) %>%
    summarise(prop.maf.eq.0 = mean(value == 0)) %>%
    ggplot(aes(factor(theta), prop.maf.eq.0)) +
      geom_bar(stat = "identity") +  labs(
        x = "simulation Theta",
        y = "Proportion of loci fixed (MAF = 0)",
        title = title
      ) +
      facet_grid(Nm ~ ., labeller = label_both) +
      my.theme
  print(p)
}


pdf(fname)

locVarPlot(pop.loc.df, "maf", "MAF", "MAF - Within Population")
propLociFixed(pop.loc.df, "MAF - Within Population")

locVarPlot(ovl.loc.df, "maf", "MAF", "MAF - Metapopulation")
propLociFixed(ovl.loc.df, "MAF - Metapopulation")

locVarPlot(pop.loc.df, "het", "Observed Heterozygosity", "Heterozygosity - Within Population")
locVarPlot(ovl.loc.df, "het", "Observed Heterozygosity", "Heterozygosity - Metapopulation")
locVarPlot(pop.loc.df, "theta", "Estimated Theta", "Theta - Within Population")
locVarPlot(ovl.loc.df, "theta", "Estimated Theta", "Theta - Metapopulation")

ne.df %>%
  filter(variable == "Ne") %>%
  mutate(
    min.MAF = factor(maf.thresh),
    log.est.pct = log10(value / Ne)
  ) %>%
  ggplot(aes(min.MAF, log.est.pct)) +
    geom_violin(draw_quantiles = 0.5) +
    geom_hline(yintercept = 0, linetype = 2, color = "red") +
    labs(
      x = "miniumum MAF",
      y = expression(log[10]("estimated Ne / simulation Ne")),
      title = "Ne"
    ) +
    facet_grid(Nm ~ theta, labeller = label_both, scales = "free") +
    theme(
      legend.position = "top",
      axis.text.x = element_text(angle = 45, hjust = 1)
    )

fst.df %>%
  filter(maf.thresh == 0) %>%
  mutate(
    exp.fst = 1 / (4 * Nm + 1),
    est.exp.fst = log10(est.fst / exp.fst)
  ) %>%
  ggplot(aes(factor(theta), est.exp.fst)) +
    geom_violin(draw_quantiles = 0.5) +
    geom_hline(yintercept = 0, linetype = 2, color = "red") +
    labs(
      x = "theta",
      y = expression(log[10]("est Fst / expected Fst")),
      title = "Fst"
    ) +
    facet_grid(Nm ~ ., labeller = label_both, scales = "free") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))


fst.prime.df %>%
  filter(maf.thresh == 0) %>%
  mutate(
    exp.fst = 1 / (4 * Nm + 1),
    est.exp.fst = log10(est.fst.prime / exp.fst)
  ) %>%
  ggplot(aes(factor(theta), est.exp.fst)) +
  geom_violin(draw_quantiles = 0.5) +
  geom_hline(yintercept = 0, linetype = 2, color = "red") +
  labs(
    x = "theta",
    y = expression(log[10]("est F'st / expected Fst")),
    title = "F'st"
  ) +
  facet_grid(Nm ~ ., labeller = label_both, scales = "free") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

gst.df %>%
  filter(maf.thresh == 0) %>%
  mutate(
    exp.fst = 1 / (4 * Nm + 1),
    est.exp.fst = log10(est.gst / exp.fst)
  ) %>%
  ggplot(aes(factor(theta), est.exp.fst)) +
  geom_violin(draw_quantiles = 0.5) +
  geom_hline(yintercept = 0, linetype = 2, color = "red") +
  labs(
    x = "theta",
    y = expression(log[10]("est Gst / expected Fst")),
    title = "Gst"
  ) +
  facet_grid(Nm ~ ., labeller = label_both, scales = "free") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

gst.prime.df %>%
  filter(maf.thresh == 0) %>%
  mutate(
    exp.fst = 1 / (4 * Nm + 1),
    est.exp.fst = log10(est.gst.prime / exp.fst)
  ) %>%
  ggplot(aes(factor(theta), est.exp.fst)) +
  geom_violin(draw_quantiles = 0.5) +
  geom_hline(yintercept = 0, linetype = 2, color = "red") +
  labs(
    x = "theta",
    y = expression(log[10]("est G'st / expected Fst")),
    title = "G'st"
  ) +
  facet_grid(Nm ~ ., labeller = label_both, scales = "free") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

d.df %>%
  filter(maf.thresh == 0) %>%
  ggplot(aes(factor(theta), est.d)) +
  geom_violin(draw_quantiles = 0.5) +
  labs(
    x = "theta",
    y = "Jost's D",
    title = "D"
  ) +
  facet_grid(Nm ~ ., labeller = label_both, scales = "free") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

dev.off()