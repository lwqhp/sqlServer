
--����cpu��ʹ����
/*
sqlServer��ʹ��cpu�ĵط�
1��������ر���

2������;ۺϼ���

3���������join����

��cpu��ص����ã�sp_configure��
1,priority boost
sqlserver������window�ϵ����ȼ���������1,sqlserver ���̻��Խϸߵ����ȼ��������Ӷ�ʹ֮��windows���̵����ﱻ�������С�

2��affinity mask
���� sqlserver�̶�ʹ��ĳ����cpu

3,lightweight pooling 
����sqlserver�Ƿ�Ҫʹ���˳̼���

4��max degree of parallelism
����sqlserver����ö��ٸ��߳�������ִ��һ��ָ��

5��cost threshold of parallelism
������ֵ���������ĸ��Ӷ�

6��max worker threads
����sqlserver��������߳�����


�������������cpuʹ�����
processor : processor time
			privileged tme
			user time
system : processor queue length
context switches/sec

���ÿ�����̵�cpuʹ�����
process : processor time
			privileged time
			user time

2,ȷ����ʱsqlserver�Ƿ�������������û��17883/17884֮������ⷢ������û�з���Խ��(access violation)֮����������ⷢ��


3���ҳ�cpu100%��ʱ��sqlserver ���������е����cpu��Դ����䣬�����ǽ����Ż���			

4,����ϵͳ���أ���������Ӳ��
*/