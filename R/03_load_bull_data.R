#------------------------------------------------------------------------------
# Load PTAGIS complete tag history queries for Bull Trout observations in the 
# Imnaha River from the "rkinzer" folder on the PTAGIS ftp.server.  The script
# also performs the initial data cleaning and processing steps using
# PITcleanr.
#
# Created by: Ryan N. Kinzer
# Created on: 06/05/2018
#------------------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(PITcleanr)

# load PTAGIS and PITcleanr configuration files
load("data/config_data_20180605.rda")

# load complete tag history from ftp.server
bull_obs_raw<-read.csv('ftp://ftp.ptagis.org/MicroStrategyExport/rkinzer/Imnaha_Bull_Complete_Tag_History.csv', colClasses="character",fileEncoding = "UTF-16LE")

# The PTAGIS results have the word "value", but not the documentation.
# Example: Event Date Time vs Event Date Time Value
bull_obs<-bull_obs_raw %>%
  select(Tag.Code = Tag,
         Event.Date.Time.Value = Event.Date.Time,
         Event.Release.Date.Time.Value =  Event.Release.Date.Time,
         Event.Site.Code.Value = Event.Site.Code,
         Antenna.ID = Antenna,
         Antenna.Group.Configuration.Value = Antenna.Group.Configuration)

#needs to be numeric
bull_obs$Antenna.Group.Configuration.Value<-as.numeric(bull_obs$Antenna.Group.Configuration.Value)

#replace . with a space to be consistent with PITcleanr
names(bull_obs) <- gsub("\\.", " ",names(bull_obs))

# create tag ids and fictitious trap date
bull_tag<-bull_obs %>%
  select(TagID=`Tag Code`) %>%
  distinct() %>%
  mutate(TrapDate = ymd("2018-01-01"))
  


# use PITcleanr to assign nodes to each tag observation and to truncate unneccessary obs
valid_obs <- assignNodes(valid_tag_df = bull_tag,
                         observation = bull_obs,
                         configuration = my_config,
                         parent_child_df = parent_child,
                         truncate = T)

# use PITcleanr to process direction and determine if path is valid 
proc_obs <- writeCapHistOutput(valid_obs,
                               valid_paths,
                               node_order,
                               save_file = FALSE)
  
# This section starts the summarization of the processed observations

imn_nodes <- c('IR1', 'IR2', 'IR3B0', 'IR3A0', 'IR4B0', 'IR4A0', 'IMLB0', 'IMLA0', 'IMNAHW', 'IR5B0', 'IR5A0')
  
# Remove observations in Cow Creek and Big Sheep Creek, order SiteID and nodes for output purposes.
bull_dat <- proc_obs %>%
  filter(grepl('I', SiteID)) %>% # only obs at Imnaha nodes; removes COC and BSC
  mutate(SiteID = factor(SiteID, levels = c('IR1', 'IR2', 'IR3', 'IR4', 'IML', 'IMNAHW', 'IR5')),
         Node = factor(Node, levels = imn_nodes))

# Estimate detection probabilities and the total number of unique tags at
# each Imnaha River node. 

#Assumptions are different for fish passing the weir through the ladder
# and trap, versus fish passing in-stream array/nodes so the two groups
# are estimated with different datasets.
  
tags_df <- bull_dat %>%
  filter(grepl('IR', Node)) %>%
  nodeEfficiency(direction = 'Upstream') %>%
  arrange(NodeOrder) %>%
  mutate(det_eff = Recaps/Marks,
         se_eff = (1/Marks^2)*(Marks*det_eff)*(1-det_eff),
         N_tags = Unique_tags/det_eff,
         se_N = sqrt(((Marks+1)*(Unique_tags+1)*(Marks - Recaps) * (Unique_tags - Recaps))/ ((Recaps+1)^2 * (Recaps+2))),
         lwr_N = N_tags - 1.96*se_N,
         upr_N = N_tags + 1.96*se_N) %>%
  mutate_at(c(6,7,9), round, 3) %>%
  mutate_at(c(8,10,11), round, 0)

# Plot migration movement of fish -- should be moved down

# set plot limits
lims <- ymd_hms(c(min(bull_dat$ObsDate), Sys.time()))

# randomly select tags to look at
    tmp_tag <- bull_dat %>%
      select(TagID) %>%
      sample_n(6) %>% # change number of tags here
      pull()

    bull_dat %>%
      filter(TagID %in% tmp_tag) %>%
      ggplot(aes(x = ObsDate, y = Node, group = TagID)) +
      geom_line() +
      geom_point() +
      geom_vline(xintercept = Sys.time(), linetype = 4) +
      scale_x_datetime(breaks = scales::date_breaks('1 month'), labels = date_format("%d-%b"), limits = lims) +
      facet_wrap(~TagID, scale = 'free_x') +
      theme_bw() +
      theme(legend.position = 'bottom') +
      labs(x = 'Observation Date',
           y = 'Node')
