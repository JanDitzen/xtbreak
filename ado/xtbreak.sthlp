{smcl}
{hline}
{hi:help xtbreak}{right: xtbreak v. 2.0 - 20.01.2025}

{hline}
{title:Title}

{p 4 4}{cmd:xtbreak} - estimating and testing for many known and unknown structural breaks in time series and panel data.{p_end}

{title:Syntax}

{p 4}For a more detailed description for {bf:testing} see {help xtbreak_tests:xtbreak test} and on {bf:estimation} see {help xtbreak_estimate:xtbreak estimate}.

{p 4}{ul:Automatic estimation of number and location of break:}{p_end}

{p 4 13}{cmd:xtbreak} {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmd:{help xtbreak##options1:options1}}
{cmd:{help xtbreak##options1:options2}}
{cmd:{help xtbreak##options5:options5}}
{cmd:{help xtbreak##options6:options6}}
{p_end}

{p 4}{ul:Testing for {bf:known} structural breaks:}{p_end}

{p 4 13}{cmd:xtbreak} test {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmdab:breakp:oints(}{help numlist}| {help datelist}{cmd: [,index|fmt(}{help format}{cmd:)])} 
{cmd:{help xtbreak##options1:options1}}
{cmd:{help xtbreak##options4:options5}}{p_end}

{p 8}{cmdab:breakp:oints(}{it:numlist}{cmd:[,index|fmt()])} specifies the time period of the known 
structural break.{p_end}

{p 4}{ul:Testing for {bf:unknown} structural breaks:}{p_end}

{p 4 13}{cmd:xtbreak} {cmd:test} {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmdab:h:ypothesis(}{bf:A|B|C}{cmd:)} 
{cmd:breaks(}{it:#}{cmd:)} 
{cmd:{help xtbreak##options1:options1}}
{cmd:{help xtbreak##options2:options2}}
{cmd:{help xtbreak##options3:options3}}
{cmd:{help xtbreak##options4:options4}}
{cmd:{help xtbreak##options5:options5}}
{p_end}

{p 8}{cmdab:h:ypothesis(}{bf:A|B|C}{cmd:)} specifies which hypothesis to test, see {help xtbreak_tests##hypothesis:hypothesises}. 
{cmd:breaks(#)} sets the number of breaks.
{p_end}

{p 4}{ul:Estimation of breakpoints:}{p_end}

{p 4 13}{cmd:xtbreak} {cmdab:est:imate} {depvar} [{indepvars}] {ifin} {cmd:,} 
{cmd:breaks(}{it:#}{cmd:)}
{cmd:showindex}
{cmd:{help xtbreak##options1:options1}}
{cmd:{help xtbreak##options2:options2}}
{cmd:{help xtbreak##options5:options5}}
{p_end}

{p 8}{cmd:breaks(#)} sets the number of breaks.{p_end}

{p 4}{ul: Maintenance}{p_end}

{p 4 13}{cmd:xtbreak , [update version]}{p_end}

{p 8}{cmd:version} displays version. 
{cmd:update} updates {cmd:xtbreak} from {browse "https://janditzen.github.io/xtbreak/":GitHub}
using {help net install}.{p_end}

INCLUDE help xtbreak_options

{marker options}
{p 4}{bf:Options for automatic estimation of number and location of break}{p_end}
{synoptset 30}{...}
{synopt:{it:options6}}Description{p_end}
{synoptline}
{synopt:{opt skiph2}}skips hypohesis B{p_end}
{synopt:{opt clevel(#)}}specifies level for critical values to detect breaks. {p_end}
{synopt:{opt strict}}strict behaviour of sequential test. Improves speed.{p_end}
{synopt:{opt maxbreaks(#)}}sets maximum number of breaks for sequential test. Improves speed.{p_end}
{synoptline}
{p2colreset}{...}

{p 4 4}Data has to be {help tsset} or {help xtset} before using {cmd:xtbreak}. 
{depvars}, {indepvars} and {it:varlist}, {it:varlist}1 - {it:varlist}5 may contain time-series operators, see {help tsvarlist}.{break}
{cmd:xtdcce2} requires the {help moremata} package.


{title:Contents}

{p 4}{help xtbreak##description:Description}{p_end}
{p 4}{help xtbreak##options:Options}{p_end}
{p 4}{help xtbreak##note_panel:Panel Data}{p_end}
{p 4}{help xtbreak##cov:Covariance Estimator}{p_end}
{p 4}{help xtbreak##python:Python}{p_end}
{p 4}{help xtbreak##unbalanced:Unbalanced Panel Data}{p_end}
{p 4}{help xtbreak##example:Examples}{p_end}
{p 4}{help xtbreak##references:Refrences}{p_end}
{p 4}{help xtbreak##about:Authors and About}{p_end}

{marker description}{title:Description}
{p 4 4}
{cmd:xtbreak test} implements multiple tests for structural breaks in time series and panel data models.
The number and period of occurrence of structural breaks can be known and unknown.
In the case of a known breakpoint {cmd:xtbreak test} can test if the break occurs at a specific point in time.
For unknown breaks, {cmd:xtbreak test} implements three different hypothesises. 
The first is no break against the alternative of {it:s} breaks,
the second hypothesis is no breaks against a lower and upper limit of breaks. 
The last hypothesis tests the null of {it:s} breaks against the alternative of
one more break ({it:s+1}). 
For a further explanation see {help xtbreak_tests:xtbreak test}.{p_end}

{p 4 4}
{cmd:xtbreak estimate} estimates the location of the break points.
The underlying idea is that if the model with the true breakdates given a number of breaks
has a smaller sum of squared residuals (SSR) than a model with 
incorrect breakdates. 
To find the breakdates, {cmd:xtbreak estimate} uses the algorithm (dynamic program) from {help xtbreak_estimate##BP2003:Bai and Perron (2003)}.
All {it:necessary} SSRs are calculated and then the smallest one selected.
For a further explanation see {help xtbreak_estimate:xtbreak estimate}.{p_end}

{p 4 4}{cmd:xtbreak} implements the tests for and estimation of structural breaks discussed in 
Bai & Perron ({help xtbreak_tests##BP1998:1998}, {help xtbreak_tests##BP2003:2003}),
Karavias, Narayan, Westerlund ({help xtbreak_tests##KNW2021:2022})
and Ditzen, Karavias, Westerlund ({help xtbreak_tests##DKW2021:2024}). 

{p 4 4}If neither {cmd:test} or {cmd:estimate} is defined,
{cmd:xtbreak} will do a sequential F-Test based on hypothesis 3 to determine the 
number of breaks. 
It will then select the number of breaks as the maximum number the hypothesis is rejected 
using the the critical value as set by {help c(level)}. 
Then it will estimate the breakdates using {help xtbreak_estimate:xtbreak estimate}.{p_end}

{marker options}
{title:Options}

{p 4 8 12}{cmdab:breakp:oints(}{help numlist}{cmd: ,index |}
{help datelist}{cmd:, fmt(}{help fmt}{cmd:))}
specifies the known 
breakpoints. 
Kown breakpoints can be set by either the number of observation or by the value of the 
time identifier.
If a {help numlist} is used, option index is required. 
For example {cmd:breakpoints(10,index)} specifies that the one break occurs at the 10th observation in time.
{help datelist} takes a list of dates.
For example {cmd:breakpoints(2010Q1,fmt(tq))} specifies a break in Quarter 1 in 2010. 
If a datelist is used, 
the format set in {cmd:breakpoints()} and the time identifier needs to be the same.{p_end}

{p 4 8 12}{cmd:wdmax} Use weighted test statistic instead of 
unweighted for the double maximum test (hypothesis 2).{p_end}

{p 4 8 12}{cmd:level(#)} set level for critical values for weighted double maximum test.
If a value is chosen for which no critical values exists, {cmd:xtbreak test} will choose the closest level.{p_end}

{p 4 8 12}{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} specifies which hypothesis to test, see {help xtbreak_tests##DefUnknown:xtbreak test - unknown break dates}.{break} 
{cmd:h(1)} test for no breaks vs. {it:s} breaks, {break}
{cmd:h(2)} for no break vs. {it:s0 <= s <= s1} breaks and {break}
{cmd:h(3)} for {it:s} vs. {it:s+1} breaks.{p_end}

INCLUDE help xtbreak_options_detail

{p 4 8 12}{cmd:showindex} shows index for confidence intervals rather than formatted time value.{p_end}

{p 4 8 12}{cmd:skiph2} Skips Hypothesis 2 (H0: no break vs H1: \(0 < s < s_{max}\) breaks) when running {cmd:xtbreak} without the {cmd:estimate} or {cmd:test} option.{p_end}

{p 4 8 12}{cmd:cvalue(level)} specifies the level of the critical value to be used to estimate the number of breaks using the sequential test. 
For example {cmd:cvalue(0.99)} uses the 1\% critical values to determine the number of breaks using the sequential test. 
See {cmd:level(#)} for further details.{p_end}

{p 4 8 12}{cmd:strict} enforces strict behaviour of the sequential test to determine number of breaks.
Sequential test will stop once F(s+1|s) is not rejected given a rejection of F(s|s-1).
Option improves speed in large time series, but should be used with caution.{p_end} 

{p 4 8 12}{cmdab:max:breaks(#)} limits number of breaks when using the sequential test to determine number of breaks.
Option improves speed in large time series, but should be used with caution.{p_end} 

{p 4 8 12}{cmd:update} Update {cmd:xtbreak} from Github. 
This is essentially the following call:{p_end}
{col 8}{stata `"net install xtbreak , from("https://janditzen.github.io/xtbreak/") force replace"'}

{p 4 8 12}{cmd:version} Displays version.{p_end}

INCLUDE help xtbreak_PanelVarCov

{marker python}
{title:Python}

{p 4 4}The option {cmd:python} uses Python to calculate the sum of squared residuals (SSRs) necessary to compute the F-Statistics to 
estimate the dates of breaks and perform tests for an unknown break date.
The number of possible SSRs can be very large and computation time consuming.
For example, for a model without non-breaking variables, one break (m=1) and a minimal segment length of
h=trimming * T, the number of SSRs is: T (T + 1)/2 − (h − 1)T + (h − 2)(h − 1)/2 − h2m(m + 1)/2,
hence in the order of O(T^2).
Using Python improves the speed of calculations.{p_end}

{p 4 4}Python cannot be combined with unbalanced panels.
It uses the standard inverter from numpy (linalg.inv), the pseudo-inverse (linalg.pinv) or SVD decomposition (scipy.linalg.svd).
Differences between results obtained with and without the 
Python option may occur for ill-conditioned or (nearly) invertible 
matrices.
{p_end}

{p 4 4}{cmd:xtbreak} checks if the Python and required packages (numpy, scipy, xarray and pandas) are installed. The option {cmd:python} can only be used with Stata 16 or later.{p_end}

{marker unbalanced}
{title:Unbalanced Panel Data}

{p 4 4}{cmd: xtbreak} allows for unbalanced panels when using panel data. 
7Pure time series data (i.e. data with only one cross-section) with gaps is not allowed. 
In the case of unbalanced panels, the degree of freedom adjustment for the sup F(s) statistic are adjusted.{p_end}

{p 4 4}While {cmd: xtbreak}allows for unbalanced data, results should be taken with extra caution. 
The underlying assumption is that the break dates are the same for all units, including those with gaps in the data. 
The break date estimation can be biased if data is very unbalanced, that is if a large number of time periods are missing for multiple units. 
Care is also required if estimated breaks coincide with the start or end of unbalanced panels. 
We strongly recommend to investigate the SSRs using {cmd: estat ssr} after an estimation with a single break point to identify increases or decreases in the estimated SSRs.{p_end}

{p 4 4}The option {cmd:noreweigh} avoids to reweigh time-individual errors for the calculation of the SSR to artificially increase the SSR of unabalanced sections of the panel. Results with this options should be used indicative.{p_end}

{marker example}
{title:Examples}

{p 4}{ul:Time Series}{p_end}

{p 4 4}This example was presented in similar form at the Stata Conference {browse "https://www.stata.com/meeting/us21/":2021}. 
We will try to estimate the breakpoints in the relationship
between COVID infections in the US and deaths from the virus in 2020 and 2021. 
Weekly data is available on {browse "https://github.com/JanDitzen/xtbreak/tree/main/data":GitHub}.
The variable {it:deaths} are deaths from COVID and the variable {it:cases} contains
the number of new covid cases. 
The idea is that initially more people died from COVID because it was a new virus. 
Then medical treatment advanced and vaccines became more available which should
decrease deaths.
On the other hand COVID cases have likely been under-reported during the first wave.
We assume that there is a lag between the a positive test and death of one week. 
The data is from the {browse "https://data.cdc.gov/Case-Surveillance/United-States-COVID-19-Cases-and-Deaths-by-State-o/9mfq-cb36":CDC}.{p_end}

{p 4 4}First we load the data into Stata:{p_end}

{col 8}{stata "use https://github.com/JanDitzen/xtbreak/raw/main/data/US.dta"}

{p 4 4}We start with no prior knowledge of i) the number of breaks and ii) the exact date of each break. 
Therefore before estimating the breakpoints we use the sequential F-Test based on hypothesis 2 ({help xtbreak_test##h2:details}):{p_end}

{col 8}{stata xtbreak deaths L1.cases}

{p 4 4}We find three breaks, the first in week 20 in 2020, the second at the end of 2020 
and the last in week 11 in 2021.
However, we note that the second break has very wide confidence intervals.
This can be caused by the break being very small.
We thus proceed with only 2 breaks.{break}
We estimate the model with just two breaks:{p_end}

{col 8}{stata xtbreak estimate deaths L1.cases, breaks(2)}

{p 4 4}We find the same breakpoints and the confidence intervals are small.{break}
Next we test the hypothesis of no breaks against 2 breaks using hypothesis 1 
(see {help xtbreak_test##DefUnknown:details}):{p_end}

{col 8}{stata xtbreak test deaths L1.cases, hypothesis(1) breaks(2)}

{p 4 4}The test statistic is close to the one for the test of an additional break,
 however the critical values are smaller placing a lower 
bound on the rejection of the hypothesis.{p_end}

{p 4 4}Since we have an estimate of the breakpoints, we can test the two breakpoints 
as known breakpoints (see {help xtbreak_test##h1k:details}):{p_end}

{col 8}{stata xtbreak test deaths L1.cases, breakpoints(2020w20 2021w11 , fmt(tw))}

{p 4 4}Since we are using a {help datelist}, we need to specify the format of it.
{help datelist} also has to be the same format as the time identifier.{p_end}

{p 4 4}We have established that we have found 2 breaks. We can test the hypothesis 3, i.e. 2 breaks against the alternative of 3 breaks
(see {help xtbreak_test##h3:details}):{p_end}

{col 8}{stata xtbreak test deaths L1.cases, hypothesis(3) breaks(3)}

{p 4 4}First, note that we have to define in {cmd:breaks()} the alternative, that is we use {cmd:breaks(3)}. 
Secondly we are able to reject the hypothesis of 2 breaks. 
However as discussed before, the thrid break is estimated unprecisly. 
Panel data can contribute additional information for a better estimate
as discussed in the next section.{p_end}

{p 4 4}So far we have assumed no break in the constant, only in the number of COVID cases. 
We can test for only a break in the constant and keep the coefficient of the cases fixed. 
To do so, the options {cmd:nobreakvar(L.cases)} and {cmd:breakconstant} are required.{p_end}

{col 8}{stata xtbreak test deaths , breakconstant nobreakvar(L1.cases) breaks(3)}

{p 4 4}After testing for breaks thoroughly we can estimate the breaks and construct confidence intervals (see {help xtbreak_estimate:details}):{p_end}

{col 8}{stata xtbreak estimate deaths L1.cases, breaks(2)}

{p 4 4}If we want to see the index of the confidence interval rather than the date, the option {cmd:showindex} can be used:{p_end}

{col 8}{stata xtbreak estimate deaths L1.cases, breaks(2) showindex}

{p 4 4}We can split the variable L1.cases into the different values for each regime using {cmd:estat split}. 
The variable list is saved in {cmd:r(varlist)} and we run a simple OLS regression on it:{p_end}

{col 8}{stata estat split}
{col 8}{stata reg deaths `r(varlist)'}

{p 4 4}Finally, we can draw a scatter plot of the variables with a different colour for each segement. 
The command line is {cmd:estat scatter {varlist}} where {varlist} is the independent variable (X), 
the dependent variable is automatically added on the y-axis.{p_end}

{col 8}{stata xtbreak estimate deaths L1.cases, breaks(2) showindex}
{col 8}{stata estat scatter L.cases}

{p 4 4}An example how to draw a time series line plot with confidence intervals can be found on {browse "https://janditzen.github.io/xtbreak/":GitHub}.{p_end}

{p 4}{ul:Panel Data}{p_end}

{p 4 4}We are using a dataset with the same variables as above, but on US State level. 
First we load the dataset:{p_end}

{col 8}{stata "use https://github.com/JanDitzen/xtbreak/raw/main/data/US_panel.dta"}

{p 4 4}As before, we start with the sequential F-Test and the estimation of the break dates. 
We account for heteroskedasticity and autocorrelation by using an HAC robust variance estimator with the option {cmd:vce(hac)}.
Otherwise the syntax remains the same. 
{cmd:xtbreak} automatically detects if a panel or time series is used.{p_end}

{col 8}{stata xtbreak deaths L.cases, vce(hac)}

{p 4 4}We find evidence for 2 and 4 breaks. 
As this is a panel data set, we account for cross-section dependence as well using {cmd:csa(L.cases)} and 
we set the trimming to 10% with {cmd:trimming(0.1)}:{p_end}

{col 8}{stata xtbreak deaths L.cases, vce(hac) csa(L.cases) trimming(0.1)}

{p 4 4}Using this we observe that the values of the test stastic across all F-Statistics are relatively low. 
We are never able to reject the hypothesis of no break at a level of 1\%. 
Using a level of 5\%, we are able to reject F(1|0) and F(3|2), which implies either no break or 2 breaks. We test the null of no breaks against up to 5 breaks:{p_end}

{col 8}{stata xtbreak test deaths L.cases, h(2) breaks(5) trimming(0.1) vce(hac) csa(L.cases)}

{p 4 4}We find evidence for breaks, thus we are going to test the alternatives of one and three breaks:{p_end}

{col 8}{stata xtbreak test deaths L.cases, h(1) breaks(1) trimming(0.1) vce(hac) csa(L.cases)}

{col 8}{stata xtbreak test deaths L.cases, h(1) breaks(3) trimming(0.1) vce(hac) csa(L.cases)}

{p 4 4}Given that we are just about to reject the null hypothesis in the case of 1 break, 
we will assume 3 breaks. 
Next we are going to estimate the break points and run a fixed effects regression:{p_end}

{col 8}{stata xtbreak estimate deaths L.cases, breaks(3) trimming(0.1) vce(hac) csa(L.cases)}

{col 8}{stata estat split L.cases}

{col 8}{stata xtreg deaths `r(varlist)', fe}

INCLUDE help xtbreak_about


