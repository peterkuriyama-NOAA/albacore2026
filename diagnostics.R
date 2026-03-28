#-------------------------------------------------------------------------------
#Diagnostics
#-------------------------------------------------------------------------------
basemod_folder <- "model/day"
basemod <- SS_output()
#-------------------------------------------------------------------------------

##Model convergence (jittering)-------------------------------------------------

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
