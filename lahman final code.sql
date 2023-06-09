SELECT *
FROM allstarfull

SELECT *
FROM appearances

SELECT *
FROM awardsmanagers

SELECT *
FROM awardsplayers

SELECT *
FROM awardssharemanagers

SELECT *
FROM awardsshareplayers

SELECT *
FROM batting

SELECT *
FROM battingpost

SELECT *
FROM collegeplaying

SELECT *
FROM fielding

SELECT *
FROM fieldingof

SELECT *
FROM people


---1.What range of years for baseball games played does the provided database cover?---

SELECT MIN(yearid),MAX(yearid)
FROM batting

SELECT MIN(yearid),MAX(yearid)
FROM pitching

SELECT MIN(yearid),MAX(yearid)
FROM fielding

SELECT min(debut),MAX(finalgame)
FROM people

---1871 to 2017

---2.Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
---edward carl (gaedeed01)

SELECT playerid,namegiven,MIN(height)
FROM people
INNER JOIN batting
USING (playerid)
GROUP BY namegiven,playerid
ORDER BY min ASC


SELECT people.namegiven,teams.name,COUNT(DISTINCT batting.g)
FROM people
INNER JOIN batting
USING (playerid)
INNER JOIN teams
USING (teamid)
WHERE playerid='gaedeed01'
GROUP BY people.namegiven,teams.name


---3.Find all players in the database who played at Vanderbilt University.
---Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
---Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors

SELECT people.namefirst,people.namelast,SUM(salaries.salary) AS sum_mlb_salary,collegeplaying.schoolid
FROM people
INNER JOIN collegeplaying
USING (playerid)
INNER JOIN salaries
USING (PLAYERID)
WHERE schoolid ILIKE '%vand%'
GROUP BY people.namefirst,people.namelast,collegeplaying.schoolid
ORDER by sum_mlb_salary DESC


---4.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", 
---those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery".
---Determine the number of putouts made by each of these three groups in 2016.----

SELECT SUM(po) AS putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		 WHEN pos = 'SS' THEN 'Infield'
		 WHEN pos = '1B' THEN 'Infield'
		 WHEN pos = '2B' THEN 'Infield'
		 WHEN pos = '3B' THEN 'Infield'
		 WHEN pos = 'P' THEN 'Battery'
		 WHEN pos = 'C' THEN 'Battery'
		 END AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY position

---5. Find the average number of strikeouts per game by decade since 1920. 
---Round the numbers you report to 2 decimal places. 
---Do the same for home runs per game. Do you see any trends?---


select *
FROM pitching

SELECT *
FROM teams

SELECT SUM(so) AS Ks, SUM (g) AS games,ROUND(SUM(so)/SUM(g)::numeric,2) avg_ks,
	CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
		 WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		 WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		 WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		 WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		 WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		 WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		 WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		 WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		 WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
		 END AS decade
FROM teams
GROUP BY decade
ORDER BY decade


SELECT SUM(hr) AS homeruns,SUM(g) AS games,ROUND(SUM(hr)/SUM(g)::numeric,2) AS avg_homeruns,
	CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
		 WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		 WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		 WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		 WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		 WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		 WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		 WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		 WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		 WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
		 END AS decade
FROM teams
GROUP BY decade
ORDER BY decade


---6.Find the player who had the most success stealing bases in 2016,
----where success is measured as the percentage of stolen base attempts which are successful. 
---(A stolen base attempt results either in a stolen base or being caught stealing.) 
---Consider only players who attempted at least 20 stolen bases.


SELECT playerid,sb,cs,sb+cs AS sb_attempts,ROUND(sb/(sb+cs)::numeric,2)*100 AS sb_success_percentage
FROM batting
INNER JOIN people
USING (playerid)
WHERE yearid=2016
AND (sb) + (cs) >= 20
ORDER BY SB_success_percentage DESC

---7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
---What is the smallest number of wins for a team that did win the world series? 
---Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
---Then redo your query, excluding the problem year. 
---How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

---largest number of wins for a team that did not win the world series, 116


WITH wins_by_year AS				(SELECT teamid,yearid,w             ---CTE showing wins by year by team
									 FROM teams
									 WHERE yearid BETWEEN 1970 AND 2016
									 ORDER BY yearid asc)
SELECT teamid,MAX(teams.w) AS max_wins
FROM teams
INNER JOIN wins_by_year
USING (teamid)
WHERE wswin = 'N'
GROUP BY teamid
ORDER BY max_wins DESC


SELECT teamid,yearid,w
FROM teams
WHERE teamid = 'PIT'
order by yearid
---- will probably result in an unusually small number of wins for a world series champion – determine why this is the case.
--- smallest number of wins for a team that did win the world series, 63-dodgers (SHORTENED SEASON DUE TO 1981 PLAYERS STRIKE)

WITH wins_by_year AS				(SELECT teamid,yearid,w             ---CTE showing wins by year by team
									 FROM teams
									 WHERE yearid BETWEEN 1970 AND 2016
									 ORDER BY yearid asc)
SELECT teamid,MIN(teams.w) AS min_wins
FROM teams
INNER JOIN wins_by_year
USING (teamid)
WHERE wswin = 'Y'
GROUP BY teamid
ORDER BY min_wins ASC


---Then redo your query, excluding the problem year. 
---How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

----Cardinals with 83
WITH wins_by_year AS				(SELECT teamid,yearid,w             ---CTE showing wins by year by team
									 FROM teams
									 WHERE yearid >=1970
									 ORDER BY yearid asc)
SELECT teamid,teams.yearid,MIN(teams.w) AS min_wins
FROM teams
INNER JOIN wins_by_year
USING (teamid)
WHERE wswin = 'Y'
AND teams.yearid <> 1981
AND teams.yearid >=1970
GROUP BY teamid,teams.yearid
ORDER BY min_wins ASC


WITH statement AS							(WITH max_wins_year AS		(SELECT MAX(w) AS max_wins,yearid                       ----cte within ctw to percentage of time team w most wins wins ws
																	 FROM teams
																	 WHERE yearID BETWEEN 1970 AND 2016
																	 GROUP BY yearid)
							SELECT name,yearid,max_wins,w,
								(CASE WHEN max_wins = w THEN 1
								WHEN max_wins<>w THEN 0
								END) AS ws_win
							FROM teams
							INNER JOIN max_wins_year
							USING (yearid)
							WHERE wswin = 'Y')
SELECT ROUND(SUM(ws_win)/COUNT(*)::numeric,2) *100 as percent_most_wins_wins_ws
FROM statement









---8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
---(where average attendance is defined as total attendance divided by number of games). 
---Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. 
---Repeat for the lowest 5 average attendance.

SELECT team,park, ROUND(SUM(attendance)/SUM(games)::numeric,2) as avg_attendance
FROM homegames
WHERE games >=10
AND year = 2016
GROUP BY team,park
ORDER by avg_attendance DESC
LIMIT 5

SELECT team,park, ROUND(SUM(attendance)/SUM(games)::numeric,2) as avg_attendance
FROM homegames
WHERE games >=10
AND year = 2016
GROUP BY team,park
ORDER by avg_attendance ASC
LIMIT 5

---9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
---Give their full name and the teams that they were managing when they won the award.

SELECT *
FROM managers

SELECT *
FROM awardsmanagers


WITH al_and_nl_winners AS ((SELECT playerid
	  					   FROM awardsmanagers
	 					   WHERE lgid = 'NL'
	 					   AND awardid ILIKE 'TSN%')
	  					   INTERSECT
						  (SELECT playerid
 	 					   FROM awardsmanagers
	 					   WHERE lgid = 'AL'
	  					   AND awardid ILIKE 'TSN%'))		
						   
SELECT awardsmanagers.playerid,namefirst,namelast,awardsmanagers.yearid,awardsmanagers.lgid,awardsmanagers.awardid,managers.teamid
FROM people
INNER JOIN al_and_nl_winners
USING (playerid)
INNER JOIN awardsmanagers
USING (playerid)
INNER JOIN managers
USING (yearid,playerid)
WHERE awardid ILIKE 'TSN%'



---10. Find all players who hit their career highest number of home runs in 2016. 
---Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
---Report the players' first and last names and the number of home runs they hit in 2016.---


	 
SELECT people.namefirst,people.namelast,batting.hr,batting.yearid,max_hr_season.playerid,max_hr_season.MAX_HR
FROM(SELECT playerid,MAX(hr) AS max_hr
	 FROM batting
	 INNER JOIN people
	 USING (playerid)
	 GROUP BY playerid
	 ORDER BY max_hr DESC) AS max_hr_season
INNER JOIN batting
USING (playerid)
INNER JOIN people
USING (playerid)
WHERE debut::date<='2006-03-01'
AND hr = max_hr
AND batting.yearid = 2016
AND batting.hr > 0
ORDER BY hr DESC


---11. Is there any correlation between number of wins and team salary? 
---Use data from 2000 and later to answer this question. 
---As you do this analysis, keep in mind that salaries across the whole league tend to increase together, 
---so you may want to look on a year-by-year basis.

WITH total_team_salary AS (SELECT teamid, yearid,SUM(salary)::text::money AS total_salary
	  						FROM salaries
	  						WHERE yearid >= 2000
	  						GROUP BY teamid,yearid)
SELECT teamid, total_team_salary.total_salary,teams.yearid,teams.w
FROM teams
INNER JOIN total_team_salary
USING (teamid,yearid)

---12. In this question, you will explore the connection between number of wins and attendance.
---Does there appear to be any correlation between attendance at home games and number of wins?
---Do teams that win the world series see a boost in attendance the following year? 
---What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

WITH home_attendance_per_year AS (SELECT team,year,SUM(attendance) as total_home_attendance
							  FROM homegames
							  GROUP BY team,year
							  ORDER BY year ASC)
SELECT home_attendance_per_year.team,home_attendance_per_year.year,home_attendance_per_year.total_home_attendance,teams.w,teams.wswin,teams.divwin,teams.wcwin
FROM teams
INNER JOIN home_attendance_per_year
ON home_attendance_per_year.team=teams.teamid
AND home_attendance_per_year.year=teams.yearid
WHERE year >=1995


select *
FROM teams

SELECT *
FROM homegames


---13.It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. 
---Investigate this claim and present evidence to either support or dispute this claim.
---First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 
---Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?



WITH pitching_both AS 		(SELECT DISTINCT playerid,throws  ---all pitchers
						 	 FROM pitching
						 	 INNER JOIN people
						 	 USING (playerid)),
pitching_lefties AS			(SELECT DISTINCT playerid,throws --left handed pitchers
						 	 FROM pitching
						 	 INNER JOIN people
						 	 USING (playerid)
						 	 WHERE throws = 'L'),							 
pitching_righties AS		(SELECT DISTINCT playerid,throws ---right handed pitcher
						 	 FROM pitching
						 	 INNER JOIN people
						 	 USING (playerid)
						 	 WHERE throws = 'R')
SELECT ROUND(COUNT(DISTINCT pitching_lefties.playerid)/COUNT(DISTINCT pitching_both.playerid)::numeric,2)*100 AS percentage_lefty_pitchers  --lefties divided by all pitchers = ~27%
FROM pitching
LEFT JOIN pitching_both
USING (playerid)
LEFT JOIN pitching_lefties
USING (playerid)
LEFT JOIN pitching_righties
USING (playerid)


---cy young award with ctes

WITH pitching_both AS 		(SELECT DISTINCT playerid						---all pitchers who won cy young
						 	 FROM pitching
						 	 INNER JOIN people
						 	 USING (playerid)
							 INNER JOIN awardsplayers
							 USING (playerid,yearid)
							 WHERE awardid ILIKE '%CY%'),
pitching_lefties AS			(SELECT DISTINCT playerid					---all LEFTY pitchers who won cy young
						 	 FROM pitching
						 	 INNER JOIN people
						 	 USING (playerid)
							 INNER JOIN awardsplayers
							 USING (playerid,yearid)
							 WHERE awardid ILIKE '%CY%'
							 AND throws = 'L')						 
SELECT ROUND(COUNT(pitching_lefties.playerid)/COUNT(pitching_both.playerid)::numeric,2) *100 AS percentage_lefty_pitchers_cy_young          ---Percentage of cy young winners that throw lefty
FROM pitching
LEFT JOIN pitching_both
USING (playerid)
LEFT JOIN pitching_lefties
USING (playerid)


---cy youngs with case statements

WITH pitching_both AS 		(SELECT DISTINCT playerid,yearid,awardsplayers.lgid,teamid,people.throws,
							 	(CASE WHEN people.throws = 'L' THEN 1
							 	ELSE 0 END)	AS lefties															---all pitchers who won cy young
						 	 FROM pitching
						 	 INNER JOIN people
						 	 USING (playerid)
							 INNER JOIN awardsplayers
							 USING (playerid,yearid)
							 WHERE awardid ILIKE '%CY%')
SELECT ROUND(SUM(lefties)/COUNT(*)::numeric,2) AS percentage_lefties_cy_young
FROM pitching_both


---hall of fame



WITH pitching_both AS 		(SELECT DISTINCT playerid		---all pitchers in HOF
						 	 FROM pitching
						 	 INNER JOIN people
						 	 USING (playerid)
							 INNER JOIN halloffame
							 USING (playerid)
							 WHERE inducted = 'Y'),
pitching_lefties AS			(SELECT DISTINCT playerid		---all LEFTY pitchers in HOF
						 	 FROM pitching
						 	 INNER JOIN people
						 	 USING (playerid)
							 INNER JOIN halloffame
							 USING (playerid)
							 WHERE inducted = 'Y'
							 AND people.throws = 'L')
SELECT ROUND(COUNT(pitching_lefties)/COUNT(pitching_both)::numeric,2)*100 AS percent_lefty_pitchers_HOF
FROM pitching_both
LEFT JOIN pitching_lefties
USING(playerid)
