capture program drop xtbreak

program define xtbreak, rclass
	syntax anything [if], [*] 
	
	tokenize `anything' 
	
	if "`1'" == "test" {
		macro shift
		xtbreak_tests `*' `if' , `options'
		return add
	}
	
end
