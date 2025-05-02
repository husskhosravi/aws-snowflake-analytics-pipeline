-- Description: Transform raw JSON data from S3 into structured Snowflake tables

-- Create Yelp Reviews Table
CREATE OR REPLACE TABLE tbl_yelp_reviews AS
SELECT
  review_text:business_id::STRING     AS business_id,
  review_text:date::DATE              AS review_date,
  review_text:user_id::STRING         AS user_id,
  review_text:stars::NUMBER           AS review_stars,
  review_text:text::STRING            AS review_text,
  analyze_sentiment(review_text)      AS sentiments
FROM yelp_reviews;


-- Create Yelp Businesses Table
CREATE OR REPLACE TABLE tbl_yelp_businesses AS
SELECT
  business_text:business_id::STRING   AS business_id,
  business_text:name::STRING          AS name,
  business_text:city::STRING          AS city,
  business_text:state::STRING         AS state,
  business_text:review_count::STRING  AS review_count,
  business_text:stars::NUMBER         AS stars,
  business_text:categories::STRING    AS categories
FROM yelp_businesses;
