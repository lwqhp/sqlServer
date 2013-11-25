

/*

数据权限-也就是我们常说的页面栏位控制
  针对是数据的控制，比如某些模板可以看几个部门,或只能看到某些供应商
  
  现实需求：控制页面上的栏位操作权限，不同的人看，查不同的内容，或是使用权,比如，控制栏位不同的人能看到不同的供应商限制
  
  转成模型：
	页面--模块，每个主页面是一个模块,也就是菜单项是一个模块*/
	SELECT * FROM dbo.Sys_Module --重点模块编号 ModuleCOde


	/*控制内容，比如供应商，部门,店辅，业务员,--转成数据项：供应商权限，部门权限，店辅权限*/
	SELECT * FROM dbo.Sys_DataItem --数据项ID

	/*指定用户授权--转成角色*/
	SELECT * FROM dbo.Sys_Role --RoleID 内码，RoleCOde 编码
	
	/*角色--数据项--模块关系
	
		角色-->启用数据项控制-->分配待管控的数据项	*/
	
	SELECT * FROM dbo.Sys_Role WHERE AllowDataRight = 1
	/*数据项分配表，角色ID-数据项ID 存在有效*/
	SELECT * FROM [Sys_Role_DataItemCo]
	
	SELECT * FROM Sys_Module_FuncCo

