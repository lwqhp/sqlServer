
/*  
 SQL Server 2005 ���뼸���µ�����(����)����,��ROW_NUMBER��RANK��DENSE_RANK�ȡ� 
 ��Щ�º���ʹ��������Ч�ط��������Լ����ѯ�Ľ�����ṩ����ֵ��  
  
 -------------------------------------------------------------------------- 
 ROW_NUMBER() 
  
 ˵�������ؽ�����������е����кţ�ÿ�������ĵ�һ�д� 1 ��ʼ�� 
 �﷨��ROW_NUMBER () OVER ( [  <partition_by_clause> ]  <order_by_clause> ) �� 
 ��ע��ORDER BY �Ӿ��ȷ�����ض�������Ϊ�з���Ψһ ROW_NUMBER ��˳�� 
 ������ <partition_by_clause> ���� FROM �Ӿ����ɵĽ��������Ӧ���� ROW_NUMBER �����ķ�����  
        <order_by_clause>��ȷ���� ROW_NUMBER ֵ����������е��е�˳�� 
 �������ͣ�bigint �� 
  
 ʾ���� 
 ����ʾ�������������������۶���� AdventureWorks ��������Ա�� ROW_NUMBER��*/ 
  
 USE AdventureWorks 
 GO 
 SELECT c.FirstName, c.LastName, ROW_NUMBER() OVER(ORDER BY SalesYTD DESC) AS 'Row Number', s.SalesYTD, a.PostalCode 
 FROM Sales.SalesPerson s JOIN Person.Contact c on s.SalesPersonID = c.ContactID 
 JOIN Person.Address a ON a.AddressID = c.ContactID 
 WHERE TerritoryID IS NOT NULL AND SalesYTD  <> 0 
 /* 
 FirstName  LastName    Row Number  SalesYTD      PostalCode 
 ---------  ----------  ----------  ------------  ---------------------------- 
 Shelley    Dyck        1           5200475.2313  98027 
 Gail       Erickson    2           5015682.3752  98055 
 Maciej     Dusza       3           4557045.0459  98027 
 Linda      Ecoffey     4           3857163.6332  98027 
 Mark       Erickson    5           3827950.238   98055 
 Terry      Eminhizer   6           3587378.4257  98055 
 Michael    Emanuel     7           3189356.2465  98055 
 Jauna      Elson       8           3018725.4858  98055 
 Carol      Elliott     9           2811012.7151  98027 
 Janeth     Esteves     10          2241204.0424  98055 
 Martha     Espinoza    11          1931620.1835  98055 
 Carla      Eldridge    12          1764938.9859  98027 
 Twanna     Evans       13          1758385.926   98055 
 (13 ����Ӱ��) 
 */ 
   
 /*����ʾ���������к�Ϊ 50 �� 60���������У����� OrderDate ����*/  
 USE AdventureWorks; 
 GO 
 WITH OrderedOrders AS 
 (SELECT SalesOrderID, OrderDate, 
 ROW_NUMBER() OVER (order by OrderDate)as RowNumber 
 FROM Sales.SalesOrderHeader )  
 SELECT *  
 FROM OrderedOrders  
 WHERE RowNumber between 50 and 60; 
 /* 
 SalesOrderID OrderDate               RowNumber 
 ------------ ----------------------- -------------------- 
 43708        2001-07-03 00:00:00.000 50 
 43709        2001-07-03 00:00:00.000 51 
 43710        2001-07-03 00:00:00.000 52 
 43711        2001-07-04 00:00:00.000 53 
 43712        2001-07-04 00:00:00.000 54 
 43713        2001-07-05 00:00:00.000 55 
 43714        2001-07-05 00:00:00.000 56 
 43715        2001-07-05 00:00:00.000 57 
 43716        2001-07-05 00:00:00.000 58 
 43717        2001-07-05 00:00:00.000 59 
 43718        2001-07-06 00:00:00.000 60 
 (11 ����Ӱ��) 
 */ 
  
 --------------------------------------------------------------
 
 --���󣺸��ݲ��ŷ��飬��ʾÿ�����ŵĹ�������
SELECT *, Row_Number() OVER (partition by deptid ORDER BY salary desc) rank FROM employee
