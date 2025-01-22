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
	syntax [varlist(ts default=none) ] [if] , tvar(varname) idvar(varname) localname(string) localnamek(string)

	foreach var in `varlist' {
		cap tsrevar `var'
		if _rc != 0 {
			_xt
			issorted `r(ivar)' `r(tvar)'
			tsrevar `var'
		}
		
		local varn `r(varlist)' 
		tempvar check check2
		by `tvar' (`idvar'), sort: gen `check' = `varn'[_n]==`varn'[_n-1] `if'
		by `tvar' (`idvar'), sort: gen `check2' = `varn'[1]
		by `tvar' (`idvar'), sort: replace `check' = 1 if `varn' == `check2'

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
		c_local `localname' "`csa'" 
		c_local `localnamek' "`commfac'"
	}
	else {
		c_local `localname' "`csa'"
	}

end


if c(version) >= 16 {

python:
from sfi import Mata

import numpy as np
import xarray as xr
import pandas as pd

def py_xtb_ssr(mata_data,mata_breaks,mata_N,mata_T,mata_numX):	

	N = np.int_(Mata.get(mata_N))
	T = np.int_(Mata.get(mata_T))

	numX = np.int_(Mata.get(mata_numX))

	PosBreaks = np.array(Mata.get(mata_breaks))
	mat = np.array(Mata.get(mata_data))

	N = N.astype(int)	
	T = T.astype(int)
	
	numX = numX.astype(int)
	numX = numX[0,0]

	PosBreaks = PosBreaks.astype(int)
	numBreaks = PosBreaks.shape
	numBreaks = numBreaks[0]

	numKTotal = mat.shape[1]-2
	nx = numX
	print("numKTotal")
	print(numKTotal)
	if nx == numKTotal:
		rmCSA = 0
		csanames = [""]
	else:
		rmCSA = 1
		csanames = ["x"+str(i) for i in range(numX+2,numKTotal+1)]

	columns =["x"+str(i) for i in range(-1,numKTotal+1,1)]
	xnames = ["x"+str(i) for i in range(2,numX+1,1)]

	data = pd.DataFrame(mat,columns=columns)
	data.rename(columns={"x-1": "id", "x0": "t"}, errors="raise",inplace=True)
	data = data.set_index(["id", "t"])	
	print("numX")
	print(nx)
	print(numX)
	print("numKTotal")
	print(numKTotal)	
	print("names")
	print(columns)
	print(xnames)
	print(csanames)
	print("has csa")
	print(rmCSA)
	print(data)
	numK = mat.shape[1]-3
	
	
	SSR = np.zeros((T[0,0],T[0,0]))	

	
	PosBreaks = PosBreaks - 1

	for Breaki in range(0,numBreaks+1):
		print("regime")
		print(Breaki)
		
		i = PosBreaks[Breaki,0]
		j = PosBreaks[Breaki,1]
		tirange = range(i,j+1,1)
		
		csai = 0

		
		zz = np.zeros((numX-1,numX-1))
		zy = np.zeros((numX-1,1))
		yy = np.zeros((1,1))

		for idx, datai in data.groupby(level=0):
			y = data.loc[(idx,(tirange)),"x1"]			
			z = data.loc[(idx,(tirange)),xnames]
			if rmCSA == 1:
				csai = data.loc[(idx,(tirange)),csanames]
				csai = csai.to_numpy()		

			z = z.to_numpy()
			y = y.to_numpy()
			
			yy = yy + py_xtb_qqx(y,y,csai,rmCSA)			
			zz = zz + py_xtb_qqx(z,z,csai,rmCSA)
			zy = zy + py_xtb_qqx(z,y,csai,rmCSA)

		res = yy - zy @ (np.linalg.inv(zz) @ zy)
		SSR[i,j] = res[0,0]
	
	Mata.create("py_SSR",T[0,0],T[0,0],0)
	Mata.store("py_SSR",SSR)

def py_xtb_qqx(x1,x2,csa,usei):
	if usei == 1:
		icsaca = np.linalg.inv((csa.T @ csa))		
		x2 = x2 - csa @  (icsaca@ (csa.T @ x2))
		x1 = x1 - csa @  (icsaca@ (csa.T @ x1))
	return x1.T @ x2 

end
}

