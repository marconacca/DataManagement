DROP TABLE IF EXISTS goalscorers CASCADE;
CREATE TABLE  goalscorers
(date VARCHAR(100) NOT NULL,
home_team VARCHAR(100),
away_team VARCHAR(100),
team VARCHAR(100) check (team = home_team or team = away_team),
scorer VARCHAR(100),
minute_ INT check (minute_ >= 0 and minute_ <= 125),
own_goal BOOLEAN NOT NULL,
penalty BOOLEAN NOT NULL
);

DROP TABLE IF EXISTS results CASCADE;
CREATE TABLE  results
(date VARCHAR(100)NOT NULL,
home_team VARCHAR(100),
away_team VARCHAR(100),
home_score INT,
away_score INT,
tournament VARCHAR(100),
city VARCHAR(100),
country VARCHAR(100),
neutral boolean not null
);

DROP TABLE IF EXISTS shootouts CASCADE;
CREATE TABLE  shootouts
(date VARCHAR(100)NOT NULL,
home_team VARCHAR(100),
away_team VARCHAR(100),
winner VARCHAR(100) check (winner = home_team or winner = away_team)
);

alter table goalscorers alter column date type date using date::date;
alter table results alter column date type date using date::date;
alter table shootouts alter column date type date using date::date;

