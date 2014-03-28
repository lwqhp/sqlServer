/*
��ָ���������ȼ������ܵ���������ѭ���������Ĺ�������
--[��ָ���������ȼ������ܵ���������ѭ������ʣ��Ĺ�����������]
/*���Ҫ��������ָ�����������ܵ�����һ��Ĵ���������ͬ������ָ�����������ܵ�����һ���ϸ���
SET DATEFIRST���õ�һ�ܵĵ�һ�������ڼ������㡣���磬����ָ����������һ�ܵĵ�2�죬���SET DATEFIRST 7��
������ĵ�һ��������һ�������SET DATEFIRST 1����ô������Ľ������ڶ���

�����ָ���������ڵ��ܵ����ڼ�������Ľ������SET DATEFIRST���õ�Ӱ�죬������SET DATEFIRST���������
������ָ�����ڵ����ڶ���������Ľ��Ӧ���ǹ̶��ġ�

Ҫ�����ָ�����������ܵ��������ڼ������ȣ�Ҫ��ָ������ת��Ϊָ�����������ܵ�������
������ǰ��й������ڴ���ϰ�ߣ�����ת��Ϊָ�����������ܵ�����һ������SQL Server�У�
û�еõ�ָ������Ϊ���ڼ�������ֵĺ�����Ҫ�õ�ָ������Ϊ���ڼ�������֣�
����ʹ��DATEPART��Weekday,date�����������ϵͳ����@@DATEFIRST����ȡ��
��SET DATEFIRST 1��ʱ�����ڼ���DATEPART��Weekday,Date���õ��Ľ����һ�µģ�
����Ҫ�����������������SET DATEFIRST���õ�Ӱ�죬���Ⱦ�Ҫ��DATEPART��Weekday,date��
�Ľ������ΪSET DATEFIRST 1ʱ��DATEPART��Weekday ,date��ֵ����SET DATEFIRST 2ʱ��DATEPART��Weekday,date��
�����ڶ�������һ�ܵĵ�һ���λ�ã�����һ����������һλ������DATEPART��Weekday,date��
�Ľ���ټ���1�Ϳ��԰�DATEPART��Weekday,date���Ľ������ΪSET DATEFIRST 1ʱ�Ľ����
ͬ��SET DATEFIRST 3ʱ��ֻ��Ҫ��DATEPART��Weekday,date���Ľ������2���Ϳ��԰ѽ������ΪSET DATEFIRST 1ʱ
��DATEPART��Weekday,date��ֵ����ͨ��@@DATEFIRST���Եõ���ǰSET DATEFIRST���õ�ֵ��
����ͨ��DATEADD��Day,DATEPART��Weekday,date)+@@DATEFIRST,date)���������ָ������ǰһ�ܵ����һ�������գ�
Ȼ���ټ���Ҫ�õ������ڼ���������������Ҫ�Ľ����

��������������У���Ҫ����һ�����⣬һ��������7�죬DATEPART��Weekday��date���Ľ��ʼ����1��7��
����SET DATEFIRST n�������ǰ�����n֮ǰ�����������ƣ�������ѭ���ƶ������Ի�Ҫ����λ����
�������ǰ�DATEPART��Weekday,date)+@@DATEFIRST-1�Ľ��MOD 7��������õ���ָ�����ڵ����ڼ�������֡�
*/
*/

CREATE FUNCTION dbo.f_WorkDayADD(
	@date    datetime,  --��������
	@workday int        --Ҫ���ӵĹ�������(���Ϊ����,��ʾ����ָ���Ĺ�������)
)RETURNS datetime
AS
BEGIN
	DECLARE 
		@bz int

	--�������ܵ�����
	SELECT 
		-- ���ӻ��߼��ٹ��������ı�־
		@bz = CASE WHEN @workday < 0 THEN -1 ELSE 1 END,
		-- ����(���߼���)������
		@date=DATEADD(Week, @workday / 5, @date),
		-- ʣ��ķ����ܵĹ�������
		@workday = @workday % 5

	-- ����(���߼��ٲ������ܵĹ�������
	WHILE @workday <> 0 
		SELECT
			@date = DATEADD(Day, @bz, @date),
			@workday = CASE 
						WHEN (@@DATEFIRST + DATEPART(Weekday, @date) - 1) % 7 BETWEEN 1 AND 5
							THEN @workday - @bz
						ELSE @workday 
					END
	--���⴦��������ͣ���ڷǹ�������
	WHILE (@@DATEFIRST+DATEPART(Weekday, @date) - 1) % 7 IN(0, 6) 
		SET @date = DATEADD(Day, @bz, @date)
	RETURN(@date)
END
GO

/*-----�нڼ��ձ�Ĵ�����-----------*/

/*��ָ������Dֱ�Ӽ��Ϲ����������õ�����D1��Ȼ�����D��D1���ʱ���ڵĽڼ�������N��
���N=0����ʾ���ʱ���ڶ��ǹ����գ��ǾͲ���Ҫ�����������N��0����ʾ��������N�������գ�
�Ǿͼ���D1����N�������պ�����ڣ�ѭ����NΪ0*/
create table dbo.tb_Holiday(
	HDate	smalldatetime	--�ڼ�����
		PRIMARY key,
	Name	nvarchar(50)	not null	--�ڼ�����
)

create function dbo.f_workDayADD(
	@date	datetime,	--��������
	@workday int		--Ҫ���ӵĹ�������
)returns datetime
as
begin
	if @workday >0	--����
		while @workday >0
			select 
				@date = @date + @workday,
				@workday = count(*)
			from dbo.tb_Holiday
			where Hdate between @date and @date+@workday
	else
		while @workday <0
			select 
				@date = @date + @workday,
				@workday = -count(*)
			from dbo.tb_Holiday
			where Hdate between @date and @date+@workday
	return(@date)
end


