# Replicate Table 5 in BCH
# we consider different variants:
# orginal AER data set,
# new data set
# rounding adjusted data set with dropped oberservations
make.ak.tables = function() {
  library(MetaStudies)
  library(here)
  library(restorepoint)
  
  modes = c("aer_10","aer_100","new_10","new_100","drop_10","drop_100")
  lapply(modes,make.ak.table)
}

make.ak.table = function(mode) {
  restore.point("make.ak.table")
  methods = c("DID","IV","RCT","RDD")
  panelA = bind_rows(lapply(methods, est.ak, panel="A", mode=mode))
  
  panelB = bind_rows(lapply(methods, est.ak, panel="B", mode=mode))
  
  panel = bind_rows(panelA, panelB)
  library(xglue)
  tpl = readLines(here("Tex_templates","tab_bch_ak_tpl.tex"))

  d = function(p, col, row) {
    rows = panel$panel == p & panel$row == row
    #return(panel[rows,])
    round(panel[[col]][rows],3) %>% format(nsmall=3)
  }
  d("A","estimate",1)
  res = xglue(tpl, open="<<", close=">>")
  writeLines(res, here("Results", paste0("tab_bch_ak_",mode,".tex")))
  invisible(res)
}



est.ak = function(m, panel="A", mode="", verbose=TRUE) {
  restore.point("est.ak")
  cat("\n",m, " ", mode, " panel ", panel, " \n\n")
  dat = read.csv(here("Data",paste0(m, "_", mode,".csv")))
  X = dat[,1]
  sigma = dat[,2]
  if (panel == "B") {
    ms = metastudies_estimation(X,sigma, cutoffs = c(1.645, 1.96, 2.326), symmetric=TRUE, model="t")
    inds = c(4:6,1:3)
  } else {
    ms = metastudies_estimation(X,sigma, cutoffs = c(1.96), symmetric=TRUE, model="t")
    inds = c(4,1:3)
  }
  tab = ms$est_tab
  
  res = tibble(method=m, panel=panel, lab = colnames(tab)[inds],estimate=tab[1,inds], sd = tab[2,inds]) %>%
    mutate(row = 1:n())
}