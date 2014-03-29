
/*
�������б����ֵ���������ϵ������һ��Դ��ĵ������ݼ���

Դ���е�����ֵ�ķ�Χ���������б�cross joinʱҪ�������ж�
id	shopName	cardtype	startCard	endCard	preCard	digit
1	G080		�ŵϰ���	8801456		8801466			7
2	G080		�ŵϰ���	8801601		8801620			7

--������
1	G080	�ŵϰ���	8801463
1	G080	�ŵϰ���	8801464
1	G080	�ŵϰ���	8801465
1	G080	�ŵϰ���	8801466

2	G080	�ŵϰ���	8801601
2	G080	�ŵϰ���	8801602
2	G080	�ŵϰ���	8801603


*/

--��Ų���--˫��
--drop table #cardCode
IF object_id('tempdb.dbo.#cardCode') IS NOT NULL DROP TABLE #cardCode
create table #cardCode(
	shopName varchar(50),
	cardtype varchar(50),
	cardCode varchar(100)
)
go
insert into #cardCode
select 'G080','�ŵϰ���','8801456����8801466' UNION ALL
select 'G080','�ŵϰ���','8801601����8801620' 


--ͳһ�ָ���
update #cardCode set cardCode= replace(cardCode,'��','-')
--select * from #cardCode

--ȥ����˾����
;with tmp as(
	select shopName,cardtype,
	startCard=left(cardCode,charindex('-',cardCode+'-')-1),
	endCard =right(cardCode,charindex('-',reverse('-'+cardCode))-1)
	from #cardCode
)
select  identity(int,1,1) as id,shopName,cardtype,
startCard=stuff(startCard,1,patindex('%[0-9]%',startCard)-1,''),
endCard =stuff(endCard,1, patindex('%[0-9]%',endCard)-1,''),
preCard = left(startCard,patindex('%[0-9]%',startCard)-1),
digit = len(stuff(endCard,1, patindex('%[0-9]%',endCard)-1,''))
into #
from tmp

--select * from #

select id,shopName,cardtype, 
	newcard= case when len(startCard+number)<digit
					then preCard+right(replicate('0',digit)+cast(startCard+number as varchar),digit)
					else preCard+cast(startCard+number as varchar)
					end 
	from #,master..spt_values where type = 'P' and startCard+number<=endCard


