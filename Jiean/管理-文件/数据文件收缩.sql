


--�����ļ�����
/*
1,��ѹ������������ļ�֮ǰ������Ҫ���������Ҫ������
delete  ������ͷſռ�
truncate table  drop table �����ͷſռ䣬��Ϊ
a)���õ�������־�ռ����
b)ʹ�õ���ͨ������
c)���н���������ز������κ�ҳ��

���ַ�������delete��Ŀ�ҳ
a),�����ۼ��������ؽ������ͷſ���ҳ��
b),�½�һ�ű������ݵ���ȥ��drop ���ɱ�

2���������ݿ�
*/
--����ָ�����ݿ��е����������ļ�����־�ļ��Ĵ�С
DBCC SHRINKDATABASE

--������ǰ���ݿ�ָ�������ļ�����־�ļ��Ĵ�С
--����ͨ�������ݴ�ָ�����ļ��ƶ�����ͬ�ļ����е������ļ�������ļ�������������ݿ���ɾ�����ļ�
DBCC SHRINKFILE

/*
�������ݿ�ע��㣺
1������Ҫ�˽������ļ���ǰ��ʹ������������������ܳ�����ǰ�ļ��Ŀ��пռ�Ĵ�С�������Ҫѹ�����ݿ�Ĵ�С������
Ҫ�������ļ����ȷ����Ӧδ��ʹ�õĿռ䣬����ռ䶼��ʹ����Ҫ��ȷ�ϴ���ռ�ÿռ�Ķ��󣨱����������Ȼ��ͨ���鵵
�������ݣ��ѿռ��ͷų�����

2���������ļ��ǲ��ܱ���յģ��ܱ���ȫ��յ�ֻ�и��������ļ���

3��¦��Ҫ��һ���ļ����� ����գ�Ҫɾ������������ļ����ϵĶ�����߰������Ƶ������ļ�����

4�������ļ����пռ䣬��������գ�����Ϊ�����ļ�������Ȼ�кܶ�Ŀյ�ҳ�棬������Щҳ���ɢ�ڸ������ʹ�������ļ�û�кܶ�յ�����
dbcc shrinkfile���Ķ�����һ���Ķ����������һ��������Ŀ�ҳ�Ƴ����ϲ�����

5����������ŵ���text��image֮����������ͣ��ؽ���������Ӱ�����ǵĿռ䣬�����Ȱ���Щ����������Ķ����ҳ�����
Ȼ���ؽ����ǡ�

*/

--����dbcc extentinfo�����������ļ�����������ķ�����Ϣ����ڸ�����������������Ŀ��ʵ�ʵ���Ŀ�����ʵ����
--ĿԶ�����������ݣ���������������Ƭ���࣬���Կ����ؽ�����

CREATE TABLE extentinfo(
FILE_ID SMALLINT,
page_id INT,
pg_alloc INT,
ext_size INT,
obj_id INT,
index_id INT,
partition_number INT,
partition_id BIGINT,
iam_chain_type VARCHAR(50),
pfs_bytes VARBINARY(10)
)
go
CREATE PROCEDURE import_extentinfo
AS
DBCC extentinfo('lwqhp')
GO

INSERT extentinfo
EXEC import_extentinfo
go

SELECT 
FILE_ID,obj_id,index_id,partition_id,ext_size,
'actual extent count'=COUNT(*),'actual page count'=SUM(pg_alloc),
'possible extent count'=CEILING(SUM(pg_alloc)*1.0/ext_size),
'possible extents / actual extents'=(CEILING(SUM(pg_alloc)*1.0/ext_size)*100.00)/COUNT(*)
 FROM extentinfo
GROUP BY FILE_ID,obj_id,index_id,partition_id,ext_size
HAVING COUNT(*)-CEILING(SUM(pg_alloc)*1.0/ext_size)>0
ORDER BY partition_id,obj_id,index_id,file_id
