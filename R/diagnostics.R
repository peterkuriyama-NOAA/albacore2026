#-------------------------------------------------------------------------------
#Diagnostics
#-------------------------------------------------------------------------------
#Starting on workstations
orig_dir <- "/home/user/2026_albacore"
setwd(orig_dir)

source("Rcode/alb_header.R")


#-------Add in assessment packages
remotes::install_github("r4ss/r4ss")
library(r4ss)

devtools::install_github("peterkuriyama/cpsassessment")
library(cpsassessment)

devtools::install_github("peterkuriyama-NOAA/hmsassessment")

#Add permissions to run ss command line if necessary
# system(" chmod +x 'ss3.30.24_linux/ss3'  ")

#-------------------------------------------------------------------------------
#Base model
basemod_folder <- "model/day"
basemod <- SS_output()
#-------------------------------------------------------------------------------

##Model convergence (jittering)-------------------------------------------------

#Jitters
fromdir <- "model/day5base_scen4_F25fixed/"
todir <- "model/day5base_scen4_F25fixed_jitter/"
dir.create(todir)

# flz <- list.files(fromdir)
copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))
file.copy(from = "ss3.30.24_linux/ss3", to = paste0(todir, "ss3"))


ncores <- 10
numjitter <- 10


future::plan(future::multisession, workers = ncores)
jit.likes <- r4ss::jitter(
  dir = todir, Njitter = numjitter,
  jitter_fraction = 0.1, init_values_src = 1,
  exe = "ss3", extras = "-nohess"
)
future::plan(future::sequential)


##ASPM and ASPMR----------------------------------------------------------------



##R0 profiles-------------------------------------------------------------------
#Specify base model


dir_prof <- "model/day4base_mixedsel_R0profile/"
copy_SS_inputs(dir.old= 'model/day4base_mixedsel/', dir.new = dir_prof,
               create.dir = T, overwrite = T, copy_par = T,
               verbose = T)

#Copy SS version
system(paste0("cp ss3.30.24_linux/ss3", " ", dir_prof))

starter <- SS_readstarter(file.path(dir_prof, "starter.ss"))
# change control file name in the starter file
starter[["ctlfile"]] <- "control_modified.ss"
# for non-estimated quantities
starter[["prior_like"]] <- 1
# write modified starter file
SS_writestarter(starter, dir = dir_prof, overwrite = TRUE)

# vector of values to profile over
R0.vec <- seq(10.8, 13.2, by = .1)

Nprofile <- length(R0.vec)

#Run models in parallel
ncores <- Nprofile

future::plan(future::multisession, workers = ncores)
prof.table <- profile(
  dir = dir_prof,
  oldctlfile = "control.ss",
  newctlfile = "control_modified.ss",
  string = "R0", # subset of parameter label
  profilevec = R0.vec,
  extras = "-nohess"
)



##Residual Analysis---------------------------------

##Retrospective Analysis---------------------------------
