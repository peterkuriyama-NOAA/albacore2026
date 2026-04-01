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


##Hindcast----------------------------------------------------------------------
#
hindcasts <- read.csv("../albacore2026/output/hindcast_F10.csv")
names(hindcasts) <- tolower(names(hindcasts))
hindcasts <- hindcasts %>% select(fleet, yr, obs, exp, use, npred, retro)

#Start manipulating the hindcasts data
lastyears <- hindcasts %>% filter(use != -1) %>% group_by(npred, retro) %>% 
  summarize(last_obs_year = max(yr))
hindcasts <- hindcasts %>% left_join(lastyears)
hindcasts$pred <- hindcasts$exp

hindcasts %>% filter(npred == 4, retro == 4)


pred0 <- hindcasts %>% filter(yr == last_obs_year) %>% mutate(pred0 = pred) %>%
  distinct(npred, retro, last_obs_year, pred0)
  
hindcasts <- hindcasts %>% left_join(pred0)
hindcasts <- hindcasts %>% mutate(resid = obs - pred, resid0 = obs - pred0)
hindcasts$horizon <- hindcasts$last_obs_year + hindcasts$npred


hindcasts %>% filter(yr > last_obs_year, yr <= horizon) %>% 
  group_by(npred) %>% summarize(mae = mean(abs(resid)),
                                scale = mean(abs(resid0)),
                                mase = mae / scale)


#Check these, a horizon of 5 years
hindcasts %>% filter(yr > last_obs_year, npred == 5,
                     yr <= horizon)




hindcasts %>% filter(npred == 1, retro == 0)

hindcasts %>% filter(yr > last_obs_year) 



hindcasts %>% group_by(npred, retro) %>%
  
  mutate(last_obs_yr =)
  
  filter(npred == 1)

hindcasts %>% mutate(endyear = 2024, p)

hindcasts %>% select(fleet, yr) %>% filter(npred == 1, retro == 1)

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




