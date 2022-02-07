*** Time Series Examples
use  https://github.com/JanDitzen/xtbreak/raw/main/data/US.dta

xtbreak deaths L.cases

xtbreak test deaths L1.cases, hypothesis(1) breaks(2)

xtbreak test deaths L1.cases, breakpoints(2020w20 2021w8 , fmt(tw))

xtbreak test deaths L1.cases, hypothesis(3) breaks(3)

xtbreak test deaths , breakconstant nobreakvar(L1.cases) breaks(3) h(1)

xtbreak estimate deaths L1.cases, breaks(2)

xtbreak estimate deaths L1.cases, breaks(2) showindex

estat split
reg deaths `r(varlist)'

xtbreak estimate deaths L1.cases, breaks(3) showindex
estat scatter L.cases

*** Graph with CI
xtbreak deaths L.cases
mata st_local("breaks",invtokens(strofreal(st_matrix("e(breaks)"))[2,.]))
mata st_local("ci_ups",invtokens(strofreal(st_matrix("e(CI)"))[2,.]))
mata st_local("ci_lows",invtokens(strofreal(st_matrix("e(CI)"))[1,.]))

sum date if e(sample)
local min = r(min)

local i = 1
foreach s in `breaks' {
	local dashes `dashes' xline(`s',lp(dash) lc(black))
	
	local ci_upi = real(word("`ci_ups'",`i'))
	local ci_lowi = real(word("`ci_lows'",`i')) 

	local ci_upi = `ci_upi' + `min' - 1
	local ci_lowi = `ci_lowi' +`min' - 1

	local ci_up `ci_up' xline(`ci_upi',lp(dot) lc(black))
	local ci_low `ci_low' xline(`ci_lowi',lp(dot) lc(black))

	local i = `i' + 1
}


twoway 	(tsline deaths if year > 2019 , 	///
		yaxis(1) )	///
		(tsline L1.cases if year > 2019, 			///
		yaxis(2)  ),	///
		ytitle("Deaths" "1000", axis(1))	///
		ytitle("Weekly Cases" "1000", axis(2))		///
		xtitle("")									///
		legend(label(1 "Deaths") label(2 "COVID Cases (1 week lag)")) name(ExcessDeaths, replace) ///
		 `dashes' `ci_low' `ci_up' ///
		xlabel(`=yw(2020,1)' "2020"  `=yw(2020,20)' `"" "w20"' `=yw(2021,1)' "2021" `=yw(2021,11)' `"" "w10"')

*** Panel case
use https://github.com/JanDitzen/xtbreak/raw/main/data/US_panel.dta

xtbreak deaths L.cases, vce(hac)

xtbreak deaths L.cases, trimming(0.1) vce(hac) csa(L.cases)

xtbreak test deaths L.cases, h(2) breaks(5) trimming(0.1) vce(hac) csa(L.cases)

xtbreak test deaths L.cases, h(1) breaks(1) trimming(0.1) vce(hac) csa(L.cases)

xtbreak test deaths L.cases, h(1) breaks(3) trimming(0.1) vce(hac) csa(L.cases)

xtbreak estimate deaths L.cases, breaks(3) trimming(0.1) vce(hac) csa(L.cases)

estat split L.cases
xtreg deaths `r(varlist)', fe

