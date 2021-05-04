// -------------------------------------------------------------------------------------------------
// VarCov Estimators
// -------------------------------------------------------------------------------------------------
/// Implements the non parametric covariance estimator from Pesaran (2006)
capture mata mata drop VarCov_NP()
mata:
	function VarCov_NP(real matrix Y, real matrix X, real matrix idt, real matrix betaP, real matrix N)
	{		
		/// MG estimation for variance
		index = panelsetup(idt[.,1],1)	
		beta_mgi = J(N,cols(X),1)
		i = 1
		while (i<=N) {
			Y_i = panelsubmatrix(Y,i,index)
			W_i = panelsubmatrix(X,i,index)			 
			beta_mgi[i,.]  = (m_xtdcce_inverter(quadcross(W_i,W_i)) * quadcross(W_i,Y_i))'
			i++
		}
		
		beta_mg = mean(beta_mgi)
		beta_diff = beta_mgi:- beta_mg 
		
		/// covariance estimation
		/// Standard VarianceCovarianceEstimator from Pesaran 2006, Eq 67 - 69.
		cov_PSI = J(rows(betaP),cols(betaP),0) 
		cov_R =  J(rows(betaP),cols(betaP),0)
		cov_w = J(N,1,1/N)
		cov_w_s = sum(cov_w:^2)		
		
		i = 1
		while (i<=N) {
			cov_w_i = cov_w[i]
			cov_w_tilde = cov_w_i :/ sqrt(1/N :* cov_w_s)
			b_i1 = beta_diff[i,.]'
			
			tmp_x = panelsubmatrix(X,i,index)
			tmptmp = quadcross(tmp_x,tmp_x):/ rows(tmp_x)
				
			/// eq. 67 Pesaran 2006
			cov_R = cov_R :+ cov_w_tilde:^2 :* tmptmp*b_i1*b_i1'*tmptmp	
			
			/// eq. 68 Pesaran 2006
			cov_PSI = cov_PSI :+ cov_w_i :* tmptmp	
			i++
					
		}
		cov_R = cov_R / (N - 1)
		PSI1 = m_xtdcce_inverter(cov_PSI)
		//// eq. 69 Pesaran 2006 
		cov =  cov_w_s :* PSI1 * cov_R * PSI1 	

		return(cov)
	}
end

/// SSR instead of variance/covariance time (X'X)^(-1)
capture mata mata drop VarCov_SSR()
mata:
	function VarCov_SSR(real matrix Y, real matrix X, real matrix betaP)
	{		
		e = Y - X*betaP
		tmp_xx = quadcross(X,X)
		tmp_xx = m_xtdcce_inverter(tmp_xx)
		cov = quadcross(e,e) * tmp_xx
		return(cov)
				
	}
end


/// VarCov from Karavias, Westerlund, Persyn (2021)
/// VarCov is HAC robust
capture mata mata drop VarCov_KWP()
mata:
	function VarCov_KWP(real matrix Y, real matrix X, real matrix idt, real matrix betaP, real scalar N)
	{
		e = Y - X* betaP
		uniqueid = uniqrows(idt[.,1])
		N = rows(uniqueid)
		
		Shat = J(cols(X),cols(X),0)
		Shat0 = J(cols(X),cols(X),0)	
		T_avg = 0
		i = 1
		while ( i <= N) {					
			/// select data
			indic = (idt[.,1] :== uniqueid[i])
			tmp_x = select(X,indic)
			tmp_e = select(e,indic)
			tmp_xe = tmp_e :* tmp_x
			Ti = rows(tmp_x)	
			
			Shat0 = Shat0 + quadcross(tmp_xe,tmp_xe) 
			sij = 0
			bandwith = floor(Ti:^(1/3))	
			
			j = 1
			while (j <= bandwith){
				tmp_xep =  tmp_xe[j+1..Ti,.]
				tmp_xepJ = tmp_xe[1..Ti-j,.]	
				tmp_tmp = quadcross(tmp_xep,tmp_xepJ)
				/// add N*Ti for scaling down kernel parameter because it is in loops
				sij = sij :+  (1- j/(bandwith+1)) :* (tmp_tmp + tmp_tmp')	
				j++
			}
			Shat = Shat +  sij 
			T_avg = Ti + T_avg
			i++
		}
		T_avg = T_avg / N
		Shat = (Shat + Shat0) / (N*T_avg)
		tmp_xx = quadcross(X,X) 
		Sigma =  tmp_xx / (N*T_avg)				
		sigma1 = m_xtdcce_inverter(Sigma) 				
		cov = sigma1 * Shat * sigma1 
		return(cov)
	}
end

/// VarCov H robust
capture mata mata drop VarCov_HC()
mata:
	function VarCov_HC(real matrix Y, real matrix X, real matrix betaP)
	{
		e = Y - X*betaP	
		e2 = e:^2		
		s2= quadcross(X,e2,X)
		tmp_xx = quadcross(X,X) 
		tmp_xx1 = m_xtdcce_inverter(tmp_xx)
		cov = tmp_xx1 * (s2 * tmp_xx) * tmp_xx1 * rows(X)/ (rows(X) - cols(X))
		return(cov)
	}
end
