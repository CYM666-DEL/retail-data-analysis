#1.数据概览和质量检查
SELECT 
'数据概览' AS 分析类型,
COUNT(*) AS 总记录,
COUNT(DISTINCT InvoiceNo) AS 发票种类,
COUNT(DISTINCT CustomerID) AS 客户ID种类,
COUNT(DISTINCT StockCode) AS 产品种类,
COUNT(DISTINCT Country) AS 覆盖国家
FROM retail_transactions;

#检查缺失值
SELECT
'数据质量检查' AS check_type,
SUM(CASE WHEN CustomerID IS NULL OR CustomerID = '' THEN 1 ELSE 0 END) AS missing_customer_ids,
SUM(CASE WHEN Description IS NULL OR Description = '' THEN 1 ELSE 0 END) AS missing_descriptions,
SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantities
FROM retail_transactions;

#2.销售绩效分析
#2010年度销售额
SELECT 
'2010年度销售总览' AS metric,
ROUND(SUM(quantity*unitprice))AS total_revenue,
SUM(quantity)as total_quantity_sold,
COUNT(DISTINCT InvoiceNo) AS total_transactions,
ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2) AS avg_transaction_value
FROM retail_transactions
WHERE Quantity > 0 AND InvoiceDate like '2010%';

##2011年度销售额
SELECT 
'2011年度销售总览' AS metric,
ROUND(SUM(quantity*unitprice))AS total_revenue,
SUM(quantity)as total_quantity_sold,
COUNT(DISTINCT InvoiceNo) AS total_transactions,
ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2) AS avg_transaction_value
FROM retail_transactions
WHERE Quantity > 0 AND InvoiceDate like '2011%';

#3.客户分析
#高价值客户TOP 10
SELECT 
CustomerID,
ROUND(SUM(Quantity * UnitPrice), 2) AS total_spent,
COUNT(DISTINCT InvoiceNo) AS transaction_count,
ROUND(SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2) AS avg_transaction_value
FROM retail_transactions
WHERE Quantity > 0 AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_spent DESC
LIMIT 10;
#客户平均消费
SELECT
ROUND(SUM(UnitPrice*Quantity),2) AS total_spent,
COUNT(DISTINCT InvoiceNo) AS transaction_count,
ROUND(SUM(UnitPrice*Quantity)/COUNT(DISTINCT InvoiceNo),2)AS avg_spent
FROM retail_transactions;

#4.产品分析
#每日销售趋势
SELECT 
DATE(InvoiceDate) AS sales_date,
ROUND(SUM(Quantity * UnitPrice), 2) AS daily_revenue,
COUNT(DISTINCT InvoiceNo) AS daily_transactions,
SUM(Quantity) AS daily_quantity
FROM retail_transactions
WHERE Quantity > 0
GROUP BY DATE(InvoiceDate)
ORDER BY sales_date;

#最畅销商品TOP 10
SELECT 
StockCode,
Description,
SUM(Quantity) AS total_quantity_sold,
ROUND(SUM(Quantity*UnitPrice), 2) AS total_revenue,
ROUND(AVG(UnitPrice), 2) AS avg_price
FROM retail_transactions
WHERE Quantity > 0
GROUP BY StockCode, Description
ORDER BY total_revenue DESC
LIMIT 10;

#最畅销的国家TOP3
SELECT 
Country,
COUNT(DISTINCT CustomerID) AS customer_count,
COUNT(DISTINCT InvoiceNo) AS transaction_count,
ROUND(SUM(Quantity*UnitPrice), 2) AS total_revenue
FROM retail_transactions
WHERE Quantity>0
GROUP BY Country 
ORDER BY total_revenue DESC
LIMIT 3;

#5.退货分析
#退货率
SELECT 
SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END) as return_invoices,
COUNT(*) as total_invoices,
ROUND(SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END)*100.0/COUNT(*), 2) 
AS 退货率
FROM retail_transactions;
