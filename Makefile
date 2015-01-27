all: move rmd2md

vignettes:
		cd inst/vign;\
		Rscript -e 'library(knitr); knit("search.Rmd")'

move:
		cp inst/vign/search.md vignettes

rmd2md:
		cd vignettes;\
		mv search.md search.Rmd
