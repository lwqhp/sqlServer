

--���ݿ�汾
SELECT @@VERSION
--�򲹶�
SELECT SERVERPROPERTY('productLevel')
--ʵ��
computer_name\instance_name

--ͳ�����ݿ���ÿ�������ϸ�����
  exec sp_MSforeachtable @command1="sp_spaceused '?'"

  --���ÿ����ļ�¼��������:
  EXEC sp_MSforeachtable @command1="print '?'",
       @command2="sp_spaceused '?'",
       @command3= "SELECT count(*) FROM ? "

  --������е����ݿ�Ĵ洢�ռ�:
  EXEC sp_MSforeachdb  @command1="print '?'",
       @command2="sp_spaceused "
       
       

---------------���ݿ����滷��-----------------

--���Ի���
/*sql server �ж�����33�����ԣ�ÿ������ȷ����һ�����ڽ��ͷ��������� syslanguages ϵͳ����
SET LANGUAGE ָ��SqlServer����
SET DATEFIRST {number | @number_var} ����һ�ܵĵ�һ�������ڼ����������û�����Ч��
	1~��ʾһ�ܵĵ�һ��������һ��7~��ʾһ�ܵĵ�һ���ӦΪ�����ա�
*/
SELECT @@LANGUAGE

--����Ĭ������ΪӢ��
use master
exec sp_configure 'default language',0
reconfigure with override 
--SET ָ����������(�Ự��)
set language N'english'

--һ�ܵĵ�һ�������ڼ�,1-7
SELECT @@DATEFIRST

--���õ�һ�������ڼ�
set datefirst 7

--�������ڵ���ʾ��ʽ
set dateformat dmy --mdy,dmy,ymd,ydm,myd,dym