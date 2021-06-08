/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name, membercost
FROM Facilities
WHERE membercost > 0.00;

-- Answer = Facilities that charge = Tennis Court 1, Tennis Court 2, Massage Room 1, Massage Room 2, Squash Court

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0.00;

--Answer = 4 facilities do not charge a fee to members

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name AS facility_name, membercost, monthlymaintenance
FROM Facilities
WHERE (0.2 * monthlymaintenance) >= membercost

--Answer = 8 facilities where fee is less than 20% of monthly main. cost

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1, 5) -- Answer IN

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT
	name,
	monthlymaintenance,
	CASE WHEN monthlymaintenance > 100 THEN 'expensive' --Answer
		WHEN monthlymaintenance < 100 THEN 'cheep'
		ELSE '' END AS facilities_maintenance
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE firstname <> 'GUEST'; --Answer: as to not include the "GUEST" row and get full list

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

--Answer
SELECT DISTINCT CONCAT(firstname, ' ', surname) AS member_name, Facilities.name
FROM Members
INNER JOIN Bookings
ON Members.memid = Bookings.memid
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE Facilities.name LIKE '%Tennis Court%' AND Members.surname <> 'GUEST'
ORDER BY Members.surname

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

--Attempt
SELECT DISTINCT CONCAT(firstname, ' ', surname) AS member_name, name AS facility
CASE WHEN firstname = 'GUEST' THEN guestcost * slots
	ELSE membercost * slots
	END AS cost
FROM members
	INNER JOIN Bookings
		ON Members.memid = Bookings.memid
	INNER JOIN Facilities
		ON Bookings.facid = Facilites.facid
WHERE starttime LIKE '%2012-09-14%'
	AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots
		ELSE membercost * slots
		END > 30
ORDER BY cost DESC;

--answer
SELECT name AS facility, CONCAT(firstname, ' ', surname) AS member_name,
CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost
FROM Members
	INNER JOIN Bookings
		ON Members.memid = Bookings.memid
	INNER JOIN Facilities
		ON Bookings.facid = Facilities.facid
WHERE starttime LIKE '%2012-09-14%'
	AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots
		ELSE membercost * slots
		END > 30
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT name AS facility, CONCAT(firstname, ' ', surname) AS member_name, cost
FROM
	(SELECT
		firstname,
		surname,
		name,
	CASE WHEN firstname = 'GUEST' THEN guestcost * slots
     ELSE membercost * slots
     END AS cost,
		starttime
	FROM Members
	INNER JOIN Bookings
		ON Members.memid = Bookings.memid
	INNER JOIN Facilities
		ON Bookings.facid = Facilities.facid) AS inner_table
WHERE starttime LIKE '%2012-09-14%'
	AND cost > 30
ORDER BY cost DESC;


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine.
Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it.
Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.
You should see the output from the initial query 'SELECT * FROM FACILITIES'.
Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to.
You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output. */


QUESTIONS: --Jeff said answer them in same UI
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
--Attempt 1
SELECT name AS facility,
	CASE WHEN firstname = 'GUEST' THEN guestcost * slots
		WHEN firstname <> 'GUEST' THEN membercost * slots
		ELSE '' END AS total_revenue
FROM Members
INNER JOIN Bookings
	ON Members.memid = Bookings.memid
INNER JOIN Facilities
	ON Bookings.facid = Facilities.facid
--Answer
SELECT name, total_revenue
FROM
	(SELECT name,
		SUM(CASE WHEN memid = 0 THEN guestcost * slots
			ELSE membercost * slots
            END) AS total_revenue
     FROM Bookings
     INNER JOIN Facilities
     	ON Bookings.facid = Facilities.facid
     GROUP BY name) AS inner_table
WHERE total_revenue < 1000
ORDER BY total_revenue;


/* Q11: Produce a report of members and who recommended them in
alphabetic surname,firstname order */

SELECT CONCAT(rcmdb.firstname, ' ', rcmdb.surname) AS recommended_by, CONCAT(m.firstname, ' ', m.surname) AS member
FROM Members AS m
INNER JOIN Members AS rcmdb
	ON rcmdb.recommendedby = m.memid
WHERE m.memid > 0
ORDER BY m.surname, m.firstname, rcmdb.surname, rcmdb.firstname

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name, CONCAT(m.firstname, ' ' ,m.surname) as Member, COUNT(f.name) as usage_by_member
FROM Members AS m
INNER JOIN Bookings AS bk
	ON bk.memid = m.memid
INNER JOIN Facilities AS f
	ON f.facid = bk.facid
WHERE m.memid > 0
GROUP BY f.name, concat(m.firstname, ' ', m.surname)
ORDER BY f.name, m.surname, m.firstname


/* Q13: Find the facilities usage by month, but not guests */

SELECT f.name, CONCAT(m.firstname, ' ' ,m.surname) as Member, COUNT(f.name) as usage_by_month,
SUM(CASE WHEN month(starttime) = 1 THEN 1 ELSE 0 END) AS Jan,
SUM(CASE WHEN month(starttime) = 2 THEN 1 ELSE 0 END) AS Feb,
SUM(CASE WHEN month(starttime) = 3 THEN 1 ELSE 0 END) AS Mar,
SUM(CASE WHEN month(starttime) = 4 THEN 1 ELSE 0 END) AS Apr,
SUM(CASE WHEN month(starttime) = 5 THEN 1 ELSE 0 END) AS May,
SUM(CASE WHEN month(starttime) = 6 THEN 1 ELSE 0 END) AS Jun,
SUM(CASE WHEN month(starttime) = 7 THEN 1 ELSE 0 END) AS Jul,
SUM(CASE WHEN month(starttime) = 8 THEN 1 ELSE 0 END) AS Aug,
SUM(CASE WHEN month(starttime) = 9 THEN 1 ELSE 0 END) AS Sep,
SUM(CASE WHEN month(starttime) = 10 THEN 1 ELSE 0 END) AS Oct,
SUM(CASE WHEN month(starttime) = 11 THEN 1 ELSE 0 END) AS Nov,
SUM(CASE WHEN month(starttime) = 12 THEN 1 ELSE 0 END) AS Decm
FROM Members AS m
INNER JOIN Bookings AS bk
	ON bk.memid = m.memid
INNER JOIN Facilities AS f
	ON f.facid = bk.facid
WHERE m.memid > 0
GROUP BY f.name, concat(m.firstname, ' ', m.surname)
ORDER BY f.name, m.surname, m.firstname;

