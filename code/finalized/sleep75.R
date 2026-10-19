# Sleep and work: multiple regression on the sleep75 data (wooldridge package).
rm(list = ls())

# install.packages("wooldridge")  # run once
data(sleep75, package = "wooldridge")

train_index <- sample(1:nrow(sleep75), size = 0.8 * nrow(sleep75))
sleep75train <- sleep75[train_index, ]
sleep75test <- sleep75[-train_index, ]

# ---- a) Multiple regression --------------------------------------------------

model1 <- lm(sleep ~ totwrk + age + I(age^2) + educ + male + yngkid,
            data = sleep75train)

summary(model1)
# Interpretation:
#  - being male is associated with a 71.8 increase in mins spent sleeping per week 
#      + comment on magnitude and significance
#  - presence of young child: 9 minutes per week more sleep, or ~1 min per day, non-sig.
#  S.E. is large --> imprecisely estimated 

# ---- b) Descriptives -----------------------------------------------------------
# Option 1: make a table
tapply(sleep75train$sleep, list(male = sleep75train$male, yngkid = sleep75train$yngkid), mean)

# Option 2: make a box plot
boxplot(sleep ~ male + yngkid, data = sleep75train,
        xlab = "", ylab = "Minutes of sleep per week")
# note: this did not work on the lab computers

# ... or ggplot box plot:
ggplot(sleep75train, aes(x = factor(male, labels = c("Women", "Men")), y = sleep)) +
  geom_boxplot() +
  facet_wrap(~ yngkid, labeller = labeller(yngkid = c("0" = "No young child", "1" = "Young child"))) +
  labs(x = NULL, y = "Minutes of sleep per week") +
  theme_bw()

# ---- d) Model with interaction -----------------------------------------------

model_int <- lm(sleep ~ totwrk + age + I(age^2) + educ + male * yngkid,
                data = sleep75train)

summary(model_int)

# Interpretations: male, youngkid, interaction should be read together.
# Each should be interpreted as the effect when the others are 0. 
# Interaction: it is the difference in the young-child effect between 
# men and women. 

# ---- f) Prediction for a 40-year-old full-time man ---------------------------

# Full-time work is 40 hours = 2,400 minutes per week (totwrk is in minutes).

new <- data.frame(totwrk = 40 * 60, age = 40, educ = 15, male = 1, yngkid = 1)

predict(model_int, new, interval = "confidence", level = 0.90) / 60
predict(model_int, new, interval = "prediction", level = 0.90) / 60

# ---- g) Test RMSE ------------------------------------------------------------

sqrt(mean((sleep75test$sleep - predict(model1,     sleep75test))^2))
sqrt(mean((sleep75test$sleep - predict(model_int, sleep75test))^2))

# ---- h) BIC ------------------------------------------------------------------

BIC(model1, model_int)

