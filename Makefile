.PHONY: help data full-main minimal-main cached-main appendix additional-example-quantiles

RSCRIPT := Rscript
LOG_DIR := logs
MAKE_RUN_LOG := $(LOG_DIR)/make-target-runs.tsv
export RSTUDIO_PANDOC ?= /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64

define RUN_STEP
	@mkdir -p "$(LOG_DIR)"; \
	command="$(1)"; \
	printf '%s\t%s\t%s\t%s\t%s\n' "$$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$@" "START" "" "$$command" >> "$(MAKE_RUN_LOG)"; \
	eval "$$command"; status=$$?; \
	if [ $$status -eq 0 ]; then state="END"; else state="FAIL"; fi; \
	printf '%s\t%s\t%s\t%s\t%s\n' "$$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$@" "$$state" "$$status" "$$command" >> "$(MAKE_RUN_LOG)"; \
	exit $$status
endef


help:
	@echo "Top-level reproduction targets:"
	@echo "  make data          Archive/download external datasets and checksums"
	@echo "  make full-main     Run the full main-manuscript analyses"
	@echo "  make minimal-main  Run shorter verification analyses for main results"
	@echo "  make cached-main   Display/check cached main-result objects"
	@echo "  make appendix      Run appendix/supplementary analyses"
	@echo "  make additional-example-quantiles      Run additional analyses added to main text and appendix on quantile functions"
	@echo "Run log:"
	@echo "  $(MAKE_RUN_LOG)"

data:
	$(call RUN_STEP,$(RSCRIPT) code/00-download-data.R)

full-main:
	$(call RUN_STEP,$(RSCRIPT) code/01-information-loss-figure.R)
	$(call RUN_STEP,$(RSCRIPT) code/02-generror-distribution-summaries-figure.R)
	$(call RUN_STEP,$(RSCRIPT) code/03-data-objects-plot.R)
	$(call RUN_STEP,$(RSCRIPT) code/04.1-run-eye-analysis.R)
	$(call RUN_STEP,$(RSCRIPT) code/04.2-plot-eye-results.R)
	$(call RUN_STEP,$(RSCRIPT) code/04.3-eye-reconstruction-plus-other.R)
	$(call RUN_STEP,$(RSCRIPT) code/05.1-run-gels-pca-dwt.R)
	$(call RUN_STEP,$(RSCRIPT) code/05.2-run-gel-analysis-ae-batch.R)
	$(call RUN_STEP,$(RSCRIPT) code/05.4-combine-gels-ae-results.R)
	$(call RUN_STEP,$(RSCRIPT) code/05.5-plot-gels-results.R)
	$(call RUN_STEP,$(RSCRIPT) code/05.6-plot-gels-reconstruction.R)
	$(call RUN_STEP,$(RSCRIPT) code/06.1-run-mnist-analysis.R)
	$(call RUN_STEP,$(RSCRIPT) code/06.2-plot-mnist-results.R)
	$(call RUN_STEP,$(RSCRIPT) code/06.3-mnist-reconstruction.R)
	$(call RUN_STEP,$(RSCRIPT) code/07.1-sample-size-experiment-seed-01.R)

minimal-main:
	$(call RUN_STEP,$(RSCRIPT) code/extra-reproduction-review/minimal-reproduce-eye.R)
	$(call RUN_STEP,$(RSCRIPT) code/extra-reproduction-review/minimal-reproduce-gels.R)
	$(call RUN_STEP,$(RSCRIPT) code/extra-reproduction-review/minimal-reproduce-mnist.R)

cached-main:
	$(call RUN_STEP,$(RSCRIPT) -e \"rmarkdown::render('display-cached-results.rmd')\")

appendix:
	$(call RUN_STEP,$(RSCRIPT) code/07.2-sample-size-experiment-seed-02.R)
	$(call RUN_STEP,$(RSCRIPT) code/07.3-sample-size-experiment-seed-03.R)
	$(call RUN_STEP,$(RSCRIPT) code/08-phoneme-data.R)
	$(call RUN_STEP,$(RSCRIPT) code/09-dwt-padding.R)
	$(call RUN_STEP,$(RSCRIPT) code/09-dwt-recon.R)
	$(call RUN_STEP,$(RSCRIPT) code/additional-multivariate-functional-data.R)

additional-example-quantiles:
	$(call RUN_STEP,$(RSCRIPT) code/additional-revision-quantiles.R)
	$(call RUN_STEP,$(RSCRIPT) code/additional-revision-quantiles-sensitivity.R)
