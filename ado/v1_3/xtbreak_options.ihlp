{marker options1}
{p 4}{bf:General Options}{p_end}
{synoptset 30}{...}
{synopt:{it:options1}}Description{p_end}
{synoptline}
{synopt:{opt breakc:onstant}}break in constant{p_end}
{synopt:{opt noconst:ant}}suppresses constant or pooled constant in panel model{p_end}
{synopt:{opt nobreakvar:iables(varlist1)}}variables with no structural break(s){p_end}
{synopt:{opt vce(type)}}covariance matrix estimator, allowed: ssr, hac, hc and np{p_end}
{synoptline}
{p2colreset}{...}
{marker options2}
{p 4}{bf:Options for unknown breakdates}{p_end}
{synoptset 30}{...}
{synopt:{it:options2}}Description{p_end}
{synoptline}
{synopt:{opt trim:ming(real)}}minimal segment length, default is 15%{p_end}
{synopt:{opt error(real)}}error margin for partial break model{p_end}
{synopt:{opt region(region_options)}}specifies between which dates to search for unknown breakpoints. 
Option is {cmd:region(}{it:num#1 num#2}| {it: date#1 date#2}{cmd: [,index|fmt(}{help format}{cmd:)])} and the syntax is the same as for {cmd:breakpoints}.{p_end}
{synoptline}
{p2colreset}{...}
{marker options3}
{p 4}{bf:Options for testing with unknown breakdates and {cmd:hypothesis(2)}}{p_end}
{synoptset 30}{...}
{synopt:{it:options3}}Description{p_end}
{synoptline}
{synopt:{opt wdmax}}Use weighted test statistic instead of unweighted{p_end}
{synopt:{opt level(#)}}set level for critical values{p_end}
{synoptline}
{p2colreset}{...}
{marker options4}
{p 4}{bf:Options for testing with unknown breakdates and {cmd:hypothesis(3)}}{p_end}
{synoptset 30}{...}
{synopt:{it:options4}}Description{p_end}
{synoptline}
{synopt:{opt seq:uential}}Sequential F-Test to obtain number of breaks{p_end}
{synoptline}
{p2colreset}{...}
{marker options5}
{p 4}{bf:Options for panel data}{p_end}
{synoptset 30}{...}
{synopt:{it:options5}}Description{p_end}
{synoptline}
{synopt:{opt breakfixed:effects}}break in fixed effects {p_end}
{synopt:{opt nofixed:effects}}suppresses fixed effects {p_end}
{synopt:{opt csd}}add cross-section averages (automatically){p_end}
{synopt:{opt csa(varlist2)}}Variables with breaks used to calculate cross-sectional averages{p_end}
{synopt:{opt csano:break(varlist3)}}Variables without breaks used to calculate cross-sectional averages{p_end}
{synopt:{opt kf:actors(varlist4)}}Known factors, which are constant across the cross-sectional dimension.
 Examples are seasonal dummies or other observed common factors such as asset returns and oil prices. 
The factors in this list are affected by structural breaks in that their loadings change.{p_end}
{synopt:{opt nbkf:actors(varlist5)}}same as above but without breaks.{p_end}
{synoptline}
{p2colreset}{...}


{p 4 4}Data has to be {help tsset} or {help xtset} before using {cmd:xtbreak}. 
Data has to be balanced.
{depvars}, {indepvars} and {it:varlist}, {it:varlist}1 - {it:varlist}5 may contain time-series operators, see {help tsvarlist}.{break}
{cmd:xtdcce2} requires the {help moremata} package.
