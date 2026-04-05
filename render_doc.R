#!/usr/bin/env Rscript
# Render the Rmd document
setwd("c:/Users/adria/adrianne-code")
rmarkdown::render('integrated_DRIFTS_analysis.Rmd', output_dir = './') 
cat('\n✓ Document rendered successfully\n')
