/*
存储过程的好处
1,帮助在数据层聚集t-sql代码
2,帮助大的即席查询减少网络流量
3,促进代码的可复用性。
4，淡化数据获取的方法
5，与视图不同，存储过程可以利用流控制，临时表，表变量等
6,对查询响应时间的影响比较稳定
*/

--存储过程
/*
声明参数
1)名称		:以@开头，不能内嵌空格，符合命名规则
2)数据类型	:sqlserver内置或用户自定义的有效数据类型
3)默认值	：参数初始值
4)方向		：output表示引用外部变量地址。（也可理解为输出参数）

return 返回值：必须为整数，默认返回0,表示存储过程执行成功，return处返回
返回值可用于实际地返回数据，比如标识值或是存储过程影响的行数，一般主要用于确定存储过程的执行状态。
*/

--返回值存变量----------------------------------------
DECLARE @RetVal INT
EXEC @RetVal = Sp_TestReturns;
SELECT @RetVal

/*
存储过程的编译：第一次运行：优化并编译
当不是第一次运行，但不在缓存中：重新编译
当不是第一次运行，但在缓存中，直接运行。

除非手动地干预(with recompile),否则只会在第一次运行存储过程时，或者当查询所涉及的表更新了统计信息时，才对存
储过程进行优化。
*/

--1,创建
CREATE PROCEDURE proName(
@sqlParam nvarchar(100)
,@param2 int
)
AS

--定义变量
DECLARE @varName int
DECLARE @varName2 nvarchar(1000)
DECLARE @sql nvarchar(4000)

--打印结果和执行语句,退出
PRINT @varName
EXECUTE(@sql)
RETURN 

--给变量赋值
SET @varName = 'a'
SELECT @varName = filed FROM tableName



 BEGIN TRY
 --正常语句
 END TRY
 begin CATCH
	--执行出错
		Set @RetBillNo = ''	--A)设数据为空
 	    Set  @RetVal = -1	--B)设条件号为-1
 	     Select @Msg = ERROR_MESSAGE() ;	--C)获取错语信息
 	    INSERT INTO  [BC_Bas_MargeOrderLog]	--D)写表
 END CATCH 
 
 --使用系统表处理
 RaisError(100016, 16, 1,@CheckBillNo)  	  
 Set Language @Lang --E)还原语言 
 Set @RetVal = -1 	  
 return --F)退出
 
 
 

--存储过程调用存储过程
/*
子存储过程返回执行状态
@RetVal int Output 参数

返回
Set @RetVal=-1
RETURN @RetVal


主存储过程中
exec procName
IF @RetVal<>1
return
*/	


--退出信息
Declare @MsgLangID Int
Select @MsgLangID = msglangid From sys.syslanguages  Where name = @@LANGUAGE  
Begin
	Set @RetVal = 0
	--单据不存在
	Select [text] From sys.messages Where message_id = 50001 And language_id = @MsgLangID
	Set Language @Lang 
	Return 
END

--数据库语言选择
Set NoCount On 
Declare @Lang nVarchar(30) --暂存原语种
Set @Lang = @@Language
--设置为客户端选用语种
If Upper(@FormLang) = 'CN' 
	Set Language 'Simplified Chinese'  --简体 
Else If Upper(@FormLang) = 'TW' 
	Set Language 'Traditional Chinese' --繁体
Else If Upper(@FormLang) = 'KR' 
	Set Language 'Lorean'              --韩语
Else If Upper(@FormLang) = 'JP' 
	Set Language 'Japanese'            --日语
Else If Upper(@FormLang) = 'EN' 
	Set Language 'English'             --英语  
--================================	
		

--sqlServer 启动时自动执行存储过程

--切换到master,只在在这个地方才能放置自动执行的存储过程
USE master
go 

--定义一个要sqlserver启动后自动执行的存储过程
CREATE PROCEDURE sqlStartupLog(
	@startupDateTime datetime NOT null
)
AS
INSERT INTO sqlStartupLog(startupDateTime)VALUES(GETDATE()
go

--自执行设置
EXEC sys.sp_procoption  @ProcName = N'sqlStartupLog', -- nvarchar(776) 要执行的存储过程名称
    @OptionName = 'startup', -- varchar(35) 活动
    @OptionValue = 'true' -- varchar(12) 表示启用或禁用


--查看存储过程元数据
SELECT * FROM sys.sql_modules

 

	
--用于控制条件分支，选择的方法
SELECT @@ERROR
--错误跳转，多在事务中，没错误就继续往下执行，有错误就跳转到错误判断语句，回滚或提交
	DECLARE @error	int
	SET @ERROR = 0
	--执行一条语句
	SET @ERROR = @@ERROR
		IF(@ERROR <> 0)
		GOTO ERROR
		
		--跳转点
	ERROR:
		IF(@ERROR <> 0)
		BEGIN
			ROLLBACK TRANSACTION
			--写日志
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			--执行后续语句
		END	

-------------------------------------------------------------------------------------------
----存储过程的起手五式：-------------------------------------------------------------------

--1，判断存储过程参数，并初始化--------------------------------------------------

IF @objectId IS NULL -- 判断对象是否存在
    BEGIN
        PRINT 'The object not exists'
        RETURN
    END	
    
IF ISNULL(@var,'') =''
	SET @var = '初始值'   
	
--2，获取基准数据，处理及转换数据格式--------------------------------------------------

	--分割字符串形成临时表
	 Create Table #CardTypeList (CardTypeID varchar(20) )	
		if IsNull(@CardTypeID,'') <> ''
		begin
			insert into #CardTypeList(CardTypeID) Select * From dbo.fnSys_SplitString(@CardTypeID,',')
		end
		else
			set @CardTypeID =Null;  
			
	--提取小部份参与关联的数据存临时表		  	
	 Select StateFixFlag, StateId, StateType,
	  Into #TmpVIPOperState
		From Sys_State 
		Where StateFixFlag = 'VIPOperState'	

--3，处理业务逻辑--------------------------------------------------------------------------
/*
根据基准数据，按业务要求对数据进行加工，关联，处理,构建事实表
比如循环，分支条件，调用等
*/

--4，数据合并----------------------------------------------------------------------
/*
对处理完的业务数据根据最终显示要求进行数据合并,构建维度表与并事实表关联
*/

--5，清除临时表----------------------------------------------------------------------

If OBJECT_ID('tempdb.dbo.#StateList') Is Not Null 
	Drop Table #StateList	