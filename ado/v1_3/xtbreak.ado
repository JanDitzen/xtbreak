*! xtbreak version 1.3 - 22.03.2023
/*
Changelog
- 19.03.2023 - bug when time series and vce(hac) used fixed
- 15.11.2022 - bug when using fixed effects, FE always partialled out with breaks, fixed.
			 - added e(SSR) with minimum SSR for xtbreak est
			 - added e(SSRm) as hidden matrix with all partial SSRs
			 - support for Stata 14.2
- 30.02.2022 - breaks are now a column vector, harmonized across all programs
version 1.1
- 15.11.2021 - bug when variable name contained "est". 
- 07.02.2021 - error when using Stata 15 and xtbreak, local cannot access r() matrix.
*/

capture program drop xtbreak

program define xtbreak, rclass
	syntax [anything] [if], [* version update ] 
		
		version 14.2

		local cmd "`*'"

		if "`update'" != "" {
			qui xtbreak, version
			local v_installed "`r(version)'"	
			cap net uninstall xtbreak
			if _rc == 0 {
				noi disp "Version `v_installed' removed."
				local rm = 0
			}
			else {
				cap ssc uninstall xtbreak
				if _rc == 0 {
					noi disp "Version `v_installed' (from SSC) removed."
				}
				else {
					noi disp "No version from net install or ssc install found!"
				}
			}
			noi disp "Updating from Github ... ", _c
			cap qui net install xtbreak , from("https://janditzen.github.io/xtbreak/") force replace
			if _rc == 0 {
				noi disp " Update successfull."
				qui xtbreak, version
				noi disp "New version is `r(version)'"
			}
			else {
				noi disp "Update not successfull!"
			}
			exit
		}

		if "`version'" != "" {
			local version 1.3
			noi disp "This is version `version' - 22.03.2023"
			return local version "`version'"
			exit
		}

		*** check that mata library is installed
		qui mata mata mlib index
		tempname mataversion
		cap mata st_numscalar("`mataversion'",xtbreak_m_version())
		if _rc != 0 {
			noi disp "mata library for xtbreak not found."
			exit
 		}
 		else {
			if `mataversion' < 1.01 {
				noi disp "mata library outdated. Pleae update xtbreak:"
				noi disp as smcl "{stata:xtbreak, update}"
				exit
			}
		}

		*** now start main program

		tokenize `anything' 
				
		if "`1'" == "test" { 
			macro shift
			xtbreak_tests `*' `if' , `options'
			return add
		}
		else if regexm("`1'","^est") {
			macro shift
			xtbreak_estimate `*' `if', `options'
			return add
		}
		else {
			local 0 `*' , `options'
			syntax anything [if] , [Breaks(string) BREAKPoints(string) ] * 

			

			if  "`breakpoints'" != "" {
				noi disp as smcl "Option breakpoints() requires xtbreak test. Please run:"
				noi disp as smcl "{stata xtbreak test `anything' `if', breakpoints(`breakpoints') `options'}"
				exit
			}
			if "`breaks'" != "" {
				noi disp as smcl "Option breaks() requires xtbreak test or xtbreak estimate. Please run:"
				noi disp as smcl "{stata xtbreak test `anything' `if', breaks(`breaks') `options'}"
				noi disp as smcl "or"
				noi disp as smcl "{stata xtbreak estimate `anything' `if', breaks(`breaks') `options'}"
				exit
			}

			xtbreak_tests `anything' `if' ,`options' donotdisptrim

			tempname estBreak Nbreaksmat
			matrix `Nbreaksmat' = r(Nbreaks)
			if `c(level)' == 99 { 
				local estBreak = `Nbreaksmat'[1,1]
				if `estBreak' == 0 {
					local estBreak = `Nbreaksmat'[2,1] 
				}
			}
			else if `c(level)' == 90 {
				local estBreak = `Nbreaksmat'[1,3]
				if `estBreak' == 0 {
					local estBreak = `Nbreaksmat'[2,3] 
				}
			}
			else {
				local estBreak = `Nbreaksmat'[1,2]
				if `estBreak' == 0 {
					local estBreak = `Nbreaksmat'[2,2] 
				}
			}
			return add

			if `estBreak' == . | `estBreak'== 0{
				noi disp ""
				noi disp in smcl as error "No breaks found, cannot estimate breakpoints."
				exit
			}

			xtbreak_estimate `anything' `if', `options' breaks(`estBreak')

			return local cmd "xtbreak `cmd'"
			return hidden local seq "1"
		}
	
end


