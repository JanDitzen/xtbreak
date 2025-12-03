**** Auxiliary programs

*** checks if data is sorted, if not then sorts it
program define issorted
	syntax	varlist 
	
	local sorted : sortedby
	if "`sorted'" != "`varlist'" {
		noi disp "NOT SORTED!!!!! `sorted' -- `varlist'"
	    noi disp "sort data"
	    sort `varlist'
	}

end

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
	foreach pack in scipy numpy sfi   joblib  {
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
cap python which joblib 
if _rc == 0 {
python:

from sfi import Mata, Macro

import numpy as np
import scipy as sc
import scipy.linalg as la
from joblib import Parallel, delayed, cpu_count
import time as _time
from multiprocessing import Pool, cpu_count

def py_xtb_inverter(mat: np.ndarray) -> np.ndarray:
    """
    Invert matrix using runtime control from Stata/Mata macro 'inverter'.

    inverter = -1 -> force np.linalg.inv
    inverter = 0  -> Moore-Penrose pseudo-inverse
    inverter = 1  -> SVD-based inversion
    inverter = 2  -> np.linalg.pinv
    inverter = 3  -> np.linalg.pinv
    """
    #try:
    inverter = int(Macro.getLocal("inverter"))
    #except Exception:
    #    inverter = 0 
    
    if inverter == -1:
        try:
        	return np.linalg.inv(mat)
        except np.linalg.LinAlgError:
            inverter = 0

    if inverter == 0:
        return np.linalg.pinv(mat)

    if inverter == 1:
        U, S, Vt = np.linalg.svd(mat)
        S_inv = sc.linalg.diagsvd(1 / S, mat.shape[1], mat.shape[0])
        return Vt.T @ S_inv @ U.T

    if inverter in (2, 3):
        return np.linalg.pinv(mat)


def _batch_solve(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Solve A @ X = B for batched matrices.
    Shapes:
      A: (..., n, n)
      B: (..., n, k)
    """
    try:
    	return np.linalg.solve(A, B)
    except np.linalg.LinAlgError:
        return py_xtb_inverter(A) @ B


def _batch_xtx(X: np.ndarray) -> np.ndarray:
    return np.einsum('bij,bik->bjk', X, X)


def _batch_xty(X: np.ndarray, Y: np.ndarray) -> np.ndarray:
    return np.einsum('bij,bik->bjk', X, Y)

def py_xtb_solver(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    xx = _batch_xtx(x)
    xy = _batch_xty(x, y)

    return _batch_solve(xx, xy)


def py_xtb_solver_s(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    return _batch_solve(x, y)


def py_xtb_partial(x1: np.ndarray, csa: np.ndarray, usei: int) -> np.ndarray:
    if usei == 1 and csa is not None and csa.size:
        return x1 - csa @ py_xtb_solver(csa, x1)
    return x1

def _process_break(dataR, PosBreak, selX, selCSA, rmCSA):
    i, j = PosBreak
    tirange = slice(i - 1, j)

    t0 = _time.perf_counter()
    dataRi = dataR[:, tirange, :]
    y = dataRi[:, :, [0]]
    z = dataRi[:, :, selX]
    csai = dataRi[:, :, selCSA] if rmCSA == 1 and selCSA else None
    t_block = _time.perf_counter() - t0

    t0 = _time.perf_counter()
    yT = py_xtb_partial(y, csai, rmCSA)
    zT = py_xtb_partial(z, csai, rmCSA)

    yy = np.einsum('bij,bik->jk', yT, yT)
    zy = np.einsum('bij,bik->jk', zT, yT)
    zz = np.einsum('bij,bik->jk', zT, zT)

    beta_rhs = py_xtb_solver_s(zz[None, ...], zy[None, ...])[0]
    res = yy - zy.T @ beta_rhs
    t_calc = _time.perf_counter() - t0

    return i, j, float(res[0, 0]), t_block, t_calc


def py_xtb_ssr(mata_data, mata_breaks, mata_N, mata_T, mata_numX, m_jobs):
    """
    Parallelized SSR computation with runtime core control via Python argument.

    Parameters
    ----------
    n_jobs : int, default=-1
        Number of parallel jobs:
          -1 -> all available cores
           1 -> sequential
          >1 -> fixed number of workers
    """
    print("start python prog")

    t0 = _time.perf_counter()
    max_cores = cpu_count()
    n_jobs = np.int_(Mata.get(m_jobs))

    max_cores = cpu_count()
    try:
        n_jobs = int(np.int_(Mata.get(m_jobs)))
    except Exception:
        print("Invalid n_jobs, falling back to 1 core")
        n_jobs = 1

    n_jobs = max(1, min(n_jobs if n_jobs != -1 else max_cores, max_cores))

    print(f"Number of jobs:{n_jobs}")

    N = int(np.int_(Mata.get(mata_N))[0, 0])
    T = int(np.int_(Mata.get(mata_T))[0, 0])
    numX = int(np.int_(Mata.get(mata_numX))[0, 0])
    print(f"N = {N}, T = {T}")

    PosBreaks = np.array(Mata.get(mata_breaks), dtype=int)
    numBreaks = PosBreaks.shape[0]

    mat = np.array(Mata.get(mata_data))
    t_load = _time.perf_counter() - t0

    print("Data Mean")
    print(np.mean(mat,axis=0))	

    numKTotal = mat.shape[1] - 2
    rmCSA = 0 if numX == numKTotal else 1

    dataR = mat[:, range(2, numKTotal + 2)]
    K_dataR = dataR.shape[1]
    dataR = dataR.reshape(N, T, K_dataR)

    selX = list(range(1, numX + 1))
    selCSA = list(range(numX + 1, K_dataR))

   
    results = []

    if n_jobs == 1:
    	for Breaki in range(numBreaks):
            results.append(
                _process_break(dataR, PosBreaks[Breaki], selX, selCSA, rmCSA)
            )
    else:

        results = Parallel(n_jobs=n_jobs, prefer="threads")(
            delayed(_process_break)(dataR, PosBreaks[Breaki], selX, selCSA, rmCSA)
            for Breaki in range(numBreaks)
        )
  
    SSR = np.zeros((T, T))
    t_blocks, t_calc = 0.0, 0.0
    for i, j, res_scalar, tb, tp in results:
        SSR[i - 1, j - 1] = res_scalar
        t_blocks += tb
        t_calc += tp
   
    print(["block time", t_blocks, t_blocks / max(numBreaks, 1)])
    print(["calculation time", t_calc, t_calc / max(numBreaks, 1)])
    print(["loading_time", t_load, t_load / max(numBreaks, 1)])
    Mata.store("py_SSR", SSR)

end

} 
}
}
}
}
}

