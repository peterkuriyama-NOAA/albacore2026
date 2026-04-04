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

f2val <- f2val[-which(f2val %in% c("R0_5_old"))]

folds2 <- paste0(folds2, "/",f2val)

folds <- c(folds1, folds2, basemod_folder)

#check the R0s

#----------------Read in results
R0res <- ssoutput_parallel(ncores = 10, folders = folds) #Takes like 2.5 minutes

# R0resorig <- R0res
# R0res <- R0resorig

# R0res <- R0res[-16]


names(R0res)
R0summs <- SSsummarize(R0res[-17], verbose = F)

R0summs$pars %>% slice(grep("R0", Label)) %>% melt(id.var = c("Label", "Yr", "recdev"))  %>% 
  arrange(value)



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

R0_figfold <- paste0(figfold, "R0profile_v3")
dir.create(R0_figfold)  

make_R0profile_plots(figfold = R0_figfold, res = R0res[-17])



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



##Fishery impact----------------------------------------------------------------------
#rm(list=ls())

# library(r4ss)
library(colorRamps)

startyr <- 2000
endyr <- 2024
outfile <- "Y:/My Drive/assessments/albacore2026/figs/fishery_impacts.png"

outfile.TF <- T

dirvec <- c("model/base_model_2026",
            "model/base_model_2026_noLL", "model/base_model_2026_nocatch","model/base_model_2026_nosurface")
SSreps <- ssoutput_parallel(ncores = length(dirvec), folders = dirvec)
SSsummary <- SSsummarize(SSreps)

yearvec <- seq(startyr,endyr)
wantedrows <- (SSsummary$SpawnBio$Yr >= startyr)&(SSsummary$SpawnBio$Yr <= endyr)

SSB.nocatch <- SSsummary$SpawnBio[wantedrows,3]
SSB.noSF <- SSsummary$SpawnBio[wantedrows,4]
SSB.noLL <- SSsummary$SpawnBio[wantedrows,2]
SSB.allcatch <- SSsummary$SpawnBio[wantedrows,1]


impact.LL <- SSB.nocatch - SSB.noSF 
impact.SF <- SSB.nocatch - SSB.noLL

pct.LL.1 <- 100*(impact.LL/SSB.nocatch)
pct.SF.1 <- 100*(impact.SF/SSB.nocatch)
pct.all.1 <- 100 - pct.LL.1 - pct.SF.1
matrix.1 <- cbind(pct.all.1,pct.LL.1,pct.SF.1)


pct.LL.2 <- 100*(impact.LL/(impact.SF+impact.LL))
pct.SF.2 <- 100*(impact.SF/(impact.SF+impact.LL))


if (outfile.TF) {
  png(outfile)
}

stackpoly(x=yearvec,y=matrix.1,ylab='Percentage of dynamic SSB0 (%)',col=rainbow(3),ylim=c(0,100))
text(x=c(2003,2003,2003),y=c(85,57,20), labels=c('Surface','Longline','Current SSB'))

if (outfile.TF) {
  dev.off()
}


#-----------------------------------------------------------------
##Sensitivities
#-----------------------------------------------------------------

##1.Natural mortalities---------------------------------------
Mfolds <- c("model/sens1a_M3/", "model/sens1b_consM/",
  "model/sens1c_estM//")

Mres <- ssoutput_parallel(ncores = 3, folders = Mfolds)
Mres1 <- Mres
Mres1[[4]] <- basemod
names(Mres1) <- c('M=0.3', "M=consM_consF", "estM", "base2026")

figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens1_M/"
dir.create(figfolder)

plot_sensitivity(Mres1, figfolder = figfolder)



##2.Steepness--------------------------------------- 
hfold <- list.files('model')[grep("sens2a", list.files('model'))]
hfold <- hfold[grep("tuned", hfold)]

hfold <- c(hfold, "sens2b_hprior", "base_model_2026")
hres <- ssoutput_parallel(ncores = length(hfold), 
                          folders = paste0("model/", hfold))

hsumm <- SSsummarize(hres)

names(hres) <- c('h=0.75', "h=0.80", "h=0.85", 'h est (no conv)', "base2026")

figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens2_steep/"
dir.create(figfolder)

plot_sensitivity(hres, figfolder = figfolder)

##Plot without esth runs
figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens2_steep_noesth/"
dir.create(figfolder)

plot_sensitivity(hres[-4], figfolder = figfolder)
list.files('model')[grep("sens", list.files('model'))]



##3. Growth---------------------------------------

gfold <- c("sens3a_cv8_tuned_v2",
  "sens3b_estgrowth_tuned_v2", "base_model_2026")
gfold <- paste0("model/", gfold)

gres <- ssoutput_parallel(ncores = length(gfold), 
                          folders = gfold)

names(gres) <- c("cvold=.08", "growth est", "base2026")

figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens3_growth/"
dir.create(figfolder)

plot_sensitivity(gres, figfolder = figfolder)

##4.Size composition Weighting ---------------------------------------
scfold <- list.files('model')[grep("sens4", list.files('model'))]
scfold1 <- list.files(paste0("model/",scfold[1]))


sc1 <- paste0("model/", scfold[1],"/",scfold1[grep("F", scfold1)])
sc2 <- paste0("model/", scfold[2])
scfold <- c(sc1, sc2)

# scres <- ssoutput_parallel(folders = scfold, ncores = 10)
# save(scres, file = "output/scres.Rdata")

#Compare likelihoods fit to index and comps and 
#SSBs

scres[[25]] <- basemod
names(scres)[25] <- 'basemod'

scres_summ <- SSsummarize(scres)

totlikes <- scres_summ$likelihoods %>% melt(id.var = "Label")
totlikes$variable <- as.character(totlikes$variable)

vv <- data.frame(variable = unique(totlikes$variable))
vv2 <- strsplit(vv$variable, split = "\\/") %>% lapply(FUN = function(xx) temp <- xx[length(xx)]) %>%
  ldply %>% pull(V1)


vv$modname <- vv2
vv$modname1 <- vv$modname
vv$modname1 <- gsub("F", "", vv$modname1)
vv$modname1 <- gsub("down", "", vv$modname1)
vv$modname1 <- as.numeric(vv$modname1)

ff <- fleetkey %>% filter(type == "base") %>% select(fleetnum, fishery, area, fleet_name) %>% rename(modname1 = "fleetnum")
vv <- vv %>% left_join(ff, by = "modname1") 

vv[which(is.na(vv$fleet_name)), 'fleet_name'] <- vv[which(is.na(vv$fleet_name)), 'modname']

totlikes <- totlikes %>% left_join(vv, by = 'variable')

totlikes <- totlikes %>% group_by(Label) %>% mutate(minval = min(value), delta = value - minval)  %>% as.data.frame


#-----Survey likelihoods
mle_survey <- totlikes %>% filter(Label == "Survey", modname == "basemod") %>% pull(delta)
totlikes %>% filter(Label == "Survey") %>% ggplot(aes(x = fleet_name, y = delta)) + 
  geom_point() + theme_sleek() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) + 
  geom_hline(aes(yintercept  = mle_survey), lty = 2) + xlab("Model run") + ylab("Survey change in NLL")
ggsave("Y:/My Drive/assessments/albacore2026/figs/totlikes_sizecompweighting.png", width = 8, height = 7)

#Lengthc omp likelihoods
mle_length <- totlikes %>% filter(Label == "Length_comp", modname == "basemod") %>% pull(delta)
totlikes %>% filter(Label == "Length_comp") %>% ggplot(aes(x = fleet_name, y = delta)) + 
  geom_point() + theme_sleek() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) + 
  geom_hline(aes(yintercept  = mle_length), lty = 2) + xlab("Model run") + 
  ylab("Length comp change in NLL")

ggsave("Y:/My Drive/assessments/albacore2026/figs/lengthcomplikes_sizecompweighting.png", width = 8, height = 7)
##SSBs
ssbs <- scres_summ$SpawnBio %>% melt(id.var = c("Label", "Yr"))

ssbs <- ssbs %>% left_join(vv, by = 'variable')

ssbs[which(is.na(ssbs$fishery)), "fishery"] <- ssbs[which(is.na(ssbs$fishery)), "fleet_name"]


ssbs %>% filter(Yr >= 1994) %>% ggplot(aes(x = Yr, y = value, group = fleet_name, color = fleet_name)) + 
  geom_line() + facet_wrap(~ fishery) + theme_sleek() +
  theme(legend.position = "none") + scale_y_continuous(label = comma, lim = c(0, NA)) + 
  ylab("SSB (mt)") + xlab("Year")

ggsave("Y:/My Drive/assessments/albacore2026/figs/ssbs_sizecompweighting.png", width = 8, height = 7)

#5. Selectivity-------------------------------------------------------------------
# selruns <- list.files("model")[grep("sens5",list.files("model"))]
# selruns <- selruns[grep("tune", selruns)]

selruns <- c("sens5a_down", "sens5a_up","sens5b_2daroff", "sens5c_noage",  "base_model_2026")

selfold <- paste0("model/", c(selruns))

selres <- ssoutput_parallel(ncores = 5, folders = selfold)
names(selres) <- c('sigma_down.25', "sigma_up.25","2dAR off"  ,"No age sel","base2026")


figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens5_selex/"
dir.create(figfolder)

plot_sensitivity(selres, figfolder = figfolder)



#6. Index standardization models---------------------------------------
indexruns <- list.files("model")[grep("sens6",list.files("model"))]
indexfolds <- paste0("model/", c("sens6a_S36_tuned", "sens6b_S37_tuned", "sens6c_S34_tuned"))

indexres <- ssoutput_parallel(ncores = 5, folders = indexfolds)
indexres[[4]] <- basemod
names(indexres)[4] <- "base"
names(indexres) <- c('S36 only', "F10 and S37",  "F10 and S34",  "base2026")


figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens6_index/"
dir.create(figfolder)

plot_sensitivity(indexres, figfolder = figfolder)

###ASPMs
#S36_tuned----------------
aspm36 <- list.files("model")[grep("S36_tuned", list.files("model"))]
aspm36 <- paste0("model/", aspm36, "/")

aspm36res <- ssoutput_parallel(ncores = 3, folders = aspm36)
names(aspm36res) <- c("base", "aspm", "aspmr")
# res <- list(base = basemod, aspm = aspm, aspmr = aspmr)
aspm36summs <- SSsummarize(aspm36res)

aspm_figfold <- "Y:/My Drive/assessments/albacore2026/figs/S36_ASPM/"

dir.create(aspm_figfold)  
compare_aspm(figfold = aspm_figfold, 
             aspm_res = aspm36res)


#S37_tuned----------------
aspm37 <- list.files("model")[grep("S37_tuned", list.files("model"))]
aspm37 <- paste0("model/", aspm37, "/")

aspm37res <- ssoutput_parallel(ncores = 3, folders = aspm37)
names(aspm37res) <- c("base", "aspm", "aspmr")
# res <- list(base = basemod, aspm = aspm, aspmr = aspmr)
aspm37summs <- SSsummarize(aspm37res)

aspm_figfold <- "Y:/My Drive/assessments/albacore2026/figs/S37_ASPM/"

dir.create(aspm_figfold)  
compare_aspm(figfold = aspm_figfold, 
             aspm_res = aspm37res)

#S34_tuned--------------------------
aspm34 <- list.files("model")[grep("S34_tuned", list.files("model"))]
aspm34 <- paste0("model/", aspm34, "/")

aspm34res <- ssoutput_parallel(ncores = 3, folders = aspm34)
names(aspm34res) <- c("base", "aspm", "aspmr")
# res <- list(base = basemod, aspm = aspm, aspmr = aspmr)
aspm34summs <- SSsummarize(aspm34res)

aspm_figfold <- "Y:/My Drive/assessments/albacore2026/figs/S34_ASPM/"

dir.create(aspm_figfold)  
compare_aspm(figfold = aspm_figfold, 
             aspm_res = aspm34res)



#7. Initial conditions---------------------------------------
init_folds <- list.files("model")[grep("sens7", list.files("model"))]
init_folds <- paste0("model/", c(init_folds[grep("tuned", init_folds)], "base_model_2026"))
init_res <- ssoutput_parallel(ncores = 5, folders = init_folds)

names(init_res) <- c('TWLLA35_EPOSF', "JPPLA35_JPLLA13",  "JPPLA35_TWLLA35",  "JPLLA35_USLLA24",
                     "base")

figfolder <- "Y:/My Drive/assessments/albacore2026/figs/sens7_initF/"
dir.create(figfolder)

plot_sensitivity(init_res, figfolder = figfolder)

# 8. Model Structure---------------------------------------


