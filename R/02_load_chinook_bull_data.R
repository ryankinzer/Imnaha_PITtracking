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

# join covariate data with processed capture histories
PITcleanr_2018_chs_bull <- right_join(ExtraData, proc_obs, ExtraData, by="TagID") %>%
  select(-TrapDate) %>%
  select(TagID, Mark.Species, Origin, Release.Site.Code,
         firstObsDateTime = ObsDate, lastObsDateTime = lastObsDate,
         everything()) %>%
  droplevels()

saveRDS(PITcleanr_2018_chs_bull,"./data/PITcleanr_2018_chs_bull.rds")

#Write xlsx file and auto fit the column widths
write.xlsx2(as.data.frame(PITcleanr_2018_chs_bull),"./data/PITcleanr_2018_chs_bull.xlsx",row.names=FALSE)
wb <- loadWorkbook("./data/PITcleanr_2018_chs_bull.xlsx")
sheets <- getSheets(wb)
# autosize column widths
autoSizeColumn(sheets[[1]], colIndex=1:ncol(df))
saveWorkbook(wb,"./data/PITcleanr_2018_chs_bull.xlsx")


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
