
/*
���洦��û�п��ǹ���ʱ�䶨����ж����ʱ���������ڿ�������
��������
	���õ�������ʱ���ķ������������������ʱ���ȥ7.5Сʱ����ʱ�������һ��֮�ڣ�
	�ڼ��㹤��ʱ��ʱ�����������ʼʱ��Ҳ��ȥ7.5Сʱ���������ڹ���ʱ��ļ����ϾͲ��������⴦���ˡ�
*/

-- ����ʱ�����ñ�
CREATE TABLE dbo.tb_worktime(
	ID int IDENTITY
		PRIMARY KEY,
	time_start smalldatetime,  --�����Ŀ�ʼʱ��
	time_end smalldatetime,   --�����Ľ���ʱ��
	worktime AS DATEDIFF(Minute,time_start,time_end) --����ʱ��(����)
)
INSERT dbo.tb_worktime(
	time_start,time_end)
SELECT '1900-1-1 00:30','1900-1-1 07:00' UNION ALL
SELECT '1900-1-1 08:30','1900-1-1 17:30' UNION ALL
SELECT '1900-1-2 18:00','1900-1-2 23:30'
GO

-- ���ݹ���ʱ�����ñ�, ����ָ��ʱ����ڵĹ���ʱ��
CREATE FUNCTION dbo.f_WorkTime(
	@date_begin datetime,  --����Ŀ�ʼʱ��
	@date_end datetime     --����Ľ���ʱ��
)RETURNS int
AS
BEGIN
	DECLARE
		@worktime int,
		@time_begin smalldatetime,
		@time_end smalldatetime

	-- ��ʼ�ͽ���ʱ���ʱ�䲿��
	SELECT
		@time_begin = CONVERT(VARCHAR, @date_begin, 108),
		@time_end = CONVERT(VARCHAR, @date_end, 108)
	
	-- ������Ĺ���ʱ�����
	IF DATEDIFF(Day, @date_begin, @date_end) = 0
		SELECT 
			@worktime = SUM(
					DATEDIFF(Minute,
						-- ÿ��ʱ��εĿ�ʼʱ��
						CASE 
							WHEN @time_begin > time_start THEN @time_begin
							ELSE time_start 
						END,
						-- ÿ��ʱ��εĽ���ʱ��
						CASE 
							WHEN @time_end < time_end THEN @time_end
							ELSE time_end
						END
					))
		FROM dbo.tb_worktime 
		WHERE time_end > @time_begin
			AND time_start < @time_end
	ELSE
		SELECT
			@worktime = 
				(   -- ��ʼʱ��(��һ��)
					SELECT 
						SUM(CASE
								WHEN time_start > @time_begin THEN worktime
								ELSE DATEDIFF(Minute, @time_begin, time_end)
							END)
					FROM dbo.tb_worktime 
					WHERE time_end > @time_begin
				)
				+ ( -- ����ʱ��(���һ��)
					SELECT
						SUM(CASE
								WHEN time_end < @time_end THEN worktime
								ELSE DATEDIFF(Minute, time_start, @time_end)
							END)
					FROM dbo.tb_worktime 
					WHERE time_start < @time_end
				)				
			+ (  -- ����
				(DATEDIFF(Day, @date_begin, @date_end) - 1)
				* ( SELECT SUM(worktime) FROM dbo.tb_worktime)
				)

	RETURN(@worktime)
END
GO
