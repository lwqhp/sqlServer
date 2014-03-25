
/*
���ݰ���������з���ķ�ҳ
*/
-- Ҫ��ҳ��ԭʼ����
--drop table tb
CREATE TABLE tb(
	ID    int			-- ��¼���
		PRIMARY KEY, 
	grade  varchar(10),	-- �������
	uptime datetime		-- ����ʱ��
)
INSERT tb SELECT 1 , 'a', '2004-12-11'
UNION ALL SELECT 2 , 'b', '2004-12-11'
UNION ALL SELECT 3 , 'c', '2004-12-11'
UNION ALL SELECT 4 , 'a', '2004-12-12'
UNION ALL SELECT 5 , 'c', '2004-12-13'
UNION ALL SELECT 6 , 'c', '2004-12-13'
UNION ALL SELECT 7 , 'a', '2004-12-14'
UNION ALL SELECT 8 , 'a', '2004-12-15'
UNION ALL SELECT 9 , 'b', '2004-12-16'
UNION ALL SELECT 10, 'b', '2004-12-17'
UNION ALL SELECT 11, 'a', '2004-12-17'

--select * from tb
-- ��ҳ�����
CREATE TABLE tb_Page(
	grade   varchar(10)	-- �������,��tb���grade����
		PRIMARY KEY,
	Records int,		-- ÿҳ��ʾ�ļ�¼��
	Orders  int			-- ��ҳ�е���ʾ˳��
)
INSERT tb_Page SELECT 'c', 2, 1
UNION  ALL     SELECT 'b', 1, 2
UNION  ALL     SELECT 'a', 2, 3
GO

--select * from tb_Page
-- ʵ�ַ�ҳ����Ĵ洢����
CREATE PROC dbo.spVP_PageView(
	@PageCurrent int = 1  --Ҫ��ʾ�ĵ�ǰҳ��
)
AS
SET NOCOUNT ON

-- �õ�ÿҳ��Ҫ��ʾ�ļ�¼��
DECLARE	@PageSize int
SELECT @PageSize = SUM(Records) FROM tb_Page

IF ISNULL(@PageSize, 0) < 0
	RETURN

-- ��ҳ��ʾ����
DECLARE	@Rows int
-- ��ȡ��ֹ��ǰҳ�ļ�¼��
SET @Rows = @PageCurrent * @PageSize
SET ROWCOUNT @Rows
-- ��ȡ��ֹ��ǰҳ����������
SELECT SID = IDENTITY(int, 1, 1),ID 
INTO #
FROM(SELECT TOP 100 PERCENT	A.ID 
	FROM tb A
	LEFT JOIN tb_Page B	ON A.grade = B.grade
	ORDER BY CASE WHEN B.grade IS NULL THEN 1 ELSE 0 END, -- ���ڷ�ҳ������еķ������
		((  -- ���� uptime �Ӵ�С���ɵ�ǰ��¼�����
			SELECT COUNT(*) FROM tb 
			WHERE grade = A.grade 
				AND (uptime > A.uptime OR uptime = A.uptime AND id >= A.id)
		) - 1) / B.Records, -- ��� tb_Page ���㵱ǰ��¼Ӧ������һҳ��ʾ, ���ݴ�����
		B.Orders,					-- ���� tb_Page ����� Orders ˳����ʾ
		A.uptime DESC, A.ID DESC	-- ͬһ grade �ļ�¼���� uptime �� id ������ʾ
)A
SET ROWCOUNT 0
-- ɾ������ʾҳ��������¼
IF @Rows > @PageSize
BEGIN
	SET @Rows = @Rows - @PageSize
	SET ROWCOUNT @Rows
	DELETE FROM #
	SET ROWCOUNT 0
END
SELECT
	A.*
FROM tb A, # B
WHERE A.ID = B.ID
ORDER BY B.SID

drop table #
GO

-- ����
EXEC dbo.spVP_PageView 2
/*--���
ID          grade      uptime                                                 
----------- ---------- ---------------------------
3           c          2004-12-11 00:00:00.000
9           b          2004-12-16 00:00:00.000
7           a          2004-12-14 00:00:00.000
4           a          2004-12-12 00:00:00.000
2           b          2004-12-11 00:00:00.000
--*/
GO

-- ɾ�����Ի���
DROP TABLE tb, tb_Page
DROP PROC dbo.p_PageView