

--事务的错误捕捉和回滚

/*
数据库引擎根据错误的严重级别的轻重分为4个级别
	等级[severity] 0`10 时，为“信息性消息”,数据库引擎不会引起严重级别为0`9的系统错误。
	等级[severity] 11`16时, 为“用户可以纠正的数据库引擎错误”。如除数为0
	等级[severity] 17`19时，为“需要DBA注意的错误”.如内存不足，数据库引擎已到极限等。
	等级[severity] 20`25时, 为“致命错误或系统问题”.如硬件或软件损坏，完整性问题等造成数据库连接中止的错误，
*/
--Exec spCRM_AddMessage
--Exec spEM_AddMessage
--Exec spSD_AddMessage
--Exec spBC_AddMessage

--错误信息捕获
/*
RaisError函数可以返回1`25级别的错误信息
try..catch 可捕捉所有严重级别大于10但不终止数据库连接的错误.严重级别0`10的错误是信息性消息，并不导致执行从try中跳出。
而终止数据库连接的错误（通常严重级别为20`25）不由catch块处理，因为连接终止后执行也中止了。

*/
--1)RaisError可用抛出指定编号的错误信息或动态的构建错误信息
RaisError(N'没有用户ID，请先到系统参数设置,才能使用自动合并功能', 16, 1,N'错误')
RaisError(100016, 16, 1,@CheckBillNo)  	

--2)当begin try 捕捉到错误时,会转到begin catch模块，这里可以做事务回滚，抛出错误，错误写日志
begin catch
	ROLLBACK
	PRINT '事务回滚' --构造一个错误信息记录

	SELECT ERROR_NUMBER() AS 错误号,
	ERROR_SEVERITY() AS 错误等级,
	ERROR_STATE() as 错误状态,
	DB_ID() as 数据库ID,
	DB_NAME() as 数据库名称,
	ERROR_MESSAGE() as 错误信息;

	insert into ErrorLog(sMessage)
	select ERROR_MESSAGE() as 错误信息
end catch

--3)@@error 上一条语句的执行错误信息
if @@error<>0 print '出错啦'

--自定义错误信息
--可以使用sp_addmessage将严重级别为1`25的用户定义错误消息添加到 "sys.messages"目录视图中。这些用户定义的错误消息可供RaisError使用.

--权限要求具有 sysadmin 和 serveradmin 固定服务器角色的成员身份
Exec sp_AddMessage 80002, 16, N'The bill', N'us_english',False,Replace
Exec sp_AddMessage 80002, 16, N'此单据已被引用，不能作废！', N'Simplified Chinese',False,Replace
Exec sp_AddMessage 80002, 16, N'此單據已被引用，不能作廢！', N'Traditional Chinese',False,Replace

select * from sys.messages


--------事务回滚----------------------------------------------------------------------------------
晚上


---后期处理
 Set Language @Lang --E)还原语言 
 Set @RetVal = -1 	  
 return --F)退出