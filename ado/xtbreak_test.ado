*! xbtreak test program
program define xtbreak_test, rclass
	syntax varlist(min=1 ts) [if] , [			///
			Hypothesis(string)					/// which hypothesis to test
			wdmax								/// if hypothesis 2, do weighted UDmax test instead of UDmax	
			/// unknow breaks
			breaks(string)						/// number of breaks under alternative
			TRIMming(real 0.15)				/// minimal time periods without a break
			region(string)						/// region to look for if breaks are unknown
			level(string)						/// level for p-value (hypothesis 2)
			error(real 0.0001)					/// error margin
			SEQuential							/// do sequentiual test for H3 with max breaks defined by breaks
			/// knwon breaks
			BREAKPoints(string)					/// periods of breakpoints
			/// general variable options	
			NOBREAKVARiables(varlist ts)		/// constant variables
			NOCONStant							/// no constant
			BREAKCONStant						/// constant has break
			BREAKFixedeffects					/// break in fixed effects
			NOFixedeffects 						/// if fixed effects are part of the model
			vce(string)	varestimator(string)	/// empty for standard, kw/nw for newey west, np for non parametric (Pesaran 2006), HC for hc [only N=1], SSR for SSR [only N=1] 
			/// trend
			trend								/// add linear trend without break
			breaktrend							/// add linear trend with break
			/// csa
			csd									/// add cross-sectional averages
			csa(string)							/// cross-sectional averages to add; support dynamic panel, i.e. csa removed
			CSANObreak(string)					/// cross-sectional averages with no break
			KFactors(varlist ts)				/// known factors with breaks
			NBKFactors(varlist ts)				/// known factors without breaks
			/// internal options				
			trace								/// show output
			showindex 							/// display index rather than breakpoint
			forcefe								/// internal option: allows for fixed effects with constant
			FORCECONstant						/// forces constant		
			allowunbalanced						/// allows unbalanced data
			NOREWEIGH							/// reweight in case of unabalanced data
			donotdisptrim						/// do not show trimming at bottom
			PYTHONdum							/// use python
			python(string)						/// specify parallel cores; -1/max ; 0 no python; > 0 number of cores
			INVerter(string)					/// favour precision over speed; options: speed (default), precision, qr, chol, p or lu
			/// specific for sequential
			strict								/// enforce strict behaviour
			cvalue(real 0.95)					/// which level to check for strict breaks
			MAXbreaks(real 9999)				/// max number of breaks
			NODEPLAG							/// do not check if lag of dep var used
		]

		
		************************************************
		**** Checks
		************************************************

		*** mark sample
		tempname touse
		marksample touse
		
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
		
		if "`python'`pythondum'" != "" {
			if "`python'" == "max" local python = -1 
			if "`pythondum'" != "" & "`python'" == "" local python = 1			
		}
		else {
			local python = 0
		}

		if `python' > 0 {
			xtbreak_pycheck
		}

		*** main check: are necessary options there?
		local auto = 0

		if "`breakpoints'`breaks'" == "" {
			*noi disp "Option breakpoints or breaks required."
			*error 198
			local breaks = floor(1/`trimming')-1
			if "`hypothesis'" != "2" local hypothesis = 3
			local sequential "sequential"
			local auto = 1
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
		
		if "`hypothesis'" == "" local hypothesis = 1
		if strlower("`hypothesis'") == "a" local hypothesis = 1
		if strlower("`hypothesis'") == "b" local hypothesis = 2
		if strlower("`hypothesis'") == "c" local hypothesis = 3

		if `hypothesis' > 3 {
			noi disp as error "Option hypothesis() has invalid value. Only allows 1, 2 or 3."
			noi disp "Only hypothesis(1|2|3) allowed."
			exit
		}



		`trace' {
			

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
			else  if strlower("`vce'") == "hc"  {
				local vce = 4
			}
			else  if strlower("`vce'") == "wpn" {
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
			if "`level'" != "" {
				if `level' > 1 local level = `level'/100
				if `level' != 0.99 & `level' != 0.975  & `level' != 0.95  & `level' != 0.9 local level 0.95
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
				local statname "supF"
			}
			else if "`hypothesis'" == "2" {
				if "`wdmax'" == "" {
					local wdmax = 0
					local wdmaxName "UDmax"
					local wdmaxRname "UDmax"
				}
				else {
					local wdmax = 1
					local wdmaxName "WDmax"
					local wdmaxRname "WDmax"
				}
				local typename "`wdmaxRname'"
				local statname "`wdmaxName'"
			}
			else if "`hypothesis'" == "3" {
				local typename "fll1"
				local statname "F(s+1|s)*"

				if "`sequential'" == "" {
					local sequential = 0
				}
				else {
					local sequential = 1				
				}
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
				issorted `idvars' `tvar_o'
				*** use gettoken to get only RHS vars
				gettoken tmp1 tmp2: indepdepvars
				*local csa "`tmp2'"
				*local csanobreak "`nobreakvariables'"
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
				syntax [varlist(ts)] , [lags(numlist)  EXCludecsa ]
				
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
				*** check if factors are actually a factor
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

			*local num_s = 0

			if "`breakpoints'" != "" {
				
				local 0 `breakpoints'
				syntax anything(name = breakpoints) , [index fmt(string)]
				
				transbreakpoints `breakpoints' , `index' tvar(`tvar' `tvar_o') touse("`touse'") format(`fmt')
				local breakpoints "`r(index)'" 

			}
			
			if "`region'" != "" {
				local 0 `region'
				syntax anything(name = region) , [index fmt(string)]
				
				transbreakpoints `region' , `index' tvar(`tvar' `tvar_o') touse("`touse'") format(`fmt')
				local region "`r(index)'" 
			}



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
					*local demean = 1
					tempname fes
					gen double `fes' = 1
					local csanb_list `csanb_list' `fes'
					local noconstant noconstant
				}
				else if "`nofixedeffects'" == "" & "`breakfixedeffects'" != "" {
					tempvar fes
					gen double `fes' = 1
					local csa_list `csa_list' `fes'
					///local num_csa = `num_csa' + 1 
					///do not update number of csa, because then FE are in determinsitic csa!
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
			
			if "`breakpoints'" != "" {
				*** Test for hypothesis i)
				tempname testh 				
				`trace'  mata `testh' = xtbreak_Test_Hi_known("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'","`breakpoints'",`vce',`demean')							
			}
			else {
				*** unknown breakpoints

				tempname testh								
				if "`hypothesis'" == "1" {
					tempname EstBreak
					`trace' mata `testh' = xtbreak_Test_Hi_unknown("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'",`breaks',`trimming',"`region'",`vce',`demean',(`dynamicpartial',`num_csa',`num_csanb'),`error',`python',1,`EstBreak'=.,)
				}
				else if "`hypothesis'" == "2" { 
					tempname testh
					`trace' mata `testh' = xtbreak_Test_Hii_unknown("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'","`breaks'",`trimming',"`region'",`vce',`demean',(`dynamicpartial',`num_csa',`num_csanb'),`error',1,`level',`python',`wdmax',`maxbreaks')
				}
				else if "`hypothesis'" == "3" {
					tempname testh
					`trace'  mata `testh' = xtbreak_Test_Hiii_unknown("`indepdepvars'","`nobreakvariables'","`csa_list'","`csanb_list'","`idvar' `tvar'","`touse'",`breaks',`trimming',"`region'",`vce',`demean',(`dynamicpartial',`num_csa',`num_csanb'),`error',`python',`sequential',("`strict'"!="")*`cvalue',`maxbreaks')
				}	
				
			}
		}
		*** Output
		return clear
		disp ""
		if "`breakpoints'" != "" {
			
			tempname wtau pvalF pvalChi 
			mata st_numscalar("`wtau'",`testh'[1,1])

			mata st_numscalar("`pvalF'",1- F(`testh'[1,2]*`testh'[1,3],`testh'[1,5],`testh'[1,1]))
			mata st_numscalar("`pvalChi'",1- chi2(`testh'[1,2]*`testh'[1,3],`testh'[1,1]))

			disp as text " F" _col(15) " = " as result _col(20) %9.2f `wtau'
			disp as text  "	p-value (F)" _col(15) " = " as result  _col(20) %9.2f `pvalF'

			return scalar p = `pvalF'
			return scalar Wtau = `wtau'			
			
		}
		else {
			/*
			tempname ml ml1
			if inlist(`trimming',0.05,0.1,0.15,0.2,0.25) == 0 {
				local trimming_o "`trimming'"
				mata `ml1' = (0.05,0.1,0.15,0.2,0.25)
				mata `ml' = abs(`ml1':-`trimming')
				mata `ml' = selectindex(min(`ml'):==`ml')
				mata `ml1' = `ml1'[`ml']
				mata st_local("trimming",strofreal(`ml1'))
				local minset = 1
				mata mata drop `ml' `ml1'

				
			}
			*/
			mata st_local("SeqN",strofreal(rows(`testh')))

			noi disp as text _col(17) as smcl "{hline 17}" as text _col(35) "Bai & Perron Critical Values" as smcl _col(64) "{hline 17}" 

			noi disp as text _col(22) "Test" _col(36) "1% Critical" _col(52) "5% Critical" _col(67) "10% Critical" 
			noi disp as text _col(19) "Statistic" _col(38) "Value" _col(55) "Value" _col(71) "Value"
			noi disp as text "{hline 80}"

			local last_reject90 = .
			local last_reject95 = .
			local last_reject99 = .

			tempname m_breaks 
			mata `m_breaks' = J(`SeqN',3,.)
 
			forvalues i = 1(1)`SeqN' {
				tempname testhi
				mata `testhi' = `testh'[`i',.]
				

				tempname stat c90 c95 c99 s 
				mata st_numscalar("`stat'",`testhi'[1,1])
				mata st_numscalar("`s'",`testhi'[1,2])
				
				mata st_numscalar("`c90'", xtbreak_GetCritVal(`trimming',0.9,`testhi'[1,2],`testhi'[1,3],"`typename'"))

				mata st_numscalar("`c95'", xtbreak_GetCritVal(`trimming',0.95,`testhi'[1,2],`testhi'[1,3],"`typename'"))

				mata st_numscalar("`c99'", xtbreak_GetCritVal(`trimming',0.99,`testhi'[1,2],`testhi'[1,3],"`typename'"))				
				
				mata `m_breaks'[`i',.] = (`=`c99' < `stat'',`=`c95' < `stat'',`=`c90' < `stat'')

				if `SeqN' > 1 {
					local statname "F(`i'|`=`i'-1')"
				}

				noi disp as text _col(2) "`statname'" as result _col(18) %9.2f `stat' _col(35) %9.2f  `c99'  _col(51)  %9.2f  `c95' _col(67) %9.2f  `c90'

				if `SeqN' == 1 noi disp as text "{hline 80}"

				if `hypothesis' == 1  {
					mata st_local("`EstBreak'",invtokens(strofreal(`EstBreak'')))

					`trace' transbreakpoints ``EstBreak'' , index tvar(`tvar' `tvar_o') touse("`touse'")

					mata st_matrix("breaks",(strtoreal(tokens("`r(index)'")) \ (strtoreal(tokens("`r(ival)'")))))

					mata st_local("tmp",invtokens(strofreal((1..cols(st_matrix("breaks"))))))

					matrix rownames breaks =  Index TimeValue
					matrix colnames breaks =  `tmp'		

					if "`showindex'" == "" {
						noi disp as text "Estimated break points: `r(val)'"
					}
					else {
						noi disp as text "Estimated break points: `=stritrim(``EstBreak'')'"
					}
				}
			
				if `hypothesis' == 2 & "`wdmax'" == "1" {
					noi disp as text "* weights set to level of " %04.2f `level' "."
				}
				if `hypothesis' == 3 & `SeqN' == 1 {				
					noi disp as text "* s = " `s'-1
				}
				*if "`minset'" == "1" {
				*	noi disp as text "No critical values for specified trimming available, set to `trimming'"
				*}
			}			

			*** Return
			local GotMax = 0
			if `hypothesis' == 1 {
				return scalar supWtau = `stat'
				return matrix breaks = breaks				
			}
			else if `hypothesis' == 2 {
				return scalar `wdmaxRname' = `stat'
			}
			else if `hypothesis' == 3 {
				if `SeqN' == 1 {
					return scalar f = `stat'
				}
				else {

					noi disp as text "{hline 80}" 
					*** Get optimals
					
					mata `m_breaks' =  ((`m_breaks'[2..rows(`m_breaks'),.]:== 0) :* (`m_breaks'[1..rows(`m_breaks')-1,.]:==1 )) \  `m_breaks'[rows(`m_breaks'),.]

					local c_Vals 99 95 90

					forvalues i = 1(1)3 {
						local c_valsi = word("`c_Vals'",`i')
						tempname zeros
						mata `zeros' = mm_which(`m_breaks'[.,`i']:==1)

						mata st_local("all_1_`c_valsi'",strofreal(sum(`zeros':==1):==rows(`zeros')))
						mata st_local("all_0_`c_valsi'",strofreal(rows(`zeros'):==0))
						

						if "`all_0_`c_valsi''" != "1" {
							mata st_local("opt`c_valsi'_min",strofreal(`zeros'[1]))	
							mata st_local("opt`c_valsi'_max",strofreal(`zeros'[rows(`zeros')]))	
						}
						else {
							local opt`c_valsi'_min = .
							local opt`c_valsi'_max = .
						}
						mata mata drop `zeros'
					}

					tempname Nbreaks				
					
					`trace' mata `m_breaks'
					if `opt90_min' == `opt90_max' & `opt95_min' == `opt95_max' & `opt99_min' == `opt99_max' {
						noi disp as text "Detected number of breaks: " _col(35) %9.0f  `opt99_min'  _col(51)  %9.0f  `opt95_min' _col(67) %9.0f  `opt90_min'
						matrix `Nbreaks' = (`opt99_min', `opt95_min', `opt90_min')
						matrix colnames `Nbreaks' = 99 95 90

					}
					else {
						noi disp as text "Detected number of breaks: (min)" _col(35) %9.0f  `opt99_min'  _col(51)  %9.0f  `opt95_min' _col(67) %9.0f  `opt90_min'
						noi disp as text _col(28) "(max)" _col(35) %9.0f  `opt99_max'  _col(51)  %9.0f  `opt95_max' _col(67) %9.0f  `opt90_max'

						matrix `Nbreaks' = (`opt99_min', `opt95_min', `opt90_min' \ `opt99_max', `opt95_max', `opt90_max')
						matrix colnames `Nbreaks' = 99 95 90
						matrix rownames `Nbreaks' = min max

					}
					noi disp as text "{hline 80}" 

					if `all_1_99' == 1 & `all_1_95' == 1 & `all_1_90' == 1 {
						mata st_local("tmptxt",strofreal(all(`m_breaks':==0)))
						if `tmptxt' == 1 noi disp as text _col(3) "Maximum number of breaks reached with null always rejected. "
						if `tmptxt' == 0 noi disp as text _col(3) "Maximum number of breaks reached with null always rejected at level of `c(level)'%. "

					}
					else if `all_0_99' == 1 & `all_0_95' == 1 & `all_0_90' == 1 {
						noi disp as text _col(3) "No breaks detected. "
					}
					else if `opt90_min' == `opt90_max' & `opt95_min' == `opt95_max' & `opt99_min' == `opt99_max' {
						noi disp as text "The detected number of breaks indicates the highest number of"
						noi disp as text " breaks for which the null hypothesis is rejected."
					}
					else {
						noi disp as text "Null hypothesis rejected more than once after non-rejection."
						noi disp as text " The detected number of breaks indicates the minimum and maximum"
						noi disp as text " number of breaks for which the null hypothesis is rejected."
					}
					/*
					if `GotMax' == 0 {
						if `end_sum' < 3 {
							noi disp as text "The detected number of breaks indicates the highest number of"
							noi disp as text " breaks for which the null hypothesis is rejected."
						}
						else {
							noi disp as text "The detected number of breaks indicates the highest number of"
							noi disp as text " breaks for which the null hypothesis is first rejected."							
						}
					}
					else {
						noi disp as text _col(3) "Maximum number of breaks reached with null always rejected. "
					}
					*/
					mata st_matrix("f",`testh'[.,1])
					return matrix f = f
					return matrix Nbreaks = `Nbreaks'

				}
			}
			if "`donotdisptrim'" == "" {
				noi disp "Trimming: " %4.2f `trimming'
			}
			if "`varname_csa_list'`varname_csanb_list'" != "" & `auto' ==0 {
				noi disp as text "Cross-section averages:"
				if "`varname_csa_list'" != "" {
					noi disp "  with breaks: `varname_csa_list'"
				}
				if "`varname_csanb_list'" != "" {
					noi disp "  without breaks: `varname_csanb_list'"
				}
			}


			return scalar c90 = `c90'
			return scalar c95 = `c95'
			return scalar c99 = `c99'			
		}
		return local cmd "xtbreak test `cmd'"

		if "`LagDepWarningMSG'" != "" & "`donotdisptrim'" == "" noi disp as text  "`LagDepWarningMSG'"
		
		return hidden scalar DepLagMsg = ("`LagDepWarningMSG'" != "" )

		if "`trace'" != "" {
			mata mata drop `testh' `testhi' `EstBreak'
		}

end

** auxiliary file with auxiliary programs
findfile "xtbreak_auxiliary.ado"
include "`r(fn)'"

