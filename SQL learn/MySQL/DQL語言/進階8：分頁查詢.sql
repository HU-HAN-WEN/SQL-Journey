# 進階8：分頁查詢 (重要)
/*
 * 應用場景：當要顯示的數據，一頁顯示不全，需要分業提交sql請求
 * 語法：					執行順序
 * 		select 查詢列表			7
 * 		from 表				1
 * 		【
 * 		join type join 表2		2
 * 		on 連接條件			3
 * 		where 篩選條件			4
 * 		group by 分組字段		5
 * 		having 分組後的篩選		6
 * 		order by 排序的字段		8
 * 		】
 * 		limit 【offset,】 size ;	9
 * 
 * 備註：
 * 	offset 要顯示條目的起始索引(起始索引從 0 開始)
 * 	size 要顯示條目的個數
 * 特點：
 * 	(1)limit 語句放在查詢語句的最後
 * 	(2)公式：
 * 		範例：要顯示頁數 - page, 每頁的條目數 - size
 * 
 * 		select 查詢列表
 * 		from 表
 * 		limit (page - 1) * size, size ;
 * 
 * 		ex.
 * 		size = 10
 * 		page	size
 * 		1	0
 * 		2	10
 * 		3	20
 */

# 案例一：顯示前五筆的客戶資料集
SELECT * FROM olist_customers oc LIMIT 0,5 ;
SELECT * FROM olist_customers oc LIMIT 5 ;

# 案例二：顯示 11～25 筆的客戶資料集
SELECT * FROM olist_customers oc LIMIT 10,15 ;

# 案例三：找出不是用 'credit_card' 支付的付款紀錄中，支付金額最高的前 5 筆是哪些？
# 對應表格：olist_order_payments

SELECT *
FROM olist_order_payments oop 
WHERE oop.payment_type != 'credit_card'
ORDER BY oop.payment_value DESC
LIMIT 5 ;


# -- 練習 --
# 1. product_category_name_translation 表中的英文類別名稱（例如 beleza_saude）是用底線 _ 連接的，我想只提取底線 _ 前面的主類別名稱（例如 beleza）。
# 對應表格：product_category_name_translation
SELECT
	SUBSTR(pcnt.product_category_name_english, 1, INSTR(pcnt.product_category_name_english, '_')-1) 主類別名稱
FROM
	product_category_name_translation pcnt ;
# 備註：substring() 擷取、INSTR()位置

# 2. 統計 delivered, shipped, canceled 等每種訂單狀態各有多少筆訂單？
# 對應表格：olist_orders
SELECT
    order_status,
    COUNT(order_id)
FROM
    olist_orders
GROUP BY
    order_status;


# 3. 查詢所有已售出的商品中，哪些商品的單價大於 500 (price > 500) 且 重量小於 1000g (product_weight_g < 1000)？請顯示這些商品的訂單 ID 和產品類別名稱。
# 對應表格：olist_order_items, olist_products
SELECT
    oi.order_id,
    p.product_category_name,
    oi.price,
    p.product_weight_g
FROM
    olist_order_items AS oi
JOIN
    olist_products AS p ON oi.product_id = p.product_id 
WHERE 
    oi.price > 500
    AND p.product_weight_g < 1000;


# 4. 找出哪些產品類別 (product_category_name)，它們的最低售價 (MIN(price)) 仍然高於 200 元？（代表這是高單價類別）
# 對應表格：olist_order_items, olist_products
SELECT
    p.product_category_name,
    MIN(oi.price) AS min_price
FROM
    olist_order_items AS oi
JOIN
    olist_products AS p ON oi.product_id = p.product_id
GROUP BY
    p.product_category_name
HAVING
    MIN(oi.price) > 200;

# 5. 試說出查詢語句中涉及到的所有的關鍵字,以及執行先後順序
/*
 * select 查詢列表		(7)
 * from 表			(1)
 * 連接類型 join 表2		(2)
 * on 連接條件			(3)
 * where 篩選條件		(4)
 * group by 分組列表		(5)
 * having 分組後的篩選		(6)
 * order by 排序列表		(8)
 * limit 偏移, 條目數;		(9)
 * 
 */





