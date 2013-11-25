
--写法规范，子查询，条件索引等

--查询或插入的表名后要标示出字段名
Select * From Production.Location                           
Select LocationID,Name,CostRate,Availability,ModifiedDate
From Production.Location                                    

Insert Into Production.Location
Values(40,'Paint',15,120,'2007-06-01')

Insert Into Production.Location( LocationID,Name,CostRate
                                 ,Availability,ModifiedDate)
Values(40,'Paint',15,120,'2007-06-01')                      


--使用TRY与CATCH这种控制流程的陈述式在T-SQL中执行错误检查的工作
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


--SQL语句包含多表连接时，关联表用JOIN的方式连接，且用别名替代
Select Production.Product.Name,Production.Location.Name,
       Production.ProductInventory.Quantity 
From Production.ProductInventory ,Production.Product,Production.Location
Where Production.ProductInventory.ProductID = Production.Product.ProductID
      And Production.ProductInventory.LocationID = Production.Location.LocationID
                                                                               ×
Select b.Name,c.Name,a.Quantity 
From Production.ProductInventory a
     Inner Join Production.Product b On a.ProductID = b.ProductID
     Inner Join Production.Location c On a.LocationID = c.LocationID

--对于能用连接方式或者视图方式实现的功能，不要用子查询 
Select name 
From customer 
Where customer_id In ( Select customer_id From order Where money>1000)
                                                                       ×
Select name 
From customer a 
     Inner Join order b On a.customer_id=b.customer_id 
Where b.money>100 


--在一个非常复杂的条件关联查询语句里，如果存在条件 or 的可以考虑替换成 union all 子句 

--多用索引字段作为查询条件，尤其是聚簇索引,效率更高。如果要用到复合索引,则必须在查询条件中包含该索引中的第一列
--例： Where  firstname = ‘张’ 该句能用到索引

--     索引一 ( firstname, lastname )     
--     索引二 ( lastname, firstname ) 不行

--尽量少用负向查询，如 not、!=、<>、!>、!<、not exists、not in 以及 not like ,它们不能用到索引　 

--当not in后接一个子查询语句时，统一改用关联加条件的方式来处理。 
  --某字段	is null


--半参照索引运算符  
--Or      条件所有字段都要在同一个复合索引里才能用到索引
/*例： Where  firstname = ‘张’ Or lastname = ‘三’
 该句能用到索引
     索引一( firstname)     

     索引二( lastname)

     索引三( firstname, lastname )  用到 
     
  Like    通配符出现在字符串前面不能用到索引
     例: 索引(Lastname)
      Where  Lastname Like ‘D%’    能用到索引 
√
      Where  Lastname Like ‘%D’   不能用到索引    
     */
     
--尽量少在where子句中的“=”左边字段列进行函数、算术运算或其他表达式运算, 因为这样用不到索引 
--例： Where  Substring(firstname,1,2) = ‘司马’

--为提高查询的效率，查询路径尽量优化,比如用关联表最少的视图, 用最少的查询嵌套

--尽可能不使用游标，除非不用游标其语义逻辑极其复杂或效率更加低下 

--新建临时表，使用 select into 比 create table更有效率 
 Select AreaCode,AreaName Into #temptable From Pub_Area

     Create table #temptable 
     Insert Into #temptable Select AreaCode,AreaName From Pub_Area
     
--临时表在使用完后要及时对其显式删除，避免长时间占用进程资源

--操作临时资料集合，数据量少则定义表变量，数据量大则创建临时表，前者比后者高效
     @temptable  表变量         #temptable 临时表

--尽量避免反复检索同一张或几张表（使用相同的检索条件），尤其是记录笔数很多的表，这种情况可以先根据条件提取所需要的数据到临时表，然后再做关联

--用来判断表中是否存在记录，exists 比 select count(1) 更有效率

--存储过程中按照一定的次序来访问你的表。如果你先锁住表A，再锁住表B，那么在所有的存储都按照这个顺序来锁定它们，这样能降低死锁的发生

--参数化查询, SQL语句在执行前首先将被编译得到优化后的执行计划，对于整体相似、仅仅是参数不同的SQL语句，SQL Server可以重用该执行计划。
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

--CTE (公用表表达式 ) 为临时结果集，它不存储为对象，并且只在查询期间有效，可在同一查询中引用多次
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


--不允许在数据库中动态创建实表，视图，实表或视图索引，存储过程，函数等数据库对象 

--同一含义字段或变量、尽量避免定义成不同类型，造成显式或隐含的类型转换带来的资源开销。例如在where子句中numeric 型和int型的列的比较 
Declare  @n numeric(10,2)
     Declare @t table(id int)

     Where id=@n

--. Null 与  空串 ’’不相同，不可替用, 转换则用 isnull(var,’’) 

---视图里对查询集进行排序不能影响其视图显示结果的排序，所以对显示结果集排序要放在视图外面。（SQLServer2005特性）

Create View v_Area
As
  Select Top 100 Percent Code,AreaName 
  From Pub_Area
  Order by Code
Go
Select * From v_Area                        --无排序
Select * From v_Area Order By Code          --有排序



