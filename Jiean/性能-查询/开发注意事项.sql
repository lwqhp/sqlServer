
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