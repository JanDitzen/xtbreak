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
		/// output
		showindex 							/// display index rather than breakpoint as CI
		/// internal options				
		trace								/// show output
		forcefe								/// internal option: allows for fixed effects with constant
		donotdisptrim						/// do not show trimming at bottom
	]

		*** mark sample
		tempname touse
		marksample touse
		
		************************************************
		**** Checks
		************************************************

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
				local tvar_o `r(tvar)'
				local idvar `r(ivar)'	
				local idvars `idvar'
				local IsPanel = 0
				xtset
				if 	`r(imax)' != `r(imin)' {
					local IsPanel = 1
				}
				if "`r(balanced)'" != "strongly balanced" {
					noi disp as error "Only balanced panels allowed."
					error(199)
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
			
			*** Additional check if panel model used and only breakconstant specified, assumption is no fixed effects
			if "`breakconstant'" != "" & `IsPanel' == 1 & "`nofixedeffects'" == "" {
				noi disp "Option {cmd:nofixedeffects} assumed."
				local nofixedeffects "nofixedeffects"				
			}


			*** generate new tvar from 1...T
			tempvar tvar
			egen `tvar' = group(`tvar_o') if `touse'
			
			*** tsset varlist 
			issorted `idvars' `tvar_o'
			tsrevar `varlist'
			local indepdepvars "`r(varlist)'"
			
			*** adjust touse
			markout `touse' `indepdepvars'
			
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
				get_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name1'")
				
				local csa_list "`r(varlist)'"
				local num_csa = wordcount("`csa_list'")
				issorted `idvars' `tvar_o'
				tsunab varname_csa_list : `varlist'
				
			}
			
			if "`kfactors'" != "" {
				local csa_list "`csa_list' `kfactors'"
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
				get_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csanb_name1'")
				
				local csanb_list "`r(varlist)'"
				local num_csanb = wordcount("`csanb_list'")
				issorted `idvars' `tvar_o'
				tsunab varname_csanb_list : `varlist'
				
			}

			if "`nbkfactors'" != "" {
				local csanb_list "`csanb_list' `nbkfactors'"
			}

			*** internal use: dynamic panel forces dynamic program to remove CSA as well.
			if "`dyn1'`dyn2'" != "" {
				local dynamicpartial = 1
			}
			else {
				local dynamicpartial = 0
			}
			
			issorted `idvars' `tvar_o'		
			markout `touse' `indepdepvars' `nobreakvariables' `csa_list' `csanb_list'
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
				if "`forcefe'" != "" local demean = 1
			}



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
					if wordcount("`indepdepvars'") > 1  {
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
				if "`breaktrend'" != "" {
					local csa_list "`csa_list' `trend'"
				}
				else {
					local csanb_list "`csanb_list' `trend'"
				}
			}

			issorted `idvars' `tvar_o'
			tempname EstCoeff EstCov EstBreak EstCI level stats
			mata xtbreak_EstBreaks("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'",`breaks',`trimming',`vce',`ConstantType',`demean',(`dynamicpartial',`num_csa',`num_csanb'),`error',1,`EstCoeff'=.,`EstCov'=.,`EstBreak'=.,`EstCI'=.,"`level'", "`stats'")
			

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
		disp in smcl as text _col(1) "Estimation of break points"
		if `N' >  1 {
			disp in smcl as text _col(`colheader') "N" _col(`colCI2') "= " as result %6.0f `N'
		}
		disp in smcl as text _col(`colheader') "T"  _col(`colCI2') "= " as result %6.0f `T'
		disp in smcl as text _col(`colheader') "SSR "  _col(`colCI2') "= " as result %9.2f `minSSR'
		disp in smcl as text _col(`=`colheader'-5') "Trimming "  _col(`colCI2') "= " as result %9.2f `trimming'
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

		if "`varname_csa_list'`varname_csanb_list'" != "" {
			noi disp as text "Cross-section averages:"
			if "`varname_csa_list'" != "" {
				noi disp "  with breaks: `varname_csa_list'"
			}
			if "`varname_csanb_list'" != "" {
				noi disp "  without breaks: `varname_csanb_list'"
			}
		}


		ereturn clear

		ereturn post , esample(`touse')

		tsunab vars: `varlist_o'
		gettoken lhs rhs: vars
		ereturn hidden local breakvars "`rhs'"
		ereturn hidden local depvar "`lhs'"
		ereturn hidden local cmd "estimate"
		
		ereturn matrix breaks = breaks
		ereturn matrix CI = CI

		ereturn hidden local estat_cmd "xtbreak_estat"



end


** auxiliary file with auxiliary programs
findfile "xtbreak_auxiliary.ado"
include "`r(fn)'"
