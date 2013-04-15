
/*
将Excel与SQL server的数据导入导出 
1）外围应用配置器的设置。
  从“功能外围应用配置器”中选择“启动 OPENROWSET 和 OPENDATASOURCE 支持”选项。
2）关闭Excel表。
  如果在导入时要导入的Excel表格处于打开状态，会提示：
  “无法初始化链接服务器 "(null)" 的 OLE DB 访问接口 "microsoft.jet.oledb.4.0" 的数据源对象。”
3）导入数据时，Excel的首行会作为表头，若导入到已存在的数据库表，则忽略首行。
*/
--查询
SELECT * FROM OpenDataSource( 'Microsoft.Jet.OLEDB.4.0','Data Source="d:\44.xls";User ID=Admin;Password=;Extended properties=Excel 5.0')...[Sheet1$]
--导入并新建表
SELECT * into #tb FROM OpenDataSource( 'Microsoft.Jet.OLEDB.4.0','Data Source="d:\44.xls";User ID=Admin;Password=;Extended properties=Excel 5.0')...[Sheet1$]
--往Excel插入数据
insert into OpenDataSource( 'Microsoft.Jet.OLEDB.4.0','Data Source="c:\Temp.xls";User ID=Admin;Password=;Extended properties=Excel 5.0')...tb (A1,A2,A3) values (1,2,3)
INSERT INTO  OPENDATASOURCE('Microsoft.JET.OLEDB.4.0','Extended Properties=Excel 8.0;Data source=C:\training\inventur.xls')...[Sheet1$]  
(bestand, produkt) VALUES (20, 'Tewsst')   
--链接服务器:在sql server中定义的虚拟服务器，链拉服务器定义包含了访问OLEDB数据源所需要全部信息。


OPENROWSET --函数使用OLEDB连接并访问远程数据。

--/*   文本文件
select   *   from  
OPENROWSET( 'MICROSOFT.JET.OLEDB.4.0 '
, 'Text;HDR=NO;DATABASE=C:\ '
,aa#txt)
--*/

--/*   Excel文件
select   *   from  
OPENROWSET( 'MICROSOFT.JET.OLEDB.4.0 '
, 'Excel   5.0;HDR=YES;DATABASE=F:\My   Documents\客户资料.xls ',全部客户$)
--*/

--/*   dBase   IV文件
select   *   from  
OPENROWSET( 'MICROSOFT.JET.OLEDB.4.0 '
, 'dBase   IV;DATABASE=C:\ ', 'select   *   from   [客户资料4.dbf] ')
--*/

--/*   dBase   III文件
select   *   from  
OPENROWSET( 'MICROSOFT.JET.OLEDB.4.0 '
, 'dBase   III;DATABASE=C:\ ', 'select   *   from   [客户资料3.dbf] ')
--*/

--/*   FoxPro   数据库
select   *   from   openrowset( 'MSDASQL ',
'Driver=Microsoft   Visual   FoxPro   Driver;SourceType=DBF;SourceDB=c:\ ',
'select   *   from   [aa.DBF] ')
--*/

--/*   Access数据库文件
SELECT   *
FROM   OPENROWSET( 'Microsoft.Jet.OLEDB.4.0 ',  
      'F:\My   Documents\客户资料.mdb '; 'admin '; ' ',客户)  
--*/--*/ 
/*示例
A.   将   OPENROWSET   与   SELECT   语句及用于   SQL   Server   的   Microsoft   OLE   DB   提供程序一起使用
下面的示例使用用于   SQL   Server   的   Microsoft   OLE   DB   提供程序访问   pubs   数据库中的   authors   表，
该数据库在一个名为   seattle1   的远程服务器上。从   datasource、user_id   及   password   中初始化提供程序，
并且使用   SELECT   语句定义返回的行集。
*/
USE   pubs
GO
SELECT   a.*
FROM   OPENROWSET( 'SQLOLEDB ', 'seattle1 '; 'sa '; 'MyPass ',
      'SELECT   *   FROM   pubs.dbo.authors   ORDER   BY   au_lname,   au_fname ')   AS   a
GO
/*
B.   将   OPENROWSET   与对象及用于   ODBC   的   OLE   DB   提供程序一起使用
下面的示例使用用于   ODBC   的   OLE   DB   提供程序以及   SQL   Server   ODBC   驱动程序访问   pubs   数据库中的   authors   表，该数据库在一个名为   seattle1   的远程服务器中。提供程序用在   ODBC   提供程序所用的   ODBC   语法中指定的   provider_string   进行初始化，定义返回的行集时使用   catalog.schema.object   语法。
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
C.   使用用于   Jet   的   Microsoft   OLE   DB   提供程序
下面的示例通过用于   Jet   的   Microsoft   OLE   DB   提供程序访问   Microsoft   Access   Northwind   数据库中的   orders   表。


说明     下面的示例假定已经安装了   Access。
*/

USE   pubs
GO
SELECT   a.*
FROM   OPENROWSET( 'Microsoft.Jet.OLEDB.4.0 ',  
      'c:\MSOffice\Access\Samples\northwind.mdb '; 'admin '; 'mypwd ',   Orders)  
      AS   a
GO
/*
D.   使用   OPENROWSET   和   INNER   JOIN   中的另一个表
下面的示例从本地   SQL   Server   Northwind   数据库的   customers   表中，以及存储在相同计算机上   
Access   Northwind   数据库的   orders   表中选择所有数据


说明     下面的示例假定已经安装了   Access。
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

--下面是个查询的示例，它通过用于   Jet   的   OLE   DB   提供程序查询   Excel   电子表格。

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