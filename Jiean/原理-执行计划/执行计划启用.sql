

--ִ�мƻ���ȡ��

/*
ִ�мƻ��Ĳ鿴�����ַ�ʽ��SSMS�п������ú�SQL Trace ����

ִ�мƻ�����ģʽ
a,��SQL���ִ��ǰ���أ�Sqlserver��������û����ҵ������õ�ִ�мƻ��󣬾����������䱾���ᱻִ�С�
	SET SHOWPLAN_ALL ON
	SET showplan_xml ON --�Ͳ˵��ϡ���ʾԤ����ִ�мƻ��� һ��
	
	Event -> Performance -> showplan all
	Event -> Performance -> showplan xml statistcs profile

b,��SQL���ִ�к󷵻أ�����Ԥ��ÿһ������������������ʵ��ÿһ���ķ�����������ռ��һ�������ܣ�������û�����
	���û�ֹͣ���ˣ�����õ�ִ�мƻ������
	SET STATISTICS PROFILE ON 
	
	Event -> Performance -> showplan statistics profile

�Աȣ�
1����Щ��Ϣ�������ǲ���reuse��һ��ִ�мƻ���sql server��û�о���ȱ��������ֻ����xml������￴����	
2�����������ݿ⣬�������ݸ��ĵ���䣬ֻ��ʹ��ִ��ǰ���أ��õ�һ��Ԥ����ִ�мƻ���
*/

