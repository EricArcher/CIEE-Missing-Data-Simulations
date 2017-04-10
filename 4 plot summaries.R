rm(list = ls())
library(tidyverse)
library(swfscMisc)

label <- "v2"
load(paste0(label, ".summaries.rdata"))

pdf(paste0(label, ".summaries.pdf"))

pop.loc.df %>%
  filter(variable == "maf") %>%
  ggplot(aes(value)) +
  geom_histogram() +
  labs(x = "MAF", title = "MAF") +
  facet_grid(Nm ~ mig.type, labeller = label_both)

pop.struct.df %>%
  filter(metric == "est.fst") %>%
  mutate(ratio = log10(estimate / (1 / (4 * Nm + 1)))) %>%
  ggplot(aes(factor(mig.type), ratio)) +
  geom_hline(yintercept = 0, color = "red") +
  geom_jitter(alpha = 0.6) +
  labs(
    x = "Migration Topology",
    y = expression(log[10]("estimated Fst / expected Fst (=1/(4Nm + 1)")),
    title = "Fst"
  ) +
  facet_wrap(~ Nm, ncol = 1, labeller = label_both)

ne.df %>%
  filter(variable == "Ne") %>%
  mutate(ratio = log10(value / Ne)) %>%
  ggplot(aes(factor(mig.type), ratio)) +
  geom_hline(yintercept = 0, color = "red") +
  geom_jitter(alpha = 0.6) +
  labs(
    x = "Migration Topology",
    y = expression(log[10]("estimated Ne / simulation Ne")),
    title = "ldNe"
  ) +
  facet_wrap(~ Nm, ncol = 1, labeller = label_both)

dev.off()
