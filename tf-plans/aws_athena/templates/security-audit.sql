-- Security audit: IAM API calls recorded in CloudTrail logs over the last 30 days.
-- Queries the CloudTrail Logs table in the analytics database.
-- Replace 'cloudtrail_logs' with your actual Athena table name.
SELECT
  eventtime                                AS event_time,
  useridentity.type                        AS identity_type,
  useridentity.arn                         AS identity_arn,
  useridentity.accountid                   AS account_id,
  eventsource                              AS event_source,
  eventname                                AS event_name,
  awsregion                                AS aws_region,
  sourceipaddress                          AS source_ip,
  errorcode                                AS error_code,
  errormessage                             AS error_message
FROM
  cloudtrail_logs
WHERE
  eventsource = 'iam.amazonaws.com'
  AND eventtime >= to_iso8601(current_timestamp - interval '30' day)
  AND (errorcode IS NULL OR errorcode NOT IN ('NoSuchEntityException'))
ORDER BY
  eventtime DESC
LIMIT 100;
