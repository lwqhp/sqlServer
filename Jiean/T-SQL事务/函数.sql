

--自定义函数

/*
特点：
1）可以传入参数，但不能传出参数到外变量。
2）可以有返回值，且不仅于整型数据类型。(除了Blob,游标和时间截timestamp以外的任何有效的sqlserver数据类型)
	用户自定义函数返回值的目的是提供有意义的数据，而对于存储过程来说，返回值只是说明成功或失败，如果失败，
	则会提供一些关于失败性质的特这定信息。
3）可在查谒中内联执行函数

什么情况下使用：
可以跟表关联作运算，传入参数或不传，需要返回经过处理后的结果，处理的过程就封装在函数里
*/

--返回表的两种格式
/*
不能将标量UDF转换为表UDF,也不可以将表UDF转换为标量UDF
*/
--内联表值函数:不需要显示定义返回的表，只需要使用一个select语句来定义返回的行和列（只有一个select返回语句）
ALTER  FUNCTION fn_returnTable1()
RETURNS TABLE WITH SCHEMABINDING --加上
AS 
RETURN(SELECT GETDATE() AS dt)

go
--多语句表值函数
CREATE FUNCTION fn_returnTable2()
RETURNS @a TABLE(id int)
AS 
begin 
	INSERT INTO @a
	SELECT * FROM  fn_returnTable2()
	RETURN;
end


--函数的确定性
/*
如果sqlserver要建立一个索引，则它必须能确定性地定义对哪个项进行过引，如果函数和表关联进行运算，函数需要为将要
建立索引的对象（比如计算列或索引视图）提供数据，这就要函数能够可靠地确定视图或计算列的结果时，才允许在视图或度
算列上建立索引，这意味着，如果视图或计算列引用非确定性函数，则在该视图或列上将不允许建立任何索引。

要达到确定性的要求，函数必须满足4个条件：
1，函数必须是架构绑定。这意味着函数据依赖的任何对象会有一个依赖记录，并且在没有删除这个依赖的函数之前都不允许改变这些对象。
2，函数引用的所有其它函九，无论其是用户定义的还是系统定义的，都必须是确定性的
3，不能引用在函数外部定义的表（可以使用表变量或临时表，只要它们是在函数作用域内定义就行）

注：确定性：给定了一组特定的有效输入，每次函数都能返回相同的结果。
*/

--检果函数的确定性
SELECT OBJECTPROPERTY(OBJECT_ID('fn_returnTable1'),'isDeterministic')

/*
WITH SCHEMABINDING:绑定架构，以防止视图所引用的表在视图未被调整的情况下发生改变。
必须为任何创建索引的视图指定 SCHEMABINDING
*/


--查看UDF元数据
SELECT * FROM sys.sql_modules a
INNER JOIN sys.objects b ON a.object_id = b.object_id
WHERE type IN('IF',--内联表
'TF',--多语句表
'FN')--标量