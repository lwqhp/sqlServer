

-- 编号表, 此表维护各类编号的规则及当前编号

create table Sys_MaxNum(
	CompanyID varchar(20),	--帐套
	ObjCode varchar(50),	--表名,模块
	MnMaxNum int ,			--当前最大值编号
	MnLen	INT ,			--流水号长度
	MnSetp TINYINT			--增加间隔
)
go

CREATE UNIQUE CLUSTERED  INDEX PK_Sys_MaxNum ON Sys_MaxNum(CompanyID,ObjCode)

INSERT INTO Sys_MaxNum
SELECT '00000000','Role',1,10,1 UNION ALL
SELECT '00000000','User',1,10,1 UNION ALL
SELECT 'PT','Role',1,4,1 UNION ALL
SELECT 'PT','User',1,4,1 
go

--创建取值存储过程

CREATE  PROC spSys_GetMaxNum(
	@CompanyID varchar(20),
	@objCode VARCHAR(50),
	@MaxID VARCHAR(20) OUTPUT
)
AS
BEGIN 
	SELECT  @MaxID=MnMaxNum FROM Sys_MaxNum WHERE companyID = @CompanyID AND objCode = @objCode
	IF @MaxID IS NULL
	BEGIN 
		INSERT INTO Sys_MaxNum
		SELECT @CompanyID,@objCode,1,4,1
		SET @MaxID =@CompanyID+RIGHT(POWER(10,4)+1,4)
	END
	ELSE 
	BEGIN 
		BEGIN TRAN
			UPDATE Sys_MaxNum with(rowlock) 
			SET  @MaxID =companyID+RIGHT(POWER(10,MnLen)+MnMaxNum+MnSetp,MnLen)
				,MnMaxNum = MnMaxNum+MnSetp
			WHERE companyID = @CompanyID AND objCode = @objCode
		COMMIT TRAN	 
	END
END
go
--SELECT * FROM Sys_MaxNum
--取最大值
DECLARE @NextId varchar(30)
EXEC spSys_GetMaxNum 'PT','user',@NextId OUTPUT
SELECT @NextId
--PT0005
go
--新增
DECLARE @NextId varchar(30)
EXEC spSys_GetMaxNum 'PT','shop',@NextId OUTPUT
SELECT @NextId
--PT0001
