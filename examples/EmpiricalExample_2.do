clear all

version 18

/* 
Requires: Python
*/

use "approval_panel", replace

xtbreak  d.approval d.CCI , trim(0.05) nobreakvar(ElectionQ)  strict maxbreaks(5) python

*** Figure 5)
mata st_local("breaks_main",invtokens(strofreal(st_matrix("e(breaks)"))[2,.]))

ereturn clear
gen break_date = .

local g = 1
levelsof country

foreach cty in `r(levels)' {
	noi disp "Country: `cty'"
	local setlevel 
	if "`cty'" == "Japan" local setlevel cvalue(90)
	xtbreak  d.approval d.CCI if country == "`cty'" , trim(0.05) nobreakvar(ElectionQ) `setlevel'  maxbreaks(5) python
	
	if `e(num_breaks)' > 0 {
		mata st_local("breaks",invtokens(strofreal(st_matrix("e(breaks)"))[2,.]))		
		foreach s in `breaks' {
			local breaki : disp %tm `s'
			replace break_date = `s' if date == `s' & country == "`cty'"
		}
	}
	ereturn clear
	local ++g
}

gen b_value = 100 if break_date != .

tw (line approval date , ylabel(10 50 90) ) (line CCI date, yaxis(2)  ylabel(92 100 108, axis(2))  lp(longdash) ) (scatter ElectionNumb date if ElectionNumb != 0, msymbol(O) mcolor(black)) (spike b_value break_date ) ,  by(country,imargin(vsmall) cols(2) legend( pos(6)) style(compact) note("") caption("")) scheme(sj) legend(label(1 Approval) label(4 CCI)  order(1 4)) xtitle("") ytitle("Approval Rating", axis(1)) ytitle("CCI", axis(2)) xlabel(`=tm(1990m1)' `=tm(2000m1)' `=tm(2010m1)' `=tm(2020m1)', labsize(vsmall)) xmtick(`=tm(1990m1)'(12)`=tm(2022m1)' ) xline(`breaks_main' , lp(dot)) name(combined, replace)

*** Table 2
* Col 1)
xtbreak  d.approval d.CCI , trim(0.05)  strict python

* Col 2)
xtbreak  d.approval d.CCI , trim(0.05) vce(hc) strict python

* Col 3)
xtbreak  d.approval d.CCI , trim(0.05) nobreakvar(ElectionQ) strict python

* Col 4)
xtbreak  d.approval d.CCI , trim(0.05) nobreakvar(ElectionQ) nofixedeffects strict python

* Col 5)
xtbreak  d.approval d.CCI , trim(0.05) nobreakvar(ElectionQ) nofixedeffects breakconstant cvalue(0.90) strict python

xtbreak est d.approval d.CCI , trim(0.05) nobreakvar(ElectionQ) breaks(1) python
estat ssr , scheme(sj) name(ssr, replace)
