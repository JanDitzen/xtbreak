/// Program to obtain break points (pure change model) (partialchange.m) (done)
capture mata mata drop GetBreakPoints()
mata:
	function GetBreakPoints( 	real matrix Y,				///
								real matrix X, 				///
								real matrix Z,				///
								real matrix idt,			///
								real matrix csa,			///
								real matrix csaNB,			///
								real scalar s,				///
								real scalar error,			///
								real scalar ConstantType,	///
								real scalar partialCSA,		///
								/// output
								real matrix finalbreaks,	///
								real matrix finaldelta,		///
								real matrix finalbeta,		///
								real matrix minSSR			///
								)
	{
		"start finding breakpoints"
		
		q = cols(Z)

		/// variables with fixed slopes
		if (X[1,1] != . ) {
			p = cols(X)
		}
		else {
			X = J(rows(Z),1,0)
			p = 1
		}
				
		Ni = uniqrows(idt[.,1])
		N = rows(Ni)
		Ti = uniqrows(idt[.,2])
		T = rows(Ti)
		
		/// panelindex
		index = panelsetup(idt[.,1],1)		

		/// Inital estimate for beta (coefficient on xvars)		
		XZ = (X, Z)
		dynamicprog(Y, XZ , (N,T), Nbreaks, idt , minSSR=.,truebreaks=. )	
		treubreaksI = (truebreaks' \ T)
		
		shapeMat = BreakMat(treubreaksI,T,Nbreaks)
		Zblk = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(s+1),1)#Z)
		Xblk = (J(N,1,1)#shapeMat#J(1,p,1)) :* (J(1,(s+1),1)#X)

		/// partial out constant and csa
		mult_partialout(Y0,Xblk,Zblk,csa,csaNB,idt,N,T,N*T,ConstantType,p,partialCSA,0,Y0=.,Z0=.,X0=.,tmp=.)

		/// inital estimate
		ccep(Y0,(X0,Z0),idt,N,beta_p=.,tmp1=.,0)

		/// beta_p has var1(b1), var2(b2); all in blockidag form for breaks
		deltahatblock = colshape(beta_p,s+1)		
		delta2hat = deltahatblock[p+1..p+q,.]		
		splitcoef_flat = colshape(delta2hat,1)

		"inital bias"
		Yn = Y0 - (X0,Z0) * splitcoef_flat


		///intital values for loop and first betahat0
		mult_partialout(Y,X,Zblk,csa,csaNB,idt,N,T,N*T,ConstantType,p,partialCSA,0,Y0=.,Z0=.,X0=.,tmp=.)
		ccep(Yn,X0,idt,N,betahat0=.,tmp1=.,0)

		/// initalise
		SSRT = J(1,0,.)
		SSRlast = 0
		count = 0
		errori = 1
		deltahat = J((s+1)*q,0,.)

		while (errori >= error) {
			count = count + 1
			/// use inital values with partialled out constant and CSA, can use X0
			Yn = Y0 - X0 * betahat0[.,count]
			dynamicprog(Yn, Z , (N,T), Nbreaks, idt , minSSR=.,truebreaks=. )
			treubreaksI = (truebreaks' \ T)

			shapeMat = BreakMat(treubreaksI,T,Nbreaks)
			Z0t = (J(N,1,1)#shapeMat#J(1,q,1)) :* (J(1,(s+1),1)#Z0)

			/// constant and CSA are partialled out in every step
			mult_partialout(Y,X,Z0t,csa,csaNB,idt,N,T,N*T,ConstantType,p,partial,0,Yt=.,Zt=.,Xt=.,tmp=.)

			/// SSR program returns beta as well
			SSR = SSR(Yt,(Xt,Zt),idt,N,thetahat_i=.)

			/// beta_p has var1(b1), var2(b2); only Z in  blockidag form for breaks
			betahat0 = betahat0,thetahat_i[1..p]
			deltahat = deltahat , thetahat_i[p+1..p+q*(s+1)]

			SSRT = SSRT, SSR
			errori = SSR - SSRlast
			SSRlast = SSR
		}
		
		
		finalbreaks = k[1..s]
		finaldelta = deltahat[.,count]
		finalbeta = betahat0[.,count+1]
		minSSR = SSRlast
	}

end

//// dynamic program (done)
capture mata mata drop dynamicprog()
mata:
	function dynamicprog(	real matrix Y,				///
							real matrix zstar,			///
							real scalar N,				///
							real scalar T,				///
							real matrix Nbreaks,		///
							real matrix idt,			///	
							//// Output
							real matrix minSSR,			///
							real matrix truebreaks )	
	{
		lambda = cols(zstar)
		N = NT[1,1]
		T = NT[1,2]
		SSR = J(T,T,.)
		index = panelsetup(idt[.,1],1)
		l = 0
		while (l <= Nbreaks-1) {
			i = l * lambda + 1
			
			i_end = (l+1)*lambda
			while (i <= i_end) {				
				j = lambda+i - 1
				j_end = T - (Nbreaks-l) * lambda
				while (j<= j_end) {
					/// demean
					e = J(j-i+1,1,1)
					ee = quadcross(e,e)
					M = I(j-i+1) - e* invsym(ee) * e'
					/// initalise final matrices for SSR
					YY = J(rows(N*T),1,0)
					up = J(lambda,1,0)
					low = J(lambda,lambda,0)
					
					ii = 1
					while (ii <= N) {
						Yi = panelsubmatrix(Y,ii,index)
						Zi = panelsubmatrix(zstar,ii,index)
						Yi = Yi[|i,1 \ j,1|]
						Zi = Zi[|i,. \ j,.|]
						YY = YY + Yi' * M * Yi
						up = up + Zi' * M * Yi
						low = low + Zi' * M * Zi
						ii++
					}
					low1 = invsym(low)
					SSR[i,j] = YY - up' * low1 * up					
					j++
				}				
				i++
			}			
			l++
		}
		i = lambda*Nbreaks+1
		i_end = T-lambda+1
		"l done"
		while (i<=i_end) {
			j = lambda+i-1
			while (j<=T) {
				e = J(j-i+1,1,1)
				ee = quadcross(e,e)
				M = I(j-i+1) - e* invsym(ee) * e'
				/// initalise final matrices for SSR
				YY = J(rows(N*T),1,0)
				up = J(lambda,1,0)
				low = J(lambda,lambda,0)
				
				ii=1
				while (ii<=N) {
					Yi = panelsubmatrix(Y,ii,index)
					Zi = panelsubmatrix(zstar,ii,index)
						
					Yi = Yi[|i,1 \ j,1|]
					Zi = Zi[|i,. \ j,.|]
					YY = YY + Yi' * M * Yi
					up = up + Zi' * M * Yi
					low = low + Zi' * M * Zi
					ii++
				}
				low1 = invsym(low)
				SSR[i,j] = YY - up' * low1 * up					
				j++
			}
			i++
		}

		/// Dynamic programming
		if (Nbreaks:== 1) {
			/// special case: only one break, no array needed			
			l = 0
			k = T
			j = (l+1)*lambda
			j_end = k-lambda			
			
			S_j =J(T,1,.)
						
			while (j<=j_end) {
				S_j[j,1] = SSR[1,j] + SSR[j+1,k]
				j++				
			}
			
			minindex(S_j,1,EstBreakDate=.,w=.)
			minSSR = S_j[EstBreakDate]	
			truebreaks = EstBreakDate
			
		}
		else {
		    "general case"
			/// general case; Nbreaks number of breaks
			S = asarray_create("real",1)
			SStar = asarray_create("real",1)
			EstBreakDate = asarray_create("real",1)

			l = 0
			k = (l+2)*lambda
			k_end = T - (Nbreaks-l-1) * lambda
			
			S_j = J(T,T,.)
			/// inital problem
			while (k<=k_end) {
				j = (l+1)*lambda
				j_end = k - lambda				
				while (j<=j_end) {
					S_j[j,k] = SSR[1,j] + SSR[j+1,k]
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
				
				k = (l+2)*lambda
				k_end = T- (Nbreaks-l-1)*lambda
							
				while (k<=k_end) {					
					j = (l+1)*lambda
					j_end = k - lambda
					while (j<=j_end) {
						Sstar_i = asarray(SStar,l)'
						S_j[j,k] = Sstar_i[.,j] + SSR[j+1,k]
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
			j_end = k - q
			
			S_j = J(T,T,.)
			
			Sstar_i = asarray(SStar,l)'
			
			while (j<=j_end) {
				S_j[j,k] = Sstar_i[.,j] + SSR[j+1,k]
				j++
			}

			asarray(S,l+1,S_j)
			minindex2(S_j,minSSR=.,breakdate_i=.)
			asarray(SStar,l+1,minSSR)
			asarray(EstBreakDate,l+1,breakdate_i)		
			
			/// Final stage
			/// why only last array?			
			minssrj = asarray(SStar,l+1)
			minSSR = min(minssrj)
			truebreaks = J(1,Nbreaks,.)
			
			truebreaks[1,Nbreaks] = (asarray(EstBreakDate,Nbreaks))[T,1]		
			
			/// check if truebreaks only missings, if so, test cannot be done
			if (missing(truebreaks) == cols(truebreaks)) {
			    "missings, too many break points"
			    truebreaks = .
				exit(0)
			}
			else {
				i = 1
				i_end = Nbreaks-1
				while (i <=i_end) {	
					j = Nbreaks - i
					break_i = asarray(EstBreakDate,j)
					truebreaks[1,j] = break_i[truebreaks[1,j+1],1]				
					i++
				}
			}
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


capture mata mata drop mult_partialout()
mata:
	function mult_partialout(	real matrix Y,				///
								real matrix X,				///
								real matrix Z,				///
								real matrix csa,			///
								real matrix csaNB,			///
								real matrix idt,			///	
								real scalar N,				///
								real scalar T,				///
								real scalar NT,				///
								real scalar ConstantType,	///
								real scalar p,				///
								real scalar partialCsa,		///
								real scalar partialX,		///
								real matrix Yt,				///
								real matrix Wt,				///
								real matrix Xt,				///
								real scalar num_partial		///
								)
	{
		/// Constant removed here
		if (ConstantType == 1) {
			"no break in constant"
			/// no break in constant, add to X
			constant = J(NT,cols(W),1)
			///p =  1
		}
		else if (ConstantType == 2) {
			"break in constant"
			/// break in constant
			constant = (J(N,1,1)#shapeMat#J(1,1,1)) :* (J(1,(s+1),1)#J(NT,1,1))
		}
		else if (ConstantType == -1) {
			"constant included in X"
		}
		
		if (ConstantType > 0) {
			"Partial out constant"
			if (N > 1) {
				/// partial constant out for each cross-section
				tilde = xtdcce_m_partialout2((Yt,Wt,Xt),constant,idt[.,1],0,tmp=.)
				Yt = tilde[.,1]
				Wt = tilde[.,2..1+cols(Wt)]
				if (p > 0) {
					Xt = tilde[.,1+cols(Wt)+1..cols(tilde)]
				}
			}
			else {
				Mx = I(T) - constant * m_xtdcce_inverter(quadcross(constant,constant))*constant'				
				Yt = Mx * Yt
				Wt = Mx * Wt
				if (p > 0){
					Xt = Mx * Xt
				}
			}
			"constant removed"
		}

		/// partial out cross-sectional averages, assumption the CSA have heterogenous factor loadings!
		/// count here partialed out variables
		num_partial = 0
		if (partialCsa == 1) {
			"partial out variables with breaks and CSA"
			csaI = (J(N,1,1)#shapeMat#J(1,cols(csa),1)) :* (J(1,(s+1),1)#csa)
				
			tilde = xtdcce_m_partialout2((Yt,Wt,Xt),( csaI, csaNB),idt[.,1],0,num_partial)
						
			Yt = tilde[.,1]
			/// correct Wt for zero columns, should only use blockdiagonal matrix, but this is faster and equivalent?
			Wt = tilde[.,2..1+cols(Wt)]
			
			if (p > 0) {
				Xt = tilde[.,1+cols(Wt)+1..cols(tilde)]
			}
		}
		
		/// Partial out X variables, assumption homogenous slopes!
		/// num_partial does not need to be adjusted, variables included in p
		if (partialX ==1 & p > 0) {
			"partial out constant variables (X)"
			XX = quadcross(Xt,Xt)
			Qx = I(rows(Wt)) - Xt * m_xtdcce_inverter(XX) * Xt'
			Yt = Qx * Yt
			Wt = Qx * Wt
		}
	}
end
