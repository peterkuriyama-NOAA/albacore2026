#-------------------------------------------------------------------------------
#Albacore header: load packages, set working directory
# options(max.print = 1000, device = 'windows')
options(max.print = 1000)
library(plyr)
library(reshape2)
library(tidyverse)
library(r4ss)
library(devtools)
# library(ggspatial)
library(scales)
library(patchwork)
library(sdmTMB)
# library(emmeans)
world_coordinates <- map_data("world")

minlong <- 0
maxlong <- 360
mm <- map_data("world", wrap = c(minlong, maxlong))


#-------------------------------------------------------------------------------


