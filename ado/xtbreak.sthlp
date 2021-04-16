{smcl}
{hline}
{hi:help xtbreak}{right: v. 0.01 - xx. xxxxx 2021}

{hline}
{title:Title}

{p 4 4}{cmd:xtbreak} - estimating and testing for many known and unknown structural breaks in time series and panel data.{p_end}

{title:Syntax}

{p 4}For a detail description for {bf:testing} see {help xtbreak_tests:xtbreak test}, 
for a detailed description on {bf:estimation} see {help xtbreak_estimate:xtbreak estimate}.

{p 4}{ul:Testing for {bf:known} structural breaks:}{p_end}

{p 4 13}{cmd:xtbreak} {cmd:test} {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmdab:breakp:oints(}{it:numlist}{cmd:[,index])} 
{cmd:{help xtbreak_tests##options1:options1}}{p_end}

{p 8}{cmdab:breakp:oints(}{it:numlist}{cmd:[,index])} specifies the time period of the known 
structural break.{p_end}

{p 4}{ul:Testing for {bf:unknown} structural breaks:}{p_end}

{p 4 13}{cmd:xtbreak} {cmd:test} {depvar} [{indepvars}]  {ifin} {cmd:,}
{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} 
{cmd:breaks(}{it:#}{cmd:)} 
{cmd:{help xtbreak_tests##options1:options1}}
{cmd:{help xtbreak_tests##options2:options2}}
{cmd:{help xtbreak_tests##options3:options3}}
{p_end}

{p 8}{cmdab:h:ypothesis(}{bf:1|2|3}{cmd:)} specifies which hypothesis to test, see {help xtbreak_tests##hypothesis:hypothesises}. 
{cmd:breaks(#)} sets the number of breaks.
{p_end}

{p 4}{ul:Estimation of breakpoints:}{p_end}

{p 4 13}{cmd:xtbreak} {cmdab:est:imate} {depvar} [{indepvars}] {ifin} {cmd:,} 
{cmd:breaks(}{it:#}{cmd:)}
{cmd:{help xtbreak_tests##options1:options1}}
{cmd:{help xtbreak_tests##options2:options2}}
{p_end}

{p 8}{cmd:breaks(#)} sets the number of breaks.{p_end}

INCLUDE help xtbreak_options

{title:Contents}

{p 4}{help xtbreak_tests##description:Description}{p_end}
{p 4}{help xtbreak_tests##options:Options}{p_end}


{marker description}{title:Description}

{marker description}{title:Description}
{p 4 4}
{cmd:xtbreak test} implements multiple tests for structural breaks in time series and panel data models.
The number and period of occurence of structral breaks can be known and unknown.
In the case of a known breakpoint {cmd:xtbreak test} can test if the break occurs at a specific point in time.
For unknown breaks, {cmd:xtbreak test} implements three different hypothesises. 
The first is no break against the alterantive of {it:s} breaks,
the second hypothesis is no breaks against a lower and upper limit of breaks. 
The last hypothesis tests the null of {it:s} breaks against the alterantive of
one more break ({it:s+1}).{p_end}

{p 4 4}{cmd:xtbreak test} implements the tests for structural breaks discussed in 
Bai & Perron ({help xtbreak_tests##BP1998:1998}, {help xtbreak_tests##BP2003:2003},
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



{marker references}{title:References}

{p 4}Andrews, D. W. K. (1993). 
Tests for Parameter Instability and Structural Change With Unknown Change Point. 
Econometrica, 61(4), 821–856.{p_end}

{p 4}Bai, B. Y. J., & Perron, P. (1998). 
Estimating and Testing Linear Models with Multiple Structural Changes. 
Econometrica, 66(1), 47–78.{p_end}

{p 4}Bai, J., & Perron, P. (2003). 
Computation and analysis of multiple structural change models. 
Journal of Applied Econometrics, 18(1), 1–22.{p_end}

INCLUDE help xtbreak_about
