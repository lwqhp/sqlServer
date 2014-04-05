
    sp_configure 'show advanced options', 1;  
    GO  
    RECONFIGURE;  
    GO  
      
    sp_configure 'Ad Hoc Distributed Queries', 1;  
    GO  
    RECONFIGURE;  
    GO  
      
    EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1  
    GO  
      
    EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1  
    GO  
/*
错误：无法初始化链接服务器 "(null)" 的 OLE DB 访问接口 "Microsoft.Jet.OLEDB.4.0" 的数据源对象。
解决：数据库->服务器对象>链接服务器>访问接口>Microsoft.Jet.OleDB.4.0>属性，去掉所有勾

错误：链接服务器 "(null)" 的 OLE DB 访问接口 "Microsoft.Jet.OLEDB.4.0" 报错。访问被拒绝。
解决：MSSQL服务使用本地登陆
*/

INSERT INTO sal_promotionshop
SELECT *
FROM OPENDATASOURCE('Microsoft.Jet.OLEDB.4.0', 'Data Source="D:\DXDb\base\sal_promotionshop.XLS"; User ID=Admin;Password=;Extended properties=Excel 5.0')...[sheet1$]
