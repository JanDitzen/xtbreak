{smcl}
{hline}
{hi:help xtbreak estimate}{right: v. 2.1 - 25. February 2025}

{hline}
{title:Title}

{p 4 4}{cmd:xtbreak test} - testing for many known and unknown structural breaks in time series and panel data.{p_end}

{title:Syntax}

{p 4}Testing for {bf:known} structural breaks:{p_end}

{p 4 13}{cmd:xtbreak} test {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmdab:breakp:oints(}{help numlist}| {help datelist}{cmd: [,index|fmt(}{help format}{cmd:)])} 
{cmd:{help xtbreak_tests##options1:options1}}
{cmd:{help xtbreak_tests##options5:options5}}{p_end}

{p 8}{cmdab:breakp:oints(}{it:numlist}{cmd:[,index])} specifies the time period of the known 
structural break.{p_end}

{p 4}Testing for {bf:unknown} structural breaks:{p_end}

{p 4 13}{cmd:xtbreak} test {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} 
{cmd:breaks(}{it:#}{cmd:)} 
{cmd:{help xtbreak_tests##options1:options1}}
{cmd:{help xtbreak_tests##options2:options2}}
{cmd:{help xtbreak_tests##options3:options3}}
{cmd:{help xtbreak_tests##options4:options4}}
{cmd:{help xtbreak_tests##options5:options5}}
{p_end}

{p 8}{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} specifies which hypothesis to test, see {help xtbreak_tests##hypothesis:hypothesises}. 
{cmd:breaks(#)} sets the number of breaks.
{p_end}

INCLUDE help xtbreak_options

{p 4 4}Data has to be {help tsset} or {help xtset} before using {cmd:xtbreak}. 
{depvars}, {indepvars} and {it:varlist}, {it:varlist}1 - {it:varlist}5 may contain time-series operators, see {help tsvarlist}.{break}
{cmd:xtdcce2} requires the {help moremata} package.


{title:Contents}

{p 4}{help xtbreak_tests##description:Description}{p_end}
{p 4}{help xtbreak_tests##options:Options}{p_end}
{p 4}{help xtbreak_tests##note_panel:Notes on Panel Data}{p_end}
{p 4}{help xtbreak##cov:Covariance Estimator}{p_end}
{p 4}{help xtbreak_tests##saved_vales:Saved Values}{p_end}
{p 4}{help xtbreak_tests##examples:Examples}{p_end}
{p 4}{help xtbreak_tests##references:References}{p_end}
{p 4}{help xtbreak_tests##about:About, Authors and Version History}{p_end}

{marker description}{title:Description}
{p 4 4}
{cmd:xtbreak test} implements multiple tests for structural breaks in time series and panel data models.
The number and period of occurrence of structural breaks can be known and unknown.
In the case of a known breakpoint {cmd:xtbreak test} can test if the break occurs at a specific point in time.
For unknown breaks, {cmd:xtbreak test} implements three different hypothesises, 1, 2 and 3. 
Hypothesis 1 is no break against the alternative of {it:s} breaks,
hypothesis 2 is no breaks against a lower and upper limit of breaks. 
The last hypothesis, 3,  tests the null of {it:s} breaks against the alternative of
one more break ({it:s+1}).{p_end}

{p 4 4}{cmd:xtbreak test} implements the tests for structural breaks discussed in 
Bai & Perron ({help xtbreak_tests##BP1998:1998}, {help xtbreak_tests##BP2003:2003}),
Karavias, Narayan, Westerlund ({help xtbreak_tests##KNW2021:2021})
and Ditzen, Karavias, Westerlund ({help xtbreak_tests##DKW2021:2024}). 

{p 4 4}For the remainder we assume the following model:{p_end}

{p 8 8}y(i,t) = sigma0(1) + sigma1(1) z(i,t) + beta0(i) + beta1 x(i,t) + e(it) for t = 1,...,T1{p_end}
{p 8 8}y(i,t) = sigma0(2) + sigma1(2) z(i,t) + beta0(i) + beta1 x(i,t) + e(it) for t = T1+1,...,T2{p_end}
{p 8 8}...{p_end}
{p 8 8}y(i,t) = sigma0(s) + sigma1(s) z(i,t) + beta0(i) + beta1 x(i,t) + e(it) for t = Ts,...,T{p_end}

{p 4 4}where {it:s} is the number of the segment/breaks, {it:z(i,t)} is a NT1xq matrix containing the variables 
whose relationship with y breaks. 
A break in the constant is possible if time series data is used.
{it:x(i,t)} is a NTxp matrix with variables without breaks.
{it:sigma0(s), sigma1(s)} are the coefficients with structural breaks
and T1,...,Ts are the periods of the breakpoints.
{it: beta1} is a px1 vector of coefficients with no breaks.
{it:beta0(i)} is a fixed effect (panel data models) or a constant (time series models). 
{p_end}

{p 4 4}
In pure time series model breaks in only the constant (or deterministics) are possible.
In this case {it:sigma0(s)} is a constant with a structural break.
{p_end}

{p 4 4}{cmd:xtbreak} will automatically determine whether a time series or panel dataset
is used.{p_end}

{marker h1k}
{p 4}{ul:{bf:Testing a known break point}}{p_end}

{p 4 4}Assume that the numbers of breaks and their occurrence is known.
{cmd:xtbreak test} can test the breakpoints. 
The F-Statistic for the test with s breaks at known dates is:
{p_end}

{p 8 8}F(s,q) = {it:dof_adj} sigma' R' (R V R')^(-1) R sigma{p_end}

{p 4 4}{it:dof_adj} is a degree of freedom adjustment, sigma a matrix containing the coefficient estimates 
of {it:sigma}, {it:R} is the conventional matrix of a Wald test and 
{it:V} is a variance-covariance matrix.
Under the null F(s,q) is F distributed.
The {it:dof_adj} differs for time series and panel datasets.
For the time series case see Bai & Perron ({help xtbreak_tests##BP1998:1998}, {help xtbreak_tests##BP2003:2003}),
for the panel data case see 
Karavias, Narayan, Westerlund ({help xtbreak_tests##KNW2021:2021})
and Ditzen, Karavias, Westerlund ({help xtbreak_tests##DKW2021:2024}) {p_end}

{p 4 4}A known break date can be tested with {cmd:xtbreak test} using the option 
{cmdab:breakp:oints(numlist|datelist,[index])}. 
{it:numlist|datelist} defines the periods of the breaks.
If {help numlist} is used, then the option index is required.{p_end}

{marker DefUnknown}{p 4}{ul:{bf:Testing for unknown break points}}{p_end}

{p 4 4}If the number and thus the time period of breaks is unknown, {cmd:xtbreak test}
offers three different hypothesises:

{marker h1def}
{p 4}{ul:1: No break against {it:s} breaks}

{p 4 4}Formally the hypothesis are:{p_end}

{p 10} H_0: no break vs. H_1: {it:s} breaks at unknown dates{p_end}

{p 4 4}Bai & Perron ({help xtbreak_tests##BP1998:1998}) suggest to take the supremum of the 
F-Statistics:{p_end}

{p 10}supF(s,q) = sup (l1,..,lq) F(l,q){p_end}

{p 4 4}where l1, lq are the different sets of possible breakpoints. 
Essentially the test is the test of a known break after estimation of the breakpoints given a number of breaks.
For a discussion of the estimation of the breakpoints see {help xtbreak_estimate:xtbreak estimate}.{p_end}

{p 4 4} The supremum F-Test is called in {cmd:xtbreak test} using the options {cmd:breaks(#) hypothesis(1)}.
{cmd:breaks(#)} sets the number of breaks.{break}
Critical values can be found in Bai & Perron ({help xtbreak_tests##BP1998:1998}, {help xtbreak_tests##BP2003:2003}) 
and are supplied by {cmd:xtbreak test}.
{p_end}

{marker h2}
{p 4}{ul:2: No break against {it:s0<= s <=s1} breaks}

{p 4 4}A test of the null hypothesis of no structural change against the alternative that 
an unknown number of structural breaks have occurred, where this unknown number of breaks
lies between {it:s0} and {it:s1} is:

{p 10} H_0: no break vs. H_1: {it:s0 <= s <= s1} breaks at unknown dates{p_end}

{p 4 4}The so-called double maximum test statistic is:{p_end}

{p 10}supF = sup(s0,..s,..,s1) supF(s,q){p_end}

{p 4 4}where  supF(s,q) is as defined {help xtbreak_tests##h1def:above}.{p_end}

{p 4 4}Generally speaking, the double maximum test estimates the breakdates for each number of breaks
between {it:s0} and {it:s1}, calculates the corresponding test statistic and then selects the largest one.
Two versions of the double maximum test are available, 
an unweighted and a weighted test. 
For the weighted test the test supF(l,q) test statistics are weighted by critical values.{p_end}

{p 4 4}The double maximum test can be used if the options {cmd:breaks(#) hypothesis(2)} are used. 
Critical values can be found in Bai & Perron ({help xtbreak_tests##BP1998:1998}, {help xtbreak_tests##BP2003:2003}) 
and are supplied by {cmd:xtbreak test}.{p_end}

{marker h3}{p 4}{ul:3: {it:s} breaks against {it:s+1} breaks}{p_end}
{p 4 4}A test of the null hypothesis that, {it:s} structural breaks have occurred, 
against the alternative that {it:s + 1} breaks have occurred is:{p_end}

{p 10} H_0: {it:s} breaks vs H_1 {it:s+1} breaks{p_end}

{p 10} F(s+1|s) = sup(s=1,..,s+1) sup(s0,..s,..,s1) supF(s,q){p_end}

{p 4 4}The test is essentially comparing the SSR of the model with {it:s} breaks to the minimum of the SSR of the model
with {it:s+1} breaks.{p_end}

{p 4 4}The F(s+1|s) test is integrated in {cmd:xtbreak test} with the options {cmd:breaks(#) hypothesis(3)}.
Critical values can be found in Bai & Perron ({help xtbreak_tests##BP1998:1998}, {help xtbreak_tests##BP2003:2003}) 
and are supplied by {cmd:xtbreak test}.{p_end}

{marker options}{title:Options}

{p 4 8 12}{cmdab:breakp:oints(}{help numlist}| {help datelist}{cmd: [,index|fmt(}{help format}{cmd:)]} specifies the known 
breakpoints. 
Kown breakpoints can be set by either the number of observation or by the value of the 
time identifier.
If a {help numlist} is used, option index is required. 
For example {cmd:breakpoints(10,index)} specifies that the one break occurs at the 10th observation in time.
{help datelist} takes a list of dates.
For example {cmd:breakpoints(2010Q1) , format(tq)} specifies a break in Quarter 1 in 2010.
The option {cmd:format()} specifies the format and is required if a datelist is used.
The format set in {cmd:breakpoints()} and the time identifier needs to be the same.{p_end}

{p 4 8 12}{cmd:wdmax} Use weighted test statistic instead of 
unweighted for the double maximum test (hypothesis 2).{p_end}

{p 4 8 12}{cmd:level(#)} set level for critical values for weighted double maximum test.
If a value is chosen for which no critical values exits, {cmd:xtbreak test} will choose the closest level.{p_end}

{p 4 8 12}{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} specifies which hypothesis to test, see {help xtbreak_tests##DefUnknown:xtbreak test - unknown break dates}.{break} 
{cmd:h(A)} test for no breaks vs. {it:s} breaks, {break}
{cmd:h(B)} for no break vs. {it:s0 <= s <= s1} breaks and {break}
{cmd:h(C)} for {it:s} vs. {it:s+1} breaks.
Default is hypothesis 3.{p_end}

INCLUDE help xtbreak_options_detail

{p 4 8 12}{cmdab:seq:uential} sequential F-Test to determine number of breaks.  
The number of breaks is varied from s = 0 to breaks()-1 or floor(1/trimming).{p_end}

INCLUDE help xtbreak_PanelVarCov

{marker saved_vales}{title:Saved Values}

{p 4}{cmd:xtbreak test} stores the following in {cmd:r()}:{p_end}

{p 4}{ul:Known Breakpoints}{p_end}

{col 4} Scalars
{col 8}{cmd: r(Wtau)}{col 27} Value of test statistic. 
{col 8}{cmd: r(p)}{col 27} p-Value from F distribution. 

{p 4}{ul:Unknown Breakpoints}{p_end}

{col 4} Scalars
{col 8}{cmd: r(supWtau)}{col 27} Value of supF statistic (hypothesis 1). 
{col 8}{cmd: r(Dmax)}{col 27} Value of unweighted double maximum test (hypothesis 2). 
{col 8}{cmd: r(WDmax)}{col 27} Value of weighted double maximum test (hypothesis 2).
{col 8}{cmd: r(f)}{col 27} Value of supremum of supF statistic (hypothesis 3). 
{col 8}{cmd: r(c90)}{col 27} Critical value at 90%. 
{col 8}{cmd: r(c95)}{col 27} Critical value at 95%.
{col 8}{cmd: r(c99)}{col 27} Critical value at 99%.

{col 4} Matrices 
{col 8}{cmd: r(breaks)}{col 27}Index and time identifier value of break dates.


{marker examples}{title:Examples}

{p 4 4}{ul:Examples using usmacro.dta}

{p 4 4}For example we want to find breaks in the 
US macro dataset supplied in Stata 16.
The dataset contains quarterly data on the inflation, GDP gap and the federal funds rate.
We load the data in as:{p_end}

{col 8}{stata "use http://www.stata-press.com/data/r16/usmacro.dta, clear"}

{p 4 4}A simple model to estimate the GDP gap using the federal funds rate and inflation woudl be:{p_end}

{col 8}{stata regress ogap inflation fedfunds}

{p 4 4}{ul:Test for known breaks}{p_end}

{p 4 4}Assume we want to test for a break in Quarter 1 1970:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1))}

{p 4 4}and if we want to test for a break in 1970q1 and 1990q4:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1) tq(1990q4))}

{p 4 4}If we want to test if breaks occurs after 10 and 20 periods:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, breakpoint(10 20, index)}

{p 4 4}{ul:Test for unknown breaks}{p_end}

{p 4 4}{bf:No vs. {it:s} breaks}

{p 4 4}To test hypothesis 1 with for example 3 breaks:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, hypothesis(1) breaks(3)}

{p 4 4}The default is to assume no break in the constant. 
To add a break in the constant, the option {cmd:breakconstant} is added:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, hypothesis(1) breaks(3) breakconstant}

{p 4 4}{bf:No vs. {it:s0 <= s <= s1} breaks}

{p 4 4}Hypothesis 2 can be tested with:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(3)}

{p 4 4}The test assumes that under the alternative, there are between 1 and 3 breaks. 
To test if there are between 2 and 4 breaks under the alternative:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(2 4)}

{p 4 4}To use the weighted double maximum test we use the option {cmd:wdmax}{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(2 4) wdmax}

{p 4 4}{bf:Testing {it:s} vs. {it:s+1} breaks}

{p 4 4}Hypothesis can be tested using option {cmd:hypothesis(3)}:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, hypothesis(3) breaks(2)}

{p 4 4}To change the minimal segment length to 5%:{p_end}

{col 8}{stata xtbreak test ogap inflation fedfunds, hypothesis(3) breaks(2) trimming(0.05)}

{p 4 4}{ul:Examples: Excess deaths in the UK due to COVID 19}

{p 4 4}An early version of {cmd:xtbreak test} was presented at the 2020 Swiss User Group meeting (see slides {browse "https://www.stata.com/meeting/switzerland20/slides/Switzerland20_Ditzen.pdf":here},
{bf:NOTE:} The examples are on an early version of {cmd:xtbreak}. Results have changed!)
The empirical example was on the question if can we identify structural breaks in the excess deaths in the
UK in 2020 due to COVID19?
Data from Office of National Statistics (ONS) for weekly deaths in the UK for 2020 was used.
The data can be downloaded {browse "https://github.com/JanDitzen/xtbreak/tree/main/data":here}.{p_end}

{p 4 4}To test for an unknown breakdate with up to for breaks:{p_end}

{col 8}{stata xtbreak test ExcessDeaths , breakconstant breaks(1 4) hypothesis(2)}

{p 4 4}We can test if there is a break in weeks 13 and 20 against the
hypothesis of no break.{p_end}

{col 8}{stata xtbreak test ExcessDeaths , breakconstant hypothesis(1) breakpoints(13 20, index)}

{p 4 4}Using a HAC consistent estimator rather than the SSR.{p_end} 

{col 8}{stata xtbreak test ExcessDeaths , breakconstant hypothesis(1) breakpoints(13 20, index) vce(hac)}

{p 4 4}Test for 2 breaks at unknown dates:{p_end}

{col 8}{stata xtbreak test ExcessDeaths , breakconstant breaks(2) hypothesis(1)}

{p 4 4}Test for 1 vs. 2 breaks:{p_end}

{col 8}{stata xtbreak test ExcessDeaths , breakconstant breaks(1) hypothesis(3)}

INCLUDE help xtbreak_about
