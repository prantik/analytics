-- This script comptues 3 of the 4 company-wide growth metrics for 2012 Q3.

-- For the definition of the company_metrics table, see ka_hive_init


-- Note: Metric 1 (Unique visitors) is easily pulled from Google analytics
-- (but not from Hive) and thus is not computed here.


-- Note: userdata_info is a view, and that can apparently cause 
-- problems with "predicate pushdown" query optimization
-- http://karmasphere.com/hive-queries-on-table-data#lateral_view_syntax
set hive.optimize.ppd=false;

-- Metric 2, Registrations
INSERT OVERWRITE TABLE company_metrics PARTITION (series='registrations')
SELECT month, count(distinct user) AS total
FROM (
  SELECT 
    u.user as user, 
    substr(from_unixtime(floor(u.joined)), 1, 7) AS month
  FROM userdata_info u
  WHERE u.registered
) registrations
GROUP BY month
ORDER BY month;


-- Metric 3, Long-term users
INSERT OVERWRITE TABLE company_metrics PARTITION (series='long term users')
SELECT month, count(distinct user) AS total
FROM (
  SELECT user_daily_activity.user, substr(user_daily_activity.dt, 1, 7) AS month
  FROM user_daily_activity 
  JOIN userdata_info
  ON user_daily_activity.user = userdata_info.user
  WHERE datediff(user_daily_activity.dt, 
                 from_unixtime(floor(userdata_info.joined))) >= 28 
        AND userdata_info.registered
) jointable
GROUP BY month
ORDER BY month;
  

-- Metric 4, Engagement
INSERT OVERWRITE TABLE company_metrics PARTITION (series='highly engaged users')
SELECT month, COUNT(distinct user) AS total
FROM (

  SELECT 
    substr(user_daily_activity.dt, 1, 7) AS month, 
    user_daily_activity.user AS user, 
    COUNT(1) AS active_visits
  FROM user_daily_activity
  JOIN userdata_info
  ON user_daily_activity.user = userdata_info.user
  WHERE userdata_info.registered
  GROUP BY user_daily_activity.user, substr(user_daily_activity.dt, 1, 7)

) monthly
WHERE monthly.active_visits >= 4
GROUP BY month
ORDER BY month;

-- Reset back to the usual value.  See Comments above.
set hive.optimize.ppd=true;
