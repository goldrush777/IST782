GO

-- down
if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_game_goalie_stats_game_id')
    alter table game_goalie_stats drop constraint fk_game_goalie_stats_game_id

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_game_goalie_stats_player_id')
    alter table game_goalie_stats drop constraint fk_game_goalie_stats_player_id

drop table if exists game_goalie_stats


if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_game_player_stats_game_id')
    alter table game_player_stats drop constraint fk_game_player_stats_game_id

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_game_player_stats_player_id')
    alter table game_player_stats drop constraint fk_game_player_stats_player_id

drop table if exists game_player_stats


if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='chk_opponent_in_game')
    alter table game_team_stats drop constraint chk_opponent_in_game

IF OBJECT_ID('CheckTeamAndOpponentExist', 'FN') IS NOT NULL
    DROP FUNCTION CheckTeamAndOpponentExist;

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_game_team_stats_game_id')
    alter table game_team_stats drop constraint fk_game_team_stats_game_id

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_game_team_stats_team_id')
    alter table game_team_stats drop constraint fk_game_team_stats_team_id

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_game_team_stats_opponent_id')
    alter table game_team_stats drop constraint fk_game_team_stats_opponent_id

drop table if exists game_team_stats

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_games_home_team_id')
    alter table games drop constraint fk_games_home_team_id

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_games_away_team_id')
    alter table games drop constraint fk_games_away_team_id

drop table if exists games

drop table if exists players

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME='fk_teams_division_name')
    alter table teams drop constraint fk_teams_division_name

drop table if exists teams
drop table if exists divisions

drop table if exists positions

GO

-- up 

create table divisions (
    division_name varchar(20) not null,
    constraint pk_divisions_division_name primary key (division_name)
) 

create table teams (
    team_id char(3) not null,
    team_location varchar(20) not null,
    team_nickname varchar(20) not null,
    team_coach varchar(50) not null,
    team_venue varchar(50) not null,
    team_division varchar(20) not null,
    constraint pk_teams_team_id primary key (team_id),
    constraint u_teams_team_nickname unique (team_nickname), 
    constraint fk_teams_division_name foreign key (team_division)
        references divisions(division_name)
)

create table positions (
    position char(2) not null,
    constraint pk_positions primary key (position)
)

create table players (
    player_id varchar(15) not null,
    player_name varchar(50) not null,
    player_team_id char(3) not null,
    player_height int not null,
    player_weight int not null,
    player_position char(2) not null,
    player_dob date not null,
    player_draft_year int null,
    player_draft_round int null,
    player_draft_pick int null,
    player_draft_team char (3) null,
    constraint pk_players_player_id primary key (player_id),
    constraint ck_players_valid_height check (player_height > 0),
    constraint ck_players_valid_weight check (player_weight > 0),
    constraint fk_players_team_id foreign key (player_team_id)
        references teams(team_id)
)

create table games (
    game_id varchar(20) not null,
    game_date date not null,
    game_away_team_id char(3) not null,
    game_away_team_score int not null,
    game_home_team_id char(3) not null,
    game_home_team_score int not null,
    game_ot char(2) null,
    game_attendance int not null,
    constraint pk_games_game_id primary key (game_id),
    constraint fk_games_home_team_id foreign key (game_home_team_id)
        references teams(team_id),
    constraint fk_games_away_team_id foreign key (game_away_team_id)
        references teams(team_id)
)

GO
CREATE FUNCTION CheckTeamAndOpponentExist(@game_id VARCHAR(20), @team_id CHAR(3), @opponent_id CHAR(3))
RETURNS INT
AS
BEGIN
    DECLARE @result INT;
    SELECT @result = COUNT(*)
    FROM games
    WHERE game_id = @game_id
    AND ((game_home_team_id = @team_id AND game_away_team_id = @opponent_id)
        OR (game_home_team_id = @opponent_id AND game_away_team_id = @team_id));
    RETURN @result;
END;
GO

create table game_team_stats (
    game_id varchar(20) not null,
    team_id char(3) not null,
    team_season_gp int not null,
    team_homeaway char(4) not null,
    opponent_team_id char(3) not null,
    goals_for int not null,
    goals_against int not null,
    shots_for int not null,
    shots_against int not null,
    game_result varchar(5) not null,
    game_ot char(2) null,
    points int not null,
    season_w int not null,
    season_l int not null,
    season_otl int not null,
    season_points int not null,
    constraint pk_game_team_stats primary key (game_id, team_id),
    constraint fk_game_team_stats_game_id foreign key (game_id)
        references games(game_id),
    constraint fk_game_team_stats_team_id foreign key (team_id)
        references teams(team_id),
    constraint fk_game_team_stats_opponent_team_id foreign key (opponent_team_id)
        references teams(team_id),
    CONSTRAINT chk_opponent_in_game CHECK (
        dbo.CheckTeamAndOpponentExist(game_id, team_id, opponent_team_id) = 1
    )
)

GO


create table game_player_stats (
    game_id varchar(20) not null,
    player_id varchar(15) not null,
    player_goals int not null,
    player_assists int not null,
    player_points int not null,
    player_shots int not null,
    player_plus_minus int not null,
    player_pim int not null,
    player_toi varchar(5) not null,
    constraint pk_game_player_stats primary key (game_id, player_id),
    constraint fk_game_player_stats_game_id foreign key (game_id)
        references games (game_id),
    constraint fk_game_player_stats_player_id foreign key (player_id)
        references players (player_id)
)

create table game_goalie_stats (
    game_id varchar(20) not null,
    player_id varchar(15) not null,
    goalie_decision char(1) null,
    goalie_ga int not null,
    goalie_sa int not null,
    goalie_sv int not null,
    goalie_svpct decimal(10,3) not null
    constraint pk_game_goalie_stats primary key (game_id, player_id),
    constraint fk_game_goalie_stats_game_id foreign key (game_id)
        references games (game_id),
    constraint fk_game_goalie_stats_player_id foreign key (player_id)
        references players (player_id)
)

GO
-- up data 

insert into divisions
    (division_name)
    values 
    ('Atlantic'), 
    ('Metropolitan'), 
    ('Central'), 
    ('Pacific')



insert into positions
    (position)
    values 
    ('C'), ('LW'), ('RW'), ('D'), ('G'), ('F')


select * from divisions
select * from positions



GO