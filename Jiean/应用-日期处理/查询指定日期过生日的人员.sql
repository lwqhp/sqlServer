
/*
��ѯ����
1,�Ƿ����Σ�����п��꣬��ֶΣ��Ȳ�ѯ��ʼ���ڵ�12-31��ֹ�ģ���һ����1-1���𣬵���������
2,2�·�29��ֻ��������ڣ�ƽ��ʱ��һ����Ϊ28�����գ�����������ķ����ǰѳ��������л�����ѯ��ֹ�ռ�����ڵ���ݡ�dateadd(year,1,'20080929')�����2009-2-28
*/

--��������
DECLARE @t TABLE(
	ID int,Name varchar(10),
	Birthday datetime)
INSERT @t SELECT 1,'aa','1999-01-01'
UNION ALL SELECT 2,'bb','1996-02-29'
UNION ALL SELECT 3,'bb','1934-03-01'
UNION ALL SELECT 4,'bb','1966-04-01'
UNION ALL SELECT 5,'bb','1997-05-01'
UNION ALL SELECT 6,'bb','1922-11-21'
UNION ALL SELECT 7,'bb','1989-12-11'

--��ѯ 2003-12-05 �� 2004-02-28 ���յļ�¼
DECLARE 
	@date_start datetime,
	@date_stop datetime
SELECT 
	@date_start = '2003-12-05',
	@date_stop = '2004-02-28'

SELECT * FROM @t
WHERE DATEADD(Year, DATEDIFF(Year, Birthday, @date_start), Birthday)--��������ݵ���ָ����ʼ���ڵ����
		BETWEEN @date_start 
				AND CASE 
						WHEN DATEDIFF(Year, @date_start, @date_stop) = 0 THEN @date_stop--������
						ELSE DATEADD(Year, DATEDIFF(Year, '19001231', @date_start), '19001231')--����
					END
	OR DATEADD(Year, DATEDIFF(Year, Birthday, @date_stop), Birthday)--��������ݵ���ָ���������ڵ����[����]
		BETWEEN CASE 
					WHEN DATEDIFF(Year, @date_start, @date_stop) = 0 THEN @date_start
					ELSE DATEADD(Year, DATEDIFF(Year, '19000101', @date_stop), '19000101')
				END
			AND @date_stop


/*--���
ID         Name       Birthday
---------------- ---------------- --------------------------
1           aa         1999-01-01 00:00:00.000
7           bb         1989-12-11 00:00:00.000
--*/

SELECT @dt1 ='2003-12-05',@dt2 ='2004-02-28'
SELECT * FROM @t
WHERE dateadd(year,datediff(year,birthday,@dt1),birthday)
	BETWEEN @dt1 AND @dt2
OR dateadd(year,datediff(year,birthday,@dt2),birthday)
	BETWEEN @dt1 AND @dt2