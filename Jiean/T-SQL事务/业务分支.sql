

--业务分支--------------------------------------------
/*
在业务逻辑处理中，通常分块实现业务功能，块级之间的分支断判多用IF条件语句判断

控制语句
 常用的有5种：
 1）return: 这个过程用于无条件退出既有域并将控制权返回给调用域。也能用于把整型值返回给调用者。
 简单的来讲，就是中断执行，强制退出，可以返回指定整型数值，在存储过程中默认返回0,表示执行完成。
 
 2）while : 当条件为true时，执行的循环语句，其中有两个命令结束循环
	break-退出循环，继续往下执行
	continue - 退出本次循环，继续下一次循环。
 
 3）goto: 用于在t-sql批处理中跳到一个标签。它通常用于在发生错误的时候跳转到某个错误处理器，或者跳过某个
 满足或不满足条件的代码，这种写法是“面条式”代码，你为了完全理解这段代码或过程实际在做什么，不得不在代码
 间跳来跳去。
 
 4）waitfor : 可以延迟它后面的后续t-sql命令，可以是一个固定的时间段或是到某个时间。
 
 5）游标： 有编程前景的查询编写者通常更习惯于使用游标，而不是基于集合的方案来获取或更新行，但游标会耗尽sql
 server实例的内存，减少并发性，减少网络带宽，锁定资源，并且经常会需要比基于集合的方案更多的代码

*/

declare @a int 

IF @a >0 
BEGIN 
	print '脚本1'
END
ELSE
	BEGIN
		print '脚本2'
	end	

IF @a>0
BEGIN 
	print '脚本1' 
END
ELSE IF @a<0 
BEGIN 
	print '脚本2'
END
ELSE
begin 
	print '脚本3'
END 	

/*
case运算-------------------------------------------------------------------------------
这个可以在查询字段里作条件判断用
*/

/*
各语句块之间的承接---------------------------------------
*/
--上面的执行控制下面块的选择
DECLARE @id INT=@@ROWCOUNT;
IF @id >0 print '下一步操作'



--中间调用存储过程，返回值
	--返回表
	INSERT INTO #tb
	EXEC spBC_MergeOrder 'A','B'
	
	--返回值和执行状态，控制下面块的选择
	DECLARE @RetVal TINYINT =0 --返回值   
	DECLARE @billno VARCHAR(20) --返回值  单号
	declare @FormLang Varchar(2) = 'CN'
	
	EXEC spBC_MergeOrder @RetVal   Output,   @FormLang , @RetBillNo   Output  
	--判断
	IF @RetVal=0 
	BEGIN 
		print '脚本1'
	END
	ELSE IF @RetVal=-1 
	BEGIN 
		print '脚本2'
	END


--循环语句
WHILE @@ROWCOUNT>0
WHILE @var IS NOT NULL 
BEGIN
	赋值区别：SELECT 和 set ：如果没有记录，SELECT 中的变量赋值语句是不执行，还是原来的值，SET，则会返回null值给变量
	
	关键点：开始前，先给@var赋一个值，以判断是否要进入循环
		
	执行完后，重新取值给@var，否则会死循环
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