#-------------------------------------------------------------------------------
#Diagnostics
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

#-------------------------------------------------------------------------------
#Base model; waiting for Hessian to run on 
# base_model_2026, which is from 
# "model/day5base_scen4_F25fixed/"
# 
# 
basemod_folder <- "model/base_model_2026/"
basemod <- SS_output(basemod_folder)

# #-------------------------------------------------------------------------------
##Model convergence (jittering)-------------------------------------------------

#Jitters
fromdir <- "model/base_model_2026/"
todir <- "model/base_model_2026_jitter_phase5R0/"
dir.create(todir)

original_dir <- paste0(todir, "/orig/")
dir.create(original_dir)

# flz <- list.files(fromdir)
copy_files(fromdir = fromdir , todir = original_dir,
           overwrite = T, files = list.files(fromdir))
file.copy(from = "ss3.30.24_linux/ss3", to = paste0(todir, "ss3"))

#njits 
njits <- 60
set.seed(300)
R0starts <- runif(n= njits, min = 11, max = 13)
R0starts <- round(R0starts, digits = 2)

#Copy the files over
for(ii in 1:length(R0starts)){
  
  tempdir <- paste0(todir, "R0_", R0starts[ii], "/")
  
  if(length(list.files(tempdir)) > 0) next
  
  dir.create(tempdir)
  copy_files(fromdir = original_dir , todir = tempdir,
             overwrite = T, files = list.files(original_dir))
  start <- SS_readstarter(file = paste0(tempdir, 'starter.ss'))
  start$ctlfile <- "control_modified.ss"
  start$jitter_fraction <- 0.1
  SS_writestarter(mylist = start, file = paste0(tempdir, "starter.ss"), overwrite = T)
  datlist <- SS_readdat(paste0(tempdir, "data.ss"))
  ctllist <- SS_readctl(datlist = datlist, file = paste0(tempdir, "control.ss"))
  ctllist$SR_parms[1, "INIT"] <- R0starts[ii]
  ctllist$SR_parms[1, "PHASE"] <- R0starts[ii]
  SS_writectl(ctllist = ctllist, outfile = paste0(tempdir, "control_modified.ss"),
              overwrite = T)

  parfile <- readLines(paste0(tempdir, "ss3.par"))  

  parfile[grep("SRparm\\[1", parfile)  + 1] <- as.character(R0starts[ii])
  writeLines(parfile, con = paste0(tempdir, "ss3.par"))
}

#---------------------Run the models in parallel

ff <- list.files("model/base_model_2026_jitter_phase5R0/")
ff <- ff[ff != "orig"]

flz <- list.files("model/base_model_2026_jitter_phase5R0/")
folds <- paste0("model/base_model_2026_jitter_phase5R0/", flz)


folds <-folds[ grep("31 00", file.info(paste0(folds, "/Report.sso"))$mtime)]
ff <- folds[folds != "model/base_model_2026_jitter_phase5R0/orig"]



ncores <- 10
cl <- makeCluster(ncores)
registerDoParallel(cl)

start_time <- Sys.time()
results <- foreach(ii = 1:length(ff), .packages = c("r4ss")) %dopar% {
  ##Run the model
  # R0dir <- paste0(todir, ff[ii])
  R0dir <- ff[ii]
  setwd(R0dir)
  # system("../ss3 -nohess -maxI 0")
  
  system("'../../../ss3.30.24_linux/ss3' -nohess -nox")
  setwd(orig_dir)
}

stopCluster(cl)
run_time <- Sys.time() - start_time; run_time

#Started at 5:24pm
# 
# #Specify number of 
# ncores <- 10
# numjitter <- 20
# 
# 
# future::plan(future::multisession, workers = ncores)
# jit.likes <- r4ss::jitter(
#   dir = todir, Njitter = numjitter,
#   jitter_fraction = 0.1, init_values_src = 1,
#   exe = "ss3", extras = "-nohess"
# )
# future::plan(future::sequential)

#--Save jitter runs and records; will need to modify some numbers as 
#necessary
flz <- list.files(todir)
folds <- paste0(todir, "Report", 1:50, ".sso")

jit.likes <- lapply(folds, FUN = function(xx){
  temp <- readLines(xx, n = 20)
  like <- plyr::ldply(strsplit(temp[19], split = ": "))  %>% pull(V2) %>%
    as.numeric
  return(like)
})
unlist(jit.likes)
likes2 <- data.frame(iter = 1:50, likes = unlist(jit.likes),
                     model = todir,
                     workstation = 'blue')
write.csv(likes2, file = "../albacore2026/output/likes2.csv", row.names = F)

#Compile all the jitter likelihoods
likes1 <- read.csv("../albacore2026/output/likes1.csv")
likes2 <- read.csv("../albacore2026/output/likes2.csv")
rbind(likes1, likes2) %>% pull(likes) %>% table


##ASPM and ASPMR----------------------------------------------------------------
fromdir <- "model/day5base_scen4_F25_fixed_best/" 
#Before modifying S36 sel to be 75 and 95 to match assumptions about spatiotemporal modeling

todir <- "model/base_model_2026_aspm/" 
hmsassessment::make_aspm(fromdir = fromdir, todir = todir, overwrite = T)

todir <- 'model/base_model_2026_aspmr/'
hmsassessment::make_aspmr(fromdir = fromdir, todir = todir, overwrite = T)

##R0 profiles-------------------------------------------------------------------
#Try another way of running the profile, moving out from the base model
R0.vec1 <- seq(11, 13, .2)
R0.vec2 <- seq(11, 13, .1)
R0.vec2 <- R0.vec2[which(R0.vec2 %in% R0.vec1 == FALSE)]
ncores <- min(12, length(R0.vec2))

R0.vec <- R0.vec2

dir_prof <- "model/base_model_2026_R0_profile_MLEout_vec2/"
copy_SS_inputs(dir.old= 'model/base_model_2026/', dir.new = dir_prof,
               create.dir = T, overwrite = T, copy_par = T,
               verbose = T)
file.copy(from = "ss3.30.24_linux/ss3", to = paste0(dir_prof, "ss3"))

#Modify base starter file in dir_prof
starter <- SS_readstarter(paste0(dir_prof, "/starter.ss"))
starter$run_display_detail <- 0
SS_writestarter(mylist = starter, file = paste0(dir_prof, "/starter.ss"),
                overwrite = T)

for(ii in 1:length(R0.vec)){
  
  R0dir <- paste0(dir_prof, "/R0_", ii)
  copy_SS_inputs( dir.old = dir_prof, dir.new = R0dir,
                  create.dir = T, overwrite = T, copy_par = T, verbose = F)
  #Change R0 value in par file  
  tempdat <- SS_readdat(paste0(R0dir, "/data.ss"))
  tempctl <- SS_readctl(datlist = tempdat, 
                        paste0(R0dir, "/control.ss"))
  temppar <- SS_readpar_3.30(paste0(R0dir, "/ss3.par"), datsource = tempdat,
                  ctlsource = tempctl)
  
  #Modify settings
  tempR <- tempctl$SR_parms 
  tempR[grep("R0", row.names(tempR)), 'INIT'] <- R0.vec[ii]
  tempR[grep("R0", row.names(tempR)), 'PHASE'] <- 
    tempR[grep("R0", row.names(tempR)), 'PHASE'] * -1
  tempctl$SR_parms <- tempR
  #WRite new control file
  SS_writectl(ctllist = tempctl, outfile =paste0(R0dir, "/control.ss"), overwrite = T)
  
  #Change par file
  temppar <- readLines(paste0(R0dir, "/ss3.par"))
  temppar[grep("SRparm\\[1", temppar) + 1] <- as.character(R0.vec[ii])
  writeLines(text = temppar, con = paste0(R0dir, "/ss3.par"))  
}


###Run the models in parallel
# ncores <- length(folds)

cl <- makeCluster(ncores)
registerDoParallel(cl)

start_time <- Sys.time()
results <- foreach(ii = 1:length(R0.vec), .packages = c("r4ss")) %dopar% {
  ##Run the model
  R0dir <- paste0(dir_prof, "/R0_", ii)
  setwd(R0dir)
  # system("../ss3 -nohess -maxI 0")
  system("../ss3 -nohess")
  setwd(orig_dir)
}

stopCluster(cl)
run_time <- Sys.time() - start_time; run_time

#Compile all R0 results#---------------------------

#Combine folders to compile
folds1 <- paste0("model/base_model_2026_R0_profile_MLEout")
f1val <- list.files(folds1)[grep("R0", list.files(folds1))]
folds1 <- paste0(folds1, "/",f1val)
folds2 <- paste0("model/base_model_2026_R0_profile_MLEout_vec2")
f2val <- list.files(folds2)[grep("R0", list.files(folds2))]
folds2 <- paste0(folds2, "/",f2val)

folds <- c(folds1, folds2, basemod_folder)

#----------------Read in results
# res <- ssoutput_parallel(ncores = 10, folders = folds)
# summs <- SSsummarize(res)
# 
# R0s <- summs$pars %>% slice(grep("R0", Label)) %>%melt(id.var = c("Label", "Yr", "recdev")) %>%
#   select(variable, value) %>% rename(R0val = "value")
# 
# likes <- summs$likelihoods %>% filter(Label == "TOTAL") %>% melt %>% 
#   mutate(minval = min(value), delta = value - minval) 
# likes <- likes %>% left_join(R0s, by = 'variable')
# 
# likes %>%
#   ggplot(aes(x = R0val, y = delta)) + geom_line() + geom_point() + 
#   geom_hline(aes(yintercept = 1.92), lty = 2)  +  
#   geom_vline(aes(xintercept = 12.1204), lty = 2)
  


##Residual Analysis---------------------------------




##Retrospective Analysis---------------------------------
fromdir <- basemod_folder
todir <- "model/base_model_2026_hindcast/"

# nretros <- 5
# npreds <- 5

#Need to re do this
make_hindcast_files(fromdir = fromdir, todir = todir,
                    nretros = 5, npreds = 5)

ncores <- 12

hinds <- list.files(todir)
hinds <- hinds[hinds != 'orig' & hinds != 'desktop.ini']
hinds <- paste0(todir, "/",hinds, "/")

####Run models in parallel
cl <- makeCluster(ncores)
registerDoParallel(cl)

start_time <- Sys.time()
results <- foreach(ii = 1:length(hinds), .packages = c("r4ss")) %dopar% {
  ##Run the model
  # R0dir <- paste0(dir_prof, "/R0_", ii)
  setwd(hinds[ii])
  # system("'../../../ss3.30.24_linux/ss3' -nohess -maxI 0")
  system("'../../../ss3.30.24_linux/ss3' -nohess")
  setwd(orig_dir)
}

stopCluster(cl)
run_time <- Sys.time() - start_time; run_time

#Steve's function to calculate MASE
ssreps2mase <- function(x, fleet, horizon=NULL, details=F, naive.all=F) {
  if (is.null(fleet)) { stop('Missing fleet ID.') }
  nmod <- length(x)
  out <- data.frame(model=1:nmod,  startyr=NA, retroyr=NA, termyr=NA, predyr=NA, 
                    horizon=NA, predobs=NA, predexp=NA) 
  for (ii in 1:nmod) {
    cpue <- NULL
    cpue <- x[[ii]]$cpue[ x[[ii]]$cpue$Fleet == fleet, ]
    if (is.null(cpue)) { stop('Check output from SSgetoutput. Cannot match fleets.') }
    out$startyr[ii] <- min( cpue$Yr[ cpue$Use == 1 ] )
    out$retroyr[ii] <- x[[ii]]$Retro_year
    out$termyr[ii] <- max(cpue$Yr[ cpue$Use == 1 ] )
    
    # browser()
    if ( is.null(horizon) ) {
      out$predyr[ii] <- out$retroyr[ii]
      out$horizon[ii] <- out$predyr[ii] - out$termyr[ii]
    } else {
      out$predyr[ii] <- out$termyr[ii] + horizon
      out$horizon[ii] <- horizon
    }
    out$predobs[ii] <- cpue$Obs[ cpue$Yr == out$predyr[ii] ]
    out$predexp[ii] <- cpue$Exp[ cpue$Yr == out$predyr[ii] ]
  }
  out$absprederr <- abs( out$predexp - out$predobs )
  mintermyr <- min(out$termyr)
  maxtermyr <- max(out$termyr)
  minretroyr <- min(out$retroyr)
  maxretroyr <- max(out$retroyr)
  
  startyr <- out$startyr[1]
  horizon2 <- out$horizon[1]
  if ( sum(out$startyr != startyr) > 0 ) { stop('Check models! Index has inconsistent start years.')	}
  if ( sum(out$horizon != horizon2) > 0 ) { stop('Check models! Horizon has inconsistent number of years.')	}
  
  if (naive.all) {
    naiveobs <- cpue$Obs[ which(cpue$Yr==(startyr+out$horizon[1])):which(cpue$Yr==maxretroyr) ]
    naiveexp <- cpue$Obs[ which(cpue$Yr==startyr):which(cpue$Yr==(maxretroyr-out$horizon[1])) ]
  } else {	
    naiveobs <- cpue$Obs[ which(cpue$Yr==mintermyr):which(cpue$Yr==maxretroyr) ]
    naiveexp <- cpue$Obs[ which(cpue$Yr==(mintermyr-out$horizon[1])):which(cpue$Yr==(maxretroyr-out$horizon[1])) ]
  }

  meanabsnaiveprederr <- mean(abs(naiveexp - naiveobs))
  out$meanabsnaiveprederr <- meanabsnaiveprederr
  
  mase <- data.frame( MASE=mean(out$absprederr)/meanabsnaiveprederr,
                      nmodels=nmod,
                      nretro=max(out$retroyr) - min(out$retroyr),
                      horizon=out$horizon[1],
                      meanabsprederr=mean(out$absprederr),
                      meanabsnaiveprederr=meanabsnaiveprederr
  )
  
  if (details) { 
    print('Predictions:')
    print(out$predexp)
    print('Observations:') 
    print(out$predobs)
    print('Naive Predictions:')
    print(naiveexp)
    print('Naive Observations:') 
    print(naiveobs)
    print('MASE:')
    print(mase)
  }
  return(mase)
}
ssreps2mafe <- function(x, fleet, details=F) {
  if (is.null(fleet)) { stop('Missing fleet ID.') }
  nmod <- length(x)
  out <- data.frame(model=1:nmod,  startyr=NA, retroyr=NA, termyr=NA, absfiterr=NA) 
  for (ii in 1:nmod) {
    cpue <- NULL
    cpue <- x[[ii]]$cpue[ x[[ii]]$cpue$Fleet == fleet, ]
    if (is.null(cpue)) { stop('Check output from SSgetoutput. Cannot match fleets.') }
    out$startyr[ii] <- min( cpue$Yr[ cpue$Use == 1 ] )
    out$retroyr[ii] <- x[[ii]]$Retro_year
    out$termyr[ii] <- max(cpue$Yr[ cpue$Use == 1 ] )
    
    obs <- cpue$Obs[ cpue$Use == 1 ]
    exp <- cpue$Exp[ cpue$Use == 1 ]
    out$absfiterr[ii] <- mean(abs(exp-obs))
  } 
  mafe <- mean(out$absfiterr)
  
  if (details) { 
    print(out)
  }
  return(mafe)
}


##-----Pull the F10 CPUE values out
hind_res <- ssoutput_parallel(ncores = 10,  fold = hinds)
#takes 3 minutes

# 
# cpues <- lapply(hind_res, FUN = function(xx) {
#   temp <- xx$cpue %>% filter(Fleet == 10)
#   return(temp)
#   }
# )

names(cpues) <- names(hind_res)
cpues <- cpues %>% ldply
names(cpues)[1] <- 'model'


##Group by preds 1:5
mase.combo <- lapply(1:5, FUN = function(xx){
  SSreps <- hind_res[grep(paste0("pred", xx), hinds)]
  
  mase <- ssreps2mase(SSreps, fleet=10, details=T, naive.all=F) # estimated mase
  
  meanabsfiterr <- ssreps2mafe(SSreps, fleet=10, details=T) #estimated fit error on same scale
  mase2 <- cbind(mase, meanabsfiterr)
  return(mase2)  
})

mase.combo <- ldply(mase.combo)
write.csv(mase.combo, file = "../albacore2026/output/mase.csv", row.names = F)


####Catch-curve analysis---------------------
fromdir <- basemod_folder
todir <- "model/base_model_2026_catchcurve/"
dir.create(todir)

# flz <- list.files(fromdir)
copy_files(fromdir = fromdir , todir = todir,
           overwrite = T, files = list.files(fromdir))

#Turn CPUE lambda off
newdat <- SS_readdat(paste0(todir, "data.ss"))
newctl <- SS_readctl(datlist = newdat, file = paste0(todir, "control.ss"))

newctl$lambdas[which(newctl$lambdas$like_comp == 1 & newctl$lambdas$value == 1), 'value'] <- 0
file.copy(from = paste0(todir, "control.ss"), to = paste0(todir, "control_old.ss"))
SS_writectl(ctllist = newctl, outfile = paste0(todir, "control.ss"), 
            overwrite = T)




























#Old Code#-------------------------
# 
# dir_prof <- "model/base_model_2026_R0profile/"
# copy_SS_inputs(dir.old= 'model/base_model_2026/', dir.new = dir_prof,
#                create.dir = T, overwrite = T, copy_par = T,
#                verbose = T)
# 
# #Copy SS version
# system(paste0("cp ss3.30.24_linux/ss3", " ", dir_prof))
# 
# starter <- SS_readstarter(file.path(dir_prof, "starter.ss"))
# # change control file name in the starter file
# starter[["ctlfile"]] <- "control_modified.ss"
# # for non-estimated quantities
# starter[["prior_like"]] <- 1
# # write modified starter file
# SS_writestarter(starter, dir = dir_prof, overwrite = TRUE)
# 
# # vector of values to profile over
# R0.vec <- seq(10.8, 13.2, by = .1)
# 
# Nprofile <- length(R0.vec)
# 
# #Run models in parallel
# ncores <- Nprofile
# 
# future::plan(future::multisession, workers = ncores)
# prof.table <- profile(
#   dir = dir_prof,
#   oldctlfile = "control.ss",
#   newctlfile = "control_modified.ss",
#   string = "R0", # subset of parameter label
#   profilevec = R0.vec,
#   extras = "-nohess"
# )
# #-------------------------------------------------------
# #Check gradients of some model runs
# paste0(dir_prof, "Report", 1:length(R0.vec), ".sso")
# 
# 
# rr <- list.files("model/base_model_2026_jitter_phase5R0")
# grads <- data.frame(R0 = rr, grad = 999, nll = 999)
# 
# for(jj in 1:length(rr)){
#   temp <- readLines(paste0("model/base_model_2026_jitter_phase5R0/", rr[jj], "/Report.sso"), n = 20  )
#   grads[jj, 'grad'] <- as.numeric(strsplit(temp[15] , split = " ")[[1]][2])
#   grads[jj, 'nll'] <- as.numeric(strsplit(temp[19] , split = " ")[[1]][2])
# }



# grads <- data.frame(R0 = R0.vec, grad = 999, nll = 999)
# 
# for(ii in 1:length(R0.vec)){
#   temp <- readLines(paste0(dir_prof, "/Report", ii, ".sso"), n = 20)
#   grads[ii, 'grad'] <- as.numeric(strsplit(temp[15] , split = " ")[[1]][2])
#   grads[ii, 'nll'] <- as.numeric(strsplit(temp[19] , split = " ")[[1]][2])
# }
# grads
# 
# ggplot(grads,aes(x = R0, y = nll)) + geom_line() + geom_point()
# 

# #Manually pick values to copy over
# #Find values to copy over
# # paste0(dir_prof, "/Report", ii, ".sso")
# 
# #
# from_vec <- 9
# to_vecs <- c(10, 11)
# 
# 
# #Make directories
# newfolds <- paste0("R0_", grads[to_vecs, "R0"])
# newR0vals <- grads[to_vecs, "R0"]
# newfolds <- paste0(dir_prof, "/", newfolds)
# # lapply(newfolds, FUN = function(xx) dir.create(xx))
# 
# #Copy files
# flz <- c("control_modified.ss", "forecast.ss", "data.ss",  "starter.ss")
# 
# for(ii in 1:length(newfolds)){
# 
#   dir.create(newfolds[ii])
#   copy_files(fromdir = paste0(dir_prof, "/"), todir =  paste0(newfolds[ii], "/"),
#              files = flz, overwrite = T)
#   file.copy(from = paste0(dir_prof, "/ss3.par_", from_vec, ".sso"),
#             to = paste0(newfolds[ii], "/ss3.par"))
# 
#   #Change starter to start from par
#   starter <- SS_readstarter(paste0(newfolds[ii], "/starter.ss"))
#   starter$init_values_src <- 1
#   SS_writestarter(starter, dir = newfolds[ii], overwrite = T )
# 
#   #Modify the R0 vals
#   datlist <- SS_readdat(paste0(newfolds[ii], "/data.ss"))
#   ctlfile <- SS_readctl(datlist = datlist,
#                         file = paste0(newfolds[ii], "/control_modified.ss"))
# 
#   parfile <- readLines(paste0(newfolds[ii], "/ss3.par"))
#   parfile[77] <- as.character(newR0vals[ii])
#   writeLines(parfile, con = paste0(newfolds[ii], "/ss3.par"))
# 
# 
#   # grep(" SRparm[1]", parfile[1:200])
# 
#   # parfile <- SS_readpar_3.30(datsource = datlist, ctlsource = ctlfile, paste0(newfolds[ii], "/ss3.par"))
# 
#   #
#   #
# 
#   # ctlfile$SR_parms[1, "INIT"] <- newR0vals[ii]
#   # SS_writectl(ctllist = ctlfile, outfile = paste0(newfolds[ii], "/control_modified.ss"),
#   #             overwrite = T)
# }
# 
# #Check to make sure that for the R0 runs,
# #the R0 in control and par files are set to right value, phase negative
# 
# folds <- list.files(dir_prof)[grep("R0", list.files(dir_prof))]
# R0vals <- as.numeric(gsub("R0_", "", folds))
# folds <- paste0(dir_prof,"/", folds)
# 
# #for(ii in 2:length(folds)){
# for(ii in 1:length(folds)){
#   dat <- SS_readdat(paste0(folds[ii], "/data.ss"))
#   # ctlnew <- SS_readctl(datlist = dat, paste0(folds[ii], "/control.ss_new"))
#   if(ctlnew$SR_parms[1, "PHASE"] > 0) ctlnew$SR_parms[1, "PHASE"] <- -1
# 
#   ctl <- SS_readctl(datlist = dat, paste0(folds[ii], "/control_modified.ss"))
#   if(ctl$SR_parms[1, "PHASE"] > 0) ctl$SR_parms[1, "PHASE"] <- -1
#   ctl$SR_parms[1, "INIT"] <- R0vals[ii]
# 
#   SS_writectl(ctllist = ctl, outfile = paste0(folds[ii], "/control_modified.ss"),
#               overwrite = T)
# 
#   #----Par file
#   parfile <- readLines(paste0(folds[ii], "/ss3.par"))
#   parfile[77] <- as.character(R0vals[ii])
#   writeLines(parfile, con = paste0(folds[ii], "/ss3.par"))
# 
# }
# 
# 
# 
# 
# 
# 
# #------------------------------------
# #------Run these models in parallel
# 
# r0files <- list.files(dir_prof)[grep("R0", list.files(dir_prof))]
# folds <- paste0(dir_prof, r0files)
# 
# 
# ncores <- length(folds)
# cl <- makeCluster(ncores)
# registerDoParallel(cl)
# 
# start_time <- Sys.time()
# results <- foreach(ii = 1:length(folds), .packages = c("r4ss")) %dopar% {
#   ##Run the model
#   setwd(folds[ii])
#   # system("../ss3 -nohess -maxI 0")
#   system("../ss3 -nohess")
#   setwd(orig_dir)
# }
# 
# stopCluster(cl)
# run_time <- Sys.time() - start_time; run_time
# 
# 
# #-------------------Check the model runs
# 
# checkfolds <- list.files(dir_prof)[grep("R0", list.files(dir_prof))]
# checkgrads <- data.frame(R0 = as.numeric(gsub("R0_", "", checkfolds)),
#                          grad1 = 999)
# 
# checkfolds <- paste0(dir_prof, "/",checkfolds)
# 
# #Runs 1 and
# 
# 
# R0.vec <- seq(11, 13, by = .2)
# length(R0.vec)
# paste0(dir_prof, "Report", 1:length(R0.vec), ".sso")
# 
# grads <- data.frame(R0 = R0.vec, grad = 999, likes = 999)
# 
# for(ii in 1:length(R0.vec)){
#   temp <- readLines(paste0(dir_prof, "/Report", ii, ".sso"), n = 20)
# 
#   grads[ii, 'grad'] <- as.numeric(strsplit(temp[15] , split = " ")[[1]][2])
#   grads[ii, 'likes'] <- as.numeric(strsplit(temp[19] , split = " ")[[1]][2])
# }
# grads$run <- 1
# 
# grads2 <- grads[1:length(checkfolds), ]
# grads2$run <- 2
# grads2
# 
# rr <- list.files(dir_prof)[grep("R0", list.files(dir_prof))]
# grads2[, 1] <- strsplit(rr, split = "_") %>% ldply %>% pull(V2) %>%
#   as.numeric
# 
# for(ii in 1:length(checkfolds)){
#   temp <- readLines(paste0(checkfolds[ii], "/Report", ".sso"), n = 20)
# 
#   grads2[ii, 'grad'] <- as.numeric(strsplit(temp[15] , split = " ")[[1]][2])
#   grads2[ii, 'likes'] <- as.numeric(strsplit(temp[19] , split = " ")[[1]][2])
# 
# }
# 
# rbind(grads, grads2)
# 
# rbind(grads, grads2) %>% filter(grad < 1e-3) %>% arrange(R0)
# 
# 

# 
# 
# 
# 
# cc <- strsplit(cpues$model, split = "//") %>% ldply() %>% pull(V2)
# cc <- gsub("/", "", cc)
# cc1 <- strsplit(cc, split = "_") %>% ldply() %>% 
#   mutate(npred = substr(V1, 5, 5), 
#          retro = substr(V2, 6, 6)) %>% select(npred, retro)
# cpues <- cbind(cpues, cc1)
# 
# write.csv(cpues, file = "../albacore2026/output/hindcast_F10.csv", row.names = F)
# 
