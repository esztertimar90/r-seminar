# Missing values: how to find them, check them, and decide what to do
#
# R marks a missing value as NA ("not available").
# This script uses a small made-up data set, so you can see every row.

library(tidyverse)

# ---- A small example -------------------------------------------------------

people <- tibble(
  id       = 1:12,
  age      = c(25, 31, 45, 52, 38, 29, 61, 44, 35, 57, 48, 27),
  female   = c(1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1),
  job      = c("employee", "employee", "self-employed", "employee",
               "self-employed", "employee", "self-employed", "employee",
               "employee", "self-employed", "employee", "employee"),
  educ     = c("secondary", "tertiary", "tertiary", NA, "secondary",
               "tertiary", "secondary", "tertiary", "secondary",
               "tertiary", "secondary", "tertiary"),
  wage     = c(1800, 2600, NA, 2900, NA, 2400, NA, 3100, 2200, 3500, 2700, 2100)
)

people

# ---- 1. How many values are missing? -----------------------------------------

# is.na() is TRUE where a value is missing. Summing TRUE values counts them.
sum(is.na(people$wage))

# The same count for every column at once
people |>
  summarise(across(everything(), \(x) sum(is.na(x))))

# ---- 2. Which rows have missing values? --------------------------------------

people |>
  filter(is.na(wage))

# Rows with a missing value in any column
people |>
  filter(if_any(everything(), is.na))

# ---- 3. Is the missingness random? -------------------------------------------

# Compare people with and without a wage on the variables we do observe.
# If the two groups look alike, the missing wages are probably unrelated to
# who these people are. If they differ, dropping them changes the sample.

people |>
  group_by(wage_missing = is.na(wage)) |>
  summarise(n = n(),
            mean_age = mean(age),
            share_female = mean(female),
            share_self_employed = mean(job == "self-employed"))

# Here three of the four self-employed have no wage. The missing wages are not
# random: they come from one group. Dropping them leaves mostly employees, so
# any result describes employees, not everyone.

# This check has a limit. It only uses variables we can see. Missingness can
# also depend on the missing value itself: for example, people with very high
# wages may refuse to report them. The data cannot show this. You have to
# think about how the data were collected.

# ---- 4. How R functions treat NA ---------------------------------------------

# Most calculations return NA if any input is missing
mean(people$wage)

# na.rm = TRUE removes missing values before calculating
mean(people$wage, na.rm = TRUE)

# Comparisons with NA give NA, and filter() drops those rows.
# (Stata is different: there a missing number counts as larger than any
# number, so "if wage > 3000" would keep the missing rows.)
people |>
  filter(wage > 3000)

# lm() drops rows with a missing value in any variable of the model, without
# a warning. nobs() shows how many rows were actually used.
model <- lm(wage ~ age + female, data = people)
nobs(model)

# ---- 5. What to do with missing values ---------------------------------------

# Option A: drop rows with a missing value in the variables you use.
# Name the variables. drop_na() with no variables drops a row if ANY column
# is missing, including columns you never use.
people_wage <- people |>
  drop_na(wage)

# Dropping is reasonable when few values are missing and the check in step 3
# shows no clear difference between the two groups. Always report how many
# rows you dropped.

# Option B: keep the rows and add a flag, so the missing group stays visible
people <- people |>
  mutate(wage_missing = as.integer(is.na(wage)))

# Option C: for a categorical variable, make "missing" its own category.
# The row stays in the analysis, and the model estimates a separate effect
# for the missing group.
people <- people |>
  mutate(educ = replace_na(educ, "unknown"))

people

# Avoid filling missing numbers with the mean of the others. It keeps the
# rows, but it makes the variable look less spread out than it is, and it
# does nothing about missingness that is not random.
