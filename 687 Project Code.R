#Load in packages
library(tidyverse)
library(arrow)

#Read in CSVs
metadata <- read_csv("data_dictionary.csv")
weather <- read_csv("G4500010.csv")
energy_usage <- read_parquet("102063.parquet")
static_house <- read_parquet("static_house_info.parquet")

#Rename time column so it has the same name as the time column in energy_usage
weather <- rename(weather, time = date_time)

#Get rid of unnecessary columns we won't use in energy_usage. This is gonna be
#called electricity usage.
electricity_usage <- energy_usage[,-c(25:42)]

#Creating our dependent variable
electricity_usage$out.electricity.total <- rowSums(electricity_usage[,1:24])

#Merge the weather and electricity_usage data frames
energy_fulltable <- merge(x = weather, y = electricity_usage, 
                       by = "time")

#Making April-June Table
april_thru_june <- energy_fulltable[2159:4342,]

#Cutting out everything that's not in July in energy_fulltable
energy_fulltable <- energy_fulltable[4343:5086,]

#Creating a new weather data frame where temperature is 5 degrees warmer
weather_plus5 <- weather
weather_plus5$`Dry Bulb Temperature [°C]` <- 
  weather_plus5$`Dry Bulb Temperature [°C]` + 5

#Cutting out everything that's not in July in weather_plus5
weather_plus5 <- weather_plus5[4344:5087,]

#Merge energy_fulltable_plus5 and weather_plus5
energy_fulltable_plus5 <- merge(x = weather_plus5, y = electricity_usage, 
                          by = "time")

#Make plus 5 data frame for april thru june
april_thru_june_plus5 <- april_thru_june
april_thru_june_plus5$`Dry Bulb Temperature [°C]` <-
  april_thru_june_plus5$`Dry Bulb Temperature [°C]` + 5

#Model
finalproj687_model1 <- lm(out.electricity.total ~ `Relative Humidity [%]` + 
                            `Wind Speed [m/s]` + 
                            `Diffuse Horizontal Radiation [W/m2]`, 
                          data = april_thru_june_plus5)

summary(finalproj687_model1)

#Use the model to predict july values
July_Predictions <- predict(finalproj687_model1, 
                            newdata = energy_fulltable_plus5)

July_Predictions

#Create a data frame with the predictions, actual values, and the differences
#between the two
July_Predictions_DF <- data.frame(
  Time = energy_fulltable_plus5$time, 
  Actual = energy_fulltable_plus5$out.electricity.total,
  Predicted = July_Predictions, 
  Difference = energy_fulltable_plus5$out.electricity.total - July_Predictions)

July_Predictions_DF

