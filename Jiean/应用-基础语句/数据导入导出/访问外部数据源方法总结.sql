/*================================================================*/
/*==                                                            ==*/
/*==                         模板关键字说明                     ==*/
/*==                                                            ==*/
/*================================================================*/
<LinkedServerName>  链接服务器名
<ServerName>        要访问的服务器名。例如，对于SQL Server数据库而言是实例名，对于ORACLE数据库而言是SQL*Net别名
<UserName>          访问OLE DB数据源的用户名
<Password>          访问OLE DB数据源的用户密码
<DatabaseName>      要访问的数据库名
<Path>              访问外部数据文件时，数据文件所在的目录
<FileName>          访问外部数据文件时，数据文件的文件名
<系统DSN名称>        SQL Server服务器操作系统数据源（ODBC），【系统DSN】中创建的系统DSN
<ODBC驱动程序>       SQL Server服务器操作系统数据源（ODBC），【驱动程序】中列出的，当前操作系统安装的ODBC驱动程序名称


/*================================================================*/
/*==                                                            ==*/
/*==                  使用链接服务器访问OLE DB数据源              ==*/
/*==                                                            ==*/
/*================================================================*/
--SQL Server
EXEC sp_addlinkedserver 
	@server = '<LinkedServerName>',
	@provider='SQLOLEDB', 
	@datasrc='<ServerName>'
	
EXEC sp_addlinkedserver 
	@server = '<ServerName>'
	
EXEC sp_addlinkedserver 
	@server = '<LinkedServerName>', 
	@srvproduct = '',
	@provider = 'MSDASQL',
	@provstr = 'DRIVER={SQL Server};SERVER=<ServerName>;UID=<UserName>;PWD=<Password>;Database=<DatabaseName>'
	
--Oracle
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = 'Oracle',
	@provider = 'MSDAORA',
	@datasrc = '<ServerName>'
	
--Sybase
EXEC sp_addlinkedserver 
	@server = '<LinkedServerName>',
	@srvproduct = '', 
	@provider = 'MSDASQL', 
	@provstr = 'Driver={Sybase System 11};Database=<DatabaseName>;Srvr=<ServerName>;UID=<UserName>;PWD=<Password>;'
	
--ACCESS
EXEC sp_addlinkedserver 
	@server = '<LinkedServerName>', 
	@provider = 'Microsoft.Jet.OLEDB.4.0', 
	@srvproduct = 'OLE DB Provider for Jet',
	@datasrc = '<Path>\<FileName>',
	@provstr = ';pwd=<Password>'	
	
--Excel
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = 'Jet 4.0',
	@provider = 'MICROSOFT.JET.OLEDB.4.0',
	@datasrc = '<Path>\<FileName>',
	@provstr = 'Excel 8.0'
	
--Text
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = 'Jet 4.0',
	@provider = 'MICROSOFT.JET.OLEDB.4.0',
	@datasrc = '<Path>',
	@provstr = 'Text'
	
--dBase
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = 'Jet 4.0',
	@provider = 'MICROSOFT.JET.OLEDB.4.0',
	@datasrc = '<Path>',
	@provstr = 'dBase 5.0'
	
--Html
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = 'Jet 4.0',
	@provider = 'MICROSOFT.JET.OLEDB.4.0',
	@datasrc = '<Path>\<FileName>',
	@provstr = 'HTML Import'
	
--Paradox
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = 'Jet 4.0',
	@provider = 'MICROSOFT.JET.OLEDB.4.0',
	@datasrc = '<Path>',
	@provstr = 'Paradox 5.x'
	
--VFP
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = '',
	@provider='MSDASQL',
	@provstr='Driver={Microsoft Visual FoxPro Driver};SourceType=DBF;SourceDB=<Path>'

--ODBC系统DSN
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = '',
	@provider='MSDASQL',
	@datasrc='<系统DSN名称>'

--ODBC驱动程序(针对文件型数据库)
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = '',
	@provider='MSDASQL',
	@provstr='Driver={<ODBC驱动程序>};DefaultDir=<Path>|<Path>\<Filename>'

--ODBC驱动程序(针对服务型数据库)
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = '',
	@provider='MSDASQL',
	@provstr='Driver={<ODBC驱动程序>};Server=<ServerName>;UID=<UserName>;PWD=<Password>'


/*================================================================*/
/*==                                                            ==*/
/*==       使用OPENROWSET或者OPENDATASOURCE访问OLE DB数据源      ==*/
/*==                                                            ==*/
/*================================================================*/
--SQL Server
--使用SQL Server身份验证
OPENROWSET('SQLOLEDB','<ServerName>';'<UserName>';'<Password>',{[catalog.][schema.]object|'query'})
OPENROWSET('SQLOLEDB','ServerName=<ServerName;UID=<UserName>;PWD=<Password>;Database=<DatabaseName>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('SQLOLEDB','Data Source=<ServerName>;User ID=<UserName>;Password=<Password>;Database=<DatabaseName>')

--使用Windows身份验证
OPENROWSET('SQLOLEDB','ServerName=<ServerName;Trusted_Connection=YES;Database=<DatabaseName>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('SQLOLEDB','Data Source=<ServerName>;Integrated Security=SSPI;Database=<DatabaseName>')

--Sybase
OPENROWSET('MSDASQL','Driver={Sybase System 11};Srvr=<ServerName>;Database=<DatabaseName>;UID=<UserName>;PWD=<Password>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('MSDASQL','Driver={Sybase System 11};Srvr=<ServerName>;Database=<DatabaseName>;UID=<UserName>;PWD=<Password>')

--ACCESS
OPENROWSET('Microsoft.Jet.OLEDB.4.0','<Path>\<FileName>';'admin';'',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('Microsoft.Jet.OLEDB.4.0','Data Source="<Path>\<FileName>";Jet OLEDB:Database Password=<Password>')

--Excel
OPENROWSET('MICROSOFT.JET.OLEDB.4.0','Excel 8.0;DATABASE=<Path>\<FileName>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('MICROSOFT.JET.OLEDB.4.0','Excel 8.0;DATABASE=<Path>\<FileName>')

--Text
OPENROWSET('MICROSOFT.JET.OLEDB.4.0','Text;DATABASE=<Path>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('MICROSOFT.JET.OLEDB.4.0','Text;DATABASE=<Path>')

--dBase
OPENROWSET('MICROSOFT.JET.OLEDB.4.0','dBase 5.0;DATABASE=<Path>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('MICROSOFT.JET.OLEDB.4.0','dBase 5.0;DATABASE=<Path>')

--Html
OPENROWSET('MICROSOFT.JET.OLEDB.4.0','HTML Import;DATABASE=<Path>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('MICROSOFT.JET.OLEDB.4.0','HTML Import;DATABASE=<Path>')
	
--Paradox
OPENROWSET('MICROSOFT.JET.OLEDB.4.0','Paradox 5.x;DATABASE=<Path>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('MICROSOFT.JET.OLEDB.4.0','Paradox 5.x;DATABASE=<Path>')
	
--VFP
OPENROWSET('MSDASQL','Driver={Microsoft Visual FoxPro Driver};SourceType=DBF;SourceDB=<path>',{[catalog.][schema.]object|'query'})

--ODBC系统DSN
OPENROWSET('MSDASQL','<系统DSN名称>';'';'',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('MSDASQL','Driver={<系统DSN名称>};Server=')

--ODBC驱动程序(针对文件型数据库)
OPENROWSET('MSDASQL','Driver={<ODBC驱动程序>};DefaultDir=<Path>|<Path>\<Filename>','query')

--ODBC驱动程序(针对服务型数据库)
OPENDATASOURCE('MSDASQL','Driver={<ODBC驱动程序>};Server=<ServerName>;UID=<UserName>;PWD=<Password>')

exec opendatasource('SQLOLEDB','Data Source=192.168.0.5;User ID=iemis;Password=adminimis').YYZM.dbo.sp_executesql N'BEGIN TRAN  update iech27h set status=''Y'',oa_formid=''1369432'' where ch_apdoc=''H100700006'' update iech27h set ie_cymd=''2010/07/14'',ie_ctime=''08:13:29'' where status=''Y'' and ch_apdoc=''H100700006'' update YYZM.iemis.iech00h set status=''Y'' where ch_apdoc=''H100700006'' update YYZM.iemis.iech00h set oa_ymd=''2010/07/14'',oa_time=''08:13:29'' where status=''Y'' and ch_apdoc=''H100700006'' IF @@ERROR>0 ROLLBACK ELSE COMMIT '
