{smcl}
{hline}
{hi:help xtbreak estimate}{right: v. 1.0 - 23. October 2021}

{hline}
{title:Title}

{p 4 4}{cmd:xtbreak estimate} - estimating many structural breaks in time series and panel data at unknown break dates.{p_end}

{title:Syntax}

{p 4}{ul:Estimation of breakpoints:}{p_end}

{p 4 13}{cmd:xtbreak} {cmdab:est:imate} {depvar} [{indepvars}] {ifin} {cmd:,} 
{cmd:breaks(}{it:#}{cmd:)}
{cmd:showindex}
{cmd:{help xtbreak_estimate##options1:options1}}
{cmd:{help xtbreak_estimate##options2:options2}}
{cmd:{help xtbreak_estimate##options5:options5}}
{p_end}

INCLUDE help xtbreak_options

{title:Contents}

{p 4}{help xtbreak_estimate##description:Description}{p_end}
{p 4}{help xtbreak_estimate##options:Options}{p_end}
{p 4}{help xtbreak_estimate##note_panel:Notes on Panel Data}{p_end}
{p 4}{help xtbreak##cov:Covariance Estimator}{p_end}
{p 4}{help xtbreak_estimate##saved_vales:Saved Values}{p_end}
{p 4}{help xtbreak_estimate##postest:Postestimation}{p_end}
{p 4}{help xtbreak_estimate##examples:Examples}{p_end}
{p 4}{help xtbreak_estimate##references:References}{p_end}
{p 4}{help xtbreak_estimate##about:About, Authors and Version History}{p_end}

{marker description}{title:Description}
{p 4 4}
{cmd:xtbreak} implements tests and estimates for multiple tests for structural breaks in time series and panel data models.{p_end}

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

{p 4 4}{cmd:xtbreak estimate} estimates the break points, that is, it estimates 
T1, T2, ..., Ts.
It implements the methods for detection ofstructural breaks discussed in 
Bai & Perron ({help xtbreak_estimate##BP1998:1998}, {help xtbreak_estimate##BP2003:2003}),
Karavias, Narayan, Westerlund ({help xtbreak_estimate##KNW2021:2021})
and Ditzen, Karavias, Westerlund ({help xtbreak_estimate##DKW2021:2021}). 
The underlying idea is that if the model with the true breakdates given a number of breaks
has a smaller sum of squared residuals (SSR) than a model with 
incorrect breakdates. 
To find the breakdates, {cmd:xtbreak estimate} uses the alogorthim (dynamic program) from {help xtbreak_estimate##BP2003:Bai and Perron (2003)}.
All {it:necessary} SSRs are calculated and then the smalles one selected.{p_end}

{p 4 4}{cmd:xtbreak estiamte} also construct confidence intervals around the
estimates for break dates.{p_end}

{p 4 4}In case of variables without breaks, {cmd:xtbreak} will remove those before
calculating the SSRs. 
The procedure follows the {it:partial dynamic program} algorithm in {help xtbreak_estimate##BP2003:Bai and Perron (2003)}.{p_end}

{p 4 4}
In pure time series model breaks in only the constant (or deterministics) are possible.
In this case {it:sigma0(s)} is a constant with a structural break. 
{p_end}

{p 4 4}{cmd:xtbreak} will automatically determine whether a time series or panel dataset
is used.{p_end}

{marker options}{title:Options}

INCLUDE help xtbreak_options_detail

{p 4 8 12}{cmd:showindex} shows index for confidence intervals rather than formatted time value.{p_end}

INCLUDE help xtbreak_PanelVarCov


{marker saved_vales}{title:Saved Values}

{p 4}{cmd:xtbreak estimate} stores the following in {cmd:e()}:{p_end}

{col 4} Matrices 
{col 8}{cmd: e(breaks)}{col 27}Matrix with break dates. First row indicates the index (t=1,..,T), second the value of the time identifier (for example 2000, 2001, ...).
{col 8}{cmd: e(CI)}{col 27}Confidence intervals with dimension {it:4 x number_breaks}.  
{col 27}The first two rows are the lower and upper 95% intervals using time indices, the second two rows are in the value of the time identifier.

{col 4} Macros
{col 8}{cmd: e(sample)}{col 27}sample

{marker postest}{title:Postestimation}

{p 4 4}{cmd:xtbreak estimate} supports three {cmd:estat} functions. The syntax to create an indicator is:{p_end}

{p 8 13}{cmd:estat} {cmdab:indic:ator} [{newvar}]{p_end}

{p 4 4}to split a {varlist} according to the estimated breakpoints{p_end}

{p 8 13}{cmd:estat split} [{varlist}]{p_end}

{p 4 4}and to draw a scatter plot of the variable with break on the x-axis and 
the dependent variable in the y-axis:{p_end}

{p 8 13}{cmd:estat scatter} [{varname}]{p_end}

{p 4 4}{cmd:estat} {cmdab:indic:ator} creates a new variable which takes on the values
1,...,number_breaks+1 for segment of the data. 
{cmd:estat split} splits the variables defined in {varlist} according to the breakdates.
{cmd:estat split} saves the names of the created variables in {cmd:r(varlist)}.
{cmd:estat scatter} draws a scatter plot with the dependent variable on the
y-axis and a variable with breaks defined in {varname} on the x-axis. 
{p_end}

{marker examples}{title:Examples}

{p 4 4}{ul:Examples using usmacro.dta}

{p 4 4}For example we want to find breaks in the 
US macro dataset supplied in Stata 16.
The dataset contains quarterly data on the inflation, GDP gap and the federal funds rate.
We load the data in as:{p_end}

{col 8}{stata "use http://www.stata-press.com/data/r16/usmacro.dta, clear"}

{p 4 4}A simple model to estimate the GDP gap using the federal funds rate and inflation woudl be:{p_end}

{col 8}{stata regress ogap inflation fedfunds}

{p 4 4}To estimate the date of - say - 2 breaks we write:{p_end}

{col 8}{stata xtbreak estimate ogap inflation fedfunds, breaks(2)}

{p 4 4}Next, we can create an indicator variable using {cmd:estat indicator}:{p_end}

{col 8}{stata estat indicator BreakRegimes}

{p 4 4}or split the variables into new ones with:{p_end}

{col 8}{stata estat split inflation fedfunds}

INCLUDE help xtbreak_about

{title:Also see}
{p 4 4}See also: {help xtbreak}, {help xtbreak_test:xtbreak test}, {help estat sbcusum}, {help estat sbknown}  {help estat sbsingle} {p_end} 
