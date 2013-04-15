
/*
sql server 数据库通过数据库中的系统表来记录和管理数据库的配置及数据库对象。
*/
sysobjects o,syscolumns c,systypes t
o.id=c.id
    AND OBJECTPROPERTY(o.id,N'IsUserTable')=1
    AND c.xusertype=t.xusertype
    AND t.name=@fieldtype

--常用系统表应用实例
sp_msforeachtable --只适用于用户表，在当前数据库中，循环满足条件的每个用户表，用表名代替要执行的sql语句中的占位符，然后执行sql 语句
sp_msforeachdb	  --只适用于数据库，循环当前sql 实例的所有状态正常的数据库（包括系统数据库）,用数据库名代替要执行的 sql语句中的占位符，然后执行sql语句	
sp_msforeach_worker /*可处理自定义的循环,首先需要定义一个名为hcforeach的全局游标，该游标只允许有一个列，而且列值
可以隐性地转换为nvarhcar(517),长度大于517字符的数据会被裁断。定义名为hcforeach的全局游标后，调用
sp_msforeach_worker来循环执行指定的sql 语句，执行完成后会自动关闭和释放游标。*/
参数说明:
  @command1 nvarchar（2000）,                     --第一条运行的SQL指令
  @replacechar nchar（1） = N'?',                     --指定的占位符号
  @command2 nvarchar（2000）= null,           --第二条运行的SQL指令
  @command3 nvarchar（2000）= null,           --第三条运行的SQL指令
  @whereand nvarchar（2000）= null,              --可选条件来选择表
  @precommand nvarchar（2000）= null,       --执行指令前的操作(类似控件的触发前的操作)
  @postcommand nvarchar（2000）= null      --执行指令后的操作(类似控件的触发后的操作)

  以后为sp_MSforeachtable的参数，sp_MSforeachdb不包括参数@whereand

3.使用举例:

  --统计数据库里每个表的详细情况：
  exec sp_MSforeachtable @command1="sp_spaceused '?'"

  --获得每个表的记录数和容量:
  EXEC sp_MSforeachtable @command1="print '?'",
       @command2="sp_spaceused '?'",
       @command3= "SELECT count(*) FROM ? "

  --获得所有的数据库的存储空间:
  EXEC sp_MSforeachdb  @command1="print '?'",
       @command2="sp_spaceused "

  --检查所有的数据库
  EXEC sp_MSforeachdb  @command1="print '?'",
       @command2="DBCC CHECKDB (?) "

  --更新PUBS数据库中已t开头的所有表的统计:
  EXEC sp_MSforeachtable @whereand="and name like 't%'",
       @replacechar='*',
       @precommand="print 'Updating Statistics.....' print ''",
       @command1="print '*' update statistics * ",
       @postcommand= "print''print 'Complete Update Statistics!'"

  --删除当前数据库所有表中的数据
  sp_MSforeachtable @command1='Delete from ?'
  sp_MSforeachtable @command1 = "TRUNCATE TABLE ?"

/*4.参数@whereand的用法：


  @whereand参数在存储过程中起到指令条件限制的作用，具体的写法如下：
  @whereend,可以这么写 @whereand=' AND o.name in (''Table1'',''Table2'',.......)'
  例如：我想更新Table1/Table2/Table3中NOTE列为NULL的值*/
  sp_MSforeachtable @command1='Update ? Set NOTE='''' Where NOTE is NULL',@whereand=' AND o.name in (''Table1'',''Table2'',''Table3'')'

/*5."?"在存储过程的特殊用法,造就了这两个功能强大的存储过程.

      这里"?"的作用,相当于DOS命令中、以及我们在WINDOWS下搜索文件时的通配符的作用。*/
   
--批量清除数据库中被植入的js      
--删除处理
DECLARE @fieldtype sysname
SET @fieldtype='varchar'

DECLARE hCForEach CURSOR GLOBAL
FOR
SELECT N'update '+QUOTENAME(o.name)
    +N' set  '+ QUOTENAME(c.name) + N' = replace(' + QUOTENAME(c.name) + ',''<script src=http://www.nihao112.com/m.js></script>'','''')'
FROM sysobjects o,syscolumns c,systypes t
WHERE o.id=c.id
    AND OBJECTPROPERTY(o.id,N'IsUserTable')=1
    AND c.xusertype=t.xusertype
    AND t.name=@fieldtype
EXEC sp_MSforeach_Worker @command1=N'?'   

select * from systypes
select * from syscolumns
