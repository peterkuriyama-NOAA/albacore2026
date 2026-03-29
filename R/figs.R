#-------------------------------------------------------------------------------
#Figures
#-------------------------------------------------------------------------------
#Directory to read in model results
setwd("Y://My Drive//assessments//2026_albacore//")
source("Rcode/alb_header.R")

library(r4ss)

# devtools::install_github("peterkuriyama/cpsassessment")
library(cpsassessment)

# devtools::install_github("peterkuriyama-NOAA/hmsassessment")
library(hmsassessment)

# detach("package:hmsassessment", unload = TRUE)

library(ggridges)
library(doParallel)
cbPalette <- c("#999999", "#E69F00", "#56B4E9", 
               "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#Base model---------------------------------------------------------------------
basemod_folder <- "model/base_model_2026/"
basemod <- SS_output(basemod_folder)

figfold <- "Y:/My Drive//assessments//albacore2026/figs/"

#Historical analysis------------------------------------------------------------


##Model convergence (jittering)-------------------------------------------------
#Find the F values and Biomass associated with jitter MLE values


##ASPM and ASPMR----------------------------------------------------------------

aspm <- SS_output('model/day4base_mixedsel_aspm/')
aspmr <- SS_output('model/day4base_mixedsel_aspmr/')

res <- list(base = basemod, aspm = aspm, aspmr = aspmr)
summs <- SSsummarize(res)

aspm_figfold <- paste0(figfold, "base_aspm")
dir.create(aspm_figfold)  
compare_aspm(figfold = aspm_figfold, 
             aspm_res = res)


##R0 profiles-------------------------------------------------------------------
#Combine folders to compile
folds1 <- paste0("model/base_model_2026_R0_profile_MLEout")
f1val <- list.files(folds1)[grep("R0", list.files(folds1))]
folds1 <- paste0(folds1, "/",f1val)
folds2 <- paste0("model/base_model_2026_R0_profile_MLEout_vec2")
f2val <- list.files(folds2)[grep("R0", list.files(folds2))]
folds2 <- paste0(folds2, "/",f2val)

folds <- c(folds1, folds2, basemod_folder)

#----------------Read in results
R0res <- ssoutput_parallel(ncores = 9, folders = folds) #Takes like 2.5 minutes
R0summs <- SSsummarize(R0res)

R0_figfold <- paste0(figfold, "R0profile")
dir.create(R0_figfold)  

make_R0profile_plots(figfold = R0_figfold, res = R0res)


##R0 profiles-------------------------------------------------------------------




