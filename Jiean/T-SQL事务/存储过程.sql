

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
--返回值存变量
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


条件语句
IF @a >0 
BEGIN 

END
ELSE
	BEGIN
	
	end	
IF @a>0
BEGIN ...END
ELSE IF @a<0 
BEGIN ...END
ELSE
begin ...END 	

--循环语句
WHILE @var IS NOT NULL 
BEGIN
	赋值区别：SELECT 和 set ：如果没有记录，SELECT 中的变量赋值语句是不执行，还是原来的值，SET，则会返回null值给变量
	
	关键点：开始前，先给@var赋一个值，以判断是否要进入循环
		
	执行完后，重新取值给@var，否则会死循环
END 

/*
各语句块之间的承接
*/
--上面的执行控制下面块的选择
DECLARE @id INT=@@ROWCOUNT;
IF @id >0 

--中间调用存储过程，返回值
	--返回表
	INSERT INTO #tb
	EXEC spBC_MergeOrder 'A','B'
	
	--返回值和执行状态，控制下面块的选择
	DECLARE @RetVal TINYINT =0 --返回值   
	DECLARE @billno VARCHAR(20) --返回值  单号
	declare @FormLang Varchar(2) = 'CN'
	
	EXEC spBC_MergeOrder @RetVal   Output,   @FormLang , @RetBillNo   Output  
	
	IF @RetVal=0 
	BEGIN ...END
	ELSE IF @RetVal=-1 
	BEGIN ...END
 













--抛出错语
 RaisError(N'没有用户ID，请先到系统参数设置,才能使用自动合并功能', 16, 1,N'错误')
 
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
 
 
 
1,创建
CREATE PROCEDURE dbo.proName(
@sqlParam nvarchar(100)
,@param2 int
)
AS

定义变量
DECLARE @varName int
DECLARE @varName2 nvarchar(1000)
DECLARE @sql nvarchar(4000)

打印结果和执行语句,退出
PRINT @varName
EXECUTE(@sql)
RETURN 

给变量赋值
SET @varName = 'a'
SELECT @varName = filed FROM tableName


条件语句
IF @a >0 
BEGIN 

END
ELSE
	BEGIN
	end	

循环语句
WHILE @var IS NOT NULL 
BEGIN
	--关键点：开始前，先给@var赋一个值，以判断是否要进入循环
		
	--执行完后，重新取值给@var，否则会死循环
	SET @var=''
END 
	
--用于控制条件分支，选择的方法

@@ERROR
--错误跳转，多在事务中，没错误就继续往下执行，有错误就跳转到错误判断语句，回滚或提交
	SET @ERROR = 0
	执行一条语句
	SET @ERROR = @@ERROR
		IF(@ERROR <> 0)
		GOTO ERROR
		
		--跳转点
	ERROR:
		IF(@ERROR <> 0)
		BEGIN
			ROLLBACK TRANSACTION
			INSERT INTO nn_sys_returnerp_log([office_missive_id]
		  ,[type]
		  ,[log_datetime]
		  ,[desc])
			VALUES(@office_missive_id,2,getdate(),Convert(varchar(30),@ERROR)+'移转到办结表出错!');
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			/*只有办结的单才自动加签名，中止的单不应该增加自动签名?*/	
			IF EXISTS(SELECT 0 FROM office_missive_search WHERE office_missive_id =	@office_missive_id 
AND m_isback = 0 AND m_status=2)	
			--自动加签名意见
			EXECUTE sp_auto_addsign_tosearch @office_missive_id
		END	

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


退出信息
Declare @MsgLangID Int
Select @MsgLangID = msglangid From sys.syslanguages  Where name = @@LANGUAGE  
Begin
	Set @RetVal = 0
	--单据不存在
	Select [text] From sys.messages Where message_id = 50001 And language_id = @MsgLangID
	Set Language @Lang 
	Return 
END

数据库语言选择
Set NoCount On 
Declare @Lang Varchar(30) --暂存原语种
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
		
		*删除模板表*/
declare @template_name varchar(50)
 
declare cur_missive_delete  cursor for 
 select [name] from sysobjects where xtype='U' and [name] like 'office_missive_template_%'
   OPEN cur_missive_delete  
   FETCH NEXT FROM cur_missive_delete  INTO @template_name 

 
   WHILE @@FETCH_STATUS = 0
   BEGIN      
     exec('delete from '+@template_name +' from #A where '+@template_name +'.sys_work_id=#A.office_missive_id')
    --print ('delete from '+@template_name +' from #A where '+@template_name +'.sys_work_id=#A.office_missive_id')
    FETCH NEXT FROM cur_missive_delete  INTO  @template_name 
   
   END

   CLOSE cur_missive_delete  
   DEALLOCATE cur_missive_delete
drop table #A


 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
	
用于控制条件分支，选择的方法

@@ERROR
错误跳转，多在事务中，没错误就继续往下执行，有错误就跳转到错误判断语句，回滚或提交
	SET @ERROR = 0
	执行一条语句
	SET @ERROR = @@ERROR
		IF(@ERROR <> 0)
		GOTO ERROR
		
		--跳转点
	ERROR:
		IF(@ERROR <> 0)
		BEGIN
			ROLLBACK TRANSACTION
			INSERT INTO nn_sys_returnerp_log([office_missive_id]
		  ,[type]
		  ,[log_datetime]
		  ,[desc])
			VALUES(@office_missive_id,2,getdate(),Convert(varchar(30),@ERROR)+'移转到办结表出错!');
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			/*只有办结的单才自动加签名，中止的单不应该增加自动签名?*/	
			IF EXISTS(SELECT 0 FROM office_missive_search WHERE office_missive_id =	@office_missive_id 
AND m_isback = 0 AND m_status=2)	
			--自动加签名意见
			EXECUTE sp_auto_addsign_tosearch @office_missive_id
		END	
		
	--================================	
		
		*删除模板表*/
declare @template_name varchar(50)
 
declare cur_missive_delete  cursor for 
 select [name] from sysobjects where xtype='U' and [name] like 'office_missive_template_%'
   OPEN cur_missive_delete  
   FETCH NEXT FROM cur_missive_delete  INTO @template_name 

 
   WHILE @@FETCH_STATUS = 0
   BEGIN      
     exec('delete from '+@template_name +' from #A where '+@template_name +'.sys_work_id=#A.office_missive_id')
    --print ('delete from '+@template_name +' from #A where '+@template_name +'.sys_work_id=#A.office_missive_id')
    FETCH NEXT FROM cur_missive_delete  INTO  @template_name 
   
   END

   CLOSE cur_missive_delete  
   DEALLOCATE cur_missive_delete
drop table #A

