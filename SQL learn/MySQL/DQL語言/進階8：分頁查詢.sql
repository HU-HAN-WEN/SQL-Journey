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


# -- 練習 --
# 1. 找出單筆支付金額最高的那筆紀錄，它的訂單 ID、付款方式和金額各是多少？」
# 對應表格：olist_order_payments

# (1)找出單筆支付金額最高的那筆紀錄
SELECT
	MAX(payment_value)
FROM
	olist_order_payments ;
# (2)在(1)情況下，它的訂單 ID、付款方式和金額
SELECT
	order_id,
	payment_type,
	payment_value
FROM
	olist_order_payments
WHERE
	payment_value = (
	SELECT
		MAX(payment_value)
	FROM
		olist_order_payments
    );


# 2. 'credit_card', 'boleto', 'voucher' 等每種付款方式中，哪一種的平均支付金額是最低的？」
# 對應表格：olist_order_payments
SELECT
	oop.payment_type ,
	SUM(oop.payment_value)
FROM
	olist_order_payments oop
GROUP BY
	oop.payment_type
ORDER BY
	SUM(oop.payment_value)
LIMIT 1 ;


# 3. 哪個產品類別 (product_category_name) 的總銷售額 (SUM(price)) 是最高的？
# 對應表格：olist_order_items, olist_products
SELECT
	op.product_category_name,
	SUM(ooi.price) 總銷售額
FROM
	olist_order_items ooi
JOIN olist_products op ON
	ooi.product_id = op.product_id
GROUP BY
	op.product_category_name
ORDER BY
	總銷售額 DESC
LIMIT 1 ;


# 4. 哪個州 (seller_state) 的賣家，他們售出商品的平均運費 (AVG(freight_value)) 是最高的？
# 對應表格：olist_order_items, olist_sellers
SELECT
	os.seller_state,
	AVG(ooi.freight_value) 平均運費
FROM
	olist_order_items ooi
JOIN olist_sellers os ON
	ooi.seller_id = os.seller_id
GROUP BY
	os.seller_state
ORDER BY
	平均運費 DESC
LIMIT 1 ;


# 5. 哪些付款方式 (payment_type)，它們的平均支付金額，高於『所有付款方式的總平均值』？
# 對應表格：olist_order_payments

# (1)所有付款方式的總平均值
SELECT
	AVG(oop.payment_value)
FROM
	olist_order_payments oop ;
# (2)付款方式 (payment_type)的平均支付金額 > (1)
SELECT
	oop1.payment_type,
	AVG(oop1.payment_value) 平均支付金額
FROM
	olist_order_payments oop1
GROUP BY
	oop1.payment_type
HAVING
	平均支付金額 > (
	SELECT
		AVG(oop.payment_value)
	FROM
		olist_order_payments oop
) ;


# 6. 從 olist_sellers (賣家總表) 中，找出所有至少在 olist_order_items (訂單商品表) 中出現過的賣家，並列出他們的城市和州。
# 對應表格：olist_order_items, olist_sellers

# (1)至少在 olist_order_items (訂單商品表) 中出現過的賣家
SELECT
	DISTINCT ooi.seller_id
FROM
	olist_order_items ooi ;
# (2)在(1)篩選下出現過的賣家，並列出他們的城市和州
SELECT
	os.seller_id,
	os.seller_city,
	os.seller_state
FROM
	olist_sellers os
WHERE
	os.seller_id IN (
	SELECT
			DISTINCT ooi.seller_id
	FROM
			olist_order_items ooi 
) ;


# 7. 找出「平均運費最低」的那個「產品類別」中，最貴的商品單價是多少
# 對應表格：olist_order_items, olist_products

# (1)找出『平均運費 (AVG(freight_value)) 最低』的那個產品類別 (product_category_name)
SELECT
	op2.product_category_name
FROM
	olist_order_items ooi2
JOIN olist_products op2 ON
	ooi2.product_id = op2.product_id
GROUP BY
	op2.product_category_name
ORDER BY
	AVG(ooi2.freight_value)
LIMIT 1 ;

# (2)查詢(1)類別的最高商品單價 (MAX(price)) 是多少？
SELECT
	op.product_category_name ,
	MAX(ooi.price)
FROM
	olist_order_items ooi
JOIN olist_products op ON
	ooi.product_id = op.product_id
WHERE
	op.product_category_name = (
	SELECT
			op2.product_category_name
	FROM
			olist_order_items ooi2
	JOIN olist_products op2 ON
			ooi2.product_id = op2.product_id
	GROUP BY
			op2.product_category_name
	ORDER BY
			AVG(ooi2.freight_value)
	LIMIT 1 
)
GROUP BY
	op.product_category_name ; -- 因為主查詢用了 MAX()，所以需要 GROUP BY


# 8. 找出 Olist 平台上總銷售額 (SUM(price)) 最高的那個賣家 (seller_id)，然後查詢他所在的城市和州。
# 對應表格：olist_order_items, olist_sellers
	
# (1)Olist 平台上總銷售額 (SUM(price)) 最高的那個賣家 (seller_id)
SELECT
	ooi.seller_id
FROM
	olist_order_items ooi
GROUP BY
	ooi.seller_id
ORDER BY
	SUM(ooi.price) DESC
LIMIT 1 ;

# (2)查詢(1)所在的城市和州
SELECT
	os.seller_city,
	os.seller_state
FROM
	olist_sellers os
WHERE
	os.seller_id = (
	SELECT
		ooi.seller_id
	FROM
		olist_order_items ooi
	GROUP BY
		ooi.seller_id
	ORDER BY
		SUM(ooi.price) DESC
	LIMIT 1
) ;
	



