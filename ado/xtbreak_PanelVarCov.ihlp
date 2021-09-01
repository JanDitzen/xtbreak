{marker note_panel}{title:Note on panel data}

{p 4 4}If a panel dataset is used, {cmd:xtbreak} differentiates between four models. 
The first model is a fixed effects model. A break in the fixed effects is not possible.
The second and third models arewith a pooled constant (pooled OLS) with and without a break.
The last model is a model with neither fixed effects nor a pooled constant.{p_end}

{p 4 4}The following table gives an overview:{p_end}

{col 8}Model  {col 24}{c |} Equation  {col 79}{c |} {cmd:xtbreak} options
{col 8}{hline 16}{c +}{hline 54}{c +}{hline 30}
{col 8}Fixed Effects {col 24}{c |} y(i,t) =  a(i) + b1 x(i,t) +s1(s) z(i,t,s) + e(it)  {col 79}{c |}
{col 8}Pooled OLS {col 24}{c |} y(i,t) =  b0 + b1 x(i,t) +s1(s) z(i,t,s) + e(it) {col 79}{c |} {cmd:nofixedeffects}
{col 8}Pooled OLS {col 24}{c |} y(i,t) =  b1 x(i,t) +s0(s) + s1(s) z(i,t,s) + e(it) {col 79}{c |} {cmd:nofixedeffects breakconstant}
{col 8}No FE or POLS {col 24}{c |} y(i,t) =  b1 x(i,t) + s1(s) z(i,t,s) + e(it) {col 79}{c |} {cmd:nofixedeffects noconstant}

{p 4 4}where b0 is the pooled constant without break, a(i) the fixed effects, 
b(1) a coefficient without break, s0(s) a pooled constant with break 
and s1(s) a coefficient with break.{p_end}

{p 4 4}In the estimation of the breakpoints, cross-sectional averages are not taken into account.{p_end}

{marker cov}{title:Covariance Estimators}