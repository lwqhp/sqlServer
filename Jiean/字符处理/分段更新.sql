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

select dbo.f_SetStr('abc,123,eft',1,'def',',')

declare @split varchar(10) =', '
declare @pos int =2
declare @s varchar(500)='abc, 123, eft'
declare @value varchar(50)='def'
	DECLARE
		@splitlen int,
		@p1 int,--��ʼ��
		@p2 int --������

-- ͨ��ѭ����������λ��Ҫ�����ݵĿ�ʼ�ͽ����㣬������滻�������

set @splitlen = len(@split+' a')-2
--set @splitlen = len(@split)
set @p1 =1
set @p2 =charindex(@split,@s+@split,1)
while @pos>1  
begin 
	set @pos = @pos-1
	set @p1 = @p2+@splitlen
	set @p2 = charindex(@split,@s+@split,@p1)
	select @splitlen,@p1,@p2
end

select @p1,@p2
select stuff(@s,@p1,@p2-@p1,@value)