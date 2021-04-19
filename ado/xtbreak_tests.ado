capture program drop xtbreak_tests

program define xtbreak_tests, rclass
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
		vce(string)	varestimator(string)	/// empty for standard, kw/nw for newey west, np for non parametric (Pesaran 2006), HC for hc [only N=1], SSR for SSR [only N=1] 
		///maintenance
		update								/// use github for update
		/// internal options				
		trace								/// show output
	]

	noi disp ""
	noi disp in red "THIS IS AN ALPHA VERSION!" 
	noi disp in red "PLEASE CHECK FOR UPDATES PRIOR PUBLISHING ANY RESULTS OBTAINED WITH THIS VERSION!"
	noi disp in text "Only Time Series supported."

	if "`update'" != "" {
		noi disp "Update from Github"
		net install xtbreak , from("https://janditzen.github.io/xtbreak/") force replace
		noi disp "Done"
		exit
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

			*** check minlength & breaks
			*if inlist("`minlength'","0.05","0.1","0.15","0.2","0.25") == 0 {
				*local minlength = 0.15
				*noi disp "Invalid entry for minlength, set to 0.15"
			*}


			/*
			TO ADD! check if break and breakpoints combined
			
			*/

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
			}
			else{
				tsset
				if "`r(panelvar)'" == "" {	
					tempvar idvar_bogus
					gen `idvar_bogus' = 1
					local tvar_o `r(timevar)'
					local idvar `idvar_bogus' 
				}				
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
			
			*** create cross-sectional averages
			if "`csa'" != "" {
				tempname csa_name
				local 0 `csa'
				syntax varlist(ts) , [lags(numlist)]
				if "`lags'" == "" { 
					local lags "0"
				}
				
				xtdcce2_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name'")
				
				local csa_list "`r(varlist)'"
			}
			if "`csanobreak'" != "" {
				tempname csa_name
				local 0 `csa'
				syntax varlist(ts) , [lags(numlist)]
				if "`lags'" == "" { 
					local lags "0"
				}
				
				xtdcce2_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name'")
				
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
				
				tempname EstCoeff EstCov testh 				
				`trace'  mata `testh' = Test_Hi_known("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'","`breakpoints'",`vce',`ConstantType',`EstCoeff'=.,`EstCov'=.)							
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
					
					`trace' mata `testh' = Test_Hi_unknown("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'",`breaks',`minlength',`vce',`ConstantType',`error',1,`EstCoeff'=.,`EstCov'=.,`EstBreak'=.)

					
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
				noi disp as text "Estimated break points: ``EstBreak''"
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
			
			return local cmd "`cmd'"
			
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
					real matrix EstCoeff,		/// matrix with estiamted coefficients
					real matrix EstCov			/// variance / covariance matrix
					)
					
	{

		LoadData(varnames,Xvarn,csanames,csaNBnames,idtname,tousename,Y=.,W=.,X=.,csa=.,csaNB=.,idt=.,N=.,T=.,partial=.)
		
		breakpoints = strtoreal(tokens(breakpoints)) 
		
		W_tauChi = Test_W_Tau(Y,W,X,breakpoints,idt,partial,csa,csaNB,N,T,varestimator,ConstantType,EstCoeff=.,EstCov=.)
		
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
						real matrix EstCoeff,			///
						real matrix EstCov				///
						)
	{
		
		partial_Bknown(Y,W,X,breakpoints,idt,partial,csa,csaNB,N,T,ConstantType,Yt=.,Wt=.,R=.,s=.,q=.,p=.,num_partial=.)
		/// estimate CCEP and get variance
		///ccep(Yt,Wt,idt,N,beta_p=.,cov_p=.,varestimator)	
		SSR = SSR(Yt,Wt,idt,N,beta_p,cov_p=.,varestimator)	
		"num paetial,q,p,s"
		num_partial,q,p,s
		
		if (N > 1) {
		*	RCR1 =  m_xtdcce_inverter(R * cov_p  * R')
		*	W_tau = (N * (T - p - q) - p - (s+1)*q) / (s*q) * (beta_p' * R' * RCR1 * R * beta_p)
		*	df = N * (T - p - q) - p - (s+1)*q
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
					real scalar errror,			///
					real scalar postmsg,		/// display message
					real matrix EstCoeff,		/// matrix with estiamted coefficients
					real matrix EstCov,			/// variance / covariance matrix
					real matrix EstBreak		/// estimated breaks
					)
					
	{
		
		/// Load Data
		LoadData(varnames,Xvarn,csanames,csaNBnames,idtname,tousename,Y=.,Z=.,X=.,csa=.,csaNB=.,idt=.,N=.,T=.,partial=.)
		
		GetBreakPoints(Y,X,Z,idt,csa,csaNB,numbreaks,errror,ConstantType,partial,min,EstBreak=.,finaldelta=.,finalbeta=.,minSSR=.)

		W_tauChi = Test_W_Tau(Y,Z,X,EstBreak',idt,partial,csa,csaNB,N,T,varestimator,ConstantType,EstCoeff=.,EstCov=.)

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


/*

*/


// -------------------------------------------------------------------------------------------------
// LoadData()
// -------------------------------------------------------------------------------------------------

capture mata mata drop LoadData()
mata:
	function LoadData(	///
					string scalar varnames, 	///
					string scalar Xvarn,		/// variables with no breakpoint (X)
					string scalar csanames,		///
					string scalar csaNBnames,	/// csa with no breaks
					string scalar idtname,		///
					string scalar tousename,	///
					real matrix Y,				///
					real matrix W,				///
					real matrix X,				///
					real matrix csa,			///
					real matrix csaNB,			///
					real matrix idt,			///
					real scalar N,				///
					real scalar T,				///
					real scalar partial
					)
	{
		
		varname = st_tsrevar(tokens(varnames))
		Y = st_data(.,varname[1],tousename)
		W = st_data(.,varname[1,2..cols(varname)],tousename)

		if (Xvarn != "") {
			X = st_data(.,st_tsrevar(tokens(Xvarn)),tousename)
		}
		else {
			X = J(rows(Y),0,.)
		}

		partial = 0
		if (csanames[1,1] != "" ) {		
			csa = st_data(.,st_tsrevar(tokens(csanames)),tousename)
			partial = 1
		}
		else {
			csa = J(rows(Y),0,.)
		}
	
		if (csaNBnames[1,1] != "" ) {
			csaNB = st_data(.,st_tsrevar(tokens(csaNBnames)),tousename)
			partial = 1
		}
		else {
			csaNB = J(rows(Y),0,.)
		}
		
		idt = st_data(.,idtname,tousename)
		Nuniq = uniqrows(idt[.,1])
		N = rows(Nuniq)
		
		Tuniq = uniqrows(idt[.,2])
		T = rows(Tuniq)	
	}
end

// -------------------------------------------------------------------------------------------------
// BreakMat
// -------------------------------------------------------------------------------------------------

/// Creates Txq vector for q breaks at dates from breakpoints vector
capture mata mata drop BreakMat()
mata:
	function BreakMat( real matrix breakpoints, real scalar T, real scalar s)
	{
		real matrix shapeMat
		
		shapeMat = J(T,(s+1),0)
		i = 1
		low = 1
		while (i<=s+1) {
			up = breakpoints[i]
 			shapeMat[low..up,i] = J(up-low+1,1,1)			
			low = up + 1
			i++
		}		
		return(shapeMat)
	}
end

// -------------------------------------------------------------------------------------------------
// ccep
// -------------------------------------------------------------------------------------------------

capture mata mata drop ccep()
mata:
	function ccep( ///
					real matrix Y,		///
					real matrix X,		///
					real matrix idt,	///
					real scalar N,		///
					real matrix betaP,	///
					real matrix cov,	///
					real scalar estCov	/// 0: no estimation, 1: standard non para. estimator Pesaran (2006) Eq. 67 - 69
										///	2: NW type estimator 
					)
	{
		
		XX = quadcross(X,X)
		XY = quadcross(X,Y)
		betaP = m_xtdcce_inverter(XX) * XY
		
		if (estCov > 0) {
			cov = covEst(Y,X,idt,betaP,N,estCov)
		}
	}
end

// -------------------------------------------------------------------------------------------------
// covEst
// -------------------------------------------------------------------------------------------------

capture mata mata drop covEst()
mata:
	function covEst( ///	
					real matrix Y,				///
					real matrix X,				///
					real matrix idt,			///
					real matrix betaP,			///
					real scalar N,				///
					real scalar estCovi 		///
					)
	{
					
		if (N == 1 & estCovi == 99) {
			estCovi = 2
		}
		else if ( estCovi == 99 ) {
			estCovi = 3
		}
		
		if (estCovi == 1) {
			 "N>1, non parametric"
			cov = VarCov_NP(Y,X,idt,betaP,N)  
		}
		else if (estCovi == 2) {
			"N=1 case, cov = SSR"
			cov = VarCov_SSR(Y,X,betaP)
		}
		else if (estCovi == 3 ) {
			"N>1, COV estimator from KW 4.10 - 4.12"
			cov = VarCov_KWP(Y,X,idt,betaP,N)
			
		}
		else if (estCovi == 4) {
			T = rows(uniqrows(idt[.,2]))
			"N = 1 case with cov = H"
			cov = VarCov_HC(Y,X,betaP) 
			
		}
		"cov done"			
		return(cov)

	}
		
	
end		

// -------------------------------------------------------------------------------------------------
// SSR program
// -------------------------------------------------------------------------------------------------

capture mata mata drop SSR()
mata:
 function SSR( ///
				real matrix Y,					///
				real matrix X,					///
				real matrix idt,				///
				real scalar N,|					///
				real matrix beta_p,				///
				real matrix cov_p,				///
				real matrix varestimator 		///
				)

	{
		if (args() < 7) {
			varestimator = 0
		}

		ccep(Y,X,idt,N,beta_p=.,cov_p=.,varestimator)
		
		eps = Y - X * beta_p
		eps2 = quadcross(eps,eps)
		
		return(eps2) 
	}
end


// -------------------------------------------------------------------------------------------------
// partial_Bknown
// -------------------------------------------------------------------------------------------------

/// partial_Bknown parialls out the cross-section averages, constant variables and creates a Wt matrix with N*T x (s+1)*q
capture mata mata drop partial_Bknown()
mata:
	function partial_Bknown(	real matrix Y,					/// dep var
								real matrix W,					/// var with breaks
								real matrix X,					/// var without breaks
								real matrix breakpoints,		///
								real matrix idt,				///
								real matrix partial,			///
								real matrix csa,				///
								real matrix csaNB,				///
								real scalar N,					///
								real scalar T,					///
								real scalar ConstantType,		///
								real matrix Yt,					///	partialed out dep var
								real matrix Wt,					/// paritaled out var with breaks
								real matrix R,					///	restriction matrix
								real scalar s,					/// number of breaks
								real scalar q,					/// number of regressors in var with breaks
								real scalar p,					/// number of regressors in var without breaks
								real scalar num_partial			/// number of variables partialled out
								)
						
						
	{
	    "start partialing out with known breaks"
		/// breakpoints should be a columnvector
		if (cols(breakpoints) < rows(breakpoints)) {
			breakpointsI = breakpoints',T
		}
		else {
			breakpointsI = breakpoints,T
		}
		s = cols(breakpointsI)-1		
		
		p = cols(X)
		q = cols(W)
		NT = rows(W)	
		
		/// bring W and CSA in shape with break structure
		
		shapeMat = BreakMat(breakpointsI,T,s)
		
		"breakpoints,p,s,q,partial,ctype"
		breakpoints
		p,s,q,partial,ConstantType

		Wt1 = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(s+1),1)#W)

		mult_partialout(Y,X,Wt1,csa,csaNB,idt,N,T,NT,ConstantType,p,s,shapeMat,partial,(p>0),Yt,Wt,Xt=.,num_partial)

		/// update q if constant is included
		///if (ConstantType==2) q = q + 1			

		R = (I(s)#I(q),J(s*q,q,0)):+(J(s*q,q,0),-I(s)#I(q))
	}
end
/*
		///shapeLong = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(s+1),1)#J(NT,cols(W),1))

		Wt = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(s+1),1)#W)
		Yt = Y		
		Xt = X

		mult_partialout(Y,)

		num_partialCSA = 0
		num_partial = 0

		/// Constant removed here
		if (ConstantType == 1) {
			"no break in constant"
			/// no break in constant
			constant = J(NT,cols(W),1)
			///p =  1
		}
		else if (ConstantType == 2) {
			"break in constant"
			/// break in constant
			constant = (J(N,1,1)#shapeMat#J(1,1,1)) :* (J(1,(s+1),1)#J(NT,1,1))
		}
		else if (ConstantType == -1) {
			"constant included in X"
		}
		
		if (ConstantType == 1) {
			if (N > 1) {
				/// partial constant out for each cross-section
				tilde = xtdcce_m_partialout2((Yt,Wt,Xt),constant,idt[.,1],0,num_partial)
				Yt = tilde[.,1]
				Wt = tilde[.,2..1+cols(Wt)]
				if (p > 0) {
					Xt = tilde[.,1+cols(Wt)+1..cols(tilde)]
				}
			}
			else {
				Mx = I(T) - constant * m_xtdcce_inverter(quadcross(constant,constant))*constant'				
				Yt = Mx * Yt
				Wt = Mx * Wt
				if (p > 0){
					Xt = Mx * Xt
				}
				num_partial = 1
			}
			"constant removed"
		}
	

		/// partial out cross-sectional averages, assumption the CSA have heterogenous factor loadings!
		/// count here partialed out variables
		
		if (partial == 1) {
			"partial out variables with breaks"
			csaI = (J(N,1,1)#shapeMat#J(1,cols(csa),1)) :* (J(1,(s+1),1)#csa)
				
			tilde = xtdcce_m_partialout2((Yt,Wt,Xt),( csaI, csaNB),idt[.,1],0,num_partialCSA)
						
			Yt = tilde[.,1]
			/// correct Wt for zero columns, should only use blockdiagonal matrix, but this is faster and equivalent?
			Wt = tilde[.,2..1+cols(Wt)]
			
			if (p > 0) {
				Xt = tilde[.,1+cols(Wt)+1..cols(tilde)]
			}
		}
		
		/// Partial out X variables, assumption homogenous slopes!
		/// num_partial does not need to be adjusted, variables included in p
		if (p > 0) {
			"partial out constant variables"
			XX = quadcross(Xt,Xt)
			Qx = I(rows(Wt)) - Xt * m_xtdcce_inverter(XX) * Xt'
			Yt = Qx * Yt
			Wt = Qx * Wt
		}

		num_partial = num_partial + num_partialCSA

	}
	
end
*/

// -------------------------------------------------------------------------------------------------
// GetAllBreakCombs
// -------------------------------------------------------------------------------------------------
capture mata mata drop GetAllBreakCombs()
mata:
	function GetAllBreakCombs(real scalar T, real scalar breaks, real scalar min)
	{
		if (T-(breaks+1)*min > 0) {
			numb = J(1,breaks,min)
			numb = numb , T-sum(numb)
			maxEnt = max(numb)
			diff = maxEnt - min
			comps = J(0,breaks,.)
			bi = 0
			while (bi <= diff) {
					comps = comps \  mm_compositions(bi,breaks)'
					bi++
			}
			/// no need to add last column as it will always sum up to T
			numb = J(rows(comps),breaks,min) :+comps
			//// get first period of change
			numb =  mm_colrunsum(numb')' 
			
		}
		else {
			numb = -9999
		}
		return(numb)
	}
end

cap program drop _dotspct
program _dotspct
        version 8.2
        syntax [anything] [, title(string) reps(integer -1) NODOTS ///
                DOTS(numlist >0 integer max=1)]
        if "`dots'"=="" local dots 1
        tokenize `anything'
        args i rc
        if "`i'" == "0" {
                if `"`title'"' != "" {
                        if `reps' > 0 {
                                di as txt "`title' ("   ///
                                   as res `reps' as txt ") " 
                        }
                        else {
                                di as txt "`title'" 
                        }
                }
                if "`nodots'" == "" {
                        di as txt "{hline 4}{c +}{hline 3} 10 "  ///
                                  "{hline 2}{c +}{hline 3} 20 "  ///
                                  "{hline 2}{c +}{hline 3} 30 "  ///
                                  "{hline 2}{c +}{hline 3} 40 "  ///
                                  "{hline 2}{c +}{hline 3} 50   %"
                }
                exit
        }
	
		else if `reps' < 100 {
		    local mult = floor(`i'/`reps'*100)-floor((`i'-1)/`reps'*100)
			forvalues s=1(1)`mult' {				
			     _dots 1 0
				 if (`i'-1)*`mult'+`s' >= 50 & (`i'-1)*`mult'+`s'-1 < 50 {
					 di as txt "" _col(51) %5.0f 50
				}
			}
			
		}
		else {
		   local check = round(`i'/`reps',0.01) - round((`i'-1)/`reps',0.01)
		 
		   if `check' > 0 {
		       _dots 1 0
		   }	   
			if `i'/`reps' >= 0.5 & (`i'-1)/`reps' < 0.5 {
				di as txt "" _col(51) %5.0f 50
			}
		}
		 
		if `i'/`reps' == 1 {
			di as txt "" _col(51) %5.0f 100
        }
end

// -------------------------------------------------------------------------------------------------
// GetBreakPoints
// -------------------------------------------------------------------------------------------------



/// Program to obtain break points (pure change model) (partialchange.m) (done)
capture mata mata drop GetBreakPoints()
mata:
	function GetBreakPoints( 	real matrix Y,				///
								real matrix X,	 			///
								real matrix Z,				///
								real matrix idt,			///
								real matrix csa,			///
								real matrix csaNB,			///
								real scalar s,				///
								real scalar error,			///
								real scalar ConstantType,	///
								real scalar partialCSA,		///
								real scalar minlength,		///
								/// output
								real matrix finalbreaks,	///
								real matrix finaldelta,		///
								real matrix finalbeta,		///
								real matrix minSSR			///
								)
	{
		"start finding breakpoints"		
		q = cols(Z)

		/// variables with fixed slopes
		if (cols(X) != 0 ) {
			p = cols(X)
			Xi = X
		}
		else {
			Xi = J(rows(Z),1,0)
			p = 0
		}
				
		Ni = uniqrows(idt[.,1])
		N = rows(Ni)
		Ti = uniqrows(idt[.,2])
		T = rows(Ti)
		
		/// panelindex
		index = panelsetup(idt[.,1],1)	
		
		if (p:==0) {
			/// full change model
			"full change model"
			mult_partialout(Y,Xi,Z,csa,csaNB,idt,N,T,N*T,ConstantType,p,0,BreakMat(T,T,0),partialCSA,0,Y0=.,Z0=.,X0=.,tmp=.)
			dynamicprog(Y0,Z0, N,T, s, index ,minlength,  minSSR=.,finalbreaks=. )	
			"final breaks are"
			finalbreaks		
			minSSR	
		}	
		else {
			/// partial change model
			"first search"
			/// partial out csa, constant, keep X vars!
			mult_partialout(Y,Xi,Z,csa,csaNB,idt,N,T,N*T,ConstantType,p,s,	(T,T,0),partialCSA,0,Y0=.,Z0=.,X0=.,tmp=.)
		
			///dynamicprog(Y0, (X0,Z0), N,T, s, index ,minlength,  minSSR=.,truebreaks=. )	
			
			/// inital breaks with only Z!
			dynamicprog(Y0,(X0,Z0), N,T, s, index ,minlength,  minSSR=.,truebreaks=. )
			"inital breaks with X and Z having breaks"
			truebreaks	
			/// inital estimate can lead to no breaks
			if (sum(truebreaks) > 0) {
				truebreaksI = (truebreaks' \ T)
				shapeMat = BreakMat(truebreaksI,T,s)
				sv = s
			}
			else {
				"no breaks found!"
				shapeMat = J(T,1,1)
				sv=0
			}
			
			Zblk = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(sv+1),1)#Z)
			Xblk = (J(N,1,1)#shapeMat#J(1,p,1)) :* (J(1,(sv+1),1)#Xi)

			/// partial out constant and csa
			///


			tmp = SSR(Y0,(Xblk,Zblk),idt,N,beta_p=.,tmp1=.,0)

			/// inital estimate for beta
			///tmp = SSR(Y0,(X0,Z0),idt,N,beta_p=.,tmp1=.,0)

			/// beta_p has var1(b1), var2(b2); all in blockidag form for breaks
			deltahatblock = colshape(beta_p,sv+1)		
			delta2hat = deltahatblock[p+1..p+q,.]		
			splitcoef_flat = colshape(delta2hat,1)



			Yn = Y - Zblk * splitcoef_flat


			///intital values for loop and first betahat0
			///mult_partialout(Y,Xi,Zblk,csa,csaNB,idt,N,T,N*T,ConstantType,p,sv,shapeMat,partialCSA,0,Y0=.,Z0=.,X0=.,tmp=.)
			
			ccep(Yn,X0,idt,N,betahat0=.,tmp1=.,0)
			
			///SSRT = SSR(Yn,X0,idt,N,betahat0=.)
			SSRT = 0
			SSRlast = 0
			count = 0
			errori = 1
			deltahat = J((s+1)*q,0,.)
		
			while (errori >= error) {
				count = count + 1
				/// use inital values with partialled out constant and CSA, can use X0
				Yn = Y - X * betahat0[.,count]
				dynamicprog(Yn, Z , N,T, s, index ,minlength, minSSR=.,truebreaks=. )
				"break in i"
				truebreaks
				if (sum(truebreaks) > 0) {
					truebreaksIL = (truebreaks , T)
					shapeMat = BreakMat(truebreaksIL,T,s)
					sv = s
					
					Z0t = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(sv+1),1)#Z)

					/// constant and CSA are partialled out in every step
					///mult_partialout(Y,Xi,Z0t,csa,csaNB,idt,N,T,N*T,ConstantType,p,sv,shapeMat,partialCSA,0,Yt=.,Zt=.,Xt=.,tmp=.)

					/// SSR program returns beta as well
					SSR = SSR(Y,(X,Z0t),idt,N,thetahat_i=.)

					/// beta_p has var1(b1), var2(b2); only Z in  blockidag form for breaks
					betahat0 = betahat0,thetahat_i[1..p]
					deltahat = deltahat , thetahat_i[p+1..p+q*(sv+1)]

				}
				else {
					"no breaks found!"
					/// make SSR artifically high
					
					SSR = 0
					sv = 0
					truebreaksIL = .
				}				
				SSRT = SSRT, SSR

				errori = SSRT[count+1] - SSRT[count]
							
				if (errori>=error) {
					truebreaksI = truebreaksIL
					SSRlast = SSR
				}
				
			}
			if (sv > 0) {
				minSSR = SSRT[count+1]
				finalbreaks = truebreaksI[1..sv]
				finaldelta = deltahat[.,count]
				finalbeta = betahat0[.,count+1]
				///minSSR = SSRlast
			}
			else {
				"no valid breaks found"
				finalbreaks = J(s,1,0)
				finaldelta = .
				finalbeta = .
				/// get normal SSR
				minSSR = SSR(Y,(X,Z),idt,N,beta_p=.,tmp=.,0)
			}
			"breaks are"
			finalbreaks
		}
	}
end

// -------------------------------------------------------------------------------------------------
// Dynamic program
// -------------------------------------------------------------------------------------------------
capture mata mata drop dynamicprog()
mata:
	function dynamicprog(	real matrix Y,				///
							real matrix zstar,			///
							real scalar N,				///
							real scalar T,				///
							real matrix Nbreaks,		///
							real matrix index,			///	
							real scalar minlength,		///
							/// Output
							real matrix minSSR,			///
							real matrix truebreaks )	
	{
		"start dynamicprog"
		///lambda = cols(zstar)		
		lambda = cols(zstar)

		q= floor(T*minlength)
		"q is"
		q,minlength,T
		///q = minlength

		/// SSRm has partial SSRs. Rows indicate start of segment, column end.
		/// Element (4,10) is segment starting at period 4 and ending at period 10
		
		SSRm = J(T,T,.)	
		l = 0
		l_end = Nbreaks - 1
		while (l<=l_end) {
			i = l*q + 1
			i_end = (l+1)*q
			while (i<=i_end) {
				j = q+i -1
				j_end = T-(Nbreaks-l)*q
				while (j<=j_end) {
					SSRii = 0
					ii = 1
					while (ii <= N) {
						Yi = panelsubmatrix(Y,ii,index)
						Zi = panelsubmatrix(zstar,ii,index)
						Yi = Yi[|i,1 \ j,1|]
						Zi = Zi[|i,. \ j,.|]
						
						/// way 1
						xx = quadcross(Zi,Zi)
						xy = quadcross(Zi,Yi)

						b = m_xtdcce_inverter(xx) * xy
						e = Yi - Zi*b 
						SSRii = SSRii + quadcross(e,e)
						ii++
					}
					SSRm[i,j] = SSRii
					j++
				}
				i++
			}
			l++
		}

		i = q*Nbreaks + 1
		i_end = T-q+1
		
		while (i<=i_end) {
			if (q>0) {
				j = q+i -1
			}
			else {
				j = 1+i -1
			}
			j_end = T
			while (j<=j_end) {			
				SSRii = 0
				ii = 1
				while (ii <= N) {
					Yi = panelsubmatrix(Y,ii,index)
					Zi = panelsubmatrix(zstar,ii,index)
					Yi = Yi[|i,1 \ j,1|]
					Zi = Zi[|i,. \ j,.|]
					
					/// way 1
					xx = quadcross(Zi,Zi)
					xy = quadcross(Zi,Yi)

					b = m_xtdcce_inverter(xx) * xy

					e = Yi - Zi * b

					SSRii = SSRii + quadcross(e,e)
					ii++
				}
				SSRm[i,j] = SSRii
				j++
			}
			i++
		}
		/// Dynamic programming
		if (Nbreaks:== 1) {
			"one break case"
			/// special case: only one break, no array needed			
			/// j is the start element
			if (q > 0) {
				j = q
				j_end = T-q	
			}
			else {
				j = 1
				j_end = T-1
			}
					
			v=1
			S_j =J(T,1,.)	
			while (j<=j_end) {
				j
				///S_j[j,1] = SSR[1,j] + SSR[j+1,j+1]
				S_j[j,1] = SSRm[1,j] + SSRm[j+1,T]
				j++	
				v++			
			}			
			minindex(S_j,1,EstBreakDate=.,w=.)
			minSSR = S_j[EstBreakDate]	
			truebreaks = EstBreakDate
			
		}
		else if (Nbreaks > 1) {
		    "general case"
			/// general case; Nbreaks number of breaks
			S = asarray_create("real",1)
			SStar = asarray_create("real",1)
			EstBreakDate = asarray_create("real",1)

			/// hack; use minlength instead of q (number of variables with breaks)
			lambda = q

			/// first break point
			l = 0
			///k = (l+1)*lambda
			k = l*lambda + 1
			k_end = T - (Nbreaks-l-1) * lambda
			
			S_j = J(T,T,.)
			/// inital problem
			while (k<=k_end) {
				j = (l+1)*lambda
				j_end = k - lambda				
				while (j<=j_end) {
					S_j[j,k] = SSRm[1,j] + SSRm[j+1,k]
					j++
				}			
				k++
			}
			
			asarray(S,l+1,S_j)
			minindex2(S_j,minSSR=.,breakdate_i=.)
			asarray(SStar,l+1,minSSR)
			asarray(EstBreakDate,l+1,breakdate_i)
			
			/// repeated subproblem
			l = 1
			l_end = Nbreaks - 2
			while (l <= l_end) {
				
				S_j = J(T,T,.)
				
				///k = (l+1)*lambda
				k = l*lambda + 1
				k_end = T- (Nbreaks-l-1)*lambda
							
				while (k<=k_end) {					
					j = (l+1)*lambda
					j_end = k - lambda
					Sstar_i = asarray(SStar,l)'
					while (j<=j_end) {						
						S_j[j,k] = Sstar_i[.,j] + SSRm[j+1,k]
						j++
					}
					k++
				}				
				asarray(S,l+1,S_j)
				minindex2(S_j,minSSR=.,breakdate_i=.)
				asarray(SStar,l+1,minSSR)
				asarray(EstBreakDate,l+1,breakdate_i)				
				l++
			}
			"final prob"
			/// final problem
			l = Nbreaks-1
			k = T
			j = (l+1)*lambda
			j_end = k - lambda
			S_j = J(T,T,.)
			
			Sstar_i = asarray(SStar,l)'
			
			while (j<=j_end) {
				S_j[j,k] = Sstar_i[.,j] + SSRm[j+1,T]
				j++
			}
			asarray(S,l+1,S_j)
			minindex2(S_j,minSSR=.,breakdate_i=.)
			asarray(SStar,l+1,minSSR)
			asarray(EstBreakDate,l+1,breakdate_i)
			
			/// only last array because last array contains sums of the SSRs			
			minssrj = asarray(SStar,l+1)
			minSSR = min(minssrj)
			
			/// collect breaks points
			truebreaks = J(1,Nbreaks,.)
			truebreaks[1,Nbreaks] = (asarray(EstBreakDate,Nbreaks))[T,1]		
			
			tt = 1
			while (tt<=Nbreaks) {
				tt
				asarray(SStar,tt),asarray(EstBreakDate,tt)
				tt++
			}


			i = 1			
			i_end = Nbreaks-1
			while (i <=i_end) {	
				j = Nbreaks - i
				break_i = asarray(EstBreakDate,j)
				truebreaks[1,j] = break_i[truebreaks[1,j+1],1]				
				i++
			}
			
			
			/// check if truebreaks only missings, if so, test cannot be done
			if (missing(truebreaks) == cols(truebreaks)) {
			    "missings, too many break points"
			    truebreaks = .
				exit(0)
			}
		}
		else {
			/// special case no break; just use SSR and no breaks
			"no break case"
			truebreaks = 0
			minSSR = SSR(Y,zstar,.,N)
			"SSR is"
			minSSR
		}
	"dynamic prog done"
	}
end



*** returns min index for matrix
capture mata mata drop minindex2()
mata:
	function minindex2 (real matrix mat, real matrix mins, real matrix index)
	{
	    real scalar K
		real scalar k
		real scalar matj 
		real scalar mati
		
		K = cols(mat)
		k = 1
		mins = J(K,1,.)
		index = J(K,1,.)
		while (k<=K) {
			matj = mat[.,k]

		    mati = order(matj,1)

			mins[k,1] = matj[mati[1,1],1]
			if (mins[k,1] != .) {
				index[k,1] = mati[1,1]
			}

			k++
		} 
		
		
	}

end

// -------------------------------------------------------------------------------------------------
// partial out program
// -------------------------------------------------------------------------------------------------



capture mata mata drop mult_partialout()
mata:
	function mult_partialout(	real matrix Y,				///
								real matrix X,				///
								real matrix W,				///
								real matrix csa,			///
								real matrix csaNB,			///
								real matrix idt,			///	
								real scalar N,				///
								real scalar T,				///
								real scalar NT,				///
								real scalar ConstantType,	///
								real scalar p,				///
								real scalar s,				///
								real matrix shapeMat,		///
								real scalar partialCsa,		///
								real scalar partialX,		///
								real matrix Yt,				///
								real matrix Wt,				///
								real matrix Xt,				///
								real scalar num_partial		///
								)
	{
		/// make copies
		Yt = Y
		Xt = X
		Wt = W
		"start partial out"
		num_partial = 0

		if (ConstantType == 1) {
			"no break in constant"
			/// no break in constant, add to X
			///Xt = constant = J(NT,1,1), X
			///Xt = X
			///p =  cols(Xt)
		}
		else if (ConstantType == 2) {
			"break in constant"
			/// break in constant
			///constant = (J(N,1,1)#shapeMat#J(1,1,1)) :* (J(1,(s+1),1)#J(NT,1,1))
			///Wt = constant, Wt
			///Wt = J(rows(W),1,1), Wt
		}
		else if (ConstantType == -1) {
			"constant included in Z"
		}
		
		if (ConstantType == 9999) {
			
			if (N > 1) {
				"Partial out constant, N > 1"
				/// partial constant out for each cross-section
				tilde = xtdcce_m_partialout2((Yt,Wt,Xt),constant,idt[.,1],0,tmp=.)
				Yt = tilde[.,1]
				Wt = tilde[.,2..1+cols(Wt)]
				if (p > 0) {
					Xt = tilde[.,1+cols(Wt)+1..cols(tilde)]
				}
			}
			else {
				"Partial out constant, N = 1"
				Mx = I(T) - constant * m_xtdcce_inverter(quadcross(constant,constant))*constant'
				Yt = Mx * Yt
				Wt = Mx * Wt
				if (p > 0){
					Xt = Mx * Xt
				}
				tmp = 1
			}
			num_partial = tmp
			"constant removed"
		}

		/// partial out cross-sectional averages, assumption the CSA have heterogenous factor loadings!
		/// count here partialed out variables
		
		if (partialCsa == 1) {
			"partial out variables with breaks and CSA"
			csaI = (J(N,1,1)#shapeMat#J(1,cols(csa),1)) :* (J(1,(s+1),1)#csa)
				
			tilde = xtdcce_m_partialout2((Yt,Wt,Xt),( csaI, csaNB),idt[.,1],0,num_partialCSA)
						
			Yt = tilde[.,1]
			/// correct Wt for zero columns, should only use blockdiagonal matrix, but this is faster and equivalent?
			Wt = tilde[.,2..1+cols(Wt)]
			
			if (p > 0) {
				Xt = tilde[.,1+cols(Wt)+1..cols(tilde)]
			}
			num_partial = num_partial+num_partialCSA
		}
		
		/// Partial out X variables, assumption homogenous slopes!
		/// num_partial does not need to be adjusted, variables included in p
		if (partialX ==1 & p > 0) {
			"partial out constant variables (X)"
			XX = quadcross(Xt,Xt)
			Qx = I(rows(Wt)) - Xt * m_xtdcce_inverter(XX) * Xt'
			Yt = Qx * Yt
			Wt = Qx * Wt
			///num_partial = num_partial+cols(Xt)
		}
	}
end


** auxiliary file with auxiliary programs
findfile "xtbreak_auxiliary.ado"
include "`r(fn)'"

** Variance Covariance Estimator
findfile "xtbreak_VarCov.ado"
include "`r(fn)'"

** Critical Values
findfile "_critval.ado"
include "`r(fn)'"
