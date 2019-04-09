all: move rmd2md

vignettes:
		cd inst/vign;\
		Rscript -e 'library(knitr); knit("search.Rmd"); knit("elastic.Rmd")'

move:
		cp inst/vign/search.md vignettes;\
		cp inst/vign/elastic.md vignettes

rmd2md:
		cd vignettes;\
		mv search.md search.Rmd;\
		mv elastic.md elastic.Rmd
