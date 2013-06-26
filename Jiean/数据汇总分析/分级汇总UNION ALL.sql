
/*
�ϼ��е�����
����������,s1:�ܼ��У�s2:�����У�s3:С����
s1,s2,s3
0,'A',0
0,'A',1--A�кϼ���
1,'A',0--�����ܼ���

*/
/*
�Ѹ��ӵĻ��ּܷ��ֲ㴦������union ����
*/
-- ʾ������
create table  #t (
	Item varchar(10),
	Color varchar(10),
	Quantity int)
INSERT #t SELECT 'Table', 'Blue', 124
UNION ALL SELECT 'Table', 'Red',  -23
UNION ALL SELECT 'Chair', 'Blue', 101
UNION ALL SELECT 'Chair', 'Red',  -90

select * from #t
-- ͳ��
SELECT Item,Color,Quantity
FROM(
	--��ϸ
	SELECT
		Item,
		Color,
		Quantity = SUM(Quantity),
		s1=0, s2=Item, s3=0  -- �����������
	FROM #t
	GROUP BY Item, Color
	UNION ALL
	-- ��Item�ϼ�
	SELECT 
		Ittem = '',
		Color = Item + ' sub total',
		Quantity = SUM(Quantity),
		s1=0,s2=Item,s3=1  -- �����������
	FROM #t
	GROUP BY Item
	UNION ALL
	-- �ܼ�
	SELECT 
		Item = 'total',
		Color = '',
		Quantity = SUM(Quantity),
		s1=1, s2 = '', s3=1 -- �����������
	FROM #t
)A
ORDER BY s1, s2, s3
/*--���
Item       Color                Quantity
---------- -------------------- -----------
Chair      Blue                 101
Chair      Red                  -90
           Chair sub total      11
Table      Blue                 124
Table      Red                  -23
           Table sub total      101
total                           112
--*/
