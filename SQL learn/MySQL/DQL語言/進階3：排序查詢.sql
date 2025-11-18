# 進階3：排序查詢.sql
# 引入

/*
 * 引入：
 * 		select * from employees;
 * 
 * 語法：
 * 		select 查詢列表
 * 		from 表
 * 		【where 篩選條件】
 * 		order by 排序列表 【 asc | desc 】
 * 特點：
 *		1. asc 代表的是升序，desc 代表的是降序 (如果都不寫默認為＂升序＂)
 *		2. order by 子句中可以支持單個字段、多個字段、表達式、函數、別名
 *		3. order by 子句一般是放在查詢句的最後面， limit 子句除外 (不能更換順序否則出錯)
 */

# 案例1：查詢支付數據，依照付款金額高到低排序
SELECT
	*
FROM
	olist_order_payments
ORDER BY
	payment_value DESC ;

# 案例2：查詢訂單分期付款的期數 >= 6 的顧客訊息，按付款金額小到大排序【添加篩選條件】
SELECT
	*
FROM
	olist_order_payments AS oop
WHERE
	oop.payment_installments >= 6
ORDER BY
	oop.payment_value ASC ;

# 案例3：按產品「估算體積」對產品進行排序 【按表達式排序】
SELECT
	*,
	ifnull(op.product_length_cm, 1) * IFNULL(op.product_height_cm, 1) * IFNULL(op.product_width_cm, 1) AS 體積
FROM
	olist_products AS op
ORDER BY
	ifnull(op.product_length_cm, 1) * IFNULL(op.product_height_cm, 1) * IFNULL(op.product_width_cm, 1) ASC ;

# 案例4：按產品「估算體積」對產品進行排序 【按別名排序】
SELECT
	*,
	ifnull(op.product_length_cm, 1) * IFNULL(op.product_height_cm, 1) * IFNULL(op.product_width_cm, 1) AS 體積
FROM
	olist_products AS op
ORDER BY
	體積 ASC ;

# 案例5：按客戶所在城市名稱長度顯示顧客ID 【按函數排序】
SELECT
	LENGTH(oc.customer_city) AS 城市名稱長度,
	oc.customer_city ,
	oc.customer_state
FROM
	olist_customers oc
ORDER BY
	城市名稱長度 DESC;

# 案例5：查詢付款紀錄，要求先按付款方式字母升序排，再按付款金額降序排 【按多個字段排序】
SELECT
	oop.order_id ,
	oop.payment_installments ,
	oop.payment_type ,
	oop.payment_value
FROM
	olist_order_payments oop
ORDER BY
	oop.payment_type ASC,
	oop.payment_value DESC;


# --- 練習 ---
# 1. 查詢支付紀錄，先按付款金額 (payment_value) 降序排，金額相同時再按付款方式 (payment_type) 字母升序排
# 對應表格：olist_order_payments
SELECT
	*
FROM
	olist_order_payments AS oop
ORDER BY
	oop.payment_value DESC,
	oop.payment_type ASC;

# 2. 查詢產品重量不在 500g 到 2000g 之間的產品資訊，按重量降序排列
# 對應表格：olist_products
SELECT
	op.product_id ,
	op.product_category_name ,
	op.product_weight_g
FROM
	olist_products AS op
WHERE
	op.product_weight_g NOT BETWEEN 500 AND 2000
ORDER BY
	op.product_weight_g DESC;

# 3. 查詢城市名稱中包含 'a' 的客戶信息，先按城市名稱的字節長度降序排，再按州 (customer_state) 字母升序排
# 對應表格：olist_customers
SELECT
	oc.customer_id ,
	oc.customer_city ,
	LENGTH(oc.customer_city) AS 城市名稱字節長度,
	oc.customer_state
FROM
	olist_customers AS oc
WHERE
	oc.customer_city LIKE '%a%'
ORDER BY
	城市名稱字節長度 DESC,
	oc.customer_state ASC;
