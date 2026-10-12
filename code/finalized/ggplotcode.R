###########################################
## GGPLOT Seminar ## 
# Author: Eszter Timar 
# Date: 2026-10-12
# Last edit: 
###########################################

getwd()

install.packages("tidyverse")
install.packages("palmerpenguins")
install.packages("ggthemes")
library(tidyverse)
library(palmerpenguins)
library(ggthemes)

## Part 1. Understanding GGPLOT

penguins <- palmerpenguins::penguins

penguinplot <- ggplot(data = penguins,
mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(title = "Penguin body mass vs flipper length",
      x = "Flipper length (mm)",
      y = "Body mass (g)") +
  scale_color_colorblind() 

penguinplot
ggsave(filename = "penguinplot.png", plot = penguinplot)

## Part 2. Concise writing of ggplot commands 
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point() 

penguins |> 
  ggplot(aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()


# Part 3. Other types of charts 
ggplot(penguins, aes(x = fct_infreq(species))) +
  geom_bar()

ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(alpha = 0.5, linewidth = 0.5) 

ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot(fill = "lightblue", color = "black") + 
  geom_jitter(width = 0.1, alpha = 0.5) + 
  labs(x = "Species", y = "Body mass (g)")



mpg <- mpg 
head(mpg)

# displ = engine displacement (L)
# hwy = highway miles per gallon
# class = type of car (suv, compact, etc.)

# Visualize the relationship between displ and hwy 
# Take into account class/type of car 
# Add axis labels and a title 

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(method = "lm") +
  labs(title = "Engine Displacement vs Highway MPG",
       x = "Engine Displacement (L)",
       y = "Highway Miles per Gallon (MPG)",
       color = "Car Class") 

ggsave("myplot.png")

## Part 4. Faceting 
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species)) + 
  facet_grid(sex ~ species)

## Part 5. Statistical transformations
diamonds <- diamonds 

ggplot(diamonds, aes(x = cut, y = price, fill = cut)) +
  geom_bar(stat = "summary", fun = "mean")

?geom_bar()



