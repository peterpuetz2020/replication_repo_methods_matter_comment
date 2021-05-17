library(RoundingMatters)
dat = readRDS("Data/MM_new.Rds")

# window sizes
h.seq = c(0.05,0.075,0.1,0.2,0.3,0.4,0.5)

# Find observations in data for which we shall perform dsr adjustment
dat = dsr.mark.obs(dat,h.seq = h.seq,no.deround = dat$no.deround)
# Create an data frame for the dsr approach
dsr = dsr.ab.df(dat, h.seq=h.seq, z0=1.96)
dsr$method = "ALL"

# save data
saveRDS(dsr,"Data/dsr_all.Rds")

# divide by method
methods = unique(dat$method)
big.dsr = bind_rows(lapply(methods, function(m) {
  mdsr = dsr.ab.df(filter(dat, method==m), h.seq=h.seq, z0=1.96)
  mdsr$method = m
  mdsr
}))
saveRDS(big.dsr,"Data/dsr.Rds")
