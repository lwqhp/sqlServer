

--����

--1��ͨ�ж������
/*
ʹ��ͨ�ж�����ܺ����������ݣ��Ͳ��õ���sysadmin��������ɫ��Ա��ȡ����(��������ɫ��Աsysadminӵ�ж�ȡ����
��ʽ�ļ������ݵ�����Ȩ��)
*/
CREATE TABLE #t(scret VARBINARY(max))

INSERT INTO #t
SELECT ENCRYPTBYPASSPHRASE('this is encryption the password','Ҫ���ܵ��ı�')


--SELECT * FROM #t

--��ȡ
SELECT 
CAST(DECRYPTBYPASSPHRASE('this is encryption the password',scret) AS VARCHAR(100))
 FROM #t
 
 --2����Կ
 /*
 sqlServer����������Կ����������Կ�����ݿ�����Կ
 ��������Կλ�ڲ�νṹ����ˣ������ڰ�װsqlserverʱ�Զ����������ڼ���ϵͳ���ݣ����ӵķ�������
��¼���Լ����ݿ�����Կ,�ڵ�һ��ͨ��sqlserverʹ�÷�������Կһ����֤�飬���ݿ�����Կ�����ӵķ���������ʱ��
��������Կ���Զ����ɣ�������ʹ��sqlserver�����ʻ���windows֤������������

 ���ݿ�����Կ��������֤�飬�Լ��ǶԳ���Կ�ͶԳ���Կ���������ݿⶼ����ֻ����һ�����ݿ�����Կ��������ʱ��ͨ��
 ��������Կ������ܡ�
 
 �����ǶԳ���Կʱ�����Ծ����ڼ��ܷǶԳ���Կ�Ե�˽Կʱ�Ƿ�������룬������������룬��ʹ�����ݿ�����Կ������
 ˽Կ��
 */
 
 --���ݷ�������Կ
 BACKUP SERVICE MASTER KEY
 TO FILE ='c:\smk.bak' --���ݵ��ļ� 
 DECRYPTION BY PASSWORD = '123456' --ָ�����������ļ�������
 
 --��ԭ��������Կ
 RESTORE SERVICE MASTER KEY 
 FROM FILE ='c:\smk.bak'
 DECRYPTION BY PASSWORD = '123456'
 
 --���ݿ�����Կ
 /*
 ����ʽ�������ݿ�����Կʱ������ͨ���Զ��������ݿ��м�����֤���ǶԳ���Կ����һ������İ�ȫ�㣬���ڽ�һ��
 �������ܵ����ݡ�
 */
 
 --����
 CREATE MASTER KEY ENCRYPTION BY PASSWORD='123456'
 
 --�޸�
 ALTER MASTER KEY REGENERATE WITH ENCRYPTION BY PASSWORD='1234'
 
 --ɾ��
 DROP MASTER KEY 
 
 --����
 BACKUP MASTER KEY TO FILE = 'c:\master_key.bak'
 ENCRYPTION BY PASSWORD = '123456'
 
 --��ԭ
 RESTORE MASTER KEY FROM FILE = 'c:\master_key.bak'
 DECRYPTION BY PASSWORD = '123456'
 ENCRYPTION BY PASSWORD = 'abc'
 
 --�����ݿ�����Կɾ����������Կ����
 /*
 �������ݿ�����Կʱ��Ĭ��ʹ�����ַ����������ܣ���������Կ����create master key������ʹ���õ����룬�Ĺ��㲻ϣ
 ��ͨ����������Կ�����ݿ�����Կ���м���(�������ӵ��sysadminȨ�޵�sqlserver��¼����֪�����ݿ������룬���Ͳ���
 ���ʼ��ܵ�����)
 */
 
ALTER MASTER KEY DROP ENCRYPTION BY SERVICE MASTER KEY
--֮�����ݿ�����Կ�������޸Ķ���Ҫʹ��open master key��������������
OPEN MASTER KEY DECRYPTION BY PASSWORD = '1234'
--��һ�ν���������Կ���ӻ���
ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY
--�ر����ݿ�����Կ
CLOSE MASTER KEY

--�ǶԳ���Կ����----------------------------------------------------------------------
/*
�ǶԳ���Կ�������ݿ⼶���ڲ���Կ��˽Կ���������������ܺͽ���sqlserver���ݿ��е����ݣ��ǶԳ���Կ���Դ��ⲿ
�ļ�������е��룬����Ҳ������sqlserver���ݿ������ɡ�
����֤�飬�ǶԳ���Կ�����Ա��ݵ��ļ�������ζ�������sqlserver�д����˷ǶԳ���Կ����û�зǳ��򵥵ķ���������
�û����ݿ���������ͬ����Կ��
�ǶԳ���Կ�������ݼ�����˵�Ǹ߰�ȫѡ�����ʹ������ʱҲ��Ҫ�����sqlserver��Դ��
*/

--����
CREATE ASYMMETRIC KEY asymooksellerkey --����Կ������
WITH  algorithm = RSA_512 --���ܰ�ȫ����
ENCRYPTION BY PASSWORD = '123456' --�������ܷǶԳ���Կ������

--�鿴
SELECT * FROM sys.asymmetric_keys

--�޸ķǶԳ���Կ��˽Կ����
ALTER ASYMMETRIC KEY asymbooksellerkey
WITH PRIVATE KEY 
(ENCRYPTION BY PASSWORD='new password'
,DECRYPTION BY PASSWORD = 'old password')

--ʹ�÷ǶԳ���Կ�����ݽ��м��ܺͽ���
CREATE TABLE booksellerbankrouting(
	bookselerID INT NOT NULL PRIMARY KEY,
	bankroutingNBR VARBINARY(300) NOT NULL --VARBINARY���ڴ洢��������
)

INSERT INTO booksellerbankrouting
SELECT 22,ENCRYPTBYASYMKEY(ASYMKEY_ID('asymbooksellerkey')--�ǶԳ���Կ��ϵͳID��ʹ��asymkey_id��������Կ����ת��Ϊ��Կid����ֵ
,'��������'))

--�鿴
SELECT 
CAST(DECRYPTBYASYMKEY(ASYMKEY_ID('asymbooksellerkey'),bankroutingNBR,
N'newpassword'--�ǶԳ���Կ��˽Կ������
) AS varchar(100))
 FROM booksellerbankrouting

--ɾ���ǶԳ���Կ
DROP ASYMMETRIC KEY asymbooksellerkey

--�Գ���Կ����--------------------------------------------------------------------------------
/*
�Գ���Կ����һ��ͬʱ�������ܺͽ��ܵ���Կ
*/

--�������ڼ��ܶԳ���Կ�ķǶԳ���Կ
/*
����Գ���Կ�������������ݣ�����ʹ��֤�飬���룬�ǶԳ���Կ�������Գ���Կ�������ܡ�
*/
CREATE ASYMMETRIC KEY asymbooksellerkey
WITH algorithm = RSA_512
ENCRYPTION BY PASSWORD = '12456'

--�����Գ���Կ
CREATE SYMMETRIC KEY sym_bookstore
WITH ALGORITHM = TRIPLE_DES
ENCRYPTION BY ASYMMETRIC KEY asymbooksellerkey

--�鿴
SELECT * FROM sys.symmetric_keys

--�ı�Գ���Կ���ܷ�ʽ

--ʹ�ü�����Կ��˽����Կ�������򿪶Գ���Կ
OPEN SYMMETRIC KEY sym_bookstore
DECRYPTION BY ASYMMETRIC KEY asymbooksellerkey
WITH password = '123456'

--������������ܣ�Ȼ��ɾ���ǶԳ���Կ����
ALTER SYMMETRIC KEY sym_bookstore
ADD ENCRYPTION BY PASSWORD = '134'

ALTER SYMMETRIC KEY sym_bookstore
DROP ENCRYPTION BY ASYMMETRIC KEY asymbooksellerkey


--�ر�
CLOSE SYMMETRIC KEY sym_bookstore

--��������
--�򿪶Գ���Կ
OPEN SYMMETRIC KEY sym_bookstore
DECRYPTION BY PASSWORD = '123456'

--��������
SELECT ENCRYPTBYKEY(KEY_GUID('sym_bookstore'),'��������')

CLOSE SYMMETRIC KEY sym_bookstore

--����
OPEN SYMMETRIC KEY sym_bookstore
DECRYPTION BY PASSWORD = '1234'

SELECT CAST(DECRYPTBYKEY(passwordHintanswer) AS VARCHAR(200)) passwprdhintanswer
FROM passwordhint

--ɾ��
DROP SYMMETRIC KEY sym_bookstore


--֤�����--------------------------------------------------------------------------------
/*
֤��������������ݿ��м��ܻ�������ݣ�֤�������Կ�ԣ�����֤��ӵ���ߵ���Ϣ�Լ�֤����õĿ�ʼ�ͽ����������ڡ�
֤��ͬʱ������Կ��˽Կ��֤��Ĺ�Կ�����������ݣ�˽Կ�����������ݡ�
*/

CREATE CERTIFICATE cert_bookstore
ENCRYPTION BY PASSWORD ='123456'--����֤�������
WITH SUBJECT = 'bookstore database'--֤�������
,START_DATE = '2/20/2015',EXPIRY_DATE  ='10/20/2016'

--�鿴
SELECT * FROM sys.certificates

--����
BACKUP CERTIFICATE cert_bookstore
TO FILE = 'c:\certbookstore.bak'
WITH private KEY (FILE ='c:\certbookstore.bak',
ENCRYPTION BY PASSWORD = '1234'
,DECRYPTION BY PASSWORD ='12345')

--����֤��˽Կ
ALTER CERTIFICATE cert_bookstore
REMOVE PRIVATE KEY

--�ӱ����ļ�Ϊ����֤����������˽Կ
ALTER CERTIFICATE cert_bookstore
WITH PRIVATE KEY
(
FILE = 'c:\certbookstorepk.bak',
DECRYPTION BY PASSWORD = '1234',
ENCRYPTION BY PASSWORD = '123456'
)

--�޸ļ���˽Կ������
ALTER CERTIFICATE cert_bookstore
WITH PRIVATE KEY (DECRYPTION BY PASSWORD = '1234',
ENCRYPTION BY PASSWORD = '12456')

--ʹ��֤�����
SELECT ENCRYPTBYCERT(CERT_ID('cert_bookstore'),'��������')

--����
SELECT CAST(DECRYPTBYCERT(CERT_ID('cert_bookstore'),passwordhintanswer,N'123456') AS VARCHAR(200))


-----ͨ���Գ���Կ�Զ��򿪺ͽ���
/*
�÷ǶԳ���Կ���ܶԳ���Կ��ʹ�ã�����open symmetric key,�����ʵ�ʵ�decryptbykey�������ã�sqlserverҲ�ṩ����
��������ǰ���ᵽ�Ĳ��ۺϵ�һ�������е���������Ľ��ܺ��������Ƿֱ�������ʹ�÷ǶԳ���Կ���ܵĶԳ���Կdecryptbykeyautoasymkey
������ʹ��֤����ܵĶԳ���Կ��decryptbykeyautocert
*/

CREATE ASYMMETRIC KEY asymbooksell_v2
WITH algorithm = RSA_512

CREATE SYMMETRIC KEY sym_bookstore_v2
WITH ALGORITHM = TRIPLE_DES
ENCRYPTION BY ASYMMETRIC KEY asymbooksell_v2

OPEN SYMMETRIC KEY sym_bookstore_v2
DECRYPTION BY ASYMMETRIC KEY asymbooksell_v2


INSERT INTO  passwordHint
SELECT ENCRYPTBYKEY(KEY_GUID('sym_bookstore_v2'),'��������')

CLOSE SYMMETRIC KEY sym_bookstore_v2

--͸�����ݼ���
/*
͸�����ݼ��ܣ�TDE�����û����ݿ���ò���������TDEʱ������д�����ʱ����ҳ��������˼��ܣ�������ҳ���뵽�ڴ�
ʱ���н��ܡ����ڼ����˵������ļ���û�����ڼ���dek�ķ�����֤�飬͵�����ݿ��ǲ����Ա���ԭ�������ظ��ӵ�����
sqlserverʵ���ϣ�Ҳ�����Զ��ļ���������ƽ⡣
*/
--��������Կ
CREATE MASTER KEY ENCRYPTION
BY PASSWORD = '123456'

--����dek��֤��
CREATE CERTIFICATE tde_Server_Certificate
WITH SUBJECT ='Server-level cert for TDE'

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = TRIPLE_DES_3KEY
ENCRYPTION BY SERVER CERTIFICATE tde_server_certificate --�����˼���dekҪʹ���ĸ������������֤��

--�������ݿ�
ALTER DATABASE bookstore
SET ENCRYPTION on


--�鿴
SELECT is_encrypted FROM sys.databases 


--����
ALTER DATABASE ENCRYPTION KEY REGENERATE WITH ALGORITHM = AES_128

SELECT * FROM sys.dm_database_encryption_keys

--�Ƴ�
ALTER DATABASE bookstore 
set ENCRYPTION OFF

DROP DATABASE ENCRYPTION KEY