{marker options1}
{p 4}{bf:General Options}{p_end}
{synoptset 30}{...}
{synopt:{it:options1}}Description{p_end}
{synoptline}
{synopt:{opt breakc:onstant}}break in constant{p_end}
{synopt:{opt noconst:ant}}suppresses constant{p_end}
{synopt:{opt trend}}add trend to model (under construction!){p_end}
{synopt:{opt breakt:rend}}add trend with breaks to model (under construction!){p_end}
{synopt:{opt nobreakvar:iables(varlist1)}}variables with no structural break(s){p_end}
{synopt:{opt vce(type)}}covariance matrix estimator, allowed: ssr, hac, np and nw (under construction!){p_end}
{synoptline}
{p2colreset}{...}
{marker options2}
{p 4}{bf:Options for unknown breakdates}{p_end}
{synoptset 30}{...}
{synopt:{it:options2}}Description{p_end}
{synoptline}
{synopt:{opt min:length(real)}}minimal segment length, default is 15%{p_end}
{synopt:{opt error(real)}}error margin for partial break model{p_end}
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
{p 4}{bf:Options for panel data}{p_end}
{synoptset 30}{...}
{synopt:{it:options4}}Description{p_end}
{synoptline}
{synopt:{opt nofixed:effects}}suppresses fixed effects (only for panel data sets) (under construction!){p_end}
{synopt:{opt csa(varlist2[, options5)}}Variables with breaks used to calculate cross-sectional averages{p_end}
{synopt:{opt csano:break(varlist3[,options5])}}Variables without breaks used to calculate cross-sectional averages{p_end}
{synoptline}
{p2colreset}{...}
{marker options4}
{p 4}{bf:Options for cross-section averages}{p_end}
{synoptset 30}{...}
{synopt:{it:options5}}Description{p_end}
{synoptline}
{synopt:{opt deter:ministic(varlist4)}}Treat variables in {varlist}4 as determinsitic cross-section averages{p_end}
{synopt:{opt deter:ministic}}Treat all variables defined in {varlist}2/3 as deterministic{p_end}
{synopt:{opt exc:ludecsa}}Excludes cross-section averages from being partialled out in the dynamic program.{p_end}
{synoptline}
{p2colreset}{...}

{p 4 4}Data has to be {cmd:xtset} before using {cmd:xtbreak}; see {help xtset}.
{depvars}, {indepvars} and {it:varlist}1, {it:varlist}2 may contain time-series operators, see {help tsvarlist}.{break}
{cmd:xtdcce2} requires the {help moremata} package.{p_end}