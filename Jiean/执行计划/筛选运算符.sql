

--ɸѡ�����������
/*
	Filter :ɨ�����룬��������Щ���� Argument ���е�ɸѡ���ʽ��ν�ʣ����С�
		�������н���ɸѡʱ��ʹ�õ���������ڲ��ң�ɨ���������WHERE�����У�Ҳ����Filter���㡣
		
	CONVERT_IMPLICIT():Filter������ʹ�õ�����ת������	
*/
|--Clustered Index Seek(OBJECT:([Test].[dbo].[NTest].[IX_NTest]), SEEK:([Test].[dbo].[NTest].[companyID] > [Expr1024] AND [Test].[dbo].[NTest].[companyID] < [Expr1025]),  WHERE:(CONVERT_IMPLICIT(nvarchar(20),[Test].[dbo].[NTest].[companyID],0)=[@4] AND CONVERT_IMPLICIT(nvarchar(20),[Test].[dbo].[NTest].[billno],0)=[@5] AND CONVERT_IMPLICIT(nvarchar(10),[Test].[dbo].[NTest].[sequence],0)=[@6]) ORDERED FORWARD)