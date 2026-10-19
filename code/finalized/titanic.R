# Who survived the Titanic? Linear probability, logit and probit models (base R).
# Data: titanic_small.xls — sex (1 = male, 2 = female), pclass, age, survived.
rm(list=ls())
getwd()
#setwd()
library(readxl)
library(tidyverse)

titanic <- read_excel("data/titanic_small.xls")

# ---- a) Survival rate by gender ----------------------------------------------
# Base R:
tapply(titanic$survived, titanic$sex, mean)
# or (with labels):
tapply(titanic$survived, c("1 Male", "2 Female")[titanic$sex], mean)
# or: 
prop.table(table(titanic$sex,titanic$survived),margin=1)

# Tidyverse:
titanic |>
  group_by(sex) |>
  summarise(survival_rate = mean(survived))

# ---- b) LPM, logit and probit ------------------------------------------------

# factor() turns class and gender into categories; the first category
# (first class, men) is the reference. Passengers with a missing age are left
# out of the models automatically.

lpm    <- lm(survived ~ factor(pclass) + factor(sex) + age, data = titanic)
logit  <- glm(survived ~ factor(pclass) + factor(sex) + age, data = titanic,
              family = binomial(link = "logit"))
probit <- glm(survived ~ factor(pclass) + factor(sex) + age, data = titanic,
              family = binomial(link = "probit"))

summary(lpm)
summary(logit)
summary(probit)

#install.packages('stargazer')
library(stargazer)
stargazer(lpm, logit, probit, type = "text")

# ---- c) Gender coefficient in the LPM versus the raw gap ---------------------

diff(tapply(titanic$survived, titanic$sex, mean))
coef(lpm)["factor(sex)2"]
  # Options for commenting: 
# class lowers the probability of survival, so it is likely that men were overrepresented in third class,
# which simple mean comparisons do not account for.
tapply(titanic$pclass, c("1 Male", "2 Female")[titanic$sex], mean)

# ---- d) Average marginal effect of age ---------------------------------------

# LPM: the coefficient is the marginal effect.

coef(lpm)["age"]
mean(dlogis(predict(logit, type = "link"))) * coef(logit)["age"]
# logit: log odds --> Average Marginal Effects
mean(dnorm(predict(probit, type = "link"))) * coef(probit)["age"]
# probit: change in probit index --> AME 

# Or you can use mfx package:
install.packages('mfx')
library(mfx)
summary(lm(survived ~ factor(pclass) + sex + age, data = titanic))
  # in LPM, the AME is the coefficient. Nothing to compute.
logitmfx(survived ~ factor(pclass) + sex + age, data=titanic, atmean=FALSE)
  # logit: the coef is in log-odds, not directly interpretable. 
probitmfx(survived ~ factor(pclass) + sex + age, data=titanic, atmean=FALSE)
  # probit: coef is change in the probit index, not directly interpretable. 
  # AME: same interpretaiton as coefficient in LPM (on average). 

# Or a tidyverse option:
avg_slopes(lpm, variables = "age")
avg_slopes(logit, variables = "age")
avg_slopes(probit, variables = "age")