delete from results
where date = '1974-02-17'
 	and home_team = 'Tahiti'
		and away_team = 'New Caledonia'
			and home_score = 1
				and away_score = 2
				
ALTER TABLE results ADD PRIMARY KEY (date, home_team, away_team);

ALTER TABLE goalscorers ADD FOREIGN KEY (date, home_team, away_team) REFERENCES results(date, home_team, away_team)

delete
from shootouts
where date = '2011-06-29'
	and home_team = 'Saare County'
	and away_team = 'Åland Islands'
	
ALTER TABLE shootouts ADD FOREIGN KEY (date, home_team, away_team) REFERENCES results(date, home_team, away_team)

