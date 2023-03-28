alter table results
add primary key (date, home_team, away_team)

delete
from results
where date = '1974-02-17'
and home_team = 'Tahiti'
and away_team = 'New Caledonia'
and home_score = 1
and away_score = 2
		
delete
from results
where date = '1977-10-22'
and home_team = 'Guyana'
and away_team = 'Barbados'
and home_score = 0
and away_score = 0

alter table goalscorers add foreign key (date, home_team, away_team) references results(date, home_team, away_team)

delete
from shootouts
where date = '2011-06-29'
	and home_team = 'Saare County'
	and away_team = 'Åland Islands'

alter table shootouts add foreign key (date, home_team, away_team) references results(date, home_team, away_team)


query_presentazione

---(1) names of teams that have played in FIFA World Cup

select distinct home_team
	from results
	where tournament = 'FIFA World Cup'
union
select distinct away_team
	from results
	where tournament = 'FIFA World Cup'


---(2) for each team that has won a match in FIFA World Cup return name and number of matches

select o.winner, count(*) as WinCount
	from(
		select s.winner
			from shootouts s, results r
			where s.date = r.date
				and s.home_team = r.home_team
				and s.away_team = r.away_team
				and r.tournament = 'FIFA World Cup'
		union all
		select r.home_team
			from results r
			where r.home_score > r.away_score
				and r.tournament = 'FIFA World Cup'
		union all
		select r.away_team
			from results r
			where r.home_score < r.away_score
				and r.tournament = 'FIFA World Cup'
		) as o
group by o.winner
order by WinCount desc

---(3) teams that have conceded a goal by Ronaldo in a FIFA World Cup 2002 match

select distinct g.home_team
from goalscorers g, results r
where g.scorer = 'Ronaldo'
	and g.home_team <> g.team
	and g.date >= ('2002-01-01')
	and g.date <= ('2002-12-31')
	and g.date = r.date
	and g.home_team = r.home_team
	and g.away_team = r.away_team
	and r.tournament = 'FIFA World Cup'
union
select distinct g.away_team
from goalscorers g, results r
where g.scorer = 'Ronaldo'
	and g.away_team <> g.team
	and g.date >= ('2002-01-01')
	and g.date <= ('2002-12-31')
	and g.date = r.date
	and g.home_team = r.home_team
	and g.away_team = r.away_team
	and r.tournament = 'FIFA World Cup'
	
---(4) matches won by teams that have conceded a goal by Ronaldo

select distinct r.date, r.home_team, r.away_team
from results r
where r.home_team in (	select distinct g.home_team
					from goalscorers g
					where g.scorer = 'Ronaldo'
						and g.home_team <> g.team
				union
				select distinct g.away_team
					from goalscorers g
					where g.scorer = 'Ronaldo'
						and g.away_team <> g.team)
	and r.home_score > r.away_score
union
select distinct r.date, r.home_team, r.away_team
from results r
where r.away_team in (	select distinct g.home_team
					from goalscorers g
					where g.scorer = 'Ronaldo'
						and g.home_team <> g.team
				union
				select distinct g.away_team
					from goalscorers g
					where g.scorer = 'Ronaldo'
						and g.away_team <> g.team)
	and r.home_score < r.away_score
	
---(5) matches won by teams that have conceded a goal by Ronaldo