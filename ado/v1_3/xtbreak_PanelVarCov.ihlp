{marker note_panel}{title:Note on panel data}

{p 4 4}If a panel dataset is used, {cmd:xtbreak} differentiates between five models. 
The default is a model with fixed effects.
The second model has breaks in the fixed effects.
The third and forth models arewith a pooled constant (pooled OLS) with and without a break.
The last model is a model with neither fixed effects nor a pooled constant.{p_end}

{p 4 4}The following table gives an overview:{p_end}

{col 8}Model  {col 24}{c |} Equation  {col 83}{c |} {cmd:xtbreak} options,
{col 8}{hline 16}{c +}{hline 58}{c +}{hline 30}
{col 8}Fixed Effects {col 24}{c |} y(i,t) =  a(i) {col 43}+ b1 x(i,t) + s1(s) z(i,t,s) + e(i,t)  {col 83}{c |} {it:*}
{col 8}  with breaks{col 24}{c |} y(i,t) =  a(i,s) {col 43}+ b1 x(i,t) + s1(s) z(i,t,s) + e(i,t)  {col 83}{c |} {cmd:breakfixedeffects} {it:*}
{col 8}Pooled OLS {col 24}{c |} y(i,t) =  b0 {col 43}+ b1 x(i,t) + s1(s) z(i,t,s) + e(i,t) {col 83}{c |} {cmd:nofixedeffects}
{col 8}  with breaks{col 24}{c |} y(i,t) =  s0(s) {col 43}+ b1 x(i,t) + s1(s) z(i,t,s) + e(i,t) {col 83}{c |} {cmd:nofixedeffects breakconstant}
{col 8}No FE or POLS {col 24}{c |} y(i,t) =  {col 43}  b1 x(i,t) + s1(s) z(i,t,s) + e(i,t) {col 83}{c |} {cmd:nofixedeffects noconstant}
{col 8}{it:*} Option {cmd:noconstant} is implied.

{p 4 4}where b0 is the pooled constant without break, a(i) the fixed effects, 
a(i,s) fixed effects with breaks,
b(1) a coefficient without break, s0(s) a pooled constant with break 
and s1(s) a coefficient with break.{p_end}

{p 4 4}A model with a constant and fixed effects, with or without breaks in both is a special case of the first two models above.
Since we are not interested in the estimation of the constant and/or the fixed effects,
we can treat them as the combination of both.{p_end}

{marker cov}{title:Covariance Estimators}

{p 4 8}{cmd:xtbreak} supports 4 different covariance estimator:{p_end}

{col 8}{cmd:vce(}{it:type}{cmd:)}{col 19}{c |} Description 
{col 8}{hline 11}{c +}{hline 65} 
{col 9}{it:ssr}{col 19}{c |} Variance Covariance estimator based on SSR: cov = (X'X)^(-1)*SSR
{col 9}{it:hc}{col 19}{c |} heteroskedastic robust; HC0
{col 9}{it:hac}{col 19}{c |} heteroskedastic and autocorrelation robust from KNW ({help xtbreak_estimate##KNW2021:2022})
{col 9}{it:np}{col 19}{c |} non-parametric estimator of Pesaran ({help xtbreak##Pesaran2006:2006)}
