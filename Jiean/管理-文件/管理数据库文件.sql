

--�������ݿ��ļ�

--����ļ�,����Ҫ�����ݿ�����Ϊ����

ALTER DATABASE Test
ADD [log] FILE (
	NAME ='test02',
	FILENAME='e:\test02.mdf',
	SIZE=1MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=1mb
)
TO FILEGROUP[primary] --ָ��������ļ����ļ���


--ɾ�����ļ�����־�ļ�
/*
�����Ҫͨ����һ�������ϴ������ļ�Ȼ��ɾ�����ļ������ļ���һ�����̡��������·��䵽��ͬ�Ĵ���/���У��Ϳ���
ϣ�������������
*/
--�鿴�߼���
SELECT * FROM sys.database_files

--����ļ��е�����
DBCC SHRINKFILE(test,EMPTYFILE)


ALTER DATABASE Test
REMOVE FILE test02

--���·��������ļ�

--����
ALTER DATABASE Test
SET OFFLINE

--�������ļ��Ƶ���Ŀ¼f:\
--�޸����ݿ�����
ALTER DATABASE Test
MODIFY FILE (
	NAME = 'test',
	FILENAME='f:\test.mdf'
)

--����
ALTER DATABASE Test
SET ONLINE

--�޸������ļ����߼���
/*
���Բ������ݿ���Ϊ���ߣ����ݿ���߼�������Ӱ�����ݿⱾ��Ĺ��ܣ��������һ���Ժ�����Լ����ԭ����޸�����
*/
ALTER DATABASE Test
MODIFY FILE (
	NAME ='test',newname = 'testnew'
)

--�������ݿ��ļ��Ĵ�С������
ALTER DATABASE Test
MODIFY FILE(
	NAME='test',
	SIZE = 30MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH=50mb
)

--��������ļ���
ALTER DATABASE Test
ADD FILE(
	NAME ='test02',
	FILENAME='e:\test02.ndf',
	SIZE=10MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=50mb
)
TO FILEGROUP [fg2]

--����Ĭ���ļ���
ALTER DATABASE Test
MODIFY FILEGROUP fg2 DEFAULT

--ɾ���ļ���

--ɾ���ļ����е��ļ�
ALTER DATABASE Test
MOVE FILE test02

--ɾ���ļ���
ALTER DATABASE Test
MOVE FILEGROUP [fg2]


--�������ݿ�ֻ��
ALTER DATABASE Test
SET READ_ONLY | READ_WRITE	

--�ļ���ֻ��
ALTER DATABASE Test
MODIFY FILEGROUP fg2 READ_ONLY