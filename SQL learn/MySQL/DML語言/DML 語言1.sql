# DML 語言

/*
 * 數據操作語言：
 * 		數據插入：insert
 * 		數據修改：update
 * 		數據刪除：delete
 */

# 一、經典的插入語句
/*
 * 語法：
 * 	insert into 表格(列名, ...) values (值1, ...) ;
 * 
 */

# 1. 插入值的類型要與列的類型一致或兼容
# 案例：Olist 平台決定引進台灣的特色商品！但系統裡沒有「台灣美食」這個分類。需要手動加入這個新分類的葡文和英文翻譯。
INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES ('comida_taiwan_bubble_tea', 'taiwanese_bubble_tea_and_snacks');
	# 驗證
	SELECT * FROM product_category_name_translation 
	WHERE product_category_name LIKE 'comida_taiwan_bubble_tea%';

# 2. 不可為 NULL 的列必須插入值；可以為 NULL 的列可以省略不寫
	# 驗證
	SELECT * FROM olist_products op WHERE op.product_id LIKE 'smart_speaker_google%';
# 方式一：
INSERT INTO olist_products (product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty)
VALUES ('smart_speaker_google_01', 'eletronicos', NULL, NULL, 3);
# 方式二：
INSERT INTO olist_products (product_id, product_category_name, product_photos_qty)
VALUES ('smart_speaker_google_02', 'eletronicos', 5);

# 3. 列的順序是否可以調換
INSERT INTO olist_products (product_category_name, product_id, product_photos_qty)
VALUES ('eletronicos','smart_speaker_google_02', 5);

# 4. 列和值的個數必須一致

# 5. 可以省略列名，默認是所有列，且列的順序與表中列的順序是一致
# 方式一：
INSERT INTO olist_products 
VALUES ('smart_speaker_google_05', 'eletronicos', NULL, NULL, 3, NULL, NULL, NULL, NULL) ;
# 方式二：
/* 語法：
 * insert into 表名
 * set 列名 = 值, 列名 = 值, ...
 */
INSERT INTO olist_products
SET product_id = 'smart_speaker_google_06', product_category_name = 'eletronicos', product_photos_qty = 10 ;

# 兩種方式大 PK
# 1. 方式一支持插入多行；方式二不支持
INSERT INTO product_category_name_translation
VALUES ('comida_taiwan_bubble_tea2', 'taiwanese_bubble_tea_and_snacks2'),
('comida_taiwan_bubble_tea3', 'taiwanese_bubble_tea_and_snacks3'),
('comida_taiwan_bubble_tea4', 'taiwanese_bubble_tea_and_snacks4') ;

# 2. 方式一支持子查詢；方式二不支持
INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
SELECT 'comida_taiwan_bubble_tea5', 'taiwanese_bubble_tea_and_snacks5';


# 警告！UPDATE 會永久修改您的資料庫資料，請謹慎操作！

# 二、修改語句
/*
 * 1. 修改單表的紀錄
 * 	語法：
 * 		update 表名
 * 		set 列 = 新值, 列 = 新值, ...
 * 		where 篩選條件
 * 
 * 2. 修改多表的紀錄(補充)
 * 	語法：
 * 		(1)sql-92 語法：
 * 			update 表1 別名, 表2 別名
 * 			set 列 = 值, ...
 * 			where 連接條件
 * 			and 篩選條件 ;
 * 
 * 		(2)sql-99 語法：
 * 			update 表1 別名
 * 			inner|left|right join 表2 別名
 * 			on 連接條件
 * 			set 列 = 值, ...
 * 			where 篩選條件 ;
 */


# 1. 修改單表的紀錄
# 案例一：修改 olist_products 表中 product_id 為 smart_speaker_google_的產品類型從電子轉為化妝品
UPDATE olist_products 
SET product_category_name = 'cosmético'
WHERE product_id LIKE 'smart_speaker_google_%' ;

# 案例二：修改 olist_products 表中 product_id 為 smart_speaker_google_05 的 product_photos_qty 為 8
UPDATE olist_products 
SET product_photos_qty = 8
WHERE product_id = 'smart_speaker_google_05' ;

# 備註：後在執行 UPDATE 或 DELETE 這種危險指令前，可以養成一個好習慣：先用 SELECT 查查看
/*
 * 先查詢
 *  SELECT * FROM olist_products WHERE product_id = 'smart_speaker_google_05';
 * 
 * 再修改
 * update olist_products SET product_photos_qty = 8
 * WHERE product_id = 'smart_speaker_google_05' ;
 */


# 2. 修改多表的紀錄(sql-99)

# 案例一：想找出兩類特殊的訂單商品，並把它們列在同一張清單上：
# 1. 高價值商品：單價 (price) 大於 500 的。
# 2. 超低運費商品：運費 (freight_value) 小於 5 的。」

-- 查詢 1：高價值商品
SELECT ooi.order_id, ooi.product_id, ooi.price, ooi.freight_value, 'Hight price' AS tag
FROM olist_order_items ooi 
WHERE price > 500

UNION -- 關鍵字：合併兩個查詢結果 (自動去重)

-- 查詢 2：低運費商品
SELECT ooi.order_id, ooi.product_id, ooi.price, ooi.freight_value, 'Low freight' AS tag
FROM olist_order_items ooi 
WHERE ooi.freight_value  < 5;


# 案例二：假設因為里約熱內盧 (Rio de Janeiro) 發生突發天災，物流中斷。
# 老闆要求將所有來自該城市且目前狀態為 'processing' (處理中) 的訂單，緊急修改為 'unavailable' (無法配送)。
UPDATE olist_orders oo 
INNER JOIN olist_customers oc ON oo.customer_id = oc.customer_id 
SET oo.order_status = 'unavailable'
WHERE oc.customer_state = "RJ"
AND oo.order_status = "processing";


SELECT *
FROM olist_orders oo 
INNER JOIN olist_customers oc ON oo.customer_id = oc.customer_id 
WHERE oc.customer_state = "RJ" AND oo.order_status = "processing";

-- 修正回來
UPDATE olist_orders oo 
INNER JOIN olist_customers oc ON oo.customer_id = oc.customer_id 
SET oo.order_status = 'processing' -- 改回處理中
WHERE oc.customer_state = 'RJ' -- 修正為縮寫
AND oo.order_status = 'unavailable'; -- 只針對被改成不可用的訂單














