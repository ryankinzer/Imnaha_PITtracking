#------------------------------------------------------------------------------
# Exploratory Data Analysis
# Joseph Feldhaus (ODFW) & Ryan Kinzer (NPT)
# Date: 6/11/18     Modified: 5/30/19
#------------------------------------------------------------------------------
# The purpose of this script is to process Imnaha only detections for more
# precise weir management and tracking of fish in the system.  THe script
# requires the PITcleanR processed capture history file output by the "02..."
# R script.
#------------------------------------------------------------------------------

# load packages
library(tidyverse)
library(lubridate)
library(PITcleanr)
library(xlsx)

# Set Return Year ----
yr = year(Sys.Date())

# Load PITcleanR Data ----
PITcleanr_chs_bull<-readRDS(paste0("./data/PITcleanr_",yr,"_chs_bull.rds"))#I prefer RDS because we can explicity name the file
#load(paste0("./data/PITcleanr_",yr,"_chs_bull.rda"))

# filter for Imanaha River only
PITcleanr_chs_bull <- PITcleanr_chs_bull %>%
  filter(Group == 'ImnahaRiver',
         firstObsDateTime>=ymd_hm(paste0(yr,"/04/01 00:00")))#the configuration file from the 02_script contains node_order where "Group" is defined


# Trap Install Date ----
trap_install <- TRUE # TRUE OR FALSE

#if(trap_install){
  install_date <- ymd_hm(paste0(yr,"/06/21 15:00")) # we could add time and second if we wanted
#}

#Write xlsx file and auto fit the column widths
#https://stackoverflow.com/questions/27322110/define-excels-column-width-with-r
PITcleanr_chs_bull2<-PITcleanr_chs_bull%>%select(-AutoProcStatus)

write.xlsx2(as.data.frame(PITcleanr_chs_bull2),paste0("./data/PITcleanr_",yr,"_chs_bull.xlsx"),row.names=FALSE)
wb <- loadWorkbook(paste0("./data/PITcleanr_",yr,"_chs_bull.xlsx"))
sheets <- getSheets(wb)
# autosize column widths
autoSizeColumn(sheets[[1]], colIndex=1:ncol(PITcleanr_chs_bull))#reference number of columns in original excel file
saveWorkbook(wb,paste0("./data/PITcleanr_",yr,"_chs_bull.xlsx"))


####Create the detection history##########
##This step seems to want the AutoProcStatus from the Original PITcleanr file

# this should be part of the load file and read-in!!!!!!!!
# We should add a field for TrapStatus - will help for summarization and grouping later
# need another field for passage route - use TagPath for ifelse (if IR5 was it IMNAHW = Handled); (if IR5 was it IML = Ladder Attempt ); if (IR5 was it IR4 = No Ladder Attempt)
# might need to consider fish going downstream

MaxTimes <- PITcleanr_chs_bull %>%
  filter(SiteID %in% c('IR4', 'IML','IMNAHW','IR5')) %>%
  select(TagID, lastObsDateTime, SiteID) %>%
  mutate(SiteID = factor(SiteID,levels=c('IR4', 'IML','IMNAHW','IR5'))) %>%
  group_by(TagID, SiteID) %>%
  slice(which.max(lastObsDateTime)) %>%
  spread(SiteID, lastObsDateTime, drop = FALSE) %>% 
  rename(IR4_max=IR4,IML_max=IML, IMNAHW_max=IMNAHW, IR5_max=IR5) 


# need to use drop = FALSE in spread with all factor levels
detect_hist_simple <- PITcleanr_chs_bull %>%
  filter(!SiteID %in% c('COC', 'BSC')) %>%
  select(TagID, firstObsDateTime, SiteID) %>% # removed Mark.Species, Origin, ReleaseDate
  mutate(SiteID = factor(SiteID,levels=c("IR1","IR2","IR3","IR4","IML","IMNAHW","IR5"))) %>%
  group_by(TagID, SiteID) %>%
  slice(which.min(firstObsDateTime)) %>%
  spread(SiteID, firstObsDateTime, drop = FALSE) %>%
  left_join(PITcleanr_chs_bull %>%
              select(TagID, Mark.Species, Origin, Release.Site.Code, Release.Date) %>%
              distinct(),
            by = 'TagID') %>%
  left_join(PITcleanr_chs_bull %>%
              mutate(UserProcStatus = AutoProcStatus) %>%
              rename(ObsDate = firstObsDateTime, lastObsDate = lastObsDateTime) %>%
              estimateSpawnLoc(),
            by = 'TagID') %>%
  left_join(MaxTimes,by='TagID') %>%
  select(Mark.Species, Origin, Release.Site.Code, Release.Date, everything())%>%
  arrange(Mark.Species,Origin,TagID)

write.xlsx2(as.data.frame(detect_hist_simple),paste0("./data/",yr,"_detect_hist_simple.xlsx"),row.names=FALSE) 

###I separated the mutate statements to calculate travel days because they don't work well with missing dates##
###We need detections at an interrogation site before the calculations work###

detect_hist <- detect_hist_simple%>%
  mutate(min_IR1orIR2 = if_else(is.na(IR1), IR2, IR1),
         IR1_IR3 = difftime(IR3, min_IR1orIR2, units = 'days'),
         IR3_IR4 = difftime(IR4, IR3, units = 'days'),
         IR4_IML = difftime(IML, IR4, units = 'days'),
         IML_IMNAHW = difftime(IMNAHW, IML, units = 'days'),
         IR4_IMNAHW = difftime(IMNAHW, IR4, units = 'days'),
         IR4_IR5 = difftime(IR5, IR4, units = 'days')) %>%
  mutate(NewTag = case_when(
                    Mark.Species == "Bull Trout" & trap_install & Release.Date > install_date ~ "TRUE",
                    TRUE ~ "FALSE"),
         WeirArrivalDate = if_else(!is.na(IR4), IR4, #if IR4 has a date, use IR4,
                                   if_else(!is.na(IML), IML, # use IML,
                                           if_else(!is.na(IMNAHW), IMNAHW, IR5))), # if IMNAHW has a date use IMNAHW otherwise use IR5
         Arrival_Month = month(WeirArrivalDate, label = TRUE, abbr = FALSE),
         TagStatus = ifelse(grepl("(IR4|IML|IMNAHW|IR5)",TagPath) & WeirArrivalDate <= install_date, paste0("Passed: <",format(install_date, "%d-%B")),
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
#detect_hist$PassageRoute[detect_hist$TagID=="3D9.1C2D90A52D"]<-"Handled 6/5/18"#tag paths that end at the trap

#Rearange variable names
detect_hist_out<-detect_hist%>%select(TagID,Mark.Species,Origin,NewTag,TagStatus,TrapStatus,PassageRoute,Release.Date,WeirArrivalDate,everything())

saveRDS(detect_hist_out, file = paste0("./data/",yr,"_detect_hist.rds"))
#save(detect_hist_out, file = paste0("./data/",yr,"_detect_hist.rda")) #Save as rda
write.xlsx2(as.data.frame(detect_hist_out), paste0("./data/",yr, "_detect_hist.xlsx"),row.names=FALSE) 
wb2 <- loadWorkbook(paste0("./data/",yr, "_detect_hist.xlsx"))
sheets2 <- getSheets(wb2)
#autoSizeColumn(sheets2[[1]], colIndex=1:ncol(detect_hist))# autosize column widths
setColumnWidth(sheets2[[1]],colIndex=1:ncol(detect_hist_out),colWidth=18)
saveWorkbook(wb2,paste0("./data/",yr, "_detect_hist.xlsx"))

# Compile pdf document.
knitr::knit("2019_chinook_bull_report.Rmd")

##Amazon and Shiny####
source('./R/aws_keys.R')

setKeys()

aws.s3::s3write_using(detect_hist_out, FUN = write.csv,
                      bucket = "nptfisheries-pittracking",
                      object = paste0("detection_history_",yr))


# Clean the R-environment
rm(list = ls())
