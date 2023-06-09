-------1.  What range of years for baseball games played does the provided database cover? 
SELECT MIN(year), MAX(year), MAX(year)-MIN(year) || ' years' AS total FROM homegames;

SELECT LEFT(MIN(debut),4), LEFT(MAX(finalgame),4) FROM people;


----------2. Find the name and height of the shortest player in the database. What range of years for baseball games played does the provided database cover? 
SELECT playerid, height, namefirst, namelast, namegiven, teams.name, g_all FROM people
INNER JOIN appearances
	USING(playerid)
INNER JOIN teams
	USING(teamid)
ORDER BY height
LIMIT 1;

---------3. Find all players in the database who played at Vanderbilt University. 
------------Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
------------Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT playerid, namefirst, namelast, SUM(salary)::text::money AS total_salary FROM collegeplaying
INNER JOIN schools
	USING(schoolid)
INNER JOIN salaries
	USING(playerid)
INNER JOIN people
	USING(playerid)
WHERE schoolname ILIKE 'vanderbilt university'
GROUP BY playerid, namefirst, namelast
ORDER BY total_salary DESC;

--------4. Using the fielding table, group players into three groups based on their position: 
-----------label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
-----------Determine the number of putouts made by each of these three groups in 2016.
SELECT (CASE WHEN pos = 'OF' THEN 'Outfield'
		 		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield' 
		 		WHEN pos IN ('P', 'C') THEN 'Battery' END) AS position,
		SUM(po) AS total_po
FROM fielding
WHERE yearid = '2016'
GROUP BY position;

----------5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
-------------Do the same for home runs per game. Do you see any trends?
SELECT AVG(so) OVER(PARTITION BY yearid ORDER BY yearid ROWS BETWEEN 9 PRECEEDING AND CURRENT ROW) AS avg_so, 
		AVG(hr) OVER(PARTITION BY yearid ORDER BY yearid ROWS BETWEEN 9 PRECEEDING AND CURRENT ROW) AS avg_hr,
FROM people
INNER JOIN batting
	USING(playerid)
WHERE yearid >= 1920;

SELECT yearid, hr, g, ROUND((hr/g),2) FROM teams
WHERE yearid BETWEEN 2000 AND 2009
GROUP BY yearid, hr, g
ORDER BY yearID desc

SELECT ROUND(SUM(hr)/SUM(g),15), yearid FROM teams
GROUP BY yearid
ORDER BY yearid

SELECT SUM(hr) AS homeruns,SUM(g) AS games, ROUND((SUM(hr)::numeric/SUM(g)),2) AS avg_homeruns,
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
ORDER BY decade;


--------6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. 
-----------(A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

WITH sb_success_rate AS			(SELECT playerid, sb, cs, ROUND((sb::numeric/(sb+cs)),2) AS sb_percent FROM batting
								 WHERE  sb > 0
									AND cs > 0
									AND sb+cs >= 20
									AND yearid = 2016
								ORDER BY sb_percent DESC)					------CTE to calculate stolen base success rate
SELECT playerid, namefirst, namelast, sb, cs, sb_percent FROM sb_success_rate
INNER JOIN people USING(playerid)
ORDER BY playerid;											------join people to display name





--------7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a 
-----------team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine 
-----------why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins 
-----------also won the world series? What percentage of the time?

SELECT MIN(w) FROM teams               -----LEAST WINS OF WS CHAMPS
			WHERE yearid >= 1970
			AND wswin = 'Y'
			AND yearid != 1981;

SELECT teamid, franchid, yearid, w     -----TEAM OF LEAST WINS OF WS CHAMP
FROM teams
WHERE 	wswin = 'Y'
		AND yearid >= 1970
		AND w = (SELECT MIN(w) FROM teams 
			WHERE yearid >= 1970
			AND wswin = 'Y'
			AND yearid != 1981)				
					
SELECT teamid, franchid, yearid, w
FROM teams
WHERE wswin = 'N'
	AND yearid >= 1970
	AND w = (SELECT MAX(w)-----MOST WINS OF NON WS CHAMPS
			FROM teams 
			WHERE yearid >= 1970
				AND wswin = 'N');


WITH max_wins AS (SELECT yearid, MAX(w) AS max_w   ----------max wins per year 
				  FROM teams
					GROUP BY yearid)
SELECT name, yearid, w, max_w,
		(CASE WHEN w = max_w THEN 1				-------CASE STATEMENT TO DETERMINE IF WS CHAMP HAD MOST WINS (1 FOR TRUE. 0 FOR FALSE)
	 		ELSE 0 END) AS ws_and_most_wins
FROM teams
INNER JOIN max_wins
USING(yearid)
WHERE yearid >= 1970
	AND wswin = 'Y'



WITH list AS (WITH max_wins AS (SELECT yearid, MAX(w) AS max_w    
				  FROM teams
					GROUP BY yearid)							------- CTE to determine max wins each year
SELECT name, yearid, w, max_w,
		(CASE WHEN w = max_w THEN 1
	 		ELSE 0 END) AS ws_and_most_wins
FROM teams
INNER JOIN max_wins
USING(yearid)
WHERE yearid >= 1970
	AND wswin = 'Y')						------- CTE to show if the WS champs also had most wins that season. 1 = True 0 = False,
SELECT ROUND((SUM(ws_and_most_wins)::numeric/COUNT(*))*100,2) FROM list        ------- PERCENT OF TIME THE WS CHAMPS ALSO HAD MOST WINS OF SEASON




--------8. Using the attendance figures from the homegames table, find the teams and parks which had the 
-----------top 5 average attendance per game in 2016 (where average attendance is defined as total attendance 
-----------divided by number of games). Only consider parks where there were at least 10 games played. 
-----------Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT * FROM homegames
WHERE year = 2016
AND team = 'LAA'

(SELECT park, team, ROUND(attendance/games,0) AS avg_attendance   -----------top 5 avg attendance
FROM homegames
WHERE year = 2016
	AND games > 10
ORDER BY avg_attendance DESC
LIMIT 5)
UNION
(SELECT park, team, ROUND(attendance/games,0) AS avg_attendance   -----------bottom 5 avg attendance
FROM homegames
WHERE year = 2016
	AND games > 10
ORDER BY avg_attendance
LIMIT 5)
ORDER BY avg_attendance DESC;

--------9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)?
-----------Give their full name and the teams that they were managing when they won the award.

WITH awards_both_leagues AS ((SELECT playerid FROM awardsmanagers           ---------------intersect to find managers with award in both leagues
							WHERE awardid = 'TSN Manager of the Year'
								AND lgid = 'NL')
							INTERSECT
							(SELECT playerid FROM awardsmanagers
							WHERE awardid = 'TSN Manager of the Year'
								AND lgid = 'AL'))
SELECT namefirst, namelast, yearid, teamid, awardid, awardsmanagers.lgid FROM awards_both_leagues
INNER JOIN awardsmanagers USING(playerid)
INNER JOIN people USING (playerid)
LEFT JOIN managers USING (playerid,yearid)
WHERE awardid = 'TSN Manager of the Year'
GROUP BY namefirst, namelast, yearid, teamid, awardid, awardsmanagers.lgid


SELECT * FROM managers
WHERE playerid = 'leylaji99'
	OR playerid = 'johnsda02'




----------10. Find all players who hit their career highest number of home runs in 2016.
--------------Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--------------Report the players' first and last names and the number of home runs they hit in 2016.


WITH max_hr AS (SELECT playerid, MAX(hr) AS max_hrs FROM batting
				GROUP BY playerid)
				
SELECT namefirst, namelast, playerid, max_hrs, hr, yearid FROM max_hr
INNER JOIN batting USING(playerid)
INNER JOIN people USING(playerid)
WHERE max_hrs = hr
	AND yearid = 2016
	AND max_hrs > 0
	AND debut::date < '2006-03-01'


-----------11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question.
---------------As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.


WITH team_salary AS (SELECT teamid, yearid, SUM(salary)::text::money AS salary_total FROM salaries
					WHERE yearid >= 2000
					GROUP BY teamid, yearid
					ORDER BY yearid)
					
SELECT teamid, name, salary_total, yearid, w, l, ROUND((w::numeric/(w::numeric+l::numeric)*100),2) AS percent_wins FROM teams
INNER JOIN team_salary USING(teamid,yearid)
WHERE yearid >= 2000





-----------12. In this question, you will explore the connection between number of wins and attendance.
---------------Does there appear to be any correlation between attendance at home games and number of wins? 
---------------Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? 
---------------Making the playoffs means either being a division winner or a wild card winner.

SELECT * FROM homegames




-----------13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective.
---------------Investigate this claim and present evidence to either support or dispute this claim. 
---------------First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? 
---------------Are they more likely to make it into the hall of fame?

SELECT namefirst, namelast, throws FROM pitching
INNER JOIN people USING(playerid);

WITH total_right AS (SELECT DISTINCT playerid, throws FROM pitching               -----#of Rightys
					INNER JOIN people USING(playerid)
					WHERE throws = 'R'),

WITH total_left AS  (SELECT DISTINCT playerid, throws FROM pitching               -----#of Leftys
					INNER JOIN people USING(playerid)
					WHERE throws = 'L'),

total_both AS (SELECT DISTINCT playerid, throws FROM pitching							-----#of All Pitchers
					INNER JOIN people USING(playerid)
					WHERE throws IS NOT NULL)

SELECT ROUND(COUNT(DISTINCT total_left.playerid)/COUNT(DISTINCT total_both.playerid)::numeric*100,2) AS percent_lefties ------Percentage of lefties
FROM total_both
LEFT JOIN total_left USING (playerid)


SELECT COUNT(DISTINCT playerid), throws FROM pitching				-----CY YOUNG AWARDS by pitching type
INNER JOIN people USING(playerid)
LEFT JOIN awardsplayers USING(playerid)
WHERE awardid = 'Cy Young Award' 
GROUP BY throws;


WITH total_cy AS 	(SELECT playerid FROM awardsplayers 			-----Percent of Cy young winners that are left handed
					WHERE awardid = 'Cy Young Award'),
					
total_left_cy AS	(SELECT playerid FROM awardsplayers
					 INNER JOIN people USING(playerid)
					WHERE awardid = 'Cy Young Award'
						AND throws = 'L')

SELECT COUNT(total_left_cy.playerid), COUNT(total_cy.playerid)::numeric
FROM total_cy
LEFT JOIN total_left_cy USING(playerid);


WITH cy_young AS (SELECT namefirst, namelast, throws,
					(CASE WHEN throws = 'L' THEN 1
						ELSE 0 END) AS lefties
					FROM pitching
					INNER JOIN people USING(playerid)
					INNER JOIN awardsplayers USING(playerid, yearid)
					WHERE awardid = 'Cy Young Award')
SELECT SUM(lefties)/COUNT(*)::numeric
FROM  cy_young;






SELECT batting.playerid,batting.sb,batting.cs,stolen_bases_2016.sb_attempts,ROUND(batting.sb/stolen_bases_2016.sb_attempts::numeric,2) AS success_percentage
FROM (SELECT DISTINCT playerid,sb,cs,yearid,(sb) + (cs) AS sb_attempts
        FROM batting
        WHERE yearid= 2016
        AND (sb) + (cs) >= 20) AS stolen_bases_2016
LEFT JOIN batting
USING (playerid)
WHERE batting.yearid=2016
ORDER BY success_percentage DESC


SELECT * FROM batting
WHERE (playerid = 'nunezed02'
	OR playerid = 'uptonbj01')
	AND YEARID = 2016

















