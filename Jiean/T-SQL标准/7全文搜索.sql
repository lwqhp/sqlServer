

--全文搜索
/*
这是基于字符和二进制数据的智能单词，短语的搜索，执行效率比普通的like查询好很多


--全文索引

与普通的B树聚集索引或非聚集索引不同的是，全文索引是由文本数据的索引标记组成的压缩的索引结构，标记是sql2008
在索引过程中标识的单词或字符串


--全文目录

可以不包含全文索引，也可以包含数量不等的全文索引
*/

--创建全文目录
CREATE FULLTEXT CATALOG cat_producttion_document --创建一个全文目录
CREATE FULLTEXT CATALOG cat_production_document_ex2 WITH accent_sensitivity=ON --建立一个区分重音的全文目录
/*
一个全文目录只能属于一个数据库
全文目录可以用来聚合一个或更多全文索引的实例逻辑实体，全文目录创建后，可以在它下面创建全文索引
*/

--创建全文索引
CREATE FULLTEXT INDEX ON production.Document --表
(DocumentSummary,Document TYPE COLUMN fileextension) --列，type olumn指明列类型指针，帮助sqlserver解释存储的数据
KEY INDEX PK_document_documentNode --标识键（表的非空唯一列）的名称
ON cat_production_document -- 指定全文索引要存储的全文目录
WITH change_tracking AUTO,STOPLIST=SYSTEM --填充方式及使用系统默认非索引字表

--修改全文目录

ALTER FULLTEXT CATALOG cat_production_document
REORGANIZE -- 优化全文目录

ALTER FULLTEXT CATALOG cat_production_document
AS DEFAULT --设置为数据库的默认全文目录

ALTER FULLTEXT CATALOG cat_production_document
REBUILD WITH accent_sensitivity = OFF --重建一个禁用分重音的全文目录和其中的全部索引

--修改全文索引

ALTER FULLTEXT INDEX ON Production.Document
ADD (Title)--增加一个新的列到表的全文索引中

ALTER FULLTEXT INDEX ON production.Document
START FULL POPULATION --启动一个全文索引填充操作

ALTER FULLTEXT INDEX ON production.Document
SET CHANGE_TRACKING OFF 

ALTER FULLTEXT INDEX ON production.Document 
DROP (Title) --将列从全文索引中删除


--查看全文目录和索引信息
SELECT * FROM sys.fulltext_catalogs

SELECT * FROM sys.fulltext_indexes

SELECT * FROM sys.fulltext_index_columns

--删除全文索引
DROP FULLTEXT CATALOG cat_production_documet

DROP FULLTEXT INDEX ON production.Document

-----全文索引的使用---------------------------------------------------------------------

CREATE FULLTEXT CATALOG cat_production_Document
CREATE FULLTEXT INDEX ON Production.Document(DocumentSummary)
KEY INDEX PK_document_documentNode ON cat_production_Document
WITH change_tracking AUTO,stoplist=system

--FreeText
/*
用于基于变形的，字面的，同义的匹配方式搜索非结构化的文本数据，比like 的方式更智能因为文本数据是按照意思而
不是准确的单词来搜索
*/

SELECT DocumentNode,documentSummary FROM production.Document
WHERE FREETEXT(DocumentSummary,'change pedal')--搜索短语change pedal,会找到pedal的复数形式pedals

--Contains
/*
用于以精确或模糊的单词和短语匹配来搜索非结构化文本数据，这个命令还能考虑单词之间的接近程度，并且允许加权结果
*/

SELECT documentNode,documentSummary FROM production.Document
WHERE CONTAINS(DocumentSummary,'"replacing" or "pedals"') --搜索字面单词

--1）使用通配符搜索
SELECT * FROM production.Document
WHERE CONTAINS (DocumentSummary,'"import*"')--任何由import开始的单词的行都会返回

--2)搜索变形匹配
SELECT * FROM production.Document
WHERE CONTAINS (DocumentSummary,'FORMSOF(inflectional,replace)')--搜索replace的所有变形形式，replaced,replacing

--3) 根据词的相邻来搜索结果
SELECT * FROM production.Document
WHERE CONTAINS(DocumentSummary,'oil NEAR grease')--查找grease 和oil两个词相邻的所有文本。

--根据含义返回排名搜索结果
SELECT * FROM Production.Document d
INNER JOIN FREETEXTTABLE(Production.Document,DocumentSummary,'bicycle seat') f ON d.documentNode = f.[key]
ORDER BY RANK DESC-- freetexttable结果集搜索documentSummary列的bicycle seat值，并根据它的key值联结到d.documentNode
/*
freetexttable 和freetext相似，都是根据含义而不是文本值搜索全文索引的列，但是freetexttable可以像表一样在from
子句中引用，并且允许你使用它的key来联结数据（key和rank是freetexttable在结果集中返回的两列，key是定义在全文
索引中的唯一键、主键，而rank是一个行在结果集中正确性的评估值。）
*/

--根据权值返回排名搜索结果
SELECT * FROM production.Document d
INNER JOIN CONTAINSTABLE(production.Document,DocumentSummary,'isabout(bicycle weight(.9),seat weight(.1))') f
ON d.DocumentNode = f.[key]
ORDER BY RANK DESC 

/*
containstable 是一个结果集，根据key和documentID来把它联结到production.document,在select 子句中返回rank,

加权项搜索，也就是说单词都被指定了一个值来影禹它们在排名中的权值
权值0-1的数字，它影响每个行的匹配在containstable中的排名，isabout放在单引号中，列的定义放在圆括号中，每一项
后都跟着单词weight 和在圆括号中的0-1.0，虽然权值不会影响查询返回的行，但它会影响排名值。
*/