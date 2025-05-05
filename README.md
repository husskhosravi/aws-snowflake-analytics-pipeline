## 🧠 Yelp Reviews Analytics Pipeline (AWS + Snowflake + Python)

This project builds an end-to-end analytics pipeline to extract insights from [**Yelp’s open review dataset**](https://business.yelp.com/data/resources/open-dataset/), which contains millions of user-generated reviews, business metadata, and ratings across industries such as restaurants, retail, automotive, and healthcare.

Yelp is a widely used platform for discovering and reviewing local businesses. Users leave textual reviews and star ratings that reflect their customer experience. These reviews represent rich, real-world data ideal for performing sentiment analysis, behavioural analytics, and performance benchmarking.

In this project, I ingested and transformed over 7 million reviews on Yelp using AWS S3 and Snowflake, applied Python-based sentiment classification directly within Snowflake, and used advanced SQL techniques to extract business insights — all while handling large-scale semi-structured JSON efficiently in the cloud.

---

### 🚀 What I Built

- Ingested **~7 million Yelp reviews (5GB JSON)** into AWS S3, then into **Snowflake** as semi-structured data.
- Created a **Python-based sentiment analysis UDF** using `textblob`, executed directly within Snowflake.
- Converted raw JSON data to tabular form using Snowflake SQL, handled nested fields and types.
- Solved **9 real-world SQL problems** including joins, aggregations, rankings, lateral splits, and sentiment-based filtering.

![workflow](https://github.com/user-attachments/assets/d2c3c0ad-5062-4574-bcc6-2ed277bd12e3)

---

### 🔧 Tech Stack

| Tool/Service      | Purpose                                                |
|-------------------|--------------------------------------------------------|
| **AWS S3**         | Cloud storage for raw Yelp data (split JSON files)     |
| **Snowflake**      | Warehouse to ingest, transform, and analyse data       |
| **Python UDFs**    | Custom sentiment classification inside SQL             |
| **SQL (Snowflake)**| Heavy querying on JSON-transformed tabular data        |
| **TextBlob**       | Sentiment polarity detection via Python                |

---

### 📁 S3 Storage Structure

```bash
s3://<bucket>/yelp/
  ├── review_split_file_1.json
  ├── review_split_file_2.json
  ├── ...
  ├── review_split_file_10.json
  └── yelp_academic_dataset_business.json
```

---

### 🧩 Why I Split the JSON Files Before Upload

The original Yelp review file is **~5GB and contains 7 million lines**, making it inefficient to load as a single file. Snowflake processes data **in parallel** by assigning threads to each file during ingestion.

By splitting the file into **10+ smaller chunks (~500MB each)**:

- ✅ **Parallelism kicks in** → Snowflake loads multiple files **concurrently**, massively reducing load time.
- ✅ **Faster COPY INTO execution**
- ✅ **Smaller memory footprint** and better fault tolerance
- ✅ Aligns with Snowflake’s internal best practices for loading from external stages (like S3)

**Result:** A ~5x speed-up compared to uploading the entire file as one monolith.

---

### 🧠 Sentiment Analysis with `analyze_sentiment` UDF

To analyse the sentiment of each Yelp review, I created a **Python UDF** in Snowflake named `analyze_sentiment`.

This function uses the **TextBlob** library to compute **polarity**, a float value between -1 and 1 that reflects the emotional tone of the text:

| Polarity Range | Meaning         |
|----------------|------------------|
| `< 0`          | Negative review  |
| `= 0`          | Neutral review   |
| `> 0`          | Positive review  |

#### 🔧 How It Works

```python
from textblob import TextBlob

def analyze_sentiment(text):
    polarity = TextBlob(text).sentiment.polarity
    if polarity > 0:
        return 'positive'
    elif polarity == 0:
        return 'neutral'
    else:
        return 'negative'
```
Here’s how different reviews are scored using analyze_sentiment:
- The function was registered in Snowflake via Python UDFs.
- Executed directly inside SQL queries for **real-time classification**.
- Returned a labelled sentiment (`positive`, `neutral`, or `negative`) for each review.

✅ This let me slice and analyse the data by emotional tone without exporting it to an external Python environment.

#### 📈 Example Output for Illustration
![polarities_snippet_for_illustration](https://github.com/user-attachments/assets/a80ddb8e-d392-4058-a68c-a431311f6341)

---

### 📥 Data Ingestion to Snowflake from AWS S3

To load the Yelp review and business datasets into Snowflake directly from S3, I used the COPY INTO command with Snowflake’s native S3 integration. This requires generating an AWS access key ID and secret key and granting read access.

Here’s the command to load Yelp reviews (in JSON format):

```sql
CREATE OR REPLACE TABLE yelp_reviews (review_text VARIANT);

COPY INTO yelp_reviews
FROM 's3://<bucket>/yelp/'
CREDENTIALS = (
    AWS_KEY_ID = '<your-access-key-id>'
    AWS_SECRET_KEY = '<your-secret-access-key>'
)
FILE_FORMAT = (TYPE = JSON);
```

Repeat the same process for the business dataset by creating a new table and updating the path. Finally, I created two tables:

- tbl_yelp_reviews: review_id, business_id, user_id, date, stars, text, sentiment
- tbl_yelp_businesses: business_id, name, city, state, categories, stars, review_count

Quick recap of what I’ve done so far:

- ✅ Loaded raw JSON as `VARIANT` into Snowflake  
- ✅ Flattened nested fields and casted to native types -> [Code in here](https://github.com/husskhosravi/aws-snowflake-analytics-pipeline/blob/main/data_scripts/data_transformation.sql) 
- ✅ Used Python UDFs for review sentiment  

---

### ✅ Real-world SQL Analytics

Answered:

- Top users by reviews
- Top cities by business volume
- Most common categories
- Sentiment breakdown
- Monthly review trends
- 5-star percentage by business
- Top-reviewed businesses per city
- And more...
    
---

### 📊 Example Query – Sentiment-Aware Aggregation
### Top 10 businesses with the highest number of positive sentiment reviews
```sql
SELECT 
    r.business_id, 
    b.name, 
    COUNT(*) AS total_reviews
FROM 
    tbl_yelp_reviews r
INNER JOIN 
    tbl_yelp_businesses b 
    ON r.business_id = b.business_id
WHERE 
    r.sentiments = 'Positive'
GROUP BY 
    r.business_id, b.name
ORDER BY 
    total_reviews DESC
LIMIT 10;

```
---

### 📈 Example of Insights Generated

- Restaurants dominate Yelp in both **volume and positivity** of reviews.
- Top users who have reviewed most businesses in the **Restaurants** category.
- Peak review month: **July**

---

### 📂 Repo Structure

```bash
.
├── README.md
├── /sql
│   └── analytics_queries.md
├── /data_script
│   └── data_transformation.sql
│   └── split_files.py
├── /udf
    └── sentiment_udf.py
