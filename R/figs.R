#-------------------------------------------------------------------------------
#Figures
#-------------------------------------------------------------------------------
#Started on local computer
setwd("Y://My Drive//assessments//2026_albacore//")
source("Rcode/alb_header.R")

library(r4ss)

# devtools::install_github("peterkuriyama/cpsassessment")
library(cpsassessment)

# devtools::install_github("peterkuriyama-NOAA/hmsassessment")
library(hmsassessment)

#Base model---------------------------------------------------------------------
basemod_folder <- "model/base_model_2026/"
basemod <- SS_output(basemod_folder)

#Historical analysis------------------------------------------------------------


##Model convergence (jittering)-------------------------------------------------
#Find the F values and Biomass associated with jitter MLE values


##ASPM and ASPMR----------------------------------------------------------------

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
res <- ssoutput_parallel(ncores = 9, folders = folds) #Should take like 1.5 minutes
summs <- SSsummarize(res)

R0s <- summs$pars %>% slice(grep("R0", Label)) %>%melt(id.var = c("Label", "Yr", "recdev")) %>%
  select(variable, value) %>% rename(R0val = "value")

likes <- summs$likelihoods %>% filter(Label == "TOTAL") %>% melt %>% 
  mutate(minval = min(value), delta = value - minval) 
likes <- likes %>% left_join(R0s, by = 'variable')

likes %>%
  ggplot(aes(x = R0val, y = delta)) + geom_line() + geom_point() + 
  geom_hline(aes(yintercept = 1.92), lty = 2)  +  
  geom_vline(aes(xintercept = 12.1204), lty = 2)







