
/*
����ָ�����ݷָ����ָ����ַ����У���ȡ��N���������ֵ��
*/
CREATE FUNCTION dbo.f_GetStr(
	@s varchar(8000),      --���������������ַ���
	@pos int,             --Ҫ��ȡ���������λ��
	@split varchar(10)     --���ݷָ���
)RETURNS varchar(100)
AS
BEGIN
	IF @s IS NULL 
		RETURN(NULL)
	DECLARE
		@splitlen int
	SELECT
		@splitlen = LEN(@split + ' a') - 2
	WHILE @pos > 1 AND CHARINDEX(@split, @s + @split) > 0
		SELECT
			@pos = @pos - 1,
			@s = STUFF(@s, 1, CHARINDEX(@split, @s + @split) + @splitlen, '')
	RETURN(ISNULL(LEFT(@s, CHARINDEX(@split, @s + @split) - 1), ''))
END
GO
