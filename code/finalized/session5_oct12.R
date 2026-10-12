########## R CODING SEMINAR (ECONOMETRICS) #########
# SESSION 5: GGPLOT In-depth #
# Based on: Chapter 1 and 9 in H. Wickham: Data Science with R (2016) #
## ---------------------------------------------- ##
getwd()

#Install and load packages:
install.packages("tidyverse")
install.packages("palmerpenguins")
install.packages("ggthemes")
library(tidyverse)
library(palmerpenguins)
library(ggthemes)

penguins <- palmerpenguins::penguins

#### Part 1. Understanding layers in ggplot ####

# Our goal: visualize therelationship between flipper lengths and body mass,
#  taking into consideration the species of the penguin.

ggplot(data = penguins)

# we need to add a mapping argument: how to visualize data

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
)

# we also need to add a geometry: how to visualize the data
# these are the 2 basic layers of a ggplot
# ... but there are many more!

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()

# What can we tell about the relationship at this point?
# Can there be any confounding factors or additional variables to consider?

# Let's see if the relationship differs by species
# We add a color argument to the mapping layer

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point()

# What does this tell us?

# We can add multiple geom layers to a single graph: 
# Draw the line of best fit based on a linear regression model
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  geom_smooth(method = "lm")

# Now compare it with this solution:
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")

# If the color argument is in the mapping layer, it applies to all layers. 
# If it is in a specific geom layer, it only applies to that layer.
# But subsequent layers can overwrite each other.

# It is not a good idea to use color to carry important information.
# Many people have difficulty with color or print in black and white.
# What can we do to make the graph more accessible?

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")

# Let's add some labels with the labs() function
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) +
  scale_color_colorblind()

# We can write ggplot commands a bit more concisely:
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point()
    # we don't need to type out data = and mapping = every time.

# data = penguins can just be penguins 
# or we can use |> to pipe the data into ggplot:
penguins |>
  ggplot(aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()

#### Part 2. Distributions ####
# Bar chart for frequencies of a categorical/factor variable:
ggplot(penguins, aes(x = species)) +
  geom_bar()

# To order the bars by frequency:
ggplot(penguins, aes(x = fct_infreq(species))) +
  geom_bar()

# Histogram for a continuous variable:
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200)

# Density plot:
ggplot(penguins, aes(x = body_mass_g)) +
  geom_density()

ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.75)

ggplot(penguins, aes(x = body_mass_g, fill = species)) +
  geom_density(alpha = 0.5, linewidth = 0.75)

ggplot(penguins, aes(x = species)) +
  geom_bar(color = "red")

ggplot(penguins, aes(x = species)) +
  geom_bar(fill = "red")

ggplot(penguins, aes(x = species)) +
  geom_bar(fill = "red", color = "black")

# Box plot for a continuous variable by a categorical variable:

ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot()

# We can layer different geoms on top of each other:
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot(fill = "lightblue", color = "black") +
  geom_jitter(width = 0.1, alpha = 0.5) +
  labs(x = "Species", y = "Body mass (g)")

### IN-CLASS TASK:
mpg <- mpg  
head(mpg)

# displ = engine displacement (in litres)
# hwy = highway miles per gallon
# class = type of car (e.g., compact, SUV, etc.)

# Visualize the relationship between displ and hwy, taking into consideration the class of the car.
# Add axis labels and give your graph a title.
# Save it into your graphs folder.

# Solution: 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Highway MPG vs Engine Displacement",
    x = "Engine Displacement (litres)",
    y = "Highway Miles per Gallon",
    color = "Car Class"
  ) 

# Faceting: 
# let's return to the penguins data
# do you remember what faceting does? 
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point(aes(color = species)) + 
  facet_wrap(~species)

# Facet grids:

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species)) +
  facet_grid(sex ~ species)

# Statistical transformations: 

# let's take another dataset: diamonds
diamonds <- diamonds

# tell R to make a bar chart of the cut variable in the diamonds dataset
ggplot(diamonds, aes(x = cut)) + 
  geom_bar()

# x axis is cut, y axis is count - where is that coming from? not a var in our dataset!
diamonds
# many geoms, like a bar chart, plot calculated stats from your data
# they differ in what is the standard statistical transformation applied to the data.
# to check: 
?geom_bar()

# We may want to show the mean value of a variable over a category
# e.g. average price per type of cut.
# we can do this by overriding the standard statistical transformation applied to the geom_bar() function:
ggplot(diamonds, aes(x = cut, y = price)) +
  geom_bar(stat = "summary", fun = "mean")

# let's add some color to it: 
ggplot(diamonds, aes(x = cut, y = price, fill = cut)) +
  geom_bar(stat = "summary", fun = "mean")

# drop the legend:
ggplot(diamonds, aes(x = cut, y = price, fill = cut)) +
  geom_bar(stat = "summary", fun = "mean") +
  theme(legend.position = "none")

# sort by price from smallest to largest:
ggplot(diamonds, aes(x = fct_reorder(cut, price), y = price, fill = cut)) +
  geom_bar(stat = "summary", fun = "mean") +
  theme(legend.position = "none")

# Use AI to make your figures nicer and help you with ggplot code. 
# Student Developer Pack will give you access to GitHub Copilot, which you can integrate into RStudio.