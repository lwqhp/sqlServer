/*
��ָҪ���ݶ���еĲ�ֵͬ����ĳ��������ת��Ϊ�м�¼����ʾ����������Ϊÿ����Ҫ��ʾΪ�м�¼���б�д��ͬ�Ĵ������                                                                                                                                    
*/

DECLARE @t TABLE(
	Groups char(2),
	Item varchar(10),
	Color varchar(10),
	Quantity int
)
INSERT @t SELECT 'aa', 'Table', 'Blue',  124
UNION ALL SELECT 'bb', 'Table', 'Red',   -23
UNION ALL SELECT 'bb', 'Cup'  , 'Green', -23
UNION ALL SELECT 'aa', 'Chair', 'Blue',  101
UNION ALL SELECT 'aa', 'Chair', 'Red',   -90

--��ѯ����
SELECT 
	Groups,
	[Table] = SUM(
				CASE Item 
					WHEN 'Table' THEN Quantity
				END),
	[Cup] = SUM(
				CASE Item 
					WHEN 'Cup' THEN Quantity
				END),
	[Chair] = SUM(
				CASE Item 
					WHEN 'Chair' THEN Quantity
				END),

	[Blue] = SUM(
				CASE Color 
					WHEN 'Blue' THEN Quantity
				END),
	[Red] = SUM(
				CASE Color 
					WHEN 'Red' THEN Quantity
				END),
	[Green] = SUM(
				CASE Color 
					WHEN 'Green' THEN Quantity
				END)
FROM @t
GROUP BY Groups
/*--���
Groups Table       Cup         Chair       Blue        Red         Green
------ ----------- ----------- ----------- ----------- ----------- -----------
aa     124         NULL        11          225         -90         NULL
bb     -23         -23         NULL        NULL        -23         -23
--*/
