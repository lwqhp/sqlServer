sysname
sysname 数据类型用于表列、变量以及用于存储对象名的存储过程参数。sysname 的精确定义与标识符规则有关。因此，
它可能会因 SQL Server 实例的不同而有所不同。除了 sysname 在默认情况下为 NOT NULL 之外，sysname 的功能
与 nvarchar(128) 相同。在早期版本的 SQL Server 中，sysname 被定义为 varchar(30)

这个可以在一些系统表中看到（如sysobjects表的name字段就是sysname类型的）的，
因此 sysname类型直接决定了tablename的字符空间，如6.5之前的表名不支持中文，而2000以后的表名就支持中文，
就是因为sysname再两个版本中的含义不一样

table_name、column_name等可以是由用户自己输入的符合sysname类型的的数据，说明这些名称是sysname类型的，
因此，这些名称你可以使用nvarchar(128)的任意字符串；而数据类型（如column1_datatype）、
主键标示（如columns_in_primary_key）等就不是sysname类型的，区别就在这里。（帮助理解的句子，外引，自注！）