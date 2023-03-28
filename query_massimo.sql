alter table goalscorers alter column date type date using date::date;
alter table results alter column date type date using date::date;
alter table shootouts alter column date type date using date::date;

CREATE TABLE  goalscorers
(date DATE NOT NULL,
home_team CHAR(100),
away_team CHAR(100),
team CHAR(100),
scorer CHAR(100),
minute INT,
own_goal BOOLEAN NOT NULL,
penalty BOOLEAN NOT NULL
);

COPY goalscorers(date, home_team, away_team, team, scorer, minute,own_goal, penalty)
FROM 'C:\Program Files\PostgreSQL\13\scripts\goalscorers2.csv'
WITH (FORMAT CSV, HEADER);

CREATE TABLE  results
(date DATE NOT NULL,
home_team CHAR(100),
away_team CHAR(100),
home_score INT,
away_score INT,
tournament CHAR(100),
city CHAR(100),
country CHAR(100),
neutral boolean not null
);

COPY results(date, home_team, away_team, home_score, away_score, tournament,city, country,neutral)
FROM 'C:\Program Files\PostgreSQL\13\scripts\results.csv'
WITH (FORMAT CSV, HEADER);


CREATE TABLE  shootouts
(date DATE NOT NULL,
home_team CHAR(100),
away_team CHAR(100),
winner CHAR(100)
);

COPY shootouts(date, home_team, away_team, winner)
FROM 'C:\Program Files\PostgreSQL\13\scripts\shootouts.csv'
WITH (FORMAT CSV, HEADER);


====================================================================================================

---a nomi delle squadre che hanno partecipato a FIFA World Cup

select distinct home_team
from results
where tournament = 'FIFA World Cup'
union
select distinct away_team
from results
where tournament = 'FIFA World Cup'

---b nomi delle squadre che hanno subito gol da Gianfranco Zola
select distinct home_team
from goalscorers
where scorer = 'Gianfranco Zola'
	and home_team <> team
union
select distinct away_team
from goalscorers
where scorer = 'Gianfranco Zola'
	and away_team <> team	
	
---c nomi delle squadre che hanno subito gol da Gianfranco Zola nel 1995
select distinct home_team
from goalscorers
where scorer = 'Gianfranco Zola'
	and home_team <> team
	and date >= ('1995-01-01')
	and date <= ('1995-12-31')
union
select distinct away_team
from goalscorers
where scorer = 'Gianfranco Zola'
	and away_team <> team
	and date >= ('1995-01-01')
	and date <= ('1995-12-31')
	
---d nomi dei giocatori che hanno segnato almeno un gol nel 1995
select distinct scorer
from goalscorers
where date >= ('1995-01-01')
	and date <= ('1995-12-31')

---e partite vinte dalle squadre che hanno subito gol da Gianfranco Zola
select distinct r.date, r.home_team, r.away_team
from results r
where r.home_team in (	select distinct g.home_team
					from goalscorers g
					where g.scorer = 'Gianfranco Zola'
						and g.home_team <> g.team
				union
				select distinct g.away_team
					from goalscorers g
					where g.scorer = 'Gianfranco Zola'
						and g.away_team <> g.team)
	and r.home_score > r.away_score
union
select distinct r.date, r.home_team, r.away_team
from results r
where r.away_team in (	select distinct g.home_team
					from goalscorers g
					where g.scorer = 'Gianfranco Zola'
						and g.home_team <> goalscorers.team
				union
				select distinct g.away_team
					from goalscorers g
					where g.scorer = 'Gianfranco Zola'
						and g.away_team <> goalscorers.team)
	and r.home_score > r.away_score


---f nomi di giocatori che hanno segnato in partite finite ai rigori
select g.scorer
from goalscorers g, shootouts s
where s.home_team = g.home_team
	and s.away_team = g.away_team
	and s.date = g.date

---g 

---h per ogni squadra ritorna la media di gol segnati a partita

---h.1 per ogni squadra ritorna la media di gol segnati a partita in casa ai mondiali
select home_team, avg(home_score)
from results
where tournament = 'FIFA World Cup'
group by home_team
order by avg(home_score) desc
---h.2 per ogni squadra ritorna la media di gol segnati a partita in trasferta ai mondiali
select away_team, avg(away_score)
from results
where tournament = 'FIFA World Cup'
group by away_team
order by avg(away_score) desc
---h.3 per ogni squadra ritorna il numero di gol segnati in casa ai mondiali
select home_team, count(home_score)
from results
where tournament = 'FIFA World Cup'
group by home_team
order by count(home_score) desc
---h.4 per ogni squadra ritorna il numero di gol segnati in trasferta ai mondiali
select away_team, count(away_score)
from results
where tournament = 'FIFA World Cup'
group by away_team
order by count(away_score) desc

---i per ogni squadra ritorna la squadra e il numero di partite in cui ha segnato almeno 4 gol ma ha perso

select home_team, count(*)
from results
where home_score > 3
	and home_score < away_score
group by home_team
union
select away_team, count(*)
from results
where away_score > 3
	and home_score > away_score
group by away_team

---j squadre che hanno fatto almeno 'numero gol' nel 'anno'

---j squadre che hanno fatto almeno 'numero gol' nel 'anno'

select results.home_team, sum(results.home_score) as sum_goal
	from results
	where results.date > '1995-01-01' and results.date < '1995-12-31'
	group by results.home_team
	having(sum(results.home_score) >= 10)
	
union

select results.away_team, sum(results.away_score) as sum_goal
	from results
	where results.date > '1995-01-01' and results.date < '1995-12-31'
	group by results.away_team
	having(sum(results.away_score) >= 10)


---k squadra che ha segnato più gol nei tempi supplementari


SELECT *
	FROM(
		SELECT o.home_team, sum(GoalCount) AS GoalSum
			FROM(
				SELECT g.home_team, count(*) AS GoalCount
					FROM goalscorers g
					WHERE g.home_team = g.team
						AND g.minute > 90
						GROUP BY g.home_team
				UNION
				SELECT g.away_team, count(*) AS GoalCount
					FROM goalscorers g
					WHERE g.away_team = g.team
						AND g.minute > 90
					GROUP BY g.away_team
				) AS o
		GROUP BY o.home_team
		) AS n
	WHERE GoalSum =
		(
		SELECT max(GoalSum) as GoalMax
			FROM(
				SELECT o.home_team, sum(GoalCount) AS GoalSum
					FROM(
						SELECT g.home_team, count(*) AS GoalCount
							FROM goalscorers g
							WHERE g.home_team = g.team
								AND g.minute > 90
							GROUP BY g.home_team
						UNION
						SELECT g.away_team, count(*) AS GoalCount
							FROM goalscorers g
							WHERE g.away_team = g.team
								AND g.minute > 90
							GROUP BY g.away_team
						) AS o
					GROUP BY o.home_team
				) AS n
		)


---k.1 squadre che hanno segnato nei tempi supplementari e quanti gol hanno fatto

select o.home_team, sum(o.count)
from (select s.home_team, count(*) 
	from results r, goalscorers s
	where r.home_team = s.home_team
		and r.away_team = s.away_team
		and r.date = s.date
		and s.team = r.home_team
		and s.minute > 90
	group by s.home_team
	union
	select s.away_team, count(*)
	from results r, goalscorers s
	where r.away_team = s.away_team
		and r.home_team = s.home_team
		and r.date = s.date	
		and s.team = r.away_team
		and s.minute > 90
	group by s.away_team
	) AS o
group by o.home_team
order by sum(o.count) desc

---k squadra che ha segnato più gol nei tempi supplementari ai mondiali in partite finite ai rigori
SELECT *
	FROM(	
		SELECT g.team, count(*) as GoalCount
			FROM goalscorers g, results r, shootouts s
			WHERE g.minute > 90
				AND g.date = r.date
				AND g.date = s.date
				AND	g.home_team = r.home_team
				AND g.home_team = s.home_team
				AND g.away_team = r.away_team
				AND g.away_team = s.away_team
				AND r.tournament = 'FIFA World Cup'
			GROUP BY g.team
		) AS o
	WHERE o.GoalCount in 	(
						SELECT max(o.GoalCount)
							FROM(
								SELECT g.team, count(*) as GoalCount
									FROM goalscorers g, results r, shootouts s
									WHERE g.minute > 90
										AND g.date = r.date
										AND g.date = s.date
										AND	g.home_team = r.home_team
										AND g.home_team = s.home_team
										AND g.away_team = r.away_team
										AND g.away_team = s.away_team
										AND r.tournament = 'FIFA World Cup'
								GROUP BY g.team							
								) AS o
						)



---k.3 squadra che ha segnato più gol ai supplementari ai mondiali in partite che non sono finite ai rigori

CREATE VIEW goalcount(team, goalcount) AS
	SELECT g.team, COUNT(*) AS GoalCount
		FROM goalscorers g,
		(
			SELECT r.date, r.home_team, r.away_team 
				FROM goalscorers g, results r
				WHERE g.minute > 90
					AND g.date = r.date
					AND	g.home_team = r.home_team
					AND g.away_team = r.away_team
					AND r.tournament = 'FIFA World Cup'
			EXCEPT
			SELECT r.date, s.home_team, s.away_team
				FROM goalscorers g, shootouts s, results r
				WHERE g.minute > 90
					AND g.date = s.date
					AND g.date = r.date
					AND g.home_team = r.home_team
					AND g.away_team = r.away_team
					AND g.home_team = s.home_team
					AND g.away_team = s.away_team
					AND r.tournament = 'FIFA World Cup'
		) AS o
		WHERE g.date = o.date
			AND g.home_team = o.home_team
			AND g.away_team = o.away_team
			AND g.minute > 90
		GROUP BY g.team
		ORDER BY GoalCount DESC

------------------------------------------------------------

SELECT goalcount.team, goalcount.goalcount
	FROM goalcount
	WHERE goalcount.goalcount = (SELECT MAX(goalcount.goalcount) FROM goalcount)



più compatta:
---k.3 squadra che ha segnato più gol ai supplementari ai mondiali in partite che non sono finite ai rigori

CREATE VIEW extratimegoals(team, goalcount) AS
	SELECT g.team, COUNT(*) AS GoalCount
		FROM goalscorers g,
		(
			SELECT r.date, r.home_team, r.away_team, r.tournament
				FROM results r
			EXCEPT
			SELECT r.date, r.home_team, r.away_team, r.tournament
				FROM shootouts s, results r
				WHERE s.date = r.date
					AND s.home_team = r.home_team
					AND s.away_team = r.away_team
		) AS o
		WHERE g.date = o.date
			AND g.home_team = o.home_team
			AND g.away_team = o.away_team
			AND o.tournament = 'FIFA World Cup'
			AND g.minute > 90
			
		GROUP BY g.team
		ORDER BY GoalCount DESC

------------------------------------------------------------

SELECT etg.team, etg.goalcount
	FROM extratimegoals etg
	WHERE etg.goalcount = (SELECT MAX(etg.goalcount) FROM extratimegoals etg)



---l giocatori che hanno segnato ai mondiali e quanti gol hanno fatto
SELECT s.scorer, count(*) AS GoalCount
	FROM
	(
		SELECT r.date, r.home_team, r.away_team, g.scorer
			FROM results r, goalscorers g
			WHERE r.tournament = 'FIFA World Cup'
				AND r.date = g.date
				AND r.home_team = g.home_team
				AND r.away_team = g.away_team
	) AS s
	GROUP BY s.scorer
	ORDER BY GoalCount DESC

