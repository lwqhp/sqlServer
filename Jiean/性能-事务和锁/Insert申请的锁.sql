

--Insert ����Ҫ�������

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
�ܽ᣺
1�����ݿ����й�����
2������������������
3��ÿ�������϶�Ҫ����һ�������ݣ���������Key��������������
4����ÿ�������Ϸ����仯���Ǹ�ҳ�棬������һ��������������
��ͬ���ǣ���heap�ṹ�ϻ�������һ��RID������Ϊ���������ݲ��Ƿ��������ϣ����Ƿ���heap�ϵġ�
*/