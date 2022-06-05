#Packages ----
packages <- c("readxl", "rJava", "xlsx", "data.table", "tidyverse")
# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
# Packages loading
invisible(lapply(packages, library, character.only = TRUE))


#get wds ----
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
wd <- dirname(rstudioapi::getSourceEditorContext()$path)                             #get current directory
in.dir <- in.dir <- paste(wd, 'input', sep="/")
in.files <- list.files(paste(in.dir), pattern = "PeakTable", full.names = TRUE)            #list all PeakTable files
source("config.R")                                                           #source config file

#read files ----
labchip <- lapply(in.files, read.csv)

labchip <- rbindlist(labchip, idcol = "id")
samples <- unique(labchip$`Sample Name`)

#cols for labchip dir, filename, date ----
names(labchip)[names(labchip) == 'Sample.Name'] <- 'Well Position'        #match col name for well position to pcr (for future merging)

#filter markers
labchip <- labchip %>% filter(across(everything(), ~ !grepl("Ladder", .)))    #remove ladders
labchip <- labchip %>% filter(across(everything(), ~ !grepl("LM", .)))        #remove LM
labchip <- labchip %>% filter(across(everything(), ~ !grepl("UM", .)))        #remove UM
labchip <- labchip %>% filter(`Size..BP.` >= 0)                               #filter fragments with no size
#remove migration time columns x2

#filter based on fragment sizes
labchip <- labchip %>% filter(`Size..BP.` >= min_size) #remove fragments below minimum limit
labchip <- labchip %>% filter(`Size..BP.` <= max_size) #remove fragments above upper limit

#generate output ----
out.dir <- substr(in.dir[1],1,nchar(in.dir[1])-4)                             #remove .xls suffix
write.csv(labchip, paste(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "bp", min_size, max_size, "labchip_unfiltered_output.csv", sep = "_"), row.names = FALSE)


#generate filtered data with number of fragments
labchip_filt <- labchip  %>% group_by(`Well Position`) %>%
  dplyr::summarise(fragment_count = n(),`Total Conc` = sum(`Conc...ng.ul.`))
write.csv(labchip, paste(format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), "bp", min_size, max_size, "labchip_filtered_output.csv", sep = "_"), row.names = FALSE)