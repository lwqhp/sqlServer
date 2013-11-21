

--���ݿ����
/*
�ܹ�schema
 �Ƕ��������ݿ��û��ķ��ظ������ռ䣬Ҳ����˵���ܹ�ֻ�Ƕ�����������κ��û�������ӵ�мܹ������Ҽܹ�����Ȩ����ת��.

�����û������ݿ�������
	��������ڼܹ����ƶ�.
	�����ܹ����԰����ɶ�����ݿ��û�ӵ�еĶ���.
	������ݿ��û����Թ�����Ĭ�ϼܹ�
*/

--�޸Ķ����schema
ALTER SCHEMA dbo transfer [db_abc].[table_a]

SELECT 'ALTER SCHEMA dbo TRANSFER ' + s.Name + '.' + p.Name + ';'
	FROM sys.tables p INNER JOIN sys.Schemas s on p.schema_id = s.schema_id 
	WHERE s.Name = 'db_abc'


--�ĵ�ǰ�û���default schema����ʱ�Ϳ��Բ��ü�ǰ׺��
ALTER USER dbo WITH DEFAULT_SCHEMA =emdbuser;

--�������л������������Ժ󣬿���ʵ��REVERT�����л�����
EXECUTE AS USER = 'emdbuser';


--������ȡһ�����Schema
select sys.objects.name as A1,sys.schemas.name A2
from�� sys.objects,
��������sys.schemas
where sys.objects.type='U'
and�� sys.objects.schema_id=sys.schemas.schema_id

-------------------------------------------------------------------------------------------

/*
�ܹ�
sys.schemas

����
sys.objects

����		��				��				
sys.types	sys.tables		sys.columns		

�洢����		������			��ͼ
sys.procedures	sys.triggers	sys.views
*/

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