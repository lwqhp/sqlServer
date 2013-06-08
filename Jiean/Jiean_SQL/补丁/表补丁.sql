
IF NOT EXISTS(SELECT 1 FROM sys.objects WHERE name = 'employee' AND type = 'U')
create table employee (empid int ,deptid int ,salary decimal(10,2))
insert into employee values(1,10,5500.00)
insert into employee values(2,10,4500.00)
insert into employee values(3,20,1900.00)
insert into employee values(4,20,4800.00)
insert into employee values(5,40,6500.00)
insert into employee values(6,40,14500.00)
insert into employee values(7,40,44500.00)
insert into employee values(8,50,6500.00)
insert into employee values(9,50,7500.00)


IF NOT EXISTS(SELECT 1 FROM sys.objects WHERE name ='EMPLOYEEa' AND type = 'U')
CREATE TABLE EMPLOYEEa (EMPID INT, FNAME VARCHAR(50),LNAME VARCHAR(50))
GO
INSERT INTO EMPLOYEEa  (EMPID, FNAME, LNAME) VALUES (2021110, 'MICHAEL', 'POLAND')
INSERT INTO EMPLOYEEa  (EMPID, FNAME, LNAME) VALUES (2021110, 'MICHAEL', 'POLAND')
INSERT INTO EMPLOYEEa  (EMPID, FNAME, LNAME) VALUES (2021115, 'JIM', 'KENNEDY')
INSERT INTO EMPLOYEEa  (EMPID, FNAME, LNAME) VALUES (2121000, 'JAMES', 'SMITH')
INSERT INTO EMPLOYEEa  (EMPID, FNAME, LNAME) VALUES (2011111, 'ADAM', 'ACKERMAN')
INSERT INTO EMPLOYEEa  (EMPID, FNAME, LNAME) VALUES (3015670, 'MARTHA', 'LEDERER')
INSERT INTO EMPLOYEEa  (EMPID, FNAME, LNAME) VALUES (1021710, 'MARIAH', 'MANDEZ')
GO

IF OBJECT_ID('SalesByQuarter') IS NULL 
CREATE TABLE SalesByQuarter
(    year INT,    -- 年份
    quarter CHAR(2),  -- 季度
    amount MONEY  -- 总额
)
--插入表数据
SET NOCOUNT ON
    DECLARE @index INT
    DECLARE @q INT
    SET @index = 0
    DECLARE @year INT
    while (@index < 30)
    BEGIN
        SET @year = 2005 + (@index % 4)
        SET @q = (CAST((RAND() * 500) AS INT) % 4) + 1
        INSERT INTO SalesByQuarter VALUES (@year, 'Q' + CAST(@q AS CHAR(1)), RAND() * 10000.00)
        SET @index = @index + 1
    END
    
---
IF object_id('student') IS NULL 
CREATE TABLE student([Name] varchar(10),lesson varchar(10),score int)
INSERT INTO student values('张三','语文',74)
insert INTO student values('张三','数学',83)
insert INTO student values('张三','物理',93)
INSERT INTO student values('李四','语文',74)
INSERT INTO student values('李四','数学',84)
INSERT INTO student values('李四','物理',94)
go    

IF object_id('studentCOl') IS NULL
CREATE TABLE studentCOl([Name] varchar(10),Chinese int,math int,physics int)
INSERT INTO studentCOl values('张三',74,83,93)
INSERT INTO studentCOl values('李四',74,84,94) 


--
create table 表A
(IDNEX_NO char(1), sort_no int,
A_num int, B_NUM int, 
C_NUM int, d_num int)

insert into 表A(IDNEX_NO,sort_no,A_num,B_NUM,C_NUM)
select 'a', 1, 100, 0, 100 union all
select 'a', 2, 50, 20, 30 union all
select 'a', 3, 40, 30, 10 union all
select 'a', 4, 0, 140, -140 union all
select 'b', 1, 200, 0, 200 union all
select 'b', 2, 50, 40, 10 union all
select 'b', 3, 0, 210, -210   


CREATE TABLE Sys_BillType
    (
      ID INT ,
      Bill_type VARCHAR(10) ,
      Bill_Code VARCHAR(10) ,
      cnt INT ,
      modifydtm DATETIME ,
      remark VARCHAR(10)
    )
INSERT  INTO Sys_BillType
        ( ID, Bill_type, Bill_Code, cnt )
VALUES  ( 1, 'POS', 'OS', 1 ),
        ( 2, 'INV', 'IM', 1 ),
        ( 3, 'Order', 'CK', 1 )
        
        
        
if not object_id('Tab') is null
    drop table Tab
Go
Create table Tab([Col1] int,[Col2] nvarchar(1))
Insert Tab
select 1,N'a' union all
select 1,N'b' union all
select 1,N'c' union all
select 2,N'd' union all
select 2,N'e' union all
select 3,N'f'
Go

SELECT * FROM Tab
        