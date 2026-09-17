########## R CODING SEMINAR (ECONOMETRICS) #########
# SESSION 2: SOLUTION - importing data assignment #
## ---------------------------------------------- ##

# This script completes the Tasks set at the end of session2_21sept.R:
#   1) Find the OSF database on https://gabors-data-analysis.com/ (under "Data and Code")
#   2) Manually download `hotelbookingdata.csv` from the `hotels-europe` dataset
#      and save it into the 'raw' folder
#   3) Load the data from this local path
#   4) Also load the data directly from the web
#   5) Write the file out as .xlsx and as .RData, next to the original data

## Packages/libraries ----------------------------------------------------------
library(tidyverse)
library(writexl)

## Paths -------------------------------------------------------------------
# data_in points to where the manually downloaded raw file lives
# (relative to the project root - open the .Rproj so this works on any computer)
data_in <- "data/raw/"

## Task 1-2) Manual download -----------------------------------------------
# Go to https://gabors-data-analysis.com/ -> Data and Code -> find the OSF page
# for the 'hotels-europe' dataset, and download 'hotelbookingdata.csv' by hand.
# Save it into the project's data/raw/ folder.

## Task 3) Load from the local path -----------------------------------------
df_local <- read_csv(paste0(data_in, "hotelbookingdata.csv"))

glimpse(df_local)

## Task 4) Load the same data directly from the web --------------------------
# Note: OSF file pages need '/download' appended to the URL to get the raw file
df_web <- read_csv("https://osf.io/yzntm/download")

glimpse(df_web)

# quick check that both versions match
identical(df_local, df_web)

## Task 5) Write the file out as .xlsx and .RData, next to the original data -
# "next to the original data" = same folder as the raw csv, i.e. data_in
write_xlsx(df_web, paste0(data_in, "hotelbookingdata.xlsx"))
save(df_web, file = paste0(data_in, "hotelbookingdata.RData"))
