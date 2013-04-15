-- �����ַ�����ָ��λ�õ�������
CREATE FUNCTION dbo.f_SetStr(
	@s varchar(8000),      --������������ַ���
	@pos int,                --Ҫ���µ�������Ķ�
	@value varchar(100),   --���º��ֵ
	@split varchar(10)     --���ݷָ���
)RETURNS varchar(8000)
AS
BEGIN
	DECLARE
		@splitlen int,
		@p1 int,
		@p2 int
	SELECT
		@splitlen = LEN(@split + 'a') - 2,
		@p1 = 1,
		@p2 = CHARINDEX(@split, @s + @split) -- ��һ���ָ�����λ��
	WHILE @pos > 1 AND @p1 <= @p2            -- ѭ��ֱ���� @pos ��������, �������Ҳ����µķָ���
		SELECT
			@pos = @pos - 1,
			@p1 = @p2 + @splitlen + 1,
			@p2 = CHARINDEX(@split, @s + @split, @p1)
	RETURN(
		CASE
			-- ����ҵ�ָ��λ�õ�������, �����
			WHEN @p1 <= @p2 THEN STUFF(@s, @p1, @p2 - @p1, @value)
			ELSE @s
		END
	)
END
GO
