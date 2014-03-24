

--������
/*
������ṩ���ڽ��ķ�����ˮƽ���ֱ��/�������е����ݣ�ͬʱҪ����һ���߼�������
ˮƽ������ָÿһ����������ͬ���������У�ֻ�Ǽ������е�������

������ʹ�����ͱ�������Ĺ����ü򵥣����ټ���ʱ�䣬���Ʋ�ѯʱ�䣬�������С��ά������

ʵ�ַ���������������:
1)�������������ͷ�������

�����������ڸ���ĳ�е�ֵ������ӳ�䵽����
�����������ö���ķ������������ѷ���ӳ�䵽ʵ�ʵ��ļ��顣

2���ѷ��������󶨵�����
*/

--����
/*
��һ������������ˮƽ���֣�Ҳ���Ǹ���ĳ���У�����ʱ�䣬�Ѽ�����ӳ�䵽�����ϲ�ͬ�ĵײ������ļ��С�
����߹�������ܡ�
*/

--Ϊ���ݿ������µ��ļ���
ALTER DATABASE AdventureWorks
ADD FILEGROUP hit1

ALTER DATABASE AdventureWorks
ADD FILEGROUP hit2

--Ϊ����ӵ��ļ��鴴�������ļ�
ALTER DATABASE AdventureWorks
ADD FILE (
	NAME = 'awhit1',
	FILENAME='d:\aqhit1.ndf',
	SIZE=1MB
)
TO FILEGROUP hit1

ALTER DATABASE AdventureWorks
ADD FILE (
	NAME = 'awhit2',
	FILENAME='d:\awhit2.ndf',
	SIZE=1MB
)
TO FILEGROUP hit2


--�����������������廮�ֳɶ��ٸ���
CREATE PARTITION FUNCTION hitDataRange(datetime) --�������ͣ������Ǵ�ֵ�������ͣ�����ɨ����
AS RANGE LEFT --���廮�ֵļ��������ʱ��ֵ���ڱ߽����һ�࣬���Կ���Ϊ׼�����ǿ���
FOR VALUES('2013/1/1','2014/1/1')-- ��������ʱ�������⽫���Ӧ����ͬ�ķ���


--�������������󶨵�ʵ���ļ���
CREATE PARTITION SCHEME hitdataRangeScheme  --������������
AS PARTITION hitDataRange --ָ����������
TO(hit1,hit2)--��Ӧ�������ļ���

--�󶨵���
CREATE TABLE sales.websiteHits(
	websiteHitID BIGINT NOT NULL IDENTITY(1,1),
	hitDate DATETIME NOT NULL,
	CONSTRAINT PK_websithits PRIMARY KEY(websiteHitID,hitDate)
)
ON hitdataRangeScheme(hitDate) --�󶨣�������������������һ����


------------------------------------------------------------------------------------------

--�鿴���������Ǹ�����
SELECT hitdate,$PARTITION.hitDataRange(hitdate) PARTITION --���÷�������
FROM sales.websiteHits

--�ָ�򴴽�һ���µķ���

--��һ�����е��ļ�����뵽���У�û�еĻ����ȴ���һ����
ALTER PARTITION SCHEME hitdateRangeScheme --�޸ķ�������
NEXT USED [Primary] --�����ǰ��������ӵ�������

--���������ǶԼ���Ļ��֣������ٻ���һ�����
ALTER PARTITION FUNCTION hitDateRange()
SPLIT RANGE('2012/1/1')

--�Ƴ��������䱾���ǰ����������ϲ���һ���������·��뵽Ŀ��ϲ��ķ�����

ALTER PARTITION FUNCTION hitDaterange()
MERGE RANGE('2012/1/1')--�Ƴ�2012���������

-----------------------------------------------------------------------------------------------

--�����ƶ�

--һ��������ʷ���ݵ��±�
CREATE TABLE sales.websiteHitsHistory
(
	websitehitid BIGINT NOT NULL IDENTITY(1,1),
	hitdate DATETIME NOT NULL,
	CONSTRAINT PK_websitehitsHistory PRIMARY KEY(websitehitid,hitdate)
)
ON hitdateRangeScheme(hitdate)

--��ԭ��ĵ�3�����Ƶ��±�
ALTER TABLE sales.websitehits 
SWITCH PARTITION 3
TO sales.websiteHitsHistory PARTITION 3 --ָ��Ŀ����Ҫ����ת�����ݵ�Ŀ���ͷ���
/*
�ڱ�֮��ת�Ʒ������ֶ�ִ���в�����insert ..select ����ܶ࣬��Ϊ�����������ƶ��������ݣ�ֻ���޸����йط���Ŀ
ǰ�������� ���Ԫ¦�ݣ�ͬ��Ҫ��ס���κμ��б��Ŀ����������ǿյĲ�����ΪĿ�ķ������������һ��δ�����ı�
��Ҳ�����ǿյġ�
*/

--ɾ�����������ͷ�����Ҫ��ɾ�����õı�����ɾ��
DROP PARTITION SCHEME hitDaterangeScheme
DROP PARTITION FUNCTION hitdateRange