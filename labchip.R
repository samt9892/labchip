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
in.dir <- paste(wd, 'input', sep="/")
in.files <- list.files(paste(in.dir), pattern = "PeakTable", full.names = TRUE)            #list all PeakTable files (fullpath)
out.files <- list.files(paste(in.dir), pattern = "PeakTable", full.names = FALSE)         #list all PeakTable files (fileonly)
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
out.dir <- paste(wd, "output", sep ="/") 
out.dir2 <- paste(out.files, "bp", min_size, max_size, "rawra_output.xlsx", sep = "_")
out.dir3 <- paste(out.files, "bp", min_size, max_size, "summarised_output.xlsx", sep = "_")

write.xlsx(labchip, paste(out.dir, out.dir2, sep ="/"), row.names = F)

#generate filtered data with number of fragments
labchip_filtered <- labchip  %>% group_by(`Well Position`) %>%
  dplyr::summarise(fragment_count = n(),`Total Conc` = sum(`Conc...ng.ul.`))

labchip_filtered <- as.data.table(labchip_filtered) #need this line to write to .xlsx
write.xlsx(labchip_filtered, paste(out.dir, out.dir3, sep="/"), row.names = F)