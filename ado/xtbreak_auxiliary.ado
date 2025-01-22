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
	local val = strtrim(stritrim("`val'"))
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

cap program drop xtbreak_pycheck
program define xtbreak_pycheck
	*** Checks for python
	if c(stata_version) < 16 {
		noi disp as error "Option Python Requires version 16 or later."
		error 199
	}
	cap python search
	if _rc != 0 {
		noi disp as error "Python not installed or linked."
		error 199
	}
	foreach pack in scipy numpy sfi pandas xarray {
		cap python which `pack'
		if _rc != 0 local err "`err' `pack'"
	}
	if "`err'" != "" {
		noi disp as error "Packages `err' required but not installed."
		error 199
	}
end


if c(stata_version) >= 16 {
cap python query
if _rc == 0 {
cap python which numpy 
if _rc == 0 {
cap python which scipy 
if _rc == 0 {
cap python which sfi 
if _rc == 0 {
cap python which pandas 
if _rc == 0 {
cap python which xarray 
if _rc == 0 {
python:
from sfi import Mata
from sfi import Macro

import numpy as np
import xarray as xr
import pandas as pd
import scipy as sc
import time as time

def py_xtb_inverter0(mat):
	det = np.linalg.det(mat)
	if det.any() > 0:
		output = np.linalg.inv(mat)
	else:
		output = np.linalg.pinv(mat)
	return output

def py_xtb_inverter_old(mat):
	inverter = np.int_(Macro.getLocal("inverter"))
	det = np.linalg.det(mat)
	if det.any() == 0:
		inverter = 0

	if inverter == -1:
		output = np.linalg.inv(mat)
	if inverter == 0:
		output = np.linalg.pinv(mat)
	if inverter == 1:
		U, S, Vt = np.linalg.svd(mat)
		S_inv = sc.linalg.diagsvd(1/S, mat.shape[1], mat.shape[0])
		output =  Vt.T @ S_inv @ U.T
	if inverter == 2:
		output = np.linalg.pinv(mat)
	if inverter == 3:
		output = np.linalg.pinv(mat)

	return output


def py_xtb_inverter(mat):
	inverter = np.int_(Macro.getLocal("inverter"))
	if inverter == -1: inverter = 0

	if inverter == -1:
		output = np.linalg.inv(mat)
	if inverter == 0:
		output = np.linalg.pinv(mat)
	if inverter == 1:
		U, S, Vt = np.linalg.svd(mat)
		S_inv = sc.linalg.diagsvd(1/S, mat.shape[1], mat.shape[0])
		output =  Vt.T @ S_inv @ U.T
	if inverter == 2:
		output = np.linalg.pinv(mat)
	if inverter == 3:
		output = np.linalg.pinv(mat)

	return output

def py_xtb_qqx_w0(x1,x2,csa,usei):	
	if usei == 1:
		csaT = np.transpose(csa, (0, 2, 1))
		icsaca = py_xtb_inverter_old((csaT @ csa))
		x2 = x2 - csa @  (icsaca@ (csaT @ x2))
		x1 = x1 - csa @  (icsaca@ (csaT @ x1))
	return np.transpose(x1, (0, 2, 1)) @ x2 

def py_xtb_qqx_w(x1,x2,csa,usei):	
	if usei == 1:
		csaT = np.transpose(csa, (0, 2, 1))
		x2 = x2 - csa @  py_xtb_solver(csaT @ csa, csaT @ x2)
		x1 = x1 - csa @  py_xtb_solver(csaT @ csa, csaT @ x1)
	return np.transpose(x1, (0, 2, 1)) @ x2 

def py_xtb_partial(x1,csa,usei):
	if usei == 1:
		output = x1 - csa @ py_xtb_solver(csa,x1)
	else:
		output = x1
	return output

def py_xtb_solver(x,y):
	xx = np.transpose(x, (0, 2, 1))@ x
	xy = np.transpose(x, (0, 2, 1))@ y
	det = np.linalg.det(xx)
	if det.all() == 0:
		b = py_xtb_inverter(xx) @ xy 
	else:
		b = np.linalg.solve(xx,xy)			
	return b

def py_xtb_solver_s(x,y):
	det = np.linalg.det(x)
	if det.all() == 0:
		b = py_xtb_inverter(x) @ y 
	else:
		b = np.linalg.solve(x,y)			
	return b



def py_xtb_ssr(mata_data,mata_breaks,mata_N,mata_T,mata_numX):	
	
	print("start python prog")

	N = np.int_(Mata.get(mata_N))
	T = np.int_(Mata.get(mata_T))
	numX = np.int_(Mata.get(mata_numX))
	PosBreaks = np.array(Mata.get(mata_breaks))
	mat = np.array(Mata.get(mata_data))

	N = N.astype(int)[0,0]	
	T = T.astype(int)[0,0]
	
	numX = numX.astype(int)
	numX = numX[0,0]

	PosBreaks = PosBreaks.astype(int)
	numBreaks = PosBreaks.shape
	numBreaks = numBreaks[0]

	numKTotal =mat.shape[1] -2

	if numX == numKTotal:
		rmCSA = 0
	else:
		rmCSA = 1

	SSR = np.zeros((T,T))	

	
	s1 = 0
	s2 = 0
	s3 = 0
	cnti = 0
	
	
	dataR = mat[:,range(2,numKTotal+2)]
	
	K_dataR = dataR.shape[1]
	dataR = dataR.reshape(N,T,K_dataR)
	
	selX = list(range(1,numX+1,1))
	selCSA = list(range(numX+1,K_dataR,1))
	

	for Breaki in range(0,numBreaks):

		i = PosBreaks[Breaki,0]
		j = PosBreaks[Breaki,1]
		tirange = list(range(i-1,j,1))
		csai = 0		
		
		s_time = time.time()
		dataRi = dataR[:,tirange,:]

		y = dataRi[:,:,[0]]
		z = dataRi[:,:,selX]
	
		if rmCSA == 1:
			csai = dataRi[:,:,selCSA]

		s1 = s1 +  time.time() - s_time

		s_time = time.time()
		yT = py_xtb_partial(y,csai,rmCSA)
		zT = py_xtb_partial(z,csai,rmCSA)
		yy = sum(np.transpose(yT, (0, 2, 1)) @ yT)
		zy = sum(np.transpose(zT, (0, 2, 1)) @ yT)
		zz = sum(np.transpose(zT, (0, 2, 1)) @ zT)
		res = yy - zy.T @ py_xtb_solver_s(zz,zy)
		s3 = s3 + time.time() - s_time
		

		SSR[i-1,j-1] = res[0,0]

	print([s1,s1/numBreaks])
	print([s2,s2/numBreaks])
	print([s3,s3/numBreaks])	
	
	Mata.store("py_SSR",SSR)
end
} 
}
}
}
}
}
}