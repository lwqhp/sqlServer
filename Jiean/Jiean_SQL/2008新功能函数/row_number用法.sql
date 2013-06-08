
/*  
 SQL Server 2005 引入几个新的排序(排名)函数,如ROW_NUMBER、RANK、DENSE_RANK等。 
 这些新函数使您可以有效地分析数据以及向查询的结果行提供排序值。  
  
 -------------------------------------------------------------------------- 
 ROW_NUMBER() 
  
 说明：返回结果集分区内行的序列号，每个分区的第一行从 1 开始。 
 语法：ROW_NUMBER () OVER ( [  <partition_by_clause> ]  <order_by_clause> ) 。 
 备注：ORDER BY 子句可确定在特定分区中为行分配唯一 ROW_NUMBER 的顺序。 
 参数： <partition_by_clause> ：将 FROM 子句生成的结果集划入应用了 ROW_NUMBER 函数的分区。  
        <order_by_clause>：确定将 ROW_NUMBER 值分配给分区中的行的顺序。 
 返回类型：bigint 。 
  
 示例： 
 以下示例将根据年初至今的销售额，返回 AdventureWorks 中销售人员的 ROW_NUMBER。*/ 
  
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
 (13 行受影响) 
 */ 
   
 /*以下示例将返回行号为 50 到 60（含）的行，并以 OrderDate 排序。*/  
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
 (11 行受影响) 
 */ 
  
 --------------------------------------------------------------
 
 --需求：根据部门分组，显示每个部门的工资排序
SELECT *, Row_Number() OVER (partition by deptid ORDER BY salary desc) rank FROM employee
