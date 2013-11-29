
ANSI_PADDING
--数据库常用一些设置


/*
SET QUOTED_IDENTIFIER ON 可以使用关键字（"select" "update" 等）作为对象名(表名)
而SET QUOTED_IDENTIFIER OFF 不可以这么使用，因为系统会解析"select"，"update"等为关键字
*/
SET QUOTED_IDENTIFIER ON  
GO 
SET QUOTED_IDENTIFIER OFF  
GO 

/*
指定在对空值使用等于 (=) 和不等于 (<>) 比较运算符时，是否遵从 SQL-92 标准。ON 遵从，OFF 不遵从

SQL-92 标准:对空值的等于 (=) 或不等于 (<>) 比较取值为 FALSE。
Column_name = null，Column_name <> null 无效。正确应该是 column_name is null ,column_name is not null
*/
SET ANSI_NULLS ON
GO
SET ANSI_NULLS OFF
go 

/*
是否返回受影响的行数
*/
SET NOCOUNT ON
GO
SET NOCOUNT OFF
GO 


/*
当 SET XACT_ABORT 为 ON 时，如果执行 Transact-SQL 语句产生运行时错误，则整个事务将终止并回滚。
当 SET XACT_ABORT 为 OFF 时，有时只回滚产生错误的 Transact-SQL 语句，而事务将继续进行处理。如果错误很严重，那么即使 SET XACT_ABORT 为 OFF，也可能回滚整个事务。
编译错误（如语法错误）不受 SET XACT_ABORT 的影响。
*/
SET XACT_ABORT ON 
GO
SET XACT_ABORT OFF
GO

/*
对空格的影响，ON时，按sql 标准，保留空格，OFF时，去掉前后空格，不管类型是char,varchar,binary
*/

SET ANSI_PADDING ON
GO
SET ANSI_PADDING OFF
GO