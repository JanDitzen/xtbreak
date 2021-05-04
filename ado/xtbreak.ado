*! xtbreak version 0.01a
capture program drop xtbreak

program define xtbreak, rclass
	syntax [anything] [if], [* version update] 
	
	if "`update'" != "" {
		noi disp "Update from Github"
		net install xtbreak , from("https://janditzen.github.io/xtbreak/") force replace
		noi disp "Done"
		exit
	}

	if "`version'" != "" {
		noi disp "This is version 0.01a - 04.05.2021"
		xtbreak_tests , version
		exit
	}

	tokenize `anything' 
	
	if "`1'" == "test" {
		macro shift
		xtbreak_tests `*' `if' , `options'
		return add
	}
	
end
