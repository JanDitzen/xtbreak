# xtbreak

## estimating and testing for many known and unknown structural breaks in time series and panel data.

For an overview of **xtbreak test** see [xtbreak test](docs/xtbreak_test.md) and for **xtbreak estimate** see [xtbreak estimate](docs/xtbreak_estimate.md).

Current Version: ![version](https://img.shields.io/github/v/release/janditzen/xtbreak) ![release](https://img.shields.io/github/release-date/janditzen/xtbreak)

Please cite as `Ditzen, J., Karavias, Y. & Westerlund, J. (2025) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. arXiv:2110.14550 [econ.EM].` A working paper describing `xtbreak` is available [here](https://arxiv.org/abs/2110.14550).

A working paper describing the panel data theory of xtbreak is available as `Ditzen, J., Karavias, Y. & Westerlund, J. (2024) Multiple Structural Breaks in Interactive Effects Panel Data Models. Journal of Applied Econometrics` [download](https://onlinelibrary.wiley.com/doi/10.1002/jae.3097).


__Table of Contents__
1. [Syntax](#1-syntax)
2. [Description](#2-description)
3. [Options](#3-options)
4. [Note on Panel Data](#4-note-on-panel-data)
5. [Python](#5-python)
6. [Unbalanced Data](#6-unbalanced-data)
7. [Examples](#7-examples)
8. [References](#8-references)
9. [How to install](#9-how-to-install)
10. [Questions?](#10-questions?)
11. [About](#11-authors)
12. [Changes](#12-changes)

# 1. Syntax

#### Automatic estimation of number and location of break (sequential F-Test)

```
xtbreak depvar [indepvars] [if], 
        options1 options2 options3 options5 options6

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
**vce(type)** | covariance matrix estimator, allowed: ssr, hac, hc and np
**inverter(type)** inverter, default is speed. See options.
**python** use Python to calculated SSRs to improve speed. See details.

#### Options for unknown breakdates

options2 | Description
--- | ---
**trimming(real)** | minimal segment length
**error(real)** | error margin for partial break model

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
**nofixedeffects** | suppresses fixed effects (only for panel data sets)
**breakfixedeffects** | break in fixed effects
**csd** | add cross-section averages of variables with and without breaks.
**csa(varlist)** | Variables with breaks used to calculate cross-sectional averages
**csanobreak(varlist)** | Variables without breaks used to calculate cross-sectional averages
**kfactors(varlist)** | Known factors, which are constant across the cross-sectional dimension but are affected by structural breaks. Examples are seasonal dummies or other observed common factors such as asset returns and oil prices. 
**nbkfactors(varlist)** | same as above but without breaks.
**noreweigh** do not reweigh time-unit specific errors by the number of total observations over actual observations for a given time period in order to increase the SSR of segments of unabalanced panels with missing data.

#### Options for automatic estimation of number and location of break

options6 | Description
--- | ---
**skiph2** | skips hypohesis B
**clevel(#)** | specifies level for critical values to detect breaks.
**strict** | strict behaviour of sequential test. Improves speed.
**maxbreaks(#)** | sets maximum number of breaks for sequential test. Improves speed.


 Data has to be ``xtset`` before using ``xtbreak``. ``depvars``, ``indepvars`` and ``varlist1``, ``varlist2`` may contain time-series operators. 


# 2. Description
**xtbreak test** implements multiple tests for structural breaks in time series and panel data models.  The number and period of occurence of structral breaks can be known and unknown.  In the case of a known    breakpoint xtbreak test can test if the break occurs at a specific point in time.  For unknown breaks, xtbreak test implements three different hypothesises.  The first is no break against the alterantive of *s* breaks, the second hypothesis is no breaks against a lower and upper limit of breaks.  The last hypothesis tests the null of s breaks against the alterantive of one more break *(s+1)*. For more details see [xtbreak test](docs/xtbreak_test.md).

**xtbreak estimate** estimates the break points, that is, it estimates *T1*, *T2*, ..., *Ts*.  The underlying idea is that if the model with the true breakdates given a number of breaks has a smaller sum of squared residuals (SSR) than a model with incorrect breakdates.  To find the breakdates, xtbreak estimate uses the alogorthim (dynamic program) from Bai and Perron (2003).  All necessary SSRs are calculated and then the smalles one selected. For more details see [xtbreak estimate](docs/xtbreak_estimate.md).

**xtbreak** implements the tests for and estimation of structural breaks discussed in Bai & Perron (1998, 2003), Karavias, Narayan, Westerlund (2021) and Ditzen, Karavias, Westerlund (2024).

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
***inverter(type)*** | sets the inverter. type can be:  speed (invsym), precision, qr (equivalent to precision; qrinv), chol (chol), p (pinv), or lu (luinv).  Choice of inverter has implications on speed and precision.  For an overview see [https://www.stata.com/manuals/m-4solvers.pdf]([M-4] solvers).
***python*** |  use Python to calculated SSRs to improve speed.  Requires Stata 16 or later, Python and the following packages: scipy, numpy, pandas and xarray.  
***noreweigh*** | avoids to reweigh time-unit specific errors by the number of total observations over actual observations for a given time period in order to increase the SSR of segments of unabalanced panels with missing data.  Results with this options should be used indicative.  See also section on Unbalanced Panels.
***skiph2*** |  Skips Hypothesis 2 (H0: no break vs H1: \(0 < s < s_{max}\) breaks) when running xtbreak without the estimate or test option.
***cvalue(level)*** |  specifies the level of the critical value to be used to estimate the number of breaks using the sequential test.  For example cvalue(0.99) uses the 1\% critical values to determine the number of breaks using the sequential test.  See level(#) for further details.
***strict*** |  enforces strict behaviour of the sequential test to determine number of breaks.  Sequential test will stop once F(s+1|s) is not rejected given a rejection of F(s|s-1).  Option improves speed in large time series, but should be used with caution.
***maxbreaks(#)*** | limits number of breaks when using the sequential test to determine number of breaks.  Option improves speed in large time series, but should be used with caution.

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

# 5. Python

The option python uses Python to calculate the sum of squared residuals (SSRs) necessary to compute the F-Statistics to estimate the dates of breaks and perform tests for an unknown break date.  The number of possible SSRs can be very large and computation time consuming.  For example, for a model without non-breaking variables, one break (m=1) and a minimal segment length of h=trimming * T, the number of SSRs is: 

```T (T + 1)/2 − (h − 1)T + (h − 2)(h − 1)/2 − h2m(m + 1)/2,```

hence in the order of O(T^2).  Using Python improves the speed of calculations.

Python cannot be combined with unbalanced panels.  It uses the standard inverter from numpy (linalg.inv), the pseudo-inverse (linalg.pinv) or SVD decomposition (scipy.linalg.svd).  Differences between results obtained with and without the Python option may occur for ill-conditioned or (nearly) invertible matrices.

**xtbreak** checks if the Python and required packages (numpy, scipy, xarray and pandas) are installed. The option python can only be used with Stata 16 or later.

# 6. Unbalanced Data

**xtbreak** allows for unbalanced panels when using panel data. Pure time series data (i.e. data with only one cross-section) with gaps is not allowed.  In the case of unbalanced panels, the degree of freedom adjustment for the sup F(s) statistic are adjusted.

While **xtbreak**  kallows for unbalanced data, results should be taken with extra caution. The underlying assumption is that the break dates are the same for all units, including those with gaps in the data.  The break date estimation can be biased if data is very unbalanced, that is if a large number of time periods are missing for multiple units.  Care is also required if estimated breaks coincide with the start or end of unbalanced panels.  We strongly recommend to investigate the SSRs using estat ssr after an estimation with a single break point to identify increases or decreases in the estimated SSRs.

The option noreweigh avoids to reweigh time-individual errors for the calculation of the SSR to artificially increase the SSR of unabalanced sections of the panel. Results with this options should be used indicative.

# 7. Examples

## Time Series

This example was presented in similar form at the Stata Conference [2021](https://www.stata.com/meeting/us21/). We will try to estimate the breakpoints in the relationship between COVID infections in the US and excess from the virus in 2020 and 2021. Weekly data is available on [GitHub](https://github.com/JanDitzen/xtbreak/tree/main/data). The variable *deaths* has the deaths from COVID and the variable **cases** contains the number of new covid cases. The idea is that initally more people died from COVID because it was a new virus. Then medical treatment advanced and vaccines became more available which should decrease deaths. On the other hand COVID cases have likely been underreported during the first wave. We assume that there is a lag between the a positive test and death of one week. The data is from the [CDC](https://data.cdc.gov/Case-Surveillance/United-States-COVID-19-Cases-and-Deaths-by-State-o/9mfq-cb36).

First we load the data into Stata:

```
use  https://github.com/JanDitzen/xtbreak/raw/main/data/US.dta
```

We start with no prior knowledge of i) the number of breaks and ii) the exact date of each break. 
As the data might be non-stationary, we use first differences.
Therefore before estimating the breakpoints we use the sequential F-Test based on hypothesis 2:

```
xtbreak d.deaths d.L(1/3).cases

Test for multiple breaks at unknown breakdates
(Bai & Perron. 1998. Econometrica)
H0: no break(s) vs. H1: 1 <= s <= 5 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 UDmax               28.91             6.09            4.74            4.13
--------------------------------------------------------------------------------

Sequential test for multiple breaks at unknown breakpoints
(Ditzen, Karavias & Westerlund. 2024)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(1|0)              28.51             6.09            4.66            4.03
 F(2|1)               5.47             6.59            5.24            4.64
 F(3|2)               2.78             6.92            5.61            4.99
 F(4|3)               2.70             7.33            5.87            5.23
 F(5|4)              19.84             7.49            6.05            5.45
--------------------------------------------------------------------------------
Detected number of breaks: (min)          1               2               2
                           (max)          5               5               5
--------------------------------------------------------------------------------
Null hypothesis rejected more than once after non-rejection.
 The detected number of breaks indicates the minimum and maximum
 number of breaks for which the null hypothesis is rejected.

Estimation of break points
                                            Number of obs       =     79
                                            SSR                 =     49.07
                                            Trimming            =      0.15
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        15      2020w22                       2020w21        2020w23
  2        45      2020w52                       2020w51        2021w1 
--------------------------------------------------------------------------------

```

We find two breaks, the first in week 22 in 2020 and the second at the end of 2020. We can directly estimate the model with two breaks:

```
xtbreak estimate d.deaths d.L(1/3).cases, breaks(2)

Estimation of break points
                                            Number of obs       =     79
                                            SSR                 =     49.07
                                            Trimming            =      0.15
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        15      2020w22                       2020w21        2020w23
  2        45      2020w52                       2020w51        2021w1 
--------------------------------------------------------------------------------

```

We find the same two break points.

Next we test the hypothesis of no breaks against 2 breaks using hypothesis 1:

```
xtbreak test d.deaths d.L(1/3).cases , hypothesis(1) breaks(2)

Test for multiple breaks at unknown breakdates
(Bai & Perron. 1998. Econometrica)
H0: no break(s) vs. H1: 2 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 supF                19.95             4.82            4.00            3.58
--------------------------------------------------------------------------------
Estimated break points: 2020w22 2020w52
Trimming: 0.15
```
Since we have an estimate of the breakpoints, we can test the two breakpoints 
as known breakpoints:

```
xtbreak test d.deaths d.L(1/3).cases , hypothesis(1) breakpoints(2020W22 2020w52, fmt(tw))
Test for multiple breaks at known breakdates
(Bai & Perron. 1998. Econometrica)
H0: no breaks vs. H1: 2 break(s)

 F             =       19.95
 p-value (F)   =        0.00
```

Since we are using a *datelist*, we need to specify the format of it.
*datelist* also has to be the same format as the time identifier.

We have established that we have found 2 breaks. We can test the hypothesis 3, i.e. 2 breaks against the alternative of 3 breaks:

```
xtbreak test d.deaths d.L(1/3).cases , hypothesis(3) breaks(3)

Test for multiple breaks at unknown breakpoints
(Bai & Perron. 1998. Econometrica)
H0: 2 vs. H1: 3 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(s+1|s)*            2.78             6.92            5.61            4.99
--------------------------------------------------------------------------------
* s = 2
Trimming: 0.15


```

First, note that we have to define in ``breaks()`` the alternative, that is we use ``breaks(3)``. Secondly we can not reject the hypothesis of 2 breaks. 

To allow for a break in the constant as well, the ``breakconstant`` option can be used:

```
xtbreak test d.deaths d.L(1/3).cases , hypothesis(1) breaks(2) breakconstant

Test for multiple breaks at unknown breakdates
(Bai & Perron. 1998. Econometrica)
H0: no break(s) vs. H1: 2 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 supF                16.27             4.14            3.44            3.15
--------------------------------------------------------------------------------
Estimated break points: 2020w23 2020w52
Trimming: 0.15
```

To test if there is only a break in the constant and the cases are nobreaking, the variables are added into the ``nobreakvar()`` option:

```
xtbreak test d.deaths  , hypothesis(1) breaks(2) breakconstant nobreakvar(d.L(1/3).cases)

Test for multiple breaks at unknown breakdates
(Bai & Perron. 1998. Econometrica)
H0: no break(s) vs. H1: 2 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 supF                 4.57             9.36            7.22            6.28
--------------------------------------------------------------------------------
Estimated break points: 2020w18 2020w29
Trimming: 0.15
```

There is no evidence for breaks in the constant only.

After estimation, we can split the breaking variable using ``estat split`` and then run a OLS regression:

```
xtbreak estimate d.deaths d.L(1/3).cases, breaks(2)

 estat split
New variables created: LD_cases1 LD_cases2 LD_cases3 L2D_cases1 L2D_cases2 L2D_cases3 L3D_cases1 L3D_cases2 L3D_cases3

. reg deaths `r(varlist)'

      Source |       SS           df       MS      Number of obs   =        79
-------------+----------------------------------   F(9, 69)        =      1.91
       Model |  596.717902         9  66.3019891   Prob > F        =    0.0649
    Residual |  2396.27612        69  34.7286394   R-squared       =    0.1994
-------------+----------------------------------   Adj R-squared   =    0.0949
       Total |  2992.99402        78  38.3717182   Root MSE        =    5.8931

------------------------------------------------------------------------------
      deaths | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
   LD_cases1 |  -.0240564   .0665594    -0.36   0.719    -.1568387    .1087259
   LD_cases2 |  -.0087608   .0107619    -0.81   0.418    -.0302303    .0127087
   LD_cases3 |  -.0055262   .0084372    -0.65   0.515    -.0223578    .0113055
  L2D_cases1 |   .0533405    .084872     0.63   0.532    -.1159745    .2226556
  L2D_cases2 |   .0147102   .0128244     1.15   0.255    -.0108738    .0402942
  L2D_cases3 |  -.0045495   .0090462    -0.50   0.617    -.0225961    .0134971
  L3D_cases1 |   .0808952   .0675054     1.20   0.235    -.0537745    .2155649
  L3D_cases2 |   .0297254   .0120054     2.48   0.016     .0057753    .0536754
  L3D_cases3 |  -.0033342   .0081565    -0.41   0.684     -.019606    .0129375
       _cons |   7.041891   .7204465     9.77   0.000      5.60464    8.479143
------------------------------------------------------------------------------
```

Finally, we can draw a scatter plot of the variables with a different colour for each segement. 
The command line is ``estat scatter varlist`` where *varlist* is the independent variable (X), 
the dependent variable is automatically added on the y-axis.

![scatter-plot](docs/DeathsScatter.jpg?raw=true "Scatter Plot")

With a bit more of codeing, see [example.do](https://github.com/JanDitzen/xtbreak/tree/main/examples/xtbreak_example.do), we can create a plot with confidence intervals and indicate the different regimes:

![scatter-plot](docs/DeathsEstCI.png?raw=true "Confidence Intervals")


## Panel Exampels

We are using a dataset with the same variables as above, but on US State level. 
First we load the dataset:

```
use https://github.com/JanDitzen/xtbreak/raw/main/data/US_panel.dta
```
As before, we start with the sequential F-Test and the estimation of the break dates. We use the heterosekdastic standard errors and a trimming of 1%. Otherwise the syntax remains the same. ``xtbreak`` automatically detects if a panel or time series is used. 

```
xtbreak d.deaths d.L(1/3).cases, vce(hc) trim(0.1) 

Test for multiple breaks at unknown breakdates
(Ditzen, Karavias & Westerlund. 2024)
H0: no break(s) vs. H1: 1 <= s <= 9 break(s)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 UDmax               13.60             6.25            4.95            4.42
--------------------------------------------------------------------------------

Sequential test for multiple breaks at unknown breakpoints
(Ditzen, Karavias & Westerlund. 2024)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(1|0)              11.90             6.24            4.87            4.26
 F(2|1)               9.31             6.78            5.51            4.85
 F(3|2)               8.50             7.20            5.81            5.21
 F(4|3)              10.76             7.45            5.99            5.49
 F(5|4)               1.14             7.65            6.20            5.65
 F(6|5)               4.82             7.79            6.34            5.78
 F(7|6)               1.24             7.84            6.42            5.89
 F(8|7)               2.20             7.90            6.54            5.98
 F(9|8)               2.44             7.93            6.65            6.12
--------------------------------------------------------------------------------
Detected number of breaks:                4               4               4
--------------------------------------------------------------------------------
The detected number of breaks indicates the highest number of
 breaks for which the null hypothesis is rejected.

Estimation of break points
                                            Number of obs       =   4740
                                            Number of Groups    =     60
                                            Obs per group       =     79
                                            SSR                 =     13.88
                                            Trimming            =      0.10
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        7       2020w14                       2020w13        2020w15
  2        14      2020w21                       2020w20        2020w22
  3        46      2021w1                        2020w52        2021w2 
  4        53      2021w8                        2021w7         2021w9 
--------------------------------------------------------------------------------

```

As there might be cross-sectional dependence presence, we add cross-sectional averages und use standard errors from Westerlund, Petrova and Norkute (2019):

```
 xtbreak d.deaths d.L(1/3).cases,  csa(d.l.cases) vce(wpn) trim(0.1) skiph2

Sequential test for multiple breaks at unknown breakpoints
(Ditzen, Karavias & Westerlund. 2024)

                ----------------- Bai & Perron Critical Values -----------------
                     Test          1% Critical     5% Critical    10% Critical
                  Statistic          Value            Value           Value
--------------------------------------------------------------------------------
 F(1|0)               6.32             6.24            4.87            4.26
 F(2|1)              68.68             6.78            5.51            4.85
 F(3|2)              73.44             7.20            5.81            5.21
 F(4|3)               9.10             7.45            5.99            5.49
 F(5|4)               4.50             7.65            6.20            5.65
 F(6|5)              13.82             7.79            6.34            5.78
 F(7|6)              10.33             7.84            6.42            5.89
 F(8|7)              10.40             7.90            6.54            5.98
 F(9|8)               8.04             7.93            6.65            6.12
--------------------------------------------------------------------------------
Detected number of breaks: (min)          4               4               4
                           (max)          9               9               9
--------------------------------------------------------------------------------
Null hypothesis rejected more than once after non-rejection.
 The detected number of breaks indicates the minimum and maximum
 number of breaks for which the null hypothesis is rejected.

Estimation of break points
                                            Number of obs       =   4740
                                            Number of Groups    =     60
                                            Obs per group       =     79
                                            SSR                 =     10.89
                                            Trimming            =      0.10
--------------------------------------------------------------------------------
  #      Index     Date                          [95% Conf. Interval]
--------------------------------------------------------------------------------
  1        7       2020w14                       2020w13        2020w15
  2        14      2020w21                       2020w20        2020w22
  3        45      2020w52                       2020w51        2021w1 
  4        53      2021w8                        2021w7         2021w9 
--------------------------------------------------------------------------------
Cross-section averages:
  with breaks: LD.cases

```

The estimated break dates remain the same.


# 8. References

Andrews, D. W. K. (1993).  Tests for Parameter Instability and Structural Change With Unknown Change Point.  Econometrica, 61(4), 821–856. [link](https://www.jstor.org/stable/2951764).

Bai, B. Y. J., & Perron, P. (1998).  Estimating and Testing Linear Models with Multiple Structural Changes.  Econometrica, 66(1), 47–78. [link](http://www.columbia.edu/~jb3064/papers/1998_Estimating_and_testing_linear_models_with_multiple_structural_changes.pdf).

Bai, J., & Perron, P. (2003).  Computation and analysis of multiple structural change models.  Journal of Applied Econometrics, 18(1), 1–22. [link](https://onlinelibrary.wiley.com/doi/full/10.1002/jae.659).

Ditzen, J., Karavias, Y. & Westerlund, J. (2024) Testing for Multiple Structural Breaks in Panel Data. Journal of Applied Econometrics [link](https://onlinelibrary.wiley.com/doi/full/10.1002/jae.3097)

Ditzen, J., Karavias, Y. & Westerlund, J. (2025) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. arXiv:2110.14550 [econ.EM]. [link](https://arxiv.org/abs/2110.14550).

Karavias, Y, Narayan P. & Westerlund, J. (2021) Structural breaks in Interactive Effects Panels and the Stock Market Reaction to COVID–19. arXiv:2111.03035 [econ.EM]. [link](https://arxiv.org/abs/2111.03035)

Westerlund, J., Petrova, Y., & Norkute, M. (2019).  CCE in fixed-T panels.  Journal of Applied Econometrics, 34(5), 1–16. [link](https://onlinelibrary.wiley.com/doi/10.1002/jae.2707)

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


# 10. Questions?

Questions? Feel free to write us an email, open an [issue](https://github.com/JanDitzen/xtbreak/issues) or [start a discussion](https://github.com/JanDitzen/xtbreak/discussions).

# 11. Authors

#### Jan Ditzen (Free University of Bozen-Bolzano)

Email: jan.ditzen@unibz.it

Web: www.jan.ditzen.net

### Yiannis Karavias (Brunel University)

Email: yiannis.karavias@brunel.ac.uk

Web: https://sites.google.com/site/yianniskaravias/

### Joakim Westerlund (Lund University)

Email: joakim.westerlund@nek.lu.se

Web: https://sites.google.com/site/perjoakimwesterlund/

## Please cite as follows:
Ditzen, J., Karavias, Y. & Westerlund, J. (2025) Testing and Estimating Structural Breaks in Time Series and Panel Data in Stata. arXiv:2110.14550 [econ.EM].

# 12. Changes

Changed to 2.1
- Bugfix using hypothesis 2 and min and max number of breaks.

Changed to 2.0
- Bugfixes in dynamic program, partial break model and variance estimator.
- Added options inverter(), skiph2, strict, maxbreaks(), python and allow for unbalanced panels.

Changed to 1.5
- additional checks if breaks and trimming are valid

Changed to 1.4
- bug fixes

Changed to 1.3
- fixed error when using fixed effects
- fixed error when using vce(hac) on time series data

Changes 1.1 to 1.11:
- fixed error when using Stata 15 and xtbreak, seq (thanks to Zachary Elkins).

Changes 1.0 to 1.1:
- added min and max to sequential test
- bug when variable name contained "est"
- error in scaling critical values (ts + xt) and test statistic (ts + xt) when using hypothesis 3

Changes 0.02 to 1.0:
- fixed error in wdmax test. Used wrong critical values.
- added sequential F-Test and general xtbreak y x syntax.
- bug fixes in var/cov estimators.
