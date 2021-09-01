{smcl}
{hline}
{hi:help xtbreak}{right: v. 0.03 - 13. August 2021}

{hline}
{title:Title}

{p 4 4}{cmd:xtbreak} - estimating and testing for many known and unknown structural breaks in time series and panel data.{p_end}

{title:Syntax}

{p 4}For a detail description for {bf:testing} see {help xtbreak_tests:xtbreak test}, 
for a detailed description on {bf:estimation} see {help xtbreak_estimate:xtbreak estimate}.

{p 4}{ul:Testing for {bf:known} structural breaks:}{p_end}

{p 4 13}{cmd:xtbreak} test {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmdab:breakp:oints(}{help numlist}| {help datelist}{cmd: [,index|fmt(}{help format}{cmd:)])} 
{cmd:{help xtbreak##options1:options1}}
{cmd:{help xtbreak##options4:options4}}{p_end}

{p 8}{cmdab:breakp:oints(}{it:numlist}{cmd:[,index|fmt()])} specifies the time period of the known 
structural break.{p_end}

{p 4}{ul:Testing for {bf:unknown} structural breaks:}{p_end}

{p 4 13}{cmd:xtbreak} {cmd:test} {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} 
{cmd:breaks(}{it:#}{cmd:)} 
{cmd:{help xtbreak##options1:options1}}
{cmd:{help xtbreak##options2:options2}}
{cmd:{help xtbreak##options3:options3}}
{cmd:{help xtbreak##options4:options4}}
{p_end}

{p 8}{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} specifies which hypothesis to test, see {help xtbreak_tests##hypothesis:hypothesises}. 
{cmd:breaks(#)} sets the number of breaks.
{p_end}

{p 4}{ul:Estimation of breakpoints:}{p_end}

{p 4 13}{cmd:xtbreak} {cmdab:est:imate} {depvar} [{indepvars}] {ifin} {cmd:,} 
{cmd:breaks(}{it:#}{cmd:)}
{cmd:showindex}
{cmd:{help xtbreak##options1:options1}}
{cmd:{help xtbreak##options2:options2}}
{cmd:{help xtbreak##options4:options4}}
{p_end}

{p 8}{cmd:breaks(#)} sets the number of breaks.{p_end}

{p 4}{ul: Maintenance}{p_end}

{p 4 13}{cmd:xtbreak , [update version]}{p_end}

{p 8}{cmd:version} displays version. 
{cmd:update} updates {cmd:xtbreak} from {browse "https://janditzen.github.io/xtbreak/":GitHub}
using {help net install}.{p_end}

INCLUDE help xtbreak_options

{title:Contents}

{p 4}{help xtbreak##description:Description}{p_end}
{p 4}{help xtbreak##options:Options}{p_end}
{p 4}{help xtbreak##example:Examples}{p_end}
{p 4}{help xtbreak##references:Refrences}{p_end}
{p 4}{help xtbreak##about:Authors and About}{p_end}

{marker description}{title:Description}
{p 4 4}
{cmd:xtbreak test} implements multiple tests for structural breaks in time series and panel data models.
The number and period of occurence of structral breaks can be known and unknown.
In the case of a known breakpoint {cmd:xtbreak test} can test if the break occurs at a specific point in time.
For unknown breaks, {cmd:xtbreak test} implements three different hypothesises. 
The first is no break against the alterantive of {it:s} breaks,
the second hypothesis is no breaks against a lower and upper limit of breaks. 
The last hypothesis tests the null of {it:s} breaks against the alterantive of
one more break ({it:s+1}). 
For further explanation see {help xtbreak_tests:xtbreak test}{p_end}

{p 4 4}
{cmd:xtbreak estimate} estimates the break points, that is, it estimates 
T1, T2, ..., Ts.
The underlying idea is that if the model with the true breakdates given a number of breaks
has a smaller sum of squared residuals (SSR) than a model with 
incorrect breakdates. 
To find the breakdates, {cmd:xtbreak estimate} uses the alogorthim (dynamic program) from {help xtbreak_estimate##BP2003:Bai and Perron (2003)}.
All {it:necessary} SSRs are calculated and then the smalles one selected.
For further explanation see {help xtbreak_estimate:xtbreak estimate}{p_end}

{p 4 4}{cmd:xtbreak} implements the tests for and estimation of structural breaks discussed in 
Bai & Perron ({help xtbreak_tests##BP1998:1998}, {help xtbreak_tests##BP2003:2003}),
Karavias, Narayan, Westerlund ({help xtbreak_tests##KNW2021:2021})
and Ditzen, Karavias, Westerlund ({help xtbreak_tests##DKW2021:2021}). 

{p 4 4}For the remainder we assume the following model:{p_end}

{p 8 8}y(i,t) = sigma0(1) + sigma1(1) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = 1,...,T1{p_end}
{p 8 8}y(i,t) = sigma0(2) + sigma1(2) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = T1+1,...,T2{p_end}
{p 8 8}...{p_end}
{p 8 8}y(i,t) = sigma0(s) + sigma1(s) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = Ts,...,T{p_end}

{p 4 4}where {it:s} is the number of the segment/breaks, {it:z(i,t)} is a NT1xq matrix containing the variables 
whose relationship with y breaks. 
A break in the constant is possible.
{it:x(i,t)} is a NTxp matrix with variables without a break.
{it:sigma0(s), sigma1(s)} are the coefficients with structural breaks
and T1,...,Ts are the periods of the breakpoints.{p_end}

{marker options}
{title:Options}

{p 4 8 12}{cmdab:breakp:oints(}{help numlist}| {help datelist}{cmd: [,index])} specifies the known 
breakpoints. 
Kown breakpoints can be set by either the number of observation or by the value of the 
time identifier.
If a {help numlist} is used, option index is required. 
For example {cmd:breakpoints(10,index)} specifies that the one break occurs at the 10th observation in time.
{help datelist} takes a list of dates.
For example {cmd:breakpoints(2010Q1)} specifies a break in Quarter 1 in 2010. 
If a datelist is used, 
the format set in {cmd:breakpoints()} and the time identifier needs to be the same.{p_end}

{p 4 8 12}{cmd:wdmax} Use weighted test statistic instead of 
unweighted for the double maximum test (hypothesis 2).{p_end}

{p 4 8 12}{cmd:level(#)} set level for critical values for weighted double maximum test.
If a value is chosen for which no critical values exits, {cmd:xtbreak test} will choose the closest level.{p_end}

{p 4 8 12}{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} specifies which hypothesis to test, see {help xtbreak_tests##DefUnknown:xtbreak test - unknown break dates}.{break} 
{cmd:h(1)} test for no breaks vs. {it:s} breaks, {break}
{cmd:h(2)} for no break vs. {it:s0 <= s <= s1} breaks and {break}
{cmd:h(3)} for {it:s} vs. {it:s+1} breaks.{p_end}

INCLUDE help xtbreak_options_detail

{p 4 8 12}{cmd:showindex} shows index for confidence intervals rather than formatted time value.{p_end}

{p 4 8 12}{cmd:update} Update {cmd:xtbreak} from Github. 
This is essentially the following call:{p_end}
{col 8}{stata `"net install xtbreak , from("https://janditzen.github.io/xtbreak/") force replace"'}

{p 4 8 12}{cmd:version} Displays version.{p_end}

{marker example}
{title:Examples}

{p 4 4}This example was presented at the Stata Conference {browse "https://www.stata.com/meeting/us21/":2021}. 
We will try to estimate the breakpoints in the relationship
between COVID infections in the US and excess deaths in 2020 and 2021. 
Weekly data is available on {browse "https://github.com/JanDitzen/xtbreak/tree/main/data":GitHub}.
The variable {it:ExcessMortality} has the excess mortality and the variable {it:new_cases} contains
the number of new covid cases. 
The idea is that initally more people died from COVID because it was a new virus. 
Then medical treatment advanced and vaccines became more available which should
decrease excess mortality.
On the other hand COVID cases have likely been underreported during the first wave.
We assume that there is a lag between the a positive test and death of one week. 
The mortality data is from {browse "https://www.cdc.gov/nchs/nvss/deaths.htm":CDC}, the data on the Covid 
cases from {browse "https://ourworldindata.org/":Our World in Data}.{p_end}

{p 4 4}First we load the data into Stata:{p_end}

{col 8}{stata "use https://github.com/JanDitzen/xtbreak/blob/main/data/US.dta"}

{p 4 4}We start with no prior knowledge of i) the number of breaks and ii) the exact date of each break. 
Therefore before estimating the breakpoints we use Hypothesis 2 (see {help xtbreak_tests##h2:details}) and assume up to 5 breaks:{p_end}

{col 8}{stata xtbreak test ExcessMortality L1.new_cases, hypothesis(2) breaks(5)}

{p 4 4}The test statistic is larger than the critical value and we reject the hypothesis of no breaks.
{cmd:xtbreak test} also reports two breaks. {break}
Next we test the hypothesis of no breaks against 2 breaks using hypothesis 1 
(see {help xtbreak_test##DefUnknown:details}):{p_end}

{col 8}{stata xtbreak test ExcessMortality L1.new_cases, hypothesis(1) breaks(2)}

{p 4 4}The test statistic is the same, however the critical values are smaller placing a lower 
bound on the rejection of the hypothesis.{p_end}

{p 4 4}Since we have an estimate of the breakpoints, we can test the two breakpoints 
as known breakpoints (see {help xtbreak_test##h1k:details}):{p_end}

{col 8}{stata xtbreak test ExcessMortality L1.new_cases, breakpoints(2020w20 2021w8 , fmt(tw))}

{p 4 4}Since we are using a {help datelist}, we need to specify the format of it.
{help datelist} also has to be the same format as the time identifier.{p_end}

{p 4 4}We have established that we have found 2 breaks. We can test the hypothesis 3, i.e. 2 breaks against the alternative of 3 breaks
(see {help xtbreak_test##h3:details}):{p_end}

{col 8}{stata xtbreak test ExcessMortality L1.new_cases, hypothesis(3) breaks(3)}

{p 4 4}First, note that we have to define in {cmd:breaks()} the alternative, that is we use {cmd:breaks(3)}. Secondly we cannot reject the hypothesis of 2 breaks.{p_end}

{p 4 4}After testing for breaks thoroughly we can estimate the breaks and construct confidence intervals (see {help xtbreak_estimate:details}):{p_end}

{col 8}{stata xtbreak estimate ExcessMortality L1.new_cases, breaks(2)}

{p 4 4}If we want to see the index of the confidence interval rather than the date, the option {cmd:showindex} can be used:{p_end}

{col 8}{stata xtbreak estimate ExcessMortality L1.new_cases, breaks(2) showindex}

{p 4 4}We can split the variable L1.new_cases into the different values for each regime using {cmd:estat split}. 
The variable list is saved in {cmd:r(varlist)} and we run a simple OLS regression on it:{p_end}

{col 8}{stata estat split}
{col 8}{stata reg ExcessMortality `r(varlist)'}

{p 4 4}Finally, we can draw a scatter plot of the variables with a different colour for each segement. 
The command line is {cmd:estat scatter {varlist}} where {varlist} is the independent variable (X), 
the dependent variable is automatically added on the y-axis.{p_end}

{col 8}{stata xtbreak estimate ExcessMortality L1.new_cases, breaks(2) showindex}
{col 8}{stata estat scatter L.new_cases}

INCLUDE help xtbreak_about

{title:Also see}
{p 4 4}See also: {help xtbreak_estimate:xtbreak estimate}, {help xtbreak_test:xtbreak test}, {help estat sbcusum}, {help estat sbknown},  {help estat sbsingle} {p_end} 
