
--д���淶���Ӳ�ѯ������������

--��ѯ�����ı�����Ҫ��ʾ���ֶ���
Select * From Production.Location                           
Select LocationID,Name,CostRate,Availability,ModifiedDate
From Production.Location                                    

Insert Into Production.Location
Values(40,'Paint',15,120,'2007-06-01')

Insert Into Production.Location( LocationID,Name,CostRate
                                 ,Availability,ModifiedDate)
Values(40,'Paint',15,120,'2007-06-01')                      


--ʹ��TRY��CATCH���ֿ������̵ĳ���ʽ��T-SQL��ִ�д�����Ĺ���
Create Procedure dbo.AddData 
  @a int, 
  @b int
As
Begin Try
  Begin Tran
  Insert Into dbo.TableNoKey Values (@a, @b)
  Insert Into dbo.TableWithKey Values (@a, @b)
  Commit Tran
End Try
Begin Catch
  Rollback Tran
  Select Error_Number() ErrorNumber, Error_Message() [Message]
End Catch


--SQL�������������ʱ����������JOIN�ķ�ʽ���ӣ����ñ������
Select Production.Product.Name,Production.Location.Name,
       Production.ProductInventory.Quantity 
From Production.ProductInventory ,Production.Product,Production.Location
Where Production.ProductInventory.ProductID = Production.Product.ProductID
      And Production.ProductInventory.LocationID = Production.Location.LocationID
                                                                               ��
Select b.Name,c.Name,a.Quantity 
From Production.ProductInventory a
     Inner Join Production.Product b On a.ProductID = b.ProductID
     Inner Join Production.Location c On a.LocationID = c.LocationID

--�����������ӷ�ʽ������ͼ��ʽʵ�ֵĹ��ܣ���Ҫ���Ӳ�ѯ 
Select name 
From customer 
Where customer_id In ( Select customer_id From order Where money>1000)
                                                                       ��
Select name 
From customer a 
     Inner Join order b On a.customer_id=b.customer_id 
Where b.money>100 


--��һ���ǳ����ӵ�����������ѯ��������������� or �Ŀ��Կ����滻�� union all �Ӿ� 

--���������ֶ���Ϊ��ѯ�����������Ǿ۴�����,Ч�ʸ��ߡ����Ҫ�õ���������,������ڲ�ѯ�����а����������еĵ�һ��
--���� Where  firstname = ���š� �þ����õ�����

--     ����һ ( firstname, lastname )     
--     ������ ( lastname, firstname ) ����

--�������ø����ѯ���� not��!=��<>��!>��!<��not exists��not in �Լ� not like ,���ǲ����õ������� 

--��not in���һ���Ӳ�ѯ���ʱ��ͳһ���ù����������ķ�ʽ������ 
  --ĳ�ֶ�	is null


--��������������  
--Or      ���������ֶζ�Ҫ��ͬһ����������������õ�����
/*���� Where  firstname = ���š� Or lastname = ������
 �þ����õ�����
     ����һ( firstname)     

     ������( lastname)

     ������( firstname, lastname )  �õ� 
     
  Like    ͨ����������ַ���ǰ�治���õ�����
     ��: ����(Lastname)
      Where  Lastname Like ��D%��    ���õ����� 
��
      Where  Lastname Like ��%D��   �����õ�����    
     */
     
--��������where�Ӿ��еġ�=������ֶ��н��к���������������������ʽ����, ��Ϊ�����ò������� 
--���� Where  Substring(firstname,1,2) = ��˾��

--Ϊ��߲�ѯ��Ч�ʣ���ѯ·�������Ż�,�����ù��������ٵ���ͼ, �����ٵĲ�ѯǶ��

--�����ܲ�ʹ���α꣬���ǲ����α��������߼����临�ӻ�Ч�ʸ��ӵ��� 

--�½���ʱ��ʹ�� select into �� create table����Ч�� 
 Select AreaCode,AreaName Into #temptable From Pub_Area

     Create table #temptable 
     Insert Into #temptable Select AreaCode,AreaName From Pub_Area
     
--��ʱ����ʹ�����Ҫ��ʱ������ʽɾ�������ⳤʱ��ռ�ý�����Դ

--������ʱ���ϼ��ϣ����������������������������򴴽���ʱ��ǰ�߱Ⱥ��߸�Ч
     @temptable  �����         #temptable ��ʱ��

--�������ⷴ������ͬһ�Ż��ű�ʹ����ͬ�ļ����������������Ǽ�¼�����ܶ�ı�������������ȸ���������ȡ����Ҫ�����ݵ���ʱ��Ȼ����������

--�����жϱ����Ƿ���ڼ�¼��exists �� select count(1) ����Ч��

--�洢�����а���һ���Ĵ�����������ı����������ס��A������ס��B����ô�����еĴ洢���������˳�����������ǣ������ܽ��������ķ���

--��������ѯ, SQL�����ִ��ǰ���Ƚ�������õ��Ż����ִ�мƻ��������������ơ������ǲ�����ͬ��SQL��䣬SQL Server�������ø�ִ�мƻ���
Declare @i Int, @count Int, @sql Nvarchar(4000)
Set @i = 150000
While @i <= 160000
Begin
    Set @sql ='Select @count=count(*) From Production.TransactionHistory 
                      Where transactionid = @i'
    Exec sp_executesql @sql, N'@count int Output, @i int', @count Output, @i
--    Set @sql = 'Select @count=count(*) From Production.TransactionHistory 
--                       Where transactionid = ' + cast( @i as varchar(10) )
--    Exec sp_executesql @sql ,N'@count INT Output', @count Output
    Set @i = @i + 1
END

--CTE (���ñ���ʽ ) Ϊ��ʱ������������洢Ϊ���󣬲���ֻ�ڲ�ѯ�ڼ���Ч������ͬһ��ѯ�����ö��
With EmpHierarchy (EmpID, MgrID, EmpLevel)
As(Select EmployeeID, ManagerID, 0 As EmpLevel
  From HumanResources.Employee
  Where ManagerID Is Null
  Union All
  Select e.EmployeeID, e.ManagerID, EmpLevel + 1
  From HumanResources.Employee As e
  Inner Join EmpHierarchy As d  On e.ManagerID = d.EmpID)

Select MgrID, Count(EmpID) As EmpTotal, EmpLevel
From EmpHierarchy
Where MgrID Is Not Null
Group By MgrID, EmpLevel
Order By EmpLevel, MgrID;


--�����������ݿ��ж�̬����ʵ����ͼ��ʵ�����ͼ�������洢���̣����������ݿ���� 

--ͬһ�����ֶλ�������������ⶨ��ɲ�ͬ���ͣ������ʽ������������ת����������Դ������������where�Ӿ���numeric �ͺ�int�͵��еıȽ� 
Declare  @n numeric(10,2)
     Declare @t table(id int)

     Where id=@n

--. Null ��  �մ� ��������ͬ����������, ת������ isnull(var,����) 

---��ͼ��Բ�ѯ������������Ӱ������ͼ��ʾ������������Զ���ʾ���������Ҫ������ͼ���档��SQLServer2005���ԣ�

Create View v_Area
As
  Select Top 100 Percent Code,AreaName 
  From Pub_Area
  Order by Code
Go
Select * From v_Area                        --������
Select * From v_Area Order By Code          --������



