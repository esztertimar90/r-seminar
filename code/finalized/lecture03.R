# ------------------------------------------------------------------------------
# Joining and merging data #
# Session 3 - 28 September 
# written by Eszter Timar 
# ------------------------------------------------------------------------------
## cleaning the environment ----------------------------------------------------
rm(list = ls())

## packages/libraries ----------------------------------------------------------
# load packages
install.packages("tidyverse")
library(tidyverse)

## 1) case study: football managers --------------------------------------------
# story: managers with more experience (games) have more points?
# points: win (3), draw (1), lose (0)
# long/wide format and data merging
# clean the environment
rm(list = ls())

# working directory, paths
getwd() # your working directory: this is where you are "standing" in your folder structure
setwd('/Users/esztertimar/Teaching/Econometrics R Seminar 2026-27') # change the working directory

# We will use a case study on how to identify successful football managers based on their experience (number of games) and their performance (points). 
# The data is available in two separate files: games.csv and points.csv. 
# We will import, clean, transform, and merge these datasets to analyze the relationship between experience and performance.

# import data
games <- read_csv('data/games.csv')
points <- read_csv('data/points.csv')

# clean missing values
games <- filter(games, !is.na(manager_games))
points <- filter(points, !is.na(manager_points))

view(games)
view(points)

# How do we define manager success?
# Let's take the average points per game. 
# We need to create one data set that contains the number of games and points for each manager.

# merge the two data sets: called "join" in R language 
# there are different types of joins: left join, right join, full join, inner join

# left join:
# - keeps all observations from the left data set (x) (now: games) (1:m in STATA)
# - adds observations from the right data set (y) (points) where the keys match
# - if there is no match, the new variables are filled with NA
games_points_left <- left_join(x = games,
                               y = points,
                               by = c('team', 'manager_id', 'manager_name'))
view(games_points_left)

# right join:
# - keeps all observations from the right data set (y) (now: points) (m:1 in STATA)
# - adds observations from the left data set (x) (games) where the keys match
# - if there is no match, the new variables are filled with NA
games_points_right <- right_join(x = games,
                                 y = points,
                                 by = c('team', 'manager_id', 'manager_name'))
view(games_points_right)

all.equal(games_points_left, games_points_right)  # they are not equal because the two data sets have different number of observations

# full join: 
# - keeps all observations from both data sets (m:m in STATA)
# - adds observations where the keys match
# - if there is no match, the new variables are filled with NA
games_points_full <- full_join(x = games,
                               y = points,
                               by = c('team', 'manager_id', 'manager_name'))

# inner join:
# - keeps only the observations where the keys match in both data sets (1:1 in STATA)
games_points_inner <- inner_join(games,
                                 points,
                                 by = c('team', 'manager_id', 'manager_name'))

# anti-join keeps observations with no match - we rarely need this
games_points_anti <- anti_join(x = games,
                                y = points,
                                by = c('team', 'manager_id', 'manager_name'))
print(games_points_anti$manager_name) # managers with no points

# Importance of the key-variables or identifiers:
# What happens if we don't have a unique ID? Let's try without naming managers:

# No unique identifier: create multiple new variables and observations
no_unique <- left_join(x = games,
                       y = points,
                       by = c('team'))

# We proceed with the inner-joined data because it does not have missing values: 
view(games_points_inner) 

# Plot points and games per manager:
ggplot(games_points_inner, aes(x = manager_games, y = manager_points)) +
  geom_point(stat = 'identity', fill = 'steelblue') +
  theme_minimal() +
  labs(title = 'Points vs Games per Manager',
       x = 'Number of Games',
       y = 'Number of Points')

# We need to calculate average score by manager (some managers switched teams)
manager_avg <- games_points_inner |>
  group_by(manager_id) |>
  summarise(avg_points = sum(manager_points) / sum(manager_games)) 

  # this introduces us to |> a.k.a. the pipe operator
  # |> means "and then" and links together multiple operations
  # Command above means:
  # create an object called manager_avg by looking at 'game_points inner',
  # and then grouping the data by the managers' ID,
  # and then creating an object from their total points divided by total games.

head(manager_avg)

# Let's add the manager averages as a new column to our tibble:
football <- left_join(x = games_points_inner,
                                y = manager_avg,
                                by = c('manager_id'))

# We can sort the data based on the average points:
football
football <- football |>
          arrange(-avg_points)
summary(football$avg_points)

view(football)

ggplot(manager_avg, aes(x = reorder(manager_id, avg_points), y = avg_points)) +
  geom_col(fill = 'steelblue') +
  theme_minimal() +
  labs(title = 'Average Points per Game by Manager',
       x = 'Manager ID',
       y = 'Average Points per Game') +
  theme(axis.text.x = element_blank())

ggsave('graphs/manager_scores.png')

# So who is the winner? 'Slice' and 'Pull' functions helps us find him:
football |>
  slice_max(avg_points, n = 1, with_ties = TRUE) |>
  pull(manager_name, team)

# And the worst performers:
football |>
  slice_min(avg_points, n = 1, with_ties = TRUE) |>
  pull(manager_name, team)