# ------------------------------------------------------------------------------
# Data cleaning
# based on
#   - Ágoston Reguly, Gábor Békés: Introduction to Data Analysis with R - lecture materials
#
## cleaning the environment ----------------------------------------------------
rm(list = ls())

## packages/libraries ----------------------------------------------------------
# install packages
install.packages('writexl')
install.packages('tidyverse')
install.packages('dplyr')

# load packages
library(writexl)
library(tidyverse)
library(dplyr)

# set working directory - it should be correct from the previous session
getwd()

# we will learn how to clean and prep data while trying to find a good deal among hotels

## 1) case study: hotels  ------------------------------------------------------
# story: You want to analyse hotels in Vienna, Austria
# import raw data: hotels-europe
# includes information on price and features of hotels in 46 European cities and for 10 different dates
raw_df <- read_csv('https://osf.io/yzntm/download')

# let's save the data for later use (optional):
write_csv(raw_df, "data/hotels_raw.csv")
  # "raw" is a naming convention, it means data in its original form (before cleaning/wrangling)

# check the data
glimpse(raw_df)
view(raw_df)
summary(raw_df)

# how many cities does it have hotels for?
unique(raw_df$city_actual)
n_distinct(raw_df$city_actual)  # there are 760 cities

# often, we do not need all the information from a dataset
# we can delete the variables (aka columns) we do not need
# create a new dataset and keep only the relevant content:
hotels <- raw_df |> 
  filter(s_city == 'Amsterdam') |> 
  select(center1distance,
         price, price_night,
         starrating,
         accommodationtype,
         guestreviewsrating,
         hotel_id,
         offer, offer_cat,
         year, month, weekend, holiday)

    # filter() is for rows: we only keep rows where s_city is Amsterdam
    # select() is for columns: we keep the hotel characteristics we care about

view(raw_df)
view(hotels)

# optional: remove raw file to save memory
rm(raw_df)

## 2) data cleaning ----------------------------------------------------------------
#--------------------------------------------------------------------------------
# we will use mutate function with gsub and regex
# mutate: tidyverse function to create new vars as 'mutations' of existing ones
# gsub: search for matches in the data for a pattern and replace it with something
# regular expression (regex): a formal language used to describe patterns in text
#   - we have to put into string quotes
#   - []: match any character from this set
#   - ^: negation, so match any character, except in the set
#   - 0-9: any digit from 0 to 9
#---------------------------------------------------------------------------------

# Problem 1: prices are not in 'per night' format, we have price and the amount of nights
# Solution: We need to create a price per night variable 

# Step 1: we extract the number of nights from 'price_night' string
hotels <- hotels |> 
  mutate(
    nights = as.numeric(
      gsub(
        pattern = '[^0-9]',
        x = price_night,
        replacement = '')))
      
        # we have a new variable 'nights' which extracted the number of nights

# Step 2: divide the total price with the number of nights:
hotels <- hotels |>
  mutate(
    price_per_night = price/nights)

        # now we have price per night!

# remove the original vars we no longer need:
hotels <- hotels |> 
  select(-price, -price_night)

    # alternative method to remove:
    # hotels$price <- NULL 

# Problem 2: accommodation type variable is messy 
# Solution: we need to get rid of the string at the beginning "_ACCOM_TYPE"
# proper type starts after @ separator

#--------------------------------------------------------------------------------
# we will use mutate function with separate
# col = the column (aka variable) we are mutating
# sep = the separator (in our case @) 
# into = names of the two new variables as c('var1', 'var2')
#---------------------------------------------------------------------------------

hotels <- hotels |> 
  separate(col = accommodationtype,
           sep = '@',
           into = c('junk', 'acc_type')) # separate accommodation type into two variables

hotels <- hotels |> 
  select(-junk) # remove the junk variable 

hotels <- hotels |> 
  mutate(acc_type = factor(acc_type)) # convert to factor 

# Problem 3: distance is also messy ("3.1 miles") and cannot be handled as a numeric var
    # let's make better use of |> and string more commands together
  hotels <- hotels |> 
    separate(center1distance,
             sep = ' ',
             into = c('distance', 'unit')) |> 
    select(-unit) |> 
    mutate(distance = as.numeric(distance)) 

# transform into kilometers instead of miles:
hotels <- hotels |>
      mutate(distance = distance * 1.609)

# now we have a clean distance variable in a familiar unit 

# Problem 4: guest ratings are also messy, need to remove '/5'

hotels <- hotels |>
  separate(guestreviewsrating,
           sep = '/',
           into = c('ratings') # if you set only one variable name, it takes only the part until the separator
  ) |> 
  mutate(ratings = as.numeric(ratings)) # convert to numeric 

# can we drop the NA values?
hotels <- hotels |> 
  filter(!is.na(ratings))

table(hotels$ratings)
table(hotels$acc_type, hotels$ratings)

# Problem 5: there might be duplicate records
# check duplicates
sum(duplicated(hotels))
hotels |> 
  filter(duplicated(hotels)) |> 
  view()

# remove duplicates
hotels <- hotels |> 
  filter(!duplicated(hotels))

## 
# Quick glance at prices per night:
hist(hotels$price_per_night)

# Would it be cheaper to stay at a hostel?
hostels <- hotels |>
  filter(acc_type == 'Hostel')
hist(hostels$price_per_night)

summary(hotels$price_per_night)
summary(hostels$price_per_night)

## 3) Limit our data to hotels that fit our criteria -------------------------------------------------------
# date: 2017 November, not in the weekend
# we only care about hotels
# with at least 3 star ratings
# below 500 EUR/night

# Step 1: keep weekday hotel prices for November 2017, below 500, with 3-5 stars
hotels_main <- filter(hotels,
                      year == 2017,
                      month == 11,
                      weekend == 0,
                      acc_type == 'Hotel',
                      price_per_night < 500,
                      starrating >= 3)

view(hotels_main)

# Step 2: remove variables that are now the same for every row
hotels_main <- select(hotels_main, -year, -month, -weekend, -acc_type)

# Step 4: sort from best to worst 
hotels_main <- arrange(hotels_main, price_per_night, desc(ratings), desc(starrating), distance)
view(hotels_main)

# Save the main sample in a csv
write_csv(hotels_main, 'data/hotels_amsterdam_main.csv')
