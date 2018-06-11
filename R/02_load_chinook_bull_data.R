#------------------------------------------------------------------------------
# Exploratory Data Analysis
# Joseph Feldhaus (ODFW) & Ryan Kinzer (NPT)
# Date: 6/11/18     Modified: 6/11/18
#------------------------------------------------------------------------------
# The purpose of this script is to combine Chinook and Bull Trout detections within the Imnaha River basin into a single file.
# The output file is processed with functions found in PITcleanr.  Noteably, assignNodes(truncate =T) to shorten the file size.
# The output file is: PITcleanr_2018_chs_bull.rda which is also saved as an xlsx file for easier viewing.
# At the very end of the script, some objects are removed from the R environment (e.g., removed chs_url, bull_obs_import)
#------------------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(xlsx)
library(PITcleanr)#devtools::install_github("KevinSee/PITcleanr", build_vignettes = TRUE)

##works with R version 3.4.2 but chokes with version 3.5
#chs_obs_import<-read.csv('ftp://ftp.ptagis.org/MicroStrategyExport/feldhauj/2018_Imnaha_CompleteTagHistory.csv', colClasses="character",fileEncoding = "UTF-16LE")
#bull_obs_raw <- read.csv('ftp://ftp.ptagis.org/MicroStrategyExport/rkinzer/Imnaha_Bull_Complete_Tag_History.csv', colClasses="character",fileEncoding = "UTF-16LE")
##https://stackoverflow.com/questions/50070113/r-3-5-read-csv-not-able-to-read-utf-16-csv-file?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa


#########Fixing read.csv code to work with R version 3.5
chs_url<-'ftp://ftp.ptagis.org/MicroStrategyExport/feldhauj/2018_Imnaha_CompleteTagHistory.csv'#Chinook file
download.file(chs_url, basename(chs_url))
chs_obs_import<-read.csv(basename(chs_url), skip = 0, colClasses="character",fileEncoding = "UTF-16", sep = ",", header = TRUE)

bull_url<-'ftp://ftp.ptagis.org/MicroStrategyExport/rkinzer/Imnaha_Bull_Complete_Tag_History.csv'#Bull trout file
download.file(bull_url, basename(bull_url))
bull_obs_import<-read.csv(basename(bull_url), skip = 0, colClasses="character",fileEncoding = "UTF-16", sep = ",", header = TRUE)


###Select the 7 key fields + a couple extra co-variates (mark site, mark file, mark species)
chs_obs_raw<-chs_obs_import%>%select(Tag.Code,
                                     Mark.Rear.Type.Name,
                                     Release.Site.Code=Release.Site.Code.Value,
                                     Event.Date.Time.Value,
                                     Event.Site.Code.Value,
                                     Antenna.ID,
                                     Antenna.Group.Configuration.Value,
                                     CTH.Count, 
                                     Mark.File=Mark.File.Name,
                                     Mark.Rear.Type=Mark.Rear.Type.Name,
                                     Mark.Species=Mark.Species.Name)

bull_obs_raw<-bull_obs_import%>%select(Tag.Code=Tag,
                                     Mark.Rear.Type, 
                                     Release.Site.Code, 
                                     Event.Date.Time.Value=Event.Date.Time, 
                                     Event.Site.Code.Value=Event.Site.Code,
                                     Antenna.ID=Antenna,
                                     CTH.Count,
                                     Antenna.Group.Configuration.Value=Antenna.Group.Configuration,
                                     Mark.File,
                                     Mark.Rear.Type,
                                     Mark.Species)

#combine the Chinook and bull trout data into a single file
chs_bull_obs_raw<-rbind(chs_obs_raw,bull_obs_raw)
chs_bull_obs_raw$Antenna.Group.Configuration.Value<-as.numeric(chs_bull_obs_raw$Antenna.Group.Configuration.Value)#needs to be numeric

###The functions seem to ignore/silently drop extra fields.  Append/Merge these extra fields at the end.
ExtraData<-chs_bull_obs_raw%>%select(TagID=Tag.Code, Mark.Species, Mark.Rear.Type,Release.Site.Code)%>%distinct()
ExtraData$Origin<-"Unk"
ExtraData$Origin[str_detect(ExtraData$Mark.Rear.Type,"Hatchery")]<-"Hat"
ExtraData$Origin[str_detect(ExtraData$Mark.Rear.Type,"Wild")]<-"Nat"

#####modify field names by replacing the "." with a space
names(chs_bull_obs_raw) <- gsub("\\.", " ",names(chs_bull_obs_raw))#replace . with a space to be consistent with PITcleanr
chs_bull_tags<-chs_bull_obs_raw%>%select(TagID=`Tag Code`)%>%distinct()%>%mutate(Tag=TagID,TrapDate=as.Date("2018-01-01"))

####These 3 steps do not require the PIT Tag observation data, but are necessary to continue the script
#load("C:/Rprojects/Imnaha_PITtracking/data/config_data_20180605.rda")
my_config<-buildConfig()#Compile metadata from all MRR and interogation sites from PTAGIS
site_df<-writeLGRNodeNetwork()#
parent_child <- createParentChildDf(site_df, my_config, startDate = 20180101)

valid_obs <- assignNodes(valid_tag_df = chs_bull_tags,
                         observation = chs_bull_obs_raw,
                         configuration = my_config,
                         parent_child_df = parent_child,
                         truncate = T)

valid_paths<-getValidPaths(parent_child_df=parent_child,root_site=NULL)
node_order<-createNodeOrder(valid_paths = valid_paths, configuration =my_config, site_df = site_df, step_num = 3)

proc_obs <- writeCapHistOutput(valid_obs,
                               valid_paths,
                               node_order,
                               save_file = FALSE)

PITcleanr_2018_chs_bull<-full_join(proc_obs,ExtraData,by="TagID")%>%select(-TrapDate)%>%
  select(TagID,Mark.Species,Origin,Mark.Rear.Type,Release.Site.Code,firstObsDateTime=ObsDate,lastObsDateTime=lastObsDate,everything())%>%droplevels()

write.xlsx2(as.data.frame(PITcleanr_2018_chs_bull),"./data/PITcleanr_2018_chs_bull.xlsx",row.names=FALSE) 
saveRDS(PITcleanr_2018_chs_bull,"./data/PITcleanr_2018_chs_bull.rds")

###Clean the R-environment###
###When the script is sourced, the following objects show up and clutter the workflow. These are remove with rm()

rm(bull_url,
   chs_url,
   bull_obs_import,
   bull_obs_raw,
   chs_bull_obs_raw,
   chs_bull_tags,
   chs_obs_import,
   chs_obs_raw,
   ExtraData,
   valid_obs,
   proc_obs)
