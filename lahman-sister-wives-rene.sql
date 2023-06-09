

--1. What range of years for baseball games played does the provided database cover? 
SELECT MIN(debut), MAX(finalgame)
FROM people
---"1871-05-04"  to  "2017-04-03"

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT namegiven, MIN(height), debut, finalgame, playerid, retroid 
FROM people
GROUP BY namegiven, debut, finalgame, playerid, retroid
ORDER BY MIN(height) ASC
--"Edward Carl" aka EDDIE GAEDEL 43"	"1951-08-19" TO "1951-08-19"  1 game "St. Louis Browns"

SELECT playerid, namefirst, namelast, namegiven, MIN(height), debut, finalgame, teamid, name 
FROM people
LEFT JOIN appearances
USING (playerid)
LEFT JOIN teams
USING (teamid)
GROUP BY namegiven, debut, finalgame, playerid, teamid, name, namefirst, namelast
ORDER BY MIN(height) ASC
LIMIT 1;

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT namefirst, namelast, SUM(salary) AS total_salary
FROM collegeplaying
INNER JOIN schools
USING (schoolid)
INNER JOIN people
USING (playerid)
INNER JOIN salaries
USING (playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY namefirst, namelast
ORDER BY total_salary DESC
----"David"	"Price"	245553888
----"Pedro"	"Alvarez"	62045112
----"Scott"	"Sanderson"	21500000
----"Mike"	"Minor"	20512500
----"Joey"	"Cora"	16867500
----"Mark"	"Prior"	12800000
----"Ryan"	"Flaherty"	12183000
----"Josh"	"Paul"	7920000
----"Sonny"	"Gray"	4627500
----"Mike"	"Baxter"	4188836
----"Jensen"	"Lewis"	3702000
----"Matt"	"Kata"	3180000
----"Nick"	"Christiani"	2000000
----"Jeremy"	"Sowers"	1154400
----"Scotti"	"Madison"	540000


--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT SUM(po),
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	WHEN pos IN ('P', 'C') THEN 'Battery' END AS position
FROM fielding
WHERE yearid = 2016
GROUP BY position
---41424	"Battery"
---58934	"Infield"
---29560	"Outfield"

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT SUM(so) AS strikeouts, SUM(g) AS games,ROUND(SUM(so)/SUM(g)::numeric,2) avg_strikeouts,  CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
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
---2.81	"1920s"
---3.32	"1930s"
---3.55	"1940s"
---4.40	"1950s"
---5.72	"1960s"
---5.14	"1970s"
---5.36	"1980s"
---6.15	"1990s"
---6.56	"2000s"
---7.52	"2010s"

--------

SELECT SUM(hr) AS homeruns, SUM(g) AS games,ROUND(SUM(hr)/SUM(g)::numeric,2) avg_homeruns,  		CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
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
---0.40	"1920s"
---0.55	"1930s"
---0.52	"1940s"
---0.84	"1950s"
---0.82	"1960s"
---0.75	"1970s"
---0.81	"1980s"
---0.96	"1990s"
---1.07	"2000s"
---0.98	"2010s"


--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT playerid,sb,cs,sb+cs AS sb_attempts,ROUND(sb/(sb+cs)::numeric,2)*100 AS sb_success_percentage
FROM batting
INNER JOIN people
USING (playerid)
WHERE yearid=2016
AND (sb) + (cs) >= 20
ORDER BY SB_success_percentage DESC
----"Christopher Scott"	"owingch01"	2016	91.00% success stealing bases in 2016


--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT yearid, teamid, w, wswin, name
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'N'
ORDER BY w DESC
--2001	"SEA"	116	"N"	"Seattle Mariners" - LARGEST WINS FORA  TEAM THAT DID NOT WIN THE WORLD SERIES.

SELECT yearid, teamid, w, wswin, name
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
ORDER BY w ASC
--1981	"LAN"	63	"Y"	"Los Angeles Dodgers" - SMALLEST WINS FOR A TEAM THAT DID WIN THE WORLD SERIES

SELECT yearid, teamid, w, wswin, name
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
	AND wswin = 'Y'
ORDER BY w ASC
--2006	"SLN"	83	"Y"	"St. Louis Cardinals" - BECAUSE THERE WAS A PLAYERS STRIKE IN 1981

WITH max_wins AS (SELECT yearid, MAX(w) AS max_wins
					FROM teams
					GROUP BY yearid) 

SELECT yearid, w, max_wins, wswin, name,
	CASE WHEN w = max_wins THEN 1
	ELSE 0 END AS max_win_years
FROM teams
INNER JOIN max_wins
USING (yearid)
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
GROUP BY yearid, w, wswin, name, max_wins
ORDER BY yearid;

WITH max_win_years AS (WITH max_wins AS (SELECT yearid, MAX(w) AS max_wins
					FROM teams
					WHERE yearid BETWEEN 1970 AND 2016
					GROUP BY yearid)					
	SELECT yearid, name, max_wins,
		CASE WHEN w = max_wins THEN 1
		ELSE 0 END AS max_win_years
	FROM teams
	INNER JOIN max_wins
	USING (yearid)
	WHERE yearid BETWEEN 1970 AND 2016
		AND wswin = 'Y'
	GROUP BY yearid, name, w, max_wins)

SELECT ROUND((SUM(max_win_years::numeric)/COUNT(max_wins::numeric))::numeric * 100, 2) AS percent
FROM teams
LEFT JOIN max_win_years
USING (yearid, name)
WHERE yearid BETWEEN 1970 AND 2016

-----12 OUT OF 47 YEARS OR 26.09% OF THE TIME


--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT team, park, attendance/games AS avg_attendance
FROM homegames
WHERE year = 2016
 AND games >= 10
ORDER BY avg_attendance DESC 
LIMIT 5
---"LAN"	"LOS03"	45719
---"SLN"	"STL10"	42524
---"TOR"	"TOR02"	41877
---"SFN"	"SFO03"	41546
---"CHN"	"CHI11"	39906

SELECT team, park, attendance/games AS avg_attendance
FROM homegames
WHERE year = 2016
 AND games >= 10
ORDER BY avg_attendance ASC 
LIMIT 5
---"TBA"	"STP01"	15878
---"OAK"	"OAK01"	18784
---"CLE"	"CLE08"	19650
---"MIA"	"MIA02"	21405
---"CHA"	"CHI12"	21559

---9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

(SELECT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid = 'NL')
INTERSECT
(SELECT playerid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
AND lgid = 'AL')
--"leylaji99"
--"johnsda02"
	
SELECT namefirst, namelast, teamid, playerid, awardid, awardsmanagers.yearid, awardsmanagers.lgid
FROM awardsmanagers
LEFT JOIN people
USING (playerid)
LEFT JOIN managers
USING (playerid, yearid)
WHERE awardid = 'TSN Manager of the Year'
	AND playerid = 'leylaji99'
	OR playerid = 'johnsda02'
	AND awardid <> 'BBWAA Manager of the Year'
GROUP BY awardsmanagers.yearid, playerid, awardid, awardsmanagers.lgid, namefirst, namelast,  teamid
---"Jim"	"Leyland"	"PIT"	"leylaji99"	"TSN Manager of the Year"	1988	"NL"
---"Jim"	"Leyland"	"PIT"	"leylaji99"	"TSN Manager of the Year"	1990	"NL"
---"Jim"	"Leyland"	"PIT"	"leylaji99"	"TSN Manager of the Year"	1992	"NL"
---"Davey"	"Johnson"	"BAL"	"johnsda02"	"TSN Manager of the Year"	1997	"AL"
---"Jim"	"Leyland"	"DET"	"leylaji99"	"TSN Manager of the Year"	2006	"AL"
---"Davey"	"Johnson"	"WAS"	"johnsda02"	"TSN Manager of the Year"	2012	"NL"

----11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

WITH team_salary AS (SELECT salaries.yearid, teamid, SUM(salary) AS team_salary
					FROM salaries
					WHERE salaries.yearid >= 2000
					GROUP BY teamid, salaries.yearid
					ORDER BY salaries.yearid ASC)

SELECT teamid, teams.yearid, w, team_salary::text::money
FROM teams
INNER JOIN team_salary
USING (teamid,yearid)
WHERE teams.yearid >= 2000
GROUP BY teamid, teams.yearid, w, team_salary
ORDER BY teams.yearid ASC

----12. In this question, you will explore the connection between number of wins and attendance.
------Does there appear to be any correlation between attendance at home games and number of wins?
------Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.
SELECT year, teamid, homegames.attendance, w, l
FROM homegames
INNER JOIN teams
ON homegames.year = teams.yearid AND homegames.team = teams.teamid
WHERE homegames.attendance > 0

SELECT year, team, teamid, homegames.attendance, w
FROM homegames
INNER JOIN teams
ON homegames.year = teams.yearid AND homegames.team = teams.teamid
WHERE wswin = 'Y'
ORDER BY homegames.attendance DESC



WITH attend_per_year AS (SELECT year, team, SUM(attendance) AS home_attendance
						FROM homegames
						GROUP BY year, team
						ORDER BY year ASC)
SELECT attend_per_year.team, attend_per_year.year, attend_per_year.home_attendance, teams.w, teams.wswin, teams.divwin, teams.wcwin
FROM teams
INNER JOIN attend_per_year
ON attend_per_year.team = teams.teamid
AND attend_per_year.year = teams.yearid
WHERE year >= 1995
ORDER BY team

WITH attend_per_year AS (SELECT year, team, SUM(attendance) AS home_attendance
						FROM homegames
						GROUP BY year, team
						ORDER BY year ASC)
SELECT attend_per_year.team, attend_per_year.year, attend_per_year.home_attendance, teams.w, teams.wswin, teams.divwin, teams.wcwin
FROM teams
INNER JOIN attend_per_year
ON attend_per_year.team = teams.teamid
AND attend_per_year.year = teams.yearid
WHERE year >= 1995
	AND wswin = 'Y'
	OR divwin = 'Y'
	OR wcwin = 'Y'
ORDER BY team