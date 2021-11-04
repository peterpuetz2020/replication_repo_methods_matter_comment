*** This script replicates BCH's Figures 1 to 6 except for Figure 4 which is replicated using R.

clear
set more off

* read in the data
cd "...\Data"
capture use "MM_new.dta", clear 

* set folder to store results
cd "...\Results"

*** caliper tables after applying omission approach
* drop obs with small significand
keep if keep_obs==1


*** BCH figure 1a
histogram t if t <= 10 , saving(temp1, replace) title() width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic, size(large)) ytitle(Density, size(large)) xline(1.65 1.96 2.58, lwidth(thin))  xlabel(0(1)10, labels labsize(large)) ylabel(, labels labsize(large)) legend(off) scheme(s1mono)
graph export figure1a_BCH_omission.pdf, replace 
* graph export figure1a_BCH_omission.png, replace width(1000)

*** BCH figure 1b

histogram t if t <= 10 & top5==1 , title("Top 5") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic, size(large)) ytitle(Density, size(large)) xline(1.65 1.96 2.58, lwidth(thin))  xlabel(0(1)10, labels labsize(large)) ylabel(, labels labsize(large)) legend(off) scheme(s1mono)
graph export figure1b_BCH_omission.pdf, replace

histogram t if t <= 10 & top5==0 , title("Non-Top 5") saving(temp3, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic, size(large)) ytitle(Density, size(large)) xline(1.65 1.96 2.58, lwidth(thin))  xlabel(0(1)10, labels labsize(large)) ylabel(, labels labsize(large)) legend(off) scheme(s1mono)
graph export figure1c_BCH_omission.pdf, replace


*** BCH figure 2

histogram t if t <= 10 & method=="DID"  , title("DID") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono) 
histogram t if t <= 10 & method=="IV" , title("IV") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RCT" , title("RCT") saving(temp3, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RDD", title("RDD") saving(temp4, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(3)
graph export figure2_BCH_omission.pdf, replace 


*** BCH Figure 3 after applying omission approach
*** Note that we used a approximate merging procedure to get the standard errors for the
*** Star Wars data 

clear all
set more off
* read in the data
cd "...\Data"

*** figure 3a
use "starwars_bch_pk.dta", clear
rename journal journal_name

append using "MM_new.dta", force

* determine folder to store results
cd "...\Results\"

* drop observartions with standard errors with significand < 37
keep if (keep_obs==1 | keep_obs==.)

capture drop top3

gen top3 = 0
replace top3 = 1 if strpos(journal_name,"Quarterly Journal of Economics")
replace top3 = 1 if strpos(journal_name,"Journal of Political Economy")
replace top3 = 1 if strpos(journal_name,"American Economic Review")

histogram t if t <= 10 & year<2015 & top3==1 , title("2005-2011") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & year>=2015 & top3==1 , title("2015 & 2018") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)


*** figure 3b

* read in the data
cd "...\Data\"
capture use "MM_new.dta", clear 

* determine folder to store results
cd "...\Results\"

*** caliper tables after applying omission approach
* drop obs with small significand
keep if keep_obs==1

histogram t if t <= 10 & year==2015 , title("2015") saving(temp3, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & year==2018 , title("2018") saving(temp4, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(3)
graph export figure3_BCH_omission.pdf, replace 


*** figure 5a
* drop obs with small significand
keep if keep_obs==1
capture destring fstat, replace force

histogram fstat if fstat <= 50 , title() width(2) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts() xtitle(F-statistic, size(large)) ytitle(Density, size(large)) xline(10, lwidth(thin)) xlabel(0 10 20 30 40 50, labels labsize(large)) ylabel(, labels labsize(large)) legend(off) scheme(s1mono)
graph export figure5a_BCH_omission.pdf, replace 

*** figure 5b

capture destring fstat, replace force

histogram t if t <= 10 & method=="IV" & fstat< 30 , title("F less than 30") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) ytitle(Density, size(large)) xtitle(z-statistic, size(large)) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10, labels labsize(large)) ylabel(, labels labsize(large)) legend(off) scheme(s1mono)
graph export figure5b_BCH_omission.pdf, replace 


histogram t if t <= 10 & method=="IV" & fstat>= 30 , title("F greater than or equal to 30") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) ytitle(Density, size(large)) xtitle(z-statistic, size(large)) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10, labels labsize(large)) ylabel(, labels labsize(large)) legend(off) scheme(s1mono)
graph export figure5c_BCH_omission.pdf, replace 

*graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon xsize(8) ysize(3) caption()
*graph export figure5b_BCH_omission.pdf, replace 

*** figure 6

* read in the data
cd "...\Data\"
capture use "MM Data with WP ready.dta", clear 

* determine folder to store results
cd "...\Results\"


* drop obs with small significand
keep if keep_obs==1

histogram t if t <= 10 & WP==0, title("Published") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) ytitle(Density, size(large)) xtitle(z-statistic, size(large)) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10, labels labsize(large)) ylabel(, labels labsize(large)) legend(off) scheme(s1mono)
graph export figure6a_BCH_omission.pdf, replace 
histogram t if t <= 10 & WP==., title("Working Paper") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) ytitle(Density, size(large)) xtitle(z-statistic, size(large)) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10, labels labsize(large)) ylabel(, labels labsize(large)) legend(off) scheme(s1mono)
graph export figure6b_BCH_omission.pdf, replace 

*graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
*graph export figure6_BCH_omission.pdf, replace 