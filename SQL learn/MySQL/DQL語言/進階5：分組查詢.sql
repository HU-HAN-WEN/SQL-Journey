# 進階5：分組查詢
/*
 * 語法：
 * 		select 分組函數, 列(要求出現在group by的後面)
 * 		from 表
 * 		【where 篩選條件】
 * 		group by 分組的列表
 * 		【order by 子句】
 * 注意：
 * 		查詢列表必須特殊，要求是分組函數和 group by 後出現的字段
 * 特點：
 * 		1. 分組查詢中的篩選條件分為兩類
 * 						數據源			位置					關鍵字
 * 			分組前篩選		原始表			group by子句的前面		where
 * 			分組後篩選		分組後的結果集		group by子句的後面		having
 * 			(1) 分組函數做條件(原始表查不到)肯定是放在 having 子句中
 * 			(2) 能用分組前篩選的，就優先考慮使用分組前篩選
 * 
 * 		2. group by 子句支持單個字段分組、多個字段分組(多個字段之間用逗號隔開，沒有順序要求)，表達式或函數(用的較少)
 * 
 * 		3. 也可以添加排序(排序放在整個分組查詢的最後)
 * 
 * 		4. ONLY_FULL_GROUP_BY 規則：
 * 		當使用 GROUP BY 時，SELECT清單中的所有欄位，必須「要馬」出現在聚合函數中 (例如 MIN(), COUNT())，
 * 		「要馬」必須一模一樣地出現在 GROUP BY 子句中。
 * 
 */

# 簡單的分組查詢

# 案例一：'credit_card', 'boleto', 'voucher' 等每種付款方式，收到過的最大單筆付款金額各是多少？
SELECT
    MAX(payment_value),
    payment_type
FROM
    olist_order_payments
GROUP BY
    payment_type;

# 案例二：每個州 (customer_state) 分別有多少客戶？
SELECT 
    COUNT(*),
    customer_state 
FROM
    olist_customers
GROUP BY
    customer_state ;


# 添加分組前的篩選條件

# 案例一：所有城市名稱包含 'sao' (例如 Sao Paulo) 的客戶中，他們分別來自哪些州？每個州有多少人？
SELECT
	COUNT(oc.customer_id) ,
	oc.customer_state 
FROM
	olist_customers oc
WHERE
	oc.customer_city LIKE '%sao%'
GROUP BY
	oc.customer_state ;

# 案例二：在所有有填寫重量 (product_weight_g) 的產品中，每種產品類別的平均重量是多少？
SELECT
	op.product_category_name ,
	AVG(op.product_weight_g )
FROM
	olist_products op
WHERE
	op.product_weight_g IS NOT NULL
GROUP BY
	op.product_category_name ;


# 添加分組後的篩選

# 案例一：找出擁有超過 1000 位客戶的「大州」
# 1. 查詢每個州的客戶人數
SELECT
	COUNT(oc.customer_id),
	oc.customer_state
FROM
	olist_customers oc
GROUP BY
	oc.customer_state ;
# 2. 根據1.的結果進行篩選，查詢哪個州的客戶 > 1000
SELECT
	COUNT(oc.customer_id),
	oc.customer_state
FROM
	olist_customers oc
GROUP BY
	oc.customer_state
HAVING
	COUNT(oc.customer_id) > 1000 ;

# 範例二：那些賣家透過銷售所有單價高於 100 元的商品，賺了總金額超過 20000 元
# 1. 查詢每個賣家單價高於 100 的商品賺了多少
SELECT
	SUM(ooi.price),
	ooi.seller_id 
FROM
	olist_order_items ooi
WHERE
	ooi.price > 100
GROUP BY
	ooi.seller_id ;
# 2. 根據1.的結果進行篩選，查詢哪些賣家總金額超過 20000 元
SELECT
	SUM(ooi.price),
	ooi.seller_id 
FROM
	olist_order_items ooi
WHERE
	ooi.price > 100
GROUP BY
	ooi.seller_id 
HAVING 
	SUM(ooi.price) > 2000;


# 按表達式或函數分組

# 案例：按照客戶的城市名稱長度分組，查詢每一組城市客戶，客戶數超過 1000 人的『熱門城市名稱長度』有哪些
# 1. 客戶的城市名稱長度 (LENGTH) 各有多少？
SELECT
	COUNT(*),
	LENGTH(oc.customer_city)
FROM
	olist_customers oc
GROUP BY
	LENGTH(oc.customer_city);

# 2. 客戶數超過 1000 人的『熱門城市名稱長度』
SELECT
	COUNT(*),
	LENGTH(oc.customer_city)
FROM
	olist_customers oc
GROUP BY
	LENGTH(oc.customer_city)
HAVING 
	COUNT(*) > 1000;

# 3. 用別名也可以
SELECT
	COUNT(*) AS 總數,
	LENGTH(oc.customer_city) AS 城市名稱長度
FROM
	olist_customers oc
GROUP BY
	城市名稱長度
HAVING 
	總數 > 1000;


# 按多個字段分組

# 案例：在聖保羅州裡面，是哪個城市的客戶最多？每個州下屬的每個城市的客戶人數？ (多個字段之間用逗號隔開，沒有順序要求)
SELECT
	COUNT(*),
	oc.customer_city,
	oc.customer_state
FROM
	olist_customers oc
GROUP BY
	oc.customer_state,
	oc.customer_city ;


# 添加排序

# 案例：在聖保羅州裡面，是哪個城市的客戶最多？每個州下屬的每個城市的客戶人數？ 按照人數的多寡進行排序
SELECT
	COUNT(*),
	oc.customer_city,
	oc.customer_state
FROM
	olist_customers oc
GROUP BY
	oc.customer_state,
	oc.customer_city
ORDER BY
	COUNT(*) DESC;



# -- 練習 --

# 1. 分析 'credit_card', 'boleto' 等每種付款方式，它們各自的最大單筆金額、最小單筆金額、平均金額、以及總收入各是多少？並按付款方式字母排序
# 對應表格：olist_order_payments
SELECT
	oop.payment_type,
	MAX(oop.payment_value),
	MIN(oop.payment_value),
	AVG(oop.payment_value),
	SUM(oop.order_id)
FROM
	olist_order_payments oop
GROUP BY 
	oop.payment_type
ORDER BY
	oop.payment_type ;

# 2. 訂單數據總共涵蓋了多長的時間？
# 對應表格：olist_orders
SELECT
	MAX(oo.order_purchase_timestamp) 最晚的訂單時間,
	MIN(oo.order_purchase_timestamp) 最早的訂單時間,
	DATEDIFF(MAX(oo.order_purchase_timestamp), MIN(oo.order_purchase_timestamp)) 總計天數
FROM
	olist_orders oo ;

# 3. 找出那些平均重量超過 5 公斤 (5000g) 的『重型產品類別』，但在計算時不考慮那些沒有填寫重量的產品。
# 對應表格：olist_products
SELECT
	op.product_category_name,
	AVG(op.product_weight_g)
FROM
	olist_products op
WHERE
	op.product_weight_g IS NOT NULL
GROUP BY
	op.product_category_name
HAVING
	AVG(op.product_weight_g) > 5000;

# 4. 每種付款方式被使用了多少次，以及它們的平均支付金額是多少？按平均金額降序排列。
# 對應表格：olist_order_payments
SELECT
	COUNT(*),
	oop.payment_type,
	AVG(oop.payment_value)
FROM
	olist_order_payments oop
GROUP BY 
	oop.payment_type
ORDER BY
	AVG(oop.payment_value) DESC ;

# 5. delivered, shipped, canceled 等三種訂單狀態各有多少筆訂單？
# 對應表格：olist_orders
SELECT
	COUNT(*),
	oo.order_status
FROM
	olist_orders oo
WHERE 
	oo.order_status IN ('delivered', 'shipped', 'canceled')
GROUP BY
	oo.order_status ;

