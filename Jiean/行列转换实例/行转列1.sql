/*	
ʵ����ת��
a
name	objec	score
a		EN		89
a		CH		78
a		HO		99
b		EN		34
b		CH		88
b		HO		66
Ҫ��������Ϊ��
name	EN	CH	HO
a		89	78	99
b		34	88	66
*/

USE tempdb
IF (SELECT 1 FROM sys.sysobjects WHERE name ='t' AND type='u') is NOT NULL 
DROP TABLE t


CREATE TABLE t
(
	NAME	CHAR(10),
	objec	CHAR(10),
	score	FLOAT
)
INSERT INTO t
VALUES('a','EN',89),('a','CH',78),('a','HO',99),('b','EN',34),('b','CH',88),('b','HO',66)

SELECT * FROM T

SELECT NAME ,MAX(CASE objec WHEN 'EN' THEN score ELSE 0 END ) EN,MAX(CASE objec WHEN 'CH' THEN score ELSE 0 END ) CH,MAX(CASE objec WHEN 'HO' THEN score ELSE 0 END ) HO
FROM t
GROUP BY NAME 
--=======================================================================================================================================================
/*	
ʵ����ת��
a
name	objec	score
a		EN		89
a		CH		78
a		HO		99
b		EN		34
b		CH		88
b		HO		66
Ҫ��������Ϊ��
name	objec		totalsorce
a		EN,CH,HO	266
b		EN,CH,HO	188
*/

USE tempdb
IF (SELECT 1 FROM sys.sysobjects WHERE name ='t' AND type='u') is NOT NULL 
DROP TABLE t

CREATE TABLE t
(
	NAME	CHAR(10),
	objec	CHAR(10),
	score	FLOAT
)
INSERT INTO t
VALUES('a','EN',89),('a','CH',78),('a','HO',99),('b','EN',34),('b','CH',88),('b','HO',66)

SELECT * FROM T

--Ϊ��ȥ��objec�е����һ�����ţ�����һ����ʱ����ʹ��substring����
SELECT name ,(SELECT LTRIM(RTRIM(objec))+',' FROM T WHERE objec=t.objec FOR XML PATH('')) objec,SUM(temp.score) totalscroe INTO #tmp
FROM T temp
GROUP BY name 


SELECT NAME ,SUBSTRING(objec,0,LEN(objec)-1) objec ,totalscroe
FROM #tmp
