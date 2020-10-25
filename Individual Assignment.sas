libname chinook "C:\Users\rbhalerao\Desktop\Business Reporting Tools\Chinook Dataset";
/*1. Gives a quick overview/summary of the sales data*/
PROC SQL;
title "Sales Overview";
SELECT Count(Distinct(a.InvoiceID)) 'Number of Orders(Invoices)', Count(Distinct(a.CustomerID)) 'Number of Customers', Count(Distinct(b.TrackID)) 'Tracks sold', Sum(b.Quantity) 'Total Quantity', Sum(a.Total) 'Revenue(Total)', Count(Distinct(A.BillingCountry)) 'Number of Countries', int(max(datepart(a.invoicedate)) - min(datepart(a.invoicedate)))/365.25 'Years'
From chinook.invoices as a, chinook.invoice_items as b
WHERE a.invoiceID = b.invoiceID; 
QUIT;
/*2. Country distribution of the Invoice data to get order details per country*/
PROC SQL;
title "Country distribution of Sales (Overview)";
SELECT (A.BillingCountry) 'Country', Count(Distinct(a.InvoiceID)) 'Number of Orders(Invoices)', Count(Distinct(a.CustomerID)) 'Number of Customers', Count(Distinct(b.TrackID)) 'Tracks sold', Sum(b.Quantity) 'Total Quantity', Sum(a.Total) 'Revenue Total'
From chinook.invoices as a, chinook.invoice_items as b
WHERE a.invoiceID = b.invoiceID
GROUP BY bILLINGCountry; 
QUIT;
/*3. Gives a quick overview/summary of the invoice data*/
PROC SQL;
title "Invoice Data Overview";
SELECT Count(DISTINCT(InvoiceID)) as NumberOfOrders, Sum(Quantity)/Count(DISTINCT(InvoiceID)) as Average_QuantityPerOrder, SUM(UnitPrice)/Count(DISTINCT(InvoiceID)) as Average_RevenuePerOrder
FROM chinook.invoice_items; 
QUIT;
/*4. Order details per year*/
PROC SQL;
title "Trends in Invoice with year";
SELECT Count(DISTINCT(b.InvoiceID)) 'Number of Orders', Sum(b.Quantity)/Count(DISTINCT(b.InvoiceID)) 'Average number of Tracks per order', SUM(b.UnitPrice)/Count(DISTINCT(b.InvoiceID)) 'Average revenue per order', Year(datepart(InvoiceDate)) as Year
FROM chinook.invoice_items as b, chinook.invoices as a
WHERE a.invoiceID = b.invoiceID
GROUP BY Year; 
QUIT;
/*5. Gives a count of tracks costing 1.99 euros purchased every year*/
PROC SQL;
title "Number of tracks with high prices";
SELECT count(a.invoiceID) 'Number of Tracks with high price', year(datepart(c.invoicedate)) as Year, b.unitprice
from chinook.invoice_items as a, chinook.tracks as b, chinook.invoices as c
where a.trackid = b.trackid and a.invoiceid = c.invoiceid
group by b.UnitPrice, Year
Having b.UnitPrice > 1;
quit;
/*6. Compares employee performance over the years*/
PROC SQL;
title "Employee Performance";
SELECT unique(a.FirstName) 'First Name', a.LastName 'Last Name', a.EmployeeID, COUNT(c.InvoiceID) 'Orders(Invoices made)', Count(DISTINCT(C.CustomerID)) 'Customers served', Sum(c.Total) 'Revenue Generated', Sum(c.Total)/COUNT(c.InvoiceID) 'Average revenue per order'
FROM chinook.EMPLOYEES as a, chinook.CUSTOMERS as b, chinook.INVOICES as c
WHERE a.employeeID = b.supportrepid and c.customerID = b.customerID
Group by a.employeeID;
QUIT;
/*7. Compares the employee performance distributed for different countries. This helps understand which employee is suitable for customers from which countries*/
PROC SQL;
title "Employee Performance by Country";
SELECT unique(a.FirstName) 'First Name', a.LastName 'Last Name', a.EmployeeID, COUNT(c.InvoiceID) 'Orders(Invoices made)', Count(DISTINCT(C.CustomerID)) 'Customers served', Sum(c.Total) 'Revenue Generated', Sum(c.Total)/COUNT(c.InvoiceID) 'Average revenue per order', c.BillingCountry
FROM chinook.EMPLOYEES as a, chinook.CUSTOMERS as b, chinook.INVOICES as c
WHERE a.employeeID = b.supportrepid and c.customerID = b.customerID
Group by a.employeeID, c.BillingCountry
order by c.BillingCountry, 'Average revenue per order' desc;
QUIT;
/*8. Gives list of 5 most loyal (oldest) customers*/
PROC SQL outobs=5;
title "Five oldest customers";
SELECT unique(a.CustomerID), b.FirstName, b.LastName, Max(a.InvoiceDate) as Most_Recent_Order format = DATETIME7. , Min(a.InvoiceDate) as First_Order format = datetime7., int((Max(Datepart(a.InvoiceDate)) - Min(Datepart(a.InvoiceDate))))/365.25 as Tenure ,  Mean(a.Total) as Average_Sales
FROM chinook.invoices as a inner join chinook.customers as b on a.customerID = b.customerID
GROUP BY a.CustomerID
ORDER BY Tenure DESC;
QUIT;
/*9. Gives list of customers with highest average sales per order*/
PROC SQL outobs=5;
title "Five Customers with highest average sales";
SELECT unique(a.CustomerID), b.FirstName, b.LastName, Max(a.InvoiceDate) as Most_Recent_Order format = DATETIME7. , Min(a.InvoiceDate) as First_Order format = datetime7., int((Max(Datepart(a.InvoiceDate)) - Min(Datepart(a.InvoiceDate))))/365.25 as Tenure ,  Mean(a.Total) as Average_Sales
FROM chinook.invoices as a inner join chinook.customers as b on a.customerID = b.customerID
GROUP BY a.CustomerID
ORDER BY Average_Sales DESC;
QUIT;
/*10. Creating regions from countries*/
PROC SQL;
title "Adding region data";
SELECT DISTINCT(a.Country), Count(a.CustomerID) as Number_Of_Customers, Sum(b.Total) as Total, case when a.country = 'USA' or a.country = 'Canada' or a.country = 'Brazil' or a.country = 'Argentina' or a.country = 'Chile' then 'Americas'
                                                                                                    when a.country = 'France' or a.country = 'Germany' or a.country = 'Spain' or a.country = 'Poland' or a.country = 'United Kingdom' or a.country = 'Portugal' or a.country = 'Czech Republic' or a.country = 'Austria' or a.country = 'Hungary' or a.country = 'Finland' or a.country = 'Belgium' or a.country = 'Italy' or a.country = 'Sweden' or a.country = 'Denmark' or a.country = 'Norway' or a.country = 'Netherlands' or a.country = 'Ireland' then 'Europe'
																									else 'Asia' end as Region
from chinook.customers as a, chinook.invoices as b
GROUP BY Country
ORDER BY Total desc;

QUIT;
/*11. Comparing revenues by region*/
proc sql;
title "Order and Revenue by Region Data";
SELECT Count(b.InvoiceID) as Number_Of_Orders, Sum(b.Total) as Total, case when a.country = 'USA' or a.country = 'Canada' or a.country = 'Brazil' or a.country = 'Argentina' or a.country = 'Chile' then 'Americas'
                                                                                                    when a.country = 'France' or a.country = 'Germany' or a.country = 'Spain' or a.country = 'Poland' or a.country = 'United Kingdom' or a.country = 'Portugal' or a.country = 'Czech Republic' or a.country = 'Austria' or a.country = 'Hungary' or a.country = 'Finland' or a.country = 'Belgium' or a.country = 'Italy' or a.country = 'Sweden' or a.country = 'Denmark' or a.country = 'Norway' or a.country = 'Netherlands' or a.country = 'Ireland' then 'Europe'
																									else 'Asia' end as Region
from chinook.customers as a, chinook.invoices as b
GROUP BY Region
ORDER BY Total desc;

QUIT;
/*12. List of tracks/songs never been purchased*/
PROC SQL;
title 'Unsold songs list';
SELECT count(unique(b.trackID)) 'Number of Unsold Tracks', b.name, (b.bytes)/1000000, sum((b.bytes)/1000000) 'Size in MB'
FROM chinook.tracks as b
WHERE b.trackID NOT IN (SELECT trackID FROM chinook.invoice_items);
QUIT;
/*13. Calculating memory used by unsold tracks*/
PROC SQL;
title 'Unsold tracks';
SELECT count(unique(b.trackID)) 'Number of Unsold Tracks', sum((b.bytes)/1000000) 'Size in MB'
FROM chinook.tracks as b
WHERE b.trackID NOT IN (SELECT trackID FROM chinook.invoice_items);
QUIT;
/*14. Invoices and sales per month*/
PROC SQL;
title 'Monthy Sales and Number of Invoices';
SELECT DISTINCT(MONTH(DATEPART(InvoiceDate))) as Month, Year(DATEPART(InvoiceDate)) as Year, Sum(TOTAL) as TotalSales, Count(InvoiceID) as Invoices
FROM chinook.invoices
GROUP BY Month, Year
ORDER BY Year, Month;
QUIT;
/*15. Revenue and number of tracks for each invoice*/
PROC SQL;
title "Revenue and Quantity per Invoice";
SELECT DISTINCT(InvoiceID) as Invoice_ID, Count(Quantity) as PurchasesMade, Sum(UnitPrice) as OrderCost
FROM chinook.invoice_items
GROUP BY InvoiceID;
QUIT;
/*16. Invoice overview*/
PROC SQL;
title 'Invoice Overview';
SELECT Count(DISTINCT(InvoiceID)) as NumberOfOrders, Sum(Quantity)/Count(DISTINCT(InvoiceID)) as Average_QuantityPerOrder, SUM(UnitPrice)/Count(DISTINCT(InvoiceID)) as Average_RevenuePerOrder
FROM chinook.invoice_items; 
QUIT;
/*17. Customers per company*/
PROC SQL;
title 'Customers and Companies';
SELECT Count(CUSTOMERID) as Number_of_Customers, Company 
FROM chinook.customers
GROUP BY Company;
QUIT; 
/*18. Employees with age over 60 years*/
PROC SQL;
title 'Employees over 60 year old';
SELECT employeeID, Lastname, Firstname, title 
from chinook.employees 
where (floor(yrdif(datepart(birthdate),today(),"AGE"))) >= 60;
quit; 
/*19. Calculating the years for which employee has been in company*/
PROC SQL;
title 'Employee tenure';
SELECT employeeID, Lastname, Firstname, title, abs(int((Datepart(today())) - (Datepart(hiredate)))/365.25) as Tenure 
from chinook.employees ;
quit; 

/*20. Huge merge with Invoice data, tracks artists and genres, media type*/
PROC SQL;
title 'Merged data';
SELECT count(a.InvoiceID), a.InvoiceDate, month(datepart(a.invoicedate)) "Month", year(datepart(a.invoicedate)) as Year, a.BillingCountry, a.Total, case when a.billingcountry = 'USA' or a.billingcountry = 'Canada' or a.billingcountry = 'Brazil' or a.billingcountry = 'Argentina' or a.billingcountry = 'Chile' then 'Americas'
                                                                                                    when a.billingcountry = 'France' or a.billingcountry = 'Germany' or a.billingcountry = 'Spain' or a.billingcountry = 'Poland' or a.billingcountry = 'United Kingdom' or a.billingcountry = 'Portugal' or a.billingcountry = 'Czech Republic' or a.billingcountry = 'Austria' or a.billingcountry = 'Hungary' or a.billingcountry = 'Finland' or a.billingcountry = 'Belgium' or a.billingcountry = 'Italy' or a.billingcountry = 'Sweden' or a.billingcountry = 'Denmark' or a.billingcountry = 'Norway' or a.billingcountry = 'Netherlands' or a.billingcountry = 'Ireland' then 'Europe'
																									else 'Asia' end as Region,
       count(unique(c.trackID)), c.name, c.milliseconds/60000 'Time in minutes', c.bytes/1000000 'Megabytes', sum(c.UnitPrice),
	   (d.Title),
	   (e.Name),
	   (f.Name),
	   (g.Name)
FROM chinook.invoices as a, chinook.customers as b, chinook.tracks as c, chinook.albums as d, chinook.artists as e, 
     chinook.genres as f, chinook.media_types as g,
     chinook.invoice_items as h
WHERE a.customerID = b.customerID and a.invoiceID = h.invoiceID and h.trackID = c.trackID and c.albumID = d.albumID and d.artistID = e.artistID and c.genreID = f.genreID and c.MediatypeID = g.mediatypeID
GROUP BY Year, Region, BillingCountry ;
QUIT;


PROC SQL;
title 'Albums by region, country and year';
SELECT count(d.albumID), year(datepart(a.invoicedate)) as Year,  case when a.billingcountry = 'USA' or a.billingcountry = 'Canada' or a.billingcountry = 'Brazil' or a.billingcountry = 'Argentina' or a.billingcountry = 'Chile' then 'Americas'
                                                                                                    when a.billingcountry = 'France' or a.billingcountry = 'Germany' or a.billingcountry = 'Spain' or a.billingcountry = 'Poland' or a.billingcountry = 'United Kingdom' or a.billingcountry = 'Portugal' or a.billingcountry = 'Czech Republic' or a.billingcountry = 'Austria' or a.billingcountry = 'Hungary' or a.billingcountry = 'Finland' or a.billingcountry = 'Belgium' or a.billingcountry = 'Italy' or a.billingcountry = 'Sweden' or a.billingcountry = 'Denmark' or a.billingcountry = 'Norway' or a.billingcountry = 'Netherlands' or a.billingcountry = 'Ireland' then 'Europe'
																									else 'Asia' end as Region,
	   f.Name as Genre
FROM chinook.invoices as a, chinook.customers as b, chinook.tracks as c, chinook.albums as d, chinook.artists as e, 
     chinook.genres as f, chinook.media_types as g,
     chinook.invoice_items as h
WHERE a.customerID = b.customerID and a.invoiceID = h.invoiceID and h.trackID = c.trackID and c.albumID = d.albumID and d.artistID = e.artistID and c.genreID = f.genreID and c.MediatypeID = g.mediatypeID 

GROUP BY Year, Region, Genre;

QUIT;


