

--��
/*

���������1024�У�ʵ��ÿ���ֽ��������ܳ���8060,һ������ҳ��СΪ8K,���а����洢�˸�ҳ��Ϣ��ͷ����ֵ��������
varchar(max),text,image,xml��������ֽ����Ƶ�Լ����
������ͨvarchar,nvarchar,varbinary,sql_variant��������������������ܣ������Щ�������͵ĳ��ȶ�û�г���8000,
�����м���������8000�ֽڵ������ƣ�������ȵ��Ǹ��лᱻ��̬���Ƶ�����һ��8kbҳ��������ԭ�����ʹ��24�ֽڵ�
ָ����棬����ҳ��������ܻή�Ͳ�ѯ���ܡ�

*/
--�޸ı��еľ�����--------------------------------------------------------------------------------
/*
����������������varcar,nvarchar,varbinary,�������޸����������е��У���ʹ��ˣ��������͵��µĴ�СҲ����Ҫ��
ԭ���Ĵ�Ҳ���ܶ��������������Լ������ʹ��alter column.
*/
SELECT * FROM dbo.a
ALTER TABLE dbo.a ALTER COLUMN a INT NOT NULL
ALTER TABLE dbo.a ADD CONSTRAINT PK_a PRIMARY KEY CLUSTERED (a)

ALTER TABLE  dbo.a ALTER COLUMN a VARCHAR(30)

ALTER TABLE a ADD a2 VARCHAR(100) NULL

ALTER TABLE a ALTER COLUMN a2 VARCHAR(50)

CREATE NONCLUSTERED INDEX IX_a ON a(a2)

ALTER TABLE a ALTER COLUMN a2 VARCHAR(100)

ALTER TABLE a ALTER COLUMN a2 VARCHAR(50)

--������--------------------------------------------------------------------------------
/*
�����в�����default����foreign key Լ���������в��ܱ���ʽ���»����(��Ϊ����ֵ���Ǽ������)
�����������������У�����һ��Ҫ����һЩ������������ȷ����(����һ��������������Ƿ�����ͬ�Ľ��)
�;�ȷ��(����������ֵ)

����ʹ��persited�����ļ����У������ڱ�������߷Ǿ�ȷ(���ڸ���)ֵ��������
*/
ALTER TABLE a ADD cost AS(a/a2) -- ��as ����һ��������

ALTER TABLE a ADD cost2 AS(a/a2) PERSISTED --��persisted�ؼ�������������
INSERT INTO a(a,a2)VALUES(10,5)

SELECT * FROM a

--ϡ����--------------------------------------------------------------------------------
/*
����һ���Ż��Ĵ洢��ʽ��Ϊnullֵ�������ֽڵĴ洢����ˣ�����Ϊ���������ϡ���У�Ŀǰ������30000����
�����ݿ���ƺ�Ӧ�ó�����Ҫ�������������У�������м��кͱ��д洢���ݵ��Ӽ����ʱ��ʹ��ϡ�����ǱȽ������
*/

ALTER TABLE a ADD a3 VARCHAR(50) SPARSE NULL  --���һ��ϡ����

SELECT * FROM dbo.a
WHERE a3 IS NULL

/*
�м������Զ����ж����ڱ��е�ϡ���н����߼����飬xml�������ͼ���������selet�������޸ģ�һ����ֻ������һ���м�

*/
--������һ���Ѿ�������ϡ���еı��������м�
ALTER TABLE a ADD a4 XML COLUMN_SET FOR ALL_SPARSE_COLUMNS


CREATE TABLE SetSparse (
a1 INT NULL
,a2 VARCHAR(30) SPARSE NULL
,a3 INT SPARSE NULL
,a4 XML COLUMN_SET FOR ALL_SPARSE_COLUMNS --�����м�
)

/*
һ���������м���select *������ʾϡ���У�
����Ϊϡ���к��м����²��룬����������ͬʱ����
ϡ���п���ʹ�úܶ��������ͣ���image,ntext,text,timestamp,geometry,geography ���û��������Ͳ��С�
*/
SELECT a2,* FROM setsparse --�����ϡ���п�����
INSERT INTO setsparse(a1,a2,a3,a4)
SELECT 1,'a',3,'dfdf'



--ɾ����--------------------------------------------------------------------------------
ALTER TABLE a DROP COLUMN a1

/*
������û��ʹ��primary key foreign key,uniqu ��check constraint ʱ���ſ���ɾ���У�Ҳ����ɾ�����������л���
����defaultֵ����
*/
--��ͼɾ��һ����Լ�����У�ʧ��
ALTER TABLE a ADD a5 INT DEFAULT(1)

ALTER TABLE a DROP COLUMN a5