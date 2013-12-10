

--����������ʽת�������ܵ�Ӱ��

/*
��������������ұ��ʽ���������Ͳ�һ��ʱ���������ʽ����ת�������������������ȼ�˳�򣬵������������ת����
���ʹԭ�е������޷�ʹ�ã���������������,���������������update,delete�����ʱ�����������������ģ�������
������Ӧ�ó����޷��������С�
*/

CREATE TABLE NTest(companyID VARCHAR(20),billno VARCHAR(20),sequence VARCHAR(10),val1 INT,val2 INT ,val3 INT)

INSERT INTO NTest
VALUES('WK','WK20130930-001','001',1,0,1)

CREATE CLUSTERED INDEX IX_NTest ON NTest(companyID,billno,sequence)
--SELECT * FROM NTest

SET STATISTICS PROFILE ON


--��������ƥ��
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID ='WK' AND billno = 'WK20130930-001' AND sequence = '001'
/*
  |--Clustered Index Update(OBJECT:([Test].[dbo].[NTest].[IX_NTest]), SET:([Test].[dbo].[NTest].[val1] = [@1],[Test].[dbo].[NTest].[val2] = [@2],[Test].[dbo].[NTest].[val3] = [@3]), WHERE:([Test].[dbo].[NTest].[companyID]=[@4] AND [Test].[dbo].[NTest].[billno]=[@5] AND [Test].[dbo].[NTest].[sequence]=[@6]))

ʹ�þۼ��������£��򵥸ɾ�
*/

--����������������ʽת��
UPDATE NTest SET val1=2,val2=3,val3=8 WHERE companyID =N'WK' AND billno =N'WK20130930-001' AND sequence =N'001'
/*

  |--Clustered Index Update(OBJECT:([Test].[dbo].[NTest].[IX_NTest]), SET:([Test].[dbo].[NTest].[val1] = [@1],[Test].[dbo].[NTest].[val2] = [@2],[Test].[dbo].[NTest].[val3] = [@3]))
       |--Top(ROWCOUNT est 0)
            |--Nested Loops(Inner Join, OUTER REFERENCES:([Expr1024], [Expr1025], [Expr1023]))
                 |--Compute Scalar(DEFINE:(([Expr1024],[Expr1025],[Expr1023])=GetRangeThroughConvert([@4],[@4],(62))))
                 |    |--Constant Scan
                 |--Clustered Index Seek(OBJECT:([Test].[dbo].[NTest].[IX_NTest]), SEEK:([Test].[dbo].[NTest].[companyID] > [Expr1024] AND [Test].[dbo].[NTest].[companyID] < [Expr1025]),  WHERE:(CONVERT_IMPLICIT(nvarchar(20),[Test].[dbo].[NTest].[companyID],0)=[@4] AND CONVERT_IMPLICIT(nvarchar(20),[Test].[dbo].[NTest].[billno],0)=[@5] AND CONVERT_IMPLICIT(nvarchar(10),[Test].[dbo].[NTest].[sequence],0)=[@6]) ORDERED FORWARD)
   
ִ�мƻ���ø����˺ִܶ࣬�мƻ�Ϊ��ʹ�õ��������ң���ܱ�ɨ�������ɨ��;
��������N'WK',
GetRangeThroughConvert()������չcompanyIDֵΪ'WK'��varchar���͵ķ�Χ[Expr1024],[Expr1025]��
ȷ������ת��������Ŀ���nvarcharֵ��varchar�������������Χ֮�ڣ�

Ȼ��ʹ�������Χ��ԭ���������й���������һ����ʱ��Ȼ����������������ʱ�������������ת���Ƚϣ�
���շ���׼ȷ�Ľ����top�������
 

������һ�������У�SQL Server������һ���ػصķ�ʽʹ����index seek�������˱�ɨ�衣��ʵ���������У���ɸѡ�ķ�Χ
��¼���ﵽNNʱ���ͼ��ײ���������


            
*/      


--�洢���̿���ע������

/*
1,������Դ�������Բ�ͬ��ģ�飬�����ݻ㼯���洢�����е����ݼ�ʱ��Ҫ��֤�洢�����и����ݼ�����������һ�£�
�Ա�������ת�����������ܿ����Լ�����ʧЧ��
*/
--DROP TABLE #sd_posSaleMaster
CREATE TABLE #sd_posSaleMaster(companyID VARCHAR(20),billno VARCHAR(40))
CREATE TABLE #sd_posSaleDetail(companyID VARCHAR(20),billno VARCHAR(40))
go
--����һ������
CREATE INDEX IX_sd_posSaleMaster ON #sd_posSaleMaster(companyID,billno)
CREATE INDEX IX_sd_posSaleDetail ON #sd_posSaleDetail(companyID,billno)

--�����������
SET STATISTICS PROFILE ON

SELECT * FROM #sd_posSaleMaster a
INNER JOIN #sd_posSaleDetail b ON a.companyID = b.companyID AND a.billno = b.billno

--ִ�мƻ��Ա�

|--Nested Loops(Inner Join, OUTER REFERENCES:([Expr1006], [Expr1007]))
   |--Compute Scalar(DEFINE:([Expr1006]=CONVERT_IMPLICIT(nvarchar(20),[tempdb].[dbo].[#sd_posSaleDetail].[companyID] as [b].[companyID],0), [Expr1007]=CONVERT_IMPLICIT(nvarchar(40),[tempdb].[dbo].[#sd_posSaleDetail].[billno] as [b].[billno],0)))
   |    |--Index Scan(OBJECT:([tempdb].[dbo].[#sd_posSaleDetail] AS [b]))
   |--Index Seek(OBJECT:([tempdb].[dbo].[#sd_posSaleMaster] AS [a]), SEEK:([a].[companyID]=[Expr1006] AND [a].[billno]=[Expr1007]) ORDERED FORWARD)
   
|--Nested Loops(Inner Join, OUTER REFERENCES:([a].[companyID], [a].[billno]))
   |--Index Scan(OBJECT:([tempdb].[dbo].[#sd_posSaleMaster] AS [a]))
   |--Index Seek(OBJECT:([tempdb].[dbo].[#sd_posSaleDetail] AS [b]), SEEK:([b].[companyID]=[tempdb].[dbo].[#sd_posSaleMaster].[companyID] as [a].[companyID] AND [b].[billno]=[tempdb].[dbo].[#sd_posSaleMaster].[billno] as [a].[billno]) ORDERED FORWARD) 