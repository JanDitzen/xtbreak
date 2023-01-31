# xtbreak estimate

## estimating many structural breaks in time series and panel data at unknown break dates

For an overview of **xtbreak** see [xtbreak](https://janditzen.github.io/xtbreak/).

__Table of Contents__
1. [Syntax](#1-syntax)
2. [Description](#2-description)
3. [Options](#3-options)
4. [Note on Panel Data](#4-note-on-panel-data)
5. [Saved Values](#5-saved-values)
6. [Postestimation](#6-postestimation)
7. [Examples](#7-examples)
8. [References](#8-references)
9. [How to install](#9-how-to-install)
10. [About](#10-authors)

# 1. Syntax

#### Estimation of breakpoints

```
xtbreak estimate depvar [indepvars] [if] [in] , breaks(#) showindex options1 options2 options5
```

#### General Options

options1 | Description
--- | ---
**breakconstant** | break in constant
**noconstant** | suppresses constant
**nobreakvariables(varlist1)** | variables with no structural break(s)
**vce(type)** | covariance matrix estimator, allowed: ssr, hac, hc and np   

#### Options for unknown breakdates

options2 | Description
--- | ---
**trimming(real)** | minimal segment length

#### Options for panel data

options5 | Description
--- | ---
***nofixedeffects*** | suppresses fixed effects (only for panel data sets)
***breakfixedeffects*** | break in fixed effects
***csd*** | add cross-section averages of variables with and without breaks.
***csa(varlist)*** | Variables with breaks used to calculate cross-sectional averages
***csanobreak(varlist)*** | Variables without breaks used to calculate cross-sectional averages
***kfactors(varlist)*** | Known factors, which are constant across the cross-sectional dimension but are affected by structural breaks. Examples are seasonal dummies or other observed common factors such as asset returns and oil prices. 
***nbkfactors(varlist)*** | same as above but without breaks.

# 2. Description
***xtbreak test*** implements tests and estimates for multiple tests for structural breaks in time series and panel data models.

***xtbreak test*** implements the estimation for structural breaks discussed in Bai & Perron (1998, 2003), Karavias, Narayan, Westerlund (2021) and Ditzen, Karavias, Westerlund (2021).

For the remainder we assume the following model:

```
y(i,t) = sigma0(1) + sigma1(1) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = 1,...,T1

y(i,t) = sigma0(2) + sigma1(2) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = T1+1,...,T2
...
y(i,t) = sigma0(s) + sigma1(s) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = Ts,...,T
```
where *s* is the number of the segment/breaks, *z(i,t)* is a *NT1xq* matrix containing the variables whose relationship with y breaks.  A break in the constant is possible.  *x(i,t)* is a *NTxp* matrix with variables without a break.  *sigma0(s)*, *sigma1(s)* are the coefficients with structural breaks and T1,...,Ts are the periods of the breakpoints.

xtbreak estimate estimates the break points, that is, it estimates T1, T2, ..., Ts.  It implements the methods for detection of structural breaks discussed in Bai & Perron (1998, 2003), Karavias, Narayan, Westerlund (2021) and Ditzen, Karavias, Westerlund (2021).  The underlying idea is that if the model with the true breakdates given a number of breaks has a smaller sum of squared residuals (SSR) than a model with incorrect breakdates.  To find the breakdates, xtbreak estimate uses the alogorthim (dynamic program) from Bai and Perron (2003).  All necessary SSRs are calculated and then the smallest one selected.

xtbreak estimate also construct confidence intervals around the estimates for break dates.

In case of variables without breaks, xtbreak will remove those before calculating the SSRs.  The procedure follows the partial dynamic program algorithm in Bai and Perron (2003).

In pure time series model breaks in the constant (or deterministics) are possible.  In this case sigma0(s) is a constant with a structural break. Fixed effects in panel data models cannot have a break.

xtbreak will automatically determine whether a time series or panel dataset is used.

# 3. Options

#### Options

Option | Description
 --- | --- 
***breaks(#)*** |  specifies the number of unknown breaks under the alternative. For hypothesis 2, ***breaks()*** can take two values, for example breaks(4 6) test for no breaks against 4-6 breaks.  If only one value specified, then the lower limit is set to 1.
***showindex*** | show confidence intervals as index.
***breakconstant*** | break in constant.  Default is no breaks in deterministics.
***noconstant*** | suppresses constant.
***nofixedeffects*** | suppresses individual fixed effects (panel data only).
***breakfixedeffects*** | break in fixed effects.
***nobreakvariables(varlist1)*** | defines variables with no structural break(s).  *varlist1* can contain time series operators.
***vce(type)*** | covariance matrix estimator, allowed: ssr, hac, hc and np.
***trimming(real)*** | minimal segment length in percent.  The minimal segment length is the minmal time periods between two breaks.  The default is 15% (0.15).  Critical values are available for %5, 10%, 15%, 20% and 25%.
***error(real)*** | define error margin for partial break model.
***csd*** |  adds cross-section averages of variables with and without breaks.
***csa(varlist)*** | specify the variables with and without breaks which are added as cross-sectional averages. ***xtbreak*** calculates internally the       cross-sectional average.
***csanobreak()*** | same as ***csa()*** but for variables without a break.
***kfactors(varlist)*** | Known factors, which are constant across the cross-sectional dimension but are affected by structural breaks. Examples are seasonal dummies or other observed common factors such as asset returns and oil prices. 
***nbkfactors(varlist)*** | same as above but without breaks.

# 4. Note on panel data

If a panel dataset is used, xtbreak differentiates between four models.  The first model is a fixed effects model. A break in the fixed effects is not possible. The second and third models arewith a pooled constant (pooled OLS) with and without a break. The last model is a model with neither fixed effects nor a pooled constant.

The following table gives an overview:

Model | Equation  (xtbreak options)
 --- | --- 
Fixed Effects (nobreak) | y(i,t) =  a(i) + b1 x(i,t) +s1(s) z(i,t,s) + e(it)  
Fixed Effects(break) |  y(i,t) =  a(i,s) + b1 x(i,t) +s1(s) z(i,t,s) + e(it)    (```breakfixedeffects```)  
Pooled OLS (nobreak)     | y(i,t) =  b0 + b1 x(i,t) +s1(s) z(i,t,s) + e(it)     (```nofixedeffects```)
Pooled OLS (break)     | y(i,t) =  b1 x(i,t) +s0(s) + s1(s) z(i,t,s) + e(it)  (```nofixedeffects breakconstant```)
No FE or POLS   | y(i,t) =  b1 x(i,t) + s1(s) z(i,t,s) + e(it)         (```nofixedeffects noconstant```)

where b0 is the pooled constant without break, a(i) the fixed effects, b(1) a coefficient without break, s0(s) a pooled constant with break and s1(s) a coefficient with break.

In the estimation of the breakpoints, cross-sectional averages are not taken into account.

# 5. Saved Values

***xtbreak estimate*** stores the following in ***e()***:

Matrices | Description
---|---
***e(breaks)*** | Matrix with break dates. First row indicates the index (t=1,..,T), second the value of the time identifier (for example 2000, 2001, ...).
***e(CI)*** | Confidence intervals with dimension 4 x number_breaks.  The first two rows are the lower and upper 95% intervals using time indices, the second two rows are in the value of the time identifier.

# 6. Postestimation

xtbreak estimate supports three ``estat`` functions. The syntax to create an indicator is:

```
estat indicator [newvar]
```

to split a varlist according to the estimated breakpoints

```
estat split [varlist]
```

and to draw a scatter plot of the variable with break on the x-axis and the dependent variable in the y-axis:

```
estat scatter [varname]
```

``estat indicator`` creates a new variable which takes on the values 1,...,number_breaks+1 for segment of the data. ``estat split`` splits the variables defined in varlist according to the breakdates.  estat split saves the names of the created variables in r(varlist).  ``estat scatter`` draws a scatter plot with the dependent variable on the y-axis and a variable with breaks defined in varname on the x-axis.

# 7. Examples

For example we want to find breaks in the US macro dataset supplied in Stata 16.  The dataset contains quarterly data on the inflation, GDP gap and the federal funds rate.  We load the data in as:

```
use http://www.stata-press.com/data/r16/usmacro.dta, clear
```

A simple model to estimate the GDP gap using the federal funds rate and inflation woudl be:

```
regress ogap inflation fedfunds
```

To estimate the date of - say - 2 breaks we write:

```
xtbreak estimate ogap inflation fedfunds, breaks(2)
```

Next, we can create an indicator variable using estat indicator:

```
estat indicator BreakRegimes
```

or split the variables into new ones with:

```
estat split inflation fedfunds
```

# 8. References

Andrews, D. W. K. (1993).  Tests for Parameter Instability and Structural Change With Unknown Change Point.  Econometrica, 61(4), 821–856. [link](https://www.jstor.org/stable/2951764).

Bai, B. Y. J., & Perron, P. (1998).  Estimating and Testing Linear Models with Multiple Structural Changes.  Econometrica, 66(1), 47–78. [link](http://www.columbia.edu/~jb3064/papers/1998_Estimating_and_testing_linear_models_with_multiple_structural_changes.pdf).

Bai, J., & Perron, P. (2003).  Computation and analysis of multiple structural change models.  Journal of Applied Econometrics, 18(1), 1–22. [link](https://onlinelibrary.wiley.com/doi/full/10.1002/jae.659).

Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing for Multiple Structural Breaks in Panel Data. Available upon request. 

Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. arXiv:2110.14550 [econ.EM]. [link](https://arxiv.org/abs/2110.14550).

Karavias, Y, Narayan P. & Westerlund, J. (2021) Structural breaks in Interactive Effects Panels and the Stock Market Reaction to COVID–19. arXiv:2111.03035 [econ.EM]. [link](https://arxiv.org/abs/2111.03035).

## Slides
1. [Slides 2020 Swiss Stata User Group Meeting](https://www.stata.com/meeting/switzerland20/slides/Switzerland20_Ditzen.pdf)
2. [Slides 2021 German Stata User Group Meeting](https://www.stata.com/meeting/germany21/slides/Germany21_Ditzen.pdf)
3. [Slides 2021 US Stata Conference](https://www.stata.com/meeting/us21/slides/US21_Ditzen.pdf)

# 9. How to install

The latest version of the ***xtbreak*** package can be obtained by typing in Stata:

```
net from https://janditzen.github.io/xtbreak/
``` 

``xtbreak`` requires Stata 15 or newer.

# 10. Authors

#### Jan Ditzen (Free University of Bozen-Bolzano)

Email: jan.ditzen@unibz.it

Web: www.jan.ditzen.net

### Yiannis Karavias (University of Birmingham)

Email: I.Karavias@bham.ac.uk

Web: https://sites.google.com/site/yianniskaravias/

### Joakim Westerlund (Lund University)

Email: joakim.westerlund@nek.lu.se

Web: https://sites.google.com/site/perjoakimwesterlund/

## Please cite as follows:
Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. arXiv:2110.14550 [econ.EM].
