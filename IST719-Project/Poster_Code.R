#Setup + Fixing Data Frame
library(tidyverse)
library(dplyr)
library(scales)
setwd("/Users/davidgold/Desktop/Research/Senior Thesis")
NHL_Season_Stats <- read_csv("full_yearly_stats.csv")
NHL_Season_Stats <- NHL_Season_Stats %>%
  filter(nchar(Team) <= 3)

NHL_Season_Stats$Team_Season <- paste(substr(NHL_Season_Stats$Season,5,8), "",
                                      NHL_Season_Stats$Team)

NHL_Season_Stats$Player_Season <- paste(substr(NHL_Season_Stats$Season,5,8), "",
                                      NHL_Season_Stats$Player)

NHL_Season_Stats$Season <- substr(NHL_Season_Stats$Season,5,8)

NHL_Season_Stats$Position <- substr(NHL_Season_Stats$Position,1,1)

#Plot 1
Top_10_Goals <- NHL_Season_Stats %>%
  group_by(Team_Season) %>%
  summarise(Team = Team_Season, 
            Goals = sum(yearly_Goals), 
            Shots = sum(yearly_Shots),
            `SH%` = Goals / Shots) %>%
  distinct()

Top_10_Goals <- Top_10_Goals %>%
  arrange(desc(Goals))

Top_10_Goals <- Top_10_Goals[1:10,]

Top_10_Goals %>%
  group_by(Team_Season) %>%
  summarise(Team = Team_Season, Goals_Per_Game = Goals/82,
            `SH%` = 100*`SH%`) %>%
  slice_max(Goals_Per_Game, n = 10) %>%
  ggplot() +
  geom_col(aes(x = Team, y = `SH%`), fill = "lightblue", width = 0.6,
           alpha = 0.8) +
  geom_col(aes(x = reorder(Team, Goals_Per_Game), y = Goals_Per_Game), fill = "blue", width = 0.1, 
           alpha = 0.8) +
  coord_flip() +
  ggtitle("Highest Goal Scoring Teams (2008-2022)") +
  xlab("Team") +
  ylab("Shooting Percentage (Goals Per Game)") +
  theme_bw() +
  theme(
    plot.background = element_rect(fill = "gray", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

#Plot 2
NHL_Season_Stats %>%
  group_by(Season) %>%
  summarize(Season = Season, Goals = sum(yearly_Goals)) %>%
  distinct() %>%
  ggplot() + 
  geom_col(aes(x = Goals, y = Season), fill = "dark red", width = 0.5) +
  scale_x_continuous(labels = comma) +
  coord_flip() +
  ggtitle("Total Goals Scored in the NHL Each Season") +
  xlab("Total Goals Scored") +
  ylab("Season") +
  theme_bw() +
  theme(
    plot.background = element_rect(fill = "gray", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

#Plot 3
NHL_Season_Stats[NHL_Season_Stats$yearly_TOI > 1000,] %>% 
  ggplot(aes(x = `yearly_SH%`, y = yearly_TOI)) + 
  geom_point(size = .75) + 
  ggtitle("Shooting Percentage vs Time on Ice (Min TOI = 1000)") + 
  xlab("Shooting Percentage") + 
  ylab("Time on Ice") + 
  scale_y_continuous(limits = c(0, NA)) +
  theme_bw()

#Plot 4
Goals_By_Position <- aggregate(yearly_Goals ~ Position, 
                               data = NHL_Season_Stats, sum)

Goals_By_Position$Position <- recode(Goals_By_Position$Position, 
                                     C = "Center", 
                                     D = "Defenseman", 
                                     L = "Left Wing", 
                                     R = "Right Wing")

par(bg = "gray")
pie(Goals_By_Position$yearly_Goals, 
    labels = Goals_By_Position$Position, 
    main = "Total Goals Scored by Position",
    col = rainbow(length(Goals_By_Position$Position)))

#Team xGoals vs Goals
install.packages("ggimage")
library(ggimage)

teams <- NHL_Season_Stats %>%
  summarise(Team = Team) %>%
  distinct() %>%
  arrange(Team)

teams$logo <-
  c("https://logos-world.net/wp-content/uploads/2020/05/Anaheim-Ducks-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/02/Arizona-Coyotes-Logo.png",
    "https://seeklogo.com/images/A/atlanta-thrashers-logo-454262B674-seeklogo.com.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Boston-Bruins-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/07/Buffalo-Sabres-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Carolina-Hurricanes-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/06/Columbus-Blue-Jackets-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/12/Calgary-Flames-Logo-1994-2020.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Chicago-Blackhawks-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Colorado-Avalanche-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/02/Dallas-Stars-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Detroit-Red-Wings-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Edmonton-Oilers-Logo-2017-Present.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Florida-Panthers-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/02/Los-Angeles-Kings-Logo-2019.png",
    "https://logos-world.net/wp-content/uploads/2020/12/Minnesota-Wild-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Montreal-Canadiens-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/06/New-Jersey-Devils-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/12/Nashville-Predators-Logo-2011-present.jpg",
    "https://logos-world.net/wp-content/uploads/2020/05/New-York-Islanders-Logo-2017-Present.png",
    "https://logos-world.net/wp-content/uploads/2020/05/New-York-Rangers-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/07/Ottawa-Senators-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Philadelphia-Flyers-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/02/Arizona-Coyotes-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Pittsburgh-Penguins-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/12/San-Jose-Sharks-Logo.png",
    "https://logos-world.net/wp-content/uploads/2021/10/Seattle-Kraken-Logo-2020-present.png",
    "https://logos-world.net/wp-content/uploads/2020/12/St.-Louis-Blues-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Tampa-Bay-Lightning-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Toronto-Maple-Leafs-logo.png",
    "https://logos-world.net/wp-content/uploads/2020/12/Vancouver-Canucks-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/12/Vegas-Golden-Knights-Logo.png",
    "https://logos-world.net/wp-content/uploads/2020/05/Winnipeg-Jets-logo.png",
    "https://seeklogo.com/images/W/washington-capitals-logo-CC18DA3B54-seeklogo.com.png"
    )

test <- NHL_Season_Stats %>%
  group_by(Season, Team) %>%
  summarize(Season = Season, Goals = sum(yearly_Goals), 
            xGoals = sum(yearly_ixG)) %>%
  distinct() %>%
  arrange(Team)

test <- test[1:27,]

test2 <- merge(test,teams2, by = "Team")

test2 %>%
  ggplot(aes(x = xGoals, y = Goals)) +
  geom_point() +  
  geom_image(aes(image = logo), size = 0.1) +
  theme_minimal()

standings22 <- data.frame(
  Team = c("ANA", "ARI", "BOS", "BUF", "CAR", "CBJ", "CGY", "CHI", "COL", "DAL", 
           "DET", "EDM", "FLA", "L.A", "MIN", "MTL", "N.J", "NSH", "NYI", "NYR", 
           "OTT", "PHI", "PIT", "S.J", "SEA", "STL", "T.B", "TOR", "VAN", "VGK", 
           "WPG", "WSH"),
  Pts_Perc = c(0.463, 0.348, 0.652, 0.457, 0.707, 0.494, 0.677, 0.415, 0.726, 0.598, 
               0.451, 0.634, 0.744, 0.604, 0.689, 0.335, 0.384, 0.591, 0.512, 0.671, 
               0.445, 0.372, 0.628, 0.47, 0.366, 0.665, 0.667, 0.71, 0.561, 0.573, 
               0.543, 0.61)
)
  
logo_plot_data <- NHL_Season_Stats %>%
  group_by(Season, Team) %>%
  summarize(Season = Season, Goals = sum(yearly_Goals), 
            xGoals = sum(yearly_ixG)) %>%
  distinct() %>%
  merge(teams, by = "Team") %>%
  arrange(desc(Season)) %>%
  head(32)

logo_plot_data <- merge(logo_plot_data,standings22,by="Team")


avg_xGoals <- mean(logo_plot_data$xGoals, na.rm = TRUE)
avg_Goals <- mean(logo_plot_data$Goals, na.rm = TRUE)

# Create the plot
logo_plot_data %>%
  ggplot(aes(x = xGoals, y = Goals)) + 
  geom_image(aes(image = logo, size = 0.1)) + 
  scale_size_continuous(range = c(0.05, 0.2), guide = "none") +
  geom_vline(xintercept = avg_xGoals, color = "black", linetype = "dashed") +
  geom_hline(yintercept = avg_Goals, color = "black", linetype = "dashed") +
  annotate("text", x = avg_xGoals * 1.2, y = avg_Goals * 1.2, label = "Great") + 
  annotate("text", x = avg_xGoals * 0.8, y = avg_Goals * 1.2, label = "Lucky") + 
  annotate("text", x = avg_xGoals * 1.2, y = avg_Goals * 0.8, label = "Unlucky") + 
  annotate("text", x = avg_xGoals * 0.8, y = avg_Goals * 0.8, label = "Bad") + 
  theme_minimal() + 
  theme(
    plot.background = element_rect(fill = "gray", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  ) +
  labs(
    title = "2022 Season Goals vs Expected Goals (xG)", 
    x = "Expected Goals (xG)", 
    y = "Actual Goals"
  )
    
#Corsi Plot
logo_plot_data2 <- NHL_Season_Stats %>%
  group_by(Season, Team) %>%
  summarize(Season = Season, CF = sum(yearly_iCF), 
            xGoals = sum(yearly_ixG)) %>%
  distinct() %>%
  merge(teams, by = "Team") %>%
  arrange(desc(Season)) %>%
  head(32)

logo_plot_data2 <- merge(logo_plot_data2,standings22,by="Team")

avg_xGoals <- mean(logo_plot_data2$xGoals, na.rm = TRUE)
avg_CF <- mean(logo_plot_data2$CF, na.rm = TRUE)

# Create the plot
logo_plot_data2 %>%
  ggplot(aes(x = CF, y = xGoals)) + 
  geom_image(aes(image = logo, size = 0.1)) + 
  scale_size_continuous(range = c(0.05, 0.2), guide = "none") +
  geom_vline(xintercept = avg_CF, color = "black", linetype = "dashed") +
  geom_hline(yintercept = avg_xGoals, color = "black", linetype = "dashed") +
  annotate("text", x = avg_CF * 1.1, y = avg_xGoals * 1.1, label = "Elite Offense") + 
  annotate("text", x = avg_CF * 0.9, y = avg_xGoals * 1.1, label = "Quality over Quantity") + 
  annotate("text", x = avg_CF * 1.1, y = avg_xGoals * 0.9, label = "Quantity over Quality") + 
  annotate("text", x = avg_CF * 0.9, y = avg_xGoals * 0.9, label = "Bad Offense") + 
  theme_minimal() + 
  theme(
    plot.background = element_rect(fill = "gray", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  ) +
  labs(
    title = "2022 Season Corsi vs Expected Goals (xG)", 
    x = "Corsi", 
    y = "Expected Goals (xG)"
  )

#Standings
fullstandings <- read_csv("nhlteampoints.csv")
fullstandings$Season <- substr(fullstandings$Season,5,8)

standings_plot_data <- NHL_Season_Stats %>%
  group_by(Season, Team) %>%
  summarize(Season = Season, Goals = sum(yearly_Goals), 
            xGoals = sum(yearly_ixG), CF = sum(yearly_iCF)) %>%
  distinct() %>%
  merge(teams, by = "Team") %>%
  arrange(desc(Season))

standings_plot_data <- merge(standings_plot_data,fullstandings, 
                             by = c("Team","Season"))

standings_plot_data %>%
  ggplot(aes(x = xGoals, y = Season_Points_Percentage, color = Goals)) +
  geom_point() +
  ggtitle("Expected Goals vs Standings Point Percentage") + 
  geom_smooth(method = "lm", col = "black") +
  geom_hline(yintercept = 0.58, color = "brown", linetype = "dashed") +
  xlab("Expected Goals") + 
  ylab("Standings Point Percentage") + 
  scale_y_continuous(limits = c(0, NA)) +
  scale_color_gradient(low = "lightblue", high = "darkred", name = "Goals") +
  theme_bw() +
  theme(
    plot.background = element_rect(fill = "gray", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

