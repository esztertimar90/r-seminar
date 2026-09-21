########## R CODING SEMINAR (ECONOMETRICS) #########
# SESSION 1: GETTING FAMILIAR WITH R AND RSTUDIO
## ---------------------------------------------- ##

## Housekeeping -------------------------------------------------------
# Use this only if you want to reset the workspace
rm(list = ls())

## Packages/libraries ----------------------------------------------------------
# Run once when you first install packages:
install.packages('tidyverse')
install.packages('wooldridge')

# load packages
library(tidyverse)
library(wooldridge)

## 1) Objects and variables ----------------------------------------------------
# everything in R is an object

# we can define numeric objects:
a <- 2
b <- 3
c <- a * b

# do mathematical operations with them:
a + b
a + b - (a * b) ^ a

# store a result as an object:
d <- a + b
d

# operations with logical expressions:
a == b     
A == a
  # line does not run because R is case-sensitive: we have "a" but not "A"
a != b
equality <- a == b
a == a
1/2 == 0.5

# negation:
a != b

# other logical operators for multiple statements
2 == 2 & 3 == 3  # and
2 == 2 | 3 == 2  # either/or

# Boolean objects:
male <- TRUE
female <- FALSE

# objects can be character strings --------------------------------------------------------
mystring <- "Hello"
mystring

## 3) Functions ---------------------------------------------------------------
# R has many built-in functions, standard format is: name(input)
# remove object d: 
rm(d)
# Have we seen the rm function before?

# mathematical functions:
sqrt(4)
  # is the same as typing:
  4^(1/2)

sum(c(1, 2, 3))
  # is the same as typing: 
  1 + 2 + 3

typeof(male)

typeof(mystring)

# get help with a function: (see the help window pop up in the right pane)
?sqrt

## 4) Vectors -----------------------------------------------------------------
# we can combine multiple numeric values into a vector --> it will have multiple values
v <- c(2, 5, 10, 13)
z <- c(3, 4, 7, 10)

v
z

#we can use them for vector operations:
z + v
v * z

#Q: how do we store the result as an object?

  #rules: same number of elements
  #we can use functions with vectors:

length(v)
sum(v)
mean(v)

#Q: how can we check if the number of elements in z and v is the same, using a logical operator?


#what happens otherwise? let's define a shorter vector q:
q <- c(2, 3)

q+v

#Q: how did R solve the problem?

# Indexing: select an element from a vector (or matrix) using [ ] brackets
v[1]

v[2:4]

v[c(1, 3)]

#you can even define an "indexing vector":
ind_vec <- c(1,3)
v[ind_vec]


## 5) Matrices -----------------------------------------------------------------
M <- matrix(c(1, 2, 3, 4), ncol = 2)
M
M[1, 2]

dim(M)
head(M)

## 6) Special variables/values ---------------------------------------------
# empty variable:
null_var <- c()
null_vector <- c()

# missing value: NA ("not available" / unknown value)
# you will encounter and have to deal with NAs when working with real data!
na_vec <- c(NA,1,2,3,4)
na_vec + 3

is.na(na_vec)

  #Q: How can we check specifically if the 1st item in the vector is NA?

mean(na_vec)
mean(na_vec, na.rm = TRUE)

# special values
nan_vector <- c(NaN, 1, 2, 3)
inf_vector <- c(Inf, 1, 2, 3)

nan_vector
inf_vector

5/0
#when an operation does not have a value but converges to infinity at the limit

## 6) Data frames --------------------------------------------------------------
# this is the most important object for econometrics!
# clean out our environment first:
rm(list=ls())

df <- diamonds  # it loads a dataset that is part of the wooldridge package, no need to download it

str(df)

#Q: what is integer vs numeric?

head(df)
names(df)

# access a column with $
df$carat
mean(df$carat)
summary(df$carat)

## 8) Practice exercise -------------------------------------------------------
# 1. Create a vector of 5 numbers
# 2. Compute the mean
# 3. Store the result in an object called avg_x
# 4. Create a small data frame with two columns: name and score
# 5. Print the first few rows

#-------- FOR THE NEXT SESSION: REGISTER A GITHUB ACCOUNT! #--------------------
