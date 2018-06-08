library(tidyverse)
library(dplyr)
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
bull_obs_raw<-read.csv(basename(bull_url), skip = 0, colClasses="character",fileEncoding = "UTF-16", sep = ",", header = TRUE)


######

###Select the 7 key fields + a couple extra co-variates (mark site, mark file, mark species)
chs_obs_raw<-chs_obs_import%>%select(Tag.Code,
                                     Mark.Rear.Type.Name,
                                     Release.Site.Code.Value,
                                     Event.Date.Time.Value,
                                     Event.Site.Code.Value,
                                     Antenna.ID,
                                     Antenna.Group.Configuration.Value,
                                     CTH.Count, Mark.File.Name, Mark.Species.Name)
names(chs_obs_raw)

names(bull_obs_raw)

bull_obs_raw2<-bull_obs_raw%>%rename(Tag.Code=Tag, 
                                     Antenna.ID=Antenna,
                                     Event.Date.Time.Value=Event.Date.Time,
                                     Antenna.Group.Configuration.Value=Antenna.Group.Configuration,
                                     Event.Site.Code.Value=Event.Site.Code)%>%
  mutate(Release.Site.Code.Value="TBD",Mark.File.Name="TBD",Mark.Rear.Type.Name="Wild",Mark.Species.Name="Bull Trout")
names(bull_obs_raw2)

###select column names in a consistent order
bull_obs_raw3<-bull_obs_raw2%>%select(Tag.Code,
                                      Mark.Rear.Type.Name,
                                      Release.Site.Code.Value,
                                      Event.Date.Time.Value,
                                      Event.Site.Code.Value,
                                      Antenna.ID,
                                      Antenna.Group.Configuration.Value,
                                      CTH.Count, Mark.File.Name, Mark.Species.Name)


#The PTAGIS results have the word "value", but not the documentation.  Example: Event Date Time vs Event Date Time Value
chs_bull_obs_raw<-rbind(chs_obs_raw,bull_obs_raw3)##Create the combined file
chs_bull_obs_raw$Antenna.Group.Configuration.Value<-as.numeric(chs_bull_obs_raw$Antenna.Group.Configuration.Value)#needs to be numeric

###The functions seem to ignore/silently drop extra fields.  Append these at the end.
ExtraData<-chs_bull_obs_raw%>%select(TagID=Tag.Code, Mark.Species.Name, Mark.Rear.Type.Name,Release.Site.Code.Value)%>%distinct()
ExtraData$Origin<-"Unk"
ExtraData$Origin[str_detect(ExtraData$Mark.Rear.Type.Name,"Hatchery")]<-"Hat"
ExtraData$Origin[str_detect(ExtraData$Mark.Rear.Type.Name,"Wild")]<-"Nat"

####These 3 steps do not require the PIT Tag observation data
org_config<-buildConfig()#Compile metadata from all MRR and interogation sites from PTAGIS
site_df<-writeLGRNodeNetwork()#
parent_child <- createParentChildDf(site_df, org_config, startDate = 20180101)

#####modify field names by replacing the "." with a space
names(chs_bull_obs_raw) <- gsub("\\.", " ",names(chs_bull_obs_raw))#replace . with a space to be consistent with PITcleanr

chs_bull_tags<-chs_bull_obs_raw%>%select(TagID=`Tag Code`)%>%distinct()%>%mutate(Tag=TagID,TrapDate=as.Date("2018-01-01"))

valid_obs <- assignNodes(valid_tag_df = chs_bull_tags,
                         observation = chs_bull_obs_raw,
                         configuration = org_config,
                         parent_child_df = parent_child,
                         truncate = T)

valid_paths2<-getValidPaths(parent_child_df=parent_child,root_site=NULL)
node_order<-createNodeOrder(valid_paths = valid_paths2, configuration =org_config, site_df = site_df,
                            step_num = 3)

proc_obs <- writeCapHistOutput(valid_obs,
                               valid_paths2,
                               node_order,
                               save_file = FALSE)

final_df<-full_join(proc_obs,ExtraData,by="TagID")%>%
  select(TagID,Mark.Species.Name,Origin,Release.Site.Code.Value,everything())%>%droplevels()


write.xlsx2(as.data.frame(final_df),"//fweou/home/feldhaj/My Documents/MyRStuff/ImnahaPITs/Data/temp_2018_chs_bull_df.xlsx",row.names=FALSE) 
saveRDS(final_df,"//fweou/home/feldhaj/My Documents/MyRStuff/ImnahaPITs/Data/testData.rds")

