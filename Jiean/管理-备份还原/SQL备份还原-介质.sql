/*
���ʼ������ʴأ����ݼ�

���ݽ��ʣ������������С��Ԫ���ִ��̺ʹŴ�
���ʼ�(ý�弯)media set��  ���ݽ��ʵ����򼯺�(�߼�����).
���ʴ�media family : �ǶԽ��ʼ��С������豸���ı�ʶ��ͬһ��ľ��񱸷��豸��ʶΪһ���ء�
		�ڽ��ʼ��У����ݽ��ʴ��ڽ��ʼ��е�λ�ã���˳������ʴؽ��б�š� 
���ݼ�: Ҳ���Ǳ����豸������һ���߼�����ڴ����У���ָ�ļ����ڴŴ����У�����ָ�Ŵ�.

��ԭ��
 �����κδӴ��̱��ݽ��еĻ�ԭ�Լ��κ�������ԭ������ͬʱװ��ȫ�����ʴء� 
 ���ڴӴŴ����ݽ��е��ѻ���ԭ���������������ڽ��ʴصı����豸�д�����ʴء� 
 ������ÿһ���ʴ�����ȫ����֮����ܿ�ʼ������һ�����ʴء� ���ʴ����ǲ��д���ģ�����ʹ�õ����豸��ԭ���ʴء�
 
 ѡ�
 ׷�ӵ����б��ݼ� ��ͨ�����µı��ݼ�׷�ӵ����н��ʼ��� ׷�ӵ�����ʱ�ᱣ��������ǰ�ı��ݡ�
	���ݼ�����ʱ�䣺���ݼ�����Ԥ����ĵ�������ʱ�����ݻ��Զ����Ǳ��ݼ������ֵ�ǰ���ʱ�ͷλ�ò��䡣

׷�ӵ����б��ݼ� �� ���Խ�������ͬ��ͬ���ݿ�ġ��ڲ�ͬʱ��ִ�еı��ݴ洢��ͬһ�������ϡ� 
	ͨ�����������ݼ�׷�ӵ����н����ϣ���������ǰ�����ݱ��ֲ��䣬�µı����ڽ��������һ�����ݵĽ�β��д�롣  
*/

------------------------------------------------------------------------------------------------
/*
����õ�һ������ʱ����ʱ����ܻ᲻֪�����ݼ��а����ı�����Ϣ
 ֻ��Ե�ǰ������·��
*/

--RESTORE ����ѯ�����ļ����ݣ�ý�壩����Ϣ
RESTORE LABELONLY FROM DISK='F:\DBBak\ad01.bak'

/*FamilyCount :���ʴ���Ŀ�����>1,��ʵ��������ʹ�õı��ݼ�С�������Ŀ�Ļ�������ζ���޷����������ý��
�������ݻ�ԭ��
*/


--�鿴���ݼ�������Ϣ
RESTORE HEADERONLY FROM DISK='F:\DBBak\ad01.bak'

/*
���ݵ��ļ��������Զ��壬ͨ��headeronly���Բ鿴�������ļ�����ʱ������backupname�����ݵ����ݿ�databasename,
���ݼ��ڱ���ý���е�λ��position,����fileѡ��������ͺ�ʱ��ȡ�
*/

--�鿴�����ļ���Ϣ�������ļ�����־�ļ�
RESTORE FILELISTONLY FROM DISK='F:\DB\Backup\947kan' WITH FILE =1

/*
�ָ����ݿ��ʱ�򣬵���Ҫ�ѱ����ļ��ָ�����ԭ����λ�ã�������Բ鵽����ʱ�����ݿ�·����ԭ�������ݿ�����
��GUI��ֻ���������������ݿ�����
*/


----===========================================================================

/*ͨ��ϵͳ��Ϣ�˽����ݿ�ı��ݼ�¼�ͱ��ݲ���*/


--���ʼ�
select * from  msdb.dbo.backupmediaset

--����ļ�¼����ĳ��ý�弯��Ű������ٸ������ļ���ÿһ���ֳ�Ϊ���ʴ�
select * from  msdb.dbo.backupmediafamily
/*
physical_device_name : ���ݼ��ı���·��

backup_set_id�������ݿ��ÿ�α��ݶ���Ψһ��һ����ţ���Ϊ���ݼ����

media_set_id��Ϊ����ý�弯��ţ���Ϊһ���߼����ƣ������������ļ��ĳ���ĳ�ν������ǰѶ�εı���ͬʱ����һ�������ļ��У��Ǳ���ý�弯����ǲ����

last_family_number�����ݷ�����ٸ������ļ��е�
*/

--������־�����ݵ���ʷ��Ϣ,ÿ�������ݿ�������ʱ��sqlserver��msdb.dbo.backupset���в���һ�м�¼
select * from msdb.dbo.backupset

--���ݿⱸ���ļ���Ϣ
select * from  msdb.dbo.backupfile
/*
physical_drive ������Դ��������
physical_name ������Դ������·��
*/

SELECT 
c.first_lsn, 
c.last_lsn,
c.database_backup_lsn,
c.backup_finish_date,
c.type,
b.physical_device_name
FROM msdb..backupmediafamily a --���ʼ���¼ÿһ�α�����Ϣ
INNER JOIN msdb..backupmediafamily b ON a.media_set_id = b.media_set_id -- ���ʴؾ����¼����·��������
INNER JOIN msdb..backupset c ON a.media_set_id = c.media_set_id --������־��������صĽ��ʼ��ı��ݼ�¼(һ��ֱ�Ӳ�ѯ���Ｔ��)
INNER JOIN msdb..backupfile d ON c.backup_set_id = d.backup_set_id --������������Դ�������Ϣ
ORDER BY c.backup_finish_date DESC 
/*
������־����������first_lsn ��ʶ���ݼ��е�һ����־��¼����־��last_lsn ��ʶ���ݼ�֮�����һ����־��¼����־
���кţ�����(first_lsn,last_lsn-1)��ʶ�������־������������������־���С�

batabase_backup_lsn ��ʶ��һ�����ݿ�ȫ���ݵ���ʼLSN.
*/

BACKUP DATABASE [Test] TO DISK = 'e:\Test.bak'

SELECT * FROM msdb..backupset a
--INNER JOIN msdb..backupfile b ON a.backup_set_id = b.backup_set_id
WHERE  a.database_name ='Test'
--first_lsn last_lsn checkpoint_lsn database_backup_lsn
--253000000558200037  253000000559800001 253000000558200037 253000000555800037

CREATE TABLE tbb1(id int)
go
INSERT INTO tbb1 VALUES(1)

--��һ����־����
BACKUP LOG [test] TO DISK = 'e:\Testlog.bak'

SELECT * FROM msdb..backupset
--fork_point_lsn - first_lsn - last_lsn - database_backup_lsn
--67000000022400001	67000000022400001  253000000561500001 253000000558200037
/*
��־���ݵ�checkpoint�����ϴα��ݵ�point�㣬database_bakcup_lsn�㱣�ֲ���
*/

--��һ���޸�
INSERT INTO tbb1(id) VALUES(2)

--����һ����־����
BACKUP LOG [Test] TO DISK='e:\Testlog2.bak'
SELECT * FROM msdb..backupset
--fork_point_lsn - first_lsn - last_lsn - database_backup_lsn
--null	253000000561500001  253000000558200037 253000000558200037
/*
first_lsn ����һ����־���ݵ�βlsn,��Ӱ��database_backup_lsn
*/


--��һ�����챸��
INSERT INTO tbb1(id) VALUES(3)

BACKUP DATABASE [Test] TO DISK='e:\Testdiff.bak' WITH differential
SELECT * FROM msdb..backupset
--differential_baselsn - first_lsn - last_lsn - checkpoint_lsn - database_backup_lsn
--253000000558200037	253000000561800144  253000000567800001 253000000561800144 253000000558200037
/*
���챸�ݵ�point_lsn�Ǹ�����ȫ���ݵ�
*/

--����һ����־����
INSERT INTO tbb1(id) VALUES(4)

BACKUP LOG [Test] TO DISK ='e:\Testlog3.bak'
SELECT * FROM msdb..backupset
--fork_point_lsn - first_lsn - last_lsn - database_backup_lsn
--null	253000000561700001  253000000568000001 253000000558200037
/*
��־���ݵ�first_lsn�ǽ�������һ����־���ݵ�last_lsn��database_backup_lsn�򱣴����һ�����ݱ��ݲ���
*/

/*
�ܽ᣺
1��������ȫ���ݻ��ǲ��챸�ݣ�������Ӱ��lsn�����У����ԣ���ʹ������ļ���ȫ���ݻ���챸������ֻҪ��һ��ȫ���ݣ�
�Լ���ȫ�������е���־���ݣ�����Ҳ���ܹ�������ȱ�ذ����ݻָ�������ֻ�ǻָ���ʱ�����΢��һ�㡣
�м�Ĳ��챸�ݻ�����ȫ����ֻ�Ǽ�������Ҫ�ָ�����־������Ŀ�����һ��˵������־���ݵ���Ҫ�ԡ�

2����־���ݵ�lsn�������ģ������ڻָ���ʱ�򣬻�������־���ѵ����⣬�ָ��ǲ��ܼ�����ȥ�ġ�

*/

--�����־��
SELECT ROW_NUMBER() OVER(ORDER BY backup_finish_date) id,first_lsn,last_lsn
INTO #tmp
 FROM msdb..backupset a
INNER JOIN msdb..backupfile b ON a.backup_set_id = b.backup_set_id AND b.file_type='L'
WHERE type='L' AND b.physical_name='F:\DB\Test_log.ldf'
ORDER BY backup_finish_date

SELECT * FROM #tmp

;WITH CTETmp AS(
	SELECT id,first_lsn,last_lsn,0 AS [level] FROM #tmp WHERE id = 1
	UNION ALL
	SELECT a.id,a.first_lsn,a.last_lsn,b.[level] +1 AS [level] FROM #tmp a
	INNER JOIN CTETmp b ON a.id = b.id+1 AND a.first_lsn <>b.last_lsn
)
SELECT * FROM CTETmp WHERE [level]>0

--����
UPDATE #tmp SET first_lsn = 253000000561500002 WHERE id = 2

