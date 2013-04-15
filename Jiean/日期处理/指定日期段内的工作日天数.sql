/*
���ȼ��㿪ʼ������������������������������������7��õ��������ٳ���5,�͵õ�ָ��ʱ�������ܵĹ���������Ȼ�����������ڵĹ���������
*/

CREATE FUNCTION dbo.f_WorkDay(
	@date_begin datetime,  --����Ŀ�ʼ����
	@date_end  datetime    --����Ľ�������
)RETURNS int
AS
BEGIN
	DECLARE 
		@weeks int,
		@workday int

	-- �������ܵĹ�������
	SELECT
		-- ����Ŀ�ʼ�ͽ�������֮�������(������)
		@weeks = (DATEDIFF(Day, @date_begin, @date_end) + 1) / 7,
		-- ���ܵĹ�������
		@workday = @weeks * 5,
		-- ���һ���������ܵĿ�ʼ����
		@date_begin = DATEADD(Day, @weeks * 7, @date_begin)

	-- �������һ���������ܵĹ�������
	WHILE @date_begin <= @date_end
	BEGIN
		SELECT 
			@workday = CASE 
						WHEN (@@DATEFIRST + DATEPART(Weekday, @date_begin) - 1) % 7 BETWEEN 1 AND 5
							THEN @workday + 1 
						ELSE @workday 
					END,
			@date_begin = @date_begin + 1
	END
	RETURN(@workday)
END
GO


/*-----�нڼ��ձ�Ĵ�����-----------*/
--ʹ��ָ��ʱ����ڵ���������ȥָ��ʱ����ڣ��ڼ��ձ��еļ�¼������
create table dbo.tb_Holiday(
	HDate	smalldatetime	--�ڼ�����
		PRIMARY key,
	Name	nvarchar(50)	not null	--�ڼ�����
)

create function dbo.f_workDay(
	@date_begin datetime,	--����Ŀ�ʼ����
	@date_end	datetime	--����Ľ�������
)returns int 
as
begin 
	return(
	datediff(day,@date_begin,@date_end)+1
	-(
	select count(*) from dbo.tb_holiday
	where Hdate between @date_begin and @date_end)	
)	
end
Go


