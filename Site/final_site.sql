SET SERVEROUTPUT ON;
SET VERIFY OFF;

drop table input;
drop table result;
drop table Mart1;


create table input(
Weight float,
Type varchar2(20),
MRP float,
Out_Size varchar2(20),
Out_type varchar2(20)
);

create table Mart1(
Weight float,
Type varchar2(20),
MRP float,
Out_Size varchar2(20),
Out_type varchar2(20),
Item_outlet_sales float
);

create table result(
    Sales_pre float
);

insert into Mart1 values(19.65,'Dairy',184.88,'High','Supermarket',2045.84);
insert into Mart1 values(15.8,'FruitVeg',178.12,'Small','Grocery',816.45);
insert into Mart1 values(17.6,'Snack',106.47,'High','Supermarket',415.4);
commit;


Accept F_type CHAR  PROMPT  "Enter Food type: ";
Accept OS CHAR prompt "Enter Outlet_size: ";
Accept OT CHAR prompt "Enter Outlet_type: ";

DECLARE 
    type1 varchar2(30) := '&F_type';
    Outlet_size input.Out_size%Type := '&OS';
    Outlet_type input.Out_type%Type := '&OT';
    WEIGHT input.Weight%Type := &Weight;
    MRP input.MRP%Type := &MRP;
    
Begin
    DBMS_OUTPUT.PUT_LINE(type1||' '||WEIGHT);
    insert into input values(WEIGHT,type1,MRP,Outlet_size,Outlet_type);
    commit;
End;
/