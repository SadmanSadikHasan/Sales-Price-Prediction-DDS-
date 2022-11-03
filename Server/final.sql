SET SERVEROUTPUT ON;
SET VERIFY OFF;

drop table min_dist;
drop table Mart;
drop table distance;
drop table dist1;



CREATE TABLE Mart(
    Weight float,
	Type varchar2(30), 
	MRP float, 
	Out_size varchar2(30),
    Out_type varchar2(30),
    Item_outlet_sales float
); 

create table distance(
    weight_dist float,
    MRP_dist float,
    OutSize_dist float,
    OutType_dist float
);

create table dist1(
    rID INTEGER,
    dist_min float
);

CREATE OR REPLACE TRIGGER dist1 
After INSERT 
ON dist1
DECLARE
BEGIN
	DBMS_OUTPUT.PUT_LINE('dist1 Table created and values inserted');
END;
/

INSERT INTO Mart VALUES (9.3,'Dairy',249.809,'Medium','Supermarket',3735.138);
INSERT INTO Mart VALUES (18.5,'Dairy',144.11,'Small','Supermarket',2187.153);
INSERT INTO Mart VALUES (13.35,'Dairy',249.809,'Medium','Grocery',2748.422);
INSERT INTO Mart VALUES (5.92,'Drink',48.27,'Medium','Supermarket',443.42);
INSERT INTO Mart VALUES (6.02,'Drink',113.28,'Medium','Supermarket',2303.688);
INSERT INTO Mart VALUES (17.5,'Drink',174.873,'Small','Grocery',2085.268);
INSERT INTO Mart VALUES (19.2,'FruitVeg',182.092,'Medium','Grocery',732.38);
INSERT INTO Mart VALUES (11.8,'FruitVeg',45.54,'High','Supermarket',1516.027);
INSERT INTO Mart VALUES (16.35,'FruitVeg',196.4426,'High','Supermarket',1977.42);
INSERT INTO Mart VALUES (12.3,'Snacks',107.766,'Medium','Supermarket',4022.76);
INSERT INTO Mart VALUES (13.65,'Snacks',57.65,'High','Supermarket',343.552);
INSERT INTO Mart VALUES (17.7,'Snacks',185.42,'Small','Grocery',184.426);




commit;

CREATE OR REPLACE PACKAGE mypckg AS 
PROCEDURE CALC(A IN Mart.Out_size%TYPE, B IN  Mart.Out_type%TYPE, OT out distance.OutSize_dist%TYPE, OS OUT distance.OutSize_dist%TYPE);

PROCEDURE dist_calc(w IN Mart.Weight%TYPE, MRP IN Mart.MRP%TYPE, OS IN distance.OutType_dist%TYPE, OT IN distance.OutType_dist%TYPE);

FUNCTION KNN(A IN distance.OutType_dist%TYPE)
RETURN dist1.dist_min%TYPE;

END mypckg;
/

CREATE OR REPLACE PACKAGE Body mypckg AS 

PROCEDURE CALC(A IN Mart.Out_size%TYPE, B IN  Mart.Out_type%TYPE, OT out distance.OutSize_dist%TYPE, OS OUT distance.OutSize_dist%TYPE)
IS 

BEGIN 
    
    IF A = 'Medium' and B = 'Supermarket' THEN
        OS := 2.0;
        OT := 2.0;
        
    END IF;
    IF A = 'Small' and B = 'Supermarket' THEN
        OS := 1.0;
        OT := 2.0;
        
    END IF;
    IF A = 'High' and B = 'Supermarket' THEN
        OS := 3.0;
        OT := 2.0;
        
    END IF;
    IF A = 'High' and B = 'Grocery' THEN
        OS := 3.0;
        OT := 1.0;
        
    END IF;
    IF A = 'Small' and B = 'Grocery' THEN
        OS := 1.0;
        OT := 1.0;
        
    END IF;
    IF A = 'Medium' and B = 'Grocery' THEN
        OS := 2.0;
        OT := 1.0;
        
    END IF;
END CALC;


PROCEDURE dist_calc(w IN Mart.Weight%TYPE, MRP IN Mart.MRP%TYPE, OS IN distance.OutType_dist%TYPE, OT IN distance.OutType_dist%TYPE)
IS
dis dist1.dist_min%TYPE;
rn int := 0;
BEGIN
    FOR R IN (select * from distance) LOOP
        dis := SQRT(power((w-R.weight_dist),2) + power((MRP-R.MRP_dist),2) + power((OS-R.OutSize_dist),2) + power((OT-R.OutType_dist),2));
        rn := rn + 1;
        INSERT INTO dist1 values(rn,dis);
    END LOOP;

    
END dist_calc;


FUNCTION KNN(A IN distance.OutType_dist%TYPE)
RETURN dist1.dist_min%TYPE
IS
d dist1.dist_min%TYPE;
BEGIN
    d := 0;
    FOR R IN (select * from dist1 where rID <= 3 ORDER by dist_min ASC ) LOOP
        d := R.dist_min + d;
    END LOOP;
    d := d/3;
    RETURN d;
END KNN;


END mypckg;
/

BEGIN
    FOR R IN (SELECT * FROM Mart where Out_size = 'Small' and Out_type = 'Supermarket' UNION SELECT * FROM Mart1@site1 where Out_size = 'Small' and Out_type = 'Supermarket') LOOP
        INSERT INTO distance VALUES(R.Weight,R.MRP,1.0,2.0);
    END LOOP;
    FOR R IN (SELECT * FROM Mart where Out_size = 'Medium' and Out_type = 'Supermarket' UNION SELECT * FROM Mart1@site1 where Out_size = 'Medium' and Out_type = 'Supermarket') LOOP
        INSERT INTO distance VALUES(R.Weight,R.MRP,2.0,2.0);
    END LOOP;
    FOR R IN (SELECT * FROM Mart where Out_size = 'High' and Out_type = 'Supermarket' UNION SELECT * FROM Mart1@site1 where Out_size = 'High' and Out_type = 'Supermarket') LOOP
        INSERT INTO distance VALUES(R.Weight,R.MRP,3.0,2.0);
    END LOOP;
    FOR R IN (SELECT * FROM Mart where Out_size = 'Small' and Out_type = 'Grocery' UNION SELECT * FROM Mart1@site1 where Out_size = 'Small' and Out_type = 'Grocery') LOOP
        INSERT INTO distance VALUES(R.Weight,R.MRP,1.0,1.0);
    END LOOP;
    FOR R IN (SELECT * FROM Mart where Out_size = 'Medium' and Out_type = 'Grocery' UNION SELECT * FROM Mart1@site1 where Out_size = 'Medium' and Out_type = 'Grocery') LOOP
        INSERT INTO distance VALUES(R.Weight,R.MRP,2.0,1.0);
    END LOOP;
    FOR R IN (SELECT * FROM Mart where Out_size = 'High' and Out_type = 'Grocery' UNION SELECT * FROM Mart1@site1 where Out_size = 'High' and Out_type = 'Grocery') LOOP
        INSERT INTO distance VALUES(R.Weight,R.MRP,3.0,1.0);
    END LOOP;
END;
/

CREATE OR REPLACE view myview(Outlet_sales_prediction) as
select Sales_pre
from result@site1;



DECLARE
w Mart.Weight%TYPE;
MRP Mart.MRP%TYPE;
OS Mart.Out_size%TYPE;
OT Mart.Out_type%TYPE;
A distance.OutSize_dist%TYPE;
B distance.OutType_dist%TYPE;
d dist1.dist_min%TYPE;
E EXCEPTION;
BEGIN

    
    FOR R in (select Weight,MRP,Out_size,Out_type from input@site1) LOOP
        w := R.Weight;
        MRP := R.MRP;
        OS := R.Out_size;
        OT := R.Out_type;
    END LOOP;
    
    IF OS IS NULL OR OT IS NULL OR w IS NULL OR MRP IS NULL THEN
        RAISE E;
    ELSE
        CALC(OS,OT,A,B);
    END IF;

    
    dist_calc(w,MRP,A,B);

    d := KNN(B);
    
    DBMS_OUTPUT.PUT_LINE(d);
    INSERT INTO result@site1 values(d);
    commit;

    EXCEPTION
	    WHEN E THEN
		    DBMS_OUTPUT.PUT_LINE('NULL VALUE ENTERED');

END;
/


