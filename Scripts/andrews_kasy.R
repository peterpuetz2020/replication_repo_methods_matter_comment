# This code computes the correlations used as specification test for 
# Andrews and Kasy
# Using 50 cores in parallel it takes around half a day to run 

library(MetaStudies)
library(here)
methods = c("DID","IV","RCT","RDD")
m = methods[2]
for (m in methods) {
  cat("\n",m,"\n\n")
  dat = read.csv(here("Data",paste0(m, ".csv")))
  X = dat[,1]
  sigma = dat[,2]
  ms = metastudies_estimation(X,sigma, cutoffs = c(1.645, 1.96, 2.576), symmetric=TRUE, model="t")
  
  res = metastudy_X_sigma_cors(ms)
  res$method = m
  res = res %>% select(method, everything())
  saveRDS(res,here("Data",paste0("mu_sigma_cors_", m,".Rds")))

  bs.res = bootstrap_specification_tests(X=X, sigma=sigma, cutoffs = c(1.645, 1.96, 2.576), B=500, symmetric=TRUE, num.cores = 50, model="t")

  bs.sum = bs.res$bs.sum
  bs.sum$method = m
  bs.sum = bs.sum %>% select(method, everything())
  saveRDS(bs.sum,here("Data",paste0("boot_mu_sigma_cor_sum_", m,".Rds")))

  bs.sim = bs.res$bs.sim
  bs.sim$method = m
  bs.sim = bs.sim %>% select(method, everything())
  saveRDS(bs.sim,here("Data",paste0("boot_mu_sigma_cor_sim_", m,".Rds")))


}

# Collect summary statistics presented in working paper
sum.df = bind_rows(lapply(methods, function(m) {
  readRDS(here("Data",paste0("boot_mu_sigma_cor_sum_", m,".Rds")))
})) 
sum.df = sum.df %>%
  filter(mode=="ipv", trans=="log") %>%
  select(method, trans, mode, stat, cor, beta, r.sqr)

write.csv(sum.df, here("Results","boot_mu_sigma_cor_sum.csv"),row.names = FALSE)
