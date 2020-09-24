#Wrangling data from PEW Research Center politics survey from Jan 2020

#Load packages 

if(!require(tidyverse)) install.packages("tidyverse", 
                                         repos = "http://cran.us.r-project.org")
if(!require(haven)) install.packages("haven", 
                                         repos = "http://cran.us.r-project.org")
if(!require(labelled)) install.packages("labelled", 
                                     repos = "http://cran.us.r-project.org")
if(!require(mvdalab)) install.packages("mvdalab", 
                                        repos = "http://cran.us.r-project.org")
if(!require(fastDummies)) install.packages("fastDummies", 
                                       repos = "http://cran.us.r-project.org")


#Import data from desktop
original_df <- read_sav("C:/Users/DBamat/Desktop/Jan20 public.sav")

#Select variables to keep

df <- original_df %>%
  select("respid", "state", "iracem1", "sex", "age", "educ", "income", "party")

#transform variables

df <- df %>%
  mutate(white = ifelse(iracem1 == 1, 1, 0),
         male = ifelse(sex == 1, 1, 0),
         college = ifelse(educ >= 5 & educ <= 8, 1, 0),
         republican = ifelse(party == 1, 1, 0))

#turn 10s (no answer) from income variable to "NA"

df$income <- as.numeric(df$income)
df$income[df$income==10] <- "NA"
df$income <- as.numeric(df$income)

#Convert state values to their labels

df$state <- unlabelled(df$state)


#Impute the 124 missing values from the income variable (get EM code from data science course)

df_for_EM <- df %>%
  select("age", "income", "white", "male", "college", "republican")

set.seed(1)
imputed_df <- imputeEM(df_for_EM)
new_df <- imputed_df[["Imputed.DataFrames"]][[1]]

#cbind state and responded ID back into df

new_df <- cbind(df[,1:2], new_df)

#Create confederate state indicator

confederate_states <- c("TX", "AR", "LA", "MS", "TN", "AL", "FL", "GA", "NC", "VA", "SC")

new_df <- new_df %>%
  mutate(confederate = ifelse(state %in% confederate_states, 1, 0))

#create dummy variables for states
new_df <- dummy_cols(new_df)

#give data frame a more descriptive name

pew_politics_jan_2020 <- new_df


<<<<<<< HEAD
#manipulate data set to support instruction around analyzing nested data. Specifically, here I artificially increase the 
# clustering and confederacy effects by recoding republican to "1" if respondent is in an ex-confederate state for a subset of
# the sample (the first 500 rows).

#create index variable
pew_politics_jan_2020$Number <- seq(1, 1504, 1)

#Manipulate
pew_politics_jan_2020$republican[pew_politics_jan_2020$Number <= 15833 & pew_politics_jan_2020$confederate == 1] <- 1


=======
>>>>>>> b35a8676eb9f4b10442672de17c446249b36d979
#write csv to folder that will be upload to gitHub
write.csv(pew_politics_jan_2020, "~/R/pew-politics-jan2020/dataset.csv")




