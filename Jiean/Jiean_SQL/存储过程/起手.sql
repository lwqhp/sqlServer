

/*
����
*/

--�洢���̶���,����

CREATE PROC AB
	@var VARCHAR(100)	--����
	@var1 varchar(Max)	--����2
AS 

--�ж�,��ʼ������ֵ

IF ISNULL(@var,'') =''
	SET @var = '��ʼֵ'
	
--2
if IsNull(@CardTypeID,'') <> ''
	begin
		insert into #CardTypeList(CardTypeID) Select * From dbo.fnSys_SplitString(@CardTypeID,',')
	end
	else
		set @CardTypeID =Null; 
		
--3
IF @objectId IS NULL -- �ж϶����Ƿ����
    BEGIN
        PRINT 'The object not exists'
        RETURN
    END		