
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
�����޷���ʼ�����ӷ����� "(null)" �� OLE DB ���ʽӿ� "Microsoft.Jet.OLEDB.4.0" ������Դ����
��������ݿ�->����������>���ӷ�����>���ʽӿ�>Microsoft.Jet.OleDB.4.0>���ԣ�ȥ�����й�

�������ӷ����� "(null)" �� OLE DB ���ʽӿ� "Microsoft.Jet.OLEDB.4.0" �������ʱ��ܾ���
�����MSSQL����ʹ�ñ��ص�½
*/

INSERT INTO sal_promotionshop
SELECT *
FROM OPENDATASOURCE('Microsoft.Jet.OLEDB.4.0', 'Data Source="D:\DXDb\base\sal_promotionshop.XLS"; User ID=Admin;Password=;Extended properties=Excel 5.0')...[sheet1$]
