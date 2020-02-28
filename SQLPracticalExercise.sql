-- STAGE 1 - NORTHWIND QUERIES

--This makes sure that we are on the correct database
Use Northwind

--1.1	Write a query that lists all Customers in either Paris or London. Include Customer ID, Company Name and all address fields.

--Outputs the ID, Name and location of any customer where the "city" field is paris or london. 
SELECT CustomerID, CompanyName, CONCAT(Address, ', ', City) AS 'Location' FROM Customers 
WHERE City = 'Paris' OR City = 'London'

--1.2	List all products stored in bottles.

--This statement checks if the string "bottles" is contained in the QuantityPerUnit field and
--outputting the record to the user
SELECT ProductName FROM Products WHERE QuantityPerUnit LIKE '%bottle%'

--1.3	Repeat question above, but add in the Supplier Name and Country.

--I'm running the above statement in a subquery. THe outer query also pulls the 
--specified columns from the suppliers table, connecting the two tables 
--using the SupplierID field
SELECT  CompanyName, CONCAT(City, ', ', Country) AS 'Country' FROM Suppliers
WHERE SupplierID IN (SELECT SupplierID FROM Products WHERE QuantityPerUnit LIKE '%bottle%')

--1.4	Write an SQL Statement that shows how many products there are in each category. 
--Include Category Name in result set and list the highest number first.

--Joining together two tables on the CategoryID field, and outputting the sum of the CategoryID
--ordering it by that column
SELECT c.CategoryID, SUM(c.CategoryID) AS 'Count', c.CategoryName FROM Products p 
INNER JOIN Categories c ON p.CategoryID=c.CategoryID 
GROUP BY c.CategoryID, c.CategoryName ORDER BY Count DESC

--1.5	List all UK employees using concatenation to join their title of courtesy, first name and last name together. 
--Also include their city of residence.

--Checking the country field and outputting a concatenation of the record's name fields, as well as their city
SELECT CONCAT(TitleOfCourtesy, ' ', FirstName, ' ', LastName) AS 'UK Employee', City FROM Employees WHERE Country = 'UK'

--1.6	List Sales Totals for all Sales Regions (via the Territories table using 4 joins) with a Sales Total 
--greater than 1,000,000. Use rounding or FORMAT to present the numbers. 

--Joining together the Region, Territories, EmployeeTerritories, Orders and OrderDetails tables using 
-- a number of Primarykey fields, then outputting the region description and the sales price
-- the latter of which was rounded up to 2 significant figures
SELECT r.RegionDescription, ROUND(SUM(od.UnitPrice*od.Quantity), -5) AS 'Sales' FROM Region r 
INNER JOIN Territories t ON r.RegionID=t.RegionID
INNER JOIN EmployeeTerritories et ON t.TerritoryID = et.TerritoryID
INNER JOIN Orders o ON et.EmployeeID=o.EmployeeID
INNER JOIN [Order Details] od ON o.orderID=od.OrderID GROUP BY r.RegionID, R.RegionDescription ORDER BY Sales DESC

--1.7	Count how many Orders have a Freight amount greater than 100.00 and either USA or UK as Ship Country.

-- Checking the freight amount against "100", and the ship country and outputting the number of records that meet the value
SELECT COUNT(OrderID) FROM Orders WHERE Freight > 100 AND ShipCountry IN ('USA', 'UK')

--1.8	Write an SQL Statement to identify the Order Number of the Order with the highest amount of discount applied to that order.

--Outputting the single record with the highest discount
SELECT TOP 1 OrderID, MAX(Discount) AS 'Discount' FROM [Order Details] GROUP BY OrderID ORDER BY Discount DESC

--STAGE 2 - CREATE SPARTANS TABLE
--2.1 Write the correct SQL statement to create the following table:
--Spartans Table – include details about all the Spartans on this course. Separate Title, First Name and Last Name into separate columns, 
--and include University attended, course taken and mark achieved. Add any other columns you feel would be appropriate. 

--Create a new table with the SpartanID as the primary key starting from 001
CREATE TABLE Spartans(
    SpartanID INT IDENTITY(001,1),
    --Longest value expected is "Miss."
    Title VARCHAR(5)
    FirstName VARCHAR(16),
    LastName VARCHAR(16),
    --University is taken as the uni's three letter code, EG UEA for University of East Anglia
    University VARCHAR(3),
    UniCourse VARCHAR(40),
    --UniMark is expected as "1st", "2:1", "2:2", "3rd", "F"
    UniMark VARCHAR(3),
    PRIMARY KEY (Title)
)

--2.2 Write SQL statements to add the details of the Spartans in your course to the table you have created.

INSERT INTO Spartans(
    Title, FirstName, LastName, University, UniCourse, UniMark
)VALUES ('Mr.', 'Adam', 'Moussa', 'UEA', 'CompSci', '1st')

INSERT INTO Spartans(
    Title, FirstName, LastName, University, UniCourse, UniMark
)VALUES ('Mr.', 'James', 'Hovell', 'UOP', 'Dance', 'F')

INSERT INTO Spartans(
    Title, FirstName, LastName, University, UniCourse, UniMark
)VALUES ('Mr.', 'Mohammed', 'Ali', 'BUL', 'SportScience', '2:1')

INSERT INTO Spartans(
    Title, FirstName, LastName, University, UniCourse, UniMark
)VALUES ('Mr.', 'Ash', 'Isbitt', 'UoH', 'VisualEffects&MotionGraphics', '1st')

INSERT INTO Spartans(
    Title, FirstName, LastName, University, UniCourse, UniMark
)VALUES ('Mr.', 'Makhsoud', 'Ahmed', 'PCL', 'CompSci', '1st')

--STAGE 3 - Northwind Data Analysis linked to Excel 
--3.1 List all Employees from the Employees table and who they report to.

-- Output the name of each employee, as well as their ID, and the ID of the person they report to
SELECT EmployeeID, CONCAT(Firstname, ' ', LastName) AS 'Employee', ReportsTo FROM Employees

--3.2 List all Suppliers with total sales over $10,000 in the Order Details table. 
--Include the Company Name from the Suppliers Table and present as a bar chart as below

--This query joins together the products, order details, and suppliers tables, displaying the
--net price formatted to UK and numeric format so that there are commas dividing up the numbers for readability
-- See attached document for the requested table 

SELECT s.SupplierID, s.CompanyName, 
FORMAT(SUM(od.UnitPrice*od.Quantity*(1-od.Discount)), 'N', 'en-uk') AS 'TotalSales' FROM [Order Details] od 
INNER JOIN Products p on od.ProductID=p.ProductID 
INNER JOIN Suppliers s ON p.SupplierID=s.SupplierID 
GROUP BY s.SupplierID, s.CompanyName HAVING (SUM(od.UnitPrice*od.Quantity*(1-od.Discount))) > 10000

-- 3.3 List the Top 10 Customers YearToDate for the latest year in the Orders file. Based on total value of orders shipped. No Excel required. (10 Marks)

--Joining together the orders, order details and customer tables, then calculating the net price
-- and taking the top 10 results, making sure that the 10 results are unique and 
-- are all in the most recent year of 1998 
SELECT DISTINCT TOP 10 o.OrderID, c.CustomerID, c.CompanyName, (od.UnitPrice*od.Quantity*(1-od.Discount)) AS 'Net Price', o.ShippedDate
FROM (Orders o INNER JOIN [Order Details] od ON o.OrderID=od.OrderID
    INNER JOIN Customers c ON o.CustomerID=c.CustomerID) 
WHERE YEAR(o.ShippedDate)=1998 ORDER BY [Net Price] DESC 

--3.4 Plot the Average Ship Time by month for all data in the Orders Table using a line chart as below. (10 Marks)
SELECT * FROM Orders

--See the attached EXCEL Spreadsheet for the requested line chart
--This query outputs the average length the journey by getting the distance between the shipping date and the required date
SELECT CONCAT(MONTH(ShippedDate), ', ', YEAR(ShippedDate)) AS 'ShipMonth', AVG(DATEDIFF(day, ShippedDate, RequiredDate)) AS 'lengthOfJourney' 
FROM [Orders] GROUP BY ShippedDate HAVING DAY(ShippedDate) = AVG(DATEDIFF(day, ShippedDate, RequiredDate))
