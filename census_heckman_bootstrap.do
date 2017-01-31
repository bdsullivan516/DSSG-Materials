set more off

// program:  bootstrap_dssg.do
// task: Bootstrap standard errors for Heckman results
// project: Gender Wage Gap

*Make sure directory is set to file location

**************************
*Create bootstrap program*
**************************
cap program drop myboot
program define myboot, rclass
	preserve //preserve the data
	bsample //samples the data in memory with replacement
	
sum year
local yr=r(mean)

*Probit estimation for inverse Mills ratio, females only
quietly probit ftfy  c.__child06## (c.widowed c.divorced c.separated c.never_married) ///
	c.midwest c.south c.west ///
	c.pot_exp1## (c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp2## (c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp3## (c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp4## (c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	if sex==1 & synthetic==1 [pweight=perwt], robust
*Append synthetic individuals after running regression so they are not included in estimation
append using temp.dta
append using tempV2.dta
append using tempV3.dta
append using temp_marst.dta
append using temp_educ.dta
tempvar lambda_input lambda_female
predict `lambda_input' if sex==1, xb
gen `lambda_female' = normalden(-`lambda_input') / (1 - normal(-`lambda_input')) //inverse Mill's ratio
replace `lambda_female'=0 if sex==0 //selection for males is assumed to be zero
replace `lambda_female'=0 if synthetic>1 //when calculating selection-corrected wages, lambda is not included

replace year=1980 if timepd==0
replace year=2000 if timepd==1

*Wage regression
quietly reg log_hourly_wage c.sex##(c.widowed c.divorced c.separated c.never_married ///
	c.midwest c.south c.west ///
	c.pot_exp1##(c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp2##(c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp3##(c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp4##(c.hsd08 c.hsd911 c.hsg c.cg c.ad)) `lambda_female' ///
	if wagesmpl==1 & synthetic==1 [pw=perwt], robust
tempvar xb
predict `xb'

sum `xb' if sex==1 & synthetic==2 & year==`yr'
local m1=r(mean)
sum `xb' if sex==0 & synthetic==2 & year==`yr'
local m2=r(mean)
return scalar heck0_var=`m1'-`m2' //wage difference calculated using variable synthetics

sum `xb' if sex==1 & synthetic==3
local m1=r(mean)
sum `xb' if sex==0 & synthetic==3
local m2=r(mean)
return scalar heck0_fix=`m1'-`m2' //wage difference calculated using fixed synthetics

	foreach x in separated widowed divorced never_married married {
		sum `xb' if sex==1 & synthetic==4 & `x'==1
		local m1=r(mean)
		sum `xb' if sex==0 & synthetic==4 & `x'==1
		local m2=r(mean)
		return scalar heck0_`x'=`m1'-`m2' //wage difference using fixed synthetics, conditional on marst
	}
	foreach x in hsd08 hsd911 hsg sc cg ad {
		sum `xb' if sex==1 & synthetic==5 & `x'==1
		local m1=r(mean)
		sum `xb' if sex==0 & synthetic==5 & `x'==1
		local m2=r(mean)
		return scalar heck0_`x'=`m1'-`m2' //wage difference using fixed synthetics, conditional on education
	}

drop if synthetic>1 //drop appended data
	restore //return data to original state
end //end myboot program

**********************************
*Run regressions and save results*
**********************************
*Code is almost identical to myboot program
foreach z in /*1980*/ 2000{
use c_`z'_MR_exact.dta, clear 

*Probit estimation for inverse mills ratio, females only
quietly probit ftfy  c.__child06## (c.widowed c.divorced c.separated c.never_married) ///
	c.midwest c.south c.west ///
	c.pot_exp1## (c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp2## (c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp3## (c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp4## (c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	if sex==1 & synthetic==1 [pweight=perwt], robust
*Append synthetic individuals
append using temp.dta
append using tempV2.dta
append using tempV3.dta
append using temp_marst.dta
append using temp_educ.dta
cap drop lambda_input lambda_female
predict lambda_input if sex==1, xb
gen lambda_female = normalden(-lambda_input) / (1 - normal(-lambda_input))
replace lambda_female=0 if sex==0
replace lambda_female=0 if synthetic>1

replace year=1980 if timepd==0
replace year=2000 if timepd==1

*Wage regression
quietly reg log_hourly_wage c.sex##(c.widowed c.divorced c.separated c.never_married ///
	c.midwest c.south c.west ///
	c.pot_exp1##(c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp2##(c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp3##(c.hsd08 c.hsd911 c.hsg c.cg c.ad) ///
	c.pot_exp4##(c.hsd08 c.hsd911 c.hsg c.cg c.ad)) lambda_female ///
	if wagesmpl==1 & synthetic==1 [pw=perwt], robust
cap drop xb
predict xb

sum xb if sex==1 & year==`z' & synthetic==2
scalar m1=r(mean)
sum xb if sex==0 & year==`z' & synthetic==2
scalar m2=r(mean)
scalar heck_var=m1-m2 //wage difference calculated using variable synthetics
display "----------heck_var---------"
display heck_var


sum xb if sex==1 & synthetic==3
scalar m1=r(mean)
sum xb if sex==0 & synthetic==3
scalar m2=r(mean)
scalar heck_fix=m1-m2 //wage difference calculated using fixed synthetics
display "----------heck_fic---------"
display heck_fix

	foreach x in separated widowed divorced never_married married {
		sum xb if sex==1 & synthetic==4 & `x'==1
		scalar m1=r(mean)
		sum xb if sex==0 & synthetic==4 & `x'==1
		scalar m2=r(mean)
		scalar heck_`x'=m1-m2 //wage difference using fixed synthetics, conditional on marst
		display "----------heck_`x'---------"
		display heck_`x'
	}
	foreach x in hsd08 hsd911 hsg sc cg ad {
		sum xb if sex==1 & synthetic==5 & `x'==1
		scalar m1=r(mean)
		sum xb if sex==0 & synthetic==5 & `x'==1
		scalar m2=r(mean)
		scalar heck_`x'=m1-m2 //wage difference using fixed synthetics, conditional on education
		display "----------heck_`x'---------"
		display heck_`x'
	}
drop if synthetic>1 

*Create matrix of wage gaps because more than one estimate is being bootstrapped
matrix diff=(heck_var, heck_fix, heck_married, heck_separated, heck_widowed, heck_divorced, ///
	heck_never_married, heck_hsd08, heck_hsd911, heck_hsg, heck_sc, ///
	heck_cg, heck_ad)
matrix colnames diff= heck_var, heck_fix, heck_married, heck_separated, heck_widowed, heck_divorced, ///
	heck_never_married, heck_hsd08, heck_hsd911, heck_hsg, heck_sc, ///
	heck_cg, heck_ad
matrix list diff

***************************
*Bootstrap standard errors*
***************************
simulate heck_var=r(heck0_var) heck_fix=r(heck0_fix) heck_married=r(heck0_married) ///
	heck_separated=r(heck0_separated) ///
	heck_widowed=r(heck0_widowed) heck_divorced=r(heck0_divorced) ///
	heck_never_married=r(heck0_never_married)  ///
	heck_hsd08=r(heck0_hsd08) heck_hsd911=r(heck0_hsd911) heck_hsg=r(heck0_hsg) ///
	heck_sc=r(heck0_sc) heck_cg=r(heck0_cg) heck_ad=r(heck0_ad) ///
	, reps(5) seed(123): myboot

**************************************************
*Store estimates and their bootstraped std errors*
**************************************************
bstat, stat(diff)
matrix heck_gap_`z'=(e(b)\ e(se))'
} //end *.dta, clear
