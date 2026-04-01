#-------------------------------------------------------------------------------
#Sensitivities
#CHECK ####TODO TODO###
#Note No HESSIAN runs also
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

devtools::install_github("peterkuriyama-NOAA/hmsassessment")
library(hmsassessment)

# detach("package:hmsassessment", unload=TRUE)
#Add permissions to run ss command line if necessary
# system(" chmod +x 'ss3.30.24_linux/ss3'  ")

###Run these with Hessian and no windows output


#------Template for modifying sensitivities
todir <- "model/sens5b_2daroff/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))

###Change things here
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))
#------End of template


#-------------------------------------------------------------------------------
#Base model; waiting for Hessian to run on 
# base_model_2026, which is from 
# "model/day5base_scen4_F25fixed/"
# 
# 
basemod_folder <- "model/base_model_2026/"
# basemod <- SS_output(basemod_folder)
fromdir <- basemod_folder
flz <- c("control_modified.ss", "data.ss", "starter.ss", "ss3.par", "forecast.ss",
         "control.ss")
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
           overwrite = T, files = flz)
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$natM[1, ] <- 0.3
ctllist$natM[2, ] <- 0.3
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#Tune the model
todir_tuned <- "model/sens1a_M3_tuned/"
dir.create(todir_tuned)

copy_files(fromdir = todir , todir = todir_tuned,
           overwrite = F, files = flz)

newctl <- do_biasadj(tempdir = todir, ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)




#---------1b. Constant M of 0.48 and 0.39 for female and male of all ages, respectively; and
todir <- "model/sens1b_consM/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$natM[1, ] <- 0.48
ctllist$natM[2, ] <- 0.39
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))


#Tune the model
todir <- "model/sens1b_consM/"
todir_tuned <- "model/sens1b_consM_tuned/"
dir.create(todir_tuned)

copy_files(fromdir = todir , todir = todir_tuned,
           overwrite = F, files = flz)

newctl <- do_biasadj(tempdir = todir, ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)




#--------- 1c. Estimated M with Lorenzen based on prior from Kinney and Teo (2017).
todir <- "model/sens1c_estM/"
dir.create(todir)

copy_files(fromdir = fromdir , todir = todir,
           overwrite = F, files = flz)
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))

####TODO TODO###
todir <- "model/sens1c_estM/"
todir_tuned <- "model/sens1c_estM_tuned/"
dir.create(todir_tuned)

copy_files(fromdir = todir , todir = todir_tuned,
           overwrite = F, files = flz)

newctl <- do_biasadj(tempdir = todir, ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)


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

#-------------------
#tune recdevs
todir <- "model/sens2a_h75/"
todir_tuned <- "model/sens2a_h75tuned/"
dir.create(todir_tuned)

copy_files(fromdir = "model/sens2a_h75/" , todir = todir_tuned,
           overwrite = F, files = c("control_modified.ss", flz))

newctl <- do_biasadj(tempdir = todir, ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)



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


#-------------------
#tune recdevs
# todir <- "model/sens2a_h80/"
todir_tuned <- "model/sens2a_h80_tuned/"
dir.create(todir_tuned)

copy_files(fromdir = "model/sens2a_h80/" , todir = todir_tuned,
           overwrite = F, files = c("control_modified.ss", flz))

newctl <- do_biasadj(tempdir = "model/sens2a_h80/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)


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
# sens2a85 <- SS_output("model/sens2a_h85/")
# 
# bb <- SS_fitbiasramp(sens2a85, plot = F)
# dat1 <- SS_readdat(paste0(todir, "data.ss"))
# ctl1 <- SS_readctl(datlist = datlist, file = paste0(todir, "control_modified.ss"))
# 
# ctl1$last_early_yr_nobias_adj <- bb$df[1, 'value']
# ctl1$first_yr_fullbias_adj <- bb$df[2, 'value']
# ctl1$last_yr_fullbias_adj <- bb$df[3, 'value']
# ctl1$first_recent_yr_nobias_adj <- bb$df[4, 'value']
# ctl1$max_bias_adj <- bb$df[5, 'value']
# SS_writectl(ctllist = ctl1, outfile = paste0(todir, "control_modified.ss"), overwrite = T)

#-------------------
#tune recdevs
# todir <- "model/sens2a_h80/"
todir_tuned <- "model/sens2a_h85_tuned_v2/"
dir.create(todir_tuned)

copy_files(fromdir = "model/sens2a_h85/" , todir = todir_tuned,
           overwrite = F, files = c("control_modified.ss", "forecast.ss", "ss3.par", 
                                    "starter.ss", "data.ss"))

newctl <- do_biasadj(tempdir = "model/sens2a_h85/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)


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

####No convergence?###
####Tune recdevs
tempmod <- SS_output("model/sens2b_hprior")
tempmod$maximum_gradient_component
tempmod$parameters %>% slice(grep("NatM|R0|steep", Label))
# 
# tunedir <- "model/sens2b_hprior_tuned/"
# dir.create(tunedir)
# 
# copy_files(fromdir = "model/sens2b_hprior/" , todir = tunedir,
#             overwrite = F, files = flz)
# newctl <- do_biasadj(tempdir = "model/sens2b_hprior/", ctlname = "control_modified.ss")
# SS_writectl(newctl, outfile = paste0(tunedir, "control_modified.ss"))
# 


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

####Tune recdevs
tunedir <- "model/sens3a_cv6_tuned/"
dir.create(tunedir)

copy_files(fromdir = "model/sens3a_cv6/" , todir = tunedir,
           overwrite = T, files = flz)
newctl <- do_biasadj(tempdir = "model/sens3a_cv6/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(tunedir, "control_modified.ss"))


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

#Tune recdevs
tunedir <- "model/sens3a_cv8_tuned_v2/"
dir.create(tunedir)

copy_files(fromdir = "model/sens3a_cv8/" , todir = tunedir,
           overwrite = F, files = c("control_modified.ss", "forecast.ss", "ss3.par", 
                                    "starter.ss", "data.ss"))
newctl <- do_biasadj(tempdir = "model/sens3a_cv8/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(tunedir, "control_modified.ss"), overwrite = T)

#-----------    b. Estimating growth; turn on age comps for available data
todir <- "model/sens3b_estgrowth/"
dir.create(todir)
flz <- c("control.ss_new", "forecast.ss", "starter.ss", "data.ss")
copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)
start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
start$init_values_src <- 0
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))

#Modify control file manually
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss_new"))
ctllist$MG_parms[1:3, "PHASE"] <- c(6, 6, 6)

#Turn on lambdas
ageon <- datlist$agecomp %>% pull(fleet) %>% unique

ctllist$lambdas[which(ctllist$lambdas$like_comp == 5 & 
        ctllist$lambdas$fleet %in% ageon), "value"] <- 1

SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"), overwrite = T)
#Turned on the three non CV growth parameters to positive phases in control file
#TUrned on age lambdas for any fleet with CAAL data

#Tune recdevs
tunedir <- "model/sens3b_estgrowth_tuned_v2/"
dir.create(tunedir)

copy_files(fromdir = "model/sens3b_estgrowth/" , todir = tunedir,
           overwrite = F, files = c("control_modified.ss", "forecast.ss", "ss3.par", 
                                    "starter.ss", "data.ss"))
newctl <- do_biasadj(tempdir = "model/sens3b_estgrowth/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(tunedir, "control_modified.ss"), overwrite = T)


# ==========================================================================
# 4. Size composition weighting: (run on a different workstation)
#    a. Down weighting each individual fleet; and
todir <- "model/sens4a_fleetdown/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

#---copy original files
odir <- paste0(todir, "orig/")
dir.create(odir)
copy_files(fromdir = fromdir , todir = odir,
           overwrite = T, files = flz)

#---Find each fleet with varadjust
origdat <- SS_readdat(paste0(odir, "data.ss"))
origctl <- SS_readctl(datlist = origdat,
                      file = paste0(odir, "control.ss"))

fleets <- origctl$Variance_adjustment_list %>% filter(factor == 4) %>%
  distinct(fleet) %>% pull(fleet)


#----Create directories for each fleet
ii <- 1
newflz <- c("forecast.ss", "starter.ss", "data.ss", "ss3.par")

ncores <- 11
cl <- makeCluster(ncores)
registerDoParallel(cl)

start_time <- Sys.time()

foreach(ii = 1:length(fleets), .packages = c("r4ss")) %dopar% {
  newdir <- paste0(todir, "F", fleets[ii], "down/")    
  dir.create(newdir)
  copy_files(fromdir = fromdir , todir = newdir,
             overwrite = T, files = newflz)
  tempctl <- origctl
  
  tempind <- which(tempctl$Variance_adjustment_list$factor == 4 &
          tempctl$Variance_adjustment_list$fleet == fleets[ii])
  
  tempctl$Variance_adjustment_list[tempind, "value"] <- .01
  
  SS_writectl(ctllist = tempctl, outfile = paste0(newdir, "control.ss"))
  
  setwd(newdir)
  system('"../../../ss3.30.24_linux/ss3"')  
  setwd(orig_dir)
}

stopCluster(cl)
run_time <- Sys.time() - start_time; run_time


##-----------b. Down weighting all fleets so the input sample size is maximum 50 (currently 150).
todir <- "model/sens4b_sampsizedown/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))

ctllist$Variance_adjustment_list[which(ctllist$Variance_adjustment_list$factor == 4), 'value'] <-
  50 / (150 / .2752)
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))



# ==========================================================================
# 5. Selectivity:
#------5a.Different sigmas UP (up/down 0.25);
todir <- "model/sens5a_up/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = F, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))

ctllist$pars_2D_AR$INIT <- ctllist$pars_2D_AR$INIT + .25

SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#---Tune Rec Devs
tunedir <- "model/sens5a_up_tuned/"
dir.create(tunedir)

copy_files(fromdir = "model/sens5a_up/" , todir = tunedir,
           overwrite = F, files = flz)
newctl <- do_biasadj(tempdir = "model/sens3b_estgrowth/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(tunedir, "control_modified.ss"), overwrite = T)



##------5a. Different sigmas DOWN 0.25);
todir <- "model/sens5a_down/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = F, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))

ctllist$pars_2D_AR$INIT <- ctllist$pars_2D_AR$INIT - .25

SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#Tune Rec Devs
tunedir <- "model/sens5a_down_tuned/"
dir.create(tunedir)

copy_files(fromdir = "model/sens5a_down/" , todir = tunedir,
           overwrite = F, files = flz)
newctl <- do_biasadj(tempdir = "model/sens5a_down/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(tunedir, "control_modified.ss"), overwrite = T)




##------5b. Turn off 2DARs;
todir <- "model/sens5b_2daroff/"
dir.create(todir)

flz <- c("control.ss_new", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss_new"))

ctllist$Use_2D_AR1_selectivity <- 0


SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))

#Tune Recdevs
#NO HESSIAN
todir_tuned <- "model/sens5b_2daroff_tuned_v2/"
dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = todir , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = todir, ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)

# tmepmod <- SS_output(todir)



##------5c. No age selectivities;
todir <- "model/sens5c_noage/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))


SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))
#Change control file manually, turn starter to 0

todir_tuned <- "model/sens5c_noage_tuned_v2/"
dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = todir , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = todir, ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)



###------5d. Not assuming that the US longline fishery in Area 2 and 4 has a descending 
#       limb in asymptotic size selectivity.

# ==========================================================================
# 6. Index standardization models:
####------6a. S36 for adults all area include ASPM/ASPMR;
todir <- "model/sens6a_S36/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))
ctllist$lambdas[which(ctllist$lambdas$like_comp == 1 &
                        ctllist$lambdas$fleet == 10  ), 'value'] <- 0
ctllist$lambdas[which(ctllist$lambdas$like_comp == 1 &
                        ctllist$lambdas$fleet == 36  ), 'value'] <- 1
ctllist$lambdas %>% filter(like_comp == 1)

###Change things here
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))


#Tune Rec Devs
todir_tuned <- "model/sens6a_S36_tuned/"
dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = "model/sens6a_S36/" , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = "model/sens6a_S36/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)

##ASPM 
make_aspm(fromdir = "model/sens6a_S36_tuned/", 
          todir = "model/sens6a_S36_tuned_ASPM/",
          files = c("data.ss", "control.ss_new", "starter.ss", "ss3.par", 
                    "forecast.ss"))

##ASPMR
make_aspmr(fromdir = "model/sens6a_S36_tuned/", 
          todir = "model/sens6a_S36_tuned_ASPMR/")

####------6b. TWNLL JUV S37 in addition to F10 include ASPM/ASPMR; and
todir <- "model/sens6b_S37/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))

ctllist$lambdas[which(ctllist$lambdas$like_comp == 1 &
                        ctllist$lambdas$fleet == 37  ), 'value'] <- 1

ctllist$lambdas %>% filter(like_comp == 1)

###Change things here
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))


#Tune Rec Devs
todir_tuned <- "model/sens6b_S37_tuned/"
dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = "model/sens6b_S37/" , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = "model/sens6b_S37/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)


##ASPM 
make_aspm(fromdir = "model/sens6b_S37_tuned/", 
          todir = "model/sens6b_S37_tuned_ASPM/",
          files = c("data.ss", "control.ss_new", "starter.ss", "ss3.par", 
                    "forecast.ss"))

##ASPMR
make_aspmr(fromdir = "model/sens6b_S37_tuned/", 
           todir = "model/sens6b_S37_tuned_ASPMR/")




###------6c. GLM Juvenile: Area 3/5 & Quarter 3/4 (EPO) in addition to F10.
todir <- "model/sens6c_S34/"
dir.create(todir)

flz <- c("control.ss", "forecast.ss", "starter.ss", "data.ss",
         "ss3.par")

copy_files(fromdir = fromdir , todir = todir,
           overwrite = F, files = flz)

start <- SS_readstarter(file = paste0(todir, 'starter.ss'))
start$ctlfile <- "control_modified.ss"
SS_writestarter(mylist = start, file = paste0(todir, "starter.ss"), overwrite = T)
datlist <- SS_readdat(paste0(todir, "data.ss"))
ctllist <- SS_readctl(datlist = datlist, file = paste0(todir, "control.ss"))

ctllist$lambdas[which(ctllist$lambdas$like_comp == 1 &
                        ctllist$lambdas$fleet == 34  ), 'value'] <- 1

ctllist$lambdas %>% filter(like_comp == 1)

###Change things here
SS_writectl(ctllist = ctllist, outfile = paste0(todir, "control_modified.ss"))


#Tune Rec Devs
todir_tuned <- "model/sens6c_S34_tuned/"
dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = "model/sens6c_S34/" , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = "model/sens6c_S34/", ctlname = "control_modified.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control_modified.ss"), overwrite = T)

##ASPM 
make_aspm(fromdir = "model/sens6c_S34_tuned/", 
          todir = "model/sens6c_S34_tuned_ASPM/",
          files = flz1)

##ASPMR
make_aspmr(fromdir = "model/sens6c_S34_tuned/", 
           todir = "model/sens6c_S34_tuned_ASPMR/")

# ==========================================================================
# 7. Initial conditions:
#7a. Investigate other initial fleets – check what was done in 2023.
#Easiest to change manually

#---------------
todir_tuned <- "model/sens7a_initF_TWA35_EPO_tuned/"
dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = "model/sens7a_initF_TWA35_EPO/" , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = "model/sens7a_initF_TWA35_EPO/", ctlname = "control.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control.ss"), overwrite = T)

#---------------
todir_tuned <- "model/sens7b_initF_JPPLA35_JPLLA13_tuned/"
dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = "model/sens7b_initF_JPPLA35_JPLLA13/" , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = "model/sens7b_initF_JPPLA35_JPLLA13/", ctlname = "control.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control.ss"), overwrite = T)

#---------------
todir_tuned <- "model/sens7c_initF_JPPLA35_TWLLA35_tuned/"

dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = "model/sens7c_initF_JPPLA35_TWLLA35/" , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = "model/sens7c_initF_JPPLA35_TWLLA35/", ctlname = "control.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control.ss"), overwrite = T)


#---------------
todir_tuned <- "model/sens7d_initF_JPLLA35_USLLA24_tuned/"

dir.create(todir_tuned)
flz1 <- c(flz, "control_modified.ss")
copy_files(fromdir = "model/sens7d_initF_JPLLA35_USLLA24/" , todir = todir_tuned,
           overwrite = F, files = flz1)

newctl <- do_biasadj(tempdir = "model/sens7d_initF_JPLLA35_USLLA24/", ctlname = "control.ss")
SS_writectl(newctl, outfile = paste0(todir_tuned, "control.ss"), overwrite = T)


# ==========================================================================
# 8. Model Structure:
#    a. Same model structure as in 2023 stock assessment; and

#Easiest to change manually

#    b. Use 2023 model structure with updated data.
#Easiest to change manually
#-------------------------------------------------------------------------------



