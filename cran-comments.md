## Test environments

* local OS X install, R 3.5.3
* ubuntu 14.04 (on travis-ci), R 3.5.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

License components with restrictions and base license permitting such:
     MIT + file LICENSE
   File 'LICENSE':
     YEAR: 2019
     COPYRIGHT HOLDER: Scott Chamberlain

## Reverse dependencies

* I have run R CMD check on the 1 downstream dependency
(<https://github.com/ropensci/elastic/blob/master/revdep/README.md>).
There is a problem with the reverse dependency (nodbi) due to changes in this package, but I have the problem fixed in nodbi and will submit a new version of nodbi to CRAN as soon as this is accepted.

-------

This version includes a major breaking change, thus the major version bump. In addition, there are many fixes and features. 

As described above there is a problem in the reverse dependency, but it is fixed and ready to submit after this is accepted.

Thanks! 
Scott Chamberlain
