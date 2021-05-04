clear all

use http://www.stata-press.com/data/r16/usmacro.dta, clear

xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1))

xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1) tq(1990q1))

cap xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1) tq(1970q1))

xtbreak test ogap inflation fedfunds, breakpoint(10 20, index)

xtbreak test ogap inflation fedfunds, hypothesis(1) breaks(3)

xtbreak test ogap inflation fedfunds, hypothesis(1) breaks(3) breakconstant

xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(3) 

xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(2 4) 

xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(2 4)  wdmax

xtbreak test ogap inflation fedfunds, hypothesis(3) breaks(2) minlength(0.05)

clear 
use "https://janditzen.github.io/xtbreak/data/UK.dta", replace

xtbreak test ExcessDeaths , breakconstant breaks(1 4) hypothesis(2)

xtbreak test ExcessDeaths , breakconstant hypothesis(1) breakpoints(13 20, index)

xtbreak test ExcessDeaths , breakconstant hypothesis(1) breakpoints(13 20, index) vce(hac)

xtbreak test ExcessDeaths , breakconstant breaks(2) hypothesis(1)
