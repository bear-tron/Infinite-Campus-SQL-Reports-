/*This code works for Scheduling Task to change ae.[code] to '2L' rather than 2A
This should only affect tardies and not absences 
 WARNING: THIS IS A DESTRUCTIVE ACTION. DO NOT PROCEED WITHOUT TESTING IN YOUR SANDBOX/TRAINING INSTANCE. 

Original Author: Karen Jimeson (karen.jimeson@dpi.nc.gov)
Original Query:

UPDATE
a
SET
a.excuseid = CASE COALESCE(x.status, a.status)
WHEN 'A' THEN
(
SELECT
AE.excuseid
FROM
AttendanceExcuse AE
WHERE
a.calendarid = ae.calendarid
AND ae. [code] = '2A')
END
FROM
dbo.Attendance a
LEFT OUTER JOIN dbo.AttendanceExcuse x ON x.excuseID = a.excuseID
AND x.calendarID = a.calendarID
INNER JOIN calendar c ON c.calendarid = a.calendarid
INNER JOIN schoolyear sy ON sy.endyear = c.endyear
WHERE (a.excuse IS NULL
AND x.excuse IS NULL)
AND sy.active = 1 

Revision History:
08/15/2024Initial creation of this template
10/04/2024- Modified to change 'T' (tardies) to code 2L by Andrew Sibbett (asibbett@whiteville.k12.nc.us)
*/

UPDATE a
SET											
    a.excuseid = (			--removed CASE COALESCE; we are not dealing with multiple status values.
        SELECT AE.excuseid	--removed 'WHEN' conditional; we only need to update the 'T' status.
        FROM AttendanceExcuse AE
        WHERE a.calendarid = AE.calendarid
        AND AE.[code] = '2L'  --changed code from '2A' (absence) to '2L' (tardy).
    )
FROM dbo.Attendance a
LEFT OUTER JOIN dbo.AttendanceExcuse x 
    ON x.excuseID = a.excuseID
    AND x.calendarID = a.calendarID
INNER JOIN calendar c 
    ON c.calendarid = a.calendarid
INNER JOIN schoolyear sy 
    ON sy.endyear = c.endyear
WHERE
    (a.excuse IS NULL AND x.excuse IS NULL) -- no changes; still targeting records without an excuse.
    AND a.status = 'T';  -- changed condition to check for 'T' (tardy) in the status column. 
