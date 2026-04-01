#------------------------------------------------------------------------------------------------
#Figures for virtual follow up meeting
basemod


# 
# dquants <- lapply(res, FUN = function(xx) xx$derived_quants)
# names(dquants) <- names(res)
# dquants <- ldply(dquants)
# names(dquants)[1] <- "type"

dquants <- basemod$derived_quants




#-----------------SSBs with uncertainties
# names(bios) <- names(res)
# bios <- ldply(bios)
# names(bios)[1] <- "type"

bios <- dquants %>% slice(grep("SSB_19|SSB_20", Label)) %>% 
  mutate(lo = qnorm(.025, mean = Value, sd = StdDev),
         hi = qnorm(.975, mean = Value, sd = StdDev))

# bios <- bios %>%  select(1:10)
bios$Yr <- as.numeric(ldply(strsplit(bios$Label, split = "_"))$V2)
bios[which(bios$Value == bios$lo), c("lo", "hi")] <- NA



summbios <- dquants %>% slice(grep("SmryBio_19|SmryBio_20", Label)) %>% 
  mutate(lo = qnorm(.025, mean = Value, sd = StdDev),
         hi = qnorm(.975, mean = Value, sd = StdDev))

# bios <- bios %>%  select(1:10)
summbios$Yr <- as.numeric(ldply(strsplit(summbios$Label, split = "_"))$V2)
summbios[which(summbios$Value == summbios$lo), c("lo", "hi")] <- NA


#-----------------Recruitments with uncrtaintiy

recs <- dquants %>% slice(grep("Recr_19|Recr_20", Label)) %>% 
  mutate(lo = qnorm(.025, mean = Value, sd = StdDev),
         hi = qnorm(.975, mean = Value, sd = StdDev))
recs$Yr <- as.numeric(ldply(strsplit(recs$Label, split = "_"))$V2)
recs[which(recs$Value == recs$lo), c("lo", "hi")] <- NA




#-----------------Plots

p0 <- summbios %>% 
  ggplot(aes(x = Yr, y = Value)) + geom_line()  +
  scale_y_continuous(label = comma, lim = c(0, NA)) + theme_sleek() +
  geom_line(aes(y = lo), lty = 2) + geom_point() +
  geom_line(aes(y = hi), lty = 2) + 
  theme(legend.position = c(.75, .85)) + xlab("Year") + ylab("Age 1+ biomass (mt)") +
  scale_color_manual(values = cbPalette) +
  guides(color = guide_legend(title = ""))

p1 <- bios %>% 
  ggplot(aes(x = Yr, y = Value)) + geom_line()  +
  scale_y_continuous(label = comma, lim = c(0, NA)) + theme_sleek() +
  geom_line(aes(y = lo), lty = 2) + geom_point() +
  geom_line(aes(y = hi), lty = 2) + 
  theme(legend.position = c(.75, .85)) + xlab("Year") + ylab("SpawnBio (mt)") +
  scale_color_manual(values = cbPalette) +
  guides(color = guide_legend(title = ""))



p2 <- recs %>% 
  ggplot(aes(x = Yr, y = Value)) + geom_line()  + geom_point() +
  scale_y_continuous(label = comma, lim = c(0, NA)) + theme_sleek() +
  geom_line(aes(y = lo), lty = 2) + 
  geom_line(aes(y = hi), lty = 2) + 
  theme(legend.position = c(.75, .85)) + xlab("Year") + ylab("Recruits (1000s of fish)") +
  scale_color_manual(values = cbPalette) +
  guides(color = guide_legend(title = ""))

p0 /p1 / p2
dir.create("Y:/My Drive/assessments/albacore2026/figs/basemodel/")
ggsave("Y:/My Drive/assessments/albacore2026/figs/basemodel/smry_ssb_rec.png", width = 7, height = 8.8)

#------------------------
deps <- lapply(res, FUN = function(xx) xx$Dynamic_Bzero)
names(deps) <- names(res)
deps <- ldply(deps)
names(deps)[1] <- "model"

deps <- deps %>% mutate(dep = SSB / SSB_nofishing)

# deps %>% filter(Era != "VIRG") %>%
#   ggplot(aes(x = Yr, y = dep, group = model, color = model)) +
#   geom_point() + geom_line() + ylim(0, NA) +
#   geom_hline(aes(yintercept = 0.3), lty = 2) +
#   geom_hline(aes(yintercept = 0.14), lty = 2) + theme_sleek() +
#   xlab("Year") + ylab("Depletion level") + theme(legend.position = c(.5, .2)) +
#   scale_color_manual(values = cbPalette) +
#   guides(color = guide_legend(title = ""))

# basemod$Dynamic_Bzero


deps <- dquants %>% slice(grep("Dyn_Bzero_19|Dyn_Bzero_20", Label)) %>%
  mutate(lo5 = qnorm(.025, mean = Value, sd = StdDev),
         hi5 = qnorm(.975, mean = Value, sd = StdDev),
         hi40 = qnorm(.8, mean = Value, sd = StdDev),
         lo40 = qnorm(.2, mean = Value, sd = StdDev))

deps <- cbind(deps, basemod$Dynamic_Bzero %>% filter(Yr >= 1994) %>% select(Yr, SSB))
deps$dep <- deps$SSB / deps$Value
deps$dep_lo5 <- deps$SSB / deps$lo5
deps$dep_hi5 <- deps$SSB / deps$hi5
deps$dep_lo40 <- deps$SSB / deps$lo40
deps$dep_hi40 <- deps$SSB / deps$hi40


m1 <-deps %>% ggplot(aes(x = Yr, y = dep)) + 
  theme_sleek()  + scale_y_continuous(lim = c(0, NA)) + 
  geom_hline(aes(yintercept = .14), lty = 2) + 
  geom_hline(aes(yintercept = .3), lty = 3) + 
  geom_ribbon(aes(ymin = dep_lo5, ymax = dep_hi5), alpha = .5, fill = 'gray') +
  geom_ribbon(aes(ymin = dep_lo40, ymax = dep_hi40), alpha = .5, fill = 'gray') + 
  geom_point() + geom_line() + 
  xlab("Year") + ylab(expression("Dynamic biomass ratio; SSB/SSB"["currentF=0"]))




# m1 <- deps %>% 
#   ggplot(aes(x = Yr, y = Value)) +
#   geom_point() + geom_line() + ylim(0, NA) +
#   geom_hline(aes(yintercept = 0.3), lty = 2) +
#   geom_hline(aes(yintercept = 0.14), lty = 2) + theme_sleek() +
#   xlab("Year") + ylab("Depletion level") + theme(legend.position = c(.5, .2)) +
#   scale_color_manual(values = cbPalette) +
#   guides(color = guide_legend(title = ""))

b1 <- list(base = basemod, base1 = basemod)
sprs <- lapply(b1, FUN = function(xx) xx$derived_quants)
names(sprs) <- names(b1)
sprs <- ldply(sprs)
names(sprs)[1] <- "model"



sprs <- sprs %>% slice(grep("SPRratio", Label)) %>% filter(model == 'base')

sprs$year <- strsplit(sprs$Label, split = "_") %>% ldply() %>% pull(V2)
sprs$year <- as.numeric(sprs$year)
sprs$lo <- qnorm(.025,mean =  sprs$Value, sd = sprs$StdDev)
sprs$hi <- qnorm(.975,mean =  sprs$Value, sd = sprs$StdDev)

m2 <- sprs %>% ggplot(aes(x = year, y = Value)) + geom_line(aes(y = lo), lty = 2) + 
  geom_line(aes(y = hi), lty = 2) + geom_point() + geom_line() + 
  theme_sleek() + xlab("Year") + geom_hline(aes(yintercept = 0.45), lty = 2) + 
  ylab(expression("F"["%SPR"])) +scale_y_continuous(breaks = seq(0, 1, by =  .1),
                                                    labels = seq(100, 0, by = -10),
                                                    lim = c(0, 1))



m1 / m2
ggsave("Y:/My Drive/assessments/albacore2026/figs/basemodel/bratio_fspr.png", width = 7, height = 7)

# geom_point(aes( group= model, color = model)) +
#   geom_line(aes( group= model, color = model)) +
#   geom_hline(aes(yintercept = 0.45), lty = 2) + ylim(0, NA)  + theme_sleek() +
#   xlab("Year")  + theme(legend.position = c(.5, .2)) +
#   scale_color_manual(values = cbPalette) +
#   theme(legend.position = "none") +
#   # guides(color = guide_legend(title = ""))  +
#   ylab(expression("F"["%SPR"])) +
#   geom_text(data = anntemp, aes(x = xpos,y = ypos, hjust=hjustvar,vjust=vjustvar,label=annotateText)) +
#   scale_y_continuous(breaks = seq(0, 1, by =  .1),
#                      labels = seq(100, 0, by = -10),
#                      lim = c(0, 1))
# 



# sprs %>% ggplot(aes(x = year, y = Value, group= model, color = model)) + geom_point() + geom_line() +
#   geom_hline(aes(yintercept = 0.55)) + ylim(0, NA)  + theme_sleek() +
#   xlab("Year") + ylab("SPR") + theme(legend.position = c(.5, .2)) +
#   scale_color_manual(values = cbPalette) +
#   guides(color = guide_legend(title = ""))

#--------------------------------------------------------------------------------------------------------------
#La Jolla Plot

# library('r4ss')
# devtools::load_all('C:\\Users\\steve.teo\\Desktop\\20260323_NPALB_stock_assess\\r4ss_Kuriyama_20260316') # base r4ss crashes

### Functions ###
mean_sd_derived_quant_byyr <- function(ssrep.in, wantedyrs, label='SPRratio_') {
  full.labels <- paste0(label,wantedyrs)
  d.quant <- ssrep.in$derived_quants[ssrep.in$derived_quants$Label %in% full.labels,]
  d.quant$var <- d.quant$StdDev^2
  
  if (length(wantedyrs) == 1) {
    d.quant.covar <- ssrep.in$CoVar[1]
    d.quant.covar$covar <- 0
  } else {
    d.quant.covar <- ssrep.in$CoVar[ (ssrep.in$CoVar$label.i %in% full.labels)&
                                       (ssrep.in$CoVar$label.j %in% full.labels), ]
    for (ii in 1:nrow(d.quant.covar)) {
      d.quant.covar$covar[ii] <- d.quant.covar$corr[ii] *
        d.quant$StdDev[(d.quant$Label==d.quant.covar$label.i[ii])]*
        d.quant$StdDev[(d.quant$Label==d.quant.covar$label.j[ii])]
    }
  }
  
  d.quant.mean <- mean(d.quant$Value)
  d.quant.sd <- sqrt(sum(d.quant$var)+sum(2*d.quant.covar$covar))/nrow(d.quant)
  return(data.frame(mean=d.quant.mean, sd=d.quant.sd))
}

plot.npalb.refpt.panels <- function(xlim=c(0,1), ylim=c(100,0),xlab='SSB/SSB_refpt',ylab=expression('F'[SPR]),xbreaks=c(0.14,0.30), ybreaks=c(0,0),blk.col=c('red','orange','green')) {
  
  print(ylim)
  poly.vert.x.1 <- c(xlim[1],xbreaks[1],xbreaks[1],xlim[1])
  poly.vert.y.1 <- c(ybreaks[1],ybreaks[1],ylim[1],ylim[1])
  poly.vert.x.2 <- c(xbreaks[1],xbreaks[2],xbreaks[2],xbreaks[1])
  poly.vert.y.2 <- c(ybreaks[2],ybreaks[2],ylim[1],ylim[1])
  poly.vert.x.3 <- c(xbreaks[2],xlim[2],xlim[2],xbreaks[2])
  poly.vert.y.3 <- c(ybreaks[2],ybreaks[2],ylim[1],ylim[1])
  
  plot(x=NA,y=NA, xlim=xlim,ylim=ylim,xlab=xlab,ylab=ylab)
  polygon(x=poly.vert.x.1 ,y=poly.vert.y.1, density=NA, col=blk.col[1])
  polygon(x=poly.vert.x.2 ,y=poly.vert.y.2, density=NA, col=blk.col[2])
  polygon(x=poly.vert.x.3 ,y=poly.vert.y.3, density=NA, col=blk.col[3])
}

plot.npalb.refpt.panels.2 <- function(xlim=c(0,1), 
                                      ylim=c(100,0),
                                      xlab='SSB/SSB_refpt',
                                      ylab=expression('F'[SPR]),
                                      xbreaks=c(0.14,0.30,1.0), 
                                      ybreaks=c(0,0,45), 
                                      blk.col=c('red','orange','green','yellow')) {
  
  poly.vert.x.1 <- c(xlim[1],xbreaks[1],xbreaks[1],xlim[1])
  poly.vert.y.1 <- c(ybreaks[1],ybreaks[1],ylim[1],ylim[1])
  poly.vert.x.2 <- c(xbreaks[1],xbreaks[2],xbreaks[2],xbreaks[1])
  poly.vert.y.2 <- c(ybreaks[2],ybreaks[2],ylim[1],ylim[1])
  poly.vert.x.3 <- c(xbreaks[2],xbreaks[3],xbreaks[3],xbreaks[2])
  poly.vert.y.3 <- c(ybreaks[3],ybreaks[3],ylim[1],ylim[1])
  poly.vert.x.4 <- c(xbreaks[2],xbreaks[3],xbreaks[3],xbreaks[2])
  poly.vert.y.4 <- c(ybreaks[3],ybreaks[3],ylim[2],ylim[2])
  
  
  plot(x=NA,y=NA, xlim=xlim,ylim=ylim,xlab=xlab,ylab=ylab)
  polygon(x=poly.vert.x.1 ,y=poly.vert.y.1, density=NA, col=blk.col[1])
  polygon(x=poly.vert.x.2 ,y=poly.vert.y.2, density=NA, col=blk.col[2])
  polygon(x=poly.vert.x.3 ,y=poly.vert.y.3, density=NA, col=blk.col[3])
  polygon(x=poly.vert.x.4 ,y=poly.vert.y.4, density=NA, col=blk.col[4])
  
}

plot.npalb.trp <- function(Fspr.trp=45, xlim=c(0,1), ylim=c(100,0), trp.lty=2, trp.lwd=2, trp.color='black', plot.bratio=F) {
  bratio.trp <- Fspr.trp/100
  lines(x=xlim,y=c(Fspr.trp,Fspr.trp), col=trp.color, lty=trp.lty, lwd=trp.lwd)
  if (plot.bratio) {
    lines(x=c(bratio.trp,bratio.trp),y=ylim, col=trp.color, lty=trp.lty, lwd=trp.lwd)
  }  
}

plot.npalb.0204 <- function(Fspr.0204, xlim=c(0,1), endpt.color='black', lty.0204=3, lwd.0204=1) {
  lines(x=xlim, y=c(Fspr.0204,Fspr.0204), col=endpt.color, lty=lty.0204, lwd=lwd.0204)
}

pickpar4plot <- function(par.in, nmodel, pick) {
  if (length(par.in) >= nmodel) {
    par.out <- par.in[pick]
  } else {
    par.out <- par.in[1]
  }
  return(par.out)
}

#################

#### get ssreps ####
### Must set Bratio to Dynamic Bratio for NPALB (check starter file)

# Set directories of ss models to read
# ssdirvec <- c(
#               '../../ss/00a_05_04_basecase_clean/'
#               ,'../../../SS_model/20230404_basecase_sensitivities/10_growth/10a2_biasadj//'
#               ,'../../../SS_model/20230404_basecase_sensitivities/10_growth/10d2_biasadj/'
#               ,'../../../SS_model/20230404_basecase_sensitivities/11_2020_model_update/11a2_biasadj//'
#               )
# ssdirvec <- c('C:\\Users\\steve.teo\\Desktop\\20260323_NPALB_stock_assess\\ss_models\\2026_base_model')

# ssreps <- SSgetoutput(dirvec=ssdirvec)
ssreps <- basemod

#### plot time series status plots, with endyr uncertainty ####
ssrep <- ssreps # assumes first ss model is base case, change if neccessary

Fspr.ci <- 0.95 
Bratio.ci <- 0.95
cex=1.5
pts.pch<-16
pts.col<-c('gray75')
line.lty<-c(1) 
line.col<-pts.col
line.lwd<-2
nmodel <- 1
startpt.pch=17
startpt.col=c('blue')
endpt.pch=16
endpt.col=c('black')
ci.yr=2024 # set year for confidence intervals cross
ci.lty=c(1)
ci.col=endpt.col
ci.lwd=2
refpt.plot.xlim <- c(0,1.0)
refpt.plot.ylim <- c(100,0)
outfile_TF <- T # set T to output as png
outfile <- "Y:/My Drive/assessments/albacore2026/figs/basemodel/2026_basecase_lajolla_plot.png"


startyr <- ssrep$startyr
endyr <- ssrep$endyr
yrvec <- startyr:endyr

bratio.labels <- paste0('Bratio_',yrvec)
sprratio.labels <- paste0('SPRratio_',yrvec)

Fspr.sd2ci.mult <- qnorm(p=Fspr.ci+((1-Fspr.ci)/2))
Bratio.sd2ci.mult <- qnorm(p=Bratio.ci+((1-Bratio.ci)/2))

bratio.timeseries <- ssrep$derived_quants[ssrep$derived_quants$Label %in% bratio.labels,]
bratio.timeseries$yr <- yrvec
bratio.timeseries$ci <- Bratio.ci
bratio.timeseries$upci <- bratio.timeseries$Value + Bratio.sd2ci.mult*bratio.timeseries$StdDev
bratio.timeseries$loci <- bratio.timeseries$Value - Bratio.sd2ci.mult*bratio.timeseries$StdDev

sprratio.timeseries <- ssrep$derived_quants[ssrep$derived_quants$Label %in% sprratio.labels,]
sprratio.timeseries$yr <- yrvec
sprratio.timeseries$Fspr <- 100*(1-sprratio.timeseries$Value)
sprratio.timeseries$ci <- Fspr.ci 
sprratio.timeseries$Fspr.upci <- sprratio.timeseries$Fspr + Fspr.sd2ci.mult*100*sprratio.timeseries$StdDev
sprratio.timeseries$Fspr.loci <- sprratio.timeseries$Fspr - Fspr.sd2ci.mult*100*sprratio.timeseries$StdDev

line.x.plot <- bratio.timeseries$Value
line.y.plot <- sprratio.timeseries$Fspr
line.lty.plot <- pickpar4plot(par.in=line.lty, nmodel=nmodel, pick=1)
line.col.plot <- pickpar4plot(par.in=line.col, nmodel=nmodel, pick=1)
line.lwd.plot <- pickpar4plot(par.in=line.lwd, nmodel=nmodel, pick=1)
pts.x.plot <- bratio.timeseries$Value
pts.y.plot <- sprratio.timeseries$Fspr
pts.pch.plot <- pickpar4plot(par.in=pts.pch, nmodel=nmodel, pick=1)
pts.col.plot <- pickpar4plot(par.in=pts.col, nmodel=nmodel, pick=1)
startpt.x.plot <- bratio.timeseries$Value[1]
startpt.y.plot <- sprratio.timeseries$Fspr[1]
startpt.pch.plot <- pickpar4plot(par.in=startpt.pch, nmodel=nmodel, pick=1)
startpt.col.plot <- pickpar4plot(par.in=startpt.col, nmodel=nmodel, pick=1)
endpt.x.plot <- bratio.timeseries$Value[nrow(bratio.timeseries)]
endpt.y.plot <- sprratio.timeseries$Fspr[nrow(bratio.timeseries)]
endpt.pch.plot <- pickpar4plot(par.in=endpt.pch, nmodel=nmodel, pick=1)
endpt.col.plot <- pickpar4plot(par.in=endpt.col, nmodel=nmodel, pick=1)

if (outfile_TF) { png(outfile) } # change file type

plot.npalb.refpt.panels.2(xlim=refpt.plot.xlim, 
                          ylim=refpt.plot.ylim, 
                          xlab=expression('SSB/SSB'[paste('current, F=',0)]),
                          ylab=expression(F[phantom()*'%'*SPR]), 
                          xbreaks=c(0.14,0.30, 1),
                          ybreaks=c(refpt.plot.ylim[2],refpt.plot.ylim[2],45)
)

lines(x=line.x.plot, y=line.y.plot,	lty=line.lty.plot, col=line.col.plot, lwd=line.lwd.plot)
points(x=pts.x.plot, y=pts.y.plot, pch=pts.pch.plot, col=pts.col.plot, cex=cex)
points(x=startpt.x.plot, y=startpt.y.plot, pch=startpt.pch.plot, col=startpt.col.plot, cex=cex)
points(x=endpt.x.plot, y=endpt.y.plot, pch=endpt.pch.plot, col=endpt.col.plot, cex=cex)

ci.lty.plot <- pickpar4plot(par.in=ci.lty, nmodel=nmodel, pick=1)
ci.col.plot <- pickpar4plot(par.in=ci.col, nmodel=nmodel, pick=1)
ci.lwd.plot <- pickpar4plot(par.in=ci.lwd, nmodel=nmodel, pick=1)
for (ii in 1:length(ci.yr)) {
  ci.yr.row <- (bratio.timeseries$yr == ci.yr)
  ci.bratio.x.plot <- c(bratio.timeseries$loci[ci.yr.row], bratio.timeseries$upci[ci.yr.row])
  ci.bratio.y.plot <- c(sprratio.timeseries$Fspr[ci.yr.row],sprratio.timeseries$Fspr[ci.yr.row])
  ci.Fspr.x.plot <- c(bratio.timeseries$Value[ci.yr.row],bratio.timeseries$Value[ci.yr.row]) 
  ci.Fspr.y.plot <- c(sprratio.timeseries$Fspr.loci[ci.yr.row],sprratio.timeseries$Fspr.upci[ci.yr.row])
  lines(x=ci.bratio.x.plot, y=ci.bratio.y.plot, lty=ci.lty.plot, col=ci.col.plot, lwd=ci.lwd.plot)
  lines(x=ci.Fspr.x.plot, y=ci.Fspr.y.plot, lty=ci.lty.plot, col=ci.col.plot, lwd=ci.lwd.plot)
}

plot.yeartext <- c(1994,2000,2010,2020) # set year labels in plot
text(x=pts.x.plot[yrvec %in% plot.yeartext],
     y=pts.y.plot[yrvec %in% plot.yeartext],
     labels=plot.yeartext, 
     col=pts.col.plot, pos=4, cex=0.8)



if (outfile_TF) { dev.off() }











#-------------------------------------------------------------------------------------------------------------------------------------------------
#### plot endpt with 95CI for multiple models
ss_summ <- SSsummarize(ssreps)

Fspr.ci <- 0.95
Bratio.ci <- 0.95
cex=1.5
pts.pch<-16
pts.col<-c('gray75')
line.lty<-c(1) 
line.col<-pts.col
line.lwd<-2
nmodel <- 1
startpt.pch=17
startpt.col=c('blue')
endpt.pch=c(16,15,17,18) # set pch for each model
endpt.col=c('black','gray75','purple','red') # set color of each model
ci.TF <- c(T,T,T,F) # Turn on (T) or off (F) the confidence interval cross for each model
ci.yr=2024 # set year for confidence intervals cross
ci.lty=c(1)
ci.col=endpt.col
ci.lwd=2
lty.0204 <- 3
lwd.0204 <- 2

outfile_TF <- T # set T to output as png
outfile <- '2026_multimodel_lajolla_plot.png'

refpt.plot.xlim <- c(0,1)
refpt.plot.ylim <- c(100,0)
bratio.yrs <- c(2021) # st years
sprratio.yrs <- c(2018, 2019, 2020)

bratio.labels <- paste0('Bratio_',bratio.yrs)
sprratio.labels <- paste0('SPRratio_',sprratio.yrs)
Fspr.sd2ci.mult <- qnorm(p=Fspr.ci+((1-Fspr.ci)/2))
Bratio.sd2ci.mult <- qnorm(p=Bratio.ci+((1-Bratio.ci)/2))
Bratio.multimodel <- data.frame(model=seq(1,length(ssreps)), Value=NA, StdDev=NA,
                                ci=Bratio.ci, loci=NA, hici=NA)
Fspr.multimodel <- data.frame(model=seq(1,length(ssreps)), Value=NA, StdDev=NA,
                              ci=Fspr.ci, loci=NA, hici=NA)
Fspr0204.multimodel <- data.frame(model=seq(1,length(ssreps)), Value=NA, StdDev=NA,
                                  ci=Fspr.ci, loci=NA, hici=NA)

for (ii in 1:length(ssreps)) {
  meanSPRratio <- mean_sd_derived_quant_byyr(ssrep.in=ssreps[[ii]],
                                             wantedyrs = sprratio.yrs,
                                             label='SPRratio_')
  meanBratio <- mean_sd_derived_quant_byyr(ssrep.in=ssreps[[ii]],
                                           wantedyrs = bratio.yrs,
                                           label='Bratio_')
  
  Bratio.multimodel$Value[ii] <- meanBratio$mean
  Bratio.multimodel$StdDev[ii] <- meanBratio$sd
  Bratio.multimodel$loci[ii] <- Bratio.multimodel$Value[ii] - Bratio.sd2ci.mult*Bratio.multimodel$StdDev[ii]
  Bratio.multimodel$hici[ii] <- Bratio.multimodel$Value[ii] + Bratio.sd2ci.mult*Bratio.multimodel$StdDev[ii]
  
  Fspr.multimodel$Value[ii] <- 100*(1-meanSPRratio$mean)
  Fspr.multimodel$StdDev[ii] <- 100*meanSPRratio$sd
  Fspr.multimodel$loci[ii] <- Fspr.multimodel$Value[ii] - Fspr.sd2ci.mult*Fspr.multimodel$StdDev[ii]
  Fspr.multimodel$hici[ii] <- Fspr.multimodel$Value[ii] + Fspr.sd2ci.mult*Fspr.multimodel$StdDev[ii]
  
  meanSPRratio.0204 <- mean_sd_derived_quant_byyr(ssrep.in=ssreps[[ii]], 
                                                  wantedyrs = 2002:2004, 
                                                  label='SPRratio_')
  Fspr0204.multimodel$Value[ii] <- 100*(1-meanSPRratio.0204$mean)
  Fspr0204.multimodel$StdDev[ii] <- 100*meanSPRratio.0204$sd
  Fspr0204.multimodel$loci[ii] <- Fspr0204.multimodel$Value[ii] - Fspr.sd2ci.mult*Fspr0204.multimodel$StdDev[ii]
  Fspr0204.multimodel$hici[ii] <- Fspr0204.multimodel$Value[ii] + Fspr.sd2ci.mult*Fspr0204.multimodel$StdDev[ii]
  
}

if (outfile_TF) { png(outfile) } # change file type

plot.npalb.refpt.panels.2(xlim=refpt.plot.xlim, 
                          ylim=refpt.plot.ylim, 
                          xlab=expression('SSB/SSB'[paste('current, F=',0)]),
                          ylab=expression(F[phantom()*'%'*SPR]), 
                          xbreaks=c(0.14,0.30, 1),
                          ybreaks=c(refpt.plot.ylim[2],refpt.plot.ylim[2],45)
)

for (ii in 1:length(ssreps)) {
  # plot.npalb.0204(Fspr.0204=Fspr0204.multimodel$Value[ii], xlim=refpt.plot.xlim, lty.0204=lty.0204, lwd.0204=lwd.0204, endpt.color=endpt.col[ii])
  points(x=Bratio.multimodel$Value[ii],y=Fspr.multimodel$Value[ii], pch=endpt.pch[ii], col=endpt.col[ii], cex=1.5)
  if (ci.TF[ii]) {
    lines(x=c(Bratio.multimodel$Value[ii],Bratio.multimodel$Value[ii]),
          y=c(Fspr.multimodel$loci[ii],Fspr.multimodel$hici[ii]), col=endpt.col[ii], lty=1, lwd=2)
    lines(x=c(Bratio.multimodel$loci[ii],Bratio.multimodel$hici[ii]),
          y=c(Fspr.multimodel$Value[ii],Fspr.multimodel$Value[ii]), col=endpt.col[ii], lty=1, lwd=2)
  }
  
}
if (outfile_TF) { dev.off() } 
