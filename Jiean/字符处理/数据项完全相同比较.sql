
/*
�Ƚ�ʹ����ͬ���ݷָ����������ַ����У����ǰ������������Ƿ���ȫ��ͬ�����������λ�ÿ��Բ�ͬ��
*/

CREATE FUNCTION dbo.f_CompareSTR(
	@s1  varchar(8000),  --Ҫ�Ƚϵĵ�һ���ַ���
	@s2  varchar(8000),  --Ҫ�Ƚϵĵڶ����ַ���
	@split varchar(10)    --���ݷָ���
)RETURNS bit
AS
BEGIN
	IF LEN(@s1) <> LEN(@s2)  -- ���Ȳ�һ�µĲ��ñȽ�������
		RETURN(0)

	DECLARE
		@splitlen int
	SET @splitlen = LEN(@split + 'a') - 2

	-- �ֲ����Ƚϵĵ�һ���ַ���
	DECLARE @r1 TABLE(
		col varchar(100))
	WHILE CHARINDEX(@split, @s1) > 0
	BEGIN
		INSERT @r1 VALUES(LEFT(@s1, CHARINDEX(@split, @s1) - 1))
		SET @s1 = STUFF(@s1, 1, CHARINDEX(@split, @s1) + @splitlen, '')
	END
	INSERT @r1 VALUES(@s1)

	-- �ֲ����Ƚϵĵڶ����ַ���
	DECLARE @r2 TABLE(
		col varchar(100))
	WHILE CHARINDEX(@split, @s2) > 0
	BEGIN
		INSERT @r2 VALUES(LEFT(@s2, CHARINDEX(@split, @s2) - 1))
		SET @s2 = STUFF(@s2, 1, CHARINDEX(@split, @s2) + @splitlen, '')
	END
	INSERT @r2 VALUES(@s2)

	-- JOIN �ֲ��ı�, �Ӷ��ж��Ƿ���ڲ�ƥ���������
	RETURN(
		CASE
			WHEN EXISTS(
					SELECT * 
					FROM @r1 A 
						FULL JOIN @r2 B 
							ON A.col = B.col 
					WHERE A.col IS NULL 
						OR B.col IS NULL)
				THEN 0
			ELSE 1 
		END)
END
GO
