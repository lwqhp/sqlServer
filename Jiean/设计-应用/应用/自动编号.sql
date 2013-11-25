
/*自动编号生成

表结构从表的命名开始
在表名上区分出 级别，子系统，表功能，关联表,单词用单数
sys_系统参数 sys_user,_modul,_version
SD_子系统名_Bas_基础资料_表功能和关联表用：功能单词和扩展表示 
	   _Mat_货品类*/

--以下代码生成的编号长度为12，前6位为日期信息，格式为YYMMDD，后6位为流水号。
--创建得到当前日期的视图
CREATE VIEW v_GetDate
AS
SELECT dt=CONVERT(CHAR(6),GETDATE(),12)
GO

--得到新编号的函数
CREATE FUNCTION f_NextBH()
RETURNS char(12)
AS
BEGIN
    DECLARE @dt CHAR(6)
    SELECT @dt=dt FROM v_GetDate
    RETURN(
        SELECT  @dt
                + SUBSTRING(CAST(1000001
                            + ISNULL(MAX(CAST(RIGHT(RTRIM(BH), 6) AS INT)), 0) AS VARCHAR(7)),
                            2, 6) 
        FROM tb WITH(XLOCK,PAGLOCK)
        WHERE BH like @dt+'%')
    --RETURN(SELECT 'BH'+RIGHT(1000001+ISNULL(RIGHT(MAX(BH),6),0),6) FROM tb WITH(XLOCK,PAGLOCK))
END
GO

--在表中应用函数
CREATE TABLE tb(
BH char(12) PRIMARY KEY DEFAULT dbo.f_NextBH(),
col int)

SELECT * FROM tb

--插入资料
INSERT tb(col) VALUES(1)
INSERT tb(col) VALUES(2)
INSERT tb(col) VALUES(3)
DELETE tb WHERE col=3
INSERT tb(col) VALUES(4)
INSERT tb(BH,col) VALUES(dbo.f_NextBH(),14)



-----------------------------------
	--查询select生成编号
	SELECT 'BYL'+RIGHT(10000000+ROW_NUMBER() OVER(ORDER BY col)+212,7) AS a  FROM TB
----------------------------------------------------------------


--生成流水号

--创建测试表
create table test(id varchar(18),  --流水号,日期(8位)+时间(4位)+流水号(4位)
    name varchar(10)  --其他字段
)


go
--创建生成流水号的触发器
create trigger t_insert on test
INSTEAD OF insert
as
declare @id varchar(18),@id1 int,@head varchar(12)
select * into #tb from inserted
set @head=convert(varchar,getdate(),112)+replace(convert(varchar(5),getdate(),108),':','')
select @id=max(id) from test where id like @head+'%'
if @id is null
    set @id1=0
else
    set @id1=cast(substring(@id,13,4) as int)
update #tb set @id1=@id1+1
    ,id=@head+right('0000'+cast(@id1 as varchar),4)
insert into test select * from #tb
go


--插入数据,进行测试
insert into test(name)
select 'aa'
union all select 'bb'
union all select 'cc'


--修改系统时间,再插入数据测试一次
insert into test(name)
select 'aa'
union all select 'bb'
union all select 'cc'

SELECT * FROM test



--新增单据号获取方式
CREATE PROC Get_BillNo
    (
      @Bill_type VARCHAR(10) ,
      @Shop_Code VARCHAR(10) ,
      @BillNo VARCHAR(20) OUTPUT
    )
AS 
    BEGIN
        SELECT  @Billno = Bill_Code + --单据代码
                CONVERT(CHAR(6), GETDATE(), 12) + --开单日期
                '-' + @Shop_Code + '-' + --店铺代码
                RIGHT('0000' + CONVERT(VARCHAR(5), CNT), 4)  --增量
        FROM    Sys_BillType
        WHERE   Bill_type = @Bill_type
 
        UPDATE  Sys_BillType
        SET     cnt = cnt % 9999 + 1
        WHERE   Bill_type = @Bill_type
 --Smallint 32767
    END
/*示例:*/
    SET STATISTICS TIME ON
    SET STATISTICS IO ON
 go
DECLARE @billno VARCHAR(25)
EXEC Get_BillNo 'POS', 'G00002', @billno OUTPUT
SELECT  @billno
 ---原有生成模式
SELECT  MAX(RIGHT(billno, 4))
FROM    Pos_Salemaster
WHERE   BillNo LIKE 'OS071201-G00002%' 
 --select top 10 * from dbo.Pos_Salemaster
--select top 10 * from dbo.Inv_MoveMaster
--select top 10 * from dbo.Inv_TransMaster
--select top 10 * from dbo.Sal_OrderMaster
--drop table Sys_BillType;
--drop proc Get_BillNo
--truncate table Sys_BillType
