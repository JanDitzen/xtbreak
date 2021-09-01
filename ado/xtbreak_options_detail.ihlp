{p 4 8 12}{cmd:breaks(}{it:#}{cmd:)} specifies the number of unknown breaks under the alternative
or the number of break points to be estimated. 
For hypothesis 2, {cmd:breaks()} can take two values, 
for example {cmd:breaks(4 6)} test for no breaks against 4-6 breaks.
If only one value specified, then the lower limit is set to 1.{p_end}

{p 4 8 12}{cmdab:breakc:onstant} break in constant. 
Default is no breaks in deterministics.{p_end}

{p 4 8 12}{cmdab:noconst:ant} suppresses constant.{p_end}

{p 4 8 12}{cmdab:nofixed:effects} suppresses individual fixed effects (panel data only).{p_end}

{p 4 8 12}{cmdab:nobreakvar:iables(}{it:varlist1}{cmd:)} defines variables with no structural break(s).
{it:varlist1} can contain time series operators. {p_end}

{p 4 8 12}{cmd:vce(type)} covariance matrix estimator, allowed: ssr, hac, hc, np and nw.
For more see,{help xtbreak_tests##cov: covariance estimators}.{p_end} 

{p 4 8 12}{cmdab:min:length(}{it:real}{cmd:)} minimal segment length in percent.
The minimal segment length is the minimal time periods between two breaks. 
The default is 15% (0.15).
Critical values are available for %5, 10%, 15%, 20% and 25%.{p_end}

{p 4 8 12}{cmd:error(}{it:real}{cmd:)} define error margin for partial break model.{p_end}

{p 4 8 12}{cmd:csa({varlist} [, deterministic[varlist] excludecsa])} and {cmd:csanobreak()} specify the variables with and without breaks which are added as cross-sectional averages. 
{cmd:xtbreak} calculates internally the cross-sectional averages.{break}
{cmd:deterministic[varlist]} can be used if the variables in {varlist}
are already cross-section averages and thus deterministic. {break}
{cmdab:exclude:csa} excludes the partialling out of cross-section
averages in the dynamic program.
{p_end}

