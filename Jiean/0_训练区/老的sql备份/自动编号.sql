
/*
�Զ���Ű�����
IDENTITY ������
ROWGUIDCOL�� Ϊuniqueidentiier�������ͣ� ȫ��Ψһ��ʹ��NEWID��������ID��
*/

--IDENTITY

CREATE TABLE tb(
	id int IDENTITY(1,1) null
)

SELECT id = IDENTITY(int,1,1)

--��ʶ��ת��
SET IDENTITY_INSERT tb ON
SET IDENTITY_INSERT tb OFF

--��ʶ������ͨ��ת��