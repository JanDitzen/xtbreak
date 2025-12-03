*! xbtreak estimate program
program define xtbreak_estimate, eclass
	syntax varlist(min=1 ts) [if] , [			///
		] breaks(numlist) [					/// number of breaks
		csd									/// add cross-sectional averages
		/// unknow breaks
		csa(string)							/// cross-sectional averages to add; support dynamic panel, i.e. csa removed
		CSANObreak(string)					/// cross-sectional averages with no break		
		KFactors(varlist ts)				/// known factors with breaks
		NBKFactors(varlist ts)				/// known factors without breaks
		/// breaks and variables
		NOBREAKVARiables(varlist ts)		/// constant variables
		NOCONStant							/// no constant
		BREAKCONStant						/// constant has break
		BREAKFixedeffects					/// break in fixed effects
		NOFixedeffects 						/// if fixed effects are part of the model
		vce(string)	varestimator(string)	/// empty for standard, kw/nw for newey west, np for non parametric (Pesaran 2006), HC for hc [only N=1], SSR for SSR [only N=1] 
		/// trend
		trend								/// add linear trend without break
		breaktrend							/// add linear trend with break
		/// settings dynamic program
		TRIMming(real 0.15)					/// minimal time periods without a break
		error(real 1e-5)					/// error margin
		region(string)						/// start and end of searching for breaks
		/// output
		showindex 							/// display index rather than breakpoint as CI
		/// internal options				
		trace								/// show output
		forcefe								/// internal option: allows for fixed effects with constant
		FORCECONstant						/// forces constant
		allowunbalanced						/// allows unbalanced data
		NOREWEIGH							/// reweight in case of unabalanced data
		donotdisptrim						/// do not show trimming at bottom
		python								/// use python to calculate SSR
		INVerter(string)					/// favour precision over speed; options: speed (default), precision, qr, chol, p or lu
		NODEPLAG							/// do not check if lag of dep var used
	]

		*** mark sample
		tempname touse
		marksample touse

		************************************************
		**** Checks
		************************************************
		/* Inverter:
		-1 Speed (invsym)
		0 Precision QR
		1 Chol
		2 LU
		3 P (Moore Penrose)
		*/

		if "`inverter'" == "speed" local inverter = -1 
		else if "`inverter'" == "precision" | "`inverter'" == "qr"  local inverter = 0
		else if "`inverter'" == "chol" local inverter = 1
		else if "`inverter'" == "lu" local inverter = 2
		else if "`inverter'" == "p" local inverter = 3
		else local inverter = -1

		if "`breaks'" == "0" {
			ereturn scalar num_breaks = 0
			exit
		}

		if "`python'" != "" {
			xtbreak_pycheck
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
			disp "varlist is `varlist'"
			local varlist_o `varlist'

			if "`vce'" == "" local vce ssr
			else if "`vce'" == "" & "`varestimator'" != "" {
				local vce "`varestimator'"
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
			else  if strlower("`vce'") == "wpn" | {
				local vce = 5
			}
			else {
				noi disp "Invalid choice for variance estimator. Default set to SSR."
				/// standard case; for panel switch to KW; for time series to ssr 
				local vce = 99
			}
			
			*** check for impossible options
			if wordcount("`varlist'") == 1 {
				if "`breakconstant'" == "" {
					noi disp "No variable(s) to test."
					error 100
				}
				if "`breakfixedeffects'" != "" {
					noi disp "Break in model with only fixed effects not possible."
					error 100
				}
			}
			if "`noconstant'" != "" & "`breakconstant'" != "" {
				noi disp "Options noconstant and breakconstant cannot be combined."
				error 184
			}
			if "`nofixedeffects'" != "" & "`breakfixedeffects'" != "" {
				noi disp "Options nofixedeffects and breakfixedeffects cannot be combined."
				error 184
			}
			
			
			if "`level'" == "" {
				local level =  c(level)/100
			}
			
			*** check if tsset or xtset and sorted
			cap _xt
			if _rc == 0 {
				xtset
				local tvar_o `r(timevar)'
				local idvar `r(panelvar)'	
				local idvars `idvar'
				local IsPanel = 0
				
				if 	`r(imax)' != `r(imin)' | "`idvar'" != "" {
					local IsPanel = 1
				}

				_xtstrbal `idvar' `tvar_o' `touse'
				if "`r(strbal)'" != "yes" {
					noi disp in ye "Panel is unbalanced or has missing values in variables. SSRs reweighed to account for missings, see help file."
				}

				*** Only internal/testing option!
				/*
				if "`allowunbalanced'" != "" { 
					noi disp as error "OPTION NOT OFFICIALY SUPPORTED!!! "
					/*
					tempvar ino
					gen `ino' = 1
					tsfill, full
					tsrevar `varlist', list 
					foreach var in `r(varlist)' `nobreakvariables'  {
						replace `var' = 0 if `ino' == .
					} 
					markout `touse' `varlist'
					drop `ino' 
					xtset*/
					
				}
				else {
					_xtstrbal `idvar' `tvar_o' `touse'
					if "`r(strbal)'" != "yes" {
						noi disp as error "Panel is unbalanced or has missing values in variables. Balanced panels are required."
						error(498)
					}
				}
				*/
				
			}
			else{
				tsreport if `touse'
				if "`r(N_gaps)'" != "0" {
					noi disp as error "Time Series contains gaps. Gaps are not allowed."
					error(498)
				}
				tsset
				if "`r(panelvar)'" == "" {	
					tempvar idvar_bogus
					gen `idvar_bogus' = 1
					local tvar_o `r(timevar)'
					local idvar `idvar_bogus'
					local idvars  
					local IsPanel = 0
				}
				else {
					local IsPanel = 1
				}
			}
			
			if `IsPanel' == 0 {
				if "`csa'" != "" | "`csanobreak'" != "" | "`csd'" != "" {
					noi disp as error "Options csa, csanobreak or csd can only be used in panels."
					local csa ""
					local csanobreak ""
					local csd ""
				}
			}	
			issorted `idvars' `tvar_o'
			
			*** Additional check if panel model used and only breakconstant specified, assumption is no fixed effects
			if "`breakconstant'" != "" & `IsPanel' == 1 & "`nofixedeffects'" == "" {
				noi disp "Option {cmd:nofixedeffects} assumed."
				local nofixedeffects "nofixedeffects"				
			}
		
			
			*** tsset varlist 
			issorted `idvars' `tvar_o'
			tsrevar `varlist'
			local indepdepvars "`r(varlist)'"

			*** Check if nobreakvar and depvars include same vars
			local check_all_vars: list indepdepvars & nobreakvariables
			if "`check_all_vars'" != "" {
				noi disp as error "Variable(s) `check_all_vars' defined as breaking and non-breaking."
				error 198
			}
			
			*** Check for lag of dep var and collinearity
			gettoken tmp1 tmp2: indepdepvars
			_rmcoll `tmp2' `nobreakvariables' L.`tmp1'  if `touse'
			if r(k_omitted) > 0 & regexm("`r(varlist)'","oL.`tmp1'") & "`nodeplag'" == "" {
				_rmcoll L.`tmp1' `tmp2' `nobreakvariables' if `touse' , forcedrop
				local Ltmp `tmp2' `nobreakvariables' 
				local Ltmp2 `r(varlist)'
				local dropped_var: list Ltmp2 - Ltmp
				*noi disp as error "Warning: lagged dependent variables not allowed in the panel case. Remove the lagged dependent variable and specify an appropriate vce option. Serial correlation in panels is dealt through the error variance-covariance matrix."
				if `IsPanel' == 1 local LagDepWarningMSG "Warning: lagged dependent variables not allowed in the panel case. Remove the lagged dependent variable and specify an appropriate vce option. Serial correlation in panels is dealt through the error variance-covariance matrix."
			}
			else if r(k_omitted) > 0 {
				noi _rmcoll `indepdepvars' `nobreakvariables'  if `touse'
				local tmpvarlist `r(varlist)'
				local indepdepvars: list indepdepvars & tmpvarlist
				local nobreakvariables: list nobreakvariables & tmpvarlist

			}
			else {
				noi _rmdcoll `indepdepvars' `nobreakvariables' if `touse'
				local tmpvarlist `tmp1' `r(varlist)'
				local indepdepvars: list indepdepvars & tmpvarlist
				local nobreakvariables: list nobreakvariables & tmpvarlist
			}

			*** adjust touse
			markout `touse' `indepdepvars'

			*** create cross-sectional averages
			*** main csd option - will overwrite csa and csanobreak!
			if "`csd'" != "" {
				*** use gettoken to get only RHS vars
				gettoken tmp1 tmp2: indepdepvars
				*local csa "`tmp2'"
				*local csanobreak "`nobreakvariables'"
				issorted `idvars' `tvar_o'
				hascommonfactors `tmp2' if `touse' , tvar(`tvar_o') idvar(`idvar') localname(csa) localnamek(kfactorsauto)
				issorted `idvars' `tvar_o'
				hascommonfactors `nobreakvariables' if `touse' , tvar(`tvar_o') idvar(`idvar') localname(csanobreak) localnamek(nbkfactorsauto)
			}
			local num_csanb = 0
			local num_csa = 0
			
			if "`csa'" != "" {
				issorted `idvars' `tvar_o'
				tempname csa_name1 csa_name2
				local 0 `csa'
				syntax varlist(ts) , [lags(numlist)  EXCludecsa ]
				
				if "`lags'" == "" { 
					local lags "0"
				}
				
				if "`excludecsa'" == "" {
					local dyn1 "dyn"
				}

				
				issorted `idvars' `tvar_o'
				get_csa `varlist' , idvar("`idvar'") tvar("`tvar_o'") cr_lags("`lags'") touse(`touse') csa("`csa_name1'")
				
				local csa_list "`r(varlist)'"
				local num_csa = wordcount("`csa_list'")
				issorted `idvars' `tvar_o'
				tsunab varname_csa_list : `varlist'
				
			}
			
			if "`kfactors'" != "" {
				tsunab kfactors: `kfactors'
				hascommonfactors `kfactors'  if `touse' , tvar(`tvar_o') idvar(`idvar') localname(check) localnamek(tmp)
				if "`check'" != "" noi disp in ye "Variable `check' not constant across units. Variable not a common factor!"
				local csa_list "`csa_list' `kfactors' `kfactorsauto'"
			}

			if "`csanobreak'" != "" {
				issorted `idvars' `tvar_o'
				tempname csanb_name1 csanb_name2
				local 0 `csanobreak'
				syntax varlist(ts) , [lags(numlist)  EXCludecsa ]
				
				if "`lags'" == "" { 
					local lags "0"
				}
				
				if "`excludecsa'" == "" {
					local dyn2 "dyn"
				}
				get_csa `varlist' , idvar("`idvar'") tvar("`tvar_o'") cr_lags("`lags'") touse(`touse') csa("`csanb_name1'")
				
				local csanb_list "`r(varlist)'"
				local num_csanb = wordcount("`csanb_list'")
				issorted `idvars' `tvar_o'
				tsunab varname_csanb_list : `varlist'
				
			}

			if "`nbkfactors'" != "" {
				tsunab nbkfactors: `nbkfactors'
				hascommonfactors `nbkfactors'  if `touse' , tvar(`tvar_o') idvar(`idvar') localname(check) localnamek(tmp)
				if "`check'" != "" noi disp in ye "Variable `check' not constant across units. Variable not a common factor!"
				local csanb_list "`csanb_list' `nbkfactors' `nbkfactorsauto'"
			}

			*** internal use: dynamic panel forces dynamic program to remove CSA as well.
			if "`dyn1'`dyn2'" != "" {
				local dynamicpartial = 1
			}
			else {
				local dynamicpartial = 0
			}

			issorted `idvars' `tvar_o'	
			*** check for collinear factors
			if "`csa_list'`csanb_list'" != "" {
				qui _rmcoll `csa_list' `csanb_list' if `touse'
				if r(k_omitted) > 0 {
					noi _rmcoll `csa_list' `csanb_list' if `touse'
					local tmpvarlist `r(varlist)'
					local csa_list: list csa_list & tmpvarlist
					local csanb_list: list csanb_list & tmpvarlist
				}
			} 
			
			issorted `idvars' `tvar_o'		
			markout `touse' `indepdepvars' `nobreakvariables' `csa_list' `csanb_list'

			*** generate new tvar from 1...T
			tempvar tvar
			egen `tvar' = group(`tvar_o') if `touse'
			
			*** constant and fixed effects 
			/*
			Cases 						Options
			1. Fixed Effects 			(noconstant) default
			2. FE with break 			breakfixed (noconstant)
			3. POLS 					nofixedeffects
			4. POLS with break          breakconstant
			5. No FE and no POLS		nofixedeffects noconstant

			*/

			if "`breakconstant'" != "" & "`breakfixedeffects'" != "" {
				noi disp as error "Break in constant and fixed effects at the same time not possible."
				error(199)
			}
			if "`breakfixedeffects'" != "" & wordcount("`indepdepvars'") == 1 {
				noi disp as error "Explanatory variables missing. Model cannot have only fixed effects with breaks."
				error(199)
			}

			local demean = 0
			if `IsPanel' == 1 {
				if "`nofixedeffects'" == "" & "`breakfixedeffects'" == "" {
					*** Standard case 
					*** demean is remove fixed effects; fixed effects are not added to no break csa/observed csa because otherwise always partial model is used
					local demean = 1
					local noconstant noconstant
				}
				else if "`nofixedeffects'" == "" & "`breakfixedeffects'" != "" {
					tempvar fes
					gen double `fes' = 1
					local csa_list `csa_list' `fes'
					///local num_csa = `num_csa' + 1 do not update number of csa, because then FE are in determinsitic csa!
					/// make sure FE are removed even if no other CSA are added!
					local dynamicpartial = 1
					local noconstant noconstant
				}
				if "`forcefe'" 			!= "" local demean = 1
				if "`forceconstant'" 	!= "" local noconstant ""
			}

			if "`noconstant'" == "" {				
				if "`breakconstant'" == "" {
					tempname cons
					gen double `cons' = 1	
					
					if wordcount("`indepdepvars'") > 1 {
						local nobreakvariables `nobreakvariables' `cons'
						
					}
					
					else if wordcount("`indepdepvars'") == 1 {						
						local indepdepvars `indepdepvars' `cons'
						
					}
					
				}
				else {
					*** constant has a break
					*** check if constant only coefficient
					if wordcount("`indepdepvars'") > 1  {						
						tempname cons
						gen double `cons' = 1	
						local indepdepvars `indepdepvars' `cons'

					}
					else {
						*** model with only a constant
						tempname cons

						gen double `cons' = 1	
						local indepdepvars `indepdepvars' `cons'
					}					
				}
			}
					

			*** trend
			if "`trend'`breaktrend'" != "" {
				disp "Trend added"
				tempvar trend
				by `idvar' (`tvar_o'), sort: gen `trend' = _n

				*** Trend is added to CSA lists, will always be assumed as determinsitic
				if "`breaktrend'" != "" {
					local csa_list "`csa_list' `trend'"
				}
				else {
					local csanb_list "`csanb_list' `trend'"
				}
			}

			**** check if break between specific region
			if "`region'" != "" {
				local 0 `region'
				syntax anything(name = region) , [index fmt(string)]
				
				transbreakpoints `region' , `index' tvar(`tvar' `tvar_o') touse("`touse'") format(`fmt')
				local region "`r(index)'" 
			}


			issorted `idvars' `tvar_o'
			tempname EstCoeff EstCov EstBreak EstCI level stats EstSSRMat
			mata xtbreak_EstBreaks("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'",`breaks',`trimming',"`region'",`vce',`demean',(`dynamicpartial',`num_csa',`num_csanb'),`error',1,`EstCoeff'=.,`EstCov'=.,`EstBreak'=.,`EstCI'=.,`EstSSRMat'=.,"`level'", "`stats'","`python'"!="")
			

			mata st_local("`EstBreak'",invtokens(strofreal(`EstBreak'')))
			`trace' transbreakpoints ``EstBreak'' , index tvar(`tvar' `tvar_o') touse("`touse'")
			mata st_matrix("breaks",(strtoreal(tokens("`r(index)'")) \ (strtoreal(tokens("`r(ival)'")))))

			mata st_local("tmp",invtokens(strofreal((1..cols(st_matrix("breaks"))))))
			matrix rownames breaks =  Index TimeValue
			matrix colnames breaks =  `tmp'		 
			
			
			qui sum `tvar_o' if `touse'
			local adj = `r(min)' - 1
			qui xtset
			local deltat = `r(tdelta)'
						
			/// CI, second part is CI in time: Breaks(Time) + Length of CI * delta_t; delta_t is delta of time variable
			mata st_matrix("CI", `EstCI' \ (st_matrix("breaks")[2,.] :+ (`EstCI':-`EstBreak'') :* `deltat' ))
			matrix rownames CI =  Low Up Low Up
			matrix roweq CI = Index Index TimeValue TimeValue
			matrix colnames CI =  `tmp'	

			local timetype : format `tvar_o'

			
		}
		local timetype = subinstr("`timetype'","%","%-",.)
		
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
		local colheader = `colheader' - 15

		disp ""
		disp in smcl as text _col(1) "Estimation of break points"
		disp in smcl as text _col(`colheader') "Number of obs" _col(`colCI2') "= " as result %6.0f `stats'_NT
		if `stats'_N >  1 {
			disp in smcl as text _col(`colheader') "Number of Groups" _col(`colCI2') "= " as result %6.0f `stats'_N
		}
		if `balanced' == 1 & `stats'_N >  1{
			disp in smcl as text _col(`colheader') "Obs per group"  _col(`colCI2') "= " as result %6.0f `stats'_T
		}
		else if `stats'_N >  1{
			dis "" 
			disp in smcl as text _col(`colheader') "Obs per group:" 
			disp in smcl as text _col(`=`colheader'+15') "min"  _col(`colCI2') "= " as result %6.0f `stats'_Tmin
			disp in smcl as text _col(`=`colheader'+15') "avg"  _col(`colCI2') "= " as result %6.1f `stats'_Tavg
			disp in smcl as text _col(`=`colheader'+15') "max"  _col(`colCI2') "= " as result %6.0f `stats'_Tmax	
			dis ""
		}
		disp in smcl as text _col(`colheader') "SSR "  _col(`colCI2') "= " as result %9.2f `stats'_minSSR
		disp in smcl as text _col(`colheader') "Trimming "  _col(`colCI2') "= " as result %9.2f `trimming'
		disp in smcl as text "{hline `colMax'}"
		disp in smcl as text _col(3) "#" _col(10) "Index" _col(20) "Date" _col(`colCI1') "[`=`level''% Conf. Interval]"
		disp in smcl as text "{hline `colMax'}"

		forvalues i = 1(1)`breaks'{
			local val = breaks[2,`i']
			local ini = breaks[1,`i']
			///local low = CI[1,`i']+`adj'
			///local up = CI[2,`i']+`adj'
			local low = CI[3,`i']
			local up = CI[4,`i']
			disp in smcl as text _col(3) "`i'" as result  _col(12) "`ini'" _col(20) `timetype' `val' _col(`colCI1') `timetypeCI' `low' _col(`colCI2') `timetypeCI' `up'
		}
		disp in smcl as text "{hline `colMax'}"

		if "`varname_csa_list'`varname_csanb_list'" != "" {
			noi disp as text "Cross-section averages:"
			if "`varname_csa_list'" != "" {
				noi disp "  with breaks: `varname_csa_list'"
			}
			if "`varname_csanb_list'" != "" {
				noi disp "  without breaks: `varname_csanb_list'"
			}
		}

		if "`LagDepWarningMSG'" != "" noi disp as text  "`LagDepWarningMSG'"

		return clear
		ereturn clear

		ereturn post , esample(`touse')

		tsunab vars: `varlist_o'
		gettoken lhs rhs: vars
		ereturn hidden local breakvars "`rhs'"
		ereturn hidden local depvar "`lhs'"
		
		ereturn matrix SSRmat = `stats'_SSRmat

		if "`breaks'" == "1" {
			ereturn matrix SSRvec = `stats'_SSRvec
			
		}
		mata xtbreak_SSRvec = `EstSSRMat'

		ereturn local cmd "`cmd'"
		
		ereturn matrix breaks = breaks
		ereturn matrix CI = CI
		ereturn scalar SSR = `stats'_minSSR

		ereturn hidden local estat_cmd "xtbreak_estat"
		ereturn hidden scalar HasBreakCons = ("`breakconstant'`breakfixedeffects'" != "") 
		if wordcount("`breaks'") == 1 ereturn scalar num_breaks = `breaks'
		else ereturn scalar num_breaks = wordcount("`breaks'")

		/// clear memory
		foreach el in EstCoeff EstCov EstBreak EstCI   EstSSRMat {
			cap mata mata drop `el'
		}


end



** auxiliary file with auxiliary programs
findfile "xtbreak_auxiliary.ado"
include "`r(fn)'"
