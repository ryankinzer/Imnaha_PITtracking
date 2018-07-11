---
title: "2018 Imnaha River Chinook Salmon and Bull Trout summaries"
author: "Joseph Feldhaus (ODFW) & Ryan Kinzer (NPT)"
date: "July 11, 2018"
output: pdf_document
editor_options: 
  chunk_output_type: console
---
### Noteable Highlights/Data issues

* Bull trout detections in the Imnaha River were limited to detections after 1 March 2018.   

* Chinook PIT tag detections are between 5/1/2018 and 10/1/2018.    

* Imnaha Weir installation date: **11 June, 2018**.
    + A staff injury on June 11th precluded the ladder from being watered to allow fish passage.
    + The ladder was watered up on June 12th at about 10:00 a.m.
  
* On June 11th, 2018 we discoved that IR5 had not been uploading tag detections to PTAGIS since 5/26. Joseph contacted BioMark staff to help diagnose and fix the problem.  All other tag detection sites were working correctly (e.g. IR4 & IML).
    + Last tag detected before IR5 went offline was on May 25th at 3:14 a.m.
    + IR5 was brought back online on June 13th and almost immediately started detecting Bull trout tags at 1:10 p.m.
    + The cause of the downtime was attributed to a faulty master controller.  

* A tribal fishery occured from xx-28 June, 2018. 

* The new measuring board PIT tag reader was installed by BioMark in the Trap House on 6/26/18.  A computer software glich prevented active use of the new board on 6/28/18.  Weir staff are continuing to hand scan for PIT tags.  BioMark and FINS staff have resolved the software glich, and the FINS staff are upgrading the RFID PIT tag client to allow for real time data collection.  We anticipate using the new measuring board for real time PIT tag data collections on 12 July.  

* Managers held a conference call @ 2:00 p.m Pacific Time on 7/3/2018 and revised the in-season natural Chinook estimate to 195 natural Chinook at the mouth of the Imnaha River.  This revision changed the sliding scale from "Critical-0.5 MAT"" to "0.5-Critical."  

* Bull Trout PIT tag:  3D9.1C2D90A52D was captured by weir staff on 6/5/2018 in the adult ladder before the antennas at IML were lowered into the ladder.  IR5 was not functional on 6/5.  We presume this fish passed upstream of IR5 prior to the weir installation.  

* Chinook PIT tag 3DD.00777AEC3F was trapped on 6/22/18 and released back into the Imnaha River below IR3. First visit to IR4 = 6/20; second visit = 7/02. 







### Unique PIT-tag observations within the Imnaha Basin by species

-------------------------------------
 Mark.Species   Origin   Unique_Tags 
-------------- -------- -------------
  Bull Trout     Nat         189     

   Chinook       Hat         17      

   Chinook       Nat         54      

   Chinook       Unk          9      
-------------------------------------

### Unique PIT-tag observations by species, origin and release site

---------------------------------------------------------
 Mark.Species   Origin   Release.Site.Code   Unique_Tags 
-------------- -------- ------------------- -------------
  Bull Trout     Nat          IMNAHW             39      

  Bull Trout     Nat          IMNTRP             15      

  Bull Trout     Nat          SNAKE3             13      

  Bull Trout     Nat          SNAKE4             122     

   Chinook       Hat          IMNAHR              2      

   Chinook       Hat          IMNAHW             11      

   Chinook       Hat          LGRLDR              4      

   Chinook       Nat          IMNTRP              9      

   Chinook       Nat          LGRLDR             45      

   Chinook       Unk          BONAFF              9      
---------------------------------------------------------



### Unique PIT-tag observations by species, SiteID and origin
Unexpanded PIT tag counts at Big Sheep Creek (BSC), Cow Creek (COC), the mainstem PIT tag interrogation sites (IR1-IR5), the Imnaha adult ladder (IML), and the Imnaha facility trap house (IMNAHW).   

----------------------------------------------
 Mark.Species   SiteID   Origin   Unique_Tags 
-------------- -------- -------- -------------
  Bull Trout     COC      Nat          1      

  Bull Trout     IR1      Nat         101     

  Bull Trout     IR2      Nat         151     

  Bull Trout     BSC      Nat         15      

  Bull Trout     IR3      Nat         114     

  Bull Trout     IR4      Nat         103     

  Bull Trout     IML      Nat         10      

  Bull Trout    IMNAHW    Nat         19      

  Bull Trout     IR5      Nat         103     

   Chinook       IR1      Hat         17      

   Chinook       IR1      Nat         53      

   Chinook       IR1      Unk          9      

   Chinook       IR2      Hat         14      

   Chinook       IR2      Nat         48      

   Chinook       IR2      Unk          8      

   Chinook       BSC      Hat          1      

   Chinook       BSC      Nat          7      

   Chinook       IR3      Hat         16      

   Chinook       IR3      Nat         42      

   Chinook       IR3      Unk          9      

   Chinook       IR4      Hat         14      

   Chinook       IR4      Nat         26      

   Chinook       IR4      Unk          6      

   Chinook       IML      Hat         12      

   Chinook       IML      Nat         20      

   Chinook       IML      Unk          3      

   Chinook      IMNAHW    Hat          5      

   Chinook      IMNAHW    Nat          9      

   Chinook      IMNAHW    Unk          2      

   Chinook       IR5      Hat          9      

   Chinook       IR5      Nat          8      

   Chinook       IR5      Unk          1      
----------------------------------------------


### Unique PIT-tag observations within the Imnaha Basin by species, origin and arrival date
First detection dates of unexpanded Bull Trout and Chinook salmon PIT tags at tributary (COC, BSC) and mainstem (IR1-IR5, IML, IMNAHW) PIT tag interrogation sites.  Site are organized from downstream to upstream with the most downstream interrogation site (COC) in the top two panels.   
![plot of chunk Unique Tag counts](figure/Unique Tag counts-1.png)

### PIT tag detection efficiency at the node level  

Detection efficiencies at the node level (i.e., upstream and downstream antenna grous) and conversion rates for Bull Trout and Chinook Salmon detected at IR1-IR5, IML, and IMNAHW.  Detections in the trap house from the measuring board PIT reader will be labeled "IMNAHWB0".


-------------------------------------------------------------------------------
 Mark.Species     Node     Unique_Tags   Marks   Recaps   det_eff   Conversion 
-------------- ---------- ------------- ------- -------- --------- ------------
  Bull Trout      IR1          101        175      98      0.56        NA%     

  Bull Trout      IR2          151        148     124      0.84        100%    

  Bull Trout     IR3B0         88         132      72      0.55        90%     

  Bull Trout     IR3A0         59         111      38      0.34        107%    

  Bull Trout     IR4B0         78         110      77       0.7        65%     

  Bull Trout     IR4A0         99         96       85      0.89        100%    

  Bull Trout     IMLB0         10         95       9       0.09        94%     

  Bull Trout     IMLA0          6         95       6       0.06        90%     

  Bull Trout    IMNAHWA0        8         92       5       0.05        155%    

  Bull Trout     IR5B0         86         87       81      0.93        63%     

  Bull Trout     IR5A0         87          0       0        NA         NaN%    

   Chinook        IR1          79         80       79      0.99        NA%     

   Chinook        IR2          70         67       57      0.85        103%    

   Chinook       IR3B0         65         66       64      0.97        81%     

   Chinook       IR3A0         53         46       33      0.72        110%    

   Chinook       IR4B0         46         45       45        1         62%     

   Chinook       IR4A0         43         35       33      0.94        99%     

   Chinook       IMLB0         33         30       28      0.93        78%     

   Chinook       IMLA0         27         27       24      0.89        86%     

   Chinook      IMNAHWA0       16         18       7       0.39        135%    

   Chinook       IR5B0         16         17       15      0.88        44%     

   Chinook       IR5A0         17          0       0        NA         NaN%    
-------------------------------------------------------------------------------

###PIT tag detection efficiency at the site level  

Detection efficiencies and converson rates at the site level.  See the Node level estimates above for an efficiency estimate at IR5B0.

-----------------------------------------------------------------------------
 Mark.Species    Node    Unique_Tags   Marks   Recaps   det_eff   Conversion 
-------------- -------- ------------- ------- -------- --------- ------------
  Bull Trout     IR1         101        175      98      0.56        NA%     

  Bull Trout     IR2         151        148     124      0.84        100%    

  Bull Trout     IR3         114        132      98      0.74        85%     

  Bull Trout     IR4         103        96       88      0.92        73%     

  Bull Trout     IML         10         95       9       0.09        94%     

  Bull Trout    IMNAHW        8         92       5       0.05        139%    

   Chinook       IR1         79         80       79      0.99        NA%     

   Chinook       IR2         70         67       57      0.85        103%    

   Chinook       IR3         67         66       66        1         81%     

   Chinook       IR4         46         45       45        1         69%     

   Chinook       IML         35         30       30        1         76%     

   Chinook      IMNAHW       16         18       7       0.39        118%    
-----------------------------------------------------------------------------


### Unique PIT-tag observations at the Imnaha Weir by trap status (based on observation date at weir sites (IR4, IML, IMNAHW, IR5)

-----------------------------------------------------
 Mark.Species    TrapStatus     SiteID   Unique_tags 
-------------- --------------- -------- -------------
  Bull Trout    Panels Closed    IML          9      

  Bull Trout    Panels Closed   IMNAHW       18      

  Bull Trout    Panels Closed    IR4         92      

  Bull Trout    Panels Closed    IR5         102     

  Bull Trout     Panels Open     IML          1      

  Bull Trout     Panels Open    IMNAHW        1      

  Bull Trout     Panels Open     IR4         11      

  Bull Trout     Panels Open     IR5          1      

   Chinook      Panels Closed    IML         35      

   Chinook      Panels Closed   IMNAHW       16      

   Chinook      Panels Closed    IR4         46      

   Chinook      Panels Closed    IR5         18      
-----------------------------------------------------

### Passage routes of PIT-tagged fish successfully reaching and being detected at IR5 
This summary is limited to previously tagged fish (i.e., not tagged at IMNAHW in 2018) detected at IR5.  

*Passage Route descriptions:*  
* *Handled*: Processed in the trap house (IMNAHW) followed by a detection at IR5.  
* *IML obs = F *: Not detected at IML (F = False).  
* *IML obs = T*:  Detected at IML (T = True). 

*Trap Status descriptions*  
* *No obs at IR4*: no PIT tag observation at IR4.  
* *Panels Closed*: Indicates that the weir was fully operational.  
* *Panels Open*:  Separates out detections at IR5 before the weir was operational.  

 

-------------------------------------------------------------
 Mark.Species    PassageRoute     TrapStatus     Unique_tags 
-------------- ---------------- --------------- -------------
  Bull Trout       Handled       Panels Closed        5      

  Bull Trout    Handled 6/5/18    Panels Open         1      

  Bull Trout     IML obs = F     Panels Closed       84      

  Bull Trout     IML obs = F      Panels Open        11      

  Bull Trout     IML obs = T     Panels Closed        2      

  Bull Trout     IML obs = T      Panels Open         1      

   Chinook         Handled       Panels Closed        7      

   Chinook       IML obs = T     Panels Closed       11      
-------------------------------------------------------------


### Unique PIT-tag observations by tag status  
*Tag status descriptions:*  
* *At Weir*: Observed at IR4 but not IML, IMNAHW, or IR5.   
* *Attempted Ladder*: Detected at IML, but not detected at IMNAHW.   
* *Last obs: BSC*: Observed at Big Sheep Creek.  
* *Last obs: IR1/IR2/IR3*: Observed at IR1, IR2, or IR3, respectively.  
* *NewTag*: Bull Trout tagged at IMNAHW in 2018.  
* *Passed*: Detected at IR5.  
* *Trapped*: Handled at IMNAHW, but no subsequent detection IR5.  
* *Trapped: Obs Below Weir*: Handled at IMNAHW & detected at IR4>IMNAHW  
 



---------------------------------------------------------------
 Mark.Species   Origin          TagStatus          Unique_Tags 
-------------- -------- ------------------------- -------------
  Bull Trout     Nat             At Weir                5      

  Bull Trout     Nat          Last obs: BSC            10      

  Bull Trout     Nat          Last obs: IR1             3      

  Bull Trout     Nat          Last obs: IR2            17      

  Bull Trout     Nat          Last obs: IR3            37      

  Bull Trout     Nat             NewTag                11      

  Bull Trout     Nat             Passed                91      

  Bull Trout     Nat        Passed: <11 June           13      

  Bull Trout     Nat             Trapped                1      

  Bull Trout     Nat     Trapped: Obs Below Weir        1      

   Chinook       Hat             At Weir                2      

   Chinook       Hat        Attempted Ladder            1      

   Chinook       Hat          Last obs: BSC             1      

   Chinook       Hat          Last obs: IR3             2      

   Chinook       Hat             Passed                 9      

   Chinook       Hat             Trapped                2      

   Chinook       Nat             At Weir                6      

   Chinook       Nat        Attempted Ladder            6      

   Chinook       Nat          Last obs: BSC             6      

   Chinook       Nat          Last obs: IR2             6      

   Chinook       Nat          Last obs: IR3            16      

   Chinook       Nat             Passed                 8      

   Chinook       Nat             Trapped                6      

   Chinook       Unk             At Weir                3      

   Chinook       Unk        Attempted Ladder            1      

   Chinook       Unk          Last obs: IR3             3      

   Chinook       Unk             Passed                 1      

   Chinook       Unk             Trapped                1      
---------------------------------------------------------------

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)


## Travel time between sites

![plot of chunk Travel Time](figure/Travel Time-1.png)


### Number of days spent at a site
![plot of chunk days_site](figure/days_site-1.png)

### Tag Status = "Last Obs:  IR3" 

Summary of tags last observed at IR3. 


----------------------------
 Mark.Species   Origin   n  
-------------- -------- ----
  Bull Trout     Nat     37 

   Chinook       Hat     2  

   Chinook       Nat     16 

   Chinook       Unk     3  
----------------------------

###Minimum Travel Time from IR4 to IMNAHW  

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)



### Tag Status = "At Weir" 

Fish assigned a tag status of "At Weir" have been detected at IR4 but have not been detected at IML, handled in the trap (IMNAHW), or detected at IR5. IR4_min and IR4_max are the first and last detection dates at IR4, respectively.


---------------------------
 Mark.Species   Origin   n 
-------------- -------- ---
  Bull Trout     Nat     5 

   Chinook       Hat     2 

   Chinook       Nat     6 

   Chinook       Unk     3 
---------------------------


------------------------------------------------------------------
     TagID        Mark.Species   Origin    IR4_min      IR4_max   
---------------- -------------- -------- ------------ ------------
 3D9.1C2DE1998D    Bull Trout     Nat     2018-06-11   2018-06-11 

 3D9.1C2DE16C44    Bull Trout     Nat     2018-06-12   2018-06-12 

 3DD.007775C608    Bull Trout     Nat     2018-06-13   2018-06-13 

 3DD.00777268AE    Bull Trout     Nat     2018-06-21   2018-06-22 

 3DD.007775A33E    Bull Trout     Nat     2018-07-06   2018-07-06 

 3DD.0077600913     Chinook       Nat     2018-06-20   2018-06-20 

 3DD.007768E7CE     Chinook       Hat     2018-06-21   2018-06-25 

 3DD.00775E6F32     Chinook       Nat     2018-06-25   2018-06-26 

 3DD.0077BA43DD     Chinook       Unk     2018-06-26   2018-06-26 

 3DD.00775F4E6B     Chinook       Nat     2018-06-27   2018-06-28 

 3DD.0077BA559F     Chinook       Unk     2018-07-07   2018-07-07 

 3DD.00775EBECB     Chinook       Nat     2018-06-26   2018-07-09 

 3DD.0077BA8FD5     Chinook       Unk     2018-07-10   2018-07-10 

 3DD.00776012FF     Chinook       Nat     2018-07-09   2018-07-10 

 3DD.0077601181     Chinook       Hat     2018-07-09   2018-07-10 

 3DD.00775FFCF7     Chinook       Nat     2018-06-24   2018-07-10 
------------------------------------------------------------------

### Source Data
The complete PIT-tag histories for Chinook Salmon and Bull trout detected during 2018 in the Imnaha River Basin were downloaded as two seperate files located on the [PTAGIS ftp server](ftp://ftp.ptagis.org/MicroStrategyExport/). The files are the result of running "Complete Tag History" queries that were parameterized on the [PTAGIS website](https://www.ptagis.org/) and set-up to run and save automatically at 6:00 a.m. and 12:00 p.m. each day.  The first file contains Chinook Salmon PIT-tag detections and is stored at the "*feldhauj/2018_Imnaha_CompleteTagHistory.csv*" file path within the ftp server.  The second file contains Bull trout detections and is stored within the "*rkinzer/Imnaha_Bull_Complete_Tag_History.csv*" filepath.  We are then using an R-script to download the files from the PTAGIS ftp server and combine them into a single file.  Once the file is combined all Chinook Salmon and Bull trout tag detections are processed using the R package [PITcleanR](https://github.com/kevinsee/PITcleanR). The final dataset provides a simplified tag history with the first and last detection dates at each PIT-tag detection node (i.e., a single spanning array or antenna) and information regarding upstream and downstream movements and a more general migration direction.   

#####*Creating the PTAGIS Chinook Complete Tag History report:*  
* *Tag list #1:* Static Tag list for all Chinook tagged in 2018 and released at BONAFF or LGRLDR.  
* *Tag list #2:* Static Tag list for Chinook released into the Imnaha River for MY2015-2017 and detected at a mainstem adult ladder interrogatoin site in 2018.  
* *Event Date:* Between 5/1/2018 and 10/1/2018
* *Event Sites:* IR1, IR2, IR3, IR4, IR5, IML, IMNAHW, BSC, IMNAHR
* *Mark Species:* Chinook
* *Event Type:* Observation, Recapture, Recovery

#####*Creating the PTAGIS Bull Trout Complete Tag History report:*  
* *Query:* All PIT-tagged Bull trout detected in the Imnaha River Basin in 2018.   
* *Event Date:* Between 1/1/2018 and 10/1/2018
* *Event Sites:* IR1, IR2, IR3, IR4, IR5, IML, IMNAHW, COC, BSC, IMNAHR
* *Mark Species:* Bull Trout
* *Event Type:* Observation, Recapture, Recovery 


#####*Output Files:*  
* *PITcleanr_2018_chs_bull.xlsx*:  The complete tag histories from 2018_Imnaha_ComploeteTagHistory.csv and Imnanha_Bull_Complete_Tag_Histories.csv combined into a single file and processed with the PITcleanr R-package.  
* *detect_hist.xlsx*: A pivot table style summary. (This description is not complete JF 7/6/18) Each row = a unique PIT tag code.  Columns correspond to first detection dates at IR1-IR5, IML, and IMNAHW.  This file contains the Trap Status, TagPath, Passage Route, and TagStatus fields.  Trap status references the dates the weir was operating. TagPath is a character string representing detections at PIT tag observations sites.  TagStatus represents the last known location of the tag and whether the tag has arrived at the weir, has attempted the ladder (i.e., detected at IML), passed the weir (i.e., detected at IR5), or has been trapped (i.e., detected at IMNAHW). The tag pathway describes the passage route through the weir.
