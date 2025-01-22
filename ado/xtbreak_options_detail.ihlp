{p 4 8 12}{cmd:breaks(}{it:#}{cmd:)} specifies the number of unknown breaks under the alternative
or the number of break points to be estimated. 
For hypothesis 2, {cmd:breaks()} can take two values, 
for example {cmd:breaks(4 6)} test for no breaks against 4-6 breaks.
If only one value specified, then the lower limit is set to 1.{p_end}

{p 4 8 12}{cmdab:breakc:onstant} break in constant. 
Default is no breaks in deterministics.{p_end}

{p 4 8 12}{cmdab:breakf:ixedeffects} break in fixed effects. 
Default is no breaks in fixed effects.{p_end}

{p 4 8 12}{cmdab:noconst:ant} suppresses constant in time series or pooled constant in panel model{p_end}

{p 4 8 12}{cmdab:nofixed:effects} suppresses individual fixed effects (panel data only).{p_end}

{p 4 8 12}{cmdab:nobreakvar:iables(}{it:varlist1}{cmd:)} defines variables with no structural break(s).
{it:varlist1} can contain time series operators. {p_end}

{p 4 8 12}{cmd:vce(type)} covariance matrix estimator, allowed: ssr, hac, hc and np.
For more see,{help xtbreak##cov: covariance estimators}.{p_end}

{p 4 8 12}{cmdab:trim:ming(}{it:real}{cmd:)} minimal segment length in percent.
The minimal segment length is the minimal time periods between two breaks. 
The default is 15% (0.15).
Critical values are available for %5, 10%, 15%, 20% and 25%.{p_end}

{p 4 8 12}{cmd:error(}{it:real}{cmd:)} define error margin for partial break model.{p_end}

{p 4 8 12}{cmd:csd} adds cross-section averages of variables with and without breaks.{p_end}

{p 4 8 12}{cmd:csa({varlist})} and {cmd:csanobreak()} specify the variables with and without breaks which are added as cross-sectional averages. 
{cmd:xtbreak} calculates internally the cross-sectional averages.{p_end}

{p 4 8 12}{cmdab:kf:actors(}{varlist}{cmd:)} (known factors) and {cmdab:nbkf:actors} (known factors without breaks) specify known factors which are constant 
across the cross-sectional dimension such as 
seasonal dummies or other observed
common factors such as asset returns and oil prices with and without breaks.
{p_end}
{marker inverter}
{p 4 8 12}{cmdab:inv:erter(}{it:type}{cmd:)} sets the inverter. {it:type} can be: 
{it:speed} ({help mata invsym:invsym}), 
{it:precision}, {it:qr} (equivalent to precision; {help mata qrinv:qrinv}), 
{it:chol} ({help mata cholinv:chol}),
{it:p} ({help mata pinv:pinv}), or
{it:lu} ({help mata luinv:luinv}).
Choice of inverter has implications on speed and precision. 
For an overview see {help [M-4] solvers}.
{p_end}

{p 4 8 12}{cmd:python} use Python to calculated SSRs to improve speed. 
Requires Stata 16 or later, Python and the following packages: scipy, numpy, pandas and xarray. 
See {help xtbreak##python:details}.{p_end}

{p 4 8 12}{cmd:noreweigh} avoids to reweigh time-unit specific errors by the number of total observations over actual observations for a given time period
in order to increase the SSR of segments of unabalanced panels with missing data.
 Results with this options should be used indicative.
See also section on {help xtbreak##unbalanced:Unbalanced Panels}.
{p_end}
