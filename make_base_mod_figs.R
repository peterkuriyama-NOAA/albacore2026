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



sprs %>% ggplot(aes(x = year, y = Value, group= model, color = model)) + geom_point() + geom_line() +
  geom_hline(aes(yintercept = 0.55)) + ylim(0, NA)  + theme_sleek() +
  xlab("Year") + ylab("SPR") + theme(legend.position = c(.5, .2)) +
  scale_color_manual(values = cbPalette) +
  guides(color = guide_legend(title = ""))
