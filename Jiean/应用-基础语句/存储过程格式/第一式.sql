

/*
��һʽ
*/

---------------�������ֵ---------------------

--�ָ��ַ����γ���ʱ��
 Create Table #CardTypeList (CardTypeID varchar(20) )	
	if IsNull(@CardTypeID,'') <> ''
	begin
		insert into #CardTypeList(CardTypeID) Select * From dbo.fnSys_SplitString(@CardTypeID,',')
	end
	else
		set @CardTypeID =Null;  
		
--��ȡС���ݲ�����������ݴ���ʱ��		  	
 Select StateFixFlag, StateId, StateType,
  Into #TmpVIPOperState
    From Sys_State 
    Where StateFixFlag = 'VIPOperState'	