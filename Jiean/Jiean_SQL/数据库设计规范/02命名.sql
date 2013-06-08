

/*好的规范的命名，可以让表结构清晰，通俗易懂，可扩展性强*/

/*表结构及字段 扩展性 和 可读性 考虑定义
	
	数据库名：一个系统一个数据库，数据库名反映了系统名称,能反映出和其它系统的 相关性 和 区别性
	
	模块化  : 系统结构按 子系统 - 模块 - 参数,基础数据划分
	
	子系统:
		把具有独立完整功能的模块定义为 子系统：	
		子系统代码（所有字母大字）+’_’+模块代码（首字母大字）+’_’+具体名称（每个单词首字母大字）
		例: FIFA_Bas_AssetClass
	
	模块：
		子系统中模块划分，能反映出系统中模块组成（有多少个独立模块构成此系统结构）
		’_’+模块代码（首字母大字）
	
	参数,基础数据:
		公共或子系统模块专有代码
		模块代码（首字母大字）+’_’+具体名称（每个单词首字母大字, 缩写也如此）
		例: SYS_User ,Bas_Area,Pub_Area,Sys_BillType
		同样，也存在于子系统中 SD_Bas_Area,SD_Pub_Area
		
	表和表字段命名：
		能准确反映出表含义和相关表关联
		’_’+具体名称（每个单词首字母大字）
		
		整理如下：
			内码：统一用ID		编码：统一用Code
		
	视图、存储过程，函数命名
		则在表名的命名规则前加两个小写字母，
		vw代表视图、 + 主表名
		sp代表存储过程、
		fn 代表函数	
		例: spSys_GetCustomerId



*/