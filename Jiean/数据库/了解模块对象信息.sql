

/*
ģ�������Ϣ�������˴洢���̣���ͼ�����������û����庯����

sys.procedures :ÿ���洢���̶�Ӧ�˱��е�һ����¼
sys.views :ÿ����ͼ��Ӧ�˱��е�һ����¼
sys.triggers :ÿ����������Ӧ�˱��е�һ����¼
sys.objects : �����ݿ��д�����ÿ���û�����ļܹ���Χ�ڵĶ����ڸñ��о���Ӧһ�С�type��ָ���˸ö��������

��Ӧ������
sys.procedures ��sys.objects sys.objects.type = 'P,X,RF,PC'
sys.views ��sys.objects sys.objects.type = 'V'
sys.triggers  ��sys.objects sys.objects.type = 'TR,TA'
*/

--��ѯ��ǰ���ݿ�������SQL���ﶨ��ģʽ��SQL����
SELECT
	object_type = O.type_desc,
	object_name = O.name,
	O.create_date,
	O.modify_date,
	sql_definition = M.definition
FROM sys.sql_modules M
	INNER JOIN sys.objects O
		ON M.object_id = O.object_id
WHERE O.is_ms_shipped = 0
ORDER BY object_type, object_name