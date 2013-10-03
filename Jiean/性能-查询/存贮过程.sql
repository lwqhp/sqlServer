
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

