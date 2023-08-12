// Page With No Likes [Facebook SQL Interview Question]
SELECT pages.page_id as PageID FROM pages 
LEFT JOIN page_likes ON pages.page_id = page_likes.page_id
WHERE user_id is NULL ORDER BY PageID ASC;

//Unfinished Parts [Tesla SQL Interview Question]
SELECT part, assembly_step FROM parts_assembly WHERE finish_date is NULL;

//Histogram of Tweets [Twitter SQL Interview Question]
SELECT tweet_bucket, COUNT(user_id) as users_num FROM (
  SELECT user_id, COUNT(msg) as tweet_bucket FROM tweets 
  WHERE EXTRACT(year from tweet_date) = 2022
  GROUP BY user_id) A
GROUP BY tweet_bucket
ORDER BY tweet_bucket ASC;

//Laptop vs. Mobile Viewership [New York Times SQL Interview Question]
SELECT laptop_views, mobile_views FROM (
  SELECT COUNT(device_type) AS laptop_views FROM viewership
    WHERE device_type IN ('laptop')
    GROUP BY device_type) A, 
  (SELECT SUM(mobile_views) as mobile_views FROM(
    SELECT COUNT(device_type) AS mobile_views FROM viewership
      WHERE device_type IN ('tablet', 'phone')
      GROUP BY device_type) C) B;

 //Data Science Skills [LinkedIn SQL Interview Question]
 SELECT candidate_id FROM
  (SELECT candidate_id, string_agg(skill,', ') as skills  FROM candidates
  GROUP BY candidate_id) A
WHERE skills LIKE '%Tableau%'
  AND skills LIKE '%Python%'
  AND skills LIKE '%PostgreSQL%'
ORDER BY candidate_id ASC;

//Teams Power Users [Microsoft SQL Interview Question]
SELECT sender_id, COUNT(message_id) as message_count 
FROM messages
WHERE EXTRACT(year from sent_date) = 2022 AND EXTRACT(month from sent_date) = 8
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2;

//Average Post Hiatus (Part 1) [Facebook SQL Interview Question]
SELECT user_id, days_between FROM (
  SELECT user_id, DATE_PART('day',MAX(post_date) - MIN(post_date)) as days_between 
  FROM posts
  WHERE EXTRACT(year FROM post_date) = 2021
  GROUP BY user_id
) A 
WHERE days_between > 0
ORDER BY user_id ASC;


//Duplicate Job Listings [Linkedin SQL Interview Question]
SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM (
  SELECT 
    company_id, 
    title, 
    description, 
    COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY company_id, title, description
) AS job_count_cte
WHERE job_count > 1;

//Average Review Ratings [Amazon SQL Interview Question]
SELECT EXTRACT(month FROM submit_date) as month, product_id, AVG(stars)::numeric(10,2)  as avg_stars
FROM reviews
GROUP BY product_id, EXTRACT(month FROM submit_date)
ORDER BY month, product_id;

//App Click-through Rate (CTR) [Facebook SQL Interview Question]
SELECT app_id,ROUND(100.0 * click_nums / imp_nums,2) as ctr FROM (
  SELECT app_id, 
  SUM(CASE WHEN event_type = 'click'  THEN 1 ELSE 0 END) as click_nums,
  SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END) as imp_nums
  FROM events
  WHERE timestamp > '12/31/2021' and timestamp < '1/1/2023'
  GROUP BY app_id) A

//Second Day Confirmation [TikTok SQL Interview Question]
SELECT emails.user_id FROM emails
LEFT JOIN texts ON emails.email_id = texts.email_id AND texts.action_date = emails.signup_date + interval '1 day' 
WHERE texts.signup_action = 'Confirmed';

//Cards Issued Difference [JPMorgan Chase SQL Interview Question]
SELECT card_name, (MAX(issued_amount) -MIN(issued_amount)) as difference 
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC;

//Compressed Mean [Alibaba SQL Interview Question]
SELECT ROUND(1.0 * SUM(order_occurrences*item_count) / SUM(order_occurrences),1) as mean FROM items_per_order;

//Pharmacy Analytics (Part 1) [CVS Health SQL Interview Question]
SELECT drug, (total_sales - cogs) as total_profit 
FROM pharmacy_sales
ORDER BY total_profit DESC
LIMIT 3;

//Pharmacy Analytics (Part 2) [CVS Health SQL Interview Question]
SELECT manufacturer, COUNT(drug) as drug_count, SUM(total_losses) as total_loss FROM (
  SELECT manufacturer, drug, (cogs - total_sales) as total_losses 
  FROM pharmacy_sales
) A 
WHERE total_losses > 0
GROUP BY manufacturer
ORDER BY total_loss DESC;

//Pharmacy Analytics (Part 3) [CVS Health SQL Interview Question]
SELECT manufacturer, CONCAT('$',ROUND((SUM(total_sales)/1000000),0),' million') as sale 
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer;

//Patient Support Analysis (Part 1) [UnitedHealth SQL Interview Question]
SELECT COUNT(policy_holder_id) as member_count FROM (
  SELECT policy_holder_id, COUNT(case_id) as nums 
  FROM callers
  GROUP BY policy_holder_id) A 
WHERE nums >= 3;

//Patient Support Analysis (Part 2) [UnitedHealth SQL Interview Question]
SELECT ROUND(100.0 * SUM(CASE WHEN call_category is null THEN 1 WHEN call_category = 'n/a' THEN 1 ELSE 0 END)/COUNT(*),1) as call_percentage 
FROM callers;

//Users Third Transaction [Uber SQL Interview Question]
SELECT user_id, spend, transaction_date FROM
  (SELECT *, ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date) as num FROM transactions ORDER BY transaction_date) A
WHERE num = 3;

//Sending vs. Opening Snaps [Snapchat SQL Interview Question]
SELECT age_bucket, ROUND(send_time/total_time*100,2) AS send_perc, 
      ROUND(open_time/total_time*100,2) AS open_perc FROM (
  SELECT user_id, SUM(time_spent) AS total_time FROM activities 
  WHERE activity_type IN ('open', 'send') GROUP BY user_id) A
LEFT JOIN (
  SELECT user_id, SUM(time_spent) as open_time FROM activities 
  WHERE activity_type = 'open' GROUP BY user_id) B
  ON A.user_id = B.user_id
LEFT JOIN(
  SELECT user_id, SUM(time_spent) as send_time FROM activities 
  WHERE activity_type = 'send' GROUP BY user_id) C
  ON A.user_id = C.user_id
LEFT JOIN age_breakdown ON age_breakdown.user_id = A.user_id
ORDER BY age_bucket ASC;

//Tweets Rolling Averages [Twitter SQL Interview Question]
SELECT user_id, tweet_date, ROUND(AVG(tweet_count) OVER ( 
PARTITION BY user_id
ORDER BY tweet_date
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) as AVG
FROM  tweets;

//Highest-Grossing Items [Amazon SQL Interview Question]
SELECT category, product, total_spend FROM
(SELECT category, product, SUM(spend) as total_spend, 
  RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) rank
  FROM product_spend 
WHERE EXTRACT(YEAR FROM transaction_date) = 2022
GROUP BY category, product
ORDER BY category, total_spend DESC) A
WHERE rank < 3;

//Top 5 Artists [Spotify SQL Interview Question]
SELECT artist_name, artist_rank FROM (
SELECT artists.artist_name, DENSE_RANK() OVER(ORDER BY  COUNT(songs.song_id) DESC) as artist_rank FROM global_song_rank 
LEFT JOIN songs ON global_song_rank.song_id = songs.song_id
LEFT JOIN artists ON artists.artist_id = songs.artist_id
WHERE global_song_rank.rank <= 10
GROUP BY artists.artist_name) A
WHERE artist_rank <=5 ;

//Signup Activation Rate [TikTok SQL Interview Question]
SELECT ROUND(1.0 * SUM(CASE WHEN A.signup_action = 'Confirmed' THEN 1 ELSE 0 END) / COUNT(*),2) as confirm_rate FROM emails 
LEFT JOIN (
  SELECT * FROM texts WHERE signup_action = 'Confirmed') A
ON A.email_id = emails.email_id;

//
