*! xtbreak version 0.02
capture program drop xtbreak

program define xtbreak, rclass
	syntax [anything] [if], [* version update] 
	
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
			local version 0.02
			noi disp "This is version 0.02 - 14.05.2021"
			xtbreak_tests , version
			return local version "`version'"
			exit
		}

		noi disp ""
		noi disp in red "THIS IS AN ALPHA VERSION!" 
		noi disp in red "PLEASE CHECK FOR UPDATES PRIOR PUBLISHING ANY RESULTS OBTAINED WITH THIS VERSION!"
		noi disp ""

		tokenize `anything' 
		
		if "`1'" == "test" {
			macro shift
			xtbreak_tests `*' `if' , `options'
			return add
		}
		else if regexm("`1'","est") {
			macro shift
			xtbreak_estimate `*' `if', `options'
			return add
		}
	
end
