*******************
*Table 2A, Panel A*
*******************
*create heck change and associated std dev
matrix rep_table_2A`pop'male[1,7]=heck0_gap2000[2,1]-heck0_gap1980[2,1]
matrix rep_table_2A`pop'male[1,8]=sqrt((heck0_gap2000[2,2])^2 + (heck0_gap1980[2,2])^2)
*create bias and its std dev
matrix rep_table_2A`pop'male[1,9]= rep_table_2A`pop'male[1,5]-rep_table_2A`pop'male[1,7]
matrix rep_table_2A`pop'male[1,10]=sqrt((rep_table_2A`pop'male[1,6])^2 + (rep_table_2A`pop'male[1,8])^2)


*******************
*Table 2A, Panel B*
*******************
matrix heck0_table_2B70=heck0_gap1980[3..7,1...] 
matrix heck0_table_2B90=heck0_gap2000[3..7,1...]
*two-step change and its std error
forval i=1/5{
	matrix rep_table_2B`pop'male[`i',7]=heck0_table_2B90[`i',1] -heck0_table_2B70[`i',1]
	matrix rep_table_2B`pop'male[`i',8]=sqrt((heck0_table_2B90[`i',2])^2 + (heck0_table_2B70[`i',2])^2)
}

*bias and its std error
forval i=1/5 {
	matrix rep_table_2B`pop'male[`i',9]=rep_table_2B`pop'male[`i',5] - rep_table_2B`pop'male[`i',7]
	matrix rep_table_2B`pop'male[`i',10]=sqrt((rep_table_2B`pop'male[`i',6])^2 + (rep_table_2B`pop'male[`i',8])^2)
}
*matrix rownames rep_table_2B`pop'male = "Currently Married" "Separated" "Widowed" "Divorced" "Never Married"

*******************
*Table 2A, Panel C*
*******************
matrix heck0_table_2C70=heck0_gap1980[8...,1...]
matrix heck0_table_2C90=heck0_gap2000[8...,1...]
*two-step change and its std error
forval i=1/6{
	matrix rep_table_2C`pop'male[`i',7]=heck0_table_2C90[`i',1] -heck0_table_2C70[`i',1]
	matrix rep_table_2C`pop'male[`i',8]=sqrt((heck0_table_2C90[`i',2])^2 + (heck0_table_2C70[`i',2])^2)
}
*bias and its std error
forval i=1/6{
	matrix rep_table_2C`pop'male[`i',9]=rep_table_2C`pop'male[`i',5] - rep_table_2C`pop'male[`i',7]
	matrix rep_table_2C`pop'male[`i',10]=sqrt((rep_table_2C`pop'male[`i',6])^2 + (rep_table_2C`pop'male[`i',8])^2)
}
*matrix rownames rep_table_2C`pop'male = "0 to 8 years" "High School, not grad" "High school graduates" "Some College" "College" "Advanced Degree"


frmttable, statmat(rep_table_2A`pop'male) sdec(3) ///
	substat(1) addrow("","Panel B: By Marital Status", "", "", "") ///
	rtitles("Conditional on"\"  marital status"\"Not conditional on"\"  marital status")  ///
	store(rep_2A`pop'maleV2)
frmttable, statmat(rep_table_2B`pop'male) sdec(3) ///
	substat(1) addrow("","Panel C: By Education", "", "", "") store(rep_2B`pop'maleV2)
frmttable, statmat(rep_table_2C`pop'male) sdec(3) ///
	substat(1) store(rep_2C`pop'maleV2)


frmttable, replay(rep_2A`pop'maleV2) append(rep_2B`pop'maleV2) store(census_table2AB)
frmttable using MR_work/tex/tables/table2_census_`pop'_male, replay(census_table2AB) append(rep_2C`pop'maleV2) ///
 	ctitles("", "OLS","","", "Two-Step", "Bias" ///
	\ "\cmidrule(r){2-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6}", "1980", "2000", "Change", "Change", "Change" \ ///
	"","Panel A: All") ///
	multicol(1,2,3; 3,2,5; 8,2,5; 19,2,5) ///
	hlines(101{0}1) tex fragment replace nocenter statfont(normalsize) ///
	store(table2_`pop'_male)
	
} //end pop

frmttable using MR_work/tex/tables/table1_exact_merge , replay(table1_exact_female) merge(table1_exact_male) ///
	ctitles("", "Female Selection", "", "", "Female and Male Selection", "", "" \ "\cmidrule(r){2-4} \cmidrule(l){5-7}", "Method","","", "Method","","" \ "\cmidrule{2-3} \cmidrule{5-6} Period", "OLS", "Two-Step", "Bias", "OLS", "Two-Step", "Bias" \  "Panel A: Variable Weights (Synthetics)") ///
	multicol(1,2,3;1,5,3; 2,2,2; 2,5,2; 4,1,7; 11,1,7) statfont(normalsize) ///
	tex fragment replace nocenter hlines(1001{0}1)
	
	
frmttable using MR_work/tex/tables/table2_exact_merge , replay(table2_exact_female) merge(table2_exact_male) ///
	ctitles("","Female Selection", "", "", "", "", "Female and Male Selection", "", "", "", "" \ "\cmidrule(r){2-6} \cmidrule(l){7-11}", "OLS","","", "Two-Step", "Bias" , "OLS","","", "Two-Step", "Bias"  \ "\cmidrule(r){2-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6} \cmidrule(lr){7-9} \cmidrule(lr){10-10} \cmidrule(lr){11-11}", "1980", "2000", "Change", "Change", "Change", "1980", "2000", "Change", "Change", "Change" \ "","Panel A: All") ///
	multicol(1,2,5;1,7,5; 2,2,3; 2,7,3; 4,2,10; 9,2,10; 20,2,10) statfont(normalsize) ///
	tex fragment replace nocenter hlines(1001{0}1)
