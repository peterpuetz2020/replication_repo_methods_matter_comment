# R code to generate CSV files used for AK app

make.all.ak.csv = function() {
  library(here)
  library(tidyverse)
  out.dir = here("Data")

  dat = rio::import(here("Data","MM_new.Rds"))
  make.ak.new.csv(dat, type = "new", out.dir)

  make.ak.new.csv(dat %>% filter(keep.obs), type = "drop", out.dir)

  # The code below generates CSV files from  
  # the original AER data supplement
  # you need to adapt the path
  
  #dat = rio::import("C:/research/comment_phack/bch_supplement/MM Data.dta")

  #make.ak.aer.csv(dat, type = "aer", out.dir)

}

make.ak.aer.csv = function(dat, type="aer", out.dir) {
  methods = c("DID","IV","RCT", "RDD")
  for (m in methods) {
    for (t.max in c(10,100)) {
      d = dat %>% filter(
        !is.na(mu),
        !is.na(sd),
        sd > 0,
        method == m,
        abs(t) <= t.max
        ) %>%
        transmute(mu = abs(mu), sd=sd)
      
      file = paste0(out.dir,"/", m, "_",type,"_",t.max,".csv")
      write.table(d, file,col.names = FALSE, quote=FALSE, sep=",", row.names=FALSE)
    }
  }
  
}


make.ak.new.csv = function(dat, type="new", out.dir) {
  methods = c("DID","IV","RCT", "RDD")
  for (m in methods) {
    for (t.max in c(10,100)) {
      d = dat %>% filter(
        !is.na(mu),
        !is.na(sigma),
        sigma > 0,
        method == m,
        abs(z) <= t.max
        ) %>%
        transmute(mu = abs(mu), sd=sigma)
      
      file = paste0(out.dir,"/", m, "_",type,"_",t.max,".csv")
      write.table(d, file,col.names = FALSE, quote=FALSE, sep=",", row.names=FALSE)
    }
  }
  
}

# Below is BCH's Stata code that we adapt

# capture use "MM Data.dta", clear
# 
# levelsof method, local(methods) 
# foreach method of local methods{
# 	di "`method'"
# preserve
# drop if mu ==.
# drop if sd ==.
# drop if sd <= 0
# keep if method=="`method'" 
# drop if abs(t)>10
# replace mu = abs(mu)
# keep mu sd 
# export delimited using "`method'.csv", novarnames replace
# restore
# }