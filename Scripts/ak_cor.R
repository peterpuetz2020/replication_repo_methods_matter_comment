# This code computes the correlations used as specification test for 
# Andrews and Kasy
# Using 50 cores in parallel it takes around half a day to run 

compute.ak.cors = function() {
  library(MetaStudies)
  B = 500
  num.cores = 50
  compute.ak.cor(mode="drop_10", panel="A", B=B,  num.cores = num.cores)
  compute.ak.cor(mode="new_10", panel="A", B=B,  num.cores = num.cores)
  compute.ak.cor(mode="new_10", panel="B", B=B,  num.cores = num.cores)
  compute.ak.cor(mode="drop_10", panel="B", B=B,  num.cores = num.cores)
}

compute.ak.cor = function(mode, panel="A", B=500, num.cores = 10) {
  restore.point("compute.ak.cor")
  methods = c("DID","IV","RCT","RDD")
  cat("\n***************************************")
  cat("\n", mode, " panel ", panel)
  cat("\n***************************************\n")
  
  m = methods[2]
  for (m in methods) {
    cat("\n",m,"\n\n")
    dat = read.csv(paste0("ak_csv/", m,"_",mode, ".csv"))
    X = dat[,1]
    sigma = dat[,2]
    #ms = metastudies_estimation(X,sigma, cutoffs = c(1.645, 1.96, 2.576), symmetric=TRUE, model="t")
    cutoffs = 
    if (panel == "B") {
      cutoffs = c(1.645, 1.96, 2.326)      
    } else {
      cutoffs = 1.96
    }
    ms = metastudies_estimation(X,sigma, cutoffs = cutoffs, symmetric=TRUE, model="t")
    
    res = metastudy_X_sigma_cors(ms)
    res$method = m
    res = res %>% select(method, everything())
    file.post = paste0(m,"_", mode, "_",panel,".Rds")
    
    saveRDS(res,paste0("ak_cor/ak_cor_",file.post))
  
    bs.res = bootstrap_specification_tests(X=X, sigma=sigma, cutoffs = cutoffs, B=B, symmetric=TRUE, num.cores = num.cores, model="t")
  
    bs.sum = bs.res$bs.sum
    bs.sum$method = m
    bs.sum = bs.sum %>% select(method, everything())
    saveRDS(bs.sum,paste0("ak_cor/ak_cor_boot_sum_",file.post))
  
    bs.sim = bs.res$bs.sim
    bs.sim$method = m
    bs.sim = bs.sim %>% select(method, everything())
    saveRDS(bs.sim,paste0("ak_cor/ak_cor_boot_sim_",file.post))
  }
}

collect.bootstrap.stats = function() {
  # Collect summary statistics presented in working paper
  files = list.files("ak_cor",glob2rx("ak_cor_boot_sum*.Rds"),full.names = TRUE) 
  
  
  file = files[1]

  sum.df = bind_rows(lapply(files, function(file) {
    df = readRDS(file)
    str = str.between(file, "ak_cor_boot_sum_",".")
    parts = strsplit(str,split = "_", fixed=TRUE)[[1]]
    df$dataset = parts[2]
    df$t_max = as.integer(parts[3])
    df$panel = parts[4]
    df
  })) 
  sum.df = sum.df %>%
    filter(mode=="ipv", trans=="log") %>%
    #select(method, dataset, panel, t_max, trans, mode, stat, val= cor)
    group_by(method, dataset, panel, mode, t_max,trans) %>%
    summarize(
      ci.low = cor[1],
      ci.up = cor[2],
      cor.bootrap.mean = cor[3]
    )
      
  
  # Load estimates without bootstrap
  no.boot = read.csv("ak_cor_noboot.csv")
  
  sum.df = left_join(sum.df, no.boot)
  
  write.csv(sum.df, "ak_cor_sum.csv",row.names = FALSE)
  
}

compute.ak.cors.no.ci = function(datasets = c("new","drop"), t.max = c(10,100), panels = c("A","B"), t_max = c(10,100), num.cores = 32) {
  restore.point("compute.ak.cors.no.ci")
  methods = c("DID","IV","RCT","RDD")
  grid = expand_grid(method=methods, dataset=datasets, panel=panels, t_max=t_max)
  
  i = 1
  bs = bind_rows(mclapply(1:NROW(grid), mc.cores=num.cores, function(i) {
    g = grid[i,]
    dat = read.csv(paste0("ak_csv/", g$method,"_",g$dataset,"_",g$t_max, ".csv"))
    X = dat[,1]
    sigma = dat[,2]
    
    if (g$panel == "B") {
      cutoffs = c(1.645, 1.96, 2.326)      
    } else {
      cutoffs = 1.96
    }
    ms = metastudies_estimation(X,sigma, cutoffs = cutoffs, symmetric=TRUE, model="t")
    res = metastudy_X_sigma_cors(ms)
    res$panel = g$panel
    res$method = g$method
    res$dataset = g$dataset
    res$t_max = g$t_max
    select(res, method, dataset, panel, t_max, trans, mode, cor, beta, r.sqr) %>% filter(mode == "ipv")
  }))
  
  write.csv(bs, "ak_cor_noboot.csv", row.names = FALSE)
  
  temp = bs %>% filter(trans == "log")
}
