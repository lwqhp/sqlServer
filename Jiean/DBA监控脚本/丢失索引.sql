--¶ªÊ§Ë÷Òý
--[SD_Mat_MaterialSize]
if exists (select 1 from sys.indexes where object_id=object_id('SD_Mat_MaterialSize') and name ='NonClusteredIndex_SD_Mat_MaterialSize')
begin
	drop index NonClusteredIndex_SD_Mat_MaterialSize on [SD_Mat_MaterialSize]
end 
create nonclustered index NonClusteredIndex_SD_Mat_MaterialSize on  [SD_Mat_MaterialSize]([MaterialID])include ([Sequence], [SizeID], [BarCode])
go
--SD_Mat_Material
if exists (select 1 from sys.indexes where object_id=object_id('SD_Mat_Material') and name ='NonClusteredIndex_SD_Mat_Material_MaterialCode')
begin
	drop index NonClusteredIndex_SD_Mat_Material_MaterialCode on SD_Mat_Material
end 
create nonclustered index NonClusteredIndex_SD_Mat_Material_MaterialCode on  [SD_Mat_Material]([MaterialCode])include ([MaterialID], [MatTypeID], [CardID], [SizeTypeID])
go
--[Bas_Shop]
if exists (select 1 from sys.indexes where object_id=object_id('Bas_Shop') and name ='NonClusteredIndex_Bas_Shop_ShopName')
begin
	drop index NonClusteredIndex_Bas_Shop_ShopName on Bas_Shop
end 
create nonclustered index NonClusteredIndex_Bas_Shop_ShopName on  Bas_Shop([StockID])include ([ShopName])
go

--SD_Pos_OnDuty
if exists (select 1 from sys.indexes where object_id=object_id('SD_Pos_OnDuty') and name ='NonClusteredIndex_SD_Pos_OnDuty_OnDutyNo')
begin
	drop index NonClusteredIndex_SD_Pos_OnDuty_OnDutyNo on SD_Pos_OnDuty
end 
create nonclustered index NonClusteredIndex_SD_Pos_OnDuty_OnDutyNo on  SD_Pos_OnDuty([OnDutyNo])include ([ClassID])
go


--[SD_Inv_MaterialAgeInv]
if exists (select 1 from sys.indexes where object_id=object_id('SD_Inv_MaterialAgeInv') and name ='NonClusteredIndex_SD_Inv_MaterialAgeInv_BatchNo')
begin
	drop index NonClusteredIndex_SD_Inv_MaterialAgeInv_BatchNo on [SD_Inv_MaterialAgeInv]
end 
create nonclustered index NonClusteredIndex_SD_Inv_MaterialAgeInv_BatchNo on  [SD_Inv_MaterialAgeInv]([CompanyID], [StockID], [MaterialID],[InvQty])include ([BatchNo])
go


--[SD_Sal_ShipDetail]
if exists (select 1 from sys.indexes where object_id=object_id('SD_Sal_ShipDetail') and name ='NonClusteredIndex_SD_Sal_ShipDetail_BillNo')
begin
	drop index NonClusteredIndex_SD_Sal_ShipDetail_BillNo on SD_Sal_ShipDetail
end 
create nonclustered index NonClusteredIndex_SD_Sal_ShipDetail_BillNo on  SD_Sal_ShipDetail([CompanyID], [SourceBillNo], [SourceBillSequence])include ([BillNo])
go
--[SD_Bas_AreaRetailPrice]
if exists (select 1 from sys.indexes where object_id=object_id('SD_Bas_AreaRetailPrice') and name ='NonClusteredIndex_SD_Bas_AreaRetailPrice')
begin
	drop index NonClusteredIndex_SD_Bas_AreaRetailPrice on SD_Bas_AreaRetailPrice
end 
create nonclustered index NonClusteredIndex_SD_Bas_AreaRetailPrice on SD_Bas_AreaRetailPrice ([CompanyID], [RetailPriceProjID])  include ([MaterialID], [AreaRetailPrice])
go
--SD_Pos_SalPromotionMaterial
if exists (select 1 from sys.indexes where object_id=object_id('SD_Pos_SalPromotionMaterial') and name ='NonClusteredIndex_SD_Pos_SalPromotionMaterial')
begin
	drop index NonClusteredIndex_SD_Pos_SalPromotionMaterial on SD_Pos_SalPromotionMaterial
end 
create nonclustered index NonClusteredIndex_SD_Pos_SalPromotionMaterial on SD_Pos_SalPromotionMaterial ([CompanyID], [PromotionID], [Par7])  include ([TypeCode], [Par1], [Par2], [Par3], [Par4], [Par6], [Par9], [Par10])
go
--SD_Pos_SalPromotionMaterial
if exists (select 1 from sys.indexes where object_id=object_id('SD_Pos_SalPromotionMaterial') and name ='NonClusteredIndex_SD_Pos_SalPromotionMaterial_Par7')
begin
	drop index NonClusteredIndex_SD_Pos_SalPromotionMaterial_Par7 on SD_Pos_SalPromotionMaterial
end 
create nonclustered index NonClusteredIndex_SD_Pos_SalPromotionMaterial_Par7 on [SD_Pos_SalPromotionMaterial] ([CompanyID], [PromotionID])  include ([Par7])
go


--Sys_AF_AuditFlow
if exists (select 1 from sys.indexes where object_id=object_id('Sys_AF_AuditFlow') and name ='NonClusteredIndex_Sys_AF_AuditFlow')
begin
	drop index NonClusteredIndex_Sys_AF_AuditFlow on [Sys_AF_AuditFlow]
end 
create nonclustered index NonClusteredIndex_Sys_AF_AuditFlow on [Sys_AF_AuditFlow] ([BillKey1], [BillKey2], [ModuleCode])
go
--[Sys_AF_AuditForCheck]
if exists (select 1 from sys.indexes where object_id=object_id('Sys_AF_AuditForCheck') and name ='NonClusteredIndex_Sys_AF_AuditForCheck')
begin
	drop index NonClusteredIndex_Sys_AF_AuditForCheck on Sys_AF_AuditForCheck
end 
create nonclustered index NonClusteredIndex_Sys_AF_AuditForCheck on Sys_AF_AuditForCheck ([BillKey1], [BillKey2], [ModuleCode])
go

--[[Sys_SingleField]]
if exists (select 1 from sys.indexes where object_id=object_id('Sys_SingleField') and name ='NonClusteredIndex_Sys_SingleField')
begin
	drop index NonClusteredIndex_Sys_SingleField on Sys_SingleField
end 
create nonclustered index NonClusteredIndex_Sys_SingleField on Sys_SingleField ([ModuleCode])
go
	