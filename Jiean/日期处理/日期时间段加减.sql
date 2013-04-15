if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_DateADD]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[f_DateADD]
GO

/*--�������ڼӼ�����

	��������ָ�����ֵļӼ���ʹ��DATEADD�����Ϳ�������ʵ�֡�
	��ʵ�ʵĴ����У�����һ�ֱȽ���������ڼӼ�����
	������ָ���������У����ϣ����߼�ȥ��������ڲ���
	���罫2005��3��11�գ�����1��3����11��2Сʱ��
	�����������ڵļӼ�����DATEADD�������������Ե��е㲻����

	������ʵ��������ʽ�������ַ����Ӽ�����
	y-m-d h:m:s.m | -y-m-d h:m:s.m
	˵����
	y-��,m-��,d-�� h-Сʱ,m-����,s-��,m-����
	Ҫ�Ӽ��������ַ����뷽ʽ�������ַ�����ͬ��������ʱ�䲿���ÿո�ָ�
	��ǰ��һ���ַ�����Ǽ��ţ�-���Ļ�����ʾ�����������������ӷ�����
	��������ַ�ֻ�������֣�����Ϊ�����ַ��У������������Ϣ��
--*/

/*--����ʾ��

	SELECT dbo.f_DateADD(GETDATE(),'11:10')
--*/
CREATE FUNCTION dbo.f_DateADD(
	@Date	datetime,      -- ����
	@DateStr varchar(23)   -- �� @Date ������Ҫ���ӻ��߼��ٵĶಿ�������ַ���
                           -- Ҫ��ĸ�ʽ: y-m-d h:m:s.m | -y-m-d h:m:s.m
)RETURNS datetime
AS
BEGIN
	DECLARE
		@bz int,
		@temp_str varchar(12),
		@pos int

	-- �жϲ����Ƿ����Ҫ��
	IF @DateStr IS NULL 
			OR @Date IS NULL 
			OR(
				CHARINDEX('.', @DateStr) > 0 AND @DateStr NOT LIKE '%[:]%[:]%.%')
		RETURN(NULL)

	IF @DateStr = ''
		RETURN(@Date)

	SELECT 
		@DateStr = LTRIM(RTRIM(@DateStr)),  -- ȥ����β�ո�
		@bz = CASE                          -- ���üӼ���־
				WHEN LEFT(@DateStr,1) = '-' THEN - 1
				ELSE 1 
			END,
		@DateStr = CASE                      -- ȥ�������ַ����еļӼ���־λ
				WHEN @DateStr LIKE '[+-]%' THEN STUFF(@DateStr, 1, 1, '')
				ELSE @DateStr
			END

	-- �������ڲ��ֵļ�(���߼�)
	IF PATINDEX('%[- ]%', @DateStr) > 1
		OR PATINDEX('%[.:]%', @DateStr) = 0
	BEGIN
		SELECT
			@pos = CHARINDEX(' ', @DateStr + ' '),
			-- ȡ���ڲ���, ��ת��Ϊ�Ĳ��ֶ������Ƹ�ʽ, �Ա�ʹ�� PARSENAME ȡ�ø�����ֵ
			@temp_str = REPLACE(LEFT(@DateStr, @pos - 1), '-', '.'),
			@DateStr = STUFF(@DateStr, 1, @pos, ''),
			-- �����ڲ���: ��-��-��
			@Date = DATEADD(Day, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 1)), 0), @Date),
			@Date = DATEADD(Month, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 2)), 0), @Date),
			@Date = DATEADD(Year, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 3)), 0), @Date)
	END

	-- ����ʱ�䲿�ֵļ�(���߼�)
	IF @DateStr > ''
	BEGIN
		SELECT
			-- ��ʱ�䲿��ת��Ϊ�Ĳ��ֶ������Ƹ�ʽ, �Ա�ʹ�� PARSENAME ȡ�ø�����ֵ
			@temp_str = REPLACE(@DateStr, ':', '.'),
			-- ��ʱ�䲿��: ����-��-����-Сʱ
			@Date = DATEADD(Millisecond, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 1)), 0), @Date),
			@Date = DATEADD(Second, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 2)), 0), @Date),
			@Date = DATEADD(Minute, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 3)), 0), @Date),
			@Date = DATEADD(Hour, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 4)), 0), @Date)
	END

	RETURN(@Date)
END
GO
