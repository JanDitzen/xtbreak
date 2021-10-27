# xtbreak test

## estimating and testing for many known and unknown structural breaks in time series and panel data.

For an overview of **xtbreak** see [xtbreak](https://janditzen.github.io/xtbreak/).

__Table of Contents__
1. [Syntax](#1-syntax)
2. [Description](#2-description)
	1. [Testing known breakpoints](#21-testing-known-breakpoints)
	2. [Testing unknown breakpoints](#22-testing-unknown-breakpoints)
3. [Options](#3-options)
4. [Note on Panel Data](#4-note-on-panel-data)
5. [Saved Values](#5-saved-values)
6. [Examples](#6-examples)
7. [References](#7-references)
8. [How to install](#8-how-to-install)
9. [About](#9-authors)

# 1. Syntax

#### Testing for known structural breaks:

```
xtbreak test depvar [indepvars] [if] , 
        breakpoints(numlist| datelist [,index| fmt(string)]) options1 options5
```

***breakpoints()*** specifies the time period of the known structural break.

#### Testing for unknown structural breaks:

```
xtbreak test depvar [indepvars] [if] , 
        hypothesis(1|2|3) breaks(#) options1 options2 options3 options4 options5
```

***hypothesis(1\2\3)*** specifies which hypothesis to test, see hypothesises. ***breaks(#)*** sets the number of breaks.

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

#### Options for testing with unknown breakdates and hypothesis(2)

options3 | Description
--- | ---
**wdmax** | Use weighted test statistic instead of unweighted
**level(#)** | set level for critical values

#### Options for testing with unknown breakdates and hypothesis(3)

options4 | Description
--- | ---
**sequential** | Sequential F-Test to obtain number of breaks

#### Options for panel data

options5 | Description
--- | ---
***nofixedeffects*** | suppresses fixed effects (only for panel data sets)
***breakfixedeffects*** | break in fixed effects
***csd*** |  adds cross-section averages of variables with and without breaks.
***csa(varlist)*** | Variables with breaks used to calculate cross-sectional averages
***csanobreak(varlist)*** | Variables without breaks used to calculate cross-sectional averages
***kfactors(varlist)*** | Known factors, which are constant across the cross-sectional dimension but are affected by structural breaks. Examples are seasonal dummies or other observed common factors such as asset returns and oil prices. 
***nbkfactors(varlist)*** | same as above but without breaks.

# 2. Description
***xtbreak test*** implements multiple tests for structural breaks in time series and panel data models. The number and period of occurence of structral
breaks can be known and unknown.  In the case of a known breakpoint ***xtbreak test*** can test if the break occurs at a specific point in time.  For
unknown breaks, ***xtbreak test*** implements three different hypothesises.  The first is no break against the alterantive of *s* breaks, the second
hypothesis is no breaks against a lower and upper limit of breaks.  The last hypothesis tests the null of *s* breaks against the alterantive of one
more break (*s+1*).

***xtbreak test*** implements the tests for structural breaks discussed in Bai & Perron (1998, 2003), Karavias, Narayan, Westerlund (2021) and Ditzen, Karavias, Westerlund (2021).

For the remainder we assume the following model:

```
y(i,t) = sigma0(1) + sigma1(1) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = 1,...,T1

y(i,t) = sigma0(2) + sigma1(2) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = T1+1,...,T2
...
y(i,t) = sigma0(s) + sigma1(s) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = Ts,...,T
```
where *s* is the number of the segment/breaks, *z(i,t)* is a *NT1xq* matrix containing the variables whose relationship with y breaks.  A break in the
constant is possible.  *x(i,t)* is a *NTxp* matrix with variables without a break.  *sigma0(s)*, *sigma1(s)* are the coefficients with structural breaks and T1,...,Ts are the periods of the breakpoints.

In pure time series model breaks in the constant (or deterministics) are possible.  In this case sigma0(s) is a constant with a structural break. Fixed effects in panel data models cannot have a break.

xtbreak will automatically determine whether a time series or panel dataset is used.


## 2.1 Testing known breakpoints

Assume that the numbers of breaks and their occurence is known.  ***xtbreak test*** can test the breakpoints.  The F-Statistic for the test with s breaks
at known dates is:

```
F(s,q) = dof_adj sigma' R' (R V R')^(-1) R sigma
```

*dof_adj* is a degree of freedom adjustment, *sigma* a matrix containing the coefficient estimates of *sigma*, *R* is the convential matrix of a Wald test
and *V* is a variance-covariance matrix. Under the null *F(s,q)* is F distributed.

A known break date can be tested with ***xtbreak test*** using the option ***breakpoints(numlist|datelist,[index|fmt()])***.  ***numlist|datelist*** defines the periods of
the breaks.  If *numlist* is used, then the option ***index*** is required.
If *datelist* is used, then option ***fmt(format)*** defines the format in use.

## 2.2 Testing unknown breakpoints

If the number and thus the time period of breaks is unknwon, ***xtbreak test*** offers three different hypothesises:

## 2.2.1 No break against *s* breaks

Formally the hypothesis are:

```
H_0: no break vs. H_1: s breaks at unknown dates
```

Bai & Perron (1998) suggest to take the supremum of the F-Statistics:

```
supF(s,q) = sup (l1,..,lq) F(l,q)
```
where *l1*, *lq* are the different sets of possible breakpoints.  Essentially the test is the test of a known break after estimation of the breakpoints given a number of breaks.  For a discussion of the estimation of the breakpoints see ***xtbreak estimate*** .

The supremum F-Test is called in ***xtbreak test*** using the options breaks(#) hypothesis(1).  breaks(#) sets the number of breaks. Critical values can be found in Bai & Perron (1998, 2003) and are supplied by ***xtbreak test***.

### 2.2.2 No break against s0<= s <=s1 breaks

A test of the null hypothesis of no structural change against the alternative that an unknown number of structural breaks have occurred, where this unknown number of breaks lies between *s0* and *s1* is:

```
H_0: no break vs. H_1: s0 <= s <= s1 breaks at unknown dates
```

The so-called double maximum test statistic is:

```
supF = sup(s0,..s,..,s1) supF(s,q)
```

where ***supF(s,q)*** is as defined above.

Generally speaking, the double maximum test estimates the breakdates for each number of breaks between *s0* and *s1*, calculates the corresponding test statistic and then selects the largest one.  Two versions of the double maximum test are available, an unweighted and a weighted test.  For the weighted test the test *supF(l,q)* test statistics are weighted by critical values.

The double maximum test can be used if the options ***breaks(#) hypothesis(2)*** are used.  Critical values can be found in Bai & Perron (1998, 2003) and are supplied by ***xtbreak test***.

### 2.2.3 s breaks against s+1 breaks

A test of the null hypothesis that, *s* structural breaks have occurred, against the alternative that *s + 1* breaks have occurred is:

```
H_0: s breaks vs H_1 s+1 breaks

F(s+1\s) = sup(s=1,..,s+1) sup(s0,..s,..,s1) supF(s,q)
```

The test is essentially comparing the SSR of the model with *s* breaks to the minimum of the SSR of the model with *s+1* breaks. 

The *F(s+1\s)* test is integrated in ***xtbreak test*** with the options ***breaks(#) hypothesis(3)***.  Critical values can be found in Bai & Perron (1998, 2003) and are supplied by ***xtbreak test***.

# 3. Options

#### Options

Option | Description
 --- | --- 
***breakpoints(numlist\datelist [,index\fmt(format)])*** |  specifies the known breakpoints.  Known breakpoints can be set by either the number of observation or by the value of the time identifier.  If a numlist is used, option index is required.  For example ***breakpoints(10,index)*** specifies that the one break occurs at the 10th observation in time.  datelist takes a list of dates.  For example ``breakpoints(2010Q1) , fmt(tq)`` specifies a break in Quarter 1 in 2010.  The option ***fmt()*** specifies the format and is required if a datelist is used.  The format set in **breakpoints()** and the time identifier needs to be the same.
***breaks(#)*** |  specifies the number of unknwon breaks under the alternative. For hypothesis 2, ***breaks()*** can take two values, for example breaks(4 6) test for no breaks against 4-6 breaks.  If only one value specfied, then the lower limit is set to 1.
***hypothesis(1\2\3)*** | specifies which hypothesis to test. *h(1)* test for no breaks vs. s breaks, *h(2)* for no break vs. s0 <= s <= s1 breaks and *h(3)* for s vs. s+1 breaks. Hypothesis 3 is the default.
***sequential*** | sequential F-Test to determin number of breaks.  The number of breaks is varied from s = 0 to breaks()-1 or floor(1/min_length).
***breakconstant*** | break in constant.  Default is no breaks in deterministics.
***noconstant*** | suppresses constant.
***nofixedeffects*** | suppresses individual fixed effects (panel data only).
***breakfixedeffects*** | break in fixed effects.
***nobreakvariables(varlist1)*** | defines variables with no structural break(s).  *varlist1* can contain time series operators.
***vce(type)*** | covariance matrix estimator, allowed: ssr, hac, hc and np.
***trimming(real)*** | minimal segment length in percent.  The minimal segment length is the minmal time periods between two breaks.  The default is 15% (0.15).  Critical values are available for %5, 10%, 15%, 20% and 25%.
***error(real)*** | define error margin for partial break model.
***wdmax*** |  Use weighted test statistic instead of unweighted for the double maximum test (hypotheis 2).
***level(#)*** | set level for critical values for weighted double maximum test.  If a value is choosen for which no critical values exists, ***xtbreak test*** will choose the closest level.
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
Fixed Effects (nobreak)  | y(i,t) =  a(i) + b1 x(i,t) +s1(s) z(i,t,s) + e(it) 
Fixed Effects(break) |  y(i,t) =  a(i,s) + b1 x(i,t) +s1(s) z(i,t,s) + e(it)    (```breakfixedeffects```)    
Pooled OLS (nobreak)     | y(i,t) =  b0 + b1 x(i,t) +s1(s) z(i,t,s) + e(it)     (```nofixedeffects```)
Pooled OLS (break)     | y(i,t) =  b1 x(i,t) +s0(s) + s1(s) z(i,t,s) + e(it)  (```nofixedeffects breakconstant```)
No FE or POLS   | y(i,t) =  b1 x(i,t) + s1(s) z(i,t,s) + e(it)         (```nofixedeffects noconstant```)

where b0 is the pooled constant without break, a(i) the fixed effects, b(1) a coefficient without break, s0(s) a pooled constant with break and s1(s) a coefficient with break.

In the estimation of the breakpoints, cross-sectional averages are not taken into account.


# 5. Saved Values

***xtbreak test*** stores the following in ***r()***:

### Known Breakpoints

Scalars | Description
---|---
***r(Wtau)*** | Value of test statistic. 
***r(p)*** | p-Value from F distribution. 

### Unknown Breakpoints

Scalars | Description
---|---
***r(supWtau)*** | Value of supF statistic (hypothesis 1). 
***r(Dmax)*** | Value of unweighted double maximum test (hypothesis 2). 
***r(WDmax)*** | Value of weighted double maximum test (hypothesis 2).
***r(f)*** | Value of supremum of supF statistic (hypothesis 3). 
***r(c90)*** | Critival value at 90%. 
***r(c95)*** | Critival value at 95%.
***r(c99)*** | Critival value at 99%.

# 6. Examples

## 6.1 Examples using usmacro.dta

For example we want to find breaks in the US macro dataset supplied in Stata 16.  The dataset contains quarterly data on the inflation, GDP gap and the federal funds rate.  We load the data in as:

```
use http://www.stata-press.com/data/r16/usmacro.dta, clear
```

A simple model to estimate the GDP gap using the federal funds rate and inflation woudl be:

```
regress ogap inflation fedfunds
```

### Test for known breaks

Assume we want to test for a break in Quarter 1 1970:

```
xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1))
```

and if we want to test for a break in 1970q1 and 1990q4:

```
xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1) tq(1990q4))
```

If we want to test if breaks occurs after 10 and 20 periods:

```
xtbreak test ogap inflation fedfunds, breakpoint(10 20, index)
```

### Test for unknown breaks

#### No vs. s breaks

To test hypothesis 1 with for example 3 breaks:

```
xtbreak test ogap inflation fedfunds, hypothesis(1) breaks(3)
```

The default is to assume no break in the constant.  To add a break in the constant, the option breakconstant is added:

```
xtbreak test ogap inflation fedfunds, hypothesis(1) breaks(3) breakconstant}
```

#### No vs. s0 <= s <= s1 breaks

Hypothesis 2 can be tested with:

```
xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(3)
```

The test assumes that under the alternative, there are between 1 and 3 breaks.  To test if there are between 2 and 4 breaks under the alterantive:

```
xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(2 4)

```

To use the weighted double maximum test we use the option wdmax

```
xtbreak test ogap inflation fedfunds, hypothesis(2) breaks(2 4) wdmax
```

#### Testing s vs. s+1 breaks

Hypothesis can be tested using option hypothesis(3):

```
xtbreak test ogap inflation fedfunds, hypothesis(3) breaks(2)
```

To change the minimal segment length to 5%:

```
xtbreak test ogap inflation fedfunds, hypothesis(3) breaks(2) trimming(0.05)
```

## 6.2 Examples: Excess deaths in the UK due to COVID 19

An early version of ***xtbreak test*** was presented at the 2020 Swiss User Group meeting (see [slides](
https://www.stata.com/meeting/switzerland20/slides/Switzerland20_Ditzen.pdf),
***NOTE*** The examples are on an early version of *xtbreak*. Results have changed!)
The empircal example was on the question if can we identify structural breaks in the excess deaths in the
UK in 2020 due to COVID19?
Data from Office of National Statistics (ONS) for weekly deaths in the UK for 2020 was used.
The data can be downloaded [here](https://github.com/JanDitzen/xtbreak/tree/main/data).

To test for an unknown breakdate with up to for breaks:

```
xtbreak test ExcessDeaths , breakconstant breaks(1 4) hypothesis(2)
```

We can test if there is a break in weeks 13 and 20 against the
hypothesis of no break.

```
xtbreak test ExcessDeaths , breakconstant hypothesis(1) breakpoints(13 20, index)
```

Using a HAC consistent estimator rather than the SSR. 

```
xtbreak test ExcessDeaths , breakconstant hypothesis(1) breakpoints(13 20, index) vce(hac)
```

Test for 2 breaks at unknown dates:

```
xtbreak test ExcessDeaths , breakconstant breaks(2) hypothesis(1)
```

Test for 1 vs. 2 breaks:

```
xtbreak test ExcessDeaths , breakconstant breaks(1) hypothesis(3)
```

# 7. References

Andrews, D. W. K. (1993).  Tests for Parameter Instability and Structural Change With Unknown Change Point.  Econometrica, 61(4), 821–856. [link](https://www.jstor.org/stable/2951764).

Bai, B. Y. J., & Perron, P. (1998).  Estimating and Testing Linear Models with Multiple Structural Changes.  Econometrica, 66(1), 47–78. [link](http://www.columbia.edu/~jb3064/papers/1998_Estimating_and_testing_linear_models_with_multiple_structural_changes.pdf).

Bai, J., & Perron, P. (2003).  Computation and analysis of multiple structural change models.  Journal of Applied Econometrics, 18(1), 1–22. [link](https://onlinelibrary.wiley.com/doi/full/10.1002/jae.659).

Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing for Multiple Structural Breaks in Panel Data. Available upon request. 

Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. Available upon request.

Karavias, Y, Narayan P. & Westerlund, J. (2021) Structural breaks in Interactive Effects Panels and the Stock Market Reaction to COVID–19. Available upon request.

## Slides
1. [Slides 2020 Swiss Stata User Group Meeting](https://www.stata.com/meeting/switzerland20/slides/Switzerland20_Ditzen.pdf)
2. [Slides 2021 German Stata User Group Meeting](https://www.stata.com/meeting/germany21/slides/Germany21_Ditzen.pdf)
3. [Slides 2021 US Stata Conference](https://www.stata.com/meeting/us21/slides/US21_Ditzen.pdf)


# 8. How to install

The latest version of the ***xtbreak*** package can be obtained by typing in Stata:

```
net from https://janditzen.github.io/xtbreak/
``` 

``xtbreak`` requires Stata 15 or newer.

# 9. Authors

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
Ditzen, J, Y. Karavias and J. Westerlund. 2021. Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata.

