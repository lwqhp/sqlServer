?SQL高度依赖网络连通性，如果没有网卡的服务器上安装它，可以先安装loopbackAdapter来“模拟”网络适配器，在win95/98上安装，必须首先安装microsoft网络用户。
?sql版本：企业版，标准版，个人版
?4.2 , 6.5 , 7.0 , 2000
?安装：1,日志，2,测试安装isql || \x86\setup\setupsql.exe k=dbg 3,启用sqlserver的帐号：本机系统帐号不能访问网络外的任务，如数据库复制，可创建域帐号
?切底删除数据库 默认不删用户定义的数据库和日志文件的相关目录。 80\tool \msmsl 注册表：h_L_M\software\microsoft\mssql_server 和microsoft sqlServer 
?升级：了解升级环境－安装需求,chkupg.exe检查数据库状态。－－验证数据，－－删除原数据库
