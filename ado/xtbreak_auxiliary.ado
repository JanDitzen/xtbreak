**** Auxiliary programs

*** checks if data is sorted, if not then sorts it
capture program drop issorted
program define issorted
	syntax	varlist 
	
	local sorted : dis "`:sortedby'"
	if "`sorted'" != "`varlist'" {
	    noi disp "sort data"
	    sort `varlist'
	}

end


/*
*** converts breakpoints from index to periods or back
capture program drop transbreakpoints
program define transbreakpoints , rclass
syntax anything , [Index] tvar(varlist) touse(varlist)
	qui{
		tokenize `tvar'
		local tvar_o `1'
		local tvar_i `2'
		
		if "`index'" == "" {
			local tvar `tvar_o'
		}
		else {
			local tvar `tvar_i'
		}

		tempvar tb	
		gen `tb' = 0
			
		local count = 0
		sum `tvar', meanonly
		local last = r(min)-1
		local end = r(max)
		
		*** sort anything ascending and make sure no items are double
		** sort; stupid macro list sorts code point and not logically....
		mata st_local("anything",invtokens(strofreal(sort(strtoreal(tokens("`anything'"))',1)')))
		local anything: list uniq anything
		
		*** special case that last period has breakpoint
		local LastPeridoUsed = 1
		if word("`anything'",wordcount("`anything'")) != "`end'" {
			local anything `anything' `r(max)'
			local LastPeridoUsed = 0
		}
				
		*** get unique list of breakpoints
		*noi disp "list is `anything'"
		*noi tab `tvar'
		foreach point in `anything' {
			local count = `count' + 1
			replace `tb' = `count' if `tvar' > `last' & `tvar' <= `point'

			** maybe faster solution than sum?
			sum `tvar_o' if `tvar' == `point' 
			local o_list "`o_list' `r(mean)'"
			
			sum `tvar_i' if `tvar' == `point' 
			local i_list "`i_list' `r(mean)'"			
			
			local last = `point'
		}
		
		*** check if all breakpoints in range
		tab `tb' if `touse' & `tb' > 0
		if r(r) != `count' {
			noi disp as error "Some breakpoints have no data."
			error 127
		}
		
		*** check that no breakpoints has zero
		cap assert `tb' != 0 if `touse'
		if _rc != 0 {
			noi disp as error "Some breakpoints undefined."
			error 124
		}
		
		*** return
		*** remove first element from breakpoint lists (only if not in list)
		if `LastPeridoUsed' == 0 {
			local o_list = subinstr("`o_list'",word("`o_list'",wordcount("`o_list'")),"",1)
			local i_list = subinstr("`i_list'",word("`i_list'",wordcount("`i_list'")),"",1)
		}
		
		return local index "`i_list'"
		return local periods "`o_list'"
		
		if "`index'" == "" {
			return local uselist "`o_list'"
			return local iindex "0"
		}
		else {
			return local uselist "`i_list'"
			return local iindex "1"
		}
	}
end
*/

capture program drop transbreakpoints
program define transbreakpoints, rclass
syntax anything , [Index] tvar(varlist) touse(varlist) 
	tokenize `tvar'
	* tvar with 1...10
	local tvar1 `1'
	* tvar formatted
	local tvar2 `2'

	local fmt : format `tvar2'
	
	foreach ii in `anything' {
		disp "`ii'"
		if "`index'" != "" {
			*** find ival		
			local i_index = `ii'
			sum `tvar2' if `tvar1' == `i_index' & `touse', meanonly 
			local i_ival = `r(mean)'
			local i_val : display `fmt' `i_ival'
		
		}
		else {
			*** find index
			sum `tvar1' if `tvar2' == `ii' & `touse', meanonly 
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
capture program drop xtdcce2_csa
program define xtdcce2_csa, rclass
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
				
	return local varlist "`clistn'"
	return local cross_structure "`cross_structure'"
end

*** Partial Out Program, loops over all cross-sections. faster than a loop in Stata.
** quadcross automatically removes missing values and therefore only uses (and updates) entries without missing values
** X1 variable which is partialled out
** id_n is the id identifier
capture mata mata drop xtdcce_m_partialout2()
mata:
	function xtdcce_m_partialout2 ( real matrix X2,
									real matrix X1, 
									real matrix id,
									real scalar useold,
									real scalar num_partial,
									| real scalar rk)	
	{
		real scalar rks, running
		real matrix ids, tousei, X1_i, X2_i, X1X2, X1X1

		rk = 0
		
		ids = uniqrows(id)
		idnum = rows(ids)
		running = 1
		"start loop"
		while (running<=idnum) {
		
			tousei = selectindex(id:==ids[running])
			
			X1_i = X1[tousei,.]
			X2_i = X2[tousei,.]
			
			X1X1 = quadcross(X1_i,X1_i)
			X1X2 = quadcross(X1_i,X2_i)
			
			/// use solver
			X2[tousei,.] = (X2_i - X1_i*m_xtdcce_solver(X1X1,X1X2,useold,rks=.))
			


			if (rks[1] < rks[2]) {
				rk = 1
			}
			running++
			num_partial = num_partial + cols(X1X1)
		}
		
		return(X2)
	}
end

// Mata utility for sequential use of solvers
// Default is cholesky;
// if that fails, use QR;
// if overridden, use QR.
// By Mark Schaffer 2015
capture mata mata drop cholqrsolve()
mata:
	function cholqrsolve (  numeric matrix A,
							numeric matrix B,
						  | real scalar useqr)
	{
			
			if (args()==2) useqr = 0
			
			real matrix C

			if (!useqr) {
					C = cholsolve(A, B)
					if (C[1,1]==.) {
							C = qrsolve(A, B)
					}
			}
			else {
					C = qrsolve(A, B)
			}
			return(C)

	};
end


capture mata mata drop cholqrinv()
mata:
	function cholqrinv (  numeric matrix A,
						  | real scalar useqr)
	{
			if (args()==2) useqr = 0

			real matrix C

			if (!useqr) {
					C = cholinv(A)
					if (C[1,1]==.) {
							C = qrinv(A)
					}
			}
			else {
					C = qrinv(A)
			}
			return(C)

	};
end

///Program for matrix inversion.
///Default is cholesky
///if not full rank use invsym (Stata standard) 
///and obtain columns to use
///options: 
///1. if columns are specified, force use invsym
///2. allow for old method (cholinv, if fails qrinv)
///output
///return: inverse
///indicator for rank (1x2, rank and rows), which method used and variables used

capture mata mata drop m_xtdcce_inverter()
mata:
	function m_xtdcce_inverter(	numeric matrix A,
								| real scalar useold,
								real matrix rank,
								real matrix coln,
								string scalar method)
								
	{
		real matrix C
		
		if (args() == 1) {
			useold = 0
			coln = 0
		}
		if (args() == 2 | args() == 3){
			coln = 0
		}
		if (useold == 2) {
			coln = (1..cols(A))
		}
		
		if (useold == 1) {			
			C = cholqrinv(A)
			qrinv(A,rank)
			method = "cholqr"		
		}
		else {
			
			if (coln[1,1] == 0) {
				/// calculate rank seperate. if A is not full rank, cholinv still produces results
				/// 1..cols(A) makes sure variables from left are not dropped
				C = invsym(A,(1..cols(A)))
				rank = rows(C)-diag0cnt(C)
				
				if (rank < rows(A)) {
					/// not full rank, use invsym
					method = "invsym"
					coln = selectindex(colsum(C:==0):==rows(C):==0)			
				}
				else {
					/// full rank use cholsolve
					C = cholinv(A)
					method = "chol full rank"
				}				
			}
			else {
				C = invsym(A,coln)
				rank = rows(C)-diag0cnt(C)
				method = "invsym"
			}			
		}
		rank = (rank, rows(C))
		return(C)
	}

end
/// same as inverter, rank is for matrix A (which is inverted) 
capture mata mata drop m_xtdcce_solver()
mata:
	function m_xtdcce_solver(	numeric matrix A,
								numeric matrix B,
								| real scalar useold,
								real matrix rank,
								real matrix coln,
								string scalar method)
								
	{
		real matrix C
		real scalar A1
		
		if (args() == 2) {
			useold = 0
			coln = 0
		}
		if (args() < 5){
			coln = 0
		}		
		
		if (useold == 2) {
			coln = (1..cols(A))
		}
		
		if (useold == 1) {			
			C = cholqrsolve(A,B)
			qrinv(A,rank)
			method = "cholqr"
			rank = (rank, rows(C))
		}
		else {
			if (coln[1,1] == 0) {
				
				/// calculate rank seperate. if A is not full rank, cholsolve still produces results
				/// 1..cols(A) makes sure variables from left are not dropped
				A1 = invsym(A,(1..cols(A)))
				rank = rows(A1)-diag0cnt(A1)
				
				if (rank < rows(A)) {	
					/// not full rank, solve by hand
					C = A1 * B
					method = "invsym"
					coln = selectindex(colsum(A1:==0):==rows(A1):==0)			
				}
				else {
					/// full rank use cholsolve
					C = cholsolve(A,B)
					method = "chol"
					coln = 0
				}
			}
			else {
				/// coln is defined, use invsym on specified columns
				A1 = invsym(A,coln)
				C = A1 * B
				method = "invsym"
				rank = rows(A1)-diag0cnt(A1)
			}
			rank = (rank, rows(A1))
		}		
		return(C)		
	}

end
