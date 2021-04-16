// -------------------------------------------------------------------------------------------------
// xtbreak_estimate
// -------------------------------------------------------------------------------------------------
capture program drop xtbreak_estimate
program define xtbreak_estimate, rclass
	syntax varlist(min=1 ts) [if] , [			///
	csa(string)							/// cross-sectional averages to add
	CSANObreak(string)					/// cross-sectional averages with no break
	/// unknow breaks
	] breaks(numlist) [					/// number of breaks
	MINLength(real 0.15)				/// minimal time periods without a break
	NOBREAKVARiables(varlist ts)		/// constant variables
	NOCONStant							/// no constant
	BREAKCONSTant						/// constant has break
	trace								/// show output
	]


	if "`trace'" == "" {
		local trace "qui"
	}
	else {
		local trace noi
	}
	noi di ""
	qui {

		cap _xt
		if _rc == 0 {
			local tvar_o `r(tvar)'
			local idvar `r(ivar)'			
		}
		else{
			tsset
			if "`r(panelvar)'" == "" {	
				tempvar idvar_bogus
				gen `idvar_bogus' = 1
				local tvar_o `r(timevar)'
				local idvar `idvar_bogus' 
			}				
		}			
		issorted `idvar' `tvar'
		
		*** generate new tvar from 1...T
		tempvar tvar
		egen `tvar' = group(`tvar_o') if `touse'
		
		*** tsset varlist 
		tsrevar `varlist'
		local indepdepvars "`r(varlist)'"
		
		*** adjust touse
		markout `touse' `indepdepvars'
		
		*** create cross-sectional averages
		if "`csa'" != "" {
			tempname csa_name
			local 0 `csa'
			syntax varlist(ts) , [lags(numlist)]
			if "`lags'" == "" { 
				local lags "0"
			}
			
			xtdcce2_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name'")
			
			local csa_list "`r(varlist)'"
		}
		if "`csanobreak'" != "" {
			tempname csa_name
			local 0 `csa'
			syntax varlist(ts) , [lags(numlist)]
			if "`lags'" == "" { 
				local lags "0"
			}
			
			xtdcce2_csa `varlist' , idvar("`idvar'") tvar("`tvar'") cr_lags("`lags'") touse(`touse') csa("`csa_name'")
			
			local csanb_list "`r(varlist)'"
		}
		markout `touse' `indepdepvars' `nobreakvariables' `csa_list' `csanb_list'
		
		local num_s = 0


	}
end


// -------------------------------------------------------------------------------------------------
// EstBreaks
// -------------------------------------------------------------------------------------------------
// estimate breaks

capture mata mata drop EstBreaks()
mata:
	function EstBreaks(		string scalar varnames, 	///
							string scalar Xvarn,		/// variables with no breakpoint (X)
							string scalar csanames,		///
							string scalar csaNBnames,	/// csa with no breaks
							string scalar idtname,		///
							string scalar tousename,	///
							string scalar numbreaks,		///
							real scalar min,			///
							real scalar varestimator,	/// which variance estimator
							real matrix EstCoeff,		/// matrix with estiamted coefficients
							real matrix EstCov			/// variance / covariance matrix	
						)
	{
		/// Load Data
		LoadData(varnames,Xvarn,csanames,csaNBnames,idtname,tousename,Y=.,W=.,X=.,csa=.,csaNB=.,idt=.,N=.,T=.,partial=.)
		
		/// Get estimated number of breaks and estimated break dates using smallest SSR
		GetBreaks(Y,W,X,csa,csaNB,idt,N,T,partial,numbreaks,EstBreaksDates=.,EstBreaksNum=.)		

		/// calculate confidence intervals
		CI = CalcCI()

	}
end


// -------------------------------------------------------------------------------------------------
// CalcCI
// -------------------------------------------------------------------------------------------------
capture mata mata drop CalcCI()
mata:
	function CalcCI(	///
						real matrix Y,
						real matrix W,
						real matrix X,
						real matrix csa,
						real matrix csaNB,
						real matrix idt,
						real scalar N,
						real scalar T,
						real scalar partial,
						real scalar BreaksNum,
						real matrix BreakDates
					)
	{
		partial_Bknown(Y,W,X,BreakDates,idt,partial,csa,csaNB,N,T,Yt=.,Wt=.,R=.,s=.,q=.)
		/// estimate CCEP and get variance
		ccep(Yt,Wt,idt,N,beta_p=.,cov_p=.,0)

		eps = Y - X * beta_p

		s2 = quadcross(eps,eps) / T
		

		i = 1
		while (i<=N) {

		}	
			
	}


end


// -------------------------------------------------------------------------------------------------
// GetBreaks
// -------------------------------------------------------------------------------------------------
capture mata mata drop GetBreaks()
mata:
	function GetBreaks(	///
						real matrix Y,					///
						real matrix W,					///
						real matrix X,					///
						real matrix csa,				///
						real matrix csaNB,				///
						real matrix idt,				///
						real scalar N,					///
						real scalar T,					///
						real scalar partial,			///
						string scalar numbreaks,		///
						real matrix EstBreaksDates,		///
						real matrix EstBreaksNum		///
					)
	{
		numbreaks = strtoreal(tokens(numbreaks))
		if (cols(numbreaks)==1) {
			numbreaks = 0,numbreaks
		}	

		minSSR = J(numbreaks[2]-numbreaks[1]+1,1,.)		
		EstBreaki = asarray_create("real",1)


		bi = 1		
		while (i<=numbreaks[2]) {

			/// get all break point combinations
			BreakpointsComb = GetAllBreakCombs(T,bi,min)

			/// do test
			numTest = rows(BreakpointsComb)
			
			cmd = sprintf("noi _dotspct 0 , title(Calculating SSR for combinations with %s break(s)) reps(%s )", strofreal(bi),strofreal(numTest))		
			stata(cmd)
			res = J(numTest,1,0)
			i = 1
			while (i<=numTest) {
				breaki = BreakpointsComb[i,.]
				partial_Bknown(Y,W,X,breaki,idt,partial,csa,csaNB,N,T,Yt=.,Wt=.,R=.,s=.,q=.)
				res[i,1] = SSR(Yt,Wt,idt,N)	
				
				cmd = sprintf("noi _dotspct %s 0 , reps(%s)",strofreal(i),strofreal(numTest))
				stata(cmd)
				
				i++
			}
			index = selectindex(res:==min(res))
			minSSR[bi,1] = resi[index,1] 
			asarray(EstBreaki,bi,BreakpointsComb[index,.])
			bi++
		}

		index = selectindex(minSSR:==min(minSSR))
		EstBreaksDates = asarray(EstBreaki,index)	
		EstBreaksNum = cols(EstBreaksDates)
	}
end
