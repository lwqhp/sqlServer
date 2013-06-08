

/*
第一式
*/

---------------处理参数值---------------------

--分割字符串形成临时表
 Create Table #CardTypeList (CardTypeID varchar(20) )	
	if IsNull(@CardTypeID,'') <> ''
	begin
		insert into #CardTypeList(CardTypeID) Select * From dbo.fnSys_SplitString(@CardTypeID,',')
	end
	else
		set @CardTypeID =Null;  
		
--提取小部份参与关联的数据存临时表		  	
 Select StateFixFlag, StateId, StateType,
  Into #TmpVIPOperState
    From Sys_State 
    Where StateFixFlag = 'VIPOperState'	