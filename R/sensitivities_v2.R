#-------------------------------------------------------------------------------
#Sensitivities Check

basemod <- SS_output("model/base_model_2026")
basemod$FleetNames
#-------------------------------------------------------------------------------
#Starting on workstations
orig_dir <- "/home/user/2026_albacore"
setwd(orig_dir)

source("Rcode/alb_header.R")

#-------Add in assessment packages
# remotes::install_github("r4ss/r4ss")
library(r4ss)

# devtools::install_github("peterkuriyama/cpsassessment")
library(cpsassessment)

detach("package:hmsassessment", unload = TRUE)
devtools::install_github("peterkuriyama-NOAA/hmsassessment")
library(hmsassessment)
# devtools::load_all("/home/user/hmsassessment/")

#  "../../../ss3.30.24_linux/ss3"
#-------------------------------------------------------------------------------
##
#Natural mortality--------------------------------------

#Steepness--------------------------------------
#h = 0.75, 0.8, 0.85

###h=.75----
change_parvalue(fromdir = "model/base_model_2026/", todir = "model/sensitivities/steep75/",
                run_from_par = T, par_to_change = "steep",
                parval_new = data.frame(INIT = c(.75), PHASE = c(-1)))

#Tune recdevs
change_parvalue(fromdir = "model/sensitivities/steep75/", 
                todir = "model/sensitivities/steep75_tuned/",
                run_from_par = T, par_to_change = "steep",
                parval_new = data.frame(INIT = c(.75), PHASE = c(-1)))

newctl <- do_biasadj("model/sensitivities/steep75/", ctlname = "control.ss_new")
SS_writectl(ctllist = newctl, outfile = paste0("model/sensitivities/steep75_tuned/", 
                                               "control.ss"), overwrite = T)

###h=.80----
change_parvalue(fromdir = "model/base_model_2026/", todir = "model/sensitivities/steep80/",
                run_from_par = T, par_to_change = "steep",
                parval_new = data.frame(INIT = c(.80), PHASE = c(-1)))

#Tune recdevs
change_parvalue(fromdir = "model/sensitivities/steep80/", 
                todir = "model/sensitivities/steep80_tuned/",
                run_from_par = T, par_to_change = "steep",
                parval_new = data.frame(INIT = c(.80), PHASE = c(-1)))

newctl <- do_biasadj("model/sensitivities/steep80/", ctlname = "control.ss_new")
SS_writectl(ctllist = newctl, outfile = paste0("model/sensitivities/steep80_tuned/", 
                                               "control.ss"), overwrite = T)


###h=.85----
change_parvalue(fromdir = "model/base_model_2026/", todir = "model/sensitivities/steep85/",
                run_from_par = T, par_to_change = "steep",
                parval_new = data.frame(INIT = c(.85), PHASE = c(-1)))

change_parvalue(fromdir = "model/sensitivities/steep85/", 
                todir = "model/sensitivities/steep85_tuned/",
                run_from_par = T, par_to_change = "steep",
                parval_new = data.frame(INIT = c(.85), PHASE = c(-1)))
newctl <- do_biasadj("model/sensitivities/steep85/", ctlname = "control.ss_new")
SS_writectl(ctllist = newctl, outfile = paste0("model/sensitivities/steep85_tuned/", 
                                               "control.ss"), overwrite = T)


###Steep prior----
#TODO
change_parvalue(fromdir = "model/base_model_2026/", todir = "model/sensitivities/steep_est/",
                run_from_par = F, 
                par_to_change = "steep",
                parval_new = data.frame(INIT = c(.9), PRIOR = c(.9), 
                                        PR_SD = c(0.1), PR_type = c(6),PHASE = c(4)))

#Tune recdevs
change_parvalue(fromdir = "model/sensitivities/steep_est/", 
                todir = "model/sensitivities/steep_est_tuned/",
                run_from_par = T, 
                par_to_change = "steep",
                parval_new = data.frame(INIT = c(.9), PRIOR = c(.9), 
                                        PR_SD = c(0.1), PR_type = c(6),PHASE = c(4)))
newctl <- do_biasadj("model/sensitivities/steep_est/", ctlname = "control.ss_new")
SS_writectl(ctllist = newctl, outfile = paste0("model/sensitivities/steep_est_tuned/", 
                                               "control.ss"), overwrite = T)



#-----
#Read in results

#Growth--------------------------------------
##CV Old
#CV = .06---------------
change_parvalue(fromdir = "model/base_model_2026/", todir = "model/sensitivities/CVold6/",
                run_from_par = T, par_to_change = "CV_old_Fem",
                parval_new = data.frame(INIT = c(.06), PHASE = c(-1)))

#Tune recdevs
change_parvalue(fromdir = "model/sensitivities/CVold6/", 
                todir = "model/sensitivities/CVold6_tuned/",
                run_from_par = T, 
                par_to_change = "CV_old_Fem",
                parval_new = data.frame(INIT = c(.06), PHASE = c(-1)))


newctl <- do_biasadj("model/sensitivities/CVold6/", ctlname = "control.ss_new")
SS_writectl(ctllist = newctl, outfile = paste0("model/sensitivities/CVold6_tuned/", 
                                               "control.ss"), overwrite = T)




#CV = .08----------------
change_parvalue(fromdir = "model/base_model_2026/", todir = "model/sensitivities/CVold8/",
                run_from_par = T, par_to_change = "CV_old_Fem",
                parval_new = data.frame(INIT = c(.08), PHASE = c(-1)))

change_parvalue(fromdir = "model/sensitivities/CVold8/", 
                todir = "model/sensitivities/CVold8_tuned/",
                run_from_par = T, par_to_change = "CV_old_Fem",
                parval_new = data.frame(INIT = c(.08), PHASE = c(-1)))
newctl <- do_biasadj("model/sensitivities/CVold8/", ctlname = "control.ss_new")
SS_writectl(ctllist = newctl, outfile = paste0("model/sensitivities/CVold8_tuned/", 
                                               "control.ss"), overwrite = T)








cvres <- ssoutput_parallel(ncores = 5, folders = c("model/base_model_2026",
                                                      "model/sensitivities/CVold6/",
                                                      "model/sensitivities/CVold8/"))

names(cvres) <- c("base", "CV.06", "CV.08")
cvsumm <- SSsummarize(cvres)
cvsumm$likelihoods
cvsumm$maxgrad
cvsumm$pars %>% slice(grep("R0", Label))

SSplotComparisons(cvsumm, subplot = 2)




#InitF--------------------------------------
#Currently initF is only on F26

#2023-F2-JPLL_A13_Q1
#2023-F22-JPPL_A35_Q2
#2023-F27-USLL_A35
#2023-F28-TWLL_A35
#2023-F34-EPO

#TWLLA35_EPO

#JPPLA35_TWLLA35 
#JPPLA35_USLLA35
#JPPLA35_JPLLA13

#2026-F1-JPLL_A13_Q1
#2026-F20-JPPL_A35_Q2
#2026-F24-USLL_A35
#2026-F26-TWLL_A35
#2026-F34-EPO

#Try on F26 and F34
change_initF(basedir = "model/base_model_2026",
             newdir = "model/sensitivities/initF_F26_F34/",
             initF_fleets = c(26, 34))


#20- 26
change_initF(basedir = "model/base_model_2026",
             newdir = "model/sensitivities/initF_F20_F26/",
             initF_fleets = c(20, 26))

#20-24
change_initF(basedir = "model/base_model_2026",
             newdir = "model/sensitivities/initF_F20_F24/",
             initF_fleets = c(20, 24))

#1-20
change_initF(basedir = "model/base_model_2026",
             newdir = "model/sensitivities/initF_F1_F20/",
             initF_fleets = c(1, 20))


SS_fitbiasramp(replist = SS_output("model/sensitivities/CVold6_tuned/"))


initFres <- ssoutput_parallel(ncores = 5, folders = c("model/base_model_2026",
                    "model/sensitivities/initF_F26_F34/",
                    "model/sensitivities/initF_F20_F26/",
                    "model/sensitivities/initF_F20_F24/",
                    "model/sensitivities/initF_F1_F20/"))

names(initFres) <- c("base_F26", "F26_F34", "F20_F26", "F20_F24", "F1_F20")
initFsumm <- SSsummarize(initFres)
initFsumm$likelihoods
initFsumm$maxgrad
initFsumm$pars %>% slice(grep("R0", Label))

SSplotComparisons(initFsumm, subplot = 2)


