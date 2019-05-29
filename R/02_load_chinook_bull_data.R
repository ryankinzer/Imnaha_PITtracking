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

# Trap Install Date

install_date <- ymd_hm("2018/06/11 15:00") # we could add time and second if we wanted
bull_cutoff_date <- ymd(paste(year(Sys.Date()),"0301"))

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
#load("./data/config_data_20180605.rda")
# load PITcleanR configuration files run on June 29th
load("./data/config_data_20180629.rda")

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

valid_obs <- assignNodes(valid_tag_df = chs_bull_tags,
                         observation = chs_bull_obs_raw,
                         configuration = my_config,
                         parent_child_df = parent_child,
                         truncate = T)#If trunc = F, the errors generated by assignNodes are hard to spot

#------------------------------------------------------------------------------
# need to test this section once we have IML 09 records
#------------------------------------------------------------------------------
valid_obs <- valid_obs %>%
  mutate(SiteID = ifelse(Node == 'IMNAHWB0', 'IMNAHW', SiteID))
#------------------------------------------------------------------------------

# assign direction and valid observation calls
proc_obs <- writeCapHistOutput(valid_obs,
                               valid_paths,
                               node_order,
                               save_file = TRUE)

# join covariate data with processed capture histories & remove columns
#Keep AutoProcStatus
PITcleanr_2018_chs_bull <- right_join(ExtraData, proc_obs, ExtraData, by="TagID") %>%
  filter(ObsDate >= bull_cutoff_date) %>%
  select(-TrapDate, -UserProcStatus,-ValidPath, -ModelObs,-UserComment) %>%
  select(TagID, Mark.Species, Origin, Release.Site.Code,
         firstObsDateTime = ObsDate, lastObsDateTime = lastObsDate,
         everything()) %>%
  left_join(node_order %>%
              select(Node, RKMTotal), by = 'Node') %>%
  mutate(RiverKM = RKMTotal - 830) %>%
         droplevels()

# need to order factor levels of nodes and sites
node_vec <- PITcleanr_2018_chs_bull %>%
  distinct(Node, NodeOrder) %>%
  arrange(NodeOrder, Node) %>%
  pull(Node)

site_vec <- PITcleanr_2018_chs_bull %>%
  select(SiteID, NodeOrder) %>%
  group_by(SiteID) %>%
  slice(which.min(NodeOrder)) %>%
  arrange(NodeOrder, SiteID) %>%
  pull(SiteID)

PITcleanr_2018_chs_bull <- PITcleanr_2018_chs_bull %>%
  mutate(Node = fct_relevel(Node, node_vec),
         Node = fct_relevel(Node, c("COCB0", "COCA0", "IR1", "IR2", "BSCB0", "BSCA0")),
         SiteID = fct_relevel(SiteID, site_vec))

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

# this should be part of the load file and read-in!!!!!!!!
# We should add a field for TrapStatus - will help for summarization and grouping later
# need another field for passage route - use TagPath for ifelse (if IR5 was it IMNAHW = Handled); (if IR5 was it IML = Ladder Attempt ); if (IR5 was it IR4 = No Ladder Attempt)
# might need to consider fish going downstream

MaxTimes <- PITcleanr_2018_chs_bull %>%
  filter(SiteID %in% c('IR4', 'IML','IMNAHW','IR5')) %>%
  select(TagID, lastObsDateTime, SiteID) %>%
  mutate(SiteID = factor(SiteID,levels=c('IR4', 'IML','IMNAHW','IR5'))) %>%
  group_by(TagID, SiteID) %>%
  slice(which.max(lastObsDateTime)) %>%
  spread(SiteID, lastObsDateTime)%>%rename(IR4_max=IR4,IML_max=IML, IMNAHW_max=IMNAHW, IR5_max=IR5) 

detect_hist <- PITcleanr_2018_chs_bull %>%
  filter(!SiteID %in% c('COC', 'BSC')) %>%
  select(TagID, Mark.Species, Origin, firstObsDateTime, SiteID, Release.Date) %>%
  mutate(SiteID = factor(SiteID,levels=c("IR1","IR2","IR3","IR4","IML","IMNAHW","IR5"))) %>%
  group_by(TagID, SiteID) %>%
  slice(which.min(firstObsDateTime)) %>%
  spread(SiteID, firstObsDateTime) %>%
  left_join(PITcleanr_2018_chs_bull %>%
              mutate(UserProcStatus = AutoProcStatus) %>%
              rename(ObsDate = firstObsDateTime, lastObsDate = lastObsDateTime) %>%
              estimateSpawnLoc(), by = 'TagID') %>%
  left_join(MaxTimes,by='TagID')%>%
  mutate(min_IR1orIR2 = if_else(is.na(IR1), IR2, IR1),
         IR1_IR3 = difftime(IR3, min_IR1orIR2, units = 'days'),
         IR3_IR4 = difftime(IR4, IR3, units = 'days'),
         IR4_IML = difftime(IML, IR4, units = 'days'),
         IML_IMNAHW = difftime(IMNAHW, IML, units = 'days'),
         IR4_IMNAHW = difftime(IMNAHW, IR4, units = 'days'),
         IR4_IR5 = difftime(IR5, IR4, units = 'days')) %>%
  mutate(NewTag = ifelse(Mark.Species == "Bull Trout"&Release.Date>install_date,"True","False"),
         WeirArrivalDate = if_else(!is.na(IR4), IR4, #if IR4 has a date, use IR4,
                                 if_else(!is.na(IML), IML, # use IML,
                                         if_else(!is.na(IMNAHW), IMNAHW, IR5))), # if IMNAHW has a date use IMNAHW otherwise use IR5
         Arrival_Month = month(WeirArrivalDate, label = TRUE, abbr = FALSE),
         TagStatus = ifelse(grepl("(IR4|IML|IMNAHW|IR5)",TagPath) & WeirArrivalDate <= install_date, "Passed: <11 June",
                            ifelse(grepl("IR5", TagPath) & NewTag == "True", "NewTag",
                                   ifelse(grepl("IR5", TagPath) & NewTag == "False", "Passed",
                                          ifelse(grepl("IMNAHW", TagPath), "Trapped",
                                                 ifelse(grepl("IML", TagPath), "Attempted Ladder",
                                                        ifelse(grepl("IR4", TagPath), "At Weir", paste0("Last obs: ", AssignSpawnSite))))))),
         TrapStatus = ifelse(is.na(WeirArrivalDate), "No obs at weir sites",
                             ifelse(WeirArrivalDate <= install_date, "Panels Open", "Panels Closed")),
         PassageRoute = ifelse(!grepl("Passed", TagStatus), NA,
                               ifelse(grepl("IMNAHW", TagPath), "Handled",
                                      ifelse(grepl("IML", TagPath), "IML obs = T", "IML obs = F"))))

detect_hist$TagStatus[detect_hist$IR4_max>detect_hist$IMNAHW&detect_hist$IMNAHW>install_date]<-"Trapped: Obs Below Weir"#tags without a detection at IR5 that fall below the weir
detect_hist$TagStatus[detect_hist$TagStatus=="Trapped: Obs Below Weir"&detect_hist$IR5>detect_hist$IR4_max]<-"Passed"#fell below weir, but made it back to IR5


detect_hist$PassageRoute[detect_hist$IMNAHW>install_date]<-"Handled"#tag paths that end at the trap
detect_hist$PassageRoute[detect_hist$TagID=="3D9.1C2D90A52D"]<-"Handled 6/5/18"#tag paths that end at the trap

#Rearange variable names
detect_hist_out<-detect_hist%>%select(TagID,Mark.Species,Origin,NewTag,TagStatus,TrapStatus,PassageRoute,Release.Date,WeirArrivalDate,everything())

saveRDS(detect_hist_out,"./data/detect_hist.rds")#Save as RDS
write.xlsx2(as.data.frame(detect_hist_out),"./data/detect_hist.xlsx",row.names=FALSE) 
wb2 <- loadWorkbook("./data/detect_hist.xlsx")
sheets2 <- getSheets(wb2)
#autoSizeColumn(sheets2[[1]], colIndex=1:ncol(detect_hist))# autosize column widths
setColumnWidth(sheets2[[1]],colIndex=1:ncol(detect_hist_out),colWidth=18)
saveWorkbook(wb2,"./data/detect_hist.xlsx")

# Compile pdf document.
knitr::knit("2018_chinook_bull_report.Rmd")

##Amazon and Shiny####
source('./R/aws_keys.R')

setKeys()

aws.s3::s3write_using(PITcleanr_2018_chs_bull, FUN = write.csv,
              bucket = "nptfisheries-pittracking",
              object = "PITcleanr_2018_chs_bull")

aws.s3::s3write_using(detect_hist_out, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = "detection_history_2018")

aws.s3::s3write_using(bull_obs_import, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = "Imnaha_Bull_Complete_Tag_History")

aws.s3::s3write_using(chs_obs_import, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = "2018_Imnaha_CompleteTagHistory")



# Clean the R-environment
rm(list = ls())
