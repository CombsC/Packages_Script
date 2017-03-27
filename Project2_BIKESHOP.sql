/*----------PROJECT 2 PACKAGES & PACKAGE BODYS --------------
/   
/      Prepared by: Crystal Combs, email: zcmc53@gmail.com  
/                 Created on: 02/10/2017
/               Last edit on: 02/23/2017
/
-------------------------------------------------------------*/
SET SERVEROUTPUT ON;  --enable print to console

DROP TYPE TEMP_CUST_TABLE; --drop past instances of TEMP_CUST_TABLE table
DROP TYPE CUST_ORDERS;  --drop past instances of CUST_ORDERS object
/

--Creates the CUST_ORDERS object
CREATE TYPE CUST_ORDERS AS OBJECT(
  CustomerID NUMBER,
  SerialNumber NUMBER
  );
/
--Creates a table type of CUST_ORDERS objects
CREATE TYPE TEMP_CUST_TABLE IS TABLE OF CUST_ORDERS;
/

/***************************************************/
/* PACKAGE BIKESHOP                                */
CREATE OR REPLACE PACKAGE BIKESHOP AS 
  PROCEDURE EXTRACT_BICYCLES(OUTPUT_TYPE IN VARCHAR2);
  PROCEDURE EXTRACT_CUSTOMERS(OUTPUT_TYPE IN VARCHAR2);
  FUNCTION  CUSTOMER_BIKES(CUSTOMER_ID IN NUMBER) RETURN TEMP_CUST_TABLE;
  PROCEDURE ARCHIVE_CUSTOMER_BIKES;
END BIKESHOP;
/

/**************************************************/  
/* PACKAGE BODY BIKESHOP                          */
CREATE OR REPLACE PACKAGE BODY BIKESHOP AS

/* PROCEDURE EXTRACT_BICYCLES
  This Procedure excepts an Input value as a VARCHAR2 and 
  queries the database for the bicycle entries in the BICYCLE
  table. If the input value is 'S' then the procedure will display
  the information to the console. If the input type is 'D' then the 
  procdure will insert the data into the current user's schema.
*/
  PROCEDURE EXTRACT_BICYCLES(OUTPUT_TYPE IN VARCHAR2) IS
  
    CURSOR cBike IS  --Creates a cursor for navigating through the result set
    
      SELECT SERIALNUMBER, MODELTYPE, PAINTID, FRAMESIZE,
             ORDERDATE, STARTDATE, SHIPDATE,
             CONSTRUCTION, LISTPRICE, SALEPRICE, SALESTAX,
             SALESTATE
        FROM BIKE_SHOP.BICYCLE 
        ORDER BY ORDERDATE ASC;
        
    rBike cBike%ROWTYPE; --Creates a rowtype for the result set of CBike cursor
  
  
    rowCount NUMBER := 0; --Declares a row counter for displaying inserted Rows 
    
    BEGIN 
    
    OPEN cBike;  --Opens the cursor
     LOOP      
       
       FETCH cBike INTO rBike; --Places the contents of cBike into rBike in turn
       EXIT WHEN cBike%NOTFOUND; --exits the loop when cBike has been exhausted 
        
        IF(OUTPUT_TYPE = 'S') THEN --Prints the data to the console if 'S' is entered
                      
            DBMS_OUTPUT.PUT_LINE('------Bicycle Inventory------');
            DBMS_OUTPUT.PUT_LINE('Serial Number: ' || rBike.SERIALNUMBER);
            DBMS_OUTPUT.PUT_LINE('Model: ' || rBike.MODELTYPE);
            DBMS_OUTPUT.PUT_LINE('Paint: ' || rBike.PAINTID);
            DBMS_OUTPUT.PUT_LINE('Frame Size: ' || rBike.FRAMESIZE);
            DBMS_OUTPUT.PUT_LINE('Order Date: ' || rBike.ORDERDATE);
            DBMS_OUTPUT.PUT_LINE('Start Date: ' || rBike.STARTDATE);
            DBMS_OUTPUT.PUT_LINE('Ship Date: ' || rBike.SHIPDATE);
            DBMS_OUTPUT.PUT_LINE('Construction: ' || rBike.CONSTRUCTION);
            DBMS_OUTPUT.PUT_LINE('List Price: ' || rBike.LISTPRICE);
            DBMS_OUTPUT.PUT_LINE('Sale Price: ' || rBike.SALEPRICE);
            DBMS_OUTPUT.PUT_LINE('Sales Tax: ' || rBike.SALESTAX);
            DBMS_OUTPUT.PUT_LINE('State Sold: ' || rBike.SALESTATE);
            DBMS_OUTPUT.NEW_LINE();
           
                 
        ELSIF(OUTPUT_TYPE = 'D') THEN --Inserts the data into the users schema if 'D' is entered
        
          INSERT INTO BICYCLES
              VALUES(rBike.SERIALNUMBER, rBike.MODELTYPE, rBike.PAINTID,
                     rBike.FRAMESIZE, rBike.ORDERDATE, rBike.STARTDATE, 
                     rBike.SHIPDATE, rBike.CONSTRUCTION, rBike.LISTPRICE,
                     rBike.SALEPRICE, rBike.SALESTAX, rBike.SALESTATE);
                     
          rowCount := rowCount + SQL%ROWCOUNT;  --Counts rows inserted and store # in rowCount         
          
          COMMIT;  --Commit insert
          
        ELSE DBMS_OUTPUT.PUT_LINE('Error! Please enter an "S" for displaying data
                                   or "D" for inserting the data into users schema!');      
        END IF;       
       END LOOP;
       
       --Displays the number of rows inserted
       IF (rowCount > 0) THEN
          DBMS_OUTPUT.PUT_LINE('# of Rows Inserted: ' || rowCount);
       ELSIF (rowCount = 0) THEN
            DBMS_OUTPUT.PUT_LINE('No Rows were inserted');
       END IF;
      
     CLOSE cBike;
  END EXTRACT_BICYCLES;
 
 /* PROCEDURE EXTRACT_CUSTOMERS
  This Procedure excepts an Input value as a VARCHAR2 and 
  queries the database for the customer entries in the CUSTOMER
  table. If the input value is 'S' then the procedure will display
  the information to the console. If the input type is 'D' then the 
  procdure will insert the data into the current user's schema.
*/ 
  PROCEDURE EXTRACT_CUSTOMERS(OUTPUT_TYPE IN VARCHAR2) AS
  
    CURSOR cCust IS  --Creates a cursor for navigating through the result set
      SELECT c.CUSTOMERID, c.LASTNAME, c.FIRSTNAME,
              c.PHONE, c.ADDRESS, s.CITY, s.STATE, c.ZIPCODE
              FROM BIKE_SHOP.CUSTOMER c
              JOIN BIKE_SHOP.CITY s
                ON c.CITYID = s.CITYID
                ORDER BY c.LASTNAME ASC, c.FIRSTNAME ASC;
        
    rCust cCust%ROWTYPE; --Creates a rowtype for each instance of cCust
    
    rowCount NUMBER := 0; --Declares a row counter for displaying inserted Rows
    
  BEGIN
  
   OPEN cCust; 
    LOOP 
     
      FETCH cCust INTO rCust;
      EXIT WHEN cCust%NOTFOUND;
      
      IF(OUTPUT_TYPE = 'S') THEN --Prints the data to the console if 'S' is entered
          DBMS_OUTPUT.PUT_LINE('-------CUSTOMER INFO-------------');
          DBMS_OUTPUT.PUT_LINE('Customer ID:  ' || rCust.CUSTOMERID);
          DBMS_OUTPUT.PUT_LINE('First Name:   ' || rCust.FIRSTNAME);
          DBMS_OUTPUT.PUT_LINE('Last Name:    ' || rCust.LASTNAME);
          DBMS_OUTPUT.PUT_LINE('Phone:        ' || rCust.PHONE);
          DBMS_OUTPUT.PUT_LINE('Address:      ' || rCust.ADDRESS);
          DBMS_OUTPUT.PUT_LINE('City:         ' || rCust.CITY);
          DBMS_OUTPUT.PUT_LINE('State:        ' || rCust.STATE);
          DBMS_OUTPUT.PUT_LINE('Zip Code:     ' || rCust.ZIPCODE);
          DBMS_OUTPUT.NEW_LINE();
      
      ELSIF(OUTPUT_TYPE = 'D') THEN --inserts the data into the users schema if a 'D' is entered
          INSERT INTO CUSTOMERS
            VALUES (rCust.CUSTOMERID, rCust.LASTNAME, rCust.FIRSTNAME,
                    rCust.PHONE, rCust.ADDRESS, rCust.CITY, rCust.STATE, 
                    rCust.ZIPCODE);
            
            rowCount := rowCount + SQL%ROWCOUNT; --Counts rows inserted and store # in rowCount
      
      ELSE DBMS_OUTPUT.PUT_LINE('Error! Please enter an "S" for displaying data
                                   or "D" for inserting the data into users schema!');
      END IF;             
    END LOOP;
    
     --Displays the number of rows inserted
       IF (rowCount > 0) THEN
          DBMS_OUTPUT.PUT_LINE('# of Rows Inserted: ' || rowCount);
       ELSIF 
            DBMS_OUTPUT.PUT_LINE('No Rows were inserted');
       END IF;
       
    CLOSE cCust;
  END EXTRACT_CUSTOMERS;
  
/* FUNCTION CUSTOMER_BIKES
  This Function queries the BIKE_SHOP schema and pulls records from CUSTOMER and 
  BICYCLE tables where the customer had a matching purchase on the bicycle table,
  the resulting records are then placed into the temporary table TEMP_CUST_TABLE
  to be used for further manipulation.
*/ 
  FUNCTION CUSTOMER_BIKES(CUSTOMER_ID IN NUMBER) RETURN TEMP_CUST_TABLE IS
  
  cust CUST_ORDERS := CUST_ORDERS(0,0); --create a CUST_ORDERS object
  custTable TEMP_CUST_TABLE := TEMP_CUST_TABLE(); --create a TEMP_CUST_TABLE object
  counter NUMBER := 0; --initialize the counter
  rowCount NUMBER := 0; --Declares a row counter for displaying inserted Rows
   
  BEGIN 
          
    FOR rec IN (SELECT CUSTOMERID, SERIALNUMBER
          FROM BIKE_SHOP.BICYCLE
          WHERE CUSTOMERID = CUSTOMER_ID) LOOP
    
    custTable.extend(1); --extend the table by 1
    counter := counter + 1; --increment counter
    
    --Creates the CUST_ORDERS object and assigns it to the custTable(counter) position
    cust := CUST_ORDERS(rec.CUSTOMERID, rec.SERIALNUMBER);
    custTable(counter) := cust;
    
    rowCount := rowCount + SQL%ROWCOUNT; --Counts rows inserted and store # in rowCount
    
    END LOOP;
    
    --Displays the number of rows inserted
       IF (rowCount = 0) THEN
          DBMS_OUTPUT.PUT_LINE('No Rows were inserted');
       END IF;
    
    RETURN TEMP_CUST_TABLE;
    
  END CUSTOMER_BIKES;
  

/* PROCEDURE ARCHIVE_CUSTOMER_BIKES
  This Procedure loops through the current state of TEMP_CUST_TABLE and inserts 
  the data row by row into the CUSTOMER_BIKE table in the users schema.
*/   
  PROCEDURE ARCHIVE_CUSTOMER_BIKES IS
      
   custTable TEMP_CUST_TABLE;   
    
  BEGIN
   --inserts the records in the table returned from CUSTOMER_BIKES and inserts into CUSTOMER_BIKE
    FOR rw IN (SELECT * FROM TABLE(CUSTOMER_BIKES)) LOOP       
      INSERT INTO CUSTOMER_BIKE
        VALUES(rw.CUSTOMERID, rw.SERIALNUMBER);
        
    END LOOP;
     
  END ARCHIVE_CUSTOMER_BIKES;

END BIKESHOP;
/

/*DELETE THESE FOR FINAL TURN IN*/
EXECUTE BIKESHOP.EXTRACT_CUSTOMERS('D');
EXECUTE BIKESHOP.EXTRACT_CUSTOMERS('S');
EXECUTE BIKESHOP.EXTRACT_BICYCLES('D');
EXECUTE BIKESHOP.EXTRACT_BICYCLES('S');

