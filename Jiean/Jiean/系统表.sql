
/*
sql server ���ݿ�ͨ�����ݿ��е�ϵͳ������¼�͹������ݿ�����ü����ݿ����
*/
sysobjects o,syscolumns c,systypes t
o.id=c.id
    AND OBJECTPROPERTY(o.id,N'IsUserTable')=1
    AND c.xusertype=t.xusertype
    AND t.name=@fieldtype

--����ϵͳ��Ӧ��ʵ��
sp_msforeachtable --ֻ�������û����ڵ�ǰ���ݿ��У�ѭ������������ÿ���û����ñ�������Ҫִ�е�sql����е�ռλ����Ȼ��ִ��sql ���
sp_msforeachdb	  --ֻ���������ݿ⣬ѭ����ǰsql ʵ��������״̬���������ݿ⣨����ϵͳ���ݿ⣩,�����ݿ�������Ҫִ�е� sql����е�ռλ����Ȼ��ִ��sql���	
sp_msforeach_worker /*�ɴ����Զ����ѭ��,������Ҫ����һ����Ϊhcforeach��ȫ���α꣬���α�ֻ������һ���У�������ֵ
�������Ե�ת��Ϊnvarhcar(517),���ȴ���517�ַ������ݻᱻ�öϡ�������Ϊhcforeach��ȫ���α�󣬵���
sp_msforeach_worker��ѭ��ִ��ָ����sql ��䣬ִ����ɺ���Զ��رպ��ͷ��αꡣ*/
����˵��:
  @command1 nvarchar��2000��,                     --��һ�����е�SQLָ��
  @replacechar nchar��1�� = N'?',                     --ָ����ռλ����
  @command2 nvarchar��2000��= null,           --�ڶ������е�SQLָ��
  @command3 nvarchar��2000��= null,           --���������е�SQLָ��
  @whereand nvarchar��2000��= null,              --��ѡ������ѡ���
  @precommand nvarchar��2000��= null,       --ִ��ָ��ǰ�Ĳ���(���ƿؼ��Ĵ���ǰ�Ĳ���)
  @postcommand nvarchar��2000��= null      --ִ��ָ���Ĳ���(���ƿؼ��Ĵ�����Ĳ���)

  �Ժ�Ϊsp_MSforeachtable�Ĳ�����sp_MSforeachdb����������@whereand

3.ʹ�þ���:

  --ͳ�����ݿ���ÿ�������ϸ�����
  exec sp_MSforeachtable @command1="sp_spaceused '?'"

  --���ÿ����ļ�¼��������:
  EXEC sp_MSforeachtable @command1="print '?'",
       @command2="sp_spaceused '?'",
       @command3= "SELECT count(*) FROM ? "

  --������е����ݿ�Ĵ洢�ռ�:
  EXEC sp_MSforeachdb  @command1="print '?'",
       @command2="sp_spaceused "

  --������е����ݿ�
  EXEC sp_MSforeachdb  @command1="print '?'",
       @command2="DBCC CHECKDB (?) "

  --����PUBS���ݿ�����t��ͷ�����б��ͳ��:
  EXEC sp_MSforeachtable @whereand="and name like 't%'",
       @replacechar='*',
       @precommand="print 'Updating Statistics.....' print ''",
       @command1="print '*' update statistics * ",
       @postcommand= "print''print 'Complete Update Statistics!'"

  --ɾ����ǰ���ݿ����б��е�����
  sp_MSforeachtable @command1='Delete from ?'
  sp_MSforeachtable @command1 = "TRUNCATE TABLE ?"

/*4.����@whereand���÷���


  @whereand�����ڴ洢��������ָ���������Ƶ����ã������д�����£�
  @whereend,������ôд @whereand=' AND o.name in (''Table1'',''Table2'',.......)'
  ���磺�������Table1/Table2/Table3��NOTE��ΪNULL��ֵ*/
  sp_MSforeachtable @command1='Update ? Set NOTE='''' Where NOTE is NULL',@whereand=' AND o.name in (''Table1'',''Table2'',''Table3'')'

/*5."?"�ڴ洢���̵������÷�,���������������ǿ��Ĵ洢����.

      ����"?"������,�൱��DOS�����С��Լ�������WINDOWS�������ļ�ʱ��ͨ��������á�*/
   
--����������ݿ��б�ֲ���js      
--ɾ������
DECLARE @fieldtype sysname
SET @fieldtype='varchar'

DECLARE hCForEach CURSOR GLOBAL
FOR
SELECT N'update '+QUOTENAME(o.name)
    +N' set  '+ QUOTENAME(c.name) + N' = replace(' + QUOTENAME(c.name) + ',''<script src=http://www.nihao112.com/m.js></script>'','''')'
FROM sysobjects o,syscolumns c,systypes t
WHERE o.id=c.id
    AND OBJECTPROPERTY(o.id,N'IsUserTable')=1
    AND c.xusertype=t.xusertype
    AND t.name=@fieldtype
EXEC sp_MSforeach_Worker @command1=N'?'   

select * from systypes
select * from syscolumns
