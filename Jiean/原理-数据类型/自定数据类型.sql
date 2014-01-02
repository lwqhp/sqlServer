

--UDT用户自定数据类型
/*
用户定义类型用于定义一种和已知业务或以应用程序为中心的属性一致的数据类型，通常也叫别名类型
不能用alter命令修改既有类型。
*/
create type T_Billno from varchar(20) not null
create type T_billno_L from varchar(40) null


--定义表值类型
/*
这是sqlserver2008的新功能，可以自定义表值类型，作为函数和存储过程的表集输入参数
*/
CREATE TYPE tb_billno AS TABLE(billno VARCHAR(20))
go

CREATE PROCEDURE spPro_Name (@tbBillno tb_billno READONLY)
/*readonly是存储过程和用户定义函数输入参数需要的，因为在sqlserver2008中不允许更改表值结果集*/
AS
	SELECT * from @tbbillno
	
	--也可以用于直接定义变表量
	DECLARE @tbVar AS tb_billno
go


--删除
drop type T_Billno

--查看用户定义类型的底层基本类型
EXEC sp_help 'dbo.T_billno'

--在移除用户定义数据类型之前，需要知道如何找出依赖某个类型的所有数据库对象

--使用了UDT的列和参数
SELECT  OBJECT_NAME(a.object_id) AS table_name,a.name AS  column 
FROM sys.columns a
INNER JOIN sys.types b ON a.user_type_id = b.user_type_id
WHERE b.name='T_billno'

--使用了UDT的作为函数或存储过程的参数引用的
SELECT * FROM sys.parameters a
INNER JOIN sys.types b ON a.user_type_id = b.user_type_id





