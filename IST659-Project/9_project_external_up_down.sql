--Relation between player points and draft pick
go
drop view v_points_pick
go 
create view v_points_pick as
    select p.player_draft_pick as pick_number, count(ps.player_id) as games_played, sum(ps.player_points) as total_points 
        from game_player_stats as ps
        join players as p on ps.player_id = p.player_id
        group by p.player_draft_pick
go
select *
    from v_points_pick
    order by pick_number

--which teams have the best goal differential
GO
drop view v_team_gd
go 
create view v_team_gd as
    select t.team_nickname as team, t.team_division as division, sum(g.goals_for) - sum(g.goals_against) as goal_difference
        from teams as t 
        join game_team_stats as g on t.team_id = g.team_id
        group by t.team_nickname, t.team_division
GO
select *
    from v_team_gd
    order by goal_difference desc

--Goals in a game compared to attendance
GO
drop view v_goal_att
GO
create view v_goal_att as
    select game_away_team_id as away_team, game_home_team_id as home_team, 
        game_away_team_score + game_home_team_score as total_score, game_attendance as attendance
        from games
        group by game_id, game_away_team_id, game_home_team_id, game_away_team_score, game_home_team_score, 
        game_attendance
GO
select * 
    from V_goal_att

--Shots against and goalie save percentage
GO
drop view v_goalie_sa_sp
GO
create view v_goalie_sa_sp as 
    select p.player_name as player, sum(gs.goalie_sa) / count(distinct gs.game_id) as shots_against,
        sum(gs.goalie_sv) / count(distinct gs.game_id) as saves, 
        round((CAST(SUM(gs.goalie_sv) AS float) / CAST(SUM(gs.goalie_sa) AS float)), 3) AS save_pct
        from game_goalie_stats as gs
        join players as p on gs.player_id = p.player_id
        group by p.player_id, p.player_name
go
select *
    from v_goalie_sa_sp
    order by save_pct desc

--which divisions and positions have the best plus minus 
GO
drop view v_div_pos_pm
GO
create view v_div_pos_pm as
    select t.team_division as division, p.player_position as position, sum(g.player_plus_minus) as plus_minus
        from teams as t
        join players as p on t.team_id = p.player_team_id
        join game_player_stats as g on p.player_id = g.player_id
        group by t.team_division, p.player_position
GO
select * 
    from v_div_pos_pm
    order by division, position