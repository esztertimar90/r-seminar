# ------------------------------------------------------------------------------
# Import data, wide and long format
# based on
#   - Ágoston Reguly, Gábor Békés: Introduction to Data Analysis with R - lecture materials
#
## cleaning the environment ----------------------------------------------------
rm(list = ls())

## packages/libraries ----------------------------------------------------------
# load packages
library(tidyverse)

## 1) case study: football managers --------------------------------------------
# story: managers with more experience (games) have more points?
# points: win (3), draw (1), lose (0)
# long/wide format and data merging
# clean the environment
rm(list = ls())

# working directory, paths
getwd() # your working directory: this is where you are "standing" in your folder structure
setwd('/Users/martinneubrandt/Library/CloudStorage/Dropbox/GitHub/corvinus_econometrics') # change the working directory

# import data
# set data input paths
games_path <- 'data/football_managers/'
points_url <- 'https://raw.githubusercontent.com/gabors-data-analysis/da-coding-rstats/main/lecture03-tibbles/data/'

games <- read_csv(paste0(games_path, 'games.csv'))
points <- read_csv(paste0(points_url, 'points.csv'))

# transform to tidy data: long format
# first we need a new variable, which contains the team names
team_names = games |> 
  select(-manager_id, -manager_name) |> # exclude the first two columns (manager id and name)
  names() # get the names of the remaining columns

# use team names for transformation to long format
tidy_games <- pivot_longer(data = games, 
                           cols = team_names,
                           names_to = 'team',
                           values_to = 'manager_games')

# clean missing values
tidy_games <- tidy_games |> 
  filter(!is.na(manager_games))

# transform to wide format (from tidy to non-tidy format)
wide_games <- pivot_wider(data = tidy_games, 
                          names_from = team, 
                          values_from = manager_games)

# merge the two data sets
# left join:
# - keeps all observations from the left data set (x) (now: games)
# - adds observations from the right data set (y) (points) where the keys match
# - if there is no match, the new variables are filled with NA
games_points_left <- left_join(x = tidy_games,
                               y = points,
                               by = c('team', 'manager_id', 'manager_name'))
# right join:
# - keeps all observations from the right data set (y) (now: points)
# - adds observations from the left data set (x) (games) where the keys match
# - if there is no match, the new variables are filled with NA
games_points_right <- right_join(x = tidy_games,
                                 y = points,
                                 by = c('team', 'manager_id', 'manager_name'))

# full join:
# - keeps all observations from both data sets
# - adds observations where the keys match
# - if there is no match, the new variables are filled with NA
games_points_full <- full_join(x = tidy_games,
                               y = points,
                               by = c('team', 'manager_id', 'manager_name'))

# inner join:
# - keeps only the observations where the keys match in both data sets
games_points_inner <- inner_join(tidy_games,
                                 points,
                                 by = c('team', 'manager_id', 'manager_name'))

# Importance of the key-variables or identifiers:
# No unique identifier: create multiple new variables and observations
no_unique <- left_join(x = tidy_games,
                       y = points,
                       by = c('team'))

# Unique identifier, but unmatched variable with the same name: create (separate) new variables
unmatched_variable <- left_join(x = tidy_games,
                                y = points,
                                by = c('team','manager_id'))

# aggregate to manager level
manager_level <- games_points_inner |> 
  group_by(manager_name, manager_id) |> 
  summarise(num_teams = n_distinct(team),
            total_games = sum(manager_games),
            total_points = sum(manager_points),
            avg_points_per_game = round(total_points/total_games, 2)) |> 
  arrange(manager_id)

# plot total points and number of games by managers
manager_level |> 
  ggplot(aes(x = total_games,
             y = total_points)) +
  geom_point() +
  geom_smooth(method = 'lm')

# plot average points and number of games by managers
manager_level |> 
  ggplot(aes(x = total_games,
             y = avg_points_per_game)) +
  geom_point() +
  geom_smooth(method = 'lm')

# transform number of teams to a factor variable, categories: 1, 2, 3+
manager_level <- manager_level |> 
  mutate(num_teams = factor(ifelse(num_teams == 1, '1',
                                   ifelse(num_teams == 2, '2', '3+')),
                            levels = c('1', '2', '3+')))

# scatter plot about the average points and number of games
# colour by number of teams managed, add labels, and change some elements in the theme
manager_level |> 
  ggplot(aes(x = total_games,
             y = avg_points_per_game)) +
  geom_point(aes(color = num_teams),
             size = 5,
             alpha = 0.7) +
  geom_smooth(method = 'lm', 
              se = FALSE, 
              color = 'black',
              linetype = 'dashed',
              size = 1) +
  labs(title = 'Average points per game vs. total games of football managers',
       x = 'Total games',
       y = 'Average points per game',
       color = 'Number of teams managed') +
  theme_minimal() +
  theme(text = element_text(size = 18),
        legend.position = 'top')

# save the figure
ggsave(filename = 'manager_points.png',
       path = 'output/figure/',
       width = 10,
       height = 6)