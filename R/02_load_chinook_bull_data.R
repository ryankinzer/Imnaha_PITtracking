#------------------------------------------------------------------------------
# Exploratory Data Analysis
# Joseph Feldhaus (ODFW) & Ryan Kinzer (NPT)
# Date: 6/11/18     Modified: 6/11/18
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
# Test Code by RK 2019 - includes all Chinook and Bulltrout obs in Snake Basin
chs_url <- 'ftp://ftp.ptagis.org/MicroStrategyExport/rkinzer/PITtrackR_Chinook_Complete_Tag_History.csv'#Chinook file
#chs_url <- 'ftp://ftp.ptagis.org/MicroStrategyExport/feldhauj/2019_Imnaha_CompleteTagHistory.csv'#Chinook file from Joseph's script.
download.file(chs_url, paste0("./data/", basename(chs_url)))
chs_obs_import <- read.csv(paste0("./data/", basename(chs_url)), skip = 0, colClasses="character",
                           fileEncoding = "UTF-16", sep = ",", header = TRUE)

bull_url <- 'ftp://ftp.ptagis.org/MicroStrategyExport/rkinzer/PITtrackR_Bulltrout_Complete_Tag_History.csv'#Bull trout file
download.file(bull_url, paste0("./data/", basename(bull_url)))
bull_obs_import <- read.csv(paste0("./data/", basename(bull_url)), skip = 0, colClasses="character",
                            fileEncoding = "UTF-16", sep = ",", header = TRUE)

# Create Full Dataset ----
chs_bull_obs_raw <- bind_rows(chs_obs_import %>%
                                select(TagID = Tag,
                                     Mark.Species,
                                     Mark.Rear.Type,
                                     #Mark.File,
                                     Release.Site.Code,
                                     Release.Date,
                                     Event.Site.Code.Value = Event.Site.Code,                                     
                                     Event.Date.Time.Value = Event.Date.Time,
                                     Event.Release.Date.Time.Value = Event.Release.Date.Time,
                                     Antenna.ID = Antenna,
                                     Antenna.Group.Configuration.Value = Antenna.Group.Configuration
                                     ),
                              bull_obs_import %>%
                                select(TagID = Tag,
                                           Mark.Species,      
                                           Mark.Rear.Type, 
                                           #Mark.File,
                                           Release.Site.Code, 
                                           Release.Date,
                                           Event.Site.Code.Value = Event.Site.Code,                                          
                                           Event.Date.Time.Value = Event.Date.Time,
                                           Event.Release.Date.Time.Value = Event.Release.Date.Time,
                                           Antenna.ID = Antenna,
                                           Antenna.Group.Configuration.Value = Antenna.Group.Configuration
                                          )
                              ) %>%
                    mutate(Antenna.Group.Configuration.Value = as.numeric(Antenna.Group.Configuration.Value),
                           Origin = ifelse(grepl("Hatchery", Mark.Rear.Type), "Hat",
                                           ifelse(grepl("Wild", Mark.Rear.Type), "Nat", "Unk")),
                           Release.Date = mdy(Release.Date),
                           Event.Site.Code.Value = ifelse(Event.Site.Code.Value == 'LGRLDR', 'GRA', Event.Site.Code.Value))

# Create Covariate Dataset ----
ExtraData <- chs_bull_obs_raw %>%
  select(TagID, Mark.Species, Origin, Release.Site.Code, Release.Date) %>%
  distinct()

# Modify field names ----
# replace the "." with a space for PITcleanR
names(chs_bull_obs_raw) <- gsub("\\.", " ",names(chs_bull_obs_raw))


# Identify Chinook trap/observations dates at GRA
GRA_obs_date <- chs_bull_obs_raw %>%
  filter(`Mark Species` == 'Chinook',
         `Event Site Code Value` %in% c('GRA', 'LGRLDR')) %>%
  group_by(TagID) %>%
  arrange(`Event Date Time Value`) %>%
  slice(1) %>%
  select(TagID, TrapDate = `Event Date Time Value`)

# append Chinook trap/observations dates at GRA to data for Chinook, and
# set bull trout TrapDate to origin release date.
# additional obs. (prior TrapDate) due to Complete Tag History query will be filter out with
# PITcleanR
chs_bull_obs_raw <- chs_bull_obs_raw %>%
  left_join(GRA_obs_date) %>%
  mutate(TrapDate = as.Date(mdy_hms(TrapDate))) %>%
  mutate(TrapDate = if_else(`Mark Species` == "Bull Trout", `Release Date`, TrapDate)) %>%
rename(`Tag Code` = TagID)


# Tag List for PITcleanR ----
chs_bull_tags <- chs_bull_obs_raw %>% 
  distinct(TagID = `Tag Code`, TrapDate)

# Load PITcleanR Configuration ----
load("./data/config_data_20190531.rda")

# assign node names to each observation and truncate


# valid_obs_errors<- assignNodes(valid_tag_df = chs_bull_tags,
#                          observation = chs_bull_obs_raw,
#                          configuration = my_config,
#                          parent_child_df = parent_child,
#                          truncate = F)
# 
# #Look for errors in the assignNodes function where Nodes are "ERROR"
# NodeError<-valid_obs_errors%>%filter(Node=="ERROR")%>%select(TagID,SiteID,AntennaID,ConfigID)%>%distinct()
# write.xlsx2(as.data.frame(NodeError),"./data/NodeError.xlsx",row.names=FALSE)#Export problem records to an excel file

# Assign Node Nodes ----
valid_obs <- assignNodes(valid_tag_df = chs_bull_tags,
                         observation = chs_bull_obs_raw,
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
PITcleanr_chs_bull <- right_join(ExtraData, proc_obs, ExtraData, by="TagID") %>%
  select(-TrapDate, -UserProcStatus,-ValidPath, -ModelObs,-UserComment) %>%
  select(TagID, Mark.Species, Origin, Release.Site.Code,
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
         #Node = fct_relevel(Node, c("COCB0", "COCA0", "IR1", "IR2", "BSCB0", "BSCA0")),
         SiteID = fct_relevel(SiteID, site_vec))

#save(PITcleanr_chs_bull, file = paste0("./data/PITcleanr_",yr,"_chs_bull.rda"))
saveRDS(PITcleanr_chs_bull, file = paste0("./data/PITcleanr_",yr,"_chs_bull.rds"))


##Amazon and Shiny####
source('./R/aws_keys.R')

setKeys()

aws.s3::s3write_using(PITcleanr_chs_bull, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = paste0("PITcleanr_",yr, "_chs_bull"))

aws.s3::s3write_using(bull_obs_import, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = paste0("PITtrackR_Bull_Complete_Tag_History_",yr))

aws.s3::s3write_using(chs_obs_import, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = paste0("PITtrackR_Chinook_Complete_Tag_History_",yr))

# Clean the R-environment
rm(list = ls())
