*** create caliper table after applying omission approach 

* read in the data
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Data\"
capture use "MM_new.dta", clear 

* determine folder to store results
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Results\"


* drop obs with small significand
keep if keep_obs==1

* first: 5% threshold

local panel = 1

forval panel = 1(1)1 {

if "`panel'"=="1" {
	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"
}

eststo clear

probit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using caliper_table_`depvar'.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

}


* second: 10% threshold

* read in the data
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Data\"
capture use "MM_new.dta", clear 

* determine folder to store results
cd "C:\Users\ppuetz\Desktop\sciebo\methods_matter_replication\Submission AER\revision\comment_methods_matter\replication_repo_methods_matter_comment\Results\"


* drop obs with small significand
keep if keep_obs==1

local panel = 1

forval panel = 1(1)1 {

if "`panel'"=="1" {
	local depvar "sign_10pct"
	local threshold 1.644854
	local weight1 "pw="
	local weight2 "aw"
}

eststo clear

probit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using caliper_table_`depvar'.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

}

