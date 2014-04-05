

--加密

--1）通行短语加密
/*
使用通行短语加密函数加密数据，就不用担心sysadmin服务器角色成员读取数据(服务器角色成员sysadmin拥有读取其他
形式的加密数据的内在权限)
*/
CREATE TABLE #t(scret VARBINARY(max))

INSERT INTO #t
SELECT ENCRYPTBYPASSPHRASE('this is encryption the password','要加密的文本')


--SELECT * FROM #t

--读取
SELECT 
CAST(DECRYPTBYPASSPHRASE('this is encryption the password',scret) AS VARCHAR(100))
 FROM #t
 
 --2）密钥
 /*
 sqlServer中有两种密钥，服务主密钥和数据库主密钥
 服务主密钥位于层次结构的最顶端，并且在安装sqlserver时自动创建，用于加密系统数据，链接的服务器，
登录名以及数据库主密钥,在第一次通过sqlserver使用服务主密钥一加密证书，数据库主密钥或链接的服务器密码时，
服务主密钥会自动生成，并且是使用sqlserver服务帐户的windows证书来生成它。

 数据库主密钥用来加密证书，以及非对称密钥和对称密钥，所有数据库都可以只包含一个数据库主密钥，创建它时，通过
 服务主密钥对其加密。
 
 创建非对称密钥时，可以决定在加密非对称密钥对的私钥时是否包含密码，如果不包含密码，将使用数据库主密钥来加密
 私钥。
 */
 
 --备份服务主密钥
 BACKUP SERVICE MASTER KEY
 TO FILE ='c:\smk.bak' --备份到文件 
 DECRYPTION BY PASSWORD = '123456' --指定用来保护文件的密码
 
 --还原服务主密钥
 RESTORE SERVICE MASTER KEY 
 FROM FILE ='c:\smk.bak'
 DECRYPTION BY PASSWORD = '123456'
 
 --数据库主密钥
 /*
 当显式创建数据库主密钥时，它会通过自动地在数据库中加密新证书或非对称密钥增加一个额外的安全层，用于进一步
 保护加密的数据。
 */
 
 --创建
 CREATE MASTER KEY ENCRYPTION BY PASSWORD='123456'
 
 --修改
 ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD='1234'
 
 --删除
 DROP MASTER KEY 
 
 --备份
 BACKUP MASTER KEY TO FILE = 'c:\master_key.bak'
 ENCRYPTION BY PASSWORD = '123456'
 
 --还原
 RESTORE MASTER KEY FROM FILE = 'c:\master_key.bak'
 DECRYPTION BY PASSWORD = '123456'
 ENCRYPTION BY PASSWORD = 'abc'
 
 --从数据库主密钥删除服务主密钥加密
 /*
 创建数据库主密钥时，默认使用两种方法对它加密：服务主密钥和在create master key命令中使用用的密码，哪果你不希
 望通过服务主密钥对数据库主密钥进行加密(这样如果拥有sysadmin权限的sqlserver登录名不知道数据库主密码，它就不能
 访问加密的数据)
 */
 
ALTER MASTER KEY DROP ENCRYPTION BY SERVICE MASTER KEY
--之后数据库主密钥的所有修改都需要使用open master key命令进行密码访问
OPEN MASTER KEY DECRYPTION BY PASSWORD = '1234'
--再一次将服务主密钥增加回来
ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY
--关闭数据库主密钥
CLOSE MASTER KEY

--非对称密钥加密----------------------------------------------------------------------
/*
非对称密钥包含数据库级的内部公钥和私钥，它可以用来加密和解密sqlserver数据库中的数据，非对称密钥可以从外部
文件或程序集中导入，并且也可以在sqlserver数据库中生成。
不像证书，非对称密钥不可以备份到文件，这意味着如果在sqlserver中创建了非对称密钥，还没有非常简单的方法在其他
用户数据库中重用相同的密钥。
非对称密钥对于数据加密来说是高安全选项，但在使用它们时也需要更多的sqlserver资源。
*/

--创建
CREATE ASYMMETRIC KEY asymooksellerkey --新密钥的名称
WITH  algorithm = RSA_512 --加密安全类型
ENCRYPTION BY PASSWORD = '123456' --用来加密非对称密钥的密码

--查看
SELECT * FROM sys.asymmetric_keys

--修改非对称密钥的私钥密码
ALTER ASYMMETRIC KEY asymbooksellerkey
WITH PRIVATE KEY 
(ENCRYPTION BY PASSWORD='new password'
,DECRYPTION BY PASSWORD = 'old password')

--使用非对称密钥对数据进行加密和解密
CREATE TABLE booksellerbankrouting(
	bookselerID INT NOT NULL PRIMARY KEY,
	bankroutingNBR VARBINARY(300) NOT NULL --VARBINARY用于存储加密数据
)

INSERT INTO booksellerbankrouting
SELECT 22,ENCRYPTBYASYMKEY(ASYMKEY_ID('asymbooksellerkey')--非对称密钥的系统ID，使用asymkey_id函数将密钥名称转换为密钥id密数值
,'加密数据'))

--查看
SELECT 
CAST(DECRYPTBYASYMKEY(ASYMKEY_ID('asymbooksellerkey'),bankroutingNBR,
N'newpassword'--非对称密钥的私钥的密码
) AS varchar(100))
 FROM booksellerbankrouting

--删除非对称密钥
DROP ASYMMETRIC KEY asymbooksellerkey

--对称密钥加密--------------------------------------------------------------------------------
/*
对称密钥包含一个同时用来加密和解密的密钥
*/

--创建用于加密对称密钥的非对称密钥
/*
这个对称密钥将用来加密数据，必须使用证书，密码，非对称密钥或其他对称密钥对它加密。
*/
CREATE ASYMMETRIC KEY asymbooksellerkey
WITH algorithm = RSA_512
ENCRYPTION BY PASSWORD = '12456'

--创建对称密钥
CREATE SYMMETRIC KEY sym_bookstore
WITH ALGORITHM = TRIPLE_DES
ENCRYPTION BY ASYMMETRIC KEY asymbooksellerkey

--查看
SELECT * FROM sys.symmetric_keys

--改变对称密钥加密方式

--使用加密密钥的私有密钥密码来打开对称密钥
OPEN SYMMETRIC KEY sym_bookstore
DECRYPTION BY ASYMMETRIC KEY asymbooksellerkey
WITH password = '123456'

--先增加密码加密，然后删除非对称密钥加密
ALTER SYMMETRIC KEY sym_bookstore
ADD ENCRYPTION BY PASSWORD = '134'

ALTER SYMMETRIC KEY sym_bookstore
DROP ENCRYPTION BY ASYMMETRIC KEY asymbooksellerkey


--关闭
CLOSE SYMMETRIC KEY sym_bookstore

--加密数据
--打开对称密钥
OPEN SYMMETRIC KEY sym_bookstore
DECRYPTION BY PASSWORD = '123456'

--加密数据
SELECT ENCRYPTBYKEY(KEY_GUID('sym_bookstore'),'加密数据')

CLOSE SYMMETRIC KEY sym_bookstore

--解密
OPEN SYMMETRIC KEY sym_bookstore
DECRYPTION BY PASSWORD = '1234'

SELECT CAST(DECRYPTBYKEY(passwordHintanswer) AS VARCHAR(200)) passwprdhintanswer
FROM passwordhint

--删除
DROP SYMMETRIC KEY sym_bookstore


--证书加密--------------------------------------------------------------------------------
/*
证书可以用来在数据库中加密或解密数据，证书包含密钥对，关于证书拥有者的信息以及证书可用的开始和结束过期日期。
证书同时包含公钥和私钥，证书的公钥用来加密数据，私钥用来解密数据。
*/

CREATE CERTIFICATE cert_bookstore
ENCRYPTION BY PASSWORD ='123456'--加密证书的密码
WITH SUBJECT = 'bookstore database'--证书的主题
,START_DATE = '2/20/2015',EXPIRY_DATE  ='10/20/2016'

--查看
SELECT * FROM sys.certificates

--备份
BACKUP CERTIFICATE cert_bookstore
TO FILE = 'c:\certbookstore.bak'
WITH private KEY (FILE ='c:\certbookstore.bak',
ENCRYPTION BY PASSWORD = '1234'
,DECRYPTION BY PASSWORD ='12345')

--管理证书私钥
ALTER CERTIFICATE cert_bookstore
REMOVE PRIVATE KEY

--从备份文件为既有证书重新增加私钥
ALTER CERTIFICATE cert_bookstore
WITH PRIVATE KEY
(
FILE = 'c:\certbookstorepk.bak',
DECRYPTION BY PASSWORD = '1234',
ENCRYPTION BY PASSWORD = '123456'
)

--修改既有私钥的密码
ALTER CERTIFICATE cert_bookstore
WITH PRIVATE KEY (DECRYPTION BY PASSWORD = '1234',
ENCRYPTION BY PASSWORD = '12456')

--使用证书加密
SELECT ENCRYPTBYCERT(CERT_ID('cert_bookstore'),'加密数据')

--解密
SELECT CAST(DECRYPTBYCERT(CERT_ID('cert_bookstore'),passwordhintanswer,N'123456') AS VARCHAR(200))


-----通过对称密钥自动打开和解密
/*
用非对称密钥加密对称密钥的使用，首先open symmetric key,随后是实际的decryptbykey函数调用，sqlserver也提供了能
够将两个前面提到的步聚合到一个操作中的两个额外的解密函数，它们分别是用于使用非对称密钥加密的对称密钥decryptbykeyautoasymkey
和用于使用证书加密的对称密钥的decryptbykeyautocert
*/

CREATE ASYMMETRIC KEY asymbooksell_v2
WITH algorithm = RSA_512

CREATE SYMMETRIC KEY sym_bookstore_v2
WITH ALGORITHM = TRIPLE_DES
ENCRYPTION BY ASYMMETRIC KEY asymbooksell_v2

OPEN SYMMETRIC KEY sym_bookstore_v2
DECRYPTION BY ASYMMETRIC KEY asymbooksell_v2


INSERT INTO  passwordHint
SELECT ENCRYPTBYKEY(KEY_GUID('sym_bookstore_v2'),'加密数据')

CLOSE SYMMETRIC KEY sym_bookstore_v2

--透明数据加密
/*
透明数据加密，TDE，当用户数据库可用并且启用了TDE时，数据写入磁盘时便在页级别进行了加密，当数据页读入到内存
时进行解密。对于加密了的数据文件，没有用于加密dek的服务器证书，偷的数据库是不可以被还原或正常地附加到其他
sqlserver实例上，也不可以对文件本身进行破解。
*/
--创建主密钥
CREATE MASTER KEY ENCRYPTION
BY PASSWORD = '123456'

--加密dek的证书
CREATE CERTIFICATE tde_Server_Certificate
WITH SUBJECT ='Server-level cert for TDE'

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = TRIPLE_DES_3KEY
ENCRYPTION BY SERVER CERTIFICATE tde_server_certificate --定义了加密dek要使用哪个服务器级别的证书

--加密数据库
ALTER DATABASE bookstore
SET ENCRYPTION on


--查看
SELECT is_encrypted FROM sys.databases 


--管理
ALTER DATABASE ENCRYPTION KEY REGENERATE WITH ALGORITHM = AES_128

SELECT * FROM sys.dm_database_encryption_keys

--移除
ALTER DATABASE bookstore 
set ENCRYPTION OFF

DROP DATABASE ENCRYPTION KEY