study.windows.with.bch.data = function() {
  library(RoundingMatters)
  # read in data
  dat = readRDS("Data/MM_new.Rds")
  # make mu non-negative
  dat$mu = abs(dat$mu)

  # Create s again
  #dat$s = significand(dat$sigma, dat$num.deci)

  all.dat = dat
  methods = c("ALL","DID","IV","RDD","RCT")
  unique(all.dat$method)

  # Binominal tables for each method and different thresholds
  
  res.binom = bind_rows(lapply(methods, deround.bch,window.fun=window.binom.test, all.dat=all.dat, repl=100))
  saveRDS(res.binom, "Data/deround_binom.Rds")

  res.binom = bind_rows(lapply(methods, deround.bch,window.fun=window.binom.test, all.dat=all.dat, repl=100, z0 =1.645))
  saveRDS(res.binom, "Data/deround_binom_10percent.Rds")

  res.binom = bind_rows(lapply(methods, deround.bch,window.fun=window.binom.test.2s, all.dat=all.dat, repl=100, z0 =2.576))
  saveRDS(res.binom, "Data/deround_binom_01percent.Rds")

  # Data for window plots
  h.seq=seq(0.01,0.5, by=0.005)
  res.t = bind_rows(lapply(methods, deround.bch, h.seq=h.seq, window.fun=window.t.ci, all.dat=all.dat, repl=100,use.dsr=FALSE, use.zda=FALSE))
  saveRDS(res.t, "Data/deround_t_ci.Rds")

  # Confidence intervals from exact biomial test
  res.binom.ci = bind_rows(lapply(methods, deround.bch, h.seq=h.seq, window.fun=window.binom.ci, all.dat=all.dat, repl=1,use.dsr=FALSE, use.zda=FALSE))
  saveRDS(res.binom.ci, "Data/deround_binom_ci.Rds")

}

deround.bch = function(method,all.dat, tag=method, window.fun=window.binom.test, repl=30,z0=1.96,h.seq=c(0.05,0.075,0.1,0.2,0.3,0.4,0.5), use.dsr = TRUE,use.zda=TRUE,common.deci=FALSE,...) {
  library(RoundingMatters)
  restore.point("deround.bch")
  if (!is.function(window.fun)) stop("window.fun is not a function object")
  
  
  if (method != "ALL") {
    dat = all.dat[all.dat$method==method,]
  } else {
    dat = all.dat
  }
  

  res.rep = study.with.derounding(dat, mode="reported",h.seq=h.seq, repl=repl, z0=z0, window.fun = window.fun, common.deci=common.deci)
  
  res.omit = study.with.derounding(filter(dat, keep.obs), mode="reported",h.seq=h.seq, repl=repl,z0=z0, window.fun = window.fun, common.deci=common.deci)
  res.omit$mode = "omit"

  res.omit.unif = study.with.derounding(filter(dat, keep.obs), mode="uniform",h.seq=h.seq, repl=repl,z0=z0, window.fun = window.fun, common.deci=common.deci)
  res.omit.unif$mode = "omit.unif"

  res.uniform = study.with.derounding(dat, mode="uniform",h.seq=h.seq, repl=repl,z0=z0, window.fun = window.fun, common.deci=common.deci)
  res.uniform

  if (use.zda) {
    z.pdf = make.z.pdf(dat=dat, bw=0.05, min.s=100, show.hist=FALSE)
    res.zda = study.with.derounding(dat, mode="zda",h.seq=h.seq,z.pdf=z.pdf, repl=repl,z0=z0, window.fun = window.fun, common.deci=common.deci)
    res.zda
  
    z.pdf = make.z.pdf(dat=all.dat, bw=0.05, min.s=100, show.hist=FALSE)
    res.zda.all.pdf = study.with.derounding(dat, mode="zda",h.seq=h.seq,z.pdf=z.pdf, repl=repl,z0=z0, window.fun = window.fun, common.deci=common.deci)
    res.zda.all.pdf
    res.zda.all.pdf$mode = "zda.all.pdf"
  } else {
    res.zda = NULL
    res.zda.all.pdf = NULL
  }

  if (use.dsr) {
    if (method=="ALL") {
      ab.df = readRDS("Data/dsr_all.Rds")
    } else {
      m = method
      ab.df = readRDS("Data/dsr.Rds") %>% filter(method==m)
    }
    res.dsr = study.with.derounding(dat, mode="dsr",h.seq=h.seq,ab.df = ab.df, repl=repl,z0=z0, window.fun = window.fun, common.deci=common.deci)
  } else {
    res.dsr = NULL
  }
  
  res = bind_rows(res.rep,res.omit, res.omit.unif, res.uniform, res.zda, res.zda.all.pdf, res.dsr) %>%
    arrange(h)
  res$method = method
  res$tag = tag
  
  res
}

