# xtbreak

##estimating and testing for many known and unknown structural breaks in time series and panel data.

__Table of Contents__
1. [Syntax](#1-syntax)
2. [Description](#2-description)
3. [Options](#3-options)

# 1. Syntax

#### Testing for known structural breaks:

```
xtbreak test depvar [indepvars] [if] [in] , 
        breakpoints(numlist| datelist [,index]) options1
```

breakpoints(numlist[,index]) specifies the time period of the known structural break.

#### Testing for unknown structural breaks:

```
xtbreak test depvar [indepvars] [if] [in] , 
        hypothesis(1|2|3) breaks(#) options1 options2 options3
```

hypothesis(1|2|3) specifies which hypothesis to test, see hypothesises.  breaks(#) sets the number of breaks.


#### General Options

options1 | Description
--- | ---
**breakconstant** | break in constant
**noconstant** | suppresses constant
**nobreakvariables(varlist1)** | variables with no structural break(s)
**vce(type)** | covariance matrix estimator, allowed: ssr, hac, np and nw
