# Creates the data set "MM_new.Rds"
# It contains some new columns such as a column indicating the significand of the standard error
# and removes unused columns 
# input data BHC's updated dataset "MM data 2021_04.dta"
adapt.MM.data = function() {
  library(dplyr)
  library(RoundingMatters)
  library(rio)
  library(haven)
  # read in the dataset provided by BCH
  # org.dat.raw = rio::import("Data/MM Data 2021_04.Rds")
  # this dataset can be saved as dta
  # write_dta(org.dat.rds, "Data/MM Data 2021_04.dta")
  # and further transformed in Stata by BCH's code provided in "read_in_and_transform_stata_data.do" (adjust directory at top of the script)
  # the resulting file "mm_data_ready.dta" can be read in again
  # org.dat = rio::import("Data/mm_data_ready.dta")
  # and saved as RDS file (to save memory)
  # saveRDS(org.dat, "Data/MM_Data_2021_04_processed.Rds")
  # or just read in the resulting file
  org.dat = rio::import("Data/MM_Data_2021_04_processed.Rds")
  
  # Issues:
  
  # 1. We have 113 some observations with report="s" but NA for sd
  #    We will not deround or omit those, but correct the assigned test statistic reported
  # temp = filter(org.dat, is.na(sd_orig) & report=="s")
  # attr(dat$ireport,"labels")
  
  # 2. Some sd are reported negative
  #    Set them positive
    
  # 3. Some sd_new_string are a point "."
  #    Set sigma to sd_orig
  
  # 4. t is not updated for sd_new or mu_new
  #    We recompute z = abs(mu)/sigma for all obs with report = "s"
  #    and mu and sigma are not NA.
  
  # 5. Dealing with observations with sigma = 0 
  #    We use BCH's t-statistic.
  #    These observations are always omitted in our ommission aproach
  #    since s = 0 < 37
  #    When derounding, sigma will be different from 0
  
  # 6. Observations that will never be derounded or never ommited:
  #    no.deround = is.true(report != "s" | is.na(sigma) | is.na(mu)),
  #    keep.obs = is.true(s >= 37 | is.na(sigma) | report != "s")
  

    # Create some helper columns and only keep used columns
  options(scipen=999)
  
  dat = org.dat %>%
    mutate(
      rowid = 1:n(),
      # account for issue 1. from above
      report=ifelse(is.na(sd_orig) & report=="s", "t", report),
      ireport=ifelse(is.na(sd_orig) & ireport==3, 4, ireport),
      # are there updated values for mu and sigma?
      mu_is_new = is.true(trimws(mu_new_string)!="" & !is.na(mu_new)),
      sigma_is_new = is.true(trimws(sd_new_string)!="" & !is.na(sd_new)),
      # if so, assign the updated values to string variables, otherwise consider old values
      mu_str = ifelse(mu_is_new,mu_new_string, as.character(mu_orig)),
      sd_str = ifelse(sigma_is_new,sd_new_string, as.character(sd_orig)),
      # transform those string variables to numeric variables, 
      # thereby account for issue 2. and 3. ("." is transformed to NA) from above
      mu = as.numeric(mu_str),
      sigma = abs(as.numeric(sd_str)),
      # create new string variable for sigma that will be used eventually
      sigma_str = ifelse(is.na(sd_str) | trimws(sd_str)=="", as.character(sigma), sd_str),
      # compute number of decimals for mu und sigma
      mu.deci = num.deci(mu_str),
      sigma.deci = num.deci(sigma_str),
      # compute maximum of decimals 
      num.deci = pmax(mu.deci, sigma.deci),
      
      # issue 4.
      # If mu or sigma is new use them to compute z
      # since the column t is not always updated otherwise;
      z = abs(ifelse(is.true(report=="s" & (mu_is_new|sigma_is_new) & (sigma!=0)), abs(mu) / sigma,t))
    )
  
  dat = dat %>%
    select(journal, article, journal_name, table,z, mu,sigma,sigma.deci, mu.deci, num.deci, report, method, title, mu_str,sigma_str, year, rct_pre_registered, registered, t.bch = t,
           experience_avg, experience_avg_sq, share_top_authors, share_top_phd, top5, aw,  sign_10pct, sign_5pct, sign_1pct, journal_article_cluster, ireport,
           authored_solo, share_female_authors, editor_present, FINANCE, MACRO_GROWTH, GEN_INT, EXP, DEV, LABOR, PUB, URB, unique_j, DID, IV, RDD, RCT ) %>%
    mutate(
      rowid = 1:n(),
      # compute significand for standard error
      s = significand(sigma, sigma.deci),
      #no.deround = is.true(report != "s" | is.na(sigma) | is.na(mu)),
      # keep observation only if significand for standard error >=37 or sigma not reported
      # or reporting type not equal to "s" ("s" means that mu and sd are reported)
      keep.obs = is.true(s >= 37 | is.na(sigma) | report != "s")
    )
  
  # save dataset in R format
  saveRDS(dat, "Data/MM_new.Rds")
  # make copy of the dataset
  invisible(dat)
  
  # save also as stata file, for this sake, recode column names
  dat_stata <- dat
  names(dat_stata ) <- gsub("\\.","_",names(dat_stata ))
  # rename t variable
  dat_stata  <- dat_stata  %>% 
    mutate(t=z)
  write_dta(dat_stata , "Data/MM_new.dta")
}
