#------------------------------------------------------------------------------
# Load PTAGIS complete tag history queries for Chinook observations in the 
# Imnaha River from the "feldhauj" folder on the PTAGIS ftp.server.  The script
# also performs the initial data cleaning and processing steps using
# PITcleanr.
#
# Created by: Joseph Feldhaus
# Created on: 06/05/2018
#------------------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(PITcleanr)

# load PTAGIS and PITcleanr configuration files
load("data/config_data_20180605.rda")

# load complete tag history from ftp.server
chs_obs_raw<-read.csv('ftp://ftp.ptagis.org/MicroStrategyExport/feldhauj/2018_Imnaha_CompleteTagHistory.csv', colClasses="character",fileEncoding = "UTF-16LE")

# The PTAGIS results have the word "value", but not the documentation.
# Example: Event Date Time vs Event Date Time Value
chs_obs<-chs_obs_raw %>%
  select(Tag.Code,
         Event.Date.Time.Value,
         Event.Release.Date.Time.Value,
         Event.Site.Code.Value,
         Antenna.ID,
         Antenna.Group.Configuration.Value,
         CTH.Count)

#needs to be numeric
chs_obs$Antenna.Group.Configuration.Value<-as.numeric(chs_obs$Antenna.Group.Configuration.Value)

#replace . with a space to be consistent with PITcleanr
names(chs_obs) <- gsub("\\.", " ",names(chs_obs))

#write.csv(chs_obs,"//fweou/home/feldhaj/My Documents/MyRStuff/ImnahaPITs/Data/Chnk2018_test.csv")
#trap_path <- '//fweou/home/feldhaj/My Documents/MyRStuff/ImnahaPITs/Data/Chnk2018_test.csv'

chs_tag<-chs_obs %>%
  select(TagID=`Tag Code`) %>%
  distinct() %>%
  mutate(TrapDate = ymd("2018-01-01"))

valid_obs <- assignNodes(valid_tag_df = chs_tag,
                         observation = chs_obs,
                         configuration = my_config,
                         parent_child_df = parent_child,
                         truncate = T)

proc_obs <- writeCapHistOutput(valid_obs,
                               valid_paths,
                               node_order,
                               save_file = FALSE)
