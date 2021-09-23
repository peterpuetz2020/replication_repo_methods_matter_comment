clear
set more off

* read in the data
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Data"
capture use "MM_new.dta", clear 


********** dropping significands 
keep if keep_obs==1

levelsof method, local(methods) 
foreach method of local methods{
	di "`method'"
preserve
drop if mu ==.
drop if sigma ==.
drop if sigma<= 0
keep if method=="`method'" 
drop if abs(t)>10
replace mu = abs(mu)
keep mu sigma 
export delimited using "`method'.csv", novarnames replace
restore
}
** and these are put into AK website
