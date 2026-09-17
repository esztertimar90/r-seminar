########## R CODING SEMINAR (ECONOMETRICS) #########
# SESSION 2: ORGANIZING YOUR WORK, IMPORTING DATA #
## ---------------------------------------------- ##

## Housekeeping ----------------------------------------------------------------
# Use this only if you want to reset the workspace
rm(list = ls())

## Packages/libraries ----------------------------------------------------------
# Run once when you first install packages:
#install.packages('tidyverse')
#install.packages('wooldridge')

# load packages
library(tidyverse)
library(wooldridge)

## 1) Organizing your work, paths, and R projects --------------------------------
# "Standard" option: working with working directory paths (aka absolute paths)
  # Check your current working directory
  getwd()
  # Set working directory:
  setwd("Users/martinneubrandt/Dropbox/Econometrics")
    # What is the problem?

  # Let's make a simple plot and try to save it: 
randomdata <- rnorm(1000)
myplot <- ggplot(data.frame(x = randomdata), aes(x = x)) +
  geom_histogram(bins = 30, fill = "pink", color = "blue") +
  labs(title = "Histogram of Random Data", x = "Value", y = "Frequency")
myplot
ggsave("myplot.png")
ggsave("graphs/myplot.png")

#Q: what happens if you download the folder to a different computer? Will the code still work? Why or why not?

# Why this matters: R looks for files relative to the working directory
# If you use setwd(), paths become hardcoded and you need to update it when you move the folder

# BETTER: Use an R Project (.Rproj file)
# Opening a .Rproj file automatically sets the working directory to the project root
# This makes paths portable across computers and enables reproducibility

# With an R Project, you use relative paths from the project root:
# Example: read.csv("data/raw/file.csv")
# Instead of: setwd("~/Documents/MyProject"); read.csv("data/file.csv")

# Recommended folder structure:
# project_root/
# ├── project_name.Rproj
# ├── data/                  (where you store data files)
# ├── code/                  (R scripts)
# ├── output/                (figures, tables, results)
# └── docs/                  (markdown files, documents etc.)

# Let's create a new R Project called 'RSeminar' and set up the folder structure
# 1. In RStudio, go to File > New Project > New Directory > New Project
# 2. Name your project and choose a location
# 3. Create folders: data, code, output, docs


## 2) Importing data -----------------------------------------------------------
# Data can come in a number of formats (e.g., .csv, .dta, .xlsx)
# There are different functions used to import data from various data formats.

rm(list = ls())

## packages/libraries ----------------------------------------------------------
# we will need a new package called writexl
install.packages('writexl')
library(writexl)
# we also use the package readr - this is included in tidyverse (already loaded)

## Importing data:
# 3 options to import data:


#####
#   1) Import by clicking: File -> Import Dataset -> 
#       -> From Text (readr) / this is for csv. You may use other to import other specific formats
#
# Notes: 
#   - Do this exercise to find your data and realize that importing this way will show up in the console.
#         if second option does not work, check the path on the console!
#   - Check the library, that the import command used: it is called 'readr' which is part of 'tidyverse'!
#         you should avoid calling libraries multiple times, thus if tidyverse is already imported,
#         there is no need to import readr again. 
#           (But in this case will not cause any problem. It may be a problem if you call different versions!)

#######
#   2) Import by defining your path:
#       a) use an absolute path (you have to know from root folder the path of your csv)

df_a <- read_csv('/Users/esztertimar/Teaching/Econometrics R Seminar 2026-27/data/hotels-vienna.csv')

#       b) use relative path:
#           check working directory:
getwd()

# and simply call the data from there:
df_b      <- read_csv('data/hotels-vienna.csv')

# delete your data
rm(df_a, df_b)


########
#   3) Import by using url
#     Note: importing from the web is almost inferior to use your local disc, 
#       but there are some exceptions:
#         a) The data is considerably large (>1GB)
#         b) It is important that there is no `refresh` or change in the data
#       in these case it is good practice to download to your computer the datas

# Can access (almost) all the dat from 'ISF'
# the hotels vienna dataset has the following url:
df <- read_csv(url('https://osf.io/y6jvb/download')) 

###
# Quick check on the data:

# glimpse on data
glimpse(df)

# Check some of the first observations
head(df)

# Have a built in summary for the variables
summary(df)

data <- '/Users/esztertimar/Teaching/Econometrics R Seminar 2026-27/data/'
###########################
# Exporting your data:
write_csv(df, paste0(data, 'my_csvfile.csv'))

# If due to some reason you would like to export as xls(x)
write_xlsx(df, paste0(data, 'my_csvfile.xlsx'))

# Third option is to save as an R object
save(df, file = paste0(data, 'my_rfile.RData'))

######
# Extra: using API (short for Application Programming Interface) 
#   - tq_get - get stock prices from Yahoo/Google/FRED/Quandl, ect.
#   - WDI    - get various data from World Bank's site
#

# tidyquant is a package for financial data use and analysis
install.packages('tidyquant')
library(tidyquant)
# Apple stock prices from Yahoo
aapl <- tq_get('AAPL',
               from = '2020-01-01',
               to = '2021-10-01',
               get = 'stock.prices')

glimpse(aapl)

# World Bank
install.packages('WDI')
library(WDI)
# How WDI works - it is an API
# Search for variables which contains GDP
a <- WDIsearch('gdp')
# Narrow down the serach for: GDP + something + capita + something + constant
a <- WDIsearch('gdp.*capita.*constant')
# Get data
gdp_data <- WDI(indicator='NY.GDP.PCAP.PP.KD', country='all', start=2019, end=2019)

glimpse(gdp_data)

# Eurostat also has an API which might be useful for project work in future courses
install.packages("eurostat")
library(eurostat)

## Example: at-risk-of-poverty rate in the EU-27, over time --------------------
# Eurostat organizes data into 'tables', each with its own short code.
# You can search for tables by keyword:
poverty_search <- search_eurostat("poverty", type = "table")
head(poverty_search)

# We'll use 'ilc_li02' - the at-risk-of-poverty rate by age and sex
# (share of people living on less than 60% of national median income)
poverty_raw <- get_eurostat("ilc_li02", time_format = "num")

# quick check on what we got
glimpse(poverty_raw)

# Eurostat data comes in 'long' format with its own codes for the breakdowns.
# Let's see what values these can take:
unique(poverty_raw$age)
unique(poverty_raw$sex)

# we only want: the total population (not broken down by age or sex),
# and only EU-27 member states (dropping EU/EA aggregate rows and non-EU countries)
eu27 <- c("BE","BG","CZ","DK","DE","EE","IE","EL","ES","FR","HR","IT",
          "CY","LV","LT","LU","HU","MT","NL","AT","PL","PT","RO","SI",
          "SK","FI","SE")

poverty_eu27 <- poverty_raw |>
  filter(age == "TOTAL", sex == "T", geo %in% eu27)

# average at-risk-of-poverty rate across the EU-27, for each year
poverty_avg <- poverty_eu27 |>
  group_by(time) |>
  summarise(avg_poverty_rate = mean(values, na.rm = TRUE))

# simple ggplot: EU-27 average poverty rate over time
ggplot(poverty_avg, aes(x = time, y = avg_poverty_rate)) +
  geom_line(color = "darkred", linewidth = 1) +
  geom_point(color = "darkred") +
  labs(
    title = "At-risk-of-poverty rate, EU-27 average",
    subtitle = "Unweighted average across member states, total population",
    x = "Year",
    y = "At-risk-of-poverty rate (%)"
  ) +
  theme_minimal()

##
# Tasks:
#
# 1) Go to the webpage: https://gabors-data-analysis.com/ and find OSF database under `Data and Code`
# 2) Go the the Gabor's OSF database and download manually 
#       the `hotelbookingdata.csv` from `hotels-europe` dataset into your computer and save it to 'raw' folder.
# 3) load the data from this path
# 4) also load the data directly from the web (note you need to add `/download` to the url)
# 5) write out this file as xlsx and as a .RData next to the original data.

# Load from path
df_t0 <- read_csv(paste0(data_in,'raw/hotelbookingdata.csv'))
# Load from wed
df_t1 <- read_csv('https://osf.io/yzntm/download')
# Write as xlsx
write_xlsx(df_t1, paste0(data_out, 'hotelbookingdata.xlsx'))
# Write as .RData
save(df_t1, file = paste0(data_out, 'hotelbookingdata.RData'))






## 3) Tibbles ------------------------------------------------------------------
# in tidyverse data objects are stored in 'tibble' format
# tibble is a special 'Data' type of variable

# create a tibble
workers <- tibble(
  name = c('Alice', 'Bob', 'Charlie', 'Diana', 'Eve'),
  age = c(30, 20, 13, 45, 39),
  height = c(1.65, 1.80, 1.75, 1.70, 1.60),
  wage = c(75000, 45000, NA, 280000, 190000),
  male = c(FALSE, TRUE, TRUE, FALSE, FALSE),
)

# check the data
view(workers)

## 2) indexing and subsetting with tibbles -------------------------------------
# get the first row (all variables of the first observation)
workers[1, ]
workers[workers$name == 'Alice', ]

# get the fourth column (all observations of the fourth variable)
workers[, 4]
workers$wage

# get the first element (first observation of the first variable)
workers[1, 1]
workers[[1, 1]]

  # difference between single and double square brackets
  typeof(workers[1, 1])  # returns list
  typeof(workers[[1, 1]])  # returns double vector

# select elements
workers[1:3, 1:2]  # first three rows, first two columns
workers[1:3, c('name', 'age')]  # first three rows, name and age columns
workers$wage[1:3]  # first three rows, wage column
workers[workers$male == FALSE, ] # females
workers[workers$age >= 20 & workers$age <= 40, ] # workers between 20-40 years old

# using built-in functions
filter(.data = workers, male == FALSE) # same but with built-in function
filter(.data = workers, age >= 20 & age <= 40) # same but with built-in function
select(.data = workers, wage)

  # what's the difference?
  workers$wage # returns a vector
  select(workers, wage) # returns a tibble

# sum of all the wages without function and deal with NAs
sum(workers$wage) # problem: NAs
sum(workers$wage, na.rm = TRUE) # how to deal with NAs

# average wage of workers between 20-40 years old
mean(workers$wage[workers$age >= 20 & workers$age <= 40], na.rm = TRUE)

## 3) the pipe operator --------------------------------------------------------
# the pipe operator is used to chain functions together

# e.g.: you can do the same with the pipe operator as with the indexing and subsetting before
# select name and age variables
workers |>
  select(name, age)

# select females
workers |>
  filter(male == FALSE)

# select wages of female workers
workers |>
  filter(male == FALSE) |>
  select(wage)

# select wages of female workers between 20-40 years old
workers |>
  filter(male == FALSE) |>
  filter(age >= 20 & age <= 40) |>
  select(wage)

workers |>
  filter(male == FALSE & age >= 20 & age <= 40) |>
  select(wage)

# average wage of workers between 30-40 years old
workers |>
  filter(age >= 30 & age <= 40) |>
  summarise(avg_wage = mean(wage, na.rm = TRUE))

# add a new variable
workers <- workers |>
  add_column(firm = c('Microsoft', 'Google', NA ,'Amazon', 'Apple')) # tidyverse thinking

workers <- workers |>
  mutate(heightsq = height*height) # create new variable using already defined variable

# change values
workers <- workers |>
  mutate(wage = replace_na(wage, 0)) # change NA to zero

workers <- workers |>
  mutate(age = replace(age, age > 30, 31))

# remove a variable
workers <- workers |>
  select(-heightsq)

# add a new observation (row)
workers <- workers |>
  add_row(name = 'Frank', age = 61, height = 179, wage = 30000, male = TRUE, firm = 'Tesla')

# remove observations
workers <- workers |>
  filter(wage > 0) # remove observations with zero wage (or keep observations with greater than zero wage)
