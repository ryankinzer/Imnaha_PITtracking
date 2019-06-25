#------------------------------------------------------------------------------
# Exploratory Data Analysis
# Joseph Feldhaus (ODFW) & Ryan Kinzer (NPT)
# Date: 6/11/18     Modified: 6/25/19
#------------------------------------------------------------------------------
# The purpose of this script is to combine Chinook and Bull Trout detections
# within the Imnaha River basin into a single file. The output file is processed
# with functions found in PITcleanr.  Noteably, assignNodes(truncate =T) to
# shorten the file size. The output file is: PITcleanr_2018_chs_bull.rda which
# is also saved as an xlsx file for easier viewing. At the very end of the
# script, some objects are removed from the R environment (e.g., removed
# chs_url, bull_obs_import)
#------------------------------------------------------------------------------

# Load Packages ----
library(tidyverse)
library(lubridate)
library(xlsx)
library(PITcleanr) #devtools::install_github("KevinSee/PITcleanr", build_vignettes = TRUE)

# Set Return Year ----
yr = year(Sys.Date())

# load chinook and bull trout data from PTAGIS ftp servers - code works with R version 3.5
# Added by RK in 2019 - includes all Chinook and Bulltrout obs in Snake Basin
#chs_url <- 'ftp://ftp.ptagis.org/MicroStrategyExport/rkinzer/PITtrackR_Chinook_Complete_Tag_History.csv'#Ryan's Chinook file
chs_url <- 'ftp://ftp.ptagis.org/MicroStrategyExport/feldhauj/2019_Imnaha_CompleteTagHistory.csv'#Chinook file from Joseph's script.
download.file(chs_url, paste0("./data/", basename(chs_url)))
chs_obs_import <- read.csv(paste0("./data/", basename(chs_url)), skip = 0, colClasses="character",
                           fileEncoding = "UTF-16", sep = ",", header = TRUE) #7466 , quote=""


bull_url <- 'ftp://ftp.ptagis.org/MicroStrategyExport/rkinzer/PITtrackR_Bulltrout_Complete_Tag_History.csv'#Bull trout file
download.file(bull_url, paste0("./data/", basename(bull_url)))
bull_obs_import <- read.csv(paste0("./data/", basename(bull_url)), skip = 0, colClasses="character",
                            fileEncoding = "UTF-16", sep = ",", header = TRUE)

names(chs_obs_import)
names(bull_obs_import)

# Create Full Dataset ----
chs_bull_obs_raw <- bind_rows(chs_obs_import %>%
                                select(Tag.Code,
                                     Mark.Species=Mark.Species.Name,
                                     Mark.Rear.Type=Mark.Rear.Type.Name,
                                     Release.Site.Code=Release.Site.Code.Value,
                                     Release.Date=Release.Date.MMDDYYYY,
                                     Event.Site.Code.Value,                                     
                                     Event.Date.Time.Value,
                                     Event.Release.Date.Time=Event.Release.Date.Time.Value,
                                     Antenna.ID,
                                     Antenna.Group.Configuration.Value),
                            bull_obs_import %>%
                                select(Tag.Code = Tag,
                                           Mark.Species,      
                                           Mark.Rear.Type, 
                                           Release.Site.Code, 
                                           Release.Date,
                                           Event.Site.Code.Value=Event.Site.Code,                                          
                                           Event.Date.Time.Value=Event.Date.Time,
                                           Event.Release.Date.Time,
                                           Antenna.ID = Antenna,
                                           Antenna.Group.Configuration.Value = Antenna.Group.Configuration)
                            ) 


chs_bull_obs_raw2<-chs_bull_obs_raw%>%
  mutate(Antenna.Group.Configuration.Value = as.numeric(Antenna.Group.Configuration.Value),
         Release.Date=mdy(Release.Date),
         TrapDate = Release.Date,##PITcleanR requires a trap date for assignNodes.  Assume TrapDate is release date
         #TrapDate=as.Date(mdy_hms(Event.Date.Time)),
        Origin = ifelse(grepl("Hatchery", Mark.Rear.Type), "Hat",
                                           ifelse(grepl("Wild", Mark.Rear.Type), "Nat", "Unk")))



#chs_bull_obs_raw <- chs_bull_obs_raw %>%
 # mutate(TrapDate = as.Date(mdy_hms(TrapDate))) %>%
  #mutate(TrapDate = if_else(Mark.Species == "Bull Trout", Release.Date, TrapDate))

# Create Covariate Dataset ----
ExtraData <- chs_bull_obs_raw2 %>%
  select(Tag.Code, Mark.Species, Origin, Release.Site.Code, Release.Date) %>%
  distinct()

# Tag List for PITcleanR ----
chs_bull_tags <- chs_bull_obs_raw2 %>% 
  distinct(TagID = Tag.Code, TrapDate)
#distinct(TagID = Tag.Code)
# Load PITcleanR Configuration ----
load("./data/config_data_20190531.rda")

# Modify field names ----
# replace the "." with a space for PITcleanR
names(chs_bull_obs_raw2) <- gsub("\\.", " ",names(chs_bull_obs_raw2))

# Assign Node Nodes ----
valid_obs <- assignNodes(valid_tag_df = chs_bull_tags,
                         observation = chs_bull_obs_raw2,
                         configuration = my_config,
                         parent_child_df = parent_child,
                         truncate = T)#If trunc = F, the errors generated by assignNodes are hard to spot

# Correct Site Names ----
#valid_obs <- valid_obs %>%
#  mutate(SiteID = ifelse(Node == 'IMNAHWB0', 'IMNAHW', SiteID))

# Process Observations ----
proc_obs <- writeCapHistOutput(valid_obs,
                               valid_paths,
                               node_order,
                               save_file = TRUE)


# join covariate data with processed capture histories & remove columns
#Keep AutoProcStatus
PITcleanr_chs_bull <- right_join(ExtraData, proc_obs, by=c('Tag.Code' = 'TagID')) %>%
  select(-UserProcStatus,-ValidPath, -ModelObs,-UserComment) %>%
  select(TagID = Tag.Code, Mark.Species, Origin, Release.Site.Code, Release.Date, TrapDate,
         firstObsDateTime = ObsDate, lastObsDateTime = lastObsDate,
         everything()) %>%
  left_join(node_order %>%
              select(Node, RKMTotal), by = 'Node') %>%
         droplevels()

# need to order factor levels of nodes and sites
node_vec <- PITcleanr_chs_bull %>%
  distinct(Node, NodeOrder) %>%
  arrange(NodeOrder, Node) %>%
  pull(Node)

site_vec <- PITcleanr_chs_bull %>%
  select(SiteID, NodeOrder) %>%
  group_by(SiteID) %>%
  slice(which.min(NodeOrder)) %>%
  arrange(NodeOrder, SiteID) %>%
  pull(SiteID)

PITcleanr_chs_bull <- PITcleanr_chs_bull %>%
  mutate(Node = fct_relevel(Node, node_vec),
         SiteID = fct_relevel(SiteID, site_vec))

#save(PITcleanr_chs_bull, file = paste0("./data/PITcleanr_",yr,"_chs_bull.rda"))
saveRDS(PITcleanr_chs_bull, file = paste0("./data/PITcleanr_",yr,"_chs_bull.rds"))


##Amazon and Shiny####
#source('./R/aws_keys.R')

#setKeys()

#aws.s3::s3write_using(PITcleanr_chs_bull, FUN = write.csv,
                     # bucket = "nptfisheries-pittracking",
                     # object = paste0("PITcleanr_",yr, "_chs_bull"))

#aws.s3::s3write_using(bull_obs_import, FUN = write.csv,
                     # bucket = "nptfisheries-pittracking",
                     # object = paste0("PITtrackR_Bull_Complete_Tag_History_",yr))

#aws.s3::s3write_using(chs_obs_import, FUN = write.csv,
                     # bucket = "nptfisheries-pittracking",
                     # object = paste0("PITtrackR_Chinook_Complete_Tag_History_",yr))

# Clean the R-environment
rm(list = ls())
