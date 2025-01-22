*** Time Series Examples
use  https://github.com/JanDitzen/xtbreak/raw/main/data/US.dta

xtbreak d.deaths d.L(1/3).cases

xtbreak estimate d.deaths d.L(1/3).cases, breaks(2)

xtbreak test d.deaths d.L(1/3).cases , hypothesis(1) breaks(2)

xtbreak test d.deaths d.L(1/3).cases , hypothesis(1) breakpoints(2020W22 2020w52, fmt(tw))

xtbreak test d.deaths d.L(1/3).cases , hypothesis(3) breaks(3)

xtbreak test d.deaths d.L(1/3).cases , hypothesis(1) breaks(2) breakconstant

xtbreak test d.deaths  , hypothesis(1) breaks(2) breakconstant nobreakvar(d.L(1/3).cases)

xtbreak estimate d.deaths d.L(1/3).cases, breaks(2)

estat split
reg deaths `r(varlist)'

xtbreak estimate d.deaths d.L(1/3).cases, breaks(2)
estat scatter L.cases

*** Graph with CI
xtbreak estimate d.deaths d.L(1/3).cases, breaks(2)
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
		legend(label(1 "Deaths") label(8 "COVID Cases (1 week lag)") order(1 8) pos(6) cols(2)) name(ExcessDeaths, replace) ///
		 `dashes' `ci_low' `ci_up' ///
		xlabel(`=yw(2020,1)' "2020"  `=yw(2020,22)' `"" "w22"' `=yw(2021,1)' "2021" `=yw(2020,52)' `"" "w52"')

*** Panel case
use https://github.com/JanDitzen/xtbreak/raw/main/data/US_panel.dta

xtbreak deaths L.cases, trimming(0.1) vce(wpn) csa(L.cases)

xtbreak test deaths L.cases, h(2) breaks(5) trimming(0.1) vce(hac) csa(L.cases)

xtbreak test deaths L.cases, h(1) breaks(1) trimming(0.1) vce(hac) csa(L.cases)

xtbreak test deaths L.cases, h(1) breaks(3) trimming(0.1) vce(hac) csa(L.cases)

xtbreak estimate deaths L.cases, breaks(3) trimming(0.1) vce(hac) csa(L.cases)

estat split L.cases
xtreg deaths `r(varlist)', fe

