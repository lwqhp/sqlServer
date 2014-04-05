

--事务的错误捕捉和回滚

/*
数据库引擎根据错误的严重级别的轻重分为4个级别
	等级[severity] 0`10 时，为“信息性消息”,数据库引擎不会引起严重级别为0`9的系统错误。
	等级[severity] 11`16时, 为“用户可以纠正的数据库引擎错误”。如除数为0,如果没有设置try/catch块，那么这些错误
							会终止过程执行并在客户端引发错误。状态显示为设置的任何值，如果定义了try块，那么将
							调用错误处理程序，而不是在客户端引发错误。
	等级[severity] 17时		，通常只有sqlserver会使用这个错误严重性级别，基本上，它表时sqlserver用完了资源（比如tempdb已满）
							而且不能完成请求。				
	等级[severity] 18`19时，为“需要DBA注意的错误”.如内存不足，数据库引擎已到极限等。而且暗示系统管理员要注意底层原因，
							对于错误严重性级别19来说，需要使用with log选项，事件将在windows event log中显示。
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
--1)RaisError可用抛出用户指定编号的错误信息或动态的构建错误信息给客户端。
RaisError(N'没有用户ID，请先到系统参数设置,才能使用自动合并功能', --自定义错误信息或者是消息ID
	16, --严重级别
	1,	--代码中发生错误位置的标识码
	N'错误' --代入错误的动态参数(%1,%2) 
	)

declare @CheckBillNo varchar(30)
set @CheckBillNo='222'
RaisError(100016, 16, 1,@CheckBillNo)  	

begin try
	raiserror('xxx',12,3)
	with log --保存到window日志
	 ,nowait --错误发送到客户端
	 ,seterror --将@@error值和error_number值设置为<消息ID>或50000
end try
begin catch
	select ERROR_MESSAGE(),error_state(),ERROR_SEVERITY()
	throw; --重新抛出错误
end catch


--2)当begin try 捕捉到错误时,会转到begin catch模块，这里可以做事务回滚，抛出错误，错误写日志
begin catch
	ROLLBACK
	--业务处理
	PRINT '事务回滚' --构造一个错误信息记录

	--返回错误信息
	SELECT ERROR_NUMBER() AS 错误号,
	ERROR_SEVERITY() AS 错误等级,
	ERROR_STATE() as 错误状态,
	DB_ID() as 数据库ID,
	DB_NAME() as 数据库名称,
	ERROR_LINE() as 错误行号,
	ERROR_PROCEDURE() as  返回出现错误的存储过程或触发器的名称,
	ERROR_MESSAGE() as 返回错误消息的完整文本。该文本可包括任何可替换参数所提供的值，如长度、对象名或时间。

	--写日志
	insert into ErrorLog(sMessage)
	select ERROR_MESSAGE() as 错误信息
end catch

--3)@@error 上一条语句的执行错误信息，通常会把@@error放到变量中，最后统一处理
if @@error<>0 print '出错啦'

--4)@@trancount 返回在当前连接上执行的 BEGIN TRANSACTION 语句的数目
/*begin  tran 语句将 @@Trancount加 1。
Rollback  tran将 @@Trancount递减到 0，
但 Rollback tran savepoint_name 除外，它不影响 @@Trancount。Commit  tran 或 Commit  work 将 @@Trancount 递减 1。*/
BEGIN TRY
    BEGIN TRANSACTION
    -- You code here.
     COMMIT TRANSACTION --在try块内提交事务
END TRY
BEGIN CATCH
    IF (@@TRANCOUNT > 0)
        -- Adds store procedure
        -- Writes the error into ErrorLog table.
        ROLLBACK TRANSACTION
END CATCH


--自定义错误信息
--可以使用sp_addmessage将严重级别为1`25的用户定义错误消息添加到 "sys.messages"目录视图中。这些用户定义的错误消息可供RaisError使用.

/*
定义：
用户自定义错误消息的ID必须大于50000
首先要添加一个英文版本的错误消息，然后才能添加其他语言的版本，如果没有指定语言，则使用默认的语言
*/
exec sp_addmessage 500001,--错误消息ID
	15,	--指定严重级别
	N'XXX',--错误信息
	us_english --语言

--修改
exec sp_altermessage 500001, --ID
	'WITH_LOG', --写入window日志
	'true'	--是否写入

exec sp_dropmessage 500001,--id
	'all' --全部

--权限要求具有 sysadmin 和 serveradmin 固定服务器角色的成员身份
Exec sp_AddMessage 80002, 16, N'The bill', N'us_english',False,Replace
Exec sp_AddMessage 80002, 16, N'此单据已被引用，不能作废！', N'Simplified Chinese',False,Replace
Exec sp_AddMessage 80002, 16, N'此單據已被引用，不能作廢！', N'Traditional Chinese',False,Replace

select * from sys.messages


--------事务回滚----------------------------------------------------------------------------------
/*
默认参数XACT_ABORT 为OFF,当事务（隐式或显式声明）提交时发生错误，只会回滚错误的语句，错误语句前后的语句都会执行。
当时 XACT_ABORT 为ON时，事务中（隐式或显式声明）出现错误时，将回滚整个事务。

注：如果需要回滚整个事务，建议捕捉错语后手动回滚事务。
*/
set  xact_abort on

--嵌套事务


/*在这个示例中，联系人的电子邮件地址在一个嵌套事务中被更新，这会被立即提交。然后ROLLBACK TRAN被执行。
ROLLBACK TRAN将@@TRANCOUNT减为0并回滚整个事务及其中嵌套的事务，无论它们是否已经被提交。
因此，嵌套事务中所做的更新被回滚，数据没有任何改变。
*/
use AdventureWorks2012
go

BEGIN TRAN
    PRINT 'After 1st BEGIN TRAN: ' + CAST(@@trancount as char(1))
    BEGIN TRAN
        PRINT 'After 2nd BEGIN TRAN: ' + CAST(@@trancount as char(1))
            BEGIN TRAN
            PRINT 'After 3rd BEGIN TRAN: ' + CAST(@@trancount as char(1))
            UPDATE Person.EmailAddress
            SET EmailAddress = 'test@test.at'
            WHERE EmailAddressID = 20
            COMMIT TRAN
        PRINT 'After first COMMIT TRAN: ' + CAST(@@trancount as char(1))
ROLLBACK TRAN

PRINT 'After ROLLBACK TRAN: ' + CAST(@@trancount as char(1))
SELECT * FROM Person.EmailAddress
WHERE EmailAddressID = 20;

/*
始终牢记:
在嵌套的事务中，只有最外层的事务决定着是否提交内部事务。
每一个COMMIT TRAN语句总是应用于最后一个执行的BEGIN TRAN。因此，对于每一个BEGIN TRAN，必须调用一个COMMIT TRAN来提交事务。
ROLLBACK TRAN语句总是属于最外层的事务，并且因此总是回滚整个事务而不论其中打开了多少嵌套事务。
正因为此，管理嵌套事务很复杂。如果每一个嵌套存储过程都在自身中开始一个事务，那么嵌套事务大部分会发生在嵌套存储过程中。
要避免嵌套事务，可以在过程开始处检查@@TRANCOUNT的值，以此来确定是否需要开始一个事务。如果@@TRANCOUNT大于0，
因为过程已经处于一个事务中并且调用实例可以在错误发生时回滚事务。

*/

BEGIN TRAN t1
SELECT @@trancount --1
	BEGIN TRAN t2
	SELECT @@trancount --2
		BEGIN TRAN t3
		SELECT @@TRANCOUNT --3
		COMMIT TRAN 
		SELECT @@TRANCOUNT -2
	ROLLBACK TRAN 
	SELECT @@trancount --0

---后期处理
 Set Language @Lang --E)还原语言 
 Set @RetVal = -1 	  
 return --F)退出