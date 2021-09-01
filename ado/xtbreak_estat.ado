capture program drop xtbreak_estat
program define xtbreak_estat, rclass

	gettoken subcmd rest: 0 
	if regexm("`subcmd'","indic*")==1 {
		indicator `rest'
	}
	else if regexm("`subcmd'","split*") == 1 {
		split `rest'
	}
	else if regexm("`subcmd'","scatter*") == 1 {
		scatter `rest'
	}
	else {
		noi disp "no cmd"
	}
	return add

end

program define split, rclass
	syntax [anything]
	qui {
		tempvar indicator  breakmat
		indicator `indicator'

		if "`anything'" == "" {
			local varlist `e(breakvars)'
		}
		else {
			local varlist `anything'
		}
		
		xtset
		local tvar `r(timevar)'
		local timeformat : format `tvar'

		matrix `breakmat' = e(breaks)

		matrix `breakmat' = `breakmat'[2,1..colsof(`breakmat')]

		sum `tvar' if e(sample)
		matrix `breakmat' = (`r(min)', `breakmat', `r(max)')

		foreach var in `varlist' {
			local varn = strtoname("`var'")
			tsrevar `var'
			seperate `r(varlist)' if e(sample) , by(`indicator')  gen(`varn') 

			local i = 1

			foreach SplitVar in `r(varlist)' {
				replace `SplitVar' = 0 if `SplitVar' == . & e(sample)

				local start = `breakmat'[1,`i']
				if `i' > 1 {
					local start = `start'+1
				}

				local ende  =  `breakmat'[1,`=`i'+1']
				
				local start : disp `timeformat' `start'
				local ende : disp `timeformat' `ende'
				
				label variable `SplitVar' "`var' - `start' to `ende' "
				local ++i
				local outputlist `outputlist' `SplitVar'
			}
		}
		noi disp "New variables created: `outputlist'"
		return local varlist "`outputlist'"
	}
end


program define indicator
	syntax [anything(name = gen)] , 

	qui {
		
			xtset

			local tvar `r(timevar)'
			*local timetype : format `tvar'
			local Tmax = r(tmax)
			if "`gen'" == "" {
				local gen "index"
			}
			
			tempvar touse
			gen `touse' = e(sample)

			gen double `gen' = .

			tempname breakmat

			matrix `breakmat' = e(breaks)
			matrix `breakmat' = `breakmat'[2,1..colsof(`breakmat')]
			matrix `breakmat' = 0 , `breakmat', `Tmax'

			local breaks : colsof(`breakmat')
			forvalues i = 1(1)`breaks' {
				local start = `breakmat'[1,`i']
				local end = `breakmat'[1,`=`i'+1']
				replace `gen' = `i' if `tvar' > `start' & `tvar' <= `end' & `touse'
			}

			noi disp as smcl "Variable {it:`gen'} created with values 1,...,`=`breaks'-1' indicating segements."
		}

end


program define scatter
	syntax varlist( ts)
	qui {
		local rhs `varlist'

		tempvar indicator  breakmat
		indicator `indicator'	

		xtset
		local tvar `r(timevar)'
		local timeformat : format `tvar'

		matrix `breakmat' = e(breaks)

		local regimes = colsof(`breakmat')+1

		sum `tvar' if e(sample)

		matrix `breakmat' = `breakmat'[2,1..colsof(`breakmat')]
		matrix `breakmat' = (`r(min)', `breakmat', `r(max)')
		
		local lhs "`e(depvar)'"
		

		/// build code for twoway
		forvalues i = 1(1)`regimes' {
			local scati "`scati' (scatter `lhs' `rhs' if `indicator' == `i')"

			local start = `breakmat'[1,`i']
			if `i' > 1 {
				local start = `start'+1
			}

			local ende  =  `breakmat'[1,`=`i'+1']
					
			local start : disp `timeformat' `start'
			local ende : disp `timeformat' `ende'

			local legend `legend' label(`i' `start' - `ende')
		}

		twoway `scati' , legend(`legend') xtitle(`rhs')
	}
end
