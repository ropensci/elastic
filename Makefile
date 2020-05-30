PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
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

check: build
	_R_CHECK_CRAN_INCOMING_=FALSE R CMD CHECK --as-cran --no-manual `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -f `ls -1tr ${PACKAGE}*gz | tail -n1`
	@rm -rf ${PACKAGE}.Rcheck

test:
	${RSCRIPT} -e "devtools::test()"

pkgdocs:
	${RSCRIPT} -e "pkgdown::build_site()"

readme:
	${RSCRIPT} -e "knitr::knit('README.Rmd')"
