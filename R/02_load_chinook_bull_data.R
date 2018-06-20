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

# load packages
library(tidyverse)
library(lubridate)
library(xlsx)
library(PITcleanr) #devtools::install_github("KevinSee/PITcleanr", build_vignettes = TRUE)

# load chinook and bull trout data from PTAGIS ftp servers - code works with R version 3.5
chs_url <- 'ftp://ftp.ptagis.org/MicroStrategyExport/feldhauj/2018_Imnaha_CompleteTagHistory.csv'#Chinook file
download.file(chs_url, paste0("./data/", basename(chs_url)))
chs_obs_import <- read.csv(paste0("./data/", basename(chs_url)), skip = 0, colClasses="character",
                           fileEncoding = "UTF-16", sep = ",", header = TRUE)

bull_url <- 'ftp://ftp.ptagis.org/MicroStrategyExport/rkinzer/Imnaha_Bull_Complete_Tag_History.csv'#Bull trout file
download.file(bull_url, paste0("./data/", basename(bull_url)))
bull_obs_import <- read.csv(paste0("./data/", basename(bull_url)), skip = 0, colClasses="character",
                            fileEncoding = "UTF-16", sep = ",", header = TRUE)

# Create full dataset
chs_bull_obs_raw <- bind_rows(chs_obs_import %>%
                                select(Tag.Code,
                                     Mark.Species = Mark.Species.Name,
                                     Mark.Rear.Type = Mark.Rear.Type.Name,
                                     Mark.File = Mark.File.Name,
                                     Release.Site.Code = Release.Site.Code.Value,
                                     Release.Date = Release.Date.MMDDYYYY,
                                     Event.Site.Code.Value,                                     
                                     Event.Date.Time.Value,
                                     Antenna.ID,
                                     Antenna.Group.Configuration.Value
                                     ),
                              bull_obs_import %>%
                                select(Tag.Code = Tag,
                                           Mark.Species,      
                                           Mark.Rear.Type, 
                                           Mark.File,
                                           Release.Site.Code, 
                                           Release.Date,
                                           Event.Site.Code.Value=Event.Site.Code,                                          
                                           Event.Date.Time.Value=Event.Date.Time, 
                                           Antenna.ID=Antenna,
                                           Antenna.Group.Configuration.Value=Antenna.Group.Configuration
                                          )
                              ) %>%
                    mutate(Antenna.Group.Configuration.Value = as.numeric(Antenna.Group.Configuration.Value),
                           Origin = ifelse(grepl("Hatchery", Mark.Rear.Type), "Hat",
                                           ifelse(grepl("Wild", Mark.Rear.Type), "Nat", "Unk")),
                           Release.Date = mdy(Release.Date))

# create dataset of lost covariates
ExtraData <- chs_bull_obs_raw %>%
  select(TagID = Tag.Code, Mark.Species, Origin, Release.Site.Code, Release.Date) %>%
  distinct()

# modify field names by replacing the "." with a space for PITcleanR
names(chs_bull_obs_raw) <- gsub("\\.", " ",names(chs_bull_obs_raw))

# subset distinct list of tag codes and name appropriately for PITcleanR
chs_bull_tags <- chs_bull_obs_raw %>% 
  distinct(`Tag Code`) %>%
  mutate(TagID = `Tag Code`,TrapDate=as.Date("2018-01-01"))

# load PITcleanR configuration files run on June 5th
load("./data/config_data_20180605.rda")

# assign node names to each observation and truncate
valid_obs <- assignNodes(valid_tag_df = chs_bull_tags,
                         observation = chs_bull_obs_raw,
                         configuration = my_config,
                         parent_child_df = parent_child,
                         truncate = T)

# assign direction and valid observation calls
proc_obs <- writeCapHistOutput(valid_obs,
                               valid_paths,
                               node_order,
                               save_file = FALSE)

# join covariate data with processed capture histories & remove columns
#Keep AutoProcStatus
PITcleanr_2018_chs_bull <- right_join(ExtraData, proc_obs, ExtraData, by="TagID") %>%
  select(-TrapDate, -UserProcStatus, -ModelObs,-UserComment) %>%
  select(TagID, Mark.Species, Origin, Release.Site.Code,
         firstObsDateTime = ObsDate, lastObsDateTime = lastObsDate,
         everything()) %>%
         droplevels()

saveRDS(PITcleanr_2018_chs_bull,"./data/PITcleanr_2018_chs_bull.rds")

#Write xlsx file and auto fit the column widths
#https://stackoverflow.com/questions/27322110/define-excels-column-width-with-r
PITcleanr_2018_chs_bull2<-PITcleanr_2018_chs_bull%>%select(-AutoProcStatus)
write.xlsx2(as.data.frame(PITcleanr_2018_chs_bull2),"./data/PITcleanr_2018_chs_bull.xlsx",row.names=FALSE)
wb <- loadWorkbook("./data/PITcleanr_2018_chs_bull.xlsx")
sheets <- getSheets(wb)
# autosize column widths
autoSizeColumn(sheets[[1]], colIndex=1:ncol(PITcleanr_2018_chs_bull))#reference number of columns in original excel file
saveWorkbook(wb,"./data/PITcleanr_2018_chs_bull.xlsx")


####Create the detection history##########
##This step seems to want the AutoProcStatus from the Original PITcleanr file
detect_hist <- PITcleanr_2018_chs_bull %>%
  filter(!SiteID %in% c('COC', 'BSC')) %>%
  select(TagID, Mark.Species, Origin, lastObsDateTime, SiteID) %>%
  mutate(SiteID = factor(SiteID,levels=c("IR1","IR2","IR3","IR4","IML","IR5"))) %>%
  group_by(TagID, SiteID) %>%
  slice(which.min(lastObsDateTime)) %>%
  spread(SiteID, lastObsDateTime) %>%
  left_join(PITcleanr_2018_chs_bull %>%
              mutate(UserProcStatus = AutoProcStatus) %>%
              rename(ObsDate = firstObsDateTime, lastObsDate = lastObsDateTime) %>%
              estimateSpawnLoc(), by = 'TagID') %>%
  mutate(TagStatus = ifelse(AssignSpawnSite=="IR4" & LastObs <= ymd(20180611), "Assumed Passed Weir prior to 6/11/18",
                            ifelse(grepl("IR5", TagPath), "Successfully Passed",
                                   ifelse(grepl("IMNAHW", TagPath) & grepl("IR4", TagPath), "Successfully Trapped",
                                          ifelse(grepl("IML", TagPath) & grepl("IR4", TagPath), "Attempting Ladder",
                                                 ifelse(grepl("IR4", TagPath), "At Weir",paste0("Last Seen at ",AssignSpawnSite))))))) 

saveRDS(detect_hist,"./data/detect_hist.rds")#Save as RDS

write.xlsx2(as.data.frame(detect_hist),"./data/detect_hist.xlsx",row.names=FALSE) 
wb2 <- loadWorkbook("./data/detect_hist.xlsx")
sheets2 <- getSheets(wb2)
autoSizeColumn(sheets2[[1]], colIndex=1:ncol(detect_hist))# autosize column widths
saveWorkbook(wb2,"./data/detect_hist.xlsx")
saveRDS(detect_hist,"./data/detect_hist.rds")


##Amazon and Shiny####
source('./R/aws_keys.R')

setKeys()

aws.s3::s3write_using(PITcleanr_2018_chs_bull, FUN = write.csv,
              bucket = "nptfisheries-pittracking",
              object = "PITcleanr_2018_chs_bull")

aws.s3::s3write_using(bull_obs_import, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = "Imnaha_Bull_Complete_Tag_History")

aws.s3::s3write_using(chs_obs_import, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = "2018_Imnaha_CompleteTagHistory")

# Clean the R-environment
rm(list = ls())
