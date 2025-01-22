clear all

version 18

/* Requires: xtdcce2 
ssc install xtdcce2
*/

use "US", replace

twoway 	(tsline deaths  , 	///
		yaxis(1) )	///
		(tsline cases , 			///
		yaxis(2)  ),	///
		ytitle("Deaths" "1000", axis(1))		///
		ytitle("Weekly Cases" "1000", axis(2))		///
		legend(label(1 "Deaths") label(2 "COVID Cases") pos(6) cols(2)) name(ExcessDeaths) scheme(sj)


*** General Model
xtbreak d.deaths d.L(1/3).cases

estat split
reg d.deaths `r(varlist)'
nlcom 	(Regime1: _b[LD_cases1] +  _b[L2D_cases1] + _b[L3D_cases1]) ///
(Regime2: _b[LD_cases2] +  _b[L2D_cases2] + _b[L3D_cases2]) ///
(Regime3: _b[LD_cases3] +  _b[L2D_cases3] + _b[L3D_cases3])

xtbreak test d.deaths d.L(1/3).cases , hypothesis(1) breakpoints(2020W22 2020w52, fmt(tw))

xtbreak test d.deaths d.L(1/3).cases , hypothesis(1) breaks(2)

xtbreak test d.deaths d.L(1/3).cases , hypothesis(2) breaks(5) 

xtbreak test d.deaths d.L(1/3).cases , hypothesis(3) breaks(4)

xtbreak test d.deaths d.L(1/3).cases , hypothesis(3) breaks(5) sequential vce(hac)

xtbreak test d.deaths d.L(1/3).cases , breakconstant

xtbreak test d.deaths  , breakconstant nobreakvar(L(1/3).cases)

xtbreak estimate d.deaths d.L(1/3).cases , breaks(2) 

estat scatter d.L.cases , ytitle("Change in Deaths in 1000s") xtitle("Change in Cases in 1000s") ///
	autolegend(pos(6) cols(3)) scheme(sj) name(xtbreak_estat, replace)

*** Graph with CI
local dashes
xtbreak d.deaths d.L(1/3).cases
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
	local arrowopt lc(black) mlc(black)
	local s1 26
	local s11 25
	local s2 24
	local s21 25

twoway 	(tsline deaths if year > 2019 , 	///
		yaxis(1) )	///
		(tsline L1.cases if year > 2019, 			///
		yaxis(2)  )	///
		(pcarrowi  `s1' `=tw(2020,1)'  `s1' `=tw(2020,22)'	, `arrowopt' text(`s11' `=(`=tw(2020,22)'+`=tw(2020,1)')/2' "R1"	, size(small))) 	(pcarrowi `s1' `=tw(2020,22)' 	`s1' `=tw(2020,1)'	, `arrowopt' ) ///
		(pcarrowi  `s1' `=tw(2020,22)' `s1' `=tw(2020,52)' 	, `arrowopt' text(`s11' `=(`=tw(2020,22)'+`=tw(2020,52)')/2' "R2"	, size(small))) 	(pcarrowi `s1' `=tw(2020,52)' 	`s1' `=tw(2020,22)' 	, `arrowopt' ) ///
		(pcarrowi  `s1' `=tw(2020,52)'  `s1' `=tw(2021,34)' 	, `arrowopt' text(`s11' `=(`=tw(2020,52)'+`=tw(2021,34)')/2' "R3"	, size(small))) 	(pcarrowi `s1' `=tw(2021,34)'	`s1' `=tw(2020,52)' 	, `arrowopt' ) ///
		, ///
		ytitle("Deaths" "1000", axis(1))	///
		ytitle("Weekly Cases" "1000", axis(2))		///
		xtitle("")									///
		legend(label(1 "Deaths") label(8 "COVID Cases (1 week lag)") pos(6) cols(2) order(1 8)) name(ExcessDeaths, replace) ///
		 `dashes' `ci_low' `ci_up' ///
		xlabel(`=yw(2020,1)' "2020"  `=yw(2020,22)' `"" "w22"'  `=yw(2020,52)' `"" "w52"'  `=yw(2021,1)' "2021" )  scheme(sj)


xtbreak est d.deaths d.L(1/3).cases , breaks(1)
estat ssr , xlabel(`=yw(2020,1)' "2020"  `=yw(2020,23)' `"" "w23"' `=yw(2021,1)' "2021" `=yw(2021,34)' `"" "w34"' )  scheme(sj) name(ssr, replace)

use "US_panel", replace

xtbreak d.deaths d.L(1/3).cases, vce(hc)

xtbreak d.deaths d.L(1/3).cases, vce(hc) trim(0.1) 

xtbreak d.deaths d.L(1/3).cases,  csa(d.l.cases) vce(wpn) trim(0.1) skiph2

*** Testing
xtbreak test d.deaths d.L(1/3).cases, h(2) breaks(5)  csa(d.L(1/3).cases)

xtbreak test d.deaths d.L(1/3).cases, h(1) breaks(1)  csa(d.L(1/3).cases)

xtbreak test d.deaths d.L(1/3).cases, h(1) breaks(5)  csa(d.L(1/3).cases)

*******************************************************************
*** 4 Breaks CSA
*******************************************************************
xtbreak estimate d.deaths d.L(1/3).cases, csa(d.l.cases) breaks(4) trim(0.1) vce(wpn)
est store estBreaks
*** Graph with CI and resutls for 4 breaks

mata st_local("breaks",invtokens(strofreal(st_matrix("e(breaks)"))[2,.]))
mata st_local("ci_ups",invtokens(strofreal(st_matrix("e(CI)"))[2,.]))
mata st_local("ci_lows",invtokens(strofreal(st_matrix("e(CI)"))[1,.]))

sum date if e(sample)
local min = r(min)
local dashes5 ""
local ci_up5
local ci_low5
local i = 1
foreach s in `breaks' {
	local dashes5 `dashes5' xline(`s',lp(dash ) lc(black))
	
	local ci_upi = real(word("`ci_ups'",`i'))
	local ci_lowi = real(word("`ci_lows'",`i')) 

	local ci_upi = `ci_upi' + `min' - 1
	local ci_lowi = `ci_lowi' +`min' - 1

	local ci_up5 `ci_up5' xline(`ci_upi',lp(dot) lc(black))
	local ci_low5 `ci_low5' xline(`ci_lowi',lp(dot) lc(black))

	local i = `i' + 1
}

preserve
	collapse (sum) deaths cases, by(date year)
	sort date
	tsset date
	local arrowopt lc(black) mlc(black)
	local s1 26
	local s11 25
	local s2 24
	local s21 25
	twoway 	(tsline deaths if year > 2019 , 	///
			yaxis(1) )	///
			(tsline L1.cases if year > 2019, 			///
			yaxis(2)  )	///
			(pcarrowi  `s1' `=tw(2020,1)'  `s1' `=tw(2020,14)'	, `arrowopt' text(`s11' `=(`=tw(2020,14)'+`=tw(2020,1)')/2' "R1"	, size(small))) 	(pcarrowi `s1' `=tw(2020,14)' 	`s1' `=tw(2020,1)'	, `arrowopt' ) ///
			(pcarrowi  `s1' `=tw(2020,14)' `s1' `=tw(2020,21)' 	, `arrowopt' text(`s11' `=(`=tw(2020,21)'+`=tw(2020,14)')/2' "R2"	, size(small))) 	(pcarrowi `s1' `=tw(2020,21)' 	`s1' `=tw(2020,14)' 	, `arrowopt' ) ///
			(pcarrowi  `s1' `=tw(2020,21)' `s1' `=tw(2020,52)' 	, `arrowopt' text(`s11' `=(`=tw(2020,21)'+`=tw(2020,52)')/2' "R3"	, size(small))) 	(pcarrowi `s1' `=tw(2020,52)' 	`s1' `=tw(2020,21)' 	, `arrowopt' ) ///
			(pcarrowi  `s1' `=tw(2020,52)' `s1' `=tw(2021,8)' 	, `arrowopt' text(`s11' `=(`=tw(2020,52)'+`=tw(2021,8)')/2' "R4"	, size(small))) 	(pcarrowi `s1' `=tw(2021,8)'  	`s1' `=tw(2020,52)' 	, `arrowopt' ) ///
			(pcarrowi  `s1' `=tw(2021,8)'  `s1' `=tw(2021,34)' 	, `arrowopt' text(`s11' `=(`=tw(2021,8)'+`=tw(2021,34)')/2' "R5"	, size(small))) 	(pcarrowi `s1' `=tw(2021,34)'	`s1' `=tw(2021,8)' 	, `arrowopt' ) ///
			, ///
			ytitle("Deaths" "1000", axis(1))	///
			ytitle("Weekly Cases" "1000", axis(2))		///
			xtitle("")									///
			legend(label(1 "Deaths") label(12 "COVID Cases (1 week lag)") pos(6) cols(2) order(1 12)) name(ExcessDeaths, replace) ///
			 `dashes5' `ci_low5' `ci_up5' ///
			xlabel(`=yw(2020,1)' "2020"  `=yw(2020,14)' `"" "w14"' `=yw(2020,21)' `"" "w21"'  `=yw(2021,1)' "2021" `=yw(2020,52)' `"" "w52"' `=yw(2021,8)' `"" "8"')  scheme(sj)
restore 


est restore estBreaks
estat split 

qui xtdcce2 d.deaths `r(varlist)', pooled(`r(varlist)') cr(d.L.cases) pooledvce(wpn)
nlcom 	(Regime1: _b[LD_cases1] +  _b[L2D_cases1] + _b[L3D_cases1]) ///
(Regime2: _b[LD_cases2] +  _b[L2D_cases2] + _b[L3D_cases2]) ///
(Regime3: _b[LD_cases3] +  _b[L2D_cases3] + _b[L3D_cases3]) ///
(Regime4: _b[LD_cases4] +  _b[L2D_cases4] + _b[L3D_cases4]) ///
(Regime5: _b[LD_cases5] +  _b[L2D_cases5] + _b[L3D_cases5]) ,  post
