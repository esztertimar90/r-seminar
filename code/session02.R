# ==============================================================================
# Session 02 — A first case study, then tidy data and the pipe
# Econometrics seminar, Corvinus University, 2026-27
#
# Part 1 puts last week's basics to work on real data: what is the connection
#        between CEO salary and return on equity?
# Part 2 introduces the tidyverse tools that make part 1 much less painful.
#
# Reading: Heiss 1.3 (data frames and files), 1.5 (the tidyverse)
#          https://www.urfie.net/downloads/PDF/URfIE_web.pdf
#
# Based on
#   - Ágoston Reguly & Gábor Békés: Introduction to Data Analysis with R
#   - Wickham, Çetinkaya-Rundel & Grolemund: R for Data Science (2e)
# ==============================================================================

## Cleaning the environment ----------------------------------------------------
rm(list = ls())

## Packages --------------------------------------------------------------------
library(tidyverse)
library(wooldridge)


# ==============================================================================
# PART 1 — Case study: CEO salary and return on equity
# ==============================================================================
# Story: firms pay their CEOs a great deal. Is the pay related to how well the
# firm does? We use return on equity (ROE) as the measure of firm performance.
#
# The data comes with the wooldridge package: 209 US CEOs, 1990.
# salary is in thousands of dollars, roe is in per cent.
# ?ceosal1 gives the full variable list.

ceo <- ceosal1


## First look at the data ------------------------------------------------------
str(ceo)      # structure: variables, their types, first values
head(ceo)     # first six rows
summary(ceo)  # descriptive statistics of every variable
view(ceo)     # the whole table in a spreadsheet-like viewer

# Always look at your data before you analyse it. Every time.


## A first plot ----------------------------------------------------------------
# ggplot2 builds a plot in layers, added together with +
#   data     what to plot from
#   mapping  which variable goes on which axis (aes = aesthetics)
#   geom_*   what to actually draw
ggplot(data = ceo,
       mapping = aes(x = roe,
                     y = salary)) +
  geom_point()

# Run just the ggplot() call on its own first: you get an empty grey panel with
# axes. You have said what to plot and where, but not what to draw.


## Saving the "base" of a plot -------------------------------------------------
roe_salary_plot <- ggplot(data = ceo,
                          mapping = aes(x = roe,
                                        y = salary))

# Add a scatter plot and a fitted straight line to it.
roe_salary_plot +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x)

# Two or three firms pay far more than the rest, and they stretch the whole
# picture. Let us look at that properly.


## Looking for outliers --------------------------------------------------------
ggplot(data = ceo,
       mapping = aes(x = salary)) +
  geom_histogram(binwidth = 100) +
  scale_x_continuous(breaks = seq(0, 15000, by = 3000))

# The 99th percentile of salary:
quantile(ceo$salary, probs = 0.99)

# $ pulls one variable out of a data set as a vector.


## Dropping the outliers -------------------------------------------------------
# NOTE: this changes the data. Dropping observations is a decision you have to
# be able to defend, and you must say in your write-up that you did it.
cutoff <- quantile(ceo$salary, probs = 0.99)

nrow(ceo)                        # how many rows before?
ceo <- ceo[ceo$salary < cutoff, ]
nrow(ceo)                        # and after? always check.

# The [row, column] rule from last week: keep the rows where salary is below
# the cutoff, keep all columns. Part 2 shows a much more readable way.


## Creating a new variable -----------------------------------------------------
# The data has four 0/1 dummies for industry. One readable variable is nicer.
# ifelse(condition, value if TRUE, value if FALSE), nested three deep.
# with() lets you refer to the variables without writing ceo$ every time.
ceo$industry <- factor(
  with(ceo,
       ifelse(indus == 1, 'industrial',
              ifelse(finance == 1, 'financial',
                     ifelse(consprod == 1, 'consumer products',
                            'transport and utility'))))
)

table(ceo$industry)

# A factor is R's type for a categorical variable: values, plus a fixed set of
# allowed categories called levels.


## Rebuilding the plot with the new data ---------------------------------------
# The stored plot base still points at the OLD data, so build it again.
roe_salary_plot <- ggplot(data = ceo,
                          mapping = aes(x = roe,
                                        y = salary))

### Colour everything by industry ----------------------------------------------
# The colour is in the main mapping, so BOTH the points and the line split.
roe_salary_plot +
  aes(colour = industry) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x)

### Colour only the points -----------------------------------------------------
# The colour is inside geom_point(), so only the points split, and one line is
# fitted to all the data.
roe_salary_plot +
  geom_point(mapping = aes(colour = industry)) +
  geom_smooth(method = "lm", formula = y ~ x)

### Set a colour by hand -------------------------------------------------------
# colour INSIDE aes()  = "use this variable to decide the colour"
# colour OUTSIDE aes() = "make it this colour, full stop"
roe_salary_plot +
  geom_point(mapping = aes(colour = industry)) +
  geom_smooth(method = "lm", formula = y ~ x,
              colour = 'black')

### Label the axes -------------------------------------------------------------
# A plot without units on its axes cannot be read. Always add labs().
roe_salary_plot +
  geom_point(mapping = aes(colour = industry)) +
  geom_smooth(method = "lm", formula = y ~ x,
              colour = 'black') +
  labs(x = 'ROE (%)',
       y = 'Salary ($1000)',
       colour = 'Industry')


## From a working plot to a presentable one ------------------------------------
# Everything above is the analysis. Everything below is presentation: sizes,
# transparency, a title, a theme, a colour palette, nicer axis ticks.
#
# This is a good place to use an AI assistant: describe the plot you want in
# words and let it write the theme() and scale_*() lines. Then read what it
# produced and check that it did not change the DATA — only the appearance.
# Session 5 is entirely about this: how these tools help, how they fail, and
# how to check their work. Today is just a taste.
roe_salary_figure <- roe_salary_plot +
  geom_point(mapping = aes(colour = industry),
             size = 3,
             alpha = 0.7) +                      # alpha = transparency
  geom_smooth(method = "lm", formula = y ~ x,
              colour = 'black',
              linetype = 'dashed',
              linewidth = 1) +
  labs(title = 'CEO salary and return on equity',
       subtitle = '209 US firms, 1990, top 1% of salaries excluded',
       x = 'ROE (%)',
       y = 'Salary ($1000)',
       colour = '') +
  theme_minimal() +
  theme(text = element_text(size = 14),
        plot.title = element_text(hjust = 0.5, face = 'bold', size = 16),
        plot.subtitle = element_text(hjust = 0.5, size = 12),
        legend.position = 'top') +
  scale_colour_brewer(palette = 'Set1') +
  scale_x_continuous(breaks = seq(-20, 80, by = 10)) +
  scale_y_continuous(breaks = seq(0, 6000, by = 500))

roe_salary_figure


## Saving the figure -----------------------------------------------------------
ggsave(filename = 'ceo_salary_roe.png',
       plot = roe_salary_figure,
       path = 'output/figures/',
       width = 10,
       height = 6,
       dpi = 300)

# A relative path, and it works — because you opened the .Rproj file.


# >>> COMMIT CHECKPOINT 1 <<<


# ==============================================================================
# PART 2 — Tidy data, tibbles, and the pipe
# ==============================================================================
# Part 1 worked, but look back at what it cost:
#   ceo[ceo$salary < cutoff, ]     you have to count brackets and commas
#   ceo$industry <- factor(with(ceo, ifelse(ifelse(ifelse(...)))))
# It is correct and it is unreadable. The tidyverse exists to fix that.


## 1) Tibbles ------------------------------------------------------------------
# In the tidyverse, data lives in a 'tibble': a modern data frame. It prints
# more sensibly, never silently converts your text to factors, and works with
# every function we use from here on.

workers <- tibble(
  name   = c('Alice', 'Bob', 'Charlie', 'Diana', 'Eve'),
  age    = c(30, 20, 13, 45, 39),
  height = c(1.65, 1.80, 1.75, 1.70, 1.60),
  wage   = c(75000, 45000, NA, 280000, 190000),
  male   = c(FALSE, TRUE, TRUE, FALSE, FALSE)
)

workers        # note what it tells you: dimensions and the type of each column
view(workers)


## 2) Indexing a tibble the base-R way -----------------------------------------
# Everything you learned last week still works.

workers[1, ]                        # first row
workers[workers$name == 'Alice', ]  # the row where name is Alice

workers[, 4]                        # fourth column
workers$wage                        # the same column, by name

workers[1, 1]                       # first element
workers[[1, 1]]

  # single vs double square brackets, again:
  typeof(workers[1, 1])    # list   — a one-cell tibble
  typeof(workers[[1, 1]])  # character — the value itself

workers[1:3, 1:2]                              # rows 1-3, columns 1-2
workers[1:3, c('name', 'age')]                 # the same, by column name
workers[workers$male == FALSE, ]               # women
workers[workers$age >= 20 & workers$age <= 40, ]   # workers aged 20-40

# It works. It is also hard to read and easy to get wrong.


## 3) The same thing with tidyverse verbs --------------------------------------
# Each verb does one job, and its name says what it does.
#   filter()     keep some ROWS
#   select()     keep some COLUMNS
#   mutate()     create or change a column
#   summarise()  collapse many rows into one number
#   arrange()    sort

filter(.data = workers, male == FALSE)
filter(.data = workers, age >= 20 & age <= 40)
select(.data = workers, wage)

  # what is the difference?
  workers$wage             # a vector
  select(workers, wage)    # a tibble with one column

# Missing values, again:
sum(workers$wage)                  # NA
sum(workers$wage, na.rm = TRUE)    # you have to decide, explicitly

# Average wage of workers aged 20-40 — readable, but still nested inside out:
mean(workers$wage[workers$age >= 20 & workers$age <= 40], na.rm = TRUE)


## 4) The pipe operator |> -----------------------------------------------------
# The pipe takes what is on its left and passes it as the first argument of the
# function on its right. It lets you write a chain of steps in the order you
# actually do them, instead of from the inside out.
#
# Shortcut: Ctrl + Shift + M (Windows) / Cmd + Shift + M (Mac)

workers |>
  select(name, age)

workers |>
  filter(male == FALSE)

# Read this out loud: "take workers, keep the women, then keep the wage column."
workers |>
  filter(male == FALSE) |>
  select(wage)

workers |>
  filter(male == FALSE) |>
  filter(age >= 20 & age <= 40) |>
  select(wage)

# The same, with one filter:
workers |>
  filter(male == FALSE & age >= 20 & age <= 40) |>
  select(wage)

# And the average wage of 30-40 year olds:
workers |>
  filter(age >= 30 & age <= 40) |>
  summarise(avg_wage = mean(wage, na.rm = TRUE))


## 5) Changing a tibble --------------------------------------------------------
### Add a column ---------------------------------------------------------------
workers <- workers |>
  add_column(firm = c('Microsoft', 'Google', NA, 'Amazon', 'Apple'))

### Create a column from existing ones -----------------------------------------
workers <- workers |>
  mutate(height_sq = height * height)

### Change values --------------------------------------------------------------
workers <- workers |>
  mutate(wage = replace_na(wage, 0))   # NA becomes zero
# Careful: is a missing wage really a wage of zero? Usually not. We do it here
# to see how, not because it is right. Session 4 takes this seriously.

workers <- workers |>
  mutate(age = replace(age, age > 30, 31))   # cap age at 31

### Remove a column ------------------------------------------------------------
workers <- workers |>
  select(-height_sq)

### Add a row ------------------------------------------------------------------
workers <- workers |>
  add_row(name = 'Frank', age = 61, height = 179, wage = 30000,
          male = TRUE, firm = 'Tesla')

### ALWAYS check your data after you change it ---------------------------------
# Frank is 179 metres tall. Nobody typed that on purpose — the other heights are
# in metres and this one is in centimetres. This is the single most common data
# error there is, and it is invisible unless you look.
summary(workers$height)
range(workers$height)

workers <- workers |>
  mutate(height = ifelse(height > 3, height / 100, height))

range(workers$height)   # fixed

### Remove rows ----------------------------------------------------------------
workers <- workers |>
  filter(wage > 0)      # drops Charlie, whose missing wage we set to zero


## 6) Back to the CEO data -----------------------------------------------------
# Remember this from part 1?
#   ceo <- ceo[ceo$salary < cutoff, ]
# With the pipe it reads as what it is:

ceo_trimmed <- ceosal1 |>
  filter(salary < quantile(salary, probs = 0.99))

nrow(ceosal1)
nrow(ceo_trimmed)

# Same result, and you can read it a year from now. From here on, we use the
# tidyverse.


# >>> COMMIT CHECKPOINT 2 <<<


# ==============================================================================
# What we did, and what comes next
# ==============================================================================
# - a real data set, a plot built up in layers, and an outlier decision
# - tibbles, and why the tidyverse verbs beat bracket-counting
# - the pipe |>, which is how every remaining script in this course is written
#
# Next session: getting data in from files and from the internet, and reshaping
# it — long format, wide format, and joining two data sets together.
