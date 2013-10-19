

--Insert 动作要申请的锁

SET TRAN ISOLATION LEVEL REPEATABLE READ
GO

BEGIN TRAN 
INSERT INTO dbo.Employee_Demo_Heap
        ( NationalIDNumber ,
          ContactID ,
          LoginID ,
          ManagerID ,
          Title ,
          BirthDate ,
          MaritalStatus ,
          Gender ,
          HireDate ,
          ModifiedDate
        )
VALUES  ( N'501' , -- NationalIDNumber - nvarchar(15)
          480168528 , -- ContactID - int
          N'1009' , -- LoginID - nvarchar(256)
          1009 , -- ManagerID - int
          N'd' , -- Title - nvarchar(50)
          '2013-10-16 15:29:43' , -- BirthDate - datetime
          N'd' , -- MaritalStatus - nchar(1)
          N'd' , -- Gender - nchar(1)
          '2013-10-16 15:29:43' , -- HireDate - datetime
          '2013-10-16 15:29:43'  -- ModifiedDate - datetime
        )
        
  ROLLBACK TRAN 
  
  BEGIN TRAN 
  INSERT INTO dbo.employee_demo_Btree
          ( NationalIDNumber ,
            ContactID ,
            LoginID ,
            ManagerID ,
            Title ,
            BirthDate ,
            MaritalStatus ,
            Gender ,
            HireDate ,
            ModifiedDate
          )
  VALUES  ( N'd' , -- NationalIDNumber - nvarchar(15)
            23 , -- ContactID - int
            N'33' , -- LoginID - nvarchar(256)
            333 , -- ManagerID - int
            N'34' , -- Title - nvarchar(50)
            '2013-10-16 15:32:10' , -- BirthDate - datetime
            N'1' , -- MaritalStatus - nchar(1)
            N'd' , -- Gender - nchar(1)
            '2013-10-16 15:32:10' , -- HireDate - datetime
            '2013-10-16 15:32:10'  -- ModifiedDate - datetime
          )
          
          
/*
总结：
1，数据库上有共享锁
2，表上有意向排它锁
3，每个索引上都要插入一条新数据，所以所有Key上有排它锁。、
4，在每个索引上发生变化的那个页面，申请了一个意向排它锁。
不同的是，在heap结构上还得申请一个RID锁，因为真正的数据不是放在索引上，而是放在heap上的。
*/