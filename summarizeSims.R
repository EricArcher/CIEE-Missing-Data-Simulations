summarizeSims <- function(folder) {
  for(f in dir(folder, pattern = "gtypes.", full.names = TRUE)) {
    cat(f, "\n")
    load(f)
    f <- gsub("gtypes.", "smry.", f)
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
        est.fst.prime = statFstPrime(g)$result["estimate"]
      )
    }, mc.cores = 3)
    attr(smry, "scenario") <- attr(rms.list, "scenario")

    save(smry, file = f)
  }


  fnames <- dir(folder, pattern = "smry.", full.names = TRUE)

  pop.loc.df <- bind_rows(lapply(fnames, function(f) {
    load(f)
    sc <- attr(smry, "scenario")
    sc$mig.mat <- NULL
    cbind(
      bind_rows(sc),
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
    sc <- attr(smry, "scenario")
    sc$mig.mat <- NULL
    cbind(
      bind_rows(sc),
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
    sc <- attr(smry, "scenario")
    sc$mig.mat <- NULL
    df <- bind_rows(lapply(smry, function(x) {
      if(is.null(x$est.ne)) return(NULL)
      x$est.ne %>%
        as.data.frame %>%
        gather %>%
        rename(variable = key)
    }))
    if(nrow(df) == 0) return(NULL)
    cbind(bind_rows(sc), df)
  }))

  pop.struct.df <- bind_rows(lapply(fnames, function(f) {
    load(f)
    sc <- attr(smry, "scenario")
    sc$mig.mat <- NULL
    cbind(
      bind_rows(sc),
      bind_rows(lapply(smry, function(x) {
        data.frame(
          est.fst = x$est.fst,
          est.fst.prime = x$est.fst.prime
        )
      })) %>%
        gather(metric, estimate)
    )
  }))

  fname <- paste0(folder, ".summaries.rdata")
  save(ovl.loc.df, pop.loc.df, ne.df, pop.struct.df, file = fname)

  load(fname)

  p1 <- pop.loc.df %>%
    filter(variable == "maf") %>%
    ggplot(aes(value)) +
    geom_histogram() +
    labs(x = "MAF", title = "MAF") +
    facet_grid(Nm ~ mig.type, labeller = label_both)

  p2 <- pop.struct.df %>%
    filter(metric == "est.fst.prime") %>%
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

  p3 <- ne.df %>%
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


  pdf(paste0(folder, ".summaries.pdf"))
  print(p1)
  print(p2)
  print(p3)
  dev.off()
}