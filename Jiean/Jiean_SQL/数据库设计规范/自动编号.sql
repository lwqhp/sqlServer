
/*�Զ��������

��ṹ�ӱ��������ʼ
�ڱ��������ֳ� ������ϵͳ�����ܣ�������,�����õ���
sys_ϵͳ���� sys_user,_modul,_version
SD_��ϵͳ��_Bas_��������_���ܺ͹������ã����ܵ��ʺ���չ��ʾ 
	   _Mat_��Ʒ��*/

--���´������ɵı�ų���Ϊ12��ǰ6λΪ������Ϣ����ʽΪYYMMDD����6λΪ��ˮ�š�
--�����õ���ǰ���ڵ���ͼ
CREATE VIEW v_GetDate
AS
SELECT dt=CONVERT(CHAR(6),GETDATE(),12)
GO

--�õ��±�ŵĺ���
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

--�ڱ���Ӧ�ú���
CREATE TABLE tb(
BH char(12) PRIMARY KEY DEFAULT dbo.f_NextBH(),
col int)

SELECT * FROM tb

--��������
INSERT tb(col) VALUES(1)
INSERT tb(col) VALUES(2)
INSERT tb(col) VALUES(3)
DELETE tb WHERE col=3
INSERT tb(col) VALUES(4)
INSERT tb(BH,col) VALUES(dbo.f_NextBH(),14)



-----------------------------------
	--��ѯselect���ɱ��
	SELECT 'BYL'+RIGHT(10000000+ROW_NUMBER() OVER(ORDER BY col)+212,7) AS a  FROM TB
----------------------------------------------------------------


--������ˮ��

--�������Ա�
create table test(id varchar(18),  --��ˮ��,����(8λ)+ʱ��(4λ)+��ˮ��(4λ)
    name varchar(10)  --�����ֶ�
)


go
--����������ˮ�ŵĴ�����
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


--��������,���в���
insert into test(name)
select 'aa'
union all select 'bb'
union all select 'cc'


--�޸�ϵͳʱ��,�ٲ������ݲ���һ��
insert into test(name)
select 'aa'
union all select 'bb'
union all select 'cc'

SELECT * FROM test



--�������ݺŻ�ȡ��ʽ
CREATE PROC Get_BillNo
    (
      @Bill_type VARCHAR(10) ,
      @Shop_Code VARCHAR(10) ,
      @BillNo VARCHAR(20) OUTPUT
    )
AS 
    BEGIN
        SELECT  @Billno = Bill_Code + --���ݴ���
                CONVERT(CHAR(6), GETDATE(), 12) + --��������
                '-' + @Shop_Code + '-' + --���̴���
                RIGHT('0000' + CONVERT(VARCHAR(5), CNT), 4)  --����
        FROM    Sys_BillType
        WHERE   Bill_type = @Bill_type
 
        UPDATE  Sys_BillType
        SET     cnt = cnt % 9999 + 1
        WHERE   Bill_type = @Bill_type
 --Smallint 32767
    END
/*ʾ��:*/
    SET STATISTICS TIME ON
    SET STATISTICS IO ON
 go
DECLARE @billno VARCHAR(25)
EXEC Get_BillNo 'POS', 'G00002', @billno OUTPUT
SELECT  @billno
 ---ԭ������ģʽ
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
