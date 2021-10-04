# Creates the data set "starwars_bch_pk.dta" to replicate Figure 3 in BCH
# It contains some new columns such as a column indicating the significand of the standard error
# and removes unused columns 
# input data: 1. BHC's dataset "Star Wars Data.dta" that includes Star Wars data from 
# Brodeur et al. (2016), but only those tests applying one of the 4 identification
# methods and no standard deviations; 
# 2. The original Star Wars data
# "final_stars_supp.dta" from Brodeur et al. (2016) including more tests and 
# standard deviations

library(haven)
library(dplyr)
library(RoundingMatters)

# Read in datasets
sw_bch <- read_dta("Data/Star Wars Data.dta")
sw_org <- read_dta("Data/final_stars_supp.dta")

# rename column
sw_org = sw_org %>% mutate(t = t_stat_raw)
# create row identifier
sw_bch = sw_bch %>% mutate(.ROW = 1:n())

# join datasets
sw = semi_join(sw_org, sw_bch)
sw = sw %>% left_join(sw_bch)

# for those tests in the smaller dataset that multiple tests from Brodeur et al. (2016),
# select just the first match (no perfect match possible)

sw = sw %>%
  group_by(.ROW) %>%
  mutate(
    count.row = n(),
    ind = 1:n()
  ) %>%
  filter(ind == 1)

# select variables of interest
sw = sw[, c("year", "journal", "issue", "article_page", "first_author", "coefficient",
            "coefficient_num", "standard_deviation",
           "standard_deviation_num", "t", "method", "IV", "DID", "RCT", "RDD", "MULTI")]

# calculate significant
sw = sw %>%
  mutate(
    mu_str = coefficient,
    sd_str = standard_deviation,
    mu = abs(coefficient_num),
    sigma = ifelse(!is.na(standard_deviation_num), abs(as.numeric(sd_str)), abs(mu/t)),
    sigma_str = ifelse(is.na(sd_str) | trimws(sd_str)=="", as.character(sigma), sd_str),
    sigma.deci = num.deci(sigma_str),
    s = significand(sigma, sigma.deci),
    keep_obs = (is.true(s >= 37 | is.na(sigma))*1)
  ) %>% 
  select(-contains("."))


# save resulting dataset
#write.csv(sw,"Data/starwars_bch_pk.csv", row.names = FALSE)
write_dta(sw,"Data/starwars_bch_pk.dta")

