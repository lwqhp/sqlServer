
/*
�˽�һ�����ݿ�ʱ��ͨ�������˽��±��Լ���Ľṹ��
���ṹ�йص�ϵͳ��
sys.schemas : ÿһ�ж�Ӧһ�����ݿ��еļܹ�
sys.tables  : ÿһ����¼��Ӧ���ݿ��е�һ����
sys.columns : ����Ϣ�������ܶ࣬������
sys.types   : ÿһ����¼��Ӧһ����������

��Ӧ��ϵ
schema_id ->sys.schemas��IDֵ
object_id -> ����ID�����ݿ��еĶ�����һ��IDΨһ��ʶ
system_type_id -> ����ID ���ͱ�sys.types
user_type_id -> ����ID ���ͱ�sys.types

sys.tables.schema_id = sys.schemas.schema_id 
sys.tables.object_id = sys.columns.object_id

sys.columns.system_type_id = sys.types.system_type_id
sys.columns.user_type_id - sys.types.user_type_id
*/

SELECT * FROM sys.tables
--��ѯ��ǰ���ݿ�����б�ṹ��Ϣ
SELECT
	schema_name = SCH.name,
	table_name = TB.name,
	column_name = C.name,
	type_name = T.name,
	column_length_byte = C.max_length,
	column_precision = C.precision,
	column_scale = C.scale,
	column_is_nullable = C.is_nullable,
	column_is_identity = C.is_identity,
	column_is_computed = C.is_computed
FROM sys.tables TB
	INNER JOIN sys.schemas SCH
		ON TB.schema_id = SCH.schema_id
	INNER JOIN sys.columns C
		ON TB.object_id = C.object_id
	INNER JOIN sys.types T
		ON C.user_type_id = T.user_type_id
WHERE TB.is_ms_shipped = 0       -- ��������ʾ����ѯ�������ڲ� SQL Server �����������
ORDER BY schema_name, table_name, column_name