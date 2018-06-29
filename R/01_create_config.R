#------------------------------------------------------------------------------
# Create the necessary configuration files (R objects) for PITcleanr to process
# the complete tag history queries.  The configuration files do not need to be
# created each time the .Rmd file is complied.  This script collects the 
# configuration information and saves the objects as a .Rda file for later use.
#
# Created by: Ryan N. Kinzer
# Created on: 06/05/2018
#------------------------------------------------------------------------------

# Load packages
library(lubridate)
library(PITcleanr)

run_date <- Sys.Date()

# collect PTAGIS interrogation (INT) and mark, release, recapture (MRR) site
# metadata and assign each antenna to a specific node based on the antenna
# group configuration in

my_config <- buildConfig()

my_config <- my_config %>%
  # need to change SiteID - IML 09 to IMNAHW and IMWB0
  # need to change Node = IMNAHW to IMWA0
  mutate(Node = ifelse(SiteID == 'IMNAHW', 'IMNAHWA0', Node),
         Node = ifelse(SiteID == 'IML' & AntennaID == '09', 'IMNAHWB0', Node))
 
# hard coded network of sites upstream of LGR
site_df = writeLGRNodeNetwork()

# maps the order of nodes upstream of LGR
parent_child <- createParentChildDf(site_df,
                       my_config,
                       startDate = paste0(year(run_date),'0301'))
 
# creates all valid detection paths upstream of LGR
valid_paths <- getValidPaths(parent_child)
 
node_order = createNodeOrder(valid_paths,
                              configuration = my_config,
                              site_df,
                              step_num = 3)

filename <- paste0("./data/config_data_",gsub("-","",run_date),".rda")

save(my_config, site_df, parent_child, valid_paths, node_order, file = filename)
