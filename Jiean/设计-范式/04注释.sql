
/*
一.存储与函数需要在代码段前注释
二.存储与函数的参数定义后要跟注释
三.存储过程代码中复杂逻辑处用独立单行注释

*/
/* ==========================================================================================  
    描   述:  客户资料查询报表 
    创建人：  王朋帅  
    创建日期：2010-11-08  
    更新说明:   
    功能测试：  
    exec spBas_Rpt_CustomerInfo 'WS','',''    
	exec GetBasCustomerInfo 'CustStateCode in (''0028'',''0032'')','CustTypeCode in (''0027'',''0052'')'
-- ==========================================================================================*/      
CREATE  PROCEDURE [dbo].[spBas_Rpt_CustomerInfo] 
	@CompanyID varchar(20),			--公司名
    @CustState varchar(max),		--状态
    @CustType  varchar(max)			--类型
