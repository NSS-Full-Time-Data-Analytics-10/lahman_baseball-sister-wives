-----INITIAL QUESTIONS-----
--1:
SELECT MAX(yearid), MIN(yearid), MAX(yearid) - MIN(yearid) AS years_covered
FROM appearances

--2:
SELECT namegiven, MIN(height)
FROM people
--ANSWER:
SELECT namegiven, height, g_all AS games_played, appearances.teamid, teams.name
FROM people INNER JOIN appearances ON people.playerid = appearances.playerid
			 INNER JOIN teams USING(teamid)
ORDER BY height
LIMIT 1;

--3:
--Players from vandy
--first & last name, total salary, desc order on salary 
SELECT people.namefirst, people.namelast, SUM(salary)::numeric::money AS total_earnings
FROM people INNER JOIN collegeplaying USING(playerid)
			INNER JOIN schools USING (schoolid)
			INNER JOIN salaries USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY people.namefirst, people.namelast
ORDER BY total_earnings DESC

--4:

--GROUPING PUTOUT TOTALS BY POSITION GROUP
----ANSWER:
SELECT SUM(po) AS total_putouts, CASE WHEN pos = 'OF' THEN 'Outfield'
			   					WHEN pos IN('1B','2B','3B','SS') THEN 'Infield'
								WHEN pos = 'P' THEN 'Battery'
			 					WHEN pos = 'C' THEN 'Battery'
			   					ELSE 'Other' END AS pos_group
FROM fielding
WHERE yearid = 2016
GROUP BY pos_group
ORDER BY total_putouts DESC;

--5:
WITH so_per_game AS (SELECT yearid, SUM(so) AS total_strikouts, SUM(g) AS total_games
					FROM pitching
					WHERE yearid >= 1920
					GROUP BY yearid)
SELECT , CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
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
FROM pitching
GROUP BY decade 



--6:

WITH total_attempts AS (SELECT yearid, playerid, (SUM(sb)+SUM(cs))::numeric AS total_attempts
						FROM batting
						WHERE yearid = 2016
						GROUP BY playerid, yearid
						ORDER BY total_attempts DESC)
SELECT batting.playerid, batting.yearid, ROUND((SUM(sb)/total_attempts * 100)::numeric,2) AS percent_sucess
FROM batting INNER JOIN total_attempts USING(playerid)
WHERE batting.yearid = 2016
	AND total_attempts >= 20
GROUP BY batting.playerid, batting.yearid, total_attempts.total_attempts
ORDER BY percent_sucess DESC


--7:






----8:

--TOP 5 PARKS WITH LOWEST AVG ATTENDANCE PER GAME
SELECT homegames.team, parks.park_name, SUM(attendance/games) AS avg_attendance_per_gm
FROM homegames INNER JOIN parks USING(park)
WHERE year = 2016
	AND games > 10
GROUP BY homegames.team, parks.park_name
ORDER BY avg_attendance_per_gm 
LIMIT 5;

--TOP 5 PARK WITH HIGHEST AVG ATTENDANCE PER GAME
SELECT homegames.team, parks.park_name, SUM(attendance/games) AS avg_attendance_per_gm
FROM homegames INNER JOIN parks USING(park)
WHERE year = 2016
	AND games > 10
GROUP BY homegames.team, parks.park_name
ORDER BY avg_attendance_per_gm DESC
LIMIT 5;

--9:

SELECT *
FROM awardsmanagers INNER JOIN people USING(playerid)
WHERE awardid = 'TSN Manager of the Year'
	AND people.namegiven = 'James Richard'

SELECT playerid, people.namegiven 					-----NL Managers who won TSN manager of year
FROM awardsmanagers INNER JOIN people USING(playerid)
WHERE Lgid = 'NL'
	AND awardid = 'TSN Manager of the Year'

SELECT playerid, people.namegiven 					-----AL Managers who won TSN manager of year
FROM awardsmanagers INNER JOIN people USING(playerid)
WHERE Lgid = 'NL'
	AND awardid = 'TSN Manager of the Year'
	
SELECT playerid, people.namegiven 					-----MANAGERS WHO WON AWARD IN BOTH THE AL & NL
FROM awardsmanagers INNER JOIN people USING(playerid)
WHERE Lgid = 'NL'
	AND awardid = 'TSN Manager of the Year'
INTERSECT
SELECT playerid, people.namegiven 					
FROM awardsmanagers INNER JOIN people USING(playerid)
WHERE Lgid = 'AL'
	AND awardid = 'TSN Manager of the Year'


-----MANAGERS WHO WON AWARD IN BOTH THE AL & NL, THE YEARS THEY WON, AND TEAMS THEY WON THE AWARD WITH.
WITH dual_winner AS (SELECT playerid, people.namegiven 					 
					FROM awardsmanagers INNER JOIN people USING(playerid)  
					WHERE Lgid = 'NL'
						AND awardid = 'TSN Manager of the Year'
					INTERSECT
					SELECT playerid, people.namegiven 					
					FROM awardsmanagers INNER JOIN people USING(playerid)
					WHERE Lgid = 'AL'
						AND awardid = 'TSN Manager of the Year')
SELECT DISTINCT people.namegiven, awardsmanagers.yearid, awardsmanagers.Lgid ,managers.teamid, teams.name, awardsmanagers.awardid
FROM people INNER JOIN dual_winner USING(playerid)
			INNER JOIN awardsmanagers USING(playerid)
			INNER JOIN managers USING(yearid,playerid)
			INNER JOIN teams USING (teamid,yearid)
WHERE awardid = 'TSN Manager of the Year'
	


--10:
-----------------------------------------------------------Players who debuted before 2006 and maximum # of homeruns in a season------------------------------------------------------------
SELECT playerid, batting.yearid, people.namefirst, people.namelast, MAX(hr) AS max_hr  
FROM batting INNER JOIN people USING(playerid)
WHERE debut::DATE <= '2006-01-01'
GROUP BY playerid, people.namefirst, people.namelast, batting.yearid
ORDER BY max_hr DESC
	
	
	
	
-------------------------------------------Players from 2016 HOMERUN COUNT and have been in the league over 10 years------------------------------------------------------
SELECT playerid, batting.hr AS homeruns_16, people.namefirst, people.namelast, MAX(b2.hr) AS max_career_homeruns    
FROM batting INNER JOIN people USING(playerid)
			 INNER JOIN batting AS b2 USING(playerid)
WHERE batting.yearid = 2016
	AND debut::date <= '2006-01-01'
GROUP BY playerid, batting.hr, people.namefirst, people.namelast
ORDER BY homeruns_16 DESC


-------------------------------------FINAL ANSWER BELOW:-----------------------------------------------------------------------
---------------------------------------------------------ALL PLAYERS WITH 10 YRS IN MLB AND HIT CAREER HIGH HOMERUNS IN 2016.-----------------------------------------
SELECT namefirst, namelast, homeruns_16
FROM (SELECT playerid, batting.hr AS homeruns_16, people.namefirst, people.namelast, MAX(b2.hr) AS max_career_homeruns 
		FROM batting INNER JOIN people USING(playerid)
					 INNER JOIN batting AS b2 USING(playerid)
		WHERE batting.yearid = 2016
			AND debut::date <= '2006-01-01'
		GROUP BY playerid, batting.hr, people.namefirst, people.namelast
		ORDER BY homeruns_16 DESC) AS homeruns
WHERE homeruns_16 >= max_career_homeruns
	AND homeruns_16 >=1
GROUP BY namefirst, namelast, homeruns_16
ORDER BY homeruns_16 DESC
	
	

	
--------------------------------OPEN ENDED QUESTIONS:------------------------------------------
-----11:
--


------------12:

WITH home_attendance AS (SELECT team, year, SUM(attendance) AS total_home_attendance
							FROM homegames
							GROUP BY team, year
							ORDER BY year ASC)
SELECT home_attendance.team, teams.name, home_attendance.year, home_attendance.total_home_attendance, teams.w, teams.wswin, teams.divwin, teams.wcwin
FROM teams INNER JOIN home_attendance ON home_attendance.team = teams.teamid
									  AND home_attendance.year =teams.yearid
WHERE year >= 1995
GROUP BY home_attendance.team,teams.name, home_attendance.year, home_attendance.total_home_attendance, teams.w, teams.wswin, teams.divwin, teams.wcwin




--13:

SELECT *  												-------CY YOUNG WINNERS
FROM awardsplayers
WHERE awardid ILIKE 'Cy%'

---------------------------------------------Having trouble with error-------------------------------------------------------
----------------------------------------------------------------------------------------ASK JARED & HUNTER 
WITH pitching_both AS 		(SELECT DISTINCT playerid, people.throws
								 FROM pitching INNER JOIN people USING(playerid))
WITH pitching_lefties AS 	(SELECT DISTINCT playerid, people.throws
								FROM pitching INNER JOIN people USING(playerid)
								WHERE throws = 'L')
WITH pitching_righties AS 	(SELECT DISTINCT playerid, people.throws
								FROM pitching INNER JOIN people USING(playerid)
								WHERE throws = 'R')
SELECT ROUND(COUNT(pitching_lefties.playerid)/COUNT(pitching_both.playerid)::numeric,2)
FROM pitching INNER JOIN pitching_both USING(playerid)
			  INNER JOIN pitching_lefties USING(playerid)
			  INNER JOIN pitching_righties USING(playerid)

						
						
						
						
						
						
						
						