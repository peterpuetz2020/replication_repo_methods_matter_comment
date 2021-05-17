*** create results for amount of distortion (following Andrews & Kasy 2019) after applying omission approach

* we create csv's here of our data 
* ready to be plugged into a readily avilable app at Maximilian Kasy's (of Andrews & Kasy 2019) website or in our R script andrews_kasy.R
clear all
set more off
* read in the data
cd "...\Data\"
capture use "MM_new.dta", clear 


********** dropping significands 
keep if keep_obs==1

levelsof method, local(methods) 
foreach method of local methods{
	di "`method'"
preserve
drop if mu ==.
drop if sigma ==.
drop if sigma <= 0
keep if method=="`method'" 
drop if abs(t)>100
keep mu sigma
export delimited using "`method'.csv", novarnames replace
restore
}
