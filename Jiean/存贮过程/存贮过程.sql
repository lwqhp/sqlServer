
1,创建
CREATE PROCEDURE proName(
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
IF @a>0
BEGIN ...END
ELSE IF @a<0 
BEGIN ...END
ELSE
begin ...END 	

循环语句
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
	DECLARE @RetVal TINYINT  --返回值   
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

