
/*
sql�е�������ѭ����ʽ
*/

--ѭ��һ����
 WHILE CHARINDEX(@split,@s)>0
 --��������һ���Ӱ���������
 WHILE @@ROWCOUNT >0

SET @id = SELECT TOP 1 id FROM #
WHILE (@id IS NOT NULL)
BEGIN
	
	DELETE # FROM id = @id
	SET @id = NULL
	SET @id = SELECT TOP 1 id FROM #
END 

--��������ID�Ƚ���ѭ���������α�

SELECT TOP 1 val FROM tb
WHILE @val IS NOT NULL
BEGIN
	SELECT TOP 1 @id = id,@val = val FROM tb WHERE id>@id ORDER BY id
	
END


--�����ж�

IF EXISTS(@id)
IF @id IS NOT NULL 
BEGIN
	
END
