**** Auxiliary programs

*** checks if data is sorted, if not then sorts it
capture program drop issorted
program define issorted
	syntax	varlist 
	
	local sorted : sortedby
	if "`sorted'" != "`varlist'" {
		noi disp "NOT SORTED!!!!! `sorted' -- `varlist'"
	    noi disp "sort data"
	    sort `varlist'
	}

end

capture program drop transbreakpoints
program define transbreakpoints, rclass
syntax anything , [Index] tvar(varlist) touse(varlist) [format(string)]
	tokenize `tvar'
	* tvar with 1...10
	local tvar1 `1'
	* tvar formatted
	local tvar2 `2'

	local fmt : format `tvar2'
	

	if "`format'" != "" {
		local inp `anything'
		local anything ""
		foreach el in `inp' {
			local anything `anything' `format'(`el')
		}
	}

	foreach ii in `anything' {
		disp "`ii'"
		if "`index'" != "" {
			*** find ival		
			local i_index = `ii'
			sum `tvar2' if `tvar1' == `i_index' & `touse', meanonly 
			if "`r(mean)'" == "" {
				noi disp as error "Index for breakpoint (`ii') out of range."
				error(125)
			}
			local i_ival = `r(mean)'
			local i_val : display `fmt' `i_ival'
		
		}
		else {
			*** find index
			sum `tvar1' if `tvar2' == `ii' & `touse', meanonly
			if "`r(mean)'" == "" {
				noi disp as error "Date for breakpoint (`ii') out of range."
				error(125)
			} 
			local i_index = `r(mean)'
			local i_ival = `ii'
			local i_val : display `fmt' `i_ival'
		}

		local ival "`ival' `i_ival'"
		local val "`val' `i_val'"
		local iindex "`iindex' `i_index'"
	}
	*** check for duplicates
	local dups : list dups iindex

	if "`dups'" != "" {
		noi disp "Duplicate entries in breakpoints."
		error 141
	}

	*** return
	return local ival "`ival'"
	return local val "`val'"
	return local index "`iindex'"

end

** xtdcce2_csa creates cross-sectional averages
** option numberonly gives only lag number in cross_structure
capture program drop get_csa
program define get_csa, rclass
	syntax varlist(ts) , idvar(varlist) tvar(varlist) cr_lags(numlist) touse(varlist) csa(string) [cluster(varlist) numberonly tousets(varlist)]

		tsrevar `varlist'
		
		if "`tousets'" == "" {
			local tousets "`touse'"
		}
		
		local varlist `r(varlist)'
		
		local c_i = 1
		foreach var in `varlist' {
			if "`cluster'" != "" {
				local clusteri = word("`cluster'",`c_i')
				if "`clusteri'" == "" {
					local clusteri `cluster_def'					
				}
				else {
					local cluster_def `clusteri'					
				}
			}
			local ii `=strtoname("`var'")'
			tempvar `ii'
		
			*by `tvar' `clusteri' `touse' (`idvar'), sort: gen ``ii'' = sum(`var') if `touse'			
			*by `tvar' `clusteri' `touse'  (`idvar'), sort: replace ``ii'' = ``ii''[_N] / _N
			*** keep slow version :/, is using _N, then if statement does not work
			by `tvar' `clusteri' (`idvar'), sort: egen ``ii'' = mean(`var') if `touse'				
			
			*** replace CSA with . if touse == 0 to make sure it is missing
			replace ``ii'' = . if `touse' == 0
			
			local clist `clist' ``ii''
			local c_i = `c_i' + 1
			
		}
				
		if "`cr_lags'" == "" {
			local cr_lags = 0
		}
		local i = 1
		local lagidef = 0
		foreach var in `clist' {
			local lagi = word("`cr_lags'",`i')
			if "`lagi'" == "" {
				local lagi = `lagidef'
			}
			else {
				local lagidef = `lagi'					
			}
			sort `idvar' `tvar'
			
			tsrevar L(0/`lagi').`var'		
			local clistfull `clistfull' `r(varlist)'
			
			tempname touse2
			gen `touse2' = 1 if `tousets'
			foreach var in `r(varlist)' {
				replace `var' = `var' * `touse2'							
			}
			drop `touse2'	
			
			if "`cluster'" != "" {
				local clusteri = word("`cluster'",`c_i')
				if "`clusteri'" == "" {
					local clusteri `cluster_def'					
				}
				else {
					local cluster_def `clusteri'					
				}
				
				if "`numberonly'" == "" {
					local cross_structure "`cross_structure' `=word("`varlist'",`i')'(`lagi'; `clusteri')"
				}
				else {
				    local cross_structure "`cross_structure' `lagi'"			
				}
			}
			else {
			    if "`numberonly'" == "" {
					local cross_structure "`cross_structure' `=word("`varlist'",`i')'(`lagi')"	
				}
				else {
					local cross_structure "`cross_structure' `lagi'"	
				}
			}
			
			local i = `i' + 1
		}
		local i = 1
		foreach var in `clistfull' {
			*rename `var' `csa'_`i'
			gen double `csa'_`i' = `var'
			drop `var'
			local clistn `clistn' `csa'_`i'
			local i = `i' + 1
		}
		* maek sure data is sored
		issorted `idvar' `tvar'			
		return local varlist "`clistn'"
		return local cross_structure "`cross_structure'"
end

// -------------------------------------------------------------------------------------------------
// has common factors
// -------------------------------------------------------------------------------------------------

capture program drop hascommonfactors
program define hascommonfactors
	syntax [varlist(ts default=none) ] [if] , tvar(varname) idvar(varname) localname(string)

	foreach var in `varlist' {
		tempvar check check2
		by `tvar' (`idvar'), sort: gen `check' = `var'[_n]==`var'[_n-1] `if'
		by `tvar' (`idvar'), sort: gen `check2' = `var'[1]
		by `tvar' (`idvar'), sort: replace `check' = 1 if `var' == `check2'

		sum `check', meanonly

		if r(mean) == 1 {
			local commfac "`commfac' `var'"
		}
		else {
			local csa "`csa' `var'"
		}
		drop `check' `check2'
	}

	if "`commfac'" != "" {
		c_local `localname' "`csa' , deter(`commfac') "
	}
	else {
		c_local `localname' "`csa'"
	}

end

