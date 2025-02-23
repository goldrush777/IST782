# Data Cleaning ----------------------------------------------------------------------------

library(tidyverse)

# kaggle data transformation ----------------------------------------
mlb <- read_csv("game_logs_2006-2016.csv")

mlb2 <- mlb %>% 
  mutate(v_name = gsub("FLO", "MIA", v_name),
         h_name = gsub("FLO", "MIA", h_name))

mlb3 <- mlb2 %>% 
  select(index,date, day_of_week, day_night,v_name,h_name,
         h_game_number, v_score, h_score, v_hits,
         h_hits, v_homeruns, h_homeruns, attendance) %>% 
  mutate(winning_team = ifelse(v_score>h_score,v_name,h_name))

mlb4 <- mlb3 %>%
  mutate(
    team = h_name,
    team_won = if_else(winning_team == team, 1, 0),
    team_hr = h_homeruns,
    team_hits = h_hits,
    team_runs = h_score
  ) %>%
  bind_rows(
    mlb3 %>% mutate(
      team = v_name,
      team_won = if_else(winning_team == team, 1, 0),
      team_hr = v_homeruns,
      team_hits = v_hits,
      team_runs = v_score
    )
  ) %>% 
  arrange(team,date) %>% 
  group_by(team) %>% 
  mutate(lag_team_won = lag(team_won, default = 0),
         lag_team_hr = lag(team_hr, default = 0),
         lag_team_hits = lag(team_hits, default = 0),
         lag_team_runs = lag(team_runs, default = 0),
         h_wins_last_30 = cumsum(lag_team_won) - lag(cumsum(lag_team_won), 30, default = 0),
         h_hr_last_30 = (cumsum(lag_team_hr) - lag(cumsum(lag_team_hr), 30, default = 0))/30,
         h_hits_last_30 = (cumsum(lag_team_hits) - lag(cumsum(lag_team_hits), 30, default = 0))/30,
         h_runs_last_30 = (cumsum(lag_team_runs) - lag(cumsum(lag_team_runs), 30, default = 0))/30) %>% 
  ungroup() %>% 
  filter(h_name == team,
         date > "2007-01-01") %>% 
  arrange(date, index) %>% 
  select(index, date, day_of_week, day_night, v_name, h_name, h_wins_last_30,
         h_hr_last_30, h_hits_last_30, h_runs_last_30, h_game_number, attendance)


# write_csv(mlb4, "game_logs_updated.csv")

# Joining with Baseball Reference Data ---------------------------------------------------------------
data <- read_csv("game_logs_updated.csv")
join <- read_csv("MAS766 Group Project Data - Table_To_Join.csv")

join$Year <- as.character(join$Year)

data$Year <- substr(data$date,1,4)

data <- data %>%
  inner_join(join, by = c("Year", "h_name"))

data$home_had_top3_award_player <- ifelse(!is.na(data$had_top3_award_player) & 
                                            data$had_top3_award_player == 1, 1, 0)

v_team_awards <- read_csv("v_team_awards.csv")
v_team_awards$Year <- as.character(v_team_awards$Year)

data <- data %>%
  inner_join(v_team_awards, by = c("Year", "v_name"))

data <- data[, !colnames(data) %in% "had_top3_award_player"]

data$h_division <- data$division

v_divisions <- read_csv("v_divisions.csv")
v_divisions$Year <- as.character(v_divisions$Year)

data <- data %>%
  inner_join(v_divisions, by = c("Year", "v_name"))

data <- data[, !colnames(data) %in% "division.x"]
data <- data[, !colnames(data) %in% "division.y"]

data$rivalry_game <- ifelse(data$h_division == data$v_division,1,0)

data$h_win_perc <- data$win_perc
data <- data[, !colnames(data) %in% "win_perc"]

v_records <- read_csv("v_records.csv")
v_records$Year <- as.character(v_records$Year)

data <- data %>%
  inner_join(v_records, by = c("Year", "v_name"))

# write_csv(data,"updated_MAS_data.csv")

# PART A VISUALIZATIONS ---------------------------------------------------------------
data <- read_csv("updated_MAS_data.csv")

data <- data[!is.na(data$attendance), ]
hist(data$attendance, main = "Histogram of Attendance", xlab = "Attendance",
     col = "blue")

summary(data$attendance)
sd(data$attendance)

hist(data$h_win_perc, main = "Histogram of Team Win Percentages", 
     xlab = "Win %", col = "lightblue", border = "darkred")

summary(data$h_win_perc)
sd(data$h_win_perc)

sum(data$rivalry_game == 1, na.rm = TRUE)
sum(data$rivalry_game == 0, na.rm = TRUE)

sum(v_team_awards$visitor_had_top3_award_player == 1, na.rm = TRUE)
sum(v_team_awards$visitor_had_top3_award_player == 0, na.rm = TRUE)


# Normal Distribution of hits in the last 30 games
histogram_hits <- ggplot(data, aes(x = h_hits_last_30)) +
  geom_histogram(binwidth = 0.5, fill = "red", color = "white") +
  labs(title = "Distribution of Hits in the Last 30 Games",
       x = "Hits in Last 30 Games", y = "Frequency") +
  theme_minimal()
histogram_hits
summary(data$h_hits_last_30)
sd(data$h_hits_last_30)

# Normal Distribution of homeruns the last 30 games
histogram_runs <- ggplot(data, aes(x = h_runs_last_30)) +
  geom_histogram(binwidth = 0.5, fill = "green", color = "black") +
  labs(title = "Distribution of Home runs in the Last 30 Games",
       x = "Home Runs in Last 30 Games", y = "Frequency") +
  theme_minimal()

histogram_runs
summary(data$h_hr_last_30)
sd(data$h_hr_last_30)

# Boxplot of home runs in the last 30 games by day or night game
boxplot_1 <- ggplot(data, aes(x = day_night, y = h_hr_last_30, fill = day_night)) +
  geom_boxplot() +
  labs(title = "Home Runs in Last 30 Games by Game Time",
       x = "Day or Night Game", y = "Home Runs in Last 30 Games") +
  theme_minimal()     

boxplot_1

# Part B Univariate Analysis ----------------------------------------------------------------

data <- read_csv("updated_MAS_data.csv")

data <- data %>% filter(attendance > 0)

data2 <- data %>% 
  group_by(h_name) %>% 
  mutate(lag_attendance = lag(attendance),
         lag2_attendance = lag(lag_attendance),
         lag3_attendance = lag(lag2_attendance),
         lag4_attendance = lag(lag3_attendance),
         lag5_attendance = lag(lag4_attendance),
         lag6_attendance = lag(lag5_attendance),
         lag7_attendance = lag(lag6_attendance),
         lag8_attendance = lag(lag7_attendance),
         lag9_attendance = lag(lag8_attendance)) %>% 
  ungroup() %>% 
  na.omit()

data2 <- data2 %>%
  mutate(day_type = case_when(
    day_of_week %in% c("Mon", "Tue", "Wed", "Thu") ~ "Weekday",
    day_of_week %in% c("Fri", "Sat", "Sun") ~ "Weekend"
  ))

y <- data2$attendance
x1 <- data2$h_wins_last_30
x2 <- data2$h_hits_last_30
x3 <- data2$h_hr_last_30
x4 <- data2$h_runs_last_30
x5 <- data2$h_win_perc
x6 <- data2$v_win_perc
x7 <- data2$h_game_number
x8 <- data2$lag_attendance

par(mfrow = c(2, 2))

plot(y~x1, main = "Attendance vs Wins in last 30 Games",
     pch = 16, col = rgb(0,0,0, alpha = 0.5),
     xlab = "Wins in Last 30",
     ylab = "Attendance")
abline(lm(y~x1), col = "red", lwd = 2)


plot(y~x2, main = "Attendance vs Hits in last 30 Games",
     pch = 16, col = rgb(0,0,0, alpha = 0.5),
     xlab = "Hits Per Game in Last 30",
     ylab = "Attendance")
abline(lm(y~x2), col = "red", lwd = 2)


plot(y~x3, main = "Attendance vs Home Runs in last 30 Games",
     pch = 16, col = rgb(0,0,0, alpha = 0.5),
     xlab = "HR per Game in Last 30",
     ylab = "Attendance")
abline(lm(y~x3), col = "red", lwd = 2)


plot(y~x4, main = "Attendance vs Runs in last 30 Games",
     pch = 16, col = rgb(0,0,0, alpha = 0.5),
     xlab = "Runs per Game in Last 30",
     ylab = "Attendance")
abline(lm(y~x4), col = "red", lwd = 2)


plot(y~x5, main = "Attendance vs Home Team Win Percentage", 
     pch = 16, col = rgb(0,0,0, alpha = 0.5),
     xlab = "Home Team Win %",
     ylab = "Attendance")
abline(lm(y~x5), col = "red", lwd = 2)


plot(y~x6, main = "Attendance vs Away Team Win Percentage",
     pch = 16, col = rgb(0,0,0, alpha = 0.5),
     xlab = "Away Team Win %",
     ylab = "Attendance")
abline(lm(y~x6), col = "red", lwd = 2)


plot(y~x7, main = "Attendance vs Home Team Game Number", 
     pch = 16, col = rgb(0,0,0, alpha = 0.5),
     xlab = "Home Team Game Number",
     ylab = "Attendance")
abline(lm(y~x7), col = "red", lwd = 2)


plot(y~x8, main = "Attendance vs Lag Attendance",
     pch = 16, col = rgb(0,0,0, alpha = 0.5),
     xlab = "Attendance in Previous Home Game",
     ylab = "Attendance")
abline(lm(y~x8), col = "red", lwd = 2)

cordf <- data.frame(X_Variable = c("Wins in Last 30", "Hits per Game in Last 30", "HR per Game in Last 30",
                                   "Runs per Game in last 30", "Home Team Win %", "Away Team Win %",
                                   "Home Game Number", "Attendance in Prior Home Game"),
                    Correlation_with_Y = c(cor(y,x1),cor(y,x2),cor(y,x3),cor(y,x4),
                                           cor(y,x5),cor(y,x6),cor(y,x7),cor(y,x8)))

par(mfrow = c(1,1))

data2$day_of_week <- factor(data2$day_of_week, 
                            levels = c("Mon", "Tue", "Wed", 
                                       "Thu", "Fri", 
                                       "Sat", "Sun"))


boxplot(data2$attendance~data2$day_of_week,
        main = "Attendance by Day of Week",
        xlab = "Day of Week",
        ylab = "Attendance",
        col = "darkorange")

boxplot(data2$attendance~data2$day_night,
        main = "Attendance by Day/Night",
        xlab = "Day or Night Game",
        ylab = "Attendance",
        col = "darkorange")

# PART B Multi variate Analysis --------------------------------------------------------------------

options(scipen = 999)
model1 <- lm(attendance ~ h_wins_last_30 + h_hr_last_30 +
               h_hits_last_30 + h_runs_last_30 + h_win_perc + v_win_perc +
               h_game_number, data = data2)

summary(model1)

model2 <- lm(attendance ~ h_wins_last_30 + h_hits_last_30 + 
               h_runs_last_30 + h_win_perc + v_win_perc + h_game_number,
             data = data2)

summary(model2)

model3 <- lm(attendance ~ h_wins_last_30 + h_hits_last_30 +
               h_runs_last_30 + h_win_perc + v_win_perc + h_game_number +
               day_night + day_type + home_had_top3_award_player +
               visitor_had_top3_award_player + rivalry_game, data = data2)

summary(model3)

model4 <- lm(attendance ~ h_wins_last_30 + h_hits_last_30 +
               h_runs_last_30 + h_win_perc + v_win_perc + h_game_number +
               day_night + day_type + rivalry_game, data = data2)

summary(model4)

model5 <- lm(attendance ~ h_wins_last_30 + h_hits_last_30 +
               h_runs_last_30 + h_win_perc + v_win_perc + h_game_number +
               day_night*day_type + rivalry_game, data = data2)

summary(model5)

model6 <- lm(attendance ~ h_wins_last_30 + h_hits_last_30 +
               h_runs_last_30 + h_win_perc + v_win_perc + h_game_number +
               day_night*day_type + rivalry_game + lag_attendance +
               lag2_attendance + lag3_attendance, data = data2)

summary(model6)

model7 <- lm(attendance ~ h_wins_last_30 + h_hits_last_30 +
               h_runs_last_30 + h_win_perc + v_win_perc + h_game_number +
               day_night*day_type + rivalry_game + lag_attendance +
               lag2_attendance + lag3_attendance + lag4_attendance +
               lag5_attendance + lag6_attendance, data = data2)

summary(model7)

model8 <- lm(attendance ~ h_wins_last_30 + h_hits_last_30 +
               h_runs_last_30 + h_win_perc + v_win_perc + h_game_number +
               day_night*day_type + rivalry_game + lag_attendance +
               lag2_attendance + lag3_attendance + lag4_attendance +
               lag5_attendance + lag6_attendance + lag7_attendance +
               lag8_attendance + lag9_attendance, data = data2)

summary(model8)

model9 <- lm(attendance ~ h_wins_last_30 + h_hits_last_30 +
               h_runs_last_30 + h_win_perc + v_win_perc + h_game_number +
               day_night*day_type + lag_attendance +
               lag2_attendance + lag3_attendance + lag4_attendance +
               lag5_attendance + lag6_attendance, data = data2)

summary(model9)

# Residual Analysis -----------------------------------------------------------------
par(mfrow = c(3,4))

plot(model9$residuals ~ data2$h_wins_last_30)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$h_hits_last_30)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$h_runs_last_30)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$h_win_perc)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$v_win_perc)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$h_game_number)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$lag_attendance)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$lag2_attendance)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$lag3_attendance)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$lag4_attendance)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$lag5_attendance)
abline(h = 0, col = "red", lty = 2)
plot(model9$residuals ~ data2$lag6_attendance)
abline(h = 0, col = "red", lty = 2)

