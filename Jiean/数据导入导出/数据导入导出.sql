
/*
��Excel��SQL server�����ݵ��뵼�� 
1����ΧӦ�������������á�
  �ӡ�������ΧӦ������������ѡ������ OPENROWSET �� OPENDATASOURCE ֧�֡�ѡ�
2���ر�Excel��
  ����ڵ���ʱҪ�����Excel����ڴ�״̬������ʾ��
  ���޷���ʼ�����ӷ����� "(null)" �� OLE DB ���ʽӿ� "microsoft.jet.oledb.4.0" ������Դ���󡣡�
3����������ʱ��Excel�����л���Ϊ��ͷ�������뵽�Ѵ��ڵ����ݿ����������С�
*/
--��ѯ
SELECT * FROM OpenDataSource( 'Microsoft.Jet.OLEDB.4.0','Data Source="d:\44.xls";User ID=Admin;Password=;Extended properties=Excel 5.0')...[Sheet1$]
--���벢�½���
SELECT * into #tb FROM OpenDataSource( 'Microsoft.Jet.OLEDB.4.0','Data Source="d:\44.xls";User ID=Admin;Password=;Extended properties=Excel 5.0')...[Sheet1$]
--��Excel��������
insert into OpenDataSource( 'Microsoft.Jet.OLEDB.4.0','Data Source="c:\Temp.xls";User ID=Admin;Password=;Extended properties=Excel 5.0')...tb (A1,A2,A3) values (1,2,3)
INSERT INTO  OPENDATASOURCE('Microsoft.JET.OLEDB.4.0','Extended Properties=Excel 8.0;Data source=C:\training\inventur.xls')...[Sheet1$]  
(bestand, produkt) VALUES (20, 'Tewsst')   
--���ӷ�����:��sql server�ж���������������������������������˷���OLEDB����Դ����Ҫȫ����Ϣ��


OPENROWSET --����ʹ��OLEDB���Ӳ�����Զ�����ݡ�

--/*   �ı��ļ�
select   *   from  
OPENROWSET( 'MICROSOFT.JET.OLEDB.4.0 '
, 'Text;HDR=NO;DATABASE=C:\ '
,aa#txt)
--*/

--/*   Excel�ļ�
select   *   from  
OPENROWSET( 'MICROSOFT.JET.OLEDB.4.0 '
, 'Excel   5.0;HDR=YES;DATABASE=F:\My   Documents\�ͻ�����.xls ',ȫ���ͻ�$)
--*/

--/*   dBase   IV�ļ�
select   *   from  
OPENROWSET( 'MICROSOFT.JET.OLEDB.4.0 '
, 'dBase   IV;DATABASE=C:\ ', 'select   *   from   [�ͻ�����4.dbf] ')
--*/

--/*   dBase   III�ļ�
select   *   from  
OPENROWSET( 'MICROSOFT.JET.OLEDB.4.0 '
, 'dBase   III;DATABASE=C:\ ', 'select   *   from   [�ͻ�����3.dbf] ')
--*/

--/*   FoxPro   ���ݿ�
select   *   from   openrowset( 'MSDASQL ',
'Driver=Microsoft   Visual   FoxPro   Driver;SourceType=DBF;SourceDB=c:\ ',
'select   *   from   [aa.DBF] ')
--*/

--/*   Access���ݿ��ļ�
SELECT   *
FROM   OPENROWSET( 'Microsoft.Jet.OLEDB.4.0 ',  
      'F:\My   Documents\�ͻ�����.mdb '; 'admin '; ' ',�ͻ�)  
--*/--*/ 
/*ʾ��
A.   ��   OPENROWSET   ��   SELECT   ��估����   SQL   Server   ��   Microsoft   OLE   DB   �ṩ����һ��ʹ��
�����ʾ��ʹ������   SQL   Server   ��   Microsoft   OLE   DB   �ṩ�������   pubs   ���ݿ��е�   authors   ��
�����ݿ���һ����Ϊ   seattle1   ��Զ�̷������ϡ���   datasource��user_id   ��   password   �г�ʼ���ṩ����
����ʹ��   SELECT   ��䶨�巵�ص��м���
*/
USE   pubs
GO
SELECT   a.*
FROM   OPENROWSET( 'SQLOLEDB ', 'seattle1 '; 'sa '; 'MyPass ',
      'SELECT   *   FROM   pubs.dbo.authors   ORDER   BY   au_lname,   au_fname ')   AS   a
GO
/*
B.   ��   OPENROWSET   ���������   ODBC   ��   OLE   DB   �ṩ����һ��ʹ��
�����ʾ��ʹ������   ODBC   ��   OLE   DB   �ṩ�����Լ�   SQL   Server   ODBC   �����������   pubs   ���ݿ��е�   authors   �������ݿ���һ����Ϊ   seattle1   ��Զ�̷������С��ṩ��������   ODBC   �ṩ�������õ�   ODBC   �﷨��ָ����   provider_string   ���г�ʼ�������巵�ص��м�ʱʹ��   catalog.schema.object   �﷨��
*/
USE   pubs
GO
SELECT   a.*
FROM   OPENROWSET( 'MSDASQL ',
      'DRIVER={SQL   Server};SERVER=seattle1;UID=sa;PWD=MyPass ',
      pubs.dbo.authors)   AS   a
ORDER   BY   a.au_lname,   a.au_fname
GO
/*
C.   ʹ������   Jet   ��   Microsoft   OLE   DB   �ṩ����
�����ʾ��ͨ������   Jet   ��   Microsoft   OLE   DB   �ṩ�������   Microsoft   Access   Northwind   ���ݿ��е�   orders   ��


˵��     �����ʾ���ٶ��Ѿ���װ��   Access��
*/

USE   pubs
GO
SELECT   a.*
FROM   OPENROWSET( 'Microsoft.Jet.OLEDB.4.0 ',  
      'c:\MSOffice\Access\Samples\northwind.mdb '; 'admin '; 'mypwd ',   Orders)  
      AS   a
GO
/*
D.   ʹ��   OPENROWSET   ��   INNER   JOIN   �е���һ����
�����ʾ���ӱ���   SQL   Server   Northwind   ���ݿ��   customers   ���У��Լ��洢����ͬ�������   
Access   Northwind   ���ݿ��   orders   ����ѡ����������


˵��     �����ʾ���ٶ��Ѿ���װ��   Access��
*/

USE   pubs
GO
SELECT   c.*,   o.*
FROM   Northwind.dbo.Customers   AS   c   INNER   JOIN  
      OPENROWSET( 'Microsoft.Jet.OLEDB.4.0 ',  
      'c:\MSOffice\Access\Samples\northwind.mdb '; 'admin '; 'mypwd ',   Orders)  
      AS   o
      ON   c.CustomerID   =   o.CustomerID  
GO 

SELECT       *
FROM             OPENDATASOURCE(
                  'SQLOLEDB ',
                  'Data   Source=ServerName;User   ID=MyUID;Password=MyPass '
                  ).Northwind.dbo.Categories

--�����Ǹ���ѯ��ʾ������ͨ������   Jet   ��   OLE   DB   �ṩ�����ѯ   Excel   ���ӱ��

    SELECT   *  
FROM   OpenDataSource(   'Microsoft.Jet.OLEDB.4.0 ',
    'Data   Source= "E:\Finance\account.xls ";User   ID=Admin;Password=;Extended   properties=Excel   5.0 ')...xactions 
    
 SELECT * FROM  OPENDATASOURCE('MICROSOFT.JET.OLEDB.4.0','Excel 8.0;DATABASE=E:\123.xls')
 exec sp_configure 'show advanced options',1
reconfigure
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
select * from openrowset('microsoft.jet.oledb.4.0','text;hdr=yes;database=E:',['query'])
select * from opendatasource('microsoft.jet.oledb.4.0','text;hdr=yes;database=E:')...12#12.txt ID Xtype UIDsysrowsetcolumns 4 S 4sysrowsets 5 S 4sysallocunits 7 S 4sysfiles1 NULL S 4syshobtcolumns ; S 