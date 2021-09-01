// -------------------------------------------------------------------------------------------------
// xtbreak_estimate
// -------------------------------------------------------------------------------------------------
capture program drop xtbreak_estimate
program define xtbreak_estimate, eclass
	syntax varlist(min=1 ts) [if] , [			///
		] breaks(numlist) [					/// number of breaks
		csd									/// add cross-sectional averages
		/// unknow breaks
		csa(string)							/// cross-sectional averages to add; support dynamic panel, i.e. csa removed
		CSANObreak(string)					/// cross-sectional averages with no break		
		/// breaks and variables
		NOBREAKVARiables(varlist ts)		/// constant variables
		NOCONStant							/// no constant
		BREAKCONSTant						/// constant has break
		NOFIXEDeffects 						/// if fixed effects are part of the model
		vce(string)	varestimator(string)	/// empty for standard, kw/nw for newey west, np for non parametric (Pesaran 2006), HC for hc [only N=1], SSR for SSR [only N=1] 
		/// trend
		trend								/// add linear trend without break
		breaktrend							/// add linear trend with break
		/// settings dynamic program
		MINLength(real 0.15)				/// minimal time periods without a break
		error(real 1e-5)					/// error margin
		/// output
		showindex 							/// display index rather than breakpoint as CI
		/// internal options				
		trace								/// show output
		forcefe								/// internal option: allows for fixed effects with constant
	]

		*** mark sample
		tempname touse
		marksample touse
		
		************************************************
		**** Checks
		************************************************

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
				error 198
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
				noi disp "Options noconstant and breakconstant cannot be combined."
				error 184
			}
			
			if "`level'" == "" {
				local level =  c(level)/100
			}
			
			*** check if tsset or xtset and sorted
			
			cap _xt
			if _rc == 0 {
				local tvar_o `r(tvar)'
				local idvar `r(ivar)'	
				local idvars `idvar'
				local IsPanel = 0
				xtset
				if 	`r(imax)' != `r(imin)' {
					local IsPanel = 1
				}	
			}
			else{
				tsset
				if "`r(panelvar)'" == "" {	
					local tvar_o `r(timevar)'
					tempvar idvar_bogus
					gen `idvar_bogus' = 1
					local idvar `idvar_bogus' 
				}
				local IsPanel = 0
			}			
			issorted `idvars' `tvar_o'
			
			*** generate new tvar from 1...T
			tempvar tvar
			egen `tvar' = group(`tvar_o') if `touse'
			
			*** tsset varlist 
			issorted `idvars' `tvar_o'
			tsrevar `varlist'
			local indepdepvars "`r(varlist)'"
			
			*** adjust touse
			markout `touse' `indepdepvars'

			*** fixed effects in panel data. cases:
			/*
				1. Only Fixed Effects 
				2. Fixed Effects + Constant [no breaks] 
				3. Fixed Effects + Constant [break in constant]
				4. Only Constant [no break]
				5. Only Constant [break]
				6. No fixed effect and Constant


			*/
			local demean = 0
			if `IsPanel' == 1 {

				if  "`nofixedeffects'" == "" & "`breakconstant'" == "" {
					/// fixed effects model
					local demean = 1
					local noconstant noconstant
				}
				
				if "`nofixedeffects'" == "" & "`breakconstant'" != ""  & "`forcefe'" == "" {
					noi disp "Fixed Effects Model cannot have break in constant."
					error 184
				}

				if "`forcefe'" != "" {
					local demean = 1
				}

				/* 
				Alterantive is 
				*/
				*if "`noconstant'" == "" {
				*	local noconstant noconstant
				*} 
			}
			
			*** create cross-sectional averages

			*** main csd option - will overwrite csa and csanobreak!
			if "`csd'" != "" {
				*** use gettoken to get only RHS vars
				gettoken tmp1 tmp2: indepdepvars
				*local csa "`tmp2'"
				*local csanobreak "`nobreakvariables'"
				hascommonfactors `tmp2' if `touse' , tvar(`tvar') idvar(`idvar') localname(csa)

				hascommonfactors `nobreakvariables' if `touse' , tvar(`tvar') idvar(`idvar') localname(csanobreak)
			}
			local num_csanb = 0
			local num_csa = 0

			/// Syntax for csa():
			/*
				deterministic(varlist)	: sets csa which are deterministic
				deterministicindic		: if all csa are deterministic
				excludecsa				: excludes csa from dynamic program

			*/

			if "`csa'" != "" {
				tempname csa_name1 csa_name2
				local 0 `csa'
				syntax varlist(ts) , [lags(numlist) DETERministic(varlist ts) DETERministicindic EXCludecsa ]
				
				if "`lags'" == "" { 
					local lags "0"
				}
				
				if "`excludecsa'" == "" {
					local dyn1 "dyn"
				}

				if "`deterministicindic'" != "" {
					local deterministic "`varlist'"
					local varlist ""
				}

				*** remove all variables from varlist which are part of dynamic
				local varlist : list varlist - deterministic
			
				if "`varlist'" != "" {		
*issorted `idvars' `tvar_o'
					get_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name1'")
				
					local csa_list "`r(varlist)'"
				}
				local num_csa = wordcount("`csa_list'")

				if "`deterministic'" != "" {
					
*issorted `idvars' `tvar_o'							
					get_csa `deterministic' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name2'")

					local csa_list "`csa_list' `r(varlist)'"

				}
			}
			
			if "`csanobreak'" != "" {
				issorted `idvars' `tvar_o'
				tempname csanb_name1 csanb_name2
				local 0 `csanobreak'
				syntax varlist(ts) , [lags(numlist) DETERministic(varlist ts) DETERministicindic EXCludecsa ]
				
				if "`lags'" == "" { 
					local lags "0"
				}
				
				if "`excludecsa'" == "" {
					local dyn2 "dyn"
				}

				if "`deterministicindic'" != "" {
					local deterministic "`varlist'"
					local varlist ""
				}

				*** remove all variables from varlist which are part of dynamic
				local varlist : list varlist - deterministic

				if "`varlist'" != "" {
*issorted `idvars' `tvar_o'					
					get_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csanb_name1'")
				
					local csanb_list "`r(varlist)'"
				}
				local num_csanb = wordcount("`csanb_list'")

				if "`deterministic'" != "" {

					
*issorted `idvars' `tvar_o'						
					get_csa `deterministic' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csanb_name2'")

					local csanb_list "`csanb_list' `r(varlist)'"

				}
			}

			*** internal use: dynamic panel forces dynamic program to remove CSA as well.
			if "`dyn1'`dyn2'" != "" {
				noi disp "WARNING: CSA will be removed in dynamic program to find breaks!"
				local dynamicpartial = 1
			}
			else {
				local dynamicpartial = 0
			}

			markout `touse' `indepdepvars' `nobreakvariables' `csa_list' `csanb_list'
				
			

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
			

			*** trend
			if "`trend'`breaktrend'" != "" {
				disp "Trend added"
				tempvar trend
				by `idvar' (`tvar_o'), sort: gen `trend' = _n

				*** Trend is added to CSA lists, will always be assumed as determinsitic
				if "`breaktrend'" == "" {
					local csa_list "`csa_list' `trend'"
				}
				else {
					local csanb_list "`csanb_list' `trend'"
				}
			}

			issorted `idvars' `tvar_o'
			tempname EstCoeff EstCov EstBreak EstCI level stats
			mata EstBreaks("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'",`breaks',`minlength',`vce',`ConstantType',`demean',(`dynamicpartial',`num_csa',`num_csanb'),`error',1,`EstCoeff'=.,`EstCov'=.,`EstBreak'=.,`EstCI'=.,"`level'", "`stats'")
			

			mata st_local("`EstBreak'",invtokens(strofreal(`EstBreak')))
			`trace' transbreakpoints ``EstBreak'' , index tvar(`tvar' `tvar_o') touse("`touse'")
			mata st_matrix("breaks",(strtoreal(tokens("`r(index)'")) \ (strtoreal(tokens("`r(ival)'")))))

			mata st_local("tmp",invtokens(strofreal((1..cols(st_matrix("breaks"))))))
			matrix rownames breaks =  Index TimeValue
			matrix colnames breaks =  `tmp'		 
			
			mata st_matrix("CI",`EstCI')
			
			qui sum `tvar_o' if `touse'
			local adj = `r(min)' - 1
			mata st_matrix("CI", `EstCI' \ `EstCI' :+`adj')
			matrix rownames CI =  Low Up Low Up
			matrix roweq CI = Index Index TimeValue TimeValue
			matrix colnames CI =  `tmp'	



			*mata st_matrix("b",`EstCoeff')
			*tsunab vars: `varlist'
			*gettoken lhs rhs: vars
			*matrix rownames b = `tmp' `=`breaks' + 1'
			*matrix colnames b = `rhs'

			local timetype : format `tvar_o'

			
		}
		local timetype = subinstr("`timetype'","%","%-",.)
		tokenize ``stats''
		local N = `1'
		local T = `2'
		local minSSR = `3'
		/// Output
		if "`showindex'" == "" {
			local dispCI "`timetype'"
			local timetypeCI "`timetype'"

			local colCI1 = 50
			local colCI2 = 65
			local colheader = 60
			local colMax = 80
			qui sum `tvar_o' if `touse'
			local adj = `r(min)' - 1

		}
		else {
			local colCI1 = 40
			local colCI2 = 55
			local colheader = 50
			local colMax = 70
			local adj = 0
		}

		disp ""
		disp in smcl as text _col(2) "Estimation of break points"
		if `N' >  1 {
			disp in smcl as text _col(`colheader') "N" _col(`colCI2') "= " as result %6.0f `N'
		}
		disp in smcl as text _col(`colheader') "T"  _col(`colCI2') "= " as result %6.0f `T'
		disp in smcl as text _col(`colheader') "SSR "  _col(`colCI2') "= " as result %9.2f `minSSR'
		disp in smcl as text "{hline `colMax'}"
		disp in smcl as text _col(3) "#" _col(10) "Index" _col(20) "Date" _col(`colCI1') "[``level''% Conf. Interval]"
		disp in smcl as text "{hline `colMax'}"

		forvalues i = 1(1)`breaks'{
			local val = breaks[2,`i']
			local ini = breaks[1,`i']
			local low = CI[1,`i']+`adj'
			local up = CI[2,`i']+`adj'
			disp in smcl as text _col(3) "`i'" as result  _col(12) "`ini'" _col(20) `timetype' `val' _col(`colCI1') `timetypeCI' `low' _col(`colCI2') `timetypeCI' `up'
		}
		disp in smcl as text "{hline `colMax'}"

		ereturn clear

		ereturn post , esample(`touse')

		tsunab vars: `varlist'
		gettoken lhs rhs: vars
		ereturn hidden local breakvars "`rhs'"
		ereturn hidden local depvar "`lhs'"
		ereturn hidden local cmd "estimate"
		
		ereturn matrix breaks = breaks
		ereturn matrix CI = CI

		ereturn hidden local estat_cmd "xtbreak_estat"



end


// -------------------------------------------------------------------------------------------------
// EstBreaks
// -------------------------------------------------------------------------------------------------
// estimate breaks

capture mata mata drop EstBreaks()
mata:
	function EstBreaks(		string scalar varnames, 	///
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
							real matrix dynamicpartial,	///
							real scalar errror,			///
							real scalar postmsg,		/// display message
							real matrix EstCoeff,		/// matrix with estiamted coefficients
							real matrix EstCov,			/// variance / covariance matrix
							real matrix EstBreak,		/// estimated breaks
							real matrix EstCI,			///
							string scalar levelname,	/// 
							string scalar stats			///
						)
	{
		/// Load Data
		LoadData(varnames,Xvarn,csanames,csaNBnames,idtname,tousename,Y=.,Z=.,X=.,csa=.,csaNB=.,idt=.,N=.,T=.,partial=dynamicpartial)
		idt
		/// Get estimated number of breaks and estimated break dates using smallest SSR
		GetBreakPoints(Y,X,Z,idt,csa,csaNB,numbreaks,errror,ConstantType,demean,partial,min,EstBreak=.,EstCoeff=.,finalbeta=.,minSSR=.)		


		CalcCI(Y,Z,X,csa,csaNB,idt,N,T,varestimator,ConstantType,demean,partial,numbreaks,EstBreak,EstCI=.,level=.)

		st_local(levelname,strofreal(100-level))

		st_local(stats,invtokens(strofreal((N,T,minSSR))))

		stats = N,T,minSSR


	}
end


// -------------------------------------------------------------------------------------------------
// CalcCI
// -------------------------------------------------------------------------------------------------
capture mata mata drop CalcCI()
mata:
	function CalcCI(	///
						real matrix Y,
						real matrix W,
						real matrix X,
						real matrix csa,
						real matrix csaNB,
						real matrix idt,
						real scalar N,
						real scalar T,
						real scalar varestimator,		///
						real scalar ConstantType,		///
						real scalar demean,				/// 
						real matrix partial,
						real scalar BreaksNum,
						real matrix BreakDates,
						real matrix EstCI,
						real scalar level
					)
	{
		partial_Bknown(Y,W,X,BreakDates,idt,partial,csa,csaNB,N,T,ConstantType,demean,Yt=.,Wt=.,R=.,s=.,q=.,p=.,num_partial=.)

		breakpointsI = BreakDates,T
		shapeMat = BreakMat((BreakDates,T),T,s)	

		/// estimate CCEP and get variance
		SSR = SSR(Yt,Wt,idt,N,beta_p=.,cov_p=.,1)
		
		level = 100-c("level")
		level
		if (level == 1) cval = 20
		else if (level == 5 ) cval = 11
		else if (level == 10) cval = 7
		else {
			cval = 11
			level = 5
		}


		if (N > 1) {
			omega = J(cols(W),cols(W),0)
			i = N
			while (i>0) {
				wi = panelsubmatrix(W,i,idt)
				omega = omega + quadcross(wi,wi) :/ (N*T)

				i--

			}
			sigma2 = SSR :/ (N*(T-q-q*(s+1))-p-(s+1)*q)
			Ls = J(s,1,.)
			upper = J(s,1,.)
			lower = J(s,1,.)
			deltaf = rowshape(beta_p,q)
			si = s
			"start loop"
			while (si>0) {			
				Ls[si] = (N*(deltaf[.,si+1]-deltaf[.,si])'*omega*(deltaf[.,si+1]-deltaf[.,si])):/sigma2
				lower[si] = BreakDates[si]- floor(cval/Ls[si])-1
				upper[si] = BreakDates[si]+ floor(cval/Ls[si])+1
				si--
			}
		}
		else {

			/// N = 1
			eps = Y - Wt * beta_p

			deltaf = rowshape(beta_p,q)


			qmat = quadcross(W,W)/(N*T)
			qmat1 = qmat
			
			phi = quadcross(eps,eps)/(N*T)
			phi1 = phi

			lower = J(s,1,.) 
			upper = J(s,1,.)

			si = s
			while (si>0) {	
			si		
				diff = deltaf[.,si+1]-deltaf[.,si]

				middle = (diff'*qmat*diff)^2 * invsym(phi1)
				
				lower[si] = floor(BreakDates[si] - (cval / middle))
				upper[si] = floor(BreakDates[si] - (cval / middle))+1 
				si--
			}
		}
		
		
		
		EstCI = (lower,upper)'
		///return(lower,upper)
		"pro done"
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
