*! xbtreak test program
*! v. 0.01a 
capture program drop xtbreak_tests

program define xtbreak_tests, rclass
	
	if replay() == 1 {
		syntax [anything] , [version *]
		if "`version'" != "" {
			noi disp "xtbreak test, v 0.01a - 04.05.2021"
			exit
		}
	else {
		syntax varlist(min=1 ts) [if] , [			///
			Hypothesis(real 1)					/// which hypothesis to test
			wdmax								/// if hypothesis 2, do weighted UDmax test instead of UDmax
			csa(string)							/// cross-sectional averages to add
			CSANObreak(string)					/// cross-sectional averages with no break
			/// unknow breaks
			breaks(string)						/// number of breaks under alternative
			MINLength(real 0.15)				/// minimal time periods without a break
			level(string)						/// level for p-value
			error(real 0.0001)					/// error margin
			/// knwon breaks
			BREAKPoints(string)					/// periods of breakpoints
			/// general variable options	
			NOBREAKVARiables(varlist ts)		/// constant variables
			NOCONStant							/// no constant
			BREAKCONSTant						/// constant has break
			NOFIXEDeffects 						/// if fixed effects are part of the model
			vce(string)	varestimator(string)	/// empty for standard, kw/nw for newey west, np for non parametric (Pesaran 2006), HC for hc [only N=1], SSR for SSR [only N=1] 
			/// internal options				
			trace								/// show output
		]



		noi disp ""
		noi disp in red "THIS IS AN ALPHA VERSION!" 
		noi disp in red "PLEASE CHECK FOR UPDATES PRIOR PUBLISHING ANY RESULTS OBTAINED WITH THIS VERSION!"

		*** main check: are necessary options there?
		if "`breakpoints'`breaks'" == "" {
			noi disp "Option breakpoints or breaks required."
			error 198
		}

		*** check that moremata is installed
		qui{
			cap findfile moremata.hlp
			if _rc != 0 {
				noi disp "Moremata is required. Please install:"
				noi disp in smcl "{stata ssc install moremata}"
			}
		}

		local cmd "`*'"



		if "`trace'" == "" {
			local trace "qui"
		}
		else {
			local trace noi
		}
			
		`trace' {
			

			if "`vce'" == "" & "`varestimator'" != "" {
				local vce "`vce'"
			}
			
			*** parse options
			if strlower("`vce'") == "np" {
				local vce = 1
			}
			else if strlower("`vce'") == "ssr" {
				local vce = 2
			}
			else if strlower("`vce'") == "kw" | strlower("`vce'") == "nw" | strlower("`vce'") == "hac"  {
				local vce = 3
			}
			else  if strlower("`vce'") == "hc" | {
				local vce = 4
			}
			else {
				/// standard case; for panel switch to KW; for time series to ssr 
				local vce = 99
			}
			
			*** check for impossible options
			if wordcount("`varlist'") == 1 & "`noconstant'" != "" {
				noi disp "No variable to test."
				error 100
			}
			if "`noconstant'" != "" & "`breakconstant'" != "" {
				noi disp "Options noconstant and breakconstant"
				error 184
			}
			
			if "`level'" == "" {
				local level =  c(level)/100
			}
			
			if "`hypothesis'" != "2" & wordcount("`breaks'") > 1 {
				noi disp in smcl "Option {cmd:breaks()} can only take one number."
				error 199
			}

			*** name of hypothesis
			if "`hypothesis'" == "1" {
				local typename "supf"
				local statname "supW(tau)"
			}
			else if "`hypothesis'" == "2" {
				if "`wdmax'" == "" {
					local wdmax = 0
					local wdmaxName "UDmax(tau)"
					local wdmaxRname "UDmax"
				}
				else {
					local wdmax = 1
					local wdmaxName "WDmax(tau)"
					local wdmaxRname "WDmax"
				}
				local typename "`wdmaxRname'"
				local statname "`wdmaxName'"
			}
			else if "`hypothesis'" == "3" {
				local typename "fll1"
				local statname "F(s+1|s)*"
			}
			
			*** mark sample
			tempname touse
			marksample touse
			
			*** check if tsset or xtset and sorted
			
			cap _xt
			if _rc == 0 {
				local tvar_o `r(tvar)'
				local idvar `r(ivar)'	

				local IsPanel = 0
				xtset
				if 	`r(imax)' != `r(imin)' {
					local IsPanel = 1
				}	
			}
			else{
				tsset
				if "`r(panelvar)'" == "" {	
					tempvar idvar_bogus
					gen `idvar_bogus' = 1
					local tvar_o `r(timevar)'
					local idvar `idvar_bogus' 
				}
				local IsPanel = 0
			}			
			issorted `idvar' `tvar_o'
			
			*** generate new tvar from 1...T
			tempvar tvar
			egen `tvar' = group(`tvar_o') if `touse'
			
			*** tsset varlist 
			tsrevar `varlist'
			local indepdepvars "`r(varlist)'"
			
			*** adjust touse
			markout `touse' `indepdepvars'

			*** remove fixed effects?
			local demean = 0
			if `IsPanel' == 1 & "`nofixedeffects'" == "" {
				local demean = 1
				local noconstant noconstant
			}

			*** create cross-sectional averages
			if "`csa'" != "" {
				tempname csa_name
				local 0 `csa'
				syntax varlist(ts) , [lags(numlist)]
				if "`lags'" == "" { 
					local lags "0"
				}
				
				get_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name'")
				
				local csa_list "`r(varlist)'"
			}
			if "`csanobreak'" != "" {
				tempname csa_name
				local 0 `csa'
				syntax varlist(ts) , [lags(numlist)]
				if "`lags'" == "" { 
					local lags "0"
				}
				
				get_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name'")
				
				local csanb_list "`r(varlist)'"
			}
			markout `touse' `indepdepvars' `nobreakvariables' `csa_list' `csanb_list'
			
			local num_s = 0

			if "`breakpoints'" != "" {
				
				local 0 `breakpoints'
				syntax anything(name = breakpoints) , [index]
				
				transbreakpoints `breakpoints' , `index' tvar(`tvar' `tvar_o') touse("`touse'")
				local breakpoints "`r(index)'" 
			}
			
			/*
			*** Stata constant solution
			if "`noconstant'" == "" {
				tempname cons
				gen double `cons' = 1				
				if "`breakconstant'" == "" {
					*local csanb_list `csanb_list' `cons' 
					local indepdepvars `indepdepvars' `cons'
				}
				else {
					local indepdepvars `indepdepvars' `cons'
				}
			}
			local ConstantType = 0
			*/

			*** constant
			/*
				no constant: 						type = 0
				no break constant:					type = 1
				break constant:						type = 2
				break constant, only coefficient : 	type = -1; constant is added to Z
			*/
			
			if "`noconstant'" == "" {				
				if "`breakconstant'" == "" {
					tempname cons
					gen double `cons' = 1	
					
					if wordcount("`indepdepvars'") > 1 {
						local nobreakvariables `nobreakvariables' `cons'
						local ConstantType = 1
					}
					
					else if wordcount("`indepdepvars'") == 1 {						
						local indepdepvars `indepdepvars' `cons'
						local ConstantType = -1
					}
					
				}
				else {
					*** constant has a break
					*** check if constant only coefficient
					if wordcount("`indepdepvars'") > 1 {
						local ConstantType = 2
						
						tempname cons
						gen double `cons' = 1	
						local indepdepvars `indepdepvars' `cons'

					}
					else {
						*** model with only a constant
						tempname cons

						gen double `cons' = 1	
						local indepdepvars `indepdepvars' `cons'
						local ConstantType = -1
					}					
				}
			}
			else {
				local ConstantType = 0
			}
					
			issorted `idvar' `tvar_o'
			
			if "`breakpoints'" != "" {
				** only hypothesis 1 makes sense, if others used, then
				*** Test for hypothesis i)
				noi disp "`indepdepvars'"
				tempname EstCoeff EstCov testh 				
				`trace'  mata `testh' = Test_Hi_known("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'","`breakpoints'",`vce',`ConstantType',`demean',`EstCoeff'=.,`EstCov'=.)							
			}
			else {
				*** unknown breakpoints
				
				tempname EstCoeff EstCov EstBreak testh
				*** min length
				///if `minlength' < 1 {
					///qui tab `tvar'
					
					///local minlength = floor(`=`minlength'*`r(r)'')
				///}
				*if `minlength' < wordcount("`indepdepvars'") {
				*	local minlength = wordcount("`indepdepvars'")
				*}
								
				if "`hypothesis'" == "1" {
					
					`trace' mata `testh' = Test_Hi_unknown("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'",`breaks',`minlength',`vce',`ConstantType',`demean',`error',1,`EstCoeff'=.,`EstCov'=.,`EstBreak'=.)

					
				}
				else if "`hypothesis'" == "2" { 
					tempname testh
					`trace' mata `testh' = Test_Hii_unknown("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'","`breaks'",`minlength',`vce',`ConstantType',`error',1,`level',`wdmax',`EstCoeff'=.,`EstCov'=.,`EstBreak'=.)
				}
				else if "`hypothesis'" == "3" {
					tempname testh
					`trace'  mata `testh' = Test_Hiii_unknown("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'",`breaks',`minlength',`vce',`ConstantType',`error',`EstCoeff'=.,`EstCov'=.)
				}
				
				
			}
		}
		*** Output
		return clear
		disp ""
		if "`breakpoints'" != "" {
			
			tempname wtau pvalF pvalChi sq
			mata st_numscalar("`wtau'",`testh'[1,1])

			/// chi2
			mata `pvalChi' = 1- chi2(`testh'[1,2]*`testh'[1,3],`testh'[1,1])

			/// F(df1,df2,f-stat); df1 = q*s , df2 = T
			mata `pvalF' = 1- F(`testh'[1,2]*`testh'[1,3],`testh'[1,5],`testh'[1,1])

			mata st_numscalar("`pvalF'",`pvalF')
			mata st_numscalar("`pvalChi'",`pvalChi')

			disp as text " W(tau) " _col(10) " = " as result _col(13) %9.2f `wtau'
			disp as text  "	p-value (F)" _col(10) " = " as result  _col(13) %9.2f `pvalF'
			disp as text  "	p-value (chi)" _col(10) " = " as result  _col(13) %9.2f `pvalChi'

			return scalar p = `pvalF'
			return scalar Wtau = `wtau'
			
		}
		else {

			if inlist(`minlength',0.05,0.1,0.15,0.2,0.25) == 0 {
				local minlength_o "`minlength'"
				mata ml1 = (0.05,0.1,0.15,0.2,0.25)
				mata ml = abs(ml1:-`minlength')
				mata ml = selectindex(min(ml):==ml)
				mata ml1 = ml1[ml]
				mata st_local("minlength",strofreal(ml1))
				local minset = 1
				mata mata drop ml ml1

				
			}
			tempname stat c90 c95 c99 s q 
			mata st_numscalar("`stat'",`testh'[1,1])
			mata st_numscalar("`s'",`testh'[1,2])
			
			mata st_numscalar("`c90'", GetCritVal(`minlength',0.9,`testh'[1,2],`testh'[1,3],"`typename'"))

			mata st_numscalar("`c95'", GetCritVal(`minlength',0.95,`testh'[1,2],`testh'[1,3],"`typename'"))

			mata st_numscalar("`c99'", GetCritVal(`minlength',0.99,`testh'[1,2],`testh'[1,3],"`typename'"))
			
			
			noi disp as text _col(17) as smcl "{hline 17}" as text _col(35) "Bai & Perron Critical Values" as smcl _col(64) "{hline 17}" 
			
			noi disp as text _col(22) "Test" _col(36) "1% Critical" _col(52) "5% Critical" _col(67) "10% Critical" 
			noi disp as text _col(19) "Statistic" _col(38) "Value" _col(55) "Value" _col(71) "Value"
			noi disp as text "{hline 80}"
			noi disp as text _col(2) "`statname'" as result _col(18) %9.2f `stat' _col(35) %9.2f  `c99'  _col(51)  %9.2f  `c95' _col(67) %9.2f  `c90'
			noi disp as text "{hline 80}"
			if `hypothesis' == 1 | `hypothesis' == 2 {
				mata st_local("`EstBreak'",invtokens(strofreal(`EstBreak')))

				`trace' transbreakpoints ``EstBreak'' , index tvar(`tvar' `tvar_o') touse("`touse'")

				mata st_matrix("breaks",(strtoreal(tokens("`r(index)'")) \ (strtoreal(tokens("`r(ival)'")))))

				matrix rownames breaks =  Index TimeValue
				
				return matrix breaks = breaks

				noi disp as text "Estimated break points: `r(val)' "
			}
			if `hypothesis' == 2 {
				noi disp as text "* evaluated at a level of " %04.2f `level' "."
			}
			if `hypothesis' == 3 {				
				noi disp as text "* s = " `s'-1
			}
			if "`minset'" == "1" {
				noi disp as text "No critical values for minmal length available, set to `minlength'"
			}


			*** Return
			if `hypothesis' == 1 {
				return scalar supWtau = `stat'				
			}
			else if `hypothesis' == 2 {
				return scalar `wdmaxRname' = `stat'
			}
			else if `hypothesis' == 3 {
				return scalar f = `stat'
			}
			return scalar c90 = `c90'
			return scalar c95 = `c95'
			return scalar c99 = `c99'
			
			return local cmd "xtbreaks test `cmd'"
		}
	}
end



// -------------------------------------------------------------------------------------------------
// Test_Hi_known
// -------------------------------------------------------------------------------------------------
capture mata mata drop Test_Hi_known()
mata:
	function Test_Hi_known( ///
					string scalar varnames, 	///
					string scalar Xvarn,		/// variables with no breakpoint (X)
					string scalar csanames,		///
					string scalar csaNBnames,	/// csa with no breaks
					string scalar idtname,		///
					string scalar tousename,	///
					string scalar breakpoints,	///
					real scalar varestimator,	/// which variance estimator
					real scalar ConstantType,	///
					real scalar demean,			/// demean
					real matrix EstCoeff,		/// matrix with estiamted coefficients
					real matrix EstCov			/// variance / covariance matrix
					)
					
	{

		LoadData(varnames,Xvarn,csanames,csaNBnames,idtname,tousename,Y=.,W=.,X=.,csa=.,csaNB=.,idt=.,N=.,T=.,partial=.)
		
		breakpoints = strtoreal(tokens(breakpoints)) 
		
		W_tauChi = Test_W_Tau(Y,W,X,breakpoints,idt,partial,csa,csaNB,N,T,varestimator,ConstantType,demean,EstCoeff=.,EstCov=.)
		
		s = cols(breakpoints)
		q = cols(W)
		
		/// output
		if (N == 1) {
			displayas("err")
			printf("{txt}Test for multiple breaks at known breakdates\n(Bai & Perron. 1998. Econometrica)\n")
			printf("{txt}H0: no breaks vs. H1: %s break(s)\n",strofreal(s))
			displayas("txt")
						
		}
		else {
			displayas("err")
			if (s>1) {
				printf("\n{txt}Test for multiple breaks at unknown breakdates\n(Ditzen, Karavias & Westerlund. 2021)\n")
			}
			else {
				printf("{txt}Test for multiple breaks at known breakdates\n(Karavias & Westerlund. 2021)\n")
			}
			printf("{txt}H0: no breaks vs. H1: %s break(s)\n",strofreal(s))
			displayas("txt")
		}
		return(W_tauChi[1,1],cols(breakpoints),cols(W),W_tauChi[1,2],T)
		
	}
end

// -------------------------------------------------------------------------------------------------
// Test_W_Tau
// -------------------------------------------------------------------------------------------------
capture mata mata drop Test_W_Tau()
mata:
	function Test_W_Tau( ///
						real matrix Y,					///
						real matrix W,					///
						real matrix X,					///
						real matrix breakpoints,		///
						real matrix idt,				///
						real matrix partial,			///
						real matrix csa,				///
						real matrix csaNB,				///
						real scalar N,					///
						real scalar T,					///
						real scalar varestimator,		///
						real scalar ConstantType,		///
						real scalar demean,				///
						real matrix EstCoeff,			///
						real matrix EstCov				///
						)
	{
		
		partial_Bknown(Y,W,X,breakpoints,idt,partial,csa,csaNB,N,T,ConstantType,demean,Yt=.,Wt=.,R=.,s=.,q=.,p=.,num_partial=.)
		/// estimate ols and get variance
		///ols(Yt,Wt,idt,N,beta_p=.,cov_p=.,varestimator)	
		SSR = SSR(Yt,Wt,idt,N,beta_p,cov_p=.,varestimator)	
		"num paetial,q,p,s,varest"
		num_partial,q,p,s,varestimator
		
		if (N > 1) {
			/// cov_p is covariance with partialled out X variables
			RCR1 =  m_xtdcce_inverter(R * cov_p  * R')
			"beta"
			beta_p

			W_tau = (N * (T -1) - p - (s+1)*q) / (s*q) * (beta_p' * R' * RCR1 * R * beta_p)
			df = (N * (T - 1) - p - (s+1)*q) / (s*q) 
			"df"
			df
			
		}
		else {
			/// cov_p here is (Z'MxZ)^(-1) * SSR; Eq. 7 in Bai&Perron 1998
			RCR1 = m_xtdcce_inverter(R * cov_p * R')			
			W_tau = (T-(s+1) * q - p - num_partial) / (s*q) * (beta_p' * R' * RCR1 * R * beta_p)
			df = T - (s+1)*q - p- num_partial
		}
		
		EstCov = cov_p
		EstCoeff = beta_p
		
		return(W_tau,SSR,df)
	}
end


// -------------------------------------------------------------------------------------------------
// Test_Hi_unknown
// -------------------------------------------------------------------------------------------------
capture mata mata drop Test_Hi_unknown()
mata:
 function Test_Hi_unknown( ///
					string scalar varnames, 	///
					string scalar Xvarn,		/// variables with no breakpoint (X)
					string scalar csanames,		///
					string scalar csaNBnames,	/// csa with no breaks
					string scalar idtname,		///
					string scalar tousename,	///
					real scalar numbreaks,		///
					real scalar min,			///
					real scalar varestimator,	/// which variance estimator
					real scalar ConstantType,	///
					real scalar demean,			/// demean
					real scalar errror,			///
					real scalar postmsg,		/// display message
					real matrix EstCoeff,		/// matrix with estiamted coefficients
					real matrix EstCov,			/// variance / covariance matrix
					real matrix EstBreak		/// estimated breaks
					)
					
	{
		
		/// Load Data
		LoadData(varnames,Xvarn,csanames,csaNBnames,idtname,tousename,Y=.,Z=.,X=.,csa=.,csaNB=.,idt=.,N=.,T=.,partial=.)
		
		GetBreakPoints(Y,X,Z,idt,csa,csaNB,numbreaks,errror,ConstantType,demean,partial,min,EstBreak=.,finaldelta=.,finalbeta=.,minSSR=.)

		W_tauChi = Test_W_Tau(Y,Z,X,EstBreak',idt,partial,csa,csaNB,N,T,varestimator,ConstantType,demean,EstCoeff=.,EstCov=.)

		s = numbreaks
		q = cols(Z)

		if (postmsg == 1) {			
			if (N == 1) {
				displayas("err")
			///	printf("{txt}  \n")
				printf("\n{txt}Test for multiple breaks at unknown breakdates\n(Bai & Perron. 1998. Econometrica)\n")
				printf("{txt}H0: no break(s) vs. H1: %s break(s)\n",strofreal(s))
				displayas("txt")
			}
			else {
				displayas("err")
			///	printf("{txt} \n ")
				if (s>1) {
					printf("\n{txt}Test for multiple breaks at unknown breakdates\n(Ditzen, Karavias & Westerlund. 2021)\n")
				}
				else {
					printf("{txt}Test for multiple breaks at known breakdates\n(Karavias & Westerlund. 2021)\n")
				}
				printf("{txt}H0: no break(s) vs. H1: %s break(s)\n",strofreal(s))
				displayas("txt")
			}
			
			
		}
		
		return(W_tauChi[1,1],s,q) 
	}

end


// -------------------------------------------------------------------------------------------------
// Test_Hii_unknown
// -------------------------------------------------------------------------------------------------

capture mata mata drop Test_Hii_unknown()
mata:
 function Test_Hii_unknown( ///
					string scalar varnames, 	///
					string scalar Xvarn,		/// variables with no breakpoint (X)
					string scalar csanames,		///
					string scalar csaNBnames,	/// csa with no breaks
					string scalar idtname,		///
					string scalar tousename,	///
					string scalar numbreaksi,	///
					real scalar minlength,			///
					real scalar varestimator,	/// which variance estimator
					real scalar ConstantType,	///
					real scalar errror,			///
					real scalar postmsg,		/// display message
					real scalar level,			/// level to test
					real scalar wdmax,			/// 0 then udmax, 1 then wdmax
					real matrix EstCoeff,		/// matrix with estiamted coefficients
					real matrix EstCov,			/// variance / covariance matrix
					real matrix EstBreak		/// estimated breaks
					)
					
	{
		
		/// Load Data
		LoadData(varnames,Xvarn,csanames,csaNBnames,idtname,tousename,Y=.,Z=.,X=.,csa=.,csaNB=.,idt=.,N=.,T=.,partial=.)
		
		/// get all break point combinations
		numbreaks = strtoreal(tokens(numbreaksi))
		
		if (cols(numbreaks)==1) {
			numbreaks = 1,numbreaks
		}		
	
		supW = J(numbreaks[2]-numbreaks[1]+1,1,.)
		
		EstBreaki = asarray_create("real",1)
		
		q = cols(Z)
		c1 = 1
		cs = 1
		if (wdmax == 1) c1 = GetCritVal(minlength,level,numbreaks[1],q,"WDmax")	

		s = numbreaks[1]
		si = 1
		while (s <= numbreaks[2]) {	
			GetBreakPoints(Y,X,Z,idt,csa,csaNB,s,errror,ConstantType,partial,minlength,breakpointsi=.,finaldelta=.,finalbeta=.,minSSR=.)
			res = Test_W_Tau(Y,Z,X,breakpointsi,idt,partial,csa,csaNB,N,T,varestimator,ConstantType,EstCoeff=.,EstCov=.)
			
			if (wdmax == 1) cs = GetCritVal(minlength,level,s,q,"WDmax")
			
			supW[si,1] = res[1,1] * c1 / cs
			asarray(EstBreaki,si,breakpointsi)
			s++
			si++			
		}

		/// Get max of supW statistic
		index = selectindex(supW:==max(supW))
		supW = supW[index]		
		EstBreak = asarray(EstBreaki,index)			
		
		s = numbreaks[2]
		s0 = numbreaks[1]		
		if (postmsg == 1) {			
			if (N == 1) {
				displayas("err")
			///	printf("{txt}  \n")
				printf("\n{txt}Test for multiple breaks at unknown breakdates\n(Bai & Perron. 1998. Econometrica)\n")
				printf("{txt}H0: no break(s) vs. H1: %s <= s <= %s break(s)\n",strofreal(s0),strofreal(s))
				displayas("txt")
			}
			else {
				displayas("err")
				///printf("{txt} \n ")
				if (s>1) {
					printf("\n{txt}Test for multiple breaks at unknown breakdates\n(Ditzen, Karavias & Westerlund. 2021)\n")
				}
				else {
					printf("{txt}Test for multiple breaks at known breakdates\n(Karavias & Westerlund. 2021)\n")
				}
				printf("{txt}H0: no break(s) vs. H1: %s <= s <= %s break(s)\n",strofreal(s0),strofreal(s))
				displayas("txt")
			}
			
			
		}
		
		return(supW,s,q) 
	}


end


// -------------------------------------------------------------------------------------------------
// Test_Hiii_unknown 
// -------------------------------------------------------------------------------------------------
capture mata mata drop Test_Hiii_unknown()
mata:
 function Test_Hiii_unknown( ///
					string scalar varnames, 	///
					string scalar Xvarn,		/// variables with no breakpoint (X)
					string scalar csanames,		///
					string scalar csaNBnames,	/// csa with no breaks
					string scalar idtname,		///
					string scalar tousename,	///
					real scalar numbreaks,		///
					real scalar min,			///
					real scalar varestimator,	/// which variance estimator
					real scalar ConstantType,	///
					real scalar errror,			///
					real matrix EstCoeff,		/// matrix with estiamted coefficients
					real matrix EstCov			/// variance / covariance matrix
					)
					
	{
		
		/// Load Data
		LoadData(varnames,Xvarn,csanames,csaNBnames,idtname,tousename,Y=.,Z=.,X=.,csa=.,csaNB=.,idt=.,N=.,T=.,partial=.)

		/// null hypothesis (in BP "l" model)
		GetBreakPoints(Y,X,Z,idt,csa,csaNB,numbreaks-1,errror,ConstantType,partial,min,breakpointsl=.,finaldelta=.,finalbeta=.,SSR_0=.)
		"ssr 0"
		SSR_0
		/// alternative (for sigma hat 2)
		GetBreakPoints(Y,X,Z,idt,csa,csaNB,numbreaks,errror,ConstantType,partial,min,tmp1=.,tmp2=.,tmp2=.,SSR_a=.)
		/// adjust SSR to get sigma2 hat (i.e. )
		sigma2_1 = SSR_a / T
		
		results = J(numbreaks,4,0)
		l = 1
		"breakpoints under null"
		breakpointsl
		sum(breakpointsl)
numbreaks
		/// dv in Matlab code	
		if (sum(breakpointsl)>0) {	
			breakpointsl1 = 0,breakpointsl,T
		}
		else {
			breakpointsl = .
			breakpointsl1 = 0,T
		}
		breakpointsl1
		while (l<=numbreaks) {
			start = breakpointsl1[l]
			ende = breakpointsl1[l+1]
			index = selectindex( (idt[.,2]:>=start+1):*(idt[.,2]:<=ende ))
			/// update data
			Yi = Y[index,.]
			Xi = X[index,.]
			Zi = Z[index,.]
			csai = csa[index,.]
			csaNBi = csa[index,.]
			idti = idt[index,.]

			GetBreakPoints(Yi,Xi,Zi,idti,csai,csaNBi,1,errror,ConstantType,partial,min,breakpoints_i=.,tmp1=.,tmp2=.,tmp3=.)
			if (sum(breakpoints_i) > 0 ) {
				"additional breakpoint at"
				breakpoints_i
				/// convert breakpoints into correct index (subsample will have breaks from 1,...,T)
				Tuniqi = uniqrows(idti[.,2])
				breakpoints_ii = Tuniqi[breakpoints_i]	
				breakpoints_ii = (sort((breakpointsl,breakpoints_ii)',1))'
				breakpoints_ii = breakpoints_ii[selectindex(breakpoints_ii:!=.)]
				"breaks are"
				breakpoints_ii
				/// now we have the optimal set of breakpoints, now problem with known breakpoints
				/// get SSR/F stat for entire dataset; Test_W_Tau returns F, SSR,df
				results[l,(1,2,3)] = Test_W_Tau(Y,Z,X,breakpoints_ii,idt,partial,csa,csaNB,N,T,varestimator,ConstantType,EstCoeff=.,EstCov=.)
				
				/// add estimated additional breakpoint
				breakpoints_i
				results[l,4] = breakpoints_i
			}
			else {
				results[l,.] = .,.,.,.
			}
			l++
		}
		"alternative done"
		results
		if (missing(results) == rows(results)*cols(results)) {
			/// if results has only missings, no additional breaks can be found
			displayas("err")
			printf("{txt}No additional breaks found. Minimal length might be too small.\n")
			exit(199)
		}
		/// Get points with minimal SSR
		index = selectindex(results[.,2]:==min(results[.,2]))
		minSSR_1 = results[index,2]
		SSR_0,minSSR_1,sigma2_1
		stat = (SSR_0 - minSSR_1) / (sigma2_1)
		/// make sure dimensions are correct
		s = numbreaks
		q = cols(Z)		
		df = results[index,3]
		p = cols(X)
		/// adjust F statistic (F-Stat is divided by 2*q and not by s*q and has q*(s+2)!
		if (N>1) {
			stat = stat / df * (N * (T - p - q) - p - (s+2)*q) / (s*q)
		}
		

		/// output
		if (N == 1) {
			displayas("err")
			///printf("{txt}  \n")
			printf("\n{txt}Test for multiple breaks at unknown breakpoints\n(Bai & Perron. 1998. Econometrica)\n")
			printf("{txt}H0: %s vs. H1: %s break(s)\n",strofreal(s-1),strofreal(s))
			displayas("txt")
						
		}
		else {
			displayas("err")
			///printf("{txt}  \n")
			printf("\n{txt}Test for multiple breaks at unknown breakpoints\n(Ditzen, Karavias & Westerlund. 2021)\n")
			printf("{txt}H0: %s vs. H1: %s break(s)\n",strofreal(s-1),strofreal(s))
			displayas("txt")
		}
		"hiii done"
		return(stat,s,q,df)  
			
}
end


** auxiliary file with auxiliary programs
findfile "xtbreak_auxiliary.ado"
include "`r(fn)'"

** Variance Covariance Estimator
findfile "xtbreak_VarCov.ado"
include "`r(fn)'"

** Critical Values
findfile "xtbreak_critval.ado"
include "`r(fn)'"
