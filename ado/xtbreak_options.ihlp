{marker options1}
{p 4}{bf:General Options}{p_end}
{synoptset 25}{...}
{synopt:{it:options1}}Description{p_end}
{synoptline}
{synopt:{cmdab:breakc:onstant}}break in constant{p_end}
{synopt:{cmdab:noconst:ant}}suppresses constant{p_end}
{synopt:{cmdab:nobreakvar:iables(}{it:varlist1}{cmd:)}}variables with no structural break(s){p_end}
{synopt:{cmd:vce(type)}}covariance matrix estimator, allowed: ssr, hac, np and nw{p_end}
{synoptline}
{p2colreset}{...}
{marker options2}
{p 4}{bf:Options for unknown breakdates}{p_end}
{synoptset 25}{...}
{synopt:{it:options2}}Description{p_end}
{synoptline}
{synopt:{cmdab:min:length(}{it:real}{cmd:)}}minimal segment length, default is 15%{p_end}
{synopt:{cmd:error(}{it:real}{cmd:)}}error margin for partial break model{p_end}
{synoptline}
{p2colreset}{...}
{marker options3}
{p 4}{bf:Options for testing with unknown breakdates and {cmd:hypothesis(2)}}{p_end}
{synoptset 25}{...}
{synopt:{it:options3}}Description{p_end}
{synoptline}
{synopt:{cmd:wdmax}}Use weighted test statistic instead of unweighted{p_end}
{synopt:{cmd:level(#)}}set level for critical values{p_end}
{synoptline}
{p2colreset}{...}
{marker options4}
{p 4}{bf:Options for panel data}{p_end}
{synoptset 25}{...}
{synopt:{it:options4}}Description{p_end}
{synoptline}
{synopt:{cmdab:nofixed:effects}}suppresses fixed effects (only for panel data sets){p_end}
{synopt:{cmd:csa({varlist})}}Variables with breaks used to calculate cross-sectional averages{p_end}
{synopt:{cmdab:csano:break(varlist)}}Variables without breaks used to calculate cross-sectional averages{p_end}
{synoptline}
{p2colreset}{...}

{p 4 4}Data has to be {cmd:xtset} before using {cmd:xtbreak}; see {help xtset}.
{depvars}, {indepvars} and {it:varlists} may contain time-series operators, see {help tsvarlist}.{break}
{cmd:xtdcce2} requires the {help moremata} package.{p_end}