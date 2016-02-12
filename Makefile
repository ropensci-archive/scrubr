all: move rmd2md

move:
		cp inst/vign/scrubr_vignette.md vignettes

rmd2md:
		cd vignettes;\
		mv scrubr_vignette.md scrubr_vignette.Rmd
