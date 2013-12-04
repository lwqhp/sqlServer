--��������
CREATE TABLE tb(
	ID1 char(2) NOT NULL,
	ID2 char(4) NOT NULL,
	col int,
	PRIMARY KEY(
		ID1, ID2))
INSERT tb SELECT 'aa', '0001', 1
UNION ALL SELECT 'aa', '0003', 2
UNION ALL SELECT 'aa', '0004', 3
UNION ALL SELECT 'bb', '0005', 4
UNION ALL SELECT 'bb', '0006', 5
UNION ALL SELECT 'cc', '0007', 6
UNION ALL SELECT 'cc', '0009', 7
GO

--���ű�Ŵ���
DECLARE
	@ID1 char(2),
	@ID2 int
UPDATE tb SET
	@ID2 = CASE
				-- �����ǰ��ID1 ֵ����һ����ͬ, ����+ 1, �����ʼΪ1
				WHEN @ID1 = ID1 THEN @ID2 + 1
				ELSE 10001
			END,
	@ID1 = ID1,  -- �洢��ǰID1 ��ֵ, �Ա��ڴ�����һ����¼ʱ��ü�¼��ID1 ֵ���Ƚ�
	ID2 = RIGHT(@ID2, 4)
SELECT * FROM tb
/*--���
ID1  ID2  col
---- ---- ----------- 
aa   0001 1
aa   0002 2
aa   0003 3
bb   0001 4
bb   0002 5
cc   0001 6
cc   0002 7
--*/
GO

-- ɾ����������
DROP TABLE tb