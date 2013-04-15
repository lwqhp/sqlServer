/*================================================================*/
/*==                                                            ==*/
/*==                         ģ��ؼ���˵��                     ==*/
/*==                                                            ==*/
/*================================================================*/
<LinkedServerName>  ���ӷ�������
<ServerName>        Ҫ���ʵķ������������磬����SQL Server���ݿ������ʵ����������ORACLE���ݿ������SQL*Net����
<UserName>          ����OLE DB����Դ���û���
<Password>          ����OLE DB����Դ���û�����
<DatabaseName>      Ҫ���ʵ����ݿ���
<Path>              �����ⲿ�����ļ�ʱ�������ļ����ڵ�Ŀ¼
<FileName>          �����ⲿ�����ļ�ʱ�������ļ����ļ���
<ϵͳDSN����>        SQL Server����������ϵͳ����Դ��ODBC������ϵͳDSN���д�����ϵͳDSN
<ODBC��������>       SQL Server����������ϵͳ����Դ��ODBC�����������������г��ģ���ǰ����ϵͳ��װ��ODBC������������


/*================================================================*/
/*==                                                            ==*/
/*==                  ʹ�����ӷ���������OLE DB����Դ              ==*/
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

--ODBCϵͳDSN
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = '',
	@provider='MSDASQL',
	@datasrc='<ϵͳDSN����>'

--ODBC��������(����ļ������ݿ�)
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = '',
	@provider='MSDASQL',
	@provstr='Driver={<ODBC��������>};DefaultDir=<Path>|<Path>\<Filename>'

--ODBC��������(��Է��������ݿ�)
EXEC sp_addlinkedserver
	@server = '<LinkedServerName>',
	@srvproduct = '',
	@provider='MSDASQL',
	@provstr='Driver={<ODBC��������>};Server=<ServerName>;UID=<UserName>;PWD=<Password>'


/*================================================================*/
/*==                                                            ==*/
/*==       ʹ��OPENROWSET����OPENDATASOURCE����OLE DB����Դ      ==*/
/*==                                                            ==*/
/*================================================================*/
--SQL Server
--ʹ��SQL Server�����֤
OPENROWSET('SQLOLEDB','<ServerName>';'<UserName>';'<Password>',{[catalog.][schema.]object|'query'})
OPENROWSET('SQLOLEDB','ServerName=<ServerName;UID=<UserName>;PWD=<Password>;Database=<DatabaseName>',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('SQLOLEDB','Data Source=<ServerName>;User ID=<UserName>;Password=<Password>;Database=<DatabaseName>')

--ʹ��Windows�����֤
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

--ODBCϵͳDSN
OPENROWSET('MSDASQL','<ϵͳDSN����>';'';'',{[catalog.][schema.]object|'query'})
OPENDATASOURCE('MSDASQL','Driver={<ϵͳDSN����>};Server=')

--ODBC��������(����ļ������ݿ�)
OPENROWSET('MSDASQL','Driver={<ODBC��������>};DefaultDir=<Path>|<Path>\<Filename>','query')

--ODBC��������(��Է��������ݿ�)
OPENDATASOURCE('MSDASQL','Driver={<ODBC��������>};Server=<ServerName>;UID=<UserName>;PWD=<Password>')

exec opendatasource('SQLOLEDB','Data Source=192.168.0.5;User ID=iemis;Password=adminimis').YYZM.dbo.sp_executesql N'BEGIN TRAN  update iech27h set status=''Y'',oa_formid=''1369432'' where ch_apdoc=''H100700006'' update iech27h set ie_cymd=''2010/07/14'',ie_ctime=''08:13:29'' where status=''Y'' and ch_apdoc=''H100700006'' update YYZM.iemis.iech00h set status=''Y'' where ch_apdoc=''H100700006'' update YYZM.iemis.iech00h set oa_ymd=''2010/07/14'',oa_time=''08:13:29'' where status=''Y'' and ch_apdoc=''H100700006'' IF @@ERROR>0 ROLLBACK ELSE COMMIT '
