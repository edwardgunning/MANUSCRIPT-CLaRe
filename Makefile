.PHONY: help data full-main minimal-main cached-main appendix

RSCRIPT := Rscript

help:
	@echo "Top-level reproduction targets:"
	@echo "  make data          Archive/download external datasets and checksums"
	@echo "  make full-main     Run the full main-manuscript analyses"
	@echo "  make minimal-main  Run shorter verification analyses for main results"
	@echo "  make cached-main   Display/check cached main-result objects"
	@echo "  make appendix      Run appendix/supplementary analyses"

data:
	$(RSCRIPT) code/00-download-data.R

full-main:
	$(RSCRIPT) code/01-information-loss-figure.R
	$(RSCRIPT) code/02-generror-distribution-summaries-figure.R
	$(RSCRIPT) code/03-data-objects-plot.R
	$(RSCRIPT) code/04.1-run-eye-analysis.R
	$(RSCRIPT) code/04.2-plot-eye-results.R
	$(RSCRIPT) code/04.3-eye-reconstruction-plus-other.R
	$(RSCRIPT) code/05.1-run-gels-pca-dwt.R
	$(RSCRIPT) code/05.2-run-gel-analysis-ae-batch.R
	$(RSCRIPT) code/05.4-combine-gels-ae-results.R
	$(RSCRIPT) code/05.5-plot-gels-results.R
	$(RSCRIPT) code/05.6-plot-gels-reconstruction.R
	$(RSCRIPT) code/06.1-run-mnist-analysis.R
	$(RSCRIPT) code/06.2-plot-mnist-results.R
	$(RSCRIPT) code/06.3-mnist-reconstruction.R
	$(RSCRIPT) code/07.1-sample-size-experiment-seed-01.R

minimal-main:
	$(RSCRIPT) -e "rmarkdown::render('code/extra-reproduction-review/minimal-reproduction-script.Rmd')"

cached-main:
	$(RSCRIPT) -e "rmarkdown::render('display-cached-results.rmd')"

appendix:
	$(RSCRIPT) code/07.2-sample-size-experiment-seed-02.R
	$(RSCRIPT) code/07.3-sample-size-experiment-seed-03.R
	$(RSCRIPT) code/08-phoneme-data.R
	$(RSCRIPT) code/additional-multivariate-functional-data.R
	$(RSCRIPT) code/additional-revision-quantiles.R
