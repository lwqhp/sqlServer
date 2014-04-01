

/*
起手
*/

--存储过程定义,参数

CREATE PROC AB
	@var VARCHAR(100)	--参数
	@var1 varchar(Max)	--参数2
AS 

--判断,初始化参数值

IF ISNULL(@var,'') =''
	SET @var = '初始值'
	
--2
if IsNull(@CardTypeID,'') <> ''
	begin
		insert into #CardTypeList(CardTypeID) Select * From dbo.fnSys_SplitString(@CardTypeID,',')
	end
	else
		set @CardTypeID =Null; 
		
--3
IF @objectId IS NULL -- 判断对象是否存在
    BEGIN
        PRINT 'The object not exists'
        RETURN
    END		