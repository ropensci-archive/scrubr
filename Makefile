all: move rmd2md

move:
		cp inst/vign/scrubr.md vignettes

rmd2md:
		cd vignettes;\
		mv scrubr.md scrubr.Rmd
