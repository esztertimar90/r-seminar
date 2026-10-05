########## R CODING SEMINAR (ECONOMETRICS) #########
# SESSION 4: DATA EXPLORATION AND INTRO TO GGPLOT #
## ---------------------------------------------- ##
getwd()
#setwd('your directory path') # set your working directory path here

# Remove variables from the memory
rm(list=ls())

# Call packages
# run once, then comment out:
# install.packages("tidyverse")
# install.packages("modelsummary")
library(tidyverse)
library(modelsummary)

### Our data today is about online and offline prices of products
# We are interested in whether the two prices differ
## Import data
bpp_orig <- read_csv('https://osf.io/yhbr5/download')

# Export data for safekeeping
write_csv(bpp_orig, 'data/bpp_orig.csv')

# Check the variables
glimpse(bpp_orig)

## Create our key variable: price differences
bpp_orig <- mutate(bpp_orig, p_diff = price_online - price)

####
## DESCRIPTIVE STATISTICS
#
# Check all the variables in tibble by a quick built-in summary statistics
  # Note: this is from modelsummary package
datasummary_skim(bpp_orig)
# alternatively - base R command: 
summary(bpp_orig)

# Get a better idea about the key variables:
# use `datasummary()` function:
# datasummary(in_rows ~ in_columns, data = df), 
#   where in_rows OR in_columns are variables and the other is a descriptive function
datasummary(price + price_online + p_diff ~ 
               Mean + Median + SD + Min + Max + P25 + P75 + N + PercentMissing, 
             data = bpp_orig)

# Or put the descriptives into rows and variables into columns:
datasummary(Mean + Median + SD + Min + Max + P25 + P75 + N + PercentMissing ~
               price + price_online + p_diff, 
             data = bpp_orig)
##
# next let us check the price differences for each countries.
# here comes 'factor' variables into picture:

# lets create a new variable country_f which is a factor variable:
bpp_orig <- mutate(bpp_orig, country_f = factor(COUNTRY))

# With datasummary it is super easy to check, we only need to use '*'
# always make sure one of the variable is factor!
datasummary(country_f * p_diff ~ Mean + Median, data = bpp_orig)
  # meaning: for each country (rows) show the mean and median of price differences (columns)

# Lets say we are interested in the prices as well for each countries.
# In this case we need to use parenthesis in a clever way:
#   for each country show the differences and levels
datasummary(country_f * (p_diff + price + price_online) ~ Mean + Median, data = bpp_orig)
  # meaning: for each country (rows) show the mean and median of price differences, prices and online prices (columns)

# for each variable, show the different countries:
datasummary((country_f * p_diff) + (country_f * price ) ~ Mean + Median, data = bpp_orig)
# datasummary has a pretty complex syntax with many options, use ?datasummary 
?datasummary

##
# Task
# 1) filter the data to 2016 and check price difference the mean and median for each country
#
datasummary(country_f * p_diff ~ Mean + Median, 
             data = filter(bpp_orig, year == 2016))

##################
## VISUALIZATION
# the ggplot
#   ggplot always has a `ggplot()` function and a geom_*type*() function added.
#     ggplot is awesome, as you can add multiple objects, easily.
#     for some historical reasons, ggplot uses '+' sign instead of '|>' or '%>%' 
#     to add new commands/objects to the graph 


# Check the empirical distribution:  histogram.
#   simple - built in histogram with `geom_histogram()`
ggplot(data = bpp_orig) +
  geom_histogram(aes(x = price), fill = 'navyblue') +
  labs(x = 'Price',
       y = 'Count')
# Lets just ignore the warning, we will discuss it later!

##
# It is clear: need to filter out some data
# FILTER DATA -> filter for 'PRICETYPE' is a too large restriction!
#     may check without that filter!
bpp <- bpp_orig |>  
  filter(is.na(sale_online)) |>
  filter(!is.na(price)) |>
  filter(!is.na(price_online)) |> 
  filter(PRICETYPE == 'Regular Price')

# Check our newly created data:
datasummary(price + price_online + p_diff ~ 
               Mean + Median + SD + Min + Max + P25 + P75 + N, 
             data = bpp)

# Drop obvious errors: price is larger than $1000
bpp <- bpp |> 
  filter(price < 1000)

# Check again our datatable:
datasummary(price + price_online + p_diff ~ 
               Mean + Median + SD + Min + Max + P25 + P75 + N, 
             data = bpp)

# Histogram for filtered data
ggplot(data = bpp) +
  geom_histogram(aes(x = price), fill = 'navyblue') +
  labs(x = 'Price',
       y = 'Count')

##
# Role of number of bins (or binwidth)

# Play with the number of Bins:
# 1) approx ok
ggplot(data = bpp) +
  geom_histogram(aes(x = price), fill = 'navyblue',
                  bins = 50) +
  labs(x = 'Price',
       y = 'Count')

# 2) too many
ggplot(data = bpp) +
  geom_histogram(aes(x = price), fill = 'navyblue',
                  bins = 150) +
  labs(x = 'Price',
       y = 'Count')

# 3) too few
ggplot(data = bpp) +
  geom_histogram(aes(x = price), fill = 'navyblue',
                  bins = 5) +
  labs(x = 'Price',
       y = 'Count')

##
# TASK: Play with the binwidth - instead of `bins=`, use `binwidth=`
##

##
# Relation: they are inversely proportional

##
# Count vs. Relative Frequency
#   until now we have used count (counted the number of observations in each bin)
#   the other possibility is to use relative frequency instead:
# you need to add `y = after_stat(density)` to the aesthetics:
ggplot(data = bpp) +
  geom_histogram(aes( y = after_stat(density), x = price), fill = 'navyblue',
                  bins = 50) +
  labs(x = 'Price',
       y = 'Relative Frequency')


##
# Kernel density
#
# Histogram or kernel density? Kernel is the smooth line instead of using bars.
# Now, let us name our ggplot:
my_graph <- ggplot(data = bpp) +
            geom_density(aes(x = price), color = 'red', bw = 20) +
            labs(x = 'Price',
                 y = 'Relative Frequency')

# to make it visible we need to call it
my_graph

# Cool stuff about ggplot, is that we can add (later as well) new geometric object to it.
# e.g. we can add a histogram:
my_graph + geom_histogram(aes( y = after_stat(density), x = price), fill = 'navyblue', 
                           alpha = 0.4, binwidth = 20)
# note alpha governs the opaqueness of the object

###
# Task
#   1) Do the same kernel density and histogram, but now with the price differences
#   2) Add xlim(-5,5) command to ggplot! What changed?
ggplot(data = bpp) +
  geom_density(aes(x = p_diff), color = 'red', fill = 'red', alpha = 0.2, bw = 0.2) +
  geom_histogram(aes( y = after_stat(density), x = p_diff), fill = 'navyblue', 
                  alpha = 0.4, binwidth = 0.2) +
  labs(x = 'Price Differences' ,
        y = 'Relative Frequency') +
  xlim(-5, 5)


# Check for price differences
chck <- bpp |> filter(p_diff > 500 | p_diff < -500)
# Drop them
bpp <- bpp |> filter(p_diff < 500 & p_diff > -500)
rm(chck)

###
# Comparing different countries via graphs

# Create ggplot for each countries - histogram:
# Note: 
#   1) if you only use one type of x or y, you can put it into the `aes()` of the ggplot. Otherwise not.
#   2) use 'fill=' in `aes()`, to define different groups. 

ggplot(data = bpp, aes(x = p_diff, fill = country_f)) +
  geom_histogram(aes(y = after_stat(density)), alpha =0.4, bins = 15) +
  labs(x = 'Price', y = 'Relative Frequency' ,
        fill = 'Country') +
  xlim(-4,4)


# 2) Use the extra command `facet_wrap(~country_f)` to create multiple plots for each country at once!

ggplot(data = bpp, aes(x = p_diff, fill = country_f)) +
  geom_histogram(aes(y = after_stat(density)), alpha =0.4, bins = 15) +
  labs(x = 'Price', y = 'Relative Frequency' ,
        fill = 'Country') +
  facet_wrap(~country_f)+
  xlim(-4,4)

###
# Task 2)
# 1) Do the same, but use geom_density instead of geom_histogram!
#     You may play around with the xlim!
# 2) Drop the `facet_wrap` command! What happens? Which graph would you use to tell your story in this case?
# What if instead of `fill` you use `color`?

# 1) Density with multiple graphs
ggplot(data = bpp, aes(x = p_diff, fill = country_f)) +
  geom_density(aes(y = after_stat(density)), alpha =0.4) +
  labs(x = 'Price', y = 'Relative Frequency' ,
        fill = 'Country') +
  facet_wrap(~country_f)+
  xlim(-1,1)

# 2) Density in a single graph, groups by color:
ggplot(data = bpp, aes(x = p_diff, color = country_f)) +
  geom_density(alpha =0.4) +
  labs(x = 'Price', y = 'Relative Frequency' ,
        color = 'Country') +
  xlim(-1,1)

# Which graph tells the story best?

####
# ASSOCIATON
#   relation between two variables

# Association between online and retail prices: geom_point() will add dots to the graph
ggplot(bpp, aes(x = price_online, y = price))+
  geom_point(color = 'red')+
  labs(x = 'Price online', y = 'Price retail')

# You can add a line (regression line to be specific), 
#   by `geom_smooth()` function. It is a great function, 
#     we now focus on `method=lm` which says it is a linear relation (linear model) 
#     and formula, which identifies y and x. You will discuss this more in the lectures.
ggplot(bpp, aes(x = price_online, y = price))+
  geom_point(color = 'red')+
  labs(x = 'Price online', y = 'Price retail')+
  geom_smooth(method = 'lm',formula = y ~ x, color = 'blue')

##
# Bin-scatter:
#
# in many case there are too many observations for a simple graph 
#   and it does not tells the story we would like to.
# One solution is to do a `bin-scatter`, which put observations into bins.
#   The simplest way to do is use 'equal distances': cut x-variable's range into k equally sized bins
#     and then calculate the same observations' y-variable e.g. mean (or median).
#     - this is great: simple and intuitive (similar to histogram),
#       BUT it hides, how many observations are in each bin. 
#         E.g. it can happen in the lowest valued bin there are many observations 
#             and in the highest there is only one.
#
#   The second option is use the same number of observations in each bin. 
#     This will ensure that no such problem will rise. On the other hand it is harder to compute, 
#     and the width of the bins will vary along x.

# Bin-scatter
# 1) 'easy way': using equal distances and calculate mean for y
#   use `stat_summary_bin()`
ggplot(bpp, aes(x = price_online, y = price))+
  stat_summary_bin(fun = 'mean', bins = 10, 
                    geom = 'point', color = 'red',
                    size = 2)

# 2) 'easy way': using equal distances
#   group by countries, explain facet_wrap additional inputs!
ggplot(bpp, aes(x = price_online, y = price ,
                   color = country_f))+
  stat_summary_bin(fun = 'mean', bins = 10, 
                    geom = 'point',  size = 2) +
  labs(x = 'Price online', y = 'Price offline', 
        color = 'Country') +
  facet_wrap(~country_f,scales = 'free',ncol = 2)+
  theme(legend.position = 'none')+
  geom_smooth(method='lm',formula = y~x, se=F)

#####
# Correlation and plots with factors
#
# Often we would like to measure an association:
# covariance and correlation for mean-dependence

# Covariance
cov(bpp$price, bpp$price_online)

##
# Task:
# Check if it is symmetric!

# Correlation
cor(bpp$price, bpp$price_online)

# What does this tell us?

##
# Make a correlation table, including correlation for each country
corr_table <- bpp |> 
  select(country_f, price, price_online) |> 
  group_by(country_f) |> 
  summarise(correlation = cor(price,price_online))

corr_table

# We can also export the correlation tables
  # Hint: these functions will be useful for your group projects!
# 1) plain csv - the universal format, opens anywhere
write_csv(corr_table, 'output/corr_by_country.csv')

# 2) Excel - writexl was installed in session 3
# install.packages('writexl')
library(writexl)
writexl::write_xlsx(corr_table, 'output/corr_by_country.xlsx')

# 3) a formatted table straight into Word (or .html / .tex / .md)
install.packages('pandoc')
library(pandoc)
datasummary_df(corr_table, output = 'output/corr_by_country.docx',
               fmt = 3, title = 'Correlation of online and offline prices by country')

# Graph to show the correlation pattern by each country:
# fct_reorder will reorder the countries by their correlation
corrgraph <- ggplot(corr_table, aes(x = correlation ,
                          y = fct_reorder(country_f, correlation))) +
  geom_point(color = 'red', size = 2)+
  labs(y='Countries',x='Correlation')

corrgraph
ggsave('graphs/corrgraph.png', corrgraph, width = 6, height = 4, dpi = 300)

#### BASIC HYPOTHESIS TESTING
# We can also test hypotheses in R. 
# Let's test the following: on average, there is no difference in prices.
# What is our hypothesis? 
# H0: mean(p_diff) = 0, H1: mean(p_diff) != 0
t.test(bpp$p_diff, mu = 0)

t.test(bpp$price_online, bpp$price, paired = TRUE)

# Is this a one-sided or two sided-test? What is the p-value?  


