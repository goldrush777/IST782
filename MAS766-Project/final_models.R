library(tidyverse)

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
         lag9_attendance = lag(lag8_attendance))%>% 
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


par(mfrow = c(1, 1))

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




