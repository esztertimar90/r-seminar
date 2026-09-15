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
install.packages('writexl')

# load packages
library(tidyverse)
library(wooldridge)
library(writexl)

## 1) Organizing your work -----------------------------------------------------
getwd()






## 2) Importing data -----------------------------------------------------------
# Data can come in a number of formats (e.g., .csv, .dta, .xlsx)
# There are different functions used to import data from various data formats.





# Tidy data, pipe operator
# based on
#   - Ágoston Reguly, Gábor Békés: Introduction to Data Analysis with R - lecture materials
#   - Hadley Wickham, Mine Çetinkaya-Rundel, and Garrett Grolemund: R for Data Science (2e)

rm(list = ls())

## packages/libraries ----------------------------------------------------------
# we need a new package called writexl
# load packages
library(tidyverse)
library(writexl)

## 1) tibbles ------------------------------------------------------------------
# in tidyverse data objects are stored in 'tibble' format
# tibble is a special 'Data' type of variable
# it is a modern version of data_frame and data.frame
# data_frame and data.frame usually do not support newer functions

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
