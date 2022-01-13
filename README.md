# xtbreak

## estimating and testing for many known and unknown structural breaks in time series and panel data.

For an overview of **xtbreak test** see [xtbreak test](docs/xtbreak_test.md) and for **xtbreak estimate** see [xtbreak estimate](docs/xtbreak_estimate.md).

Current Version: **1.1** (10.01.2022)

Please cite as `Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. arXiv:2110.14550 [econ.EM].` A working paper describing `xtbreak` is available [here](https://arxiv.org/abs/2110.14550).

__Table of Contents__
1. [Syntax](#1-syntax)
2. [Description](#2-description)
3. [Options](#3-options)
4. [Note on Panel Data](#4-note-on-panel-data)
5. [Examples](#5-examples)
6. [References](#6-references)
7. [How to install](#7-how-to-install)
8. [Citations](#8-citations)
9. [Questions?](#9-questions?)
10. [About](#10-authors)
11. [Changes](#11-changes)

# 1. Syntax

#### Automatic estimation of number and location of break (sequential F-Test)

```
xtbreak depvar [indepvars] [if], 
        options1 options5 

```


#### Testing for known structural breaks:

```
xtbreak test depvar [indepvars] [if], 
        breakpoints(numlist| datelist [,index| fmt(string)]) options1 options5
```

***breakpoints()*** specifies the time period of the known structural break.

#### Testing for unknown structural breaks:

```
xtbreak test depvar [indepvars] [if], 
        hypothesis(1|2|3) breaks(#) options1 options2 options3 options4 options5
```

***hypothesis(1\2\3)*** specifies which hypothesis to test, see hypothesises. ***breaks(#)*** sets the number of breaks.

#### Estimation of breakpoints

```
xtbreak estimate depvar [indepvars] [if], breaks(#) showindex options1 options2 options5
```

#### General Options

options1 | Description
--- | ---
**breakconstant** | break in constant
**noconstant** | suppresses constant
**nobreakvariables(varlist1)** | variables with no structural break(s)
**vce(type)** | covariance matrix estimator, allowed: ssr, hac, np and nw

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
***csd*** | add cross-section averages of variables with and without breaks.
***csa(varlist)*** | Variables with breaks used to calculate cross-sectional averages
***csanobreak(varlist)*** | Variables without breaks used to calculate cross-sectional averages
***kfactors(varlist)*** | Known factors, which are constant across the cross-sectional dimension but are affected by structural breaks. Examples are seasonal dummies or other observed common factors such as asset returns and oil prices. 
***nbkfactors(varlist)*** | same as above but without breaks.

 Data has to be ``xtset`` before using ``xtbreak``. ``depvars``, ``indepvars`` and ``varlist1``, ``varlist2`` may contain time-series operators. Data has to be balanced.


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
***breakpoints(numlist\datelist [,index\fmt(format)])*** |  specifies the known breakpoints.  Known breakpoints can be set by either the number of observation or by the value of the time identifier.  If a numlist is used, option index is required.  For example ***breakpoints(10,index)*** specifies that the one break occurs at the 10th observation in time.  datelist takes a list of dates.  For example ``breakpoints(2010Q1) , fmt(tq)`` specifies a break in Quarter 1 in 2010.  The option ***fmt()*** specifies the format and is required if a datelist is used.  The format set in **breakpoints()** and the time identifier needs to be the same. 
***breaks(#)*** |  specifies the number of unknwon breaks under the alternative. For hypothesis 2, ***breaks()*** can take two values, for example breaks(4 6) test for no breaks against 4-6 breaks.  If only one value specfied, then the lower limit is set to 1. If ``h(3)`` and ``sequential`` is used, then ``breaks()`` defines the maximum number of breaks tested for.
***showindex*** | show confidence intervals as index.
***hypothesis(1\2\3)*** | specifies which hypothesis to test. *h(1)* test for no breaks vs. s breaks, *h(2)* for no break vs. s0 <= s <= s1 breaks and *h(3)* for s vs. s+1 breaks. Hypothesis 3 is the default.
***sequential*** | sequential F-Test to determin number of breaks.  The number of breaks is varied from s = 0 to breaks()-1 or floor(1/trimming).
***breakconstant*** | break in constant.  Default is no breaks in deterministics.
***noconstant*** | suppresses constant.
***nofixedeffects*** | suppresses individual fixed effects.
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
Fixed Effects (nobreak) | y(i,t) =  a(i) + b1 x(i,t) +s1(s) z(i,t,s) + e(it)  
Fixed Effects(break) |  y(i,t) =  a(i,s) + b1 x(i,t) +s1(s) z(i,t,s) + e(it)    (```breakfixedeffects```)  
Pooled OLS (nobreak)     | y(i,t) =  b0 + b1 x(i,t) +s1(s) z(i,t,s) + e(it)     (```nofixedeffects```)
Pooled OLS (break)     | y(i,t) =  b1 x(i,t) +s0(s) + s1(s) z(i,t,s) + e(it)  (```nofixedeffects breakconstant```)
No FE or POLS   | y(i,t) =  b1 x(i,t) + s1(s) z(i,t,s) + e(it)         (```nofixedeffects noconstant```)

where b0 is the pooled constant without break, a(i) the fixed effects, b(1) a coefficient without break, s0(s) a pooled constant with break and s1(s) a coefficient with break.

In the estimation of the breakpoints, cross-sectional averages are not taken into account.

# 5. Examples

## Time Series

This example was presented in similar form at the Stata Conference [2021](https://www.stata.com/meeting/us21/). We will try to estimate the breakpoints in the relationship between COVID infections in the US and excess from the virus in 2020 and 2021. Weekly data is available on [GitHub](https://github.com/JanDitzen/xtbreak/tree/main/data). The variable *deaths* has the deaths from COVID and the variable **cases** contains the number of new covid cases. The idea is that initally more people died from COVID because it was a new virus. Then medical treatment advanced and vaccines became more available which should decrease deaths. On the other hand COVID cases have likely been underreported during the first wave. We assume that there is a lag between the a positive test and death of one week. The data is from the [CDC](https://data.cdc.gov/Case-Surveillance/United-States-COVID-19-Cases-and-Deaths-by-State-o/9mfq-cb36).

First we load the data into Stata:

```
use  https://github.com/JanDitzen/xtbreak/raw/main/data/US.dta
```

We start with no prior knowledge of i) the number of breaks and ii) the exact date of each break. 
Therefore before estimating the breakpoints we use the sequential F-Test based on hypothesis 2:

```
xtbreak deaths L.cases

Sequential test for multiple breaks at unknown breakpoints
(Ditzen, Karavias & Westerlund. 2021)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(1|0)             111.74            12.29            8.58            7.04
 F(2|1)              65.88            13.89           10.13            8.51
 F(3|2)              22.32            14.80           11.14            9.41
 F(4|3)               5.11            15.28           11.83           10.04
 F(5|4)              27.28            15.76           12.25           10.58
--------------------------------------------------------------------------------
Detected number of breaks: (min)          3               3               3
                           (max)          5               5               5
--------------------------------------------------------------------------------
Null hypothesis rejected more than once after non-rejection.
 The detected number of breaks indicates the minimum and maximum
 number of breaks for which the null hypothesis is rejected.

Estimation of break points
                                                           T    =     82
                                                           SSR  =    148.42
                                                      Trimming  =      0.15
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        16      2020w20                       2020w19        2020w21
  2        47      2020w51                       2020w19        2021w31
  3        59      2021w11                       2021w10        2021w12
--------------------------------------------------------------------------------
```

We find three breaks, the first in week 20 in 2020 , the second at the end of 2020 and the third in week 11 in 2021. The second break has however large confidence intervals. This indicates that the change in the coefficients is small. We estimate the model with two breaks:

```
xtbreak estimate deaths L1.cases, breaks(2)

Estimation of break points
                                                           T    =     82
                                                           SSR  =    226.85
                                                      Trimming  =      0.15
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        16      2020w20                       2020w19        2020w21
  2        59      2021w11                       2021w9         2021w13
--------------------------------------------------------------------------------
```

We find the same two break points.

Next we test the hypothesis of no breaks against 2 breaks using hypothesis 1:

```
xtbreak test deaths L1.cases, hypothesis(1) breaks(2)

Test for multiple breaks at unknown breakdates
(Bai & Perron. 1998. Econometrica)
H0: no break(s) vs. H1: 2 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 supW(tau)          134.70             9.36            7.22            6.28
--------------------------------------------------------------------------------
Estimated break points:  2020w20 2021w11
Trimming: 0.15

```

The test statistic is the same, however the critical values are smaller placing a lower bound on the rejection of the hypothesis.

Since we have an estimate of the breakpoints, we can test the two breakpoints 
as known breakpoints:

```
xtbreak test deaths L1.cases, breakpoints(2020w20 2021w8 , fmt(tw))
Test for multiple breaks at known breakdates
(Bai & Perron. 1998. Econometrica)
H0: no breaks vs. H1: 2 break(s)

 W(tau)        =      116.95
 p-value (F)   =        0.00

```

Since we are using a *datelist*, we need to specify the format of it.
*datelist* also has to be the same format as the time identifier.

We have established that we have found 2 breaks. We can test the hypothesis 3, i.e. 2 breaks against the alternative of 3 breaks:

```
xtbreak test deaths L1.cases, hypothesis(3) breaks(3)

Test for multiple breaks at unknown breakpoints
(Bai & Perron. 1998. Econometrica)
H0: 2 vs. H1: 3 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(s+1|s)*           22.32            14.80           11.14            9.41
--------------------------------------------------------------------------------
* s = 2
Trimming: 0.15
```

First, note that we have to define in ``breaks()`` the alternative, that is we use ``breaks(3)``. Secondly we can not reject the hypothesis of 2 breaks. However as discussed before, the 3rd break is very small. Using panel data models might add further information and improve the estimation.

So far we have assumed no break in the constant, only in the number of COVID cases. We can test for only a break in the constant and keep the coefficient of the cases fixed. To do so, the options ``nobreakvar(L.cases)`` and ``breakconstant`` are required.

```
xtbreak test deaths , breakconstant nobreakvar(L1.cases) breaks(3) h(1)

Test for multiple breaks at unknown breakdates
(Bai & Perron. 1998. Econometrica)
H0: no break(s) vs. H1: 3 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 supW(tau)           20.00             7.60            5.96            5.21
--------------------------------------------------------------------------------
Estimated break points:  2020w21 2020w46  2021w8
Trimming: 0.15

```

After testing for breaks thoroughly we can estimate the breaks and construct confidence intervals:

```
xtbreak estimate deaths L1.cases, breaks(2)

Estimation of break points
                                                           T    =     82
                                                           SSR  =    226.85
                                                      Trimming  =      0.15
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        16      2020w20                       2020w19        2020w21
  2        59      2021w11                       2021w9         2021w13
--------------------------------------------------------------------------------
```

If we want to see the index of the confidence interval rather than the date, the option {cmd:showindex} can be used:

```
xtbreak estimate deaths L1.cases, breaks(2) showindex

Estimation of break points
                                                 T    =     82
                                                 SSR  =    226.85
                                            Trimming  =      0.15
----------------------------------------------------------------------
  #      Index     Date                [95% Conf. Interval]
----------------------------------------------------------------------
  1        16      2020w20             15             17
  2        59      2021w11             57             61
----------------------------------------------------------------------
```

We can split the variable L1.cases into the different values for each regime using ``estat split``. The variable list is saved in **r(varlist)** and we run a simple OLS regression on it:

```

. estat split
New variables created: L_cases1 L_cases2 L_cases3

. reg deaths `r(varlist)'

      Source |       SS           df       MS      Number of obs   =        82
-------------+----------------------------------   F(3, 78)        =    338.24
       Model |  2951.18975         3  983.729918   Prob > F        =    0.0000
    Residual |  226.851495        78   2.9083525   R-squared       =    0.9286
-------------+----------------------------------   Adj R-squared   =    0.9259
       Total |  3178.04125        81  39.2350771   Root MSE        =    1.7054

------------------------------------------------------------------------------
      deaths | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
    L_cases1 |   .0589407   .0036153    16.30   0.000     .0517433    .0661381
    L_cases2 |   .0136155     .00045    30.26   0.000     .0127196    .0145114
    L_cases3 |   .0064061   .0009669     6.63   0.000     .0044812    .0083311
       _cons |   1.304738   .3097613     4.21   0.000      .688051    1.921426
------------------------------------------------------------------------------

```

Finally, we can draw a scatter plot of the variables with a different colour for each segement. 
The command line is ``estat scatter varlist`` where *varlist* is the independent variable (X), 
the dependent variable is automatically added on the y-axis.

```
xtbreak estimate deaths L1.cases, breaks(2) showindex
estat scatter L.cases

```

![scatter-plot](docs/DeathsScatter.jpg?raw=true "Scatter Plot")

With a bit more of codeing, see [example.do](https://github.com/JanDitzen/xtbreak/tree/main/examples/xtbreak_example.do), we can create a plot with confidence intervals:

![scatter-plot](docs/DeathsEstCI.png?raw=true "Confidence Intervals")

## Panel Exampels

We are using a dataset with the same variables as above, but on US State level. 
First we load the dataset:

```
use https://github.com/JanDitzen/xtbreak/raw/main/data/US_panel.dta
```
As before, we start with the sequential F-Test and the estimation of the break dates. We account for heteroskedasticity and autocorrelation by using an HAC robust variance estimator with the option vce(hac). Otherwise the syntax remains the same. ``xtbreak`` automatically detects if a panel or time series is used. 

```
xtbreak deaths L.cases, vce(hac)

Sequential test for multiple breaks at unknown breakpoints
(Ditzen, Karavias & Westerlund. 2021)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(1|0)              29.59            12.29            8.58            7.04
 F(2|1)              37.75            13.89           10.13            8.51
 F(3|2)              10.88            14.80           11.14            9.41
 F(4|3)              21.38            15.28           11.83           10.04
 F(5|4)               8.29            15.76           12.25           10.58
--------------------------------------------------------------------------------
Detected number of breaks: (min)          2               2               4
                           (max)          4               4               4
--------------------------------------------------------------------------------
Null hypothesis rejected more than once after non-rejection.
 The detected number of breaks indicates the minimum and maximum
 number of breaks for which the null hypothesis is rejected.

Estimation of break points
                                                           N    =     60
                                                           T    =     82
                                                           SSR  =     52.33
                                                      Trimming  =      0.15
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        15      2020w19                       2020w18        2020w20
  2        59      2021w11                       2021w10        2021w12
--------------------------------------------------------------------------------
```

We find evidence for 2 and 4 breaks. ``xtbreak`` displays the number of breaks the first time the hypothesis is not rejected, in this case 2 breaks. As this is a panel data set, we account for cross-section dependence as well using ``csa(L.cases)`` and we set the minimal length to 10% with ``minlength(0.1)``:

```
xtbreak deaths L.cases, vce(hac) csa(L.cases) trimming(0.1)

Sequential test for multiple breaks at unknown breakpoints
(Ditzen, Karavias & Westerlund. 2021)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(1|0)              10.80            13.00            9.10            7.42
 F(2|1)               8.10            14.51           10.55            9.05
 F(3|2)              12.77            15.44           11.36            9.97
 F(4|3)               4.47            15.73           12.35           10.49
 F(5|4)               9.27            16.39           12.97           10.91
 F(6|5)               5.22            16.60           13.45           11.29
 F(7|6)               5.05            16.78           13.88           11.86
 F(8|7)               5.61            16.90           14.12           12.26
 F(9|8)               4.89            16.99           14.45           12.57
--------------------------------------------------------------------------------
Detected number of breaks: (min)          .               1               1
                           (max)          .               3               3
--------------------------------------------------------------------------------
Null hypothesis rejected more than once after non-rejection.
 The detected number of breaks indicates the minimum and maximum
 number of breaks for which the null hypothesis is rejected.

Estimation of break points
                                                           N    =     60
                                                           T    =     82
                                                           SSR  =     54.06
                                                      Trimming  =      0.10
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        15      2020w19                       2020w18        2020w20
--------------------------------------------------------------------------------
Cross-section averages:
  with breaks: L.cases
```

Using this we observe that the values of the test stastic across all F-Statistics are relatively low. We are never able to reject the hypothesis of no break at a level of 1\%. Using a level of 5\%, we are able to reject F(1|0) and F(3|2), which implies either no break (indicated by .), 1 break or 3 breaks. We will investigate this next.

We test the null of no breaks against up to 5 breaks and abbreviate hypothesis with ``h``:

```
xtbreak test deaths L.cases, h(2) breaks(5) trim(0.1) vce(hac) csa(L.cases)

T
Test for multiple breaks at unknown breakdates
(Ditzen, Karavias & Westerlund. 2021)
H0: no break(s) vs. H1: 1 <= s <= 5 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 UDmax(tau)          12.20            13.07            9.52            8.05
--------------------------------------------------------------------------------
* evaluated at a level of 0.95.
Trimming: 0.10
Cross-section averages:
  with breaks: L.cases

```

We find evidence for breaks, thus we are going to test the alternatives of one and three breaks:

```
xtbreak test deaths L.cases, h(1) breaks(1) trim(0.1) vce(hac) csa(L.cases)

Test for multiple breaks at known breakdates
(Karavias, Narayan & Westerlund. 2021)
H0: no break(s) vs. H1: 1 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 supW(tau)           10.80            13.00            9.10            7.42
--------------------------------------------------------------------------------
Estimated break points:  2020w19
Trimming: 0.10
Cross-section averages:
  with breaks: L.cases

```

and

```
xtbreak test deaths L.cases, h(1) breaks(3) trim(0.1) vce(hac) csa(L.cases)

Test for multiple breaks at unknown breakdates
(Ditzen, Karavias & Westerlund. 2021)
H0: no break(s) vs. H1: 3 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 supW(tau)           12.20             8.42            6.84            6.09
--------------------------------------------------------------------------------
Estimated break points:  2020w19 2020w51  2021w9
Trimming: 0.10
Cross-section averages:
  with breaks: L.cases

```

Given that we are just about to reject the null hypothesis in the case of 1 break, we will assume 3 breaks. Next we are going to estimate the break points and run a fixed effects regression:

```
xtbreak estimate deaths L.cases, breaks(3) trim(0.1) vce(hac) csa(L.cases)

Estimation of break points
                                                           N    =     60
                                                           T    =     82
                                                           SSR  =     25.99
                                                      Trimming  =      0.10
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        15      2020w19                       2020w18        2020w20
  2        47      2020w51                       2020w50        2020w52
  3        57      2021w9                        2021w8         2021w10
--------------------------------------------------------------------------------
Cross-section averages:
  with breaks: L.cases


estat split L.cases
New variables created: L_cases1 L_cases2 L_cases3 L_cases4

xtreg deaths `r(varlist)', fe

Fixed-effects (within) regression               Number of obs     =      4,920
Group variable: ID                              Number of groups  =         60

R-squared:                                      Obs per group:
     Within  = 0.8144                                         min =         82
     Between = 0.9721                                         avg =       82.0
     Overall = 0.8565                                         max =         82

                                                F(4,4856)         =    5325.62
corr(u_i, Xb) = 0.3305                          Prob > F          =     0.0000

------------------------------------------------------------------------------
      deaths | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
    L_cases1 |   .0745328   .0008793    84.76   0.000      .072809    .0762566
    L_cases2 |   .0123852   .0001553    79.77   0.000     .0120808    .0126895
    L_cases3 |   .0157277    .000136   115.67   0.000     .0154611    .0159942
    L_cases4 |   .0077951   .0002327    33.50   0.000     .0073389    .0082512
       _cons |   .0172031   .0018211     9.45   0.000     .0136328    .0207734
-------------+----------------------------------------------------------------
     sigma_u |  .03534295
     sigma_e |  .10880368
         rho |  .09544505   (fraction of variance due to u_i)
------------------------------------------------------------------------------
F test that all u_i=0: F(59, 4856) = 7.29                    Prob > F = 0.0000

```

# 6. References

Andrews, D. W. K. (1993).  Tests for Parameter Instability and Structural Change With Unknown Change Point.  Econometrica, 61(4), 821–856. [link](https://www.jstor.org/stable/2951764).

Bai, B. Y. J., & Perron, P. (1998).  Estimating and Testing Linear Models with Multiple Structural Changes.  Econometrica, 66(1), 47–78. [link](http://www.columbia.edu/~jb3064/papers/1998_Estimating_and_testing_linear_models_with_multiple_structural_changes.pdf).

Bai, J., & Perron, P. (2003).  Computation and analysis of multiple structural change models.  Journal of Applied Econometrics, 18(1), 1–22. [link](https://onlinelibrary.wiley.com/doi/full/10.1002/jae.659).

Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing for Multiple Structural Breaks in Panel Data. Available upon request. 

Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. arXiv:2110.14550 [econ.EM]. [link](https://arxiv.org/abs/2110.14550).

Karavias, Y, Narayan P. & Westerlund, J. (2021) Structural breaks in Interactive Effects Panels and the Stock Market Reaction to COVID–19. arXiv:2111.03035 [econ.EM]. [link](https://arxiv.org/abs/2111.03035)

## Slides
1. [Slides 2020 Swiss Stata User Group Meeting](https://www.stata.com/meeting/switzerland20/slides/Switzerland20_Ditzen.pdf)
2. [Slides 2021 German Stata User Group Meeting](https://www.stata.com/meeting/germany21/slides/Germany21_Ditzen.pdf)
3. [Slides 2021 US Stata Conference](https://www.stata.com/meeting/us21/slides/US21_Ditzen.pdf)


# 7. How to install

The latest version of the ***xtbreak*** package can be obtained by typing in Stata:

```
net from https://janditzen.github.io/xtbreak/
``` 

``xtbreak`` requires Stata 15 or newer.


# 8. Citations

``xtbreak`` has been used in:

1. Regulator, E., Fallon, J., Cunningham, M. and da Silva Rosa, R., 2021. Methodological issues in estimating the equity beta for Australian network energy businesses. [Link](https://www.aer.gov.au/system/files/Report%20to%20the%20AER%20-%20Methodological%20issues%20in%20estimating%20the%20equity%20beta%20for%20Australian%20network%20energy%20businesses%20-%2030%20June%202021.pdf)

2. Gabriel Chodorow-Reich, Adam M. Guren, and Timothy J. McQuade, 2021. "The 2000s Housing Cycle With 2020 Hindsight: A Neo-Kindlebergerian View". NBER Working Paper No. 29140. [Link](https://www.nber.org/papers/w29140)

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
Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. arXiv:2110.14550 [econ.EM].

# 11. Changes

This version 1.1 - 10.01.2022
Changes 1.0 to 1.01:
- added min and max to sequential test
- bug when variable name contained "est"
- error in scaling critical values (ts + xt) and test statistic (ts + xt) when using hypothesis 3

Changes 0.02 to 1.0:
- fixed error in wdmax test. Used wrong critical values.
- added sequential F-Test and general xtbreak y x syntax.
- bug fixes in var/cov estimators.
