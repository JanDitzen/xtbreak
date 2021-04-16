Jan Ditzen
==========

16 Apr 2021

          --------------------------------------------------------------------------------------------------------------------------------------------------------
          help xtbreak                                                                                                                    v. 0.01 - xx. xxxxx 2021

          --------------------------------------------------------------------------------------------------------------------------------------------------------
          Title

              xtbreak - estimating and testing for many known and unknown structural breaks in time series and panel data.

          Syntax

              Testing for known structural breaks:

              xtbreak test depvar [indepvars] [if] [in] , breakpoints(numlist| datelist [,index]) options1

                  breakpoints(numlist[,index]) specifies the time period of the known structural break.

              Testing for unknown structural breaks:

              xtbreak test depvar [indepvars] [if] [in] , hypothesis(1|2|3) breaks(#) options1 options2 options3

                  hypothesis(1|2|3) specifies which hypothesis to test, see hypothesises.  breaks(#) sets the number of breaks.

          INCLUDE help xtbreak_options

          Contents

              Description
              Options


          Description
              xtbreak test implements multiple tests for structural breaks in time series and panel data models.  The number and period of occurence of structral
              breaks can be known and unknown.  In the case of a known breakpoint xtbreak test can test if the break occurs at a specific point in time.  For
              unknown breaks, xtbreak test implements three different hypothesises.  The first is no break against the alterantive of s breaks, the second
              hypothesis is no breaks against a lower and upper limit of breaks.  The last hypothesis tests the null of s breaks against the alterantive of one
              more break (s+1).

              xtbreak test implements the tests for structural breaks discussed in Bai & Perron (1998, 2003, Karavias, Narayan, Westerlund (2021) and Ditzen,
              Karavias, Westerlund (2021).

              For the remainder we assume the following model:

                  y(i,t) = sigma0(1) + sigma1(1) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = 1,...,T1
                  y(i,t) = sigma0(2) + sigma1(2) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = T1+1,...,T2
                  ...
                  y(i,t) = sigma0(s) + sigma1(s) z(i,t) + beta0(1,i) + beta1 x(i,t) + e(it) for t = Ts,...,T

              where s is the number of the segment/breaks, z(i,t) is a NT1xq matrix containing the variables whose relationship with y breaks.  A break in the
              constant is possible.  x(i,t) is a NTxp matrix with variables without a break.  sigma0(s), sigma1(s) are the coefficients with structural breaks and
              T1,...,Ts are the periods of the breakpoints.


              Testing a known break point

              Assume that the numbers of breaks and their occurence is known.  xtbreak test can test the breakpoints.  The F-Statistic for the test with s breaks
              at known dates is:

                  F(s,q) = dof_adj sigma' R' (R V R')^(-1) R sigma

              dof_adj is a degree of freedom adjustment, sigma a matrix containing the coefficient estimates of sigma, R is the convential matrix of a Wald test
              and V is a variance-covariance matrix.Under the null F(s,q) is F distributed.

              A known break date can be tested with xtbreak test using the option breakpoints(numlist|datelist,[index]).  numlist|datelist defines the periods of
              the breaks.  If numlist is used, then the option index is required.

              Testing for unknown break points

              If the number and thus the time period of breaks is unknwon, xtbreak test offers three different hypothesises:


              No break against s breaks

              Formally the hypothesis are:

                    H_0: no break vs. H_1: s breaks at unknown dates

              Bai & Perron (1998) suggest to take the supremum of the F-Statistics:

                    supF(s,q) = sup (l1,..,lq) F(l,q)

              where l1, lq are the different sets of possible breakpoints.  Essentially the test is the test of a known break after estimation of the breakpoints
              given a number of breaks.  For a discussion of the estimation of the breakpoints see xtbreak estimate.

              The supremum F-Test is called in xtbreak test using the options breaks(#) hypothesis(1).  breaks(#) sets the number of breaks.
              Critical values can be found in Bai & Perron (1998, 2003) and are supplied by xtbreak test.

              No break against s0<= s <=s1 breaks

              A test of the null hypothesis of no structural change against the alternative that an unknown number of structural breaks have occurred, where this
              unknown number of breaks lies between s0 and s1 is:

                    H_0: no break vs. H_1: s0 <= s <= s1 breaks at unknown dates

              The so-called double maximum test statistic is:

                    supF = sup(s0,..s,..,s1) supF(s,q)

              where supF(s,q) is as defined above.

              Generally speaking, the double maximum test estimates the breakdates for each number of breaks between s0 and s1, calculates the corresponding test
              statistic and then selects the largest one.  Two versions of the double maximum test are available, an unweighted and a weighted test.  For the
              weighted test the test supF(l,q) test statistics are weighted by critical values.

              The double maximum test can be used if the options breaks(#) hypothesis(2) are used.  Critical values can be found in Bai & Perron (1998, 2003) and
              are supplied by xtbreak test.

              s breaks against s+1 breaks
              A test of the null hypothesis that, s structural breaks have occurred, against the alternative that s + 1 breaks have occurred is:

                    H_0: s breaks vs H_1 s+1 breaks

                    F(s+1|s) = sup(s=1,..,s+1) sup(s0,..s,..,s1) supF(s,q)

              The test is essentially comparing the SSR of the model with s breaks to the minimum of the SSR of the model with s+1 breaks.

              The F(s+1|s) test is integrated in xtbreak test with the options breaks(#) hypothesis(3).  Critical values can be found in Bai & Perron (1998, 2003)
              and are supplied by xtbreak test.

          Options

              breakpoints(numlist| datelist [,index]) specifies the known breakpoints.  Kown breakpoints can be set by either the number of
                  observation or by the value of the time identifier.  If a numlist is used, option index is required.  For example
                  breakpoints(10,index) specifies that the one break occurs at the 10th observation in time.  datelist takes a list of dates.  For
                  example breakpoints(2010Q1) specifies a break in Quarter 1 in 2010.  If a datelist is used, the format set in breakpoints() and the
                  time identifer needs to be the same.

              breaks(#) specifies the number of unknwon breaks under the alternative.  For hypothesis 2, breaks() can take two values, for example
                  breaks(4 6) test for no breaks against 4-6 breaks.  If only one value specfied, then the lower limit is set to 1.

              hypothesis(1|2|3) specifies which hypothesis to test, see xtbreak_tests##DefUnknown.  h(1) test for no breaks vs. s breaks, h(2) for for
                  no break vs. s0 <= s <= s1 breaks and h(3) for s vs. s+1 breaks.{p_end

              breakconstant break in constant.  Default is no breaks in deterministics.

              noconstant suppresses constant.

              nobreakvariables(varlist1) defines variables with no structural break(s).  varlist1 can contain time series operators.

              vce(type) covariance matrix estimator, allowed: ssr, hac, hc, np and nw.  For more see, covariance estimators.
           

              minlength(real) minimal segment length in percent.  The minimal segment length is the minmal time periods between two breaks.  The
                  default is 15% (0.15).  Critical values are available for %5, 10%, 15%, 20% and 25%.

              error(real) define error margin for partial break model.

              wdmax Use weighted test statistic instead of unweighted for the double maximum test (hypotheisi 2).

              level(#) set level for critical values for weighted double maximum test.  If a value is choosen for which no critical values exits,
                  xtbreak test will choose the closest level.


          Covariance Estimators

          Saved Values

              xtbreak test stores the following in r():

              Known Breakpoints

              Scalars
                  r(Wtau)            Value of test statistic. 
                  r(p)               p-Value from F distribution. 

              Unknown Breakpoints

              Scalars
                  r(supWtau)         Value of supF statistic (hypothesis 1). 
                  r(Dmax)            Value of unweighted double maximum test (hypothesis 2). 
                  r(WDmax)           Value of weighted double maximum test (hypothesis 2).
                  r(f)               Value of supremum of supF statistic (hypothesis 3). 
                  r(c90)             Critival value at 90%. 
                  r(c95)             Critival value at 95%.
                  r(c99)             Critival value at 99%.

          Examples

              For example we want to find breaks in the US macro dataset supplied in Stata 16.  The dataset contains quarterly data on the inflation, GDP gap and
              the federal funds rate.  We load the data in as:

                 use http://www.stata-press.com/data/r16/usmacro.dta, clear

              A simple model to estimate the GDP gap using the federal funds rate and inflation woudl be:

                 regress ogap inflation fedfunds

              Test for known breaks

              Assume we want to test for a break in Quarter 1 1970:

                 xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1))

              and if we want to test for a break in 1970q1 and 1990q4:

                 xtbreak test ogap inflation fedfunds, breakpoint(tq(1970q1) tq(1990q4))

              Test for known breaks

          References

              Andrews, D. W. K. (1993).  Tests for Parameter Instability and Structural Change With Unknown Change Point.  Econometrica, 61(4), 821–856.

              Bai, B. Y. J., & Perron, P. (1998).  Estimating and Testing Linear Models with Multiple Structural Changes.  Econometrica, 66(1), 47–78.

              Bai, J., & Perron, P. (2003).  Computation and analysis of multiple structural change models.  Journal of Applied Econometrics, 18(1), 1–22.

              Ditzen, J., Karavias, Y. & Westerlund, J. (2021) Testing for Multiple Structural Breaks in Panel Data.


              Karavias, Y, Narayan P. & Westerlund, J. (2021) Structural breaks in Interactive Effects Panels and the Stock Market Reaction to COVID–19.

          INCLUDE help xtbreak_about
