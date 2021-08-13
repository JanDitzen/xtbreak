# xtbreak test

## estimating and testing for many known and unknown structural breaks in time series and panel data.

For an overview of **xtbreak test** see [xtbreak test](docs/xtbreak_test.md) and for **xtbreak estimate** see [xtbreak estimate](docs/xtbreak_estimate.md).

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
9. [Questions?](#90-questions?)
10. [About](#10-authors)

# 1. Syntax

#### Testing for known structural breaks:

```
xtbreak test depvar [indepvars] [if] [in] , 
        breakpoints(numlist| datelist [,index| fmt(string)]) options1 options4
```

***breakpoints()*** specifies the time period of the known structural break.

#### Testing for unknown structural breaks:

```
xtbreak test depvar [indepvars] [if] [in] , 
        hypothesis(1|2|3) breaks(#) options1 options2 options3 options4
```

***hypothesis(1\2\3)*** specifies which hypothesis to test, see hypothesises. ***breaks(#)*** sets the number of breaks.

#### Estimation of breakpoints

```
xtbreak estimate depvar [indepvars] [if] [in] , breaks(#) showindex options1 options2 options4
```

#### General Options

options1 | Description
--- | ---
**breakconstant** | break in constant
**noconstant** | suppresses constant
**nobreakvariables(varlist1)** | variables with no structural break(s)
**trend** | add trend to model (under construction!)
**breaktrend** | add trend with breaks to model (under construction!)
**vce(type)** | covariance matrix estimator, allowed: ssr, hac, np and nw

#### Options for unknown breakdates

options2 | Description
--- | ---
**minlength(real)** | minimal segment length
**error(real)** | error margin for partial break model

#### Options for testing with unknown breakdates and hypothesis(2)

options3 | Description
--- | ---
**wdmax** | Use weighted test statistic instead of unweighted
**level(#)** | set level for critical values

#### Options for panel data

options4 | Description
--- | ---
***nofixedeffects*** | suppresses fixed effects (only for panel data sets)
***csa(options5)*** | Variables with breaks used to calculate cross-sectional averages
***csanobreak(options5)*** | Variables without breaks used to calculate cross-sectional averages

#### Options for cross-section averages 

options5 | Description
--- | ---
**deterministic(varlist4)** | Treat variables in varlist4 as determinsitic cross-section averages
**deterministic** | Treat all variables defined in varlist2/3 as deterministic
**excludecsa** | **Excludes cross-section averages from being partialled out in the dynamic program.


# 2. Description
**xtbreak test** implements multiple tests for structural breaks in time series and panel data models.  The number and period of occurence of structral breaks can be known and unknown.  In the case of a known    breakpoint xtbreak test can test if the break occurs at a specific point in time.  For unknown breaks, xtbreak test implements three different hypothesises.  The first is no break against the alterantive of *s* breaks, the second hypothesis is no breaks against a lower and upper limit of breaks.  The last hypothesis tests the null of s breaks against the alterantive of one more break *(s+1)*. For more details see [xtbreak test](docs/xtbreak_test.md).

**xtbreak estimate** estimates the break points, that is, it estimates *T1*, *T2*, ..., *Ts*.  The underlying idea is that if the model with the true breakdates given a number of breaks has a smaller sum of squared residuals (SSR) than a model with incorrect breakdates.  To find the breakdates, xtbreak estimate uses the alogorthim (dynamic program) from Bai and Perron (2003).  All necessary SSRs are calculated and then the smalles one selected. For more details see [xtbreak estimate](docs/xtbreak_estimate.md).

**xtbreak** implements the tests for and estimation of structural breaks discussed in Bai & Perron (1998, 2003), Karavias, Narayan, Westerlund (2021) and Ditzen, Karavias, Westerlund (2021).

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

# 3. Options

#### Options

Option | Description
 --- | --- 
***breakpoints(numlist\datelist [,index|fmt(format)])*** |  specifies the known breakpoints.  Known breakpoints can be set by either the number of observation or by the value of the time identifier.  If a numlist is used, option index is required.  For example ***breakpoints(10,index)*** specifies that the one break occurs at the 10th observation in time.  datelist takes a list of dates.  For example ``breakpoints(2010Q1) , format(tq)`` specifies a break in Quarter 1 in 2010.  The option ***format()*** specifies the format and is required if a datelist is used.  The format set in **breakpoints()** and the time identifier needs to be the same.
***breaks(#)*** |  specifies the number of unknwon breaks under the alternative. For hypothesis 2, ***breaks()*** can take two values, for example breaks(4 6) test for no breaks against 4-6 breaks.  If only one value specfied, then the lower limit is set to 1.
***showindex*** | show confidence intervals as index.
***hypothesis(1\2\3)*** | specifies which hypothesis to test. *h(1)* test for no breaks vs. s breaks, *h(2)* for no break vs. s0 <= s <= s1 breaks and *h(3)* for s vs. s+1 breaks.
***breakconstant*** | break in constant.  Default is no breaks in deterministics.
***noconstant*** | suppresses constant.
***nofixedeffects*** | suppresses individual fixed effects (panel data only).
***nobreakvariables(varlist1)*** | defines variables with no structural break(s).  *varlist1* can contain time series operators.
***vce(type)*** | covariance matrix estimator, allowed: ssr, hac, hc, np and nw.  For more see, covariance estimators.
***minlength(real)*** | minimal segment length in percent.  The minimal segment length is the minmal time periods between two breaks.  The default is 15% (0.15).  Critical values are available for %5, 10%, 15%, 20% and 25%.
***error(real)*** | define error margin for partial break model.
***wdmax*** |  Use weighted test statistic instead of unweighted for the double maximum test (hypotheis 2).
***level(#)*** | set level for critical values for weighted double maximum test.  If a value is choosen for which no critical values exits, ***xtbreak test*** will choose the closest level.
***csa(varlist [, deterministic[varlist] excludecsa])*** | specify the variables with and without breaks which are added as cross-sectional averages. ***xtbreak*** calculates internally the       cross-sectional average. ``deterministic[varlist]`` can be used if the variables in varlist are already cross-section averages and thus deterministic. ``excludecsa`` excludes the partialling out of cross-section averages in the dynamic program.
***csanobreak()*** | same as ***csa()*** but for variables without a break.


# 4. Examples

This example was presented at the Stata Conference [2021](https://www.stata.com/meeting/us21/). We will try to estimate the breakpoints in the relationship between COVID infections in the US and excess deaths in 2020 and 2021. Weekly data is available on [GitHub](https://github.com/JanDitzen/xtbreak/tree/main/data). The variable *ExcessMortality* has the excess mortality and the variable **new_cases** contains the number of new covid cases. The idea is that initally more people died from COVID because it was a new virus. Then medical treatment advanced and vaccines became more available which should decrease excess mortality. On the other hand COVID cases have likely been underreported during the first wave. We assume that there is a lag between the a positive test and death of one week. The mortality data is from [CDC](https://www.cdc.gov/nchs/nvss/deaths.htm), the data on the Covid cases from browse [Our World in Data](https://ourworldindata.org/).

First we load the data into Stata:

```
use https://github.com/JanDitzen/xtbreak/blob/main/data/US.dta
```

We start with no prior knowledge of i) the number of breaks and ii) the exact date of each break. 
Therefore before estimating the breakpoints we use Hypothesis 2 and assume up to 5 breaks:

```
xtbreak test ExcessMortality L1.new_cases, hypothesis(2) breaks(5)

Test for multiple breaks at unknown breakdates
(Bai & Perron. 1998. Econometrica)
H0: no break(s) vs. H1: 1 <= s <= 5 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 UDmax(tau)         130.10            12.37            8.88            7.46
--------------------------------------------------------------------------------
Estimated break points:  2020w20  2021w8
* evaluated at a level of 0.95.

```

The test statistic is larger than the critical value and we reject the hypothesis of no breaks.
``xtbreak test`` also reports two breaks. 

Next we test the hypothesis of no breaks against 2 breaks using hypothesis 1:

```
xtbreak test ExcessMortality L1.new_cases, hypothesis(1) breaks(2)

Test for multiple breaks at unknown breakdates
(Bai & Perron. 1998. Econometrica)
H0: no break(s) vs. H1: 2 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 supW(tau)          130.10             9.36            7.22            6.28
--------------------------------------------------------------------------------
Estimated break points:  2020w20  2021w8

```

The test statistic is the same, however the critical values are smaller placing a lower bound on the rejection of the hypothesis.

Since we have an estimate of the breakpoints, we can test the two breakpoints 
as known breakpoints:

```
xtbreak test ExcessMortality L1.new_cases, breakpoints(2020w20 2021w8 , fmt(tw))
Test for multiple breaks at known breakdates
(Bai & Perron. 1998. Econometrica)
H0: no breaks vs. H1: 2 break(s)

 W(tau)        =      130.10
 p-value (F)   =        0.00

```

Since we are using a *datelist*, we need to specify the format of it.
*datelist* also has to be the same format as the time identifier.

We have established that we have found 2 breaks. We can test the hypothesis 3, i.e. 2 breaks against the alternative of 3 breaks:

```
xtbreak test ExcessMortality L1.new_cases, hypothesis(3) breaks(3)

Test for multiple breaks at unknown breakpoints
(Bai & Perron. 1998. Econometrica)
H0: 2 vs. H1: 3 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(s+1|s)*           10.26            14.80           11.14            9.41
--------------------------------------------------------------------------------
* s = 2

```

First, note that we have to define in ``breaks()`` the alternative, that is we use ``breaks(3)``. Secondly we cannot reject the hypothesis of 2 breaks.

After testing for breaks thoroughly we can estimate the breaks and construct confidence intervals:

```
xtbreak estimate ExcessMortality L1.new_cases, breaks(2)

 Estimation of break points
                                                           T    =     72
                                                           SSR  =   1519.53
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        16      2020w20                       2020w19        2020w21
  2        56      2021w8                        2021w7         2021w9 
--------------------------------------------------------------------------------


```

If we want to see the index of the confidence interval rather than the date, the option {cmd:showindex} can be used:

```
xtbreak estimate ExcessMortality L1.new_cases, breaks(2) showindex

 Estimation of break points
                                                 T    =     72
                                                 SSR  =   1519.53
----------------------------------------------------------------------
  #      Index     Date                [95% Conf. Interval]
----------------------------------------------------------------------
  1        16      2020w20             15             17
  2        56      2021w8              55             57
----------------------------------------------------------------------

```

We can split the variable L1.new_cases into the different values for each regime using ``estat split``. The variable list is saved in **r(varlist)** and we run a simple OLS regression on it:

```
estat split
New variables created: L_new_cases1 L_new_cases2 L_new_cases3

reg ExcessMortality `r(varlist)'

      Source |       SS           df       MS      Number of obs   =        72
-------------+----------------------------------   F(3, 68)        =    218.95
       Model |  14678.1397         3  4892.71323   Prob > F        =    0.0000
    Residual |  1519.52504        68  22.3459564   R-squared       =    0.9062
-------------+----------------------------------   Adj R-squared   =    0.9020
       Total |  16197.6647        71  228.136123   Root MSE        =    4.7272

------------------------------------------------------------------------------
ExcessMort~y | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
L_new_cases1 |   .1517681   .0106782    14.21   0.000     .1304601    .1730761
L_new_cases2 |   .0284604   .0013397    21.24   0.000     .0257871    .0311337
L_new_cases3 |  -.0034063   .0040829    -0.83   0.407    -.0115537    .0047411
       _cons |   8.910281   .9357773     9.52   0.000     7.042967     10.7776
------------------------------------------------------------------------------

```

Finally, we can draw a scatter plot of the variables with a different colour for each segement. 
The command line is ``estat scatter varlist`` where *varlist* is the independent variable (X), 
the dependent variable is automatically added on the y-axis.

```
xtbreak estimate ExcessMortality L1.new_cases, breaks(2) showindex
estat scatter L.new_cases

```

![scatter-plot](docs/ExcessMortalityCovid.jpg?raw=true "Scatter Plot")


# 7. References

Andrews, D. W. K. (1993).  Tests for Parameter Instability and Structural Change With Unknown Change Point.  Econometrica, 61(4), 821–856. [link](https://www.jstor.org/stable/2951764).

Bai, B. Y. J., & Perron, P. (1998).  Estimating and Testing Linear Models with Multiple Structural Changes.  Econometrica, 66(1), 47–78. [link](http://www.columbia.edu/~jb3064/papers/1998_Estimating_and_testing_linear_models_with_multiple_structural_changes.pdf).

Bai, J., & Perron, P. (2003).  Computation and analysis of multiple structural change models.  Journal of Applied Econometrics, 18(1), 1–22. [link](https://onlinelibrary.wiley.com/doi/full/10.1002/jae.659).

Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing for Multiple Structural Breaks in Panel Data.  [Slides 2020 Swiss Stata User Group Meeting](https://www.stata.com/meeting/switzerland20/slides/Switzerland20_Ditzen.pdf).


Karavias, Y, Narayan P. & Westerlund, J. (2021) Structural breaks in Interactive Effects Panels and the Stock Market Reaction to COVID–19.

# 8. How to install

The latest version of the ***xtbreak*** package can be obtained by typing in Stata:

```
net from https://janditzen.github.io/xtbreak/
``` 

# 9. Questions?

Questions? Feel free to write us an email, open an [issue](https://github.com/JanDitzen/xtbreak/issues) or [start a discussion](https://github.com/JanDitzen/xtbreak/discussions).

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
Ditzen, J, Y. Karavias and J. Westerlund. 2021. xtbreak: Estimating and testing for structural breaks in Stata

