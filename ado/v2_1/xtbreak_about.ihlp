{marker references}{title:References}

{marker Andrews1993}{p 4}Andrews, D. W. K. (1993). 
Tests for Parameter Instability and Structural Change With Unknown Change Point. 
Econometrica, 61(4), 821–856.
{browse "https://www.jstor.org/stable/2951764":link}.
{p_end}

{marker BP1998}{p 4}Bai, B. Y. J., & Perron, P. (1998). 
Estimating and Testing Linear Models with Multiple Structural Changes. 
Econometrica, 66(1), 47–78.
{browse "http://www.columbia.edu/~jb3064/papers/1998_Estimating_and_testing_linear_models_with_multiple_structural_changes.pd":link}.
{p_end}

{marker BP2003}{p 4}Bai, J., & Perron, P. (2003). 
Computation and analysis of multiple structural change models. 
Journal of Applied Econometrics, 18(1), 1–22.
{browse "https://onlinelibrary.wiley.com/doi/full/10.1002/jae.659":link}.{p_end}

{marker DKW2021}{p 4}Ditzen, J., Karavias, Y. & Westerlund, J. (2024) 
Multiple Structural Breaks in Interactive Effects Panel Data Models
Journal of Applied Econometrics
{browse "https://onlinelibrary.wiley.com/doi/10.1002/jae.3097":Link}.{p_end}

{p 4 8}Ditzen, J., Karavias, Y. & Westerlund, J. (2025) 
Testing and Estimating Structural Breaks in
Time Series and Panel Data in Stata.
arXiv:2110.14550 [econ.EM].{break} 
{browse "https://arxiv.org/abs/2110.14550":Working paper},
 Slides Stata User Group meetings:
{browse "https://www.stata.com/meeting/switzerland20/slides/Switzerland20_Ditzen.pdf":2020 Swiss},
{browse "https://www.stata.com/meeting/germany21/slides/Germany21_Ditzen.pdf":2021 German},
{browse "https://www.stata.com/meeting/us21/slides/US21_Ditzen.pdf": 2021 US}.
{p_end}

{marker KNW2021}{p 4}Karavias, Y, Narayan P. & Westerlund, J. (2023)
Structural breaks in Interactive Effects Panels and the Stock Market Reaction to COVID–19. 
Journal of Business & Economic Statistics. 41(3), 653-666
{browse "https://www.tandfonline.com/doi/full/10.1080/07350015.2022.2053690":link}.{p_end}

{marker WPN2019}{p 4}Westerlund, J., Petrova, Y., & Norkute, M. (2019). 
CCE in fixed-T panels. 
Journal of Applied Econometrics, 34(5), 1–16. 
{browse "https://doi.org/10.1002/jae.2707":link}.{p_end}

{marker Pesaran2006}{p 4}Pesaran, H. (2006)
Estimation and inference in large heterogeneous panels with a multifactor error structure.
Econometrica, 74(4), 967-1012.
{browse "https://doi.org/10.1111/j.1468-0262.2006.00692.x":link}.{p_end}

{marker about}{title:Authors}

{p 4}Jan Ditzen (Free University of Bozen-Bolzano){p_end}
{p 4}Email: {browse "mailto:jan.ditzen@unibz.it":jan.ditzen@unibz.it}{p_end}
{p 4}Web: {browse "www.jan.ditzen.net":www.jan.ditzen.net}{p_end}

{p 4}Yiannis Karavias (Brunel University){p_end}
{p 4}Email: {browse "mailto:yiannis.karavias@brunel.ac.uk":yiannis.karavias@brunel.ac.uk}{p_end}
{p 4}Web: {browse "https://sites.google.com/site/yianniskaravias/":https://sites.google.com/site/yianniskaravias/}{p_end}

{p 4}Joakim Westerlund (Lund University){p_end}
{p 4}Email: {browse "mailto:joakim.westerlund@nek.lu.se":joakim.westerlund@nek.lu.se}{p_end}
{p 4}Web: {browse "https://sites.google.com/site/perjoakimwesterlund/":https://sites.google.com/site/perjoakimwesterlund/}{p_end}

{p 4 8}Please cite as follows:{break}
Ditzen, J, Y. Karavias and J. Westerlund. 2025. Testing and Estimating Structural Breaks in
Time Series and Panel Data in Stata. {browse "https://arxiv.org/abs/2110.14550":arXiv:2110.14550} [econ.EM].{p_end}

{title:How to install}

{p 4 8}The latest versions can be obtained via {stata "net from https://github.com/JanDitzen/xtbreak"}.{p_end}

{title:Notes}

{p 4 8}{cmd:xtbreak} requires Stata version 15 or higher.{p_end}

{title:Changelog}
{p 4 4}This version 2.1 - 25.02.2025{p_end}
{p 4 4} - Bug fixed for hypothesis 2 and min and max number of breaks.{p_end}
{p 4 4}Changes to version 2.0 - 20.01.2025{p_end}
{p 4 4} - Bugfixes in dynamic program, partial break model and variance estimator.{p_end}
{p 4 4} - Added options inverter(), skiph2, strict, maxbreaks(), python and allow for unbalanced panels.{p_end}
{p 4 4}Changes to version 1.5 - 08.04.2024{p_end}
{p 4 4} - additional checks to ensure trimming and number of breaks are valid.{p_end}
{p 4 4}Changes to version 1.4 - 10.03.2024{p_end}
{p 4 4} - several bug fixes.{p_end}
{p 4 4} - added option region() to find breaks within specific region.{p_end}
{p 4 4} - estat split creates a variable for constant/fixed effect if those break.{p_end}
{p 4 4}Changes 1.1 to 1.11:{p_end}
{p 4 4}- fixed error when using Stata 15 and xtbreak, seq (thanks to Zachary Elkins).{p_end}
{p 4 4}Changes 1.0 to 1.1:{p_end}
{p 4 4}- added min and max to sequential test{p_end}
{p 4 4}- bug when variable name contained "est"{p_end}
{p 4 4}- error in scaling critical values (ts + xt) and test statistic (ts + xt) when using hypothesis 3{p_end}
{p 4 4}Changes 0.02 to 1.0:{p_end}
{p 6 6}- fixed error in wdmax test. Used wrong critical values.{p_end}
{p 6 6}- added sequential F-Test and general xtbreak y x syntax.{p_end}
{p 6 6}- bug fixes in var/cov estimators.{p_end}

{title:Also see}
{p 4 4}See also: {help xtbreak_estimate:xtbreak estimate}, {help xtbreak_test:xtbreak test}, {help estat sbcusum}, {help estat sbknown},  {help estat sbsingle} {p_end} 
