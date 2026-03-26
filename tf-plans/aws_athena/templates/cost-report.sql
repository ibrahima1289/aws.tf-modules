-- Monthly cost report: top 10 AWS services by total unblended cost.
-- Queries the Cost and Usage Report (CUR) table in the analytics database.
-- Replace 'cost_and_usage_report' with your actual CUR table name.
-- Replace the year/month filter values with the target billing period.
SELECT
  line_item_product_code                   AS service,
  line_item_usage_account_id               AS account_id,
  SUM(line_item_unblended_cost)            AS total_unblended_cost_usd,
  SUM(line_item_usage_amount)              AS total_usage_amount,
  line_item_usage_type                     AS usage_type
FROM
  cost_and_usage_report
WHERE
  year  = '2025'
  AND month = '1'
  AND line_item_line_item_type NOT IN ('Credit', 'Refund', 'Tax')
GROUP BY
  line_item_product_code,
  line_item_usage_account_id,
  line_item_usage_type
ORDER BY
  total_unblended_cost_usd DESC
LIMIT 10;
