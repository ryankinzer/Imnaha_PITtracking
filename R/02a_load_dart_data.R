# Script Metadata--------------------------------------------------------------

# Load PIT-tag observation data from DART
# Ryan N. Kinzer
# Date: 6/12/18

# Description:
# The purpose of this script is to combine Chinook and Bull Trout detections
# within the Imnaha River basin into a single file. The output file is processed
# with functions found in PITcleanr.  Noteably, assignNodes(truncate =T) to
# shorten the file size. The output file is: PITcleanr_2018_chs_bull.rda which
# is also saved as an xlsx file for easier viewing. At the very end of the
# script, some objects are removed from the R environment (e.g., removed
# chs_url, bull_obs_import)

# Load Packages----------------------------------------------------------------
library(tidyverse)
library(lubridate)
#library(xlsx)
library(PITcleanr) #devtools::install_github("KevinSee/PITcleanr", build_vignettes = TRUE)

# Load PITcleanR Configuration ----
#load("./data/config_data_20200612.rda")

my_config <- buildConfig()

my_config <- my_config %>%
  # need to change SiteID - IML 09 to IMNAHW and IMWB0
  # need to change Node = IMNAHW to IMWA0
  mutate(Node = ifelse(SiteID == 'IMNAHW', 'IMNAHWA0', Node),
         Node = ifelse(SiteID == 'IML' & AntennaID == '09', 'IMNAHWB0', Node))

# Set Parameters---------------------------------------------------------------
#yr = year(Sys.Date())
spp <- 'Coho' # Chinook = 1, Coho = 2, Steelhead = 3, Sockeye = 4
yr <- 2018

dart_obs <- processDART_LGR(species = spp,
                           spawnYear = yr,
                           configuration = my_config,
                           truncate = T)

proc_ch <- dart_obs$proc_ch
raw_dat <- dart_obs$dart_obs

mark_dat <- raw_dat %>%
  select(tag_id, mark_date, file_id, mark_site, rel_site, rel_date, t_rear_type, t_species, t_run, length, trans_status, trans_proj, trans_year) %>%
  distinct()

tmp <- proc_ch %>% 
  left_join(mark_dat, by = c('TagID' = 'tag_id')) %>%
  ungroup()

# process all spp and years with map

get_dartObs <- function(species, spawnYear, configuration){
  
  dart_obs <- processDART_LGR(species = species,
                              spawnYear = spawnYear,
                              configuration = configuration,
                              truncate = T)
  
  proc_ch <- dart_obs$proc_ch
  raw_dat <- dart_obs$dart_obs
  
  mark_dat <- raw_dat %>%
    select(tag_id, mark_date, file_id, mark_site, rel_site, rel_date,
           t_rear_type, t_species, t_run, length, trans_status,
           trans_proj, trans_year) %>%
    distinct()
  
  dat <- proc_ch %>% 
    left_join(mark_dat, by = c('TagID' = 'tag_id')) %>%
    ungroup() %>%
    mutate(trans_status = as.character(trans_status),
           UserProcStatus = as.character(UserProcStatus),
           ModelObs = as.character(ModelObs),
           ValidPath = as.character(ValidPath),
           species = species,
           spawn_yr = spawnYear) %>%
    select(species, spawn_yr, everything())
  
  return(dat)
}  

tmp <- get_dartObs(species = spp, spawnYear = yr, configuration = my_config)

spp <- c('Chinook', 'Coho', 'Steelhead', 'Sockeye')
yr <- c(2010:2019)

tmp <- expand.grid(species = spp, spawnYear = yr, stringsAsFactors = F)

species <- as.list(tmp$species)
spawnYear <- as.list(tmp$spawnYear)

all_dart_obs <- map2_dfr(species, spawnYear,
                     ~get_dartObs(.x, .y, configuration = my_config))
                
  
dat_10_17 <- all_dart_obs
save(dat_10_17, file = './data/dat_10_17.rda')

load('./data/all_dart_obs.rda')

dat_18_19 <- all_dart_obs
save(dat_18_19, file = './data/dat_18_19.rda')

all_dart_obs <- bind_rows(dat_10_17, all_dart_obs)

save(all_dart_obs, file = './data/all_dart_obs.rda')


