

--�����Ķ�λ�ͽ��

/*
�������򵥵Ľ�����������������ִ�й����У�����Ҫ��ȡ�Է�����Դ�������������ܵ������������޷��ͷŶԷ��������Դ��

����ִ�����ܵ����谭�������ԣ�
1,����Դ,���������Դ���࣬����ʱ��̫�������������Ľ����ȴ���
2�������̣߳���Ȳ�������Ĺ����߳�ִ�����񣬶�����˯��״̬����ռ�е���Դ�޷��ͷš�
3���ڴ棬�ڴ治�����ɵĵȴ���
4�����в�ѯִ�е������Դ����һ������ö���߳�����ʱ���̺߳��߳�֮����ܻᷢ��������

SqlServer��������

SQLServerĬ�ϼ��5s��������sqserver����������񣬼�⵽���������ݿ�����ͨ��ѡ������һ���߳���Ϊ��������Ʒ
��������������ֹ�̵߳�ǰִ�е��������ع���������Ʒ�����񣬲���1205���󷵻ص�Ӧ�ó���Ĭ�ϻع�������С��
����

*/


--�����Ķ�λ
/*

���������������Щ��Դ֮�������������

a,���ٷ������򿪸��ٱ�־1222
b,SqServer Profiler����ͼ��
*/

DBCC TRACEON(1222,-1)
/*
���������Ľ��� ��deadlock victim= spid=
���ӽ��̵���Դ��clientapp=,hostname=,loginname=

��ǰ�������еĶ���frame procname=
��ǰ�������е���䣺sqlhandle=
��ǰ�������е������� inputbuf

�����������Դ������ waitresource= lockmode=
��ǰ�����˼�������transcount=

������뼶��isolationlevel=

������Դ���ͣ��׾�=ridlock
������Դ���ݣ�fileid= pageid= ..
������Դ���̺����ͣ�ownerid= model=
�ȴ���Դ���̺����ͣ�waiterid= model=
*/

--SQLServer profiler -> Locks -> Deadlock Graph

--�����������
/*

1,��ͬ��ҵ��ͬһҵ���߼�������Դ�����ܻ�ȡ��A��Դʱ��˵�����������Ѿ��ͷ���A��Դ�����ڷ���B��Դ��
���Ͷ����񲢷�ִʱ��ɽ��������Դ��

2�������в������û�����

3�����������̲�����һ���������У�����ִ��ʱ��Խ����Խ���׷���������
������һ���������п�����С�������е�����ͨ�����������������������ͷ������ܡ�

4��ʹ�ýϵ͵ĸ��뼶��
ȷ�������Ƿ����ڽϴ��ĸ��뼶�������С�ʹ�ýϵ͵ĸ��뼶���ʹ�ýϸߵĸ��뼶����й�������ʱ����̡�

5����������ִ�мƻ�����������������Ŀ��
����sqlserver��Ҫɨ�����ű�����ҵ��޸ĵļ�¼������ɨ��Ĺ����У�sqlserverҪΪ������ÿһ����¼���������ִ��
�ƻ���seek,��ҪѶ�ļ�¼��Ŀ�Ƚ��٣������������ĿҲ��Ƚ��٣����ܾ��ܱ���������
*/

DBCC TRACEON(1222,-1)
GO

USE AdventureWorks
go

SET NOCOUNT ON 
GO
WHILE 1=1
BEGIN 
	BEGIN TRAN 
	UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='480951955'
	SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='480951955'
	COMMIT TRAN 
END
/*
��ִ��������ʱ���ִ��󡣴�����ϢΪ: ��������Ϊ��System.OutOfMemoryException�����쳣��
*/

--���Ӷ�
DBCC TRACEON(1222,-1)
GO

USE AdventureWorks
go

USE AdventureWorks
go

SET NOCOUNT ON 
GO
WHILE 1=1
BEGIN 
	BEGIN TRAN 
	UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='407505660'
	SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='407505660'
	COMMIT TRAN 
END
/*
��Ϣ 1205������ 13��״̬ 45���� 5 ��
����(���� ID 55)����һ�����̱������� �� ��Դ�ϣ������ѱ�ѡ����������Ʒ�����������и�����
*/

/*
������
10/19/2013 11:26:39,spid7s,δ֪,Recovery is complete. This is an informational message only. No user action is required.
--�ȴ���Դ�ߣ�process4c2bc8������Ҫһ����������
10/19/2013 11:26:32,spid15s,δ֪,waiter id=process4c2bc8 mode=U requestType=wait
10/19/2013 11:26:32,spid15s,δ֪,waiter-list
--�������Դ�ĳ����ߣ�process4c3288����Ϊprocess4c2bc8����ִ��update��䣬��������Ӧ��Դ�����������������������ġ�
10/19/2013 11:26:32,spid15s,δ֪,owner id=process4c3288 mode=X
10/19/2013 11:26:32,spid15s,δ֪,owner-list
--��һ������Դ
10/19/2013 11:26:32,spid15s,δ֪,ridlock fileid=1 pageid=25268 dbid=11 objectname=AdventureWorks.dbo.Employee_Demo_Heap id=lock8016cd00 mode=X associatedObjectId=72057594056212480
--�ȴ���Դ�ߣ�process4c3288������Ҫһ������������Ϊ������������
10/19/2013 11:26:32,spid15s,δ֪,waiter id=process4c3288 mode=S requestType=wait
10/19/2013 11:26:32,spid15s,δ֪,waiter-list --��Դ�ĵȴ��б�
--�������Դ�ĳ����ߣ�process4c2bc8����Ϊprocess4c2bc8����ִ��update��䣬��������Ӧ��Դ�����������������������ġ�
10/19/2013 11:26:32,spid15s,δ֪,owner id=process4c2bc8 mode=X
10/19/2013 11:26:32,spid15s,δ֪,owner-list --��Դ�ĳ����б�
--������Դ�����������ͣ���λ��Ϣ
10/19/2013 11:26:32,spid15s,δ֪,ridlock fileid=1 pageid=25268 dbid=11 objectname=AdventureWorks.dbo.Employee_Demo_Heap id=lock82bb2e80 mode=X associatedObjectId=72057594056212480
10/19/2013 11:26:32,spid15s,δ֪,resource-list  --���̵���Դ�б�
10/19/2013 11:26:32,spid15s,δ֪,END
10/19/2013 11:26:32,spid15s,δ֪,COMMIT TRAN
10/19/2013 11:26:32,spid15s,δ֪,SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='480951955'
10/19/2013 11:26:32,spid15s,δ֪,UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='480951955'
10/19/2013 11:26:32,spid15s,δ֪,BEGIN TRAN
10/19/2013 11:26:32,spid15s,δ֪,BEGIN
10/19/2013 11:26:32,spid15s,δ֪,WHILE 1=1
10/19/2013 11:26:32,spid15s,δ֪,inputbuf  --����ִ�е�����������
--����process4c2bc8
10/19/2013 11:26:32,spid15s,δ֪,UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='480951955'
10/19/2013 11:26:32,spid15s,δ֪,frame procname=adhoc line=4 stmtstart=68 stmtend=248 sqlhandle=0x020000002249792bd6df8d0c4302e643f5e19ac75c120d98
10/19/2013 11:26:32,spid15s,δ֪,ployee_Demo_Heap] set [BirthDate] = getdate()  WHERE [NationalIDNumber]=@1
10/19/2013 11:26:32,spid15s,δ֪,frame procname=adhoc line=4 stmtstart=68 stmtend=248 sqlhandle=0x02000000d73369359211ac96306bd966df7c5eee1da649d1
10/19/2013 11:26:32,spid15s,δ֪,executionStack
--���ǵڶ�������process4c2bc8
10/19/2013 11:26:32,spid15s,δ֪,process id=process4c2bc8 taskpriority=0 logused=208 waitresource=RID: 11:1:25268:37 waittime=2901 ownerId=2286 transactionname=user_transaction lasttranstarted=2013-10-19T11:26:29.897 XDES=0x8513b730 lockMode=U schedulerid=3 kpid=5916 status=suspended spid=59 sbid=0 ecid=0 priority=0 trancount=2 lastbatchstarted=2013-10-19T11:26:15.850 lastbatchcompleted=2013-10-19T11:26:15.850 clientapp=Microsoft SQL Server Management Studio - ��ѯ hostname=IF-PC hostpid=5856 loginname=sa isolationlevel=read committed (2) xactid=2286 currentdb=11 lockTimeout=4294967295 clientoption1=673187936 clientoption2=390200
10/19/2013 11:26:32,spid15s,δ֪,END
10/19/2013 11:26:32,spid15s,δ֪,COMMIT TRAN
10/19/2013 11:26:32,spid15s,δ֪,SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='407505660'
10/19/2013 11:26:32,spid15s,δ֪,UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='407505660'
10/19/2013 11:26:32,spid15s,δ֪,BEGIN TRAN
10/19/2013 11:26:32,spid15s,δ֪,BEGIN
10/19/2013 11:26:32,spid15s,δ֪,WHILE 1=1
10/19/2013 11:26:32,spid15s,δ֪,inputbuf  --����ִ�е�����������
--process4c3288��������ִ�е����
10/19/2013 11:26:32,spid15s,δ֪,SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='407505660'
10/19/2013 11:26:32,spid15s,δ֪,frame procname=adhoc line=5 stmtstart=250 stmtend=396 sqlhandle=0x02000000fbe0ea1f49dd2abfd1de3ffc4db9389fa280ce66
10/19/2013 11:26:32,spid15s,δ֪,frame procname=adhoc line=5 stmtstart=250 stmtend=396 sqlhandle=0x02000000b20f3208a03c7d075c98490a478482075a345313
10/19/2013 11:26:32,spid15s,δ֪,executionStack
--��һ��process4c3288���̣�������Բ鿴�����̵����������Ϣ
10/19/2013 11:26:32,spid15s,δ֪,process id=process4c3288 taskpriority=0 logused=208 waitresource=RID: 11:1:25268:30 waittime=2900 ownerId=2285 transactionname=user_transaction lasttranstarted=2013-10-19T11:26:29.300 XDES=0x8513ae80 lockMode=S schedulerid=3 kpid=7868 status=suspended spid=56 sbid=0 ecid=0 priority=0 trancount=1 lastbatchstarted=2013-10-19T11:26:29.087 lastbatchcompleted=2013-10-19T11:26:29.087 clientapp=Microsoft SQL Server Management Studio - ��ѯ hostname=IF-PC hostpid=5856 loginname=sa isolationlevel=read committed (2) xactid=2285 currentdb=11 lockTimeout=4294967295 clientoption1=673187936 clientoption2=390200
10/19/2013 11:26:32,spid15s,δ֪,process-list --�����б�
10/19/2013 11:26:32,spid15s,δ֪,deadlock victim=process4c3288 --��Ϊ����������ƷID
10/19/2013 11:26:32,spid15s,δ֪,deadlock-list  --�����б�

����־�п��Կ�����process4c3288��һ������ִ����������󣬽���ִ��һ����ѯ��䣬�����ڶԲ�ѯ�ļ�¼���빲����
��ʱ����������һ�����ڸ������������������������������������˵ȴ���������ȴ�������Լ���һ����µ������������ͷš�

ͬʱ����һ��������Ҫ������䣬���ڶԲ�ѯ�ļ�¼�������������������һ�������������ʱ�����˵ȴ������ˣ��������̽����˵ȴ��Է�����ѭ���С�

�����������������������������ڸ��²�ͬ�ļ�¼��Ϊʲô��Ҫȥ��ļ�¼�����빲�����͸�������
ԭ��Ϊ������䶼û�к��ʵ����������������table scan��ɨ�裬�����о����ļ�¼�϶�Ҫ���빲�����͸���������ô���Ǿͻ��г��ֻ���ȴ��Ŀ��ܡ�
����ī�ƶ��ɣ��κ��п��ܷ��������飬������һ���ᷢ����

���˼·��
1�������������Ե���ִ�мƻ�����������������Ŀ���Ӷ�����������

2��ʹ��nolock����select ��䲻Ҫ����S��������������Ŀ

3�������������ȣ�������ת��Ϊһ���������⡣

4��ʹ�ÿ��ո��뼶��
*/

