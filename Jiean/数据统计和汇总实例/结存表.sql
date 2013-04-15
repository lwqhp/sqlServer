-- ����
CREATE TABLE Stocks(
	Item varchar(10),
	YearMonth int,
	Quantity int)
INSERT Stocks SELECT 'aa', 200501, 100
UNION  ALL    SELECT 'cc', 200501, 100

-- ��ϸ������
CREATE TABLE tb(
	ID int IDENTITY
		PRIMARY KEY,
	Item varchar(10),  -- ��Ʒ���
	Quantity int,      -- ��������
	Flag bit,          -- ���ױ�־, 1 �������, 0 �������,����������Ч�����˻�(����)
	Date datetime)     -- ��������
INSERT tb SELECT 'aa', 100, 1, '2005-1-1'
UNION ALL SELECT 'aa', 90 , 1, '2005-2-1'
UNION ALL SELECT 'aa', 55 , 0, '2005-2-1'
UNION ALL SELECT 'aa', -10, 1, '2005-2-2'
UNION ALL SELECT 'aa', -5 , 0, '2005-2-3'
UNION ALL SELECT 'aa', 200, 1, '2005-2-2'
UNION ALL SELECT 'aa', 90 , 1, '2005-2-1'
UNION ALL SELECT 'bb', 95 , 1, '2005-2-2'
UNION ALL SELECT 'bb', 65 , 0, '2005-2-3'
UNION ALL SELECT 'bb', -15, 1, '2005-2-5'
UNION ALL SELECT 'bb', -20, 0, '2005-2-5'
UNION ALL SELECT 'bb', 100, 1, '2005-2-7'
UNION ALL SELECT 'cc', 100, 1, '2005-1-7'
GO

-- ��ѯʱ��ζ���
DECLARE
	@date_start datetime,
	@date_stop datetime
SELECT
	@date_start = '2005-2-1',
	@date_stop = '2005-2-10'

-- ��ѯ
-- a. �ڳ�������¼������ڳ����Ŀ�ʼʱ��)
DECLARE
	@YearMonth int,
	@date datetime
SELECT
	@YearMonth = CONVERT(CHAR(6),DATEADD(Month, - 1, @date_start), 112),
	@date = DATEADD(Day, 1 - Day(@date_start), @date_start)

-- b. �����ѯ
SELECT
	��Ʒ = ISNULL(A.Item, B.Item),
	���� = ISNULL(B.Date, CONVERT(char(10), @date_start, 120)),
	�ڳ��� = ISNULL(A.Quantity, 0) + ISNULL(B.Init, 0),
	������� = ISNULL(B.[IN], 0),
	��������˻� = ISNULL(B.[IN_Retrun], 0),
	���ڳ��� = ISNULL(B.[OUT], 0),
	���ڳ����˻� = ISNULL(B.[OUT_Return], 0),
	��ĩ�� = ISNULL(A.Quantity, 0) + ISNULL(B.Init, 0) + ISNULL(B.Finish, 0)
FROM(
	--�ڳ���
	SELECT
		Item, Quantity
	FROM Stocks
	WHERE YearMonth = @YearMonth
)A
	FULL JOIN(
		-- a. ��ͳ��ʱ������޷����������(���������ǲ�ѯ��Ҫ��,ȥ����β�ѯ)
		SELECT
			Item,
			Date = CONVERT(char(10), @date_start, 120),	
			Init = SUM(
						CASE
							WHEN Flag = 1 THEN Quantity
							ELSE - Quantity
						END),
			[IN] = 0,
			[IN_Retrun] = 0,
			[OUT] = 0,
			[OUT_Return] = 0,
			Finish = SUM(
						CASE
							WHEN Flag = 1 THEN Quantity
							ELSE - Quantity
						END)
		FROM tb A
		WHERE Date >= @date         -- ��ͳ���ڽ��ʱ��֮��, ͳ�ƿ�ʼʱ��֮ǰ�ļ�¼
			AND Date < @date_start 
			AND NOT EXISTS(
					-- ��������ͳ��ʱ����ڲ����ڵ� Item
					SELECT * FROM tb
					WHERE Item = A.Item
						AND Date > @date_start
						AND Date < DATEADD(Day, 1, @date_stop))
		GROUP BY Item
		UNION ALL
		-- b. ָ��ʱ������н��׷���������
		SELECT
			Item = Item,
			Date = CONVERT(char(10), Date, 120),	
			Init = ISNULL((
						-- �ڳ���ΪС�ڵ�ǰͳ�Ƽ�¼ʱ��������뵱ǰ��¼ Item ��ͬ�ļ�¼�����֮�� - ����֮��
						SELECT
							SUM(CASE
									WHEN Flag = 1 THEN Quantity
									ELSE - Quantity
							END)
						FROM tb
						WHERE Item = A.Item
							-- ��ͳ���ڽ��ʱ��֮��, ͳ�ƿ�ʼʱ��֮ǰ�ļ�¼
							AND  Date >= @date
							AND Date < MIN(A.Date)
					), 0),
			[IN] = ISNULL(
								SUM(CASE
										WHEN Flag = 0 AND Quantity > 0 THEN Quantity
									END),
								0),
			[IN_Retrun] = ISNULL(
								SUM(CASE
										WHEN Flag = 0 AND Quantity < 0 THEN - Quantity
									END),
								0),
			[OUT] = ISNULL(
								SUM(CASE
										WHEN Flag = 0 AND Quantity > 0 THEN Quantity
									END),
								0),
			[OUT_Return] = ISNULL(
								SUM(CASE
										WHEN Flag = 0 AND Quantity < 0 THEN - Quantity
									END),
								0),
			-- ��������������ͳ�������֮��Ĳ���, ��ʾ���ս��ʱ�ٴ�����ĩ����
			Finish = SUM(CASE
							WHEN Flag = 1 THEN Quantity
							ELSE - Quantity
						END)
		FROM tb A
		WHERE Date >= @date_start
			AND Date < DATEADD(Day, 1, @date_stop)
		GROUP BY Item, CONVERT(char(10), Date,120)
	)B
		ON A.Item = B.Item
ORDER BY ��Ʒ, ����
/*--���
��Ʒ	����		�ڳ���	�������	��������˻�	���ڳ���	���ڳ����˻�	��ĩ��
------- ----------- ------- ----------- --------------- ----------- --------------- ----------
aa		2005-02-01	100		55			0				55			0				225
aa		2005-02-02	225		0			0				0			0				415
aa		2005-02-03	415		0			5				0			5				420
bb		2005-02-02	0		0			0				0			0				95
bb		2005-02-03	95		65			0				65			0				30
bb		2005-02-05	30		0			20				0			20				35
bb		2005-02-07	35		0			0				0			0				135
cc		2005-02-01	100		0			0				0			0				100
--*/
GO

-- ɾ�����Ի���
DROP TABLE tb, Stocks