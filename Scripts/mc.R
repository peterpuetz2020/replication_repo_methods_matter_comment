run.mc = function() {
  library(RoundingMatters)
  library(restorepoint)
  library(dplyr)

  org.dat = readRDS("Data/MM_new.Rds") %>%
    filter(sigma > 0) %>%
    mutate(z = abs(z)) %>%
    filter(z >= 0, z <= 2*1.96)

  res = mc.inner(org.dat,true.theta = 0.5, R=100)  
  res
  #n = 30; repl=10
  set.seed(123456789)
  repl=3; R=100
  
  repl=100000; R=100
  num.cores = 50
  
  set.seed(1)
  res50 = mc.parallel(repl=repl,org.dat=org.dat, true.theta = 0.5, R=R,num.cores = num.cores)
  saveRDS(res50,"Data/mcr_50.Rds")

  set.seed(1)
  res65 = mc.parallel(repl=repl,org.dat=org.dat, true.theta = 0.65, R=R,num.cores = num.cores)
  saveRDS(res65,"Data/mcr_65.Rds")
  
  set.seed(1)
  res35 = mc.parallel(repl=repl,org.dat=org.dat, true.theta = 0.35, R=R,num.cores = num.cores)
  saveRDS(res35,"Data/mcr_35.Rds")

  res = bind_rows(
    readRDS("Data/mcr_50.Rds") %>% mutate(true.theta=0.5),
    readRDS("Data/mcr_65.Rds") %>% mutate(true.theta=0.65),
    readRDS("Data/mcr_35.Rds") %>% mutate(true.theta=0.35)
  )

  sum = res %>%
    mutate(covered = true.theta >= ci.low & true.theta <= ci.up) %>%
    group_by(true.theta, mode) %>%
    summarize(
      true.theta = first(true.theta),
      bias.theta = mean(theta) - mean(true.theta),
      ci.low = mean(ci.low,na.rm=TRUE),
      ci.up = mean(ci.up, na.rm=TRUE),
      coverage = mean(covered, na.rm=TRUE),
      obs = mean(obs),
      mae = mean(abs(theta-true.theta)),
      rmse = sqrt(mean((theta-true.theta)^2)),    
      sd.theta = sd(theta),
    ) %>%
    mutate_if(is.numeric,~round(.,3)) %>%
    arrange(true.theta,-coverage)
  sum
  
  
  write.csv(sum, "Results/mc_sum.csv")
  
  # Show as in the working paper table
  levels = c("reported", "omit","star.wars","uniform", "zda.true","zda.20","zda.05")
  tab = sum %>%
    filter(mode %in% levels) %>%
    mutate(mode = ordered(mode, levels)) %>%
    arrange(true.theta, mode) %>%
    select(true.theta, mode, bias.theta, ci.low, ci.up, coverage, rmse)
  
  
  library(ggplot2)
  ggplot(res, aes(theta, fill=mode)) + geom_histogram() + facet_grid(true.theta~mode) + geom_vline(xintercept=true.theta)

}

# Perform repl runs of the Monte-Carlo simulation
# using num.cores in parallel
mc.parallel = function(repl=100, ..., num.cores=10) {
  library(parallel)
  start.time = Sys.time()
  
  cat("\nRun", repl, "replications... ")
  
  res = bind_rows(mclapply(mc.cores = num.cores,1:repl,function(i) {
    #cat("\n",i)
    mc.inner(...)
  }))
  cat(" done after", format(Sys.time()-start.time))
  res
}

# Simulate one data set with rounding errors,
# run different methods to deal with it and return
# results
mc.inner = function(org.dat,h.seq=0.2,  true.theta=0.5, z0=1.96, s.threshold = 37,R=100,n=NROW(org.dat),...) {
  restore.point("mc.inner")

  repl=R
  # 1. Draw z from uniform distributions left and right of z0
  z.help = runif(n, 0, z0)
  is.above = (runif(n, 0,1) <= true.theta)
  z.true = z0 + ifelse(is.above, z.help,-z.help)
  
  # 2. Draw sigma and num.deci from org.dat
  inds = sample.int(NROW(org.dat),n, replace=TRUE)
  num.deci = org.dat$num.deci[inds]
  sigma.true = org.dat$sigma[inds]
  
  # 3. Compute corresponding mu 
  mu.true = sigma.true*z.true
  
  # 4. Compute corresponding rounded reported values
  mu = round(mu.true, num.deci)
  sigma = round(sigma.true, num.deci)
  z = abs(mu / sigma)
  
  s = significand(sigma, num.deci)

  sim.dat = as.data.frame(list(mu=mu, sigma=sigma, z=z, s=s, num.deci=num.deci))
  
  if (FALSE) {
    hist(z)
    hist(z.true)
  }

  res.rep = study.with.derounding(sim.dat,h.seq=h.seq, mode="reported", repl=repl)

  make.z.fun = function(dat) dat$z+runif(NROW(dat),-0.5,0.5)
  res.noisy.z = study.with.derounding(sim.dat,h.seq=h.seq, make.z.fun=make.z.fun, mode="noisy.z", repl=repl)
 
  res.omit = study.with.derounding(filter(sim.dat, s>=s.threshold | is.na(s)),,h.seq=h.seq, mode="reported", repl=repl)
  res.omit$mode = "omit"
  
  
  
  res.omit.unif = study.with.derounding(filter(sim.dat, s>=s.threshold | is.na(s)),h.seq=h.seq, mode="uniform", repl=repl)
  res.omit.unif$mode = "omit.unif"
  
  res.uniform = study.with.derounding(sim.dat, mode="uniform",h.seq=h.seq, repl=repl)

  res.star.wars = study.with.derounding(sim.dat, mode="uniform",h.seq=h.seq, repl=1)
  res.star.wars$mode = "star.wars"
  
  # True density
  y.left = (1-true.theta) / max(true.theta, 1-true.theta)
  y.right = (true.theta) / max(true.theta, 1-true.theta)
  z.pdf = approxfun(x=c(-1,z0-1e-8,z0,3*z0),y=c(y.left, y.left, y.right, y.right),yleft = y.left,yright = y.right)
  res.zda.true = study.with.derounding(sim.dat, mode="zda",h.seq=h.seq,z.pdf=z.pdf, repl=repl, verbose=FALSE)
  res.zda.true$mode = "zda.true"
  
  
  z.pdf = make.z.pdf(dat=sim.dat, min.s=100,bw=0.2, show.hist=FALSE)
  res.zda.20 = study.with.derounding(sim.dat, mode="zda",h.seq=h.seq,z.pdf=z.pdf, repl=repl, verbose=FALSE)
  res.zda.20$mode = "zda.20"
  
  z.pdf = make.z.pdf(dat=sim.dat, min.s=100,bw=0.05, show.hist=FALSE)
  res.zda.05 = study.with.derounding(sim.dat,h.seq=h.seq, mode="zda",z.pdf=z.pdf, repl=repl,verbose=FALSE)
  res.zda.05$mode = "zda.05"
  
  res = bind_rows(res.rep,res.omit, res.omit.unif, res.uniform, res.star.wars,res.zda.true, res.zda.20, res.zda.05, res.noisy.z)
  
  res$true.theta = true.theta
  res$repl = R
  
  res
}
