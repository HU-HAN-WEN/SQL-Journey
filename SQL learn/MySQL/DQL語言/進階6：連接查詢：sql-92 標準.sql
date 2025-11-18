# 進階6：連接查詢一：sql-92 標準
/*
 * 含意：又稱多表查詢，當查詢的字段來自於多個表時，就會用到連接查詢
 * 
 * 笛卡爾乘積現象：表 1 有 m 行，表 2 有 n 行，結果 = m * n 行
 * 		發生原因：沒有有效的連接條件
 * 		如何避免：添加有效的連接條件
 * 
 * 分類：
 * 		按年代分類：
 * 					sql92 標準		：僅僅支持內連接
 * 					sql99 標準【推薦】	：支持內連接 + 外連接(左外和右外) + 交叉連接
 * 		按功能分類：
 * 					內連接：
 * 							等值連接
 * 							非等值連接
 * 							自連接
 * 					外連接：
 * 							左外連接
 * 							右外連接
 * 							全外連接
 * 					交叉連接
 * 
 */

# 一、sql92 標準
# 1. 等值連接
/*
 * (1)多表等值連接的結果為多表的交集部分
 * (2) n 表連接，至少需要 n-1 個連接條件
 * (3)多表的順序沒有要求
 * (4)一般需要為表起別名
 * (5)可以搭配前面的所有子句使用，比如：排序、分組、篩選
 */

# 案例一：想知道每筆訂單的狀態，以及下這筆訂單的客戶所在的城市是哪裡？
# 對應表格：olist_orders, olist_customers
SELECT
	oo.customer_id,
	oo.order_status,
	oc.customer_city,
	oc.customer_state
FROM
	olist_orders oo,
	olist_customers oc
WHERE
	oo.customer_id = oc.customer_id ;

# 案例二：賣出去的每個商品項，對應的產品類別是什麼？
# 對應表格：olist_order_items, olist_products
SELECT
	ooi.product_id,
	ooi.price,
	op.product_category_name
FROM
	olist_order_items ooi,
	olist_products op
WHERE
	ooi.product_id = op.product_id ;


# (1) 為表起別名
/*
 * 好處：
 * 		1. 提高語句簡潔度 
 * 		2. 區分多個重名字段
 * 
 * 注意：如果為表起了別名，則查詢的字段就不能使用原來的表名去限定
 * 
 */

# 查詢賣出去的每個商品項與它對應的產品類別
SELECT
    ooi.order_id,
    ooi.price, 
    op.product_category_name,
    ooi.product_id
FROM
    olist_order_items ooi, 
    olist_products op 
WHERE
    ooi.product_id = op.product_id ;


# (2) 兩個表的順序可以調換
# 查詢賣出去的每個商品項與它對應的產品類別
SELECT
    ooi.order_id,
    ooi.price, 
    op.product_category_name,
    ooi.product_id
FROM 
    olist_products op,
    olist_order_items ooi
WHERE
    ooi.product_id = op.product_id ;


# (3) 可以加篩選？

# 案例一：所有已經付款（付款核准時間 order_approved_at 不是 NULL）的訂單，這些客戶分別來自哪個城市？
SELECT
	oo.customer_id ,
	oo.order_approved_at ,
	oc.customer_city
FROM
	olist_orders oo,
	olist_customers oc
WHERE 
	oo.customer_id = oc.customer_id
	AND 
	oo.order_approved_at IS NOT NULL ;

# 案例二：所有產品類別名稱以 'beleza' (美麗) 開頭的商品，它們在訂單中的銷售價格 (price) 各是多少？
SELECT
	ooi.product_id ,
	ooi.price ,
	op.product_category_name
FROM
	olist_order_items ooi ,
	olist_products op
WHERE 
	ooi.product_id = op.product_id
	AND
	op.product_category_name LIKE 'beleza%' ;


# (4) 可以加分組
# 案例一：'beleza_saude', 'informatica_acessorios' 等每個產品類別，總共被購買了多少次？
SELECT
	COUNT(ooi.product_id),
	op.product_category_name
FROM
	olist_order_items ooi,
	olist_products op
WHERE
	ooi.product_id = op.product_id
GROUP BY
	op.product_category_name ;

# 案例二：那些已成功送達 (delivered) 的訂單中，想知道 'credit_card' 分1期、2期、3期，以及 'boleto' 分1期... 等每種組合的最低支付金額是多少？
SELECT
	oop.payment_type,
	oop.payment_installments,
	MIN(oop.payment_value),
FROM
	olist_order_payments oop,
	olist_orders oo
WHERE
	oop.order_id = oo.order_id 
	AND
	oo.order_status IN ('delivered')
GROUP BY 
	oop.payment_type,
	oop.payment_installments
ORDER BY 
	oop.payment_type, oop.payment_installments ;


# (5) 可以加排序

# 案例一：哪個產品類別 (product_category_name) 總共賣出的金額 (SUM(price)) 最多？請按總金額從高到低列出來。
SELECT
	op.product_category_name,
	SUM(ooi.price)
FROM
	olist_order_items ooi,
	olist_products op
WHERE 
	ooi.product_id = op.product_id
GROUP BY 
	op.product_category_name
ORDER BY
	SUM(ooi.price) DESC ;

# 案例二：每筆訂單的狀態 (order_status)，以及該訂單中購買的商品類別 (product_category_name) 是什麼？
SELECT
	oo.order_status,
	op.product_category_name
FROM
	olist_orders oo,
	olist_order_items ooi,
	olist_products op
WHERE 
	oo.order_id = ooi.order_id 
	AND
	ooi.product_id = op.product_id ;



# 2. 非等值連接
# (1)先建立存放「支付金額等級」的表格

CREATE TABLE payment_value_grades (
    grade_level CHAR(1), -- 等級 (A, B, C...)
    lowest_value DECIMAL(10, 2), -- 該等級的最低金額
    highest_value DECIMAL(10, 2) -- 該等級的最高金額
);
-- 插入分級規則
INSERT INTO payment_value_grades VALUES ('E', 0, 50);      -- 50元及以下為 E 級
INSERT INTO payment_value_grades VALUES ('D', 50.01, 150); -- 50.01 到 150 為 D 級
INSERT INTO payment_value_grades VALUES ('C', 150.01, 300); -- 150.01 到 300 為 C 級
INSERT INTO payment_value_grades VALUES ('B', 300.01, 600); -- 300.01 到 600 為 B 級
INSERT INTO payment_value_grades VALUES ('A', 600.01, 99999); -- 600.01 以上為 A 級 (99999代表一個很大的數)

# (2)執行「非等值連接」
# 範例：查詢每一筆支付紀錄 (payment_value)，並為它們標上對應的『金額級別』(grade_level)。
SELECT
	oop.order_id,
	oop.payment_value,
	pvg.grade_level
FROM
	olist_order_payments oop,
	payment_value_grades pvg
WHERE
	oop.payment_value BETWEEN pvg.lowest_value AND pvg.highest_value ;



# 3. 自連接
# 案例：找出哪些客戶是『回頭客』。如果一個客戶下了多筆訂單，請幫我列出他們的『訂單配對』（例如，訂單 A 和 訂單 B 來自同一個客戶）。
SELECT
	oc1.customer_unique_id,
	oc1.customer_id,
	oc2.customer_id
FROM
	olist_customers oc1,
	olist_customers oc2
WHERE
	oc1.customer_unique_id = oc2.customer_unique_id
	AND
	oc1.customer_id != oc2.customer_id 
	AND
	oc1.customer_id < oc2.customer_id ; -- 避免 (A,B) 和 (B,A) 這種重複配對




# --- 練習 ---
# 1. 平台上所有產品的最大重量、最小重量、以及平均重量各是多少？
# 對應表格：olist_products
SELECT
	MAX(op.product_weight_g) 最大重量,
	MIN(op.product_weight_g) 最小重量,
	AVG(op.product_weight_g) 平均重量
FROM
	olist_products op ;

# 2. 查看一份客戶名單，要求先按照州 (customer_state) 的字母順序從 Z 到 A (DESC) 排列；
#    如果州相同，再按照城市 (customer_city) 的字母順序從 A 到 Z (ASC) 排列。
# 對應表格：olist_customers
SELECT
	oc.customer_state,
	oc.customer_city
FROM
	olist_customers oc
ORDER BY
	oc.customer_state DESC,
	oc.customer_city ASC ;

# 3. 找出那些產品類別名稱 (product_category_name) 中，既包含字母 'a' 又包含字母 'o'，並且 'a' 出現在 'o' 之前的所有類別。
# 對應表格：olist_products
SELECT
	DISTINCT op.product_category_name
FROM
	olist_products op
WHERE 
	op.product_category_name LIKE '%a%o%' ;
	
# 4. 每筆訂單商品項 (order_id)，是由哪個城市 (seller_city) 的哪個賣家 (seller_id) 售出的？
# 對應表格：olist_orders, olist_order_items, olist_sellers
SELECT
	oo.order_id,
	ooi.product_id,
	ooi.seller_id,
	os.seller_city 
FROM
	olist_orders oo,
	olist_order_items ooi,
	olist_sellers os 
WHERE 
	oo.order_id = ooi.order_id ;

# 5. 現在時間是？如果城市名稱前後有空格怎麼辦？如何獲取郵遞區號的前 3 碼作為大區編號？
SELECT
	NOW() AS 現在時間 ;

SELECT TRIM('  sao paulo  ')  AS 城市名稱;

SELECT
	oc.customer_zip_code_prefix,
	SUBSTRING(oc.customer_zip_code_prefix, 1, 3)
FROM
	olist_customers oc;

# TRIM() 移除一個字串開頭 (LEADING) 和結尾 (TRAILING) 的特定字元，最常用來去除多餘的空格。
	# LTRIM(string)：只清除左邊 (Left) 的空格。
	# RTRIM(string)：只清除右邊 (Right) 的空格。
# select substr(str, startIndex, length); (指定開頭和長度)