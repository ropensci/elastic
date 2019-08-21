RSCRIPT = Rscript --no-init-file

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

install: doc build
	R CMD INSTALL . && rm *.tar.gz

build:
	R CMD build .

doc:
	${RSCRIPT} -e "devtools::document()"

eg:
	${RSCRIPT} -e "devtools::run_examples()"

check:
	${RSCRIPT} -e "devtools::check(document = FALSE, cran = TRUE)"

test:
	${RSCRIPT} -e "devtools::test()"

pkgdocs:
	${RSCRIPT} -e "pkgdown::build_site()"
