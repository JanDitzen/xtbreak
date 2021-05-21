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
				
	return local varlist "`clistn'"
	return local cross_structure "`cross_structure'"
end

// -------------------------------------------------------------------------------------------------
// demean program, supports unbalanced panels
// -------------------------------------------------------------------------------------------------
capture mata mata drop xtbreak_demean()
mata:
	function xtbreak_demean(real matrix mat, real matrix idt, real scalar N)
	{
		ids = uniqrows(idt[.,1])
		i = N
		while (i>0) {
			tousei = selectindex(idt[.,1]:==ids[i])				
			mat[tousei,.] = xtbreak_demeani(mat[tousei,.])
			i--
		}
		return(mat)
	}
end

capture mata mata drop xtbreak_demeani()
mata:
	function xtbreak_demeani(real matrix mat)
	{
		Ti = rows(mat)			
		ei = J(Ti,1,1)
		Mi = I(Ti) - ei*m_xtdcce_inverter(quadcross(ei,ei)) * ei'
		Mi = Mi * mat
		return(Mi)	
	}
end

// -------------------------------------------------------------------------------------------------
// partial out programs
// -------------------------------------------------------------------------------------------------

capture mata mata drop mult_partialout()
mata:
	function mult_partialout(	real matrix Y,				///
								real matrix X,				///
								real matrix W,				///
								real matrix csa,			///
								real matrix csaNB,			///
								real matrix idt,			///	
								real scalar N,				///
								real scalar T,				///
								real scalar NT,				///
								real scalar ConstantType,	/// need to remove
								real scalar demean,			///
								real scalar p,				///
								real scalar s,				///
								real matrix shapeMat,		///
								real matrix partialCsa,		///
								real scalar partialX,		///
								real matrix Yt,				///
								real matrix Wt,				///
								real matrix Xt,				///
								real scalar num_partial		///
								)
	{
		/// make copies
		Yt = Y
		Xt = X
		Wt = W
		"start partial out"
		num_partial = 0

		
		if (demean == 1) {
			"Demean individual fixed effects"
			Yt = xtbreak_demean(Yt,idt,N)
			Wt = xtbreak_demean(Wt,idt,N)
			if (p > 0) {
				"demean X"
				Xt = xtbreak_demean(Xt,idt,N)
			}
		}

		/// partial out cross-sectional averages, assumption the CSA have heterogenous 
		ToCSA = J(N,0,.)
		if (partialCsa[1,1] == 1) {
			"partial out CSA of variables with breaks"
			ToCSA = (J(N,1,1)#shapeMat#J(1,cols(csa),1)) :* (J(1,(s+1),1)#csa)
			
			if (demean==1) {
				ToCSA = xtbreak_demean(ToCSA,idt,N) 				
			}			
		}

		if (partialCsa[1,2] == 1) {
			"partial out CSA of variables without breaks"
			csaNBt = csaNB

			if (demean==1) {
				csaNBt = xtbreak_demean(csaNBt,idt,N)
			}
			ToCSA = ToCSA, csaNBt
			
		}

		if (partialCsa[1,1] == 1 | partialCsa[1,2] == 1) {
			"partialling out CSA"
			tilde = m_partialout((Yt,Wt,Xt),ToCSA,idt[.,1],0,num_partialCSA=.)
						
			Yt = tilde[.,1]
			/// correct Wt for zero columns, should only use blockdiagonal matrix, but this is faster and equivalent?
			Wt = tilde[.,2..1+cols(Wt)]
			
			if (p > 0) {
				Xt = tilde[.,1+cols(Wt)+1..cols(tilde)]
			}
			num_partial = num_partial+num_partialCSA
		}

		/// Partial out X variables, assumption homogenous slopes!
		/// num_partial does not need to be adjusted, variables included in p
		if (partialX ==1 & p > 0) {
			"partial out constant variables (X)"
			/// even in panel case, invert XX invert is only KxK!
			XX = quadcross(Xt,Xt)			
			Qx = I(rows(Wt)) - Xt * m_xtdcce_inverter(XX) * Xt'
			Yt = Qx * Yt
			Wt = Qx * Wt
			///num_partial = num_partial+cols(Xt)
		}
		"partial done"
	}
end



*** Partial Out Program, loops over all cross-sections. faster than a loop in Stata.
** quadcross automatically removes missing values and therefore only uses (and updates) entries without missing values
** X1 variable which is partialled out
** id_n is the id identifier
capture mata mata drop m_partialout()
mata:
	function m_partialout ( real matrix X2,
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
		running = idnum
		"start loop"
		while (running>0) {
		
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
			running--
			num_partial = num_partial + cols(X1X1)
		}
		
		return(X2)
	}
end

capture mata mata drop m_partialout_i()
mata:
	function m_partialout_i ( real matrix X2,real matrix X1)	
	{

		real matrix X1X2, X1X1

		X1X1 = quadcross(X1,X1)
		X1X2 = quadcross(X1,X2)

		/// use solver
		X2 = (X2 - X1*m_xtdcce_solver(X1X1,X1X2,0,rks=.))
		
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

// -------------------------------------------------------------------------------------------------
// LoadData()
// -------------------------------------------------------------------------------------------------

capture mata mata drop LoadData()
mata:
	function LoadData(	///
					string scalar varnames, 	///
					string scalar Xvarn,		/// variables with no breakpoint (X)
					string scalar csanames,		///
					string scalar csaNBnames,	/// csa with no breaks
					string scalar idtname,		///
					string scalar tousename,	///
					real matrix Y,				///
					real matrix W,				///
					real matrix X,				///
					real matrix csa,			///
					real matrix csaNB,			///
					real matrix idt,			///
					real scalar N,				///
					real scalar T,				///
					real matrix partial
					)
	{
		
		varname = st_tsrevar(tokens(varnames))
		Y = st_data(.,varname[1],tousename)
		W = st_data(.,varname[1,2..cols(varname)],tousename)

		if (Xvarn != "") {
			X = st_data(.,st_tsrevar(tokens(Xvarn)),tousename)
		}
		else {
			X = J(rows(Y),0,.)
		}
		
		partial = 0,0,partial
		
		if (csanames[1,1] != "" ) {		
			csa = st_data(.,st_tsrevar(tokens(csanames)),tousename)
			partial[1] = 1
		}
		else {
			csa = J(rows(Y),0,.)
		}
	
		if (csaNBnames[1,1] != "" ) {
			csaNB = st_data(.,st_tsrevar(tokens(csaNBnames)),tousename)
			partial[2] = 1
		}
		else {
			csaNB = J(rows(Y),0,.)
		}
		
		idt = st_data(.,idtname,tousename)
		Nuniq = uniqrows(idt[.,1])
		N = rows(Nuniq)
		
		Tuniq = uniqrows(idt[.,2])
		T = rows(Tuniq)	
	}
end

// -------------------------------------------------------------------------------------------------
// BreakMat
// -------------------------------------------------------------------------------------------------

/// Creates Txq vector for q breaks at dates from breakpoints vector
capture mata mata drop BreakMat()
mata:
	function BreakMat( real matrix breakpoints, real scalar T, real scalar s)
	{
		real matrix shapeMat
		
		shapeMat = J(T,(s+1),0)
		i = 1
		low = 1
		while (i<=s+1) {
			up = breakpoints[i]
 			shapeMat[low..up,i] = J(up-low+1,1,1)			
			low = up + 1
			i++
		}		
		return(shapeMat)
	}
end

// -------------------------------------------------------------------------------------------------
// ols
// -------------------------------------------------------------------------------------------------

capture mata mata drop ols()
mata:
	function ols( ///
					real matrix Y,		///
					real matrix X,		///
					real matrix idt,	///
					real scalar N,		///
					real matrix betaP,	///
					real matrix cov,	///
					real scalar estCov	/// 0: no estimation, 1: standard non para. estimator Pesaran (2006) Eq. 67 - 69
										///	2: NW type estimator 
					)
	{
		if (N==1) {
			/// time series version
			XX = quadcross(X,X)
			XY = quadcross(X,Y)
		}
		else {
			/// panel version
			K = cols(X)
			XX = J(K,K,0)
			XY = J(K,1,0)
			idi = uniqrows(idt[.,1])
			i = 1
			while (i<=N) {
				indexi = selectindex((idt[.,1]:==idi[i]))
				xi = X[indexi,.]
				yi = Y[indexi,.]

				XX = XX + quadcross(xi,xi)
				XY = XY + quadcross(xi,yi)
				i++
			}
		}
		betaP = m_xtdcce_inverter(XX) * XY
		
		if (estCov > 0) {
			cov = covEst(Y,X,idt,betaP,N,estCov)
		}
	}
end

// -------------------------------------------------------------------------------------------------
// covEst
// -------------------------------------------------------------------------------------------------

capture mata mata drop covEst()
mata:
	function covEst( ///	
					real matrix Y,				///
					real matrix X,				///
					real matrix idt,			///
					real matrix betaP,			///
					real scalar N,				///
					real scalar estCovi 		///
					)
	{
					
		if (N == 1 & estCovi == 99) {
			estCovi = 2
		}
		else if ( estCovi == 99 ) {
			estCovi = 2
		}
		
		if (estCovi == 1) {
			 "N>1, non parametric"
			cov = VarCov_NP(Y,X,idt,betaP,N)  
		}
		else if (estCovi == 2) {
			"N=1 case, cov = SSR"
			cov = VarCov_SSR(Y,X,betaP)
		}
		else if (estCovi == 3 ) {
			"N>1, COV estimator from KW 4.10 - 4.12"
			cov = VarCov_KWP(Y,X,idt,betaP,N)
			
		}
		else if (estCovi == 4) {
			T = rows(uniqrows(idt[.,2]))
			"N = 1 case with cov = H"
			cov = VarCov_HC(Y,X,betaP) 
			
		}
		"cov done"			
		return(cov)

	}
		
	
end		

// -------------------------------------------------------------------------------------------------
// SSR program
// -------------------------------------------------------------------------------------------------

capture mata mata drop SSR()
mata:
 function SSR( ///
				real matrix Y,					///
				real matrix X,					///
				real matrix idt,				///
				real scalar N,|					///
				real matrix beta_p,				///
				real matrix cov_p,				///
				real matrix varestimator 		///
				)

	{
		if (args() < 7) {
			varestimator = 0
		}

		ols(Y,X,idt,N,beta_p=.,cov_p=.,varestimator)
		
		eps = Y - X * beta_p
		eps2 = quadcross(eps,eps)
		
		return(eps2) 
	}
end


// -------------------------------------------------------------------------------------------------
// partial_Bknown
// -------------------------------------------------------------------------------------------------

/// partial_Bknown parialls out the cross-section averages, constant variables and creates a Wt matrix with N*T x (s+1)*q
capture mata mata drop partial_Bknown()
mata:
	function partial_Bknown(	real matrix Y,					/// dep var
								real matrix W,					/// var with breaks
								real matrix X,					/// var without breaks
								real matrix breakpoints,		///
								real matrix idt,				///
								real matrix partial,			///
								real matrix csa,				///
								real matrix csaNB,				///
								real scalar N,					///
								real scalar T,					///
								real scalar ConstantType,		///
								real scalar demean,				/// demean
								real matrix Yt,					///	partialed out dep var
								real matrix Wt,					/// paritaled out var with breaks
								real matrix R,					///	restriction matrix
								real scalar s,					/// number of breaks
								real scalar q,					/// number of regressors in var with breaks
								real scalar p,					/// number of regressors in var without breaks
								real scalar num_partial,			/// number of variables partialled out
								| real matrix Xt 				/// if Xt in use do not partial X out
								)
						
						
	{
	    "start partialing out with known breaks"
		/// breakpoints should be a columnvector
		if (cols(breakpoints) < rows(breakpoints)) {
			breakpointsI = breakpoints',T
		}
		else {
			breakpointsI = breakpoints,T
		}
		s = cols(breakpointsI)-1		
		
		p = cols(X)
		q = cols(W)
		NT = rows(W)	
		
		/// bring W and CSA in shape with break structure
		
		shapeMat = BreakMat(breakpointsI,T,s)
		
		"breakpoints,p,s,q,partial,ctype,demean"
		breakpoints
		p,s,q,partial,ConstantType,demean

		Wt1 = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(s+1),1)#W)

		partialX = 0
		if (p > 0) {
			partialX = 1
			if (args() == 20) {
				partialX = 0
			}
		}

		mult_partialout(Y,X,Wt1,csa,csaNB,idt,N,T,NT,ConstantType,demean,p,s,shapeMat,partial,partialX,Yt,Wt,Xt=.,num_partial)

		/// update q if constant is included
		///if (ConstantType==2) q = q + 1			

		R = (I(s)#I(q),J(s*q,q,0)):+(J(s*q,q,0),-I(s)#I(q))
	}
end

// -------------------------------------------------------------------------------------------------
// GetAllBreakCombs
// -------------------------------------------------------------------------------------------------
capture mata mata drop GetAllBreakCombs()
mata:
	function GetAllBreakCombs(real scalar T, real scalar breaks, real scalar min)
	{
		if (T-(breaks+1)*min > 0) {
			numb = J(1,breaks,min)
			numb = numb , T-sum(numb)
			maxEnt = max(numb)
			diff = maxEnt - min
			comps = J(0,breaks,.)
			bi = 0
			while (bi <= diff) {
					comps = comps \  mm_compositions(bi,breaks)'
					bi++
			}
			/// no need to add last column as it will always sum up to T
			numb = J(rows(comps),breaks,min) :+comps
			//// get first period of change
			numb =  mm_colrunsum(numb')' 
			
		}
		else {
			numb = -9999
		}
		return(numb)
	}
end

cap program drop _dotspct
program _dotspct
        version 8.2
        syntax [anything] [, title(string) reps(integer -1) NODOTS ///
                DOTS(numlist >0 integer max=1)]
        if "`dots'"=="" local dots 1
        tokenize `anything'
        args i rc
        if "`i'" == "0" {
                if `"`title'"' != "" {
                        if `reps' > 0 {
                                di as txt "`title' ("   ///
                                   as res `reps' as txt ") " 
                        }
                        else {
                                di as txt "`title'" 
                        }
                }
                if "`nodots'" == "" {
                        di as txt "{hline 4}{c +}{hline 3} 10 "  ///
                                  "{hline 2}{c +}{hline 3} 20 "  ///
                                  "{hline 2}{c +}{hline 3} 30 "  ///
                                  "{hline 2}{c +}{hline 3} 40 "  ///
                                  "{hline 2}{c +}{hline 3} 50   %"
                }
                exit
        }
	
		else if `reps' < 100 {
		    local mult = floor(`i'/`reps'*100)-floor((`i'-1)/`reps'*100)
			forvalues s=1(1)`mult' {				
			     _dots 1 0
				 if (`i'-1)*`mult'+`s' >= 50 & (`i'-1)*`mult'+`s'-1 < 50 {
					 di as txt "" _col(51) %5.0f 50
				}
			}
			
		}
		else {
		   local check = round(`i'/`reps',0.01) - round((`i'-1)/`reps',0.01)
		 
		   if `check' > 0 {
		       _dots 1 0
		   }	   
			if `i'/`reps' >= 0.5 & (`i'-1)/`reps' < 0.5 {
				di as txt "" _col(51) %5.0f 50
			}
		}
		 
		if `i'/`reps' == 1 {
			di as txt "" _col(51) %5.0f 100
        }
end

// -------------------------------------------------------------------------------------------------
// GetBreakPoints
// -------------------------------------------------------------------------------------------------
capture mata mata drop GetBreakPoints()
mata:
	function GetBreakPoints( 	real matrix Y,				///
								real matrix X,	 			///
								real matrix Z,				///
								real matrix idt,			///
								real matrix csa,			///
								real matrix csaNB,			///
								real scalar s,				///
								real scalar error,			///
								real scalar ConstantType,	///
								real scalar demean,			/// demean
								real matrix partialCSA,		///
								real scalar minlength,		///
								/// output
								real matrix finalbreaks,	///
								real matrix finaldelta,		///
								real matrix finalbeta,		///
								real matrix minSSR			///
								)
	{
		"start finding breakpoints"		
		q = cols(Z)
		
		unknown_checks(q,s+1,minlength)

		/// variables with fixed slopes
		if (cols(X) != 0 ) {
			p = cols(X)
			Xi = X
		}
		else {
			Xi = J(rows(Z),1,0)
			p = 0
		}
				
		Ni = uniqrows(idt[.,1])
		N = rows(Ni)
		Ti = uniqrows(idt[.,2])
		T = rows(Ti)
		
		/// panelindex
		index = panelsetup(idt[.,1],1)	
		
		if (p:==0) {
			/// full change model
			"full change model"
			/// first partial out
			/// always demean = 0; demeaning will be in dynamic program
			/// remove CSA of variables without breaks
			/// CSA with breaks will be in dynamic program
			/// number of breaks not important here
			///mult_partialout(Y,Xi,Z,csa,csaNB,idt,N,T,N*T,ConstantType,0,p,0,.,(0,partialCSA[2]),0,Y0=.,Z0=.,X0=.,tmp=.)
			/// remove CSAnb from CSA

			dynamicprog(Y,Z, (csa,csaNB) , N,T, s, index ,minlength,demean,partialCSA[3],  minSSR=.,finalbreaks=. )	
			"final breaks are"
			finalbreaks		
			minSSR	
		}	
		else {
			/// partial change model
			"first search"
			/// keep X vars
			/// only remove constant
			//mult_partialout(Y,Xi,Z,.,csaNB,idt,N,T,N*T,ConstantType,0,p,s,(T,T,0),(0,partialCSA[2]),0,Y0=.,Z0=.,X0=.,tmp=.)
		
			/// inital breaks with X and Z
			///dynamicprog(Y0,(X0,Z0), csa,N,T, s, index ,minlength,demean,partialCSA[1],  minSSR=.,truebreaks=. )

			/// search for inital breaks. Here X and Z have breaks, all CSA have breaks
			dynamicprog(Y,(Xi,Z), (csa,csaNB) ,N,T, s, index ,minlength,demean,partialCSA[3],  minSSR=.,truebreaks=. )

			"inital breaks with X and Z having breaks"
			truebreaks	
			/// inital estimate can lead to no breaks
			if (sum(truebreaks) > 0) {
				truebreaksI = (truebreaks' \ T)
				shapeMat = BreakMat(truebreaksI,T,s)
				sv = s
			}
			else {
				"no breaks found!"
				shapeMat = J(T,1,1)
				sv=0
			}

			Zblk = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(sv+1),1)#Z)
			Xblk = (J(N,1,1)#shapeMat#J(1,p,1)) :* (J(1,(sv+1),1)#Xi)

			tmp = SSR(Y,(Xblk,Zblk),idt,N,beta_p=.,tmp1=.,0)

			/// inital estimate for beta
			/// beta_p has var1(b1), var2(b2); all in blockidag form for breaks
			deltahatblock = colshape(beta_p,sv+1)		
			delta2hat = deltahatblock[p+1..p+q,.]		
			splitcoef_flat = colshape(delta2hat,1)

			/// Yn excludes all CSA and FE
			Yn = Y - Zblk * splitcoef_flat

			ols(Yn,X,idt,N,betahat0=.,tmp1=.,0)
			

			SSRT = 0
			SSRlast = 0
			count = 0
			errori = 1
			deltahat = J((s+1)*q,0,.)
		
			while (errori >= error) {
				count = count + 1
				/// use inital values with partialled out constant and CSA, can use X0
				Yn = Y - X * betahat0[.,count]

				/// here partial out CSA NB

				dynamicprog(Yn, Z, (csa,csaNB), N,T, s, index ,minlength,demean,partialCSA[3], minSSR=.,truebreaks=. )
				"break in i"
				truebreaks
				if (sum(truebreaks) > 0) {
					truebreaksIL = (truebreaks , T)
					shapeMat = BreakMat(truebreaksIL,T,s)
					sv = s
					
					Z0t = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(sv+1),1)#Z)

					/// constant and CSA are partialled out in every step
					///mult_partialout(Y,Xi,Z0t,csa,csaNB,idt,N,T,N*T,ConstantType,p,sv,shapeMat,partialCSA,0,Yt=.,Zt=.,Xt=.,tmp=.)

					/// SSR program returns beta as well
					SSR = SSR(Y,(X,Z0t),idt,N,thetahat_i=.)

					/// beta_p has var1(b1), var2(b2); only Z in  blockidag form for breaks
					betahat0 = betahat0,thetahat_i[1..p]
					deltahat = deltahat , thetahat_i[p+1..p+q*(sv+1)]

				}
				else {
					"no breaks found!"
					/// make SSR artifically high
					
					SSR = 0
					sv = 0
					truebreaksIL = .
				}				
				SSRT = SSRT, SSR

				errori = SSRT[count+1] - SSRT[count]
							
				if (errori>=error) {
					truebreaksI = truebreaksIL
					SSRlast = SSR
				}
				
			}
			if (sv > 0) {
				minSSR = SSRT[count+1]
				finalbreaks = truebreaksI[1..sv]
				finaldelta = deltahat[.,count]
				finalbeta = betahat0[.,count+1]
				///minSSR = SSRlast
			}
			else {
				"no valid breaks found"
				finalbreaks = J(s,1,0)
				finaldelta = .
				finalbeta = .
				/// get normal SSR
				minSSR = SSR(Y,(X,Z),idt,N,beta_p=.,tmp=.,0)
			}
			"breaks are"
			finalbreaks
		}
	}
end

// -------------------------------------------------------------------------------------------------
// quadcrossdev2
// -------------------------------------------------------------------------------------------------

capture mata mata drop myquadcross()
mata: function myquadcross(x1,x2,x3,x4,x5,x6,x7) return(quadcross(x1,x2))

capture mata mata drop quadcrossdev2()
mata:
	function quadcrossdev2(real matrix X1, real matrix X2,x3,x4,x5,x6,x7)
	{	
		tmp1 = xtbreak_demeani(X1)
		tmp2 = xtbreak_demeani(X2)
		tmp = quadcross(tmp1,tmp2)
		return(tmp)
	}
end


capture mata mata drop qcrossdemeanpartial()
mata: 
	function qcrossdemeanpartial(real matrix X1, real matrix X2, real matrix CSA, real matrix index, real scalar ii,real scalar i, real scalar j)
	{
		
		CSAi = panelsubmatrix(CSA,ii,index)
		CSAi = CSAi[|i,. \ j,.|]

		tmp1 = xtbreak_demeani(X1)
		tmp2 = xtbreak_demeani(X2)
		tmp3 = xtbreak_demeani(CSAi)

		tmp11 = m_partialout_i(tmp1,tmp3)	
		tmp22 = m_partialout_i(tmp2,tmp3)

		ret = quadcross(tmp11,tmp22)

		return(ret)
	}
end

capture mata mata drop quadcrosspartial()
mata: 
	function quadcrosspartial(real matrix X1, real matrix X2, real matrix CSA, real matrix index, real scalar ii,real scalar i, real scalar j)
	{
		
		CSAi = panelsubmatrix(CSA,ii,index)
		CSAi = CSAi[|i,. \ j,.|]
		
		tmp11 = m_partialout_i(X1t,CSAi)
		tmp22 = m_partialout_i(X2t,CSAi)

		ret = quadcross(tmp11,tmp22)
		
		return(ret)
	}
end





// -------------------------------------------------------------------------------------------------
// Dynamic program
// -------------------------------------------------------------------------------------------------
capture mata mata drop dynamicprog()
mata:
	function dynamicprog(	real matrix Y,				///
							real matrix Z,			///
							real matrix CSA,			///
							real scalar N,				///
							real scalar T,				///
							real matrix Nbreaks,		///
							real matrix index,			///	
							real scalar minlength,		///
							real scalar demean,			///
							real scalar csaIndex,		///
							/// Output
							real matrix minSSR,			///
							real matrix truebreaks )	
	{
		"start dynamicprog"
		///lambda = cols(zstar)		
		lambda = cols(Z)
		"Y,Z,CSA"
		(Y,Z,J(rows(Z),1,-1),CSA)[1..20,.]
		zstar = Z
		rcZ = cols(zstar)
		

		///Ystar = Y
		///lambda = 0
		///
		///if (csaIndex == 1) {
			/// attach CSA to variables, will be removed in programs
		///	zstar = CSA,zstar
		///	Ystar = CSA,Y
		///	lambda = cols(CSA)
		///}

		q= floor(T*minlength)
		"q,minlength,T,demean,CSAindex,Nbreaks,lambda"
		q,minlength,N,T,demean,csaIndex,Nbreaks,lambda
		/// demean, use pointer to quadcross or quadcrossdev2 function. Input for both is X1, X2
		pointer(function) cross_fun
		if (demean==1 & csaIndex == 0) {
			"only demean"
			cross_fun = &quadcrossdev2()
		}
		else if (demean== 1 & csaIndex == 1) {
			"demean and partial out CSA"
			cross_fun = &qcrossdemeanpartial()
		}
		else if (demean==0 & csaIndex == 1) {
			"only partial out CSA"
			cross_fun = &quadcrosspartial()
		}
		else {
			"quadcross"
			cross_fun = &myquadcross()
		}
		"means"
mean(mean(zstar)'),mean(Y)
(Y,zstar)[1..20,.]

		/// SSRm has partial SSRs. Rows indicate start of segment, column end.
		/// Element (4,10) is segment starting at period 4 and ending at period 10
		"start build ssr"

		SSRm = J(T,T,.)	
		l = 0
		l_end = Nbreaks - 1
		while (l<=l_end) {
			i = l*q + 1
			i_end = (l+1)*q
			while (i<=i_end) {
				j = q+i -1
				j_end = T-(Nbreaks-l)*q
				while (j<=j_end) {					

					ii = 1
					SSRii = 0
					xx = J(rcZ,rcZ,0)
					xy = J(rcZ,1,0)
					yy = J(1,1,0)
					/// inefficient method, build matrix with used rows
					///Yt = J(0,1,.)
					///Zt = J(0,cols(zstar),.)

					while (ii <=N) {
						Yi = panelsubmatrix(Y,ii,index)
						Zi = panelsubmatrix(zstar,ii,index)
						///CSAi = panelsubmatrix(CSA,ii,index)
						Yi = Yi[|i,1 \ j,1|]
						Zi = Zi[|i,. \ j,.|]
						///CSAi = CSAi[|i,. \ j,.|]

						xx = xx + (*cross_fun)(Zi,Zi,CSA,index,ii,i,j)
						xy = xy + (*cross_fun)(Zi,Yi,CSA,index,ii,i,j)
						yy = yy + (*cross_fun)(Yi,Yi,CSA,index,ii,i,j)
						
						///Yt = Yt \ Yi
						///Zt = Zt \ Zi

						ii++
						
					}
					///b = m_xtdcce_inverter(xx) * xy
					///e = Yt - Zt*b 
					///SSRii =  quadcross(e,e)
					SSRii = yy - xy' *m_xtdcce_inverter(xx)*xy
					SSRm[i,j] = SSRii
					j++
				}
				i++
			}
			l++
		}

		i = q*Nbreaks + 1
		i_end = T-q+1
		"N"
		N
		while (i<=i_end) {
			if (q>0) {
				j = q+i -1
			}
			else {
				j = 1+i -1
			}
			j_end = T
			while (j<=j_end) {	

				SSRii = 0
				ii = 1
				xx = J(rcZ,rcZ,0)
				xy = J(rcZ,1,0)
				yy = J(1,1,0)

				/// inefficient method, build matrix with used rows
				///Yt = J(0,1,.)
				///Zt = J(0,cols(zstar),.)
				while (ii <= N) {
					
					Yi = panelsubmatrix(Y,ii,index)
					Zi = panelsubmatrix(zstar,ii,index)
					///CSAi = panelsubmatrix(CSA,ii,index)

					Yi = Yi[|i,1 \ j,1|]
					Zi = Zi[|i,. \ j,.|]
					///CSAi = CSAi[|i,. \ j,.|]

					xx = xx + (*cross_fun)(Zi,Zi,CSA,index,ii,i,j)
					xy = xy + (*cross_fun)(Zi,Yi,CSA,index,ii,i,j)
					yy = yy + (*cross_fun)(Yi,Yi,CSA,index,ii,i,j)

					///Yt = Yt \ Yi
					///Zt = Zt \ Zi

					ii++
						
				}

				///b = m_xtdcce_inverter(xx) * xy
				///e = Yt - Zt*b 
				///SSRii =  quadcross(e,e)
				SSRii = yy - xy' *m_xtdcce_inverter(xx)*xy
				SSRm[i,j] = SSRii
				j++
			}
			i++
		}
		"last vals"
		
		SSRm[1.,]
		/// Dynamic programming
		if (Nbreaks:== 1) {
						"last b"
			
			SSRii
			"one break case"
			/// special case: only one break, no array needed			
			/// j is the start element
			if (q > 0) {
				j = q
				j_end = T-q	
			}
			else {
				j = 1
				j_end = T-1
			}
					
			v=1
			S_j =J(T,1,.)	
			while (j<=j_end) {
				///S_j[j,1] = SSR[1,j] + SSR[j+1,j+1]
				S_j[j,1] = SSRm[1,j] + SSRm[j+1,T]
				j++	
				v++			
			}			
			SSRm[1,.]'
			minindex(S_j,1,EstBreakDate=.,w=.)
			minSSR = S_j[EstBreakDate]	
			truebreaks = EstBreakDate
			
		}
		else if (Nbreaks > 1) {
		    "general case"
			/// general case; Nbreaks number of breaks
			S = asarray_create("real",1)
			SStar = asarray_create("real",1)
			EstBreakDate = asarray_create("real",1)

			/// hack; use minlength instead of q (number of variables with breaks)
			lambda = q

			/// first break point
			l = 0
			///k = (l+1)*lambda
			k = l*lambda + 1
			k_end = T - (Nbreaks-l-1) * lambda
			
			S_j = J(T,T,.)
			/// inital problem
			while (k<=k_end) {
				j = (l+1)*lambda
				j_end = k - lambda				
				while (j<=j_end) {
					S_j[j,k] = SSRm[1,j] + SSRm[j+1,k]
					j++
				}			
				k++
			}
			
			asarray(S,l+1,S_j)
			minindex2(S_j,minSSR=.,breakdate_i=.)
			asarray(SStar,l+1,minSSR)
			asarray(EstBreakDate,l+1,breakdate_i)
			
			/// repeated subproblem
			l = 1
			l_end = Nbreaks - 2
			while (l <= l_end) {
				
				S_j = J(T,T,.)
				
				///k = (l+1)*lambda
				k = l*lambda + 1
				k_end = T- (Nbreaks-l-1)*lambda
							
				while (k<=k_end) {					
					j = (l+1)*lambda
					j_end = k - lambda
					Sstar_i = asarray(SStar,l)'
					while (j<=j_end) {						
						S_j[j,k] = Sstar_i[.,j] + SSRm[j+1,k]
						j++
					}
					k++
				}				
				asarray(S,l+1,S_j)
				minindex2(S_j,minSSR=.,breakdate_i=.)
				asarray(SStar,l+1,minSSR)
				asarray(EstBreakDate,l+1,breakdate_i)				
				l++
			}
			"final prob"
			/// final problem
			l = Nbreaks-1
			k = T
			j = (l+1)*lambda
			j_end = k - lambda
			S_j = J(T,T,.)
			
			Sstar_i = asarray(SStar,l)'
			
			while (j<=j_end) {
				S_j[j,k] = Sstar_i[.,j] + SSRm[j+1,T]
				j++
			}
			asarray(S,l+1,S_j)
			minindex2(S_j,minSSR=.,breakdate_i=.)
			asarray(SStar,l+1,minSSR)
			asarray(EstBreakDate,l+1,breakdate_i)
			
			/// only last array because last array contains sums of the SSRs			
			minssrj = asarray(SStar,l+1)
			minSSR = min(minssrj)
			
			/// collect breaks points
			truebreaks = J(1,Nbreaks,.)
			truebreaks[1,Nbreaks] = (asarray(EstBreakDate,Nbreaks))[T,1]		
			
			tt = 1
			while (tt<=Nbreaks) {
				tt
				asarray(SStar,tt),asarray(EstBreakDate,tt)
				tt++
			}


			i = 1			
			i_end = Nbreaks-1
			while (i <=i_end) {	
				j = Nbreaks - i
				break_i = asarray(EstBreakDate,j)
				truebreaks[1,j] = break_i[truebreaks[1,j+1],1]				
				i++
			}
			
			
			/// check if truebreaks only missings, if so, test cannot be done
			if (missing(truebreaks) == cols(truebreaks)) {
			    "missings, too many break points"
			    truebreaks = .
				exit(0)
			}
		}
		else {
			/// special case no break; just use SSR and no breaks
			"no break case"
			truebreaks = 0
			minSSR = SSR(Y,zstar,.,N)
			"SSR is"
			minSSR
		}
	"dynamic prog done"
	}
end



*** returns min index for matrix
capture mata mata drop minindex2()
mata:
	function minindex2 (real matrix mat, real matrix mins, real matrix index)
	{
	    real scalar K
		real scalar k
		real scalar matj 
		real scalar mati
		
		K = cols(mat)
		k = 1
		mins = J(K,1,.)
		index = J(K,1,.)
		while (k<=K) {
			matj = mat[.,k]

		    mati = order(matj,1)

			mins[k,1] = matj[mati[1,1],1]
			if (mins[k,1] != .) {
				index[k,1] = mati[1,1]
			}

			k++
		} 
		
		
	}

end


// -------------------------------------------------------------------------------------------------
// unknown_checks
// -------------------------------------------------------------------------------------------------

capture mata mata drop unknown_checks()

mata:
	function unknown_checks(real scalar q, real scalar s, real scalar minlength)
	{
		/// check if minlength is fine with number of breaks
		if (s*minlength >= 1) {
			cmd = sprintf(`"noi disp as error "Number of breaks (%s) too large for minimal segment length (%s).""', strofreal(s), strofreal(minlength,"%4.2f"))
			stata(cmd)
			cmd = sprintf(`"noi disp as text "Reduce the number of breaks or the minimal segment length.""')
			stata(cmd)
			exit(error(198))
		}

	}


end
