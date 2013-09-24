

--业务分支--------------------------------------------
/*
在业务逻辑处理中，通常分块实现业务功能，块级之间的分支断判多用IF条件语句判断
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
各语句块之间的承接
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
WHILE @var IS NOT NULL 
BEGIN
	赋值区别：SELECT 和 set ：如果没有记录，SELECT 中的变量赋值语句是不执行，还是原来的值，SET，则会返回null值给变量
	
	关键点：开始前，先给@var赋一个值，以判断是否要进入循环
		
	执行完后，重新取值给@var，否则会死循环
END 