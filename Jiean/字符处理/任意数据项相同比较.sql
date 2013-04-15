
/*
�Ƚ�ʹ����ͬ���ݷָ����������ַ����У����ǰ������������Ƿ�������һ����ͬ�����������λ�ÿ��Բ�ͬ��
*/
CREATE FUNCTION dbo.f_CompareSTR(
	@s1  varchar(8000),  --Ҫ�Ƚϵĵ�һ���ַ���
	@s2  varchar(8000),  --Ҫ�Ƚϵĵڶ����ַ���
	@split varchar(10)    --���ݷָ���
)RETURNS bit
AS
BEGIN
	DECLARE
		@splitlen int
	SET @splitlen = LEN(@split + 'a') - 2

	-- �ֲ����Ƚϵĵ�һ���ַ���
	WHILE CHARINDEX(@split, @s1) > 0
	BEGIN
		-- �������Ƚϵĵ�һ���ַ����е��������ڵڶ����ַ����д���, ��ֱ�ӷ���
		IF CHARINDEX(
					@split + LEFT(@s1, CHARINDEX(@split, @s1) - 1) + @split,
					@split + @s2 + @split
				) > 0
			RETURN(1)
		SET @s1 = STUFF(@s1, 1, CHARINDEX(@split, @s1) + @splitlen, '')
	END
	RETURN(
		CASE
			WHEN CHARINDEX(@split + @s1 + @split, @split + @s2 + @split) > 0
				THEN 1
			ELSE 0
		END)
END
GO
