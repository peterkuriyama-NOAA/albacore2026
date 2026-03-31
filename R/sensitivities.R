#-------------------------------------------------------------------------------
#Sensitivities
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

# devtools::install_github("peterkuriyama-NOAA/hmsassessment")
library(hmsassessment)

#Add permissions to run ss command line if necessary
# system(" chmod +x 'ss3.30.24_linux/ss3'  ")

###Run these with Hessian and no windows output

#-------------------------------------------------------------------------------
#Base model; waiting for Hessian to run on 
# base_model_2026, which is from 
# "model/day5base_scen4_F25fixed/"
# 
# 
basemod_folder <- "model/base_model_2026/"
# basemod <- SS_output(basemod_folder)
fromdir <- basemod_folder

#-------------------------------------------------------------------------------
#Catch curve is code is at end of diagnostics script

# ==========================================================================
# STOCK ASSESSMENT MODEL CONFIGURATION
# ==========================================================================

# ==========================================================================
# 1. Natural mortality (M):

#--------- 1a. Constant M of 0.3 across sexes and ages (same as approach used in 2014 assessment);
#running
todir <- "model/sens1a_M3/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$natM[1, ] <- 0.3
ctllist$natM[2, ] <- 0.3
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#---------1b. Constant M of 0.48 and 0.39 for female and male of all ages, respectively; and
todir <- "model/sens1b_consM/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$natM[1, ] <- 0.48
ctllist$natM[2, ] <- 0.39
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))




#--------- 1c. Estimated M with Lorenzen based on prior from Kinney and Teo (2017).
todir <- "model/sens1c_estM/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))



# ==========================================================================
# 2. Stock-recruitment steepness (h):
##--------- 2a. Alternative values for the steepness parameter (h=0.75; 0.80 and 0.85); and
todir <- "model/sens2a_h75/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$SR_parms[2, "INIT"] <- .75

SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

sens2a75 <- SS_output("model/sens2a_h75/")

bb <- SS_fitbiasramp(sens2a75)
dat1 <- SS_readdat(paste0(todir, "data.ss"))
ctl1 <- SS_readctl(datlist = datlist, file = paste0(todir, "control_modified.ss"))

ctl1$last_early_yr_nobias_adj <- bb$df[1, 'value']
ctl1$first_yr_fullbias_adj <- bb$df[2, 'value']
ctl1$last_yr_fullbias_adj <- bb$df[3, 'value']
ctl1$first_recent_yr_nobias_adj <- bb$df[4, 'value']
ctl1$max_bias_adj <- bb$df[5, 'value']
SS_writectl(ctllist = ctl1, outfile = paste0(todir, "control_modified.ss"), overwrite = T)


##---------steepness = 0.80
todir <- "model/sens2a_h80/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$SR_parms[2, "INIT"] <- .80
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#Adjust recdevs
start_time <- Sys.time()
sens2a80 <- SS_output("model/sens2a_h80/")
run_time <- Sys.time() - start_time; run_time

bb <- SS_fitbiasramp(sens2a80)
dat1 <- SS_readdat(paste0(todir, "data.ss"))
ctl1 <- SS_readctl(datlist = datlist, file = paste0(todir, "control_modified.ss"))

ctl1$last_early_yr_nobias_adj <- bb$df[1, 'value']
ctl1$first_yr_fullbias_adj <- bb$df[2, 'value']
ctl1$last_yr_fullbias_adj <- bb$df[3, 'value']
ctl1$first_recent_yr_nobias_adj <- bb$df[4, 'value']
ctl1$max_bias_adj <- bb$df[5, 'value']
SS_writectl(ctllist = ctl1, outfile = paste0(todir, "control_modified.ss"), overwrite = T)


##---------steepness = 0.85
todir <- "model/sens2a_h85/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$SR_parms[2, "INIT"] <- .85
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#Adjust recdevs
sens2a85 <- SS_output("model/sens2a_h85/")

bb <- SS_fitbiasramp(sens2a85)
dat1 <- SS_readdat(paste0(todir, "data.ss"))
ctl1 <- SS_readctl(datlist = datlist, file = paste0(todir, "control_modified.ss"))

ctl1$last_early_yr_nobias_adj <- bb$df[1, 'value']
ctl1$first_yr_fullbias_adj <- bb$df[2, 'value']
ctl1$last_yr_fullbias_adj <- bb$df[3, 'value']
ctl1$first_recent_yr_nobias_adj <- bb$df[4, 'value']
ctl1$max_bias_adj <- bb$df[5, 'value']
SS_writectl(ctllist = ctl1, outfile = paste0(todir, "control_modified.ss"), overwrite = T)

##--------- 2b. Adding prior based on Brodziak et al. (2011).
#Estimate natural mortality with Lorenzen M
#Steepness prior has sd=0.05 and M prior
todir <- "model/sens2b_hprior/"
dir.create(todir)

fromdir1 <- "model/sens1c_estM/"

flz <- c("control.ss_new", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")
copy_files(fromdir = fromdir1 , todir = todir,
           overwrite = T, files = flz)
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$init_values_src <- 0
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)

datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss_new"))

ctllist$SR_parms[2, "PR_SD"] <-  .05
ctllist$SR_parms[2, "PR_type"] <-  6
ctllist$SR_parms[2, "PHASE"] <-  4

SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

# ==========================================================================
# 3. Growth:
#    a. CV of Linf is fixed higher (0.06 or 0.08) than base case; and
todir <- "model/sens3a_cv6/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss_new"))

ctllist$MG_parms

prow <- which(row.names(ctllist$MG_parms) %in% c("CV_old_Fem_GP_1"))
ctllist$MG_parms[prow, "INIT"] <- .06
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))


#----value of 0.08
todir <- "model/sens3a_cv8/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss_new"))

prow <- which(row.names(ctllist$MG_parms) %in% c("CV_old_Fem_GP_1"))
ctllist$MG_parms[prow, "INIT"] <- .08
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#-----------    b. Estimating growth; turn on age comps for available data
todir <- "model/sens3b_estgrowth/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))

#Modify control file manually
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss_new"))

SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))
#Turned on the three non CV growth parameters to positive phases in control file
#TUrned on age lambdas for any fleet with CAAL data

# ==========================================================================
# 4. Size composition weighting: (run on a different workstation)
#    a. Down weighting each individual fleet; and
todir <- "model/sens2a_h85/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$SR_parms[2, "INIT"] <- .85
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#    b. Down weighting all fleets so the input sample size is maximum 50 (currently 150).

# ==========================================================================
# 5. Selectivity:
#    a. Different sigmas (up/down 0.25);
#    b. Turn off 2DARs;
#    c. No age selectivities;
#    d. Not assuming that the US longline fishery in Area 2 and 4 has a descending 
#       limb in asymptotic size selectivity.

# ==========================================================================
# 6. Index standardization models:
#    a. S36 for adults all area include ASPM/ASPMR;
#    b. TWNLL JUV S37 in addition to F10 include ASPM/ASPMR; and
#    c. GLM Juvenile: Area 3/5 & Quarter 3/4 (EPO) in addition to F10.

# ==========================================================================
# 7. Initial conditions:
#    a. Investigate other initial fleets – check what was done in 2023.

# ==========================================================================
# 8. Model Structure:
#    a. Same model structure as in 2023 stock assessment; and
#    b. Use 2023 model structure with updated data.

#-------------------------------------------------------------------------------



