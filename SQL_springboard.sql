/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

Ans) SELECT name from Facilities WHERE membercost>0


/* Q2: How many facilities do not charge a fee to members? */
Ans) select count(*) from Facilities where membercost=0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

Ans) SELECT facid,name,membercost,monthlymaintenance from Facilities WHERE membercost>0 AND membercost < 0.2*monthlymaintenance


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

Ans) SELECT * from Facilities WHEREfacid IN (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

Ans) SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance >100
THEN  'expensive'
ELSE  'cheap'
END AS Rating
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

Ans) SELECT firstname, surname
FROM Members
WHERE joindate
IN (SELECT MAX( joindate ) 
FROM Members
)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

Ans) SELECT DISTINCT Facilities.name, CONCAT( Members.firstname,  " ", Members.surname ) AS MemberName
FROM Bookings
LEFT JOIN Facilities ON Bookings.facid = Facilities.facid
LEFT JOIN Members ON Bookings.memid = Members.memid
WHERE Facilities.name LIKE  'Tennis%'
ORDER BY MemberName


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

Ans) SELECT f.name AS Facility, CONCAT( m.firstname,  " ", m.surname ) AS Name, 
CASE WHEN b.memid =0
THEN SUM( guestcost * slots ) 
ELSE SUM( membercost * slots ) 
END AS cost
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.Facid = f.Facid
LEFT JOIN Members AS m ON b.memid = m.memid
WHERE starttime LIKE  '2012-09-14%'
GROUP BY b.memid, Facility
HAVING cost >30
ORDER BY cost DESC 


Ans) select CONCAT(m.firstname," ",m.surname) as Name ,CASE when  b.memid=0 THEN sum(guestcost) ELSE sum(membercost) END AS Total_Cost from Bookings as b
left join Facilities as f on b.Facid = f.Facid
left join Members as m on b.memid =m.memid
where starttime like '2012-09-14%'
group by b.memid having Total_Cost>30



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT * 
FROM (
SELECT Facilities.name AS facility, CONCAT( Members.firstname,  ' ', Members.surname ) AS name, 
CASE WHEN Bookings.memid =0
THEN Facilities.guestcost * Bookings.slots
ELSE Facilities.membercost * Bookings.slots
END AS cost
FROM Bookings
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
AND Bookings.starttime LIKE  '2012-09-14%'
INNER JOIN Members ON Bookings.memid = Members.memid
)sub
WHERE sub.cost >30
ORDER BY sub.cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

Ans)
SELECT * 
FROM (
SELECT sub.facility, SUM( sub.cost ) AS total_revenue
FROM (
SELECT Facilities.name AS facility, 
CASE WHEN Bookings.memid =0
THEN Facilities.guestcost * Bookings.slots
ELSE Facilities.membercost * Bookings.slots
END AS cost
FROM Bookings
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
INNER JOIN Members ON Bookings.memid = Members.memid
)sub
GROUP BY sub.facility
)sub2
WHERE sub2.total_revenue <1000
