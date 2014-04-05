

--ȫ������
/*
���ǻ����ַ��Ͷ��������ݵ����ܵ��ʣ������������ִ��Ч�ʱ���ͨ��like��ѯ�úܶ�


--ȫ������

����ͨ��B���ۼ�������Ǿۼ�������ͬ���ǣ�ȫ�����������ı����ݵ����������ɵ�ѹ���������ṹ�������sql2008
�����������б�ʶ�ĵ��ʻ��ַ���


--ȫ��Ŀ¼

���Բ�����ȫ��������Ҳ���԰����������ȵ�ȫ������
*/

--����ȫ��Ŀ¼
CREATE FULLTEXT CATALOG cat_producttion_document --����һ��ȫ��Ŀ¼
CREATE FULLTEXT CATALOG cat_production_document_ex2 WITH accent_sensitivity=ON --����һ������������ȫ��Ŀ¼
/*
һ��ȫ��Ŀ¼ֻ������һ�����ݿ�
ȫ��Ŀ¼���������ۺ�һ�������ȫ��������ʵ���߼�ʵ�壬ȫ��Ŀ¼�����󣬿����������洴��ȫ������
*/

--����ȫ������
CREATE FULLTEXT INDEX ON production.Document --��
(DocumentSummary,Document TYPE COLUMN fileextension) --�У�type olumnָ��������ָ�룬����sqlserver���ʹ洢������
KEY INDEX PK_document_documentNode --��ʶ������ķǿ�Ψһ�У�������
ON cat_production_document -- ָ��ȫ������Ҫ�洢��ȫ��Ŀ¼
WITH change_tracking AUTO,STOPLIST=SYSTEM --��䷽ʽ��ʹ��ϵͳĬ�Ϸ������ֱ�

--�޸�ȫ��Ŀ¼

ALTER FULLTEXT CATALOG cat_production_document
REORGANIZE -- �Ż�ȫ��Ŀ¼

ALTER FULLTEXT CATALOG cat_production_document
AS DEFAULT --����Ϊ���ݿ��Ĭ��ȫ��Ŀ¼

ALTER FULLTEXT CATALOG cat_production_document
REBUILD WITH accent_sensitivity = OFF --�ؽ�һ�����÷�������ȫ��Ŀ¼�����е�ȫ������

--�޸�ȫ������

ALTER FULLTEXT INDEX ON Production.Document
ADD (Title)--����һ���µ��е����ȫ��������

ALTER FULLTEXT INDEX ON production.Document
START FULL POPULATION --����һ��ȫ������������

ALTER FULLTEXT INDEX ON production.Document
SET CHANGE_TRACKING OFF 

ALTER FULLTEXT INDEX ON production.Document 
DROP (Title) --���д�ȫ��������ɾ��


--�鿴ȫ��Ŀ¼��������Ϣ
SELECT * FROM sys.fulltext_catalogs

SELECT * FROM sys.fulltext_indexes

SELECT * FROM sys.fulltext_index_columns

--ɾ��ȫ������
DROP FULLTEXT CATALOG cat_production_documet

DROP FULLTEXT INDEX ON production.Document

-----ȫ��������ʹ��---------------------------------------------------------------------

CREATE FULLTEXT CATALOG cat_production_Document
CREATE FULLTEXT INDEX ON Production.Document(DocumentSummary)
KEY INDEX PK_document_documentNode ON cat_production_Document
WITH change_tracking AUTO,stoplist=system

--FreeText
/*
���ڻ��ڱ��εģ�����ģ�ͬ���ƥ�䷽ʽ�����ǽṹ�����ı����ݣ���like �ķ�ʽ��������Ϊ�ı������ǰ�����˼��
����׼ȷ�ĵ���������
*/

SELECT DocumentNode,documentSummary FROM production.Document
WHERE FREETEXT(DocumentSummary,'change pedal')--��������change pedal,���ҵ�pedal�ĸ�����ʽpedals

--Contains
/*
�����Ծ�ȷ��ģ���ĵ��ʺͶ���ƥ���������ǽṹ���ı����ݣ��������ܿ��ǵ���֮��Ľӽ��̶ȣ����������Ȩ���
*/

SELECT documentNode,documentSummary FROM production.Document
WHERE CONTAINS(DocumentSummary,'"replacing" or "pedals"') --�������浥��

--1��ʹ��ͨ�������
SELECT * FROM production.Document
WHERE CONTAINS (DocumentSummary,'"import*"')--�κ���import��ʼ�ĵ��ʵ��ж��᷵��

--2)��������ƥ��
SELECT * FROM production.Document
WHERE CONTAINS (DocumentSummary,'FORMSOF(inflectional,replace)')--����replace�����б�����ʽ��replaced,replacing

--3) ���ݴʵ��������������
SELECT * FROM production.Document
WHERE CONTAINS(DocumentSummary,'oil NEAR grease')--����grease ��oil���������ڵ������ı���

--���ݺ��巵�������������
SELECT * FROM Production.Document d
INNER JOIN FREETEXTTABLE(Production.Document,DocumentSummary,'bicycle seat') f ON d.documentNode = f.[key]
ORDER BY RANK DESC-- freetexttable���������documentSummary�е�bicycle seatֵ������������keyֵ���ᵽd.documentNode
/*
freetexttable ��freetext���ƣ����Ǹ��ݺ���������ı�ֵ����ȫ���������У�����freetexttable�������һ����from
�Ӿ������ã�����������ʹ������key���������ݣ�key��rank��freetexttable�ڽ�����з��ص����У�key�Ƕ�����ȫ��
�����е�Ψһ������������rank��һ�����ڽ��������ȷ�Ե�����ֵ����
*/

--����Ȩֵ���������������
SELECT * FROM production.Document d
INNER JOIN CONTAINSTABLE(production.Document,DocumentSummary,'isabout(bicycle weight(.9),seat weight(.1))') f
ON d.DocumentNode = f.[key]
ORDER BY RANK DESC 

/*
containstable ��һ�������������key��documentID���������ᵽproduction.document,��select �Ӿ��з���rank,

��Ȩ��������Ҳ����˵���ʶ���ָ����һ��ֵ��Ӱ�������������е�Ȩֵ
Ȩֵ0-1�����֣���Ӱ��ÿ���е�ƥ����containstable�е�������isabout���ڵ������У��еĶ������Բ�����У�ÿһ��
�󶼸��ŵ���weight ����Բ�����е�0-1.0����ȻȨֵ����Ӱ���ѯ���ص��У�������Ӱ������ֵ��
*/