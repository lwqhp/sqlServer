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



/*
-------���ڼӼ�����----------------------------------------------------------------------
����dateadd�������㡣
������ָ�������У����ϻ��ȥ������ڲ��֡�
˼·������Ҫ�ľ��ǰ�Ҫ�Ӽ��������ַ��ֽ⣬Ȼ����ݷֽ�Ľ����ָ�����ڵĶ�Ӧ���ڲ��ּ�����Ӧ��ֵ��
�ȶ����ʽ��y-m-d h:m:s.m | -y-m-d h:m:m.m
Ҫ�Ӽ��������ַ����뷽ʽ�������ַ�����ͬ��������ʱ�䲿���ÿո�ָ�����ǰ���һ�ַ�����Ǽ��ŵĻ���
��ʾ�����������������ӷ�������������ַ�ֻ�������֣�����Ϊ�����ַ��У������������Ϣ��

ȷ���������ַ���ʽ�󣬴������Ϳ�������ȷ������ȡ�����ַ��ĵ�һ���ַ����жϴ���ʽ��
Ȼ��Ҫ�Ӽ��������ַ����ո����Ϊ���ں�ʱ�������֣��������ڲ��ִӵ�λ����λ������ȡ�������ݽ��д���
����ʱ��Ӹ�λ����λ��������.
*/

/*
��ʽ��y-m-d h:m:s.m | -y-m-d h:m:m.m
����Ĭ�����죬ʱ��Ĭ����Сʱ���ո�ָ����ں�ʱ��
*/
CREATE FUNCTION dbo.f_DateADD(
@Date     datetime,
@DateStr   varchar(23)
)RETURNS datetime
AS
BEGIN
 DECLARE @bz int,@s varchar(12),@i int
 IF @DateStr IS NULL OR @Date IS NULL
  OR(CHARINDEX('.',@DateStr)>0
   AND @DateStr NOT LIKE '%[:]%[:]%.%')
   
  RETURN(NULL)
 IF @DateStr='' RETURN(@Date)
 --�жϼӼ�,��ʽ���ַ���
 SELECT @bz=CASE
   WHEN LEFT(@DateStr,1)='-' THEN -1
   ELSE 1 END,
  @DateStr=CASE
   WHEN LEFT(@Date,1)='-'
   THEN STUFF(RTRIM(LTRIM(@DateStr)),1,1,'')
   ELSE RTRIM(LTRIM(@DateStr)) END
   --�����ڲ���
 IF CHARINDEX(' ',@DateStr)>1
  OR CHARINDEX('-',@DateStr)>1
  OR(CHARINDEX('.',@DateStr)=0
   AND CHARINDEX(':',@DateStr)=0)
 BEGIN
  SELECT @i=CHARINDEX(' ',@DateStr+' ')
   ,@s=REVERSE(LEFT(@DateStr,@i-1))+'-'
   ,@DateStr=STUFF(@DateStr,1,@i,'')
   ,@i=0
  WHILE @s>'' and @i<3
   SELECT @Date=CASE @i
     WHEN 0 THEN DATEADD(Day,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
     WHEN 1 THEN DATEADD(Month,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
     WHEN 2 THEN DATEADD(Year,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
    END,
    @s=STUFF(@s,1,CHARINDEX('-',@s),''),
    @i=@i+1   
 END
 --��ʱ�䲿��
 IF @DateStr>''
 BEGIN
  IF CHARINDEX('.',@DateStr)>0
   SELECT @Date=DATEADD(Millisecond
     ,@bz*STUFF(@DateStr,1,CHARINDEX('.',@DateStr),''),
     @Date),
    @DateStr=LEFT(@DateStr,CHARINDEX('.',@DateStr)-1)+':',
    @i=0
  ELSE
   SELECT @DateStr=@DateStr+':',@i=0
  WHILE @DateStr>'' and @i<3
   SELECT @Date=CASE @i
     WHEN 0 THEN DATEADD(Hour,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
     WHEN 1 THEN DATEADD(Minute,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
     WHEN 2 THEN DATEADD(Second,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
    END,
    @DateStr=STUFF(@DateStr,1,CHARINDEX(':',@DateStr),''),
    @i=@i+1
 END
 RETURN(@Date)
END
GO

