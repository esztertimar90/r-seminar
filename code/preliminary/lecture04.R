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

# load packages
library(writexl)
library(tidyverse)

# set working directory
# here you have to write your OWN working directory
setwd('/Users/martinneubrandt/Dropbox/GitHub/corvinus_econometrics')

## 1) case study: hotels  ------------------------------------------------------
# story: You want to analyse hotels in Vienna, Austria
# import raw data: hotels-europe
# includes information on price and features of hotels in 46 European cities and for 10 different dates
raw_hotels <- read_csv('data/hotels_vienna/hotels-europe.csv')

# check the data
glimpse(raw_hotels)

# summary statistics
summary(raw_hotels)

# create a new dataset and keep only the relevant observations and variables
hotels <- raw_hotels |> 
  filter(s_city == 'Vienna') |> 
  select(center1distance,
         price, price_night,
         starrating,
         accommodationtype,
         guestreviewsrating,
         hotel_id,
         offer, offer_cat,
         year, month, weekend, holiday)

# optional: remove raw file to save memory
rm(raw_hotels)

# ALTERNATIVE: load only the relevant part of the data (without loading the whole raw data)
hotels <- read_csv('data/hotels_vienna/hotels-europe.csv') |> 
  filter(s_city == 'Vienna') |> 
  select(center1distance,
         price, price_night,
         starrating,
         accommodationtype,
         guestreviewsrating,
         hotel_id,
         offer, offer_cat,
         year, month, weekend, holiday)

## 2) data cleaning ------------------------------------------------------------
# clean price
# gsub: search for matches in the data for a pattern and replace it with something
# regular expression (regex): a formal language used to describe patterns in text
#   - we have to put into string quotes
#   - []: match any character from this set
#   - ^: negation, so match any character, except in the set
#   - 0-9: any digit from 0 to 9
hotels <- hotels |> 
  mutate(
    nights = as.numeric(
      gsub(
        pattern = '[^0-9]',
        x = price_night,
        replacement = '')),
    price_per_night = price/nights
  ) |> 
  select(-price_night, -price) # remove the raw variables, we don't need them anymore

# clean accomodation type: it is a string with a clear separator '@'
hotels <- hotels |> 
  separate(col = accommodationtype,
           sep = '@',
           into = c('junk', 'acc_type')) |> # separate accommodation type into two variables
  select(-junk) |> # remove the junk variable 
  mutate(acc_type = factor(acc_type)) # convert to factor

# clean distance variables
  # using regex
  #   - \\.: a dot symbol:
  #     - in plain regex a simple dot, would mean "any character"
  #     - to make it mean a literal dot (decimal point), we escape it with a backslash: \
  #     - BUT in R strings, \ itself is a special escape character (e.g. "\n" = newline).
  #     - to pass a literal backslash to regex, you need to double it: \\.
  hotels <- hotels |>
    mutate( 
      distance = as.numeric(
        gsub(
          pattern = '[^0-9\\.]',
          replacement = '',
          x = center1distance)
      )
    )|> 
    select(-center1distance)
  
  # using separate function
  hotels <- hotels |> 
    separate(center1distance,
             sep = ' ',
             into = c('distance', 'unit')) |> # separate distance into two variables
    select(-unit) |> # remove the unit variable
    mutate(distance = as.numeric(distance)) # convert to numeric

# clean guest rating: character with a clear separator '/'
hotels <- hotels %>%
  separate(guestreviewsrating,
           sep = '/',
           into = c('ratings') # if you set only one variable name, it takes only the part until the separator
  ) |> 
  mutate(ratings = as.numeric(ratings)) # convert to numeric 

# can we drop the NA values?
na_ratings <- hotels |> 
  filter(is.na(ratings))

not_na_ratings <- hotels |> 
  filter(!is.na(ratings))

table(na_ratings$acc_type)
table(not_na_ratings$acc_type)

hist(na_ratings$price_per_night)
hist(not_na_ratings$price_per_night)

summary(na_ratings$price_per_night)
summary(not_na_ratings$price_per_night)

# check duplicates
sum(duplicated(hotels))
hotels |> 
  filter(duplicated(hotels)) |> 
  view()

# remove duplicates
hotels <- hotels |> 
  filter(!duplicated(hotels))

## 3) create main sample -------------------------------------------------------
# date: 2017 November, not in the weekend
# we only care about hotels
# with at least 3 stars
# below 500 EUR/night
hotels_main <- hotels |> 
  mutate(
    starrating = ifelse(starrating == 3.5, 3, starrating),
    starrating = ifelse(starrating == 4.5, 4, starrating),
    starrating = factor(starrating,
                        levels = c(3, 4, 5)) 
  ) |> # recode starrating
  filter(
    year == 2017,
    month == 11,
    weekend == 0,
    acc_type == 'Hotel',
    price_per_night < 500,
    starrating %in% c(3, 4, 5)
    ) |>
  select(-year, -month, -weekend, -acc_type) |> # remove redundant variables
  mutate(
    distance = -distance
  ) |> 
  arrange(price_per_night) # arrange by price

# save the main sample in a csv
write_csv(hotels_main, 'data/hotels_vienna/hotels_vienna_main.csv')
