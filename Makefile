PACKAGE := $(shell grep '^Package:' DESCRIPTION | sed -E 's/^Package:[[:space:]]+//')
RSCRIPT = Rscript --no-init-file

vign_elastic:
		cd vignettes;\
		${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('elastic.Rmd.og', output = 'elastic.Rmd')";\
		cd ..

vign_search:
		cd vignettes;\
		${RSCRIPT} -e "Sys.setenv(NOT_CRAN='true'); knitr::knit('search.Rmd.og', output = 'search.Rmd')";\
		cd ..

install: doc build
	R CMD INSTALL . && rm *.tar.gz

build:
	R CMD build .

doc:
	${RSCRIPT} -e "devtools::document()"

eg:
	${RSCRIPT} -e "devtools::run_examples(run = TRUE)"

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
