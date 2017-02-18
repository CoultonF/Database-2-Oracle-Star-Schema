/*

Assignment 1

Database 2

Coulton Fraser

Nicole Waldern


*/

DROP TABLE FACT_SALES;
DROP TABLE DIM_DATE;
DROP TABLE DIM_PRODUCT;
DROP TABLE DIM_TIME;
DROP TABLE DIM_STORE;


DROP INDEX store_idx;
DROP INDEX sales_idx;
DROP INDEX product_idx;
DROP INDEX time_idx;
DROP INDEX date_idx;

PURGE RECYCLEBIN;

/*

CREATE TABLE STATEMENTS

*/

CREATE TABLE DIM_PRODUCT(
Product_ID number(4),
P_Name varchar(255),
P_Category varchar(255), 
P_Size varchar(255),
P_Calories number,
P_Desc varchar(255),
Constraint PRODUCT_ID_PK PRIMARY KEY (Product_ID)
);
/*
PRODUCT:	Dimension table.
				Records information on each product. 
					Example: A donut								                                                                                                        Product_ID: 0167
						P_NAME: Chocolate Glazed
						P_Category: Donut
						P_Size: Null 
						P_Calories: 385
						P_Desc: Delicious chocolate glazed donut. 
																						     	     	       		 The grain for this table is fine because we want to know specific data on the product for later analysis.
																								       	   	 Design:  	   All dimensions that were added are relevent to every product, with the exception of size because not every product has a size
						   Products that don't have a size will be null.
*/
CREATE TABLE DIM_STORE(
Store_ID number(4),
S_Name varchar(255),
S_Address varchar(255),
S_Postal_Code varchar(10), 
S_City varchar(255),
S_Region varchar(255),
S_Country varchar(255),
S_Owner_ID number(4),
S_Manager_ID number(4),
Constraint STORE_ID_PK PRIMARY KEY (Store_ID)
);
/*
STORE:	Dimension table.
			Records information on each store. 
					    Example: Store 1234 in Calgary:	
					    	Store_ID: 1234
						S_Name: Mount Royal University Campus
						S_Address: 4825 Mount Royal Gate
						S_Postal_Code: T3E6K6
						S_City: Calgary
						S_Region: Alberta
						S_Country: Canada																		                
						S_Owner_ID 3667
						S_Manager_ID: 4879 
						The grain for this table is fine because we want to know specific data on the store for grouping by city, region, postal code, country etc.
						Design:  	       All dimensions that were added are relevent to every store. The design allows analysis of small and large areas.
										   We are grouping region by province/state/territory. 
*/
CREATE TABLE DIM_TIME(
Time_ID number(3),
T_Hour_Quarter number(1),
T_Hour number(2),
T_Meal varchar(255),
Constraint T_TIME_ID_PK PRIMARY KEY (Time_ID)
);
/*
TIME:	Dimension table.
			Records information on the time of a transaction. 
					    Example: Donut purchased at 11:05am:
						Time_ID: 111
						T_Hour_Quarter: 1
						T_Hour: 11
						T_Meal: Breakfast
						This table is medium-grained because we are grouping the time into quarters within an hour, and not down to the second; we also do have specific meal times.
						The Time_ID is the T_Hour + T_Hour_Quarter. The T_Hour runs from 0-23 (24 hour clock). The Meal is split in 5 sections: Early-Morning 001-054, 
						Breakfast is 061-114, Lunch is 121-159, Dinner is 161-194, and Late-Night is 201-234.
*/
CREATE TABLE DIM_DATE(
Date_ID number,
D_Day number,
D_Month number,
D_Year number, 
D_Season varchar(255),
D_Quarter number,
D_Weekend number,
Constraint D_DATE_ID_PK PRIMARY KEY (Date_ID)  
);
/*
DATE:	Dimension table.
			Records information on the date of a transaction. 
					Example: Donut purchased on July 18th, 1982:
					      Date_ID: 19820718
					      D_Day: 18
					      D_Month: 07
					      D_Year: 1982
					      D_Season: Summer									   
						  D_Quarter: 3
					      D_Weekend: 1
						  This table is fine-grained for the purpose of analyzing purchases by any date throughout the year. 
					
							Weekend is a boolean value 0 or 1.
							Date_ID = D_Year + D_Month + D_Day; this is for ease of filtering. The D_Season is based on Canada's season changing days.
							Ex) March 20th - June 19th is spring.  Weekends were made as boolean flags to show if the day was a Saturday or Sunday.  
																																		    	       	      	      
*/
CREATE TABLE FACT_SALES(
Transaction_ID number(7),
Product_ID number(4),
Store_ID number(4),
Time_ID number(3),
Date_ID number(8),
Quantity number,
Constraint SALES_TRANS_PK PRIMARY KEY (Transaction_ID, Product_ID, Store_ID, Time_ID, Date_ID),
Constraint SALES_PROD_FK FOREIGN KEY (Product_ID) References DIM_PRODUCT(Product_ID),
Constraint SALES_STORE_FK FOREIGN KEY (Store_ID) References DIM_STORE(Store_ID),
Constraint SALES_TIME_FK FOREIGN KEY (Time_ID) References DIM_TIME(Time_ID),
Constraint SALES_DATE_FK FOREIGN KEY (Date_ID) References DIM_DATE(Date_ID) 
);
/*
SALES:	Fact table.
		Holds facts for sales/transactions. 
		      	    Example: Sale of a donut on July 18th 1982, at 11:05am.
			    	     	     Transaction_ID: 0017468
					       Product_ID: 0167
					       Store_ID: 1234
					       Time_ID: 111
					       Date_ID: 19820718
					       Quantity: 1
						   This fact table records facts(primary keys) from each dimension table. It also records the Transaction_ID which is a degenerate key becuase it does not need
						   to record any other data with it. Lastly, it records the quantity of items that was purchased during the transaction. 
*/

/*

BEGIN PL/SQL STATEMENTS FOR POPULATING DATA.

*/

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYYMMDD';

DECLARE

Date_ID1 varchar(50);
D_Year1 varchar(50);
D_Month1 varchar(50);
D_Day1 varchar(50);


CURRMONTH NUMBER;
SEASON VARCHAR(255);
QUARTER NUMBER;
CURRMONTHDAY NUMBER;
DAYOFWEEK VARCHAR(255);
ISWEEKEND NUMBER;

BEGIN

FOR REC IN (SELECT DATE'1959-12-31' + LEVEL "DATE" FROM DUAL CONNECT BY LEVEL <= DATE'2030-12-31' - DATE'1959-12-31') LOOP


CURRMONTHDAY := SUBSTR(REC.DATE, 5,4);


IF CURRMONTHDAY >= 1221 OR CURRMONTHDAY <= 0320 THEN

SEASON := 'Winter';

ELSIF CURRMONTHDAY >= 0321 AND CURRMONTHDAY <= 0620 THEN

SEASON := 'Spring';

ELSIF CURRMONTHDAY >= 0621 AND CURRMONTHDAY <= 0920 THEN

SEASON := 'Summer';

ELSIF CURRMONTHDAY >= 0921 AND CURRMONTHDAY <= 1220 THEN

SEASON := 'Fall';

END IF;




CURRMONTH := SUBSTR(REC.DATE, 5, 2);

IF CURRMONTH >= 1 AND CURRMONTH <= 3 THEN

QUARTER := 1;

ELSIF CURRMONTH >= 4 AND CURRMONTH <= 6 THEN

QUARTER := 2;

ELSIF CURRMONTH >= 7 AND CURRMONTH <= 9 THEN

QUARTER := 3;

ELSE

QUARTER := 4;

END IF;


DAYOFWEEK := TO_CHAR(TO_DATE(REC.DATE, 'YYYYMMDD'), 'DAY');

/* THERE IS A RANDOM SPACE AFTER THE NAME OF EACH DAY SO WE ADDED IT IN THE CONDITIONS */
IF DAYOFWEEK = 'SATURDAY ' OR DAYOFWEEK = 'SUNDAY ' THEN

ISWEEKEND := 1;

ELSE

ISWEEKEND := 0;

END IF;



Date_ID1 := REC.DATE;

D_Year1 := SUBSTR(REC.DATE,1,4);

D_Month1 := SUBSTR(REC.DATE,5,2);

D_Day1 := SUBSTR(REC.DATE,7,2);

/*INSERT STATEMENT TO LOOP THROUGH THE DATE DATA LOOP */

INSERT INTO DIM_DATE (Date_ID, D_Year, D_Month, D_Day, D_Season, D_Quarter, D_Weekend) VALUES (Date_ID1, D_Year1, D_Month1, D_Day1, SEASON, QUARTER, ISWEEKEND);

END LOOP;




END;
/

/*

INSERT STATEMENTS

*/

 INSERT INTO DIM_PRODUCT (Product_ID, P_Category, P_Size, P_Calories, P_Desc) VALUES (1234, 'Donut', NULL, 385, 'Chocolate Glazed donut');

 INSERT INTO DIM_PRODUCT (Product_ID, P_Category, P_Size, P_Calories, P_Desc) VALUES (2345, 'Coffee', 'Medium', 0, 'Black coffee');

 INSERT INTO DIM_PRODUCT (Product_ID, P_Category, P_Size, P_Calories, P_Desc) VALUES (3456, 'Timbit', NULL, 70, 'chocolate glazed timbit');

 INSERT INTO DIM_PRODUCT (Product_ID, P_Category, P_Size, P_Calories, P_Desc) VALUES (4576, 'Sandwich', 'Regular', 550, 'BLT');

INSERT INTO DIM_STORE (Store_ID, S_Name, S_Address, S_Postal_Code, S_City, S_Region, S_Country, S_Owner_ID, S_Manager_ID) VALUES (1234, 'MRU Campus', '415 Mtroyal Gate SW', 'T2E4F5', 'Calgary', 'AB', 'Canada', 4565, 9897);

INSERT INTO DIM_STORE (Store_ID, S_Name, S_Address, S_Postal_Code, S_City, S_Region, S_Country, S_Owner_ID, S_Manager_ID) VALUES (1235, 'UofC Campus 1', '2500 University Dr NW', 'T2N1N4', 'Calgary', 'AB', 'Canada', 1233, 4454);

INSERT INTO DIM_STORE (Store_ID, S_Name, S_Address, S_Postal_Code, S_City, S_Region, S_Country, S_Owner_ID, S_Manager_ID) VALUES (1236, 'Braeside', '11472 Braeside Dr SW', 'T2W2X8', 'Calgary', 'AB', 'Canada', 1234, 1235);

INSERT INTO DIM_TIME (Time_ID, T_Hour_Quarter, T_Hour, T_Meal) VALUES (111, 1, 11, 'Breakfast');

INSERT INTO DIM_TIME (Time_ID, T_Hour_Quarter, T_Hour, T_Meal) VALUES (151, 1, 15, 'Lunch');

INSERT INTO DIM_TIME (Time_ID, T_Hour_Quarter, T_Hour, T_Meal) VALUES (181, 1, 18, 'Dinner');

INSERT INTO FACT_SALES (Transaction_ID, Product_ID, Store_ID, Time_ID, Date_ID, Quantity) VALUES (0017468, 1234, 1234, 111, 19820718, 2);

INSERT INTO FACT_SALES (Transaction_ID, Product_ID, Store_ID, Time_ID, Date_ID, Quantity) VALUES (0017466, 2345, 1234, 151, 20170111, 1);

INSERT INTO FACT_SALES (Transaction_ID, Product_ID, Store_ID, Time_ID, Date_ID, Quantity) VALUES (0017466, 2345, 1235, 181, 20170211, 5);


/*

INDEX STATEMENTS

*/


CREATE INDEX date_idx ON DIM_DATE(D_Quarter, D_Season, D_Month, D_Year);

CREATE INDEX time_idx ON DIM_TIME(T_Hour_Quarter, T_Hour, T_Meal);

CREATE INDEX product_idx ON DIM_PRODUCT(P_Size, P_Category);

CREATE INDEX store_idx ON DIM_STORE(S_City, S_Region, S_Country);

CREATE INDEX sales_idx ON FACT_SALES(Quantity);


