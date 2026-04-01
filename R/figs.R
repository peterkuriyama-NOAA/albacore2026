#-------------------------------------------------------------------------------
#Figures
#-------------------------------------------------------------------------------
#Directory to read in model results
setwd("Y://My Drive//assessments//2026_albacore//")
source("Rcode/alb_header.R")

library(r4ss)

# devtools::install_github("peterkuriyama/cpsassessment")
library(cpsassessment)

devtools::install_github("peterkuriyama-NOAA/hmsassessment")
library(hmsassessment)

# detach("package:hmsassessment", unload = TRUE)

library(ggridges)
library(doParallel)
cbPalette <- c("#999999", "#E69F00", "#56B4E9", 
               "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#-------------------------------------------------------------------------------
#Base model---------------------------------------------------------------------
basemod_folder <- "model/base_model_2026/"
basemod <- SS_output(basemod_folder)




figfold <- "Y:/My Drive//assessments//albacore2026/figs/"

#Historical analysis------------------------------------------------------------
model2023 <- SS_output("model/previousbasemodels/00a_05_04_basecase_clean/")


figfold <- "Y://My Drive//assessments//albacore2026//figs/historical/"
dir.create(figfold, recursive = T)

res <- list(base2026 = basemod, base2023 = model2023)
plot_historical(res = res, figfolder = figfold, cpue_fleets = list(10, 12))

##Model convergence (jittering)-------------------------------------------------
#Find the F values and Biomass associated with jitter MLE values


##ASPM and ASPMR----------------------------------------------------------------

aspm <- SS_output('model/base_model_2026_aspm/')
aspmr <- SS_output('model/base_model_2026_aspmr/')

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
f1val <- f1val[-1]
folds1 <- paste0(folds1, "/",f1val)

folds2 <- paste0("model/base_model_2026_R0_profile_MLEout_vec2")
f2val <- list.files(folds2)[grep("R0", list.files(folds2))]

f2val <- f2val[-which(f2val == "R0_5_old")]

folds2 <- paste0(folds2, "/",f2val)

folds <- c(folds1, folds2, basemod_folder)

#----------------Read in results
R0res <- ssoutput_parallel(ncores = 10, folders = folds) #Takes like 2.5 minutes
R0summs <- SSsummarize(R0res)

# comps <- PinerPlot(R0summs)

# #Check these values
# rr <- R0summs$pars %>% slice(grep("R0", Label)) %>% select(-Yr, -recdev) %>%
#   melt(id.var = "Label") %>% rename(type = 'variable', R0 = "value") %>% select(type, R0)
# 
# 
# totlikes <- R0summs$likelihoods %>% melt(id.var = "Label") %>% mutate(type = "variable") %>%
#   left_join(rr)
# 
# R0summs$likelihoods_by_fleet

R0_figfold <- paste0(figfold, "R0profile_v2")
dir.create(R0_figfold)  

make_R0profile_plots(figfold = R0_figfold, res = R0res)



##Hindcast----------------------------------------------------------------------
##Calculated in diagnostics.R

##catch Curve----------------------------------------------------------------------
catchcurve <- SS_output("model/base_model_2026_catchcurve/")
# SS_plots(catchcurve)


figfold <- "Y://My Drive//assessments//albacore2026//figs/catch_curve/"
dir.create(figfold, recursive = T)

res <- list(base = basemod, catchcurve = catchcurve)
# debugonce(make_model_comparisons)
make_model_comparisons(res = res, figfolder = figfold, cpue_fleets = c(10, 36, 37),
                       fleets_to_plot = c(1), alfleets = 1)


#-----------------------------------------------------------------
##Sensitivities-----------------------------------------------------------------
#-----------------------------------------------------------------
##------------------Natural mortalities
Mfolds <- c("model/sens1a_M3/", "model/sens1b_consM/",
  "model/sens1c_estM//")

Mres <- ssoutput_parallel(ncores = 3, folders = Mfolds)
Mres1 <- Mres
Mres1[[4]] <- basemod
names(Mres1) <- c('M=0.3', "M=consM_consF", "estM", "base2026")

figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens1_M/"
dir.create(figfolder)

plot_sensitivity(Mres1, figfolder = figfolder)



##------------------Steepness TODO TODO
hfold <- list.files('model')[grep("sens2a", list.files('model'))]
hfold <- c(hfold, "sens2b_hprior", "base_model_2026")


hres <- ssoutput_parallel(ncores = length(hfold), 
                          folders = paste0("model/", hfold))


names(hres) <- c('h=0.75', "h=0.80", "h=0.85", 'h est (no conv)', "base2026")

figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens2_steep/"
dir.create(figfolder)

plot_sensitivity(hres, figfolder = figfolder)

##Plot without esth runs

figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens2_steep_noesth/"
dir.create(figfolder)

plot_sensitivity(hres[-4], figfolder = figfolder)



list.files('model')[grep("sens", list.files('model'))]

##------------------Growth
gfold <- list.files('model')[grep("sens3", list.files('model'))]
gfold <- gfold[grep("tuned", gfold)]

gfold <- c(gfold, "base_model_2026")


gres <- ssoutput_parallel(ncores = length(gfold), 
                          folders = paste0("model/", gfold))




