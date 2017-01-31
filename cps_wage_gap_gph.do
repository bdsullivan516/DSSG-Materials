use MR_work/mr_datasets/temp_allV2.dta, clear

gen lhw_diff=.
	forval j=1/6{ //timepd
		forval i=0/1 { //sex
			sum log_hourly_wage if sex==`i' & timepd==`j' & wagesmpl==1 & wgt>=0 [w=wgt]
			scalar lhw`i'`j'=r(mean)
		}
		
		replace lhw_diff=lhw1`j'-lhw0`j' if timepd==`j'
	}
	
gen lfp0=.
gen lfp1=.
	forval j=1/6{ //timepd
		forval i=0/1 { //sex
			sum ftfy if sex==`i' & timepd==`j' & wgt>=0 [w=wgt]
			replace lfp`i'=r(mean) if sex==`i' & timepd==`j' 
		}
	}
bysort timepd sex: keep if _n==1 //make pdf size smaller

twoway (line lhw_diff timepd, yaxis(1) color(gs0)  mcolor(gs0) msize(medlarge)) ///
       (line lfp0 timepd, yaxis(2) color(gs0) lpattern(longdash)) ///
	   (line lfp1 timepd, yaxis(2) color(gs0) lpattern(dot)) ///
	,graphregion(fcolor(white) margin(medlarge) color(white)) plotregion(fcolor(white) margin(medlarge)) ylabel(, glcolor(white)) ///
	bgcolor(white) ///
	xtitle(" " "Time Period") ytitle("Log(female/male)") xsize(6) ytitle("FTFY Participation Rate",axis(2)) ///
	xlabel(1 "1970-1974" 2 "1975-1979" 3 "1980-1984" 4 "1985-1989" 5 "1990-1994" 6 "1995-1999", labsize(small)) ///
	legend(order( 1 "Relative Average Log Wages" 2 "Male FTFY Participation Rate" 3 "Female FTFY Participation Rate" ) ///
	cols(1) position(5) ring(0) region(lcolor(white)) size(small) symxsize(*.5)  )

graph export MR_work/tex/graphs/wage_gap_cps.eps, replace
