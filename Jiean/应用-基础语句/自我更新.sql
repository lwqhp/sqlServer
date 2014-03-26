

--一个有趣的自我更新
CREATE TABLE tb(
	Item varchar(10),
	Color varchar(10),
	Quantity int
)
INSERT tb SELECT 'Table', 'Blue',   124
UNION ALL SELECT 'Table', 'Red',    60
UNION ALL SELECT 'Table', 'Red',    99
UNION ALL SELECT 'Table', 'Green',  120
UNION ALL SELECT 'Table', 'Green',  110
UNION ALL SELECT 'Chair', 'Yellow', 101
UNION ALL SELECT 'Chair', 'Yellow', 131
UNION ALL SELECT 'Chair', 'Red',    90
UNION ALL SELECT 'Chair', 'White',  55
GO

SELECT 
	Item, Color,
	No = 0
INTO # FROM tb
GROUP BY Item, Color
ORDER BY Item, Color
---------脚本-------------------------------------------------------------
DECLARE
	@Notem varchar(10),
	@No varchar(10)
UPDATE tb SET 
	@No = CASE
			WHEN @Notem = Item THEN @No + 1
			ELSE 1
		END,
	No = @No,
	@Notem = Item

