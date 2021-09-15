*** create Figures 1 and 2 after applying omission approach

clear
set more off

* read in the data
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Data"
capture use "MM_new.dta", clear 

* set folder to store results
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Results"

*** caliper tables after applying omission approach
* drop obs with small significand
keep if keep_obs==1

*** BCH figure 1a
histogram t if t <= 10 , title() width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

graph export figure1a_BCH_omission.pdf, replace 

*** BCH figure 1b

histogram t if t <= 10 & top5==1 , title("Top 5") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & top5==0 , title("Non-Top 5") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
graph export figure1b_BCH_omission.pdf, replace 

*** BCH figure 2

histogram t if t <= 10 & method=="DID"  , title("DID") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="IV" , title("IV") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RCT" , title("RCT") saving(temp3, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RDD", title("RDD") saving(temp4, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(3)
graph export figure2_BCH_omission.pdf, replace 


*** BCH Figure 3 after applying omission approach
*** Note that it is not possible with the available star wars data to drop the standard errors with significand < 37, 
*** i.e. the upper left picture in BCH's figure 3 does not change after applying our omission procedure. 

clear all
set more off
* read in the data
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Data"

*** figure 3a
use "Star Wars Data.dta", clear
rename journal journal_name

append using "MM_new.dta", force

* determine folder to store results
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Results\"

* drop observartions with standard errors with significand < 37
keep if (keep_obs==1 | keep_obs==.)

capture drop top3

gen top3 = 0
replace top3 = 1 if strpos(journal_name,"Quarterly Journal of Economics")
replace top3 = 1 if strpos(journal_name,"Journal of Political Economy")
replace top3 = 1 if strpos(journal_name,"American Economic Review")

histogram t if t <= 10 & year<2015 & top3==1 , title("2005-2011") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & year>=2015 & top3==1 , title("2015 & 2018") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(1.5)
graph export figure3a_BCH_omission.pdf, replace 



*** figure 3b

* read in the data
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Data\"
capture use "MM_new.dta", clear 

* determine folder to store results
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Results\"

*** caliper tables after applying omission approach
* drop obs with small significand
keep if keep_obs==1

histogram t if t <= 10 & year==2015 , title("2015") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & year==2018 , title("2018") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
graph export figure3b_BCH_omission.pdf, replace 

*** figure 4 combined with the t density scaled such that area under the curve is equal to one - but note that the curve is not fully visible (only for t < 10). We scale the empirical densities accordingly by considering the t>10 that are not included in the the density estimator: we scale the observed density by the share of observations with t<10

* read in the data
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Data\"
capture use "MM_new.dta", clear 

* determine folder to store results
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Results\"

capture drop x
gen x = _n / 100
replace x = . if _n > 1000

local methods DID IV RCT RDD
foreach method of local methods {

if "`method'"=="DID" {
	local df = 2
	local np = 1.81
}
if "`method'"=="IV" {
	local df = 2
	local np = 1.65
}
if "`method'"=="RCT" {
	local df = 2
	local np = 1.16
}
if "`method'"=="RDD" {
	local df = 2
	local np = 1.51
}

capture drop pdf_t F_0 pdf_t_scaled
gen pdf_t = ntden(`df',`np',x)
* calculate probability mass left of zero
gen F_0 = nt(`df',`np',0)
* scale non-central t distribution accordingly
gen pdf_t_scaled = pdf_t/(1-F_0)
** scale observed density
* save calculated densities for the kernel estimator (with t <10 only)
kdensity t if method=="`method'" & t<10, generate (`method'_x `method'_y) n(1000)
* calculate share of observations smaller than 10
capture drop sm_10 share_sm_10
gen sm_10 = 0 if method=="`method'"
replace sm_10 = 1 if t < 10 & method=="`method'"
sum sm_10
return list
gen share_sm_10 = r(mean)
* scale calculated densities accordingly
replace `method'_y = `method'_y*share_sm_10
** same for kernel estimator for omission approach
* save calculated densities for the kernel estimator (with t <10 only)
kdensity t if method=="`method'" & t<10 & keep_obs==1, generate (`method'_x_sm_37 `method'_y_sm_37) n(1000)
* calculate share of observations smaller than 10
capture drop sm_10_sm_37 share_sm_10_sm_37
gen sm_10_sm_37 = 0 if method=="`method'" & keep_obs==1
replace sm_10_sm_37 = 1 if t < 10 & method=="`method'" & keep_obs==1
sum sm_10_sm_37
return list
gen share_sm_10_sm_37 = r(mean)
* scale calculated densities accordingly
replace `method'_y_sm_37 = `method'_y_sm_37*share_sm_10_sm_37


label var pdf_t_scaled "t~(`df',`np')"

twoway 	(line pdf_t_scaled x, lpattern(dash) sort) ///
	(line `method'_y `method'_x, lcolor(black)) || (line `method'_y_sm_37 `method'_x_sm_37, lcolor(teal)) ///
	, scheme(s1mono) xlabel(0 1.65 "*" 1.96 "**" 2.58 "***" 5 10) xtitle("z-statistic") xline(1.65 1.96 2.58, lwidth(vvthin)) saving(`method',replace) legend(pos(2) ring(0) col(1) lab(1 "t~(`df',`np')") lab(2 "`method' (BCH)") lab(3 "`method' (adjusted)"))

}

graph combine DID.gph IV.gph RCT.gph RDD.gph, ycommon scheme(s1mono)
graph export figure4_BCH_omission.pdf, replace 

capture erase DID.gph 
capture erase IV.gph 
capture erase RCT.gph 
capture erase RDD.gph 



*** figure 5a
* drop obs with small significand
keep if keep_obs==1
capture destring fstat, replace force

histogram fstat if fstat <= 50 , title() width(2) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts() xtitle(F-Statistic) xline(10, lwidth(thin)) xlabel(0 10 20 30 40 50) legend(off) scheme(s1mono)
graph export figure5a_BCH_omission.pdf, replace 

*** figure 5b

capture destring fstat, replace force

histogram t if t <= 10 & method=="IV" & fstat< 30 , title("F less than 30") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

histogram t if t <= 10 & method=="IV" & fstat>= 30 , title("F greater than or equal to 30") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon xsize(4) ysize(1.5) caption()
graph export figure5b_BCH_omission.pdf, replace 

*** figure 6

* read in the data
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Data\"
capture use "MM Data with WP ready.dta", clear 

* determine folder to store results
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Results\"

*** caliper tables after applying omission approach
* drop obs with small significand
keep if keep_obs==1

histogram t if t <= 10 & WP==0, title("Published") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)
histogram t if t <= 10 & WP==., title("Working Paper") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
graph export figure6_BCH_omission.pdf, replace 