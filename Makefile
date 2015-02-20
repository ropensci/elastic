all: move rmd2md

vignettes:
		cd inst/vign;\
		Rscript -e 'library(knitr); knit("search.Rmd"); knit("elastic_intro.Rmd"); knit("elastic_dsl.Rmd")'

move:
		cp inst/vign/search.md vignettes;\
		cp inst/vign/elastic_intro.md vignettes;\
		cp inst/vign/elastic_dsl.md vignettes

rmd2md:
		cd vignettes;\
		mv search.md search.Rmd;\
		mv elastic_intro.md elastic_intro.Rmd;\
		mv elastic_dsl.md elastic_dsl.Rmd
