# 📘 Yelp SQL Insights: 9 Essential Queries for Business Intelligence

This SQL analysis explores key patterns in Yelp business and review data across nine focused questions. It covers business categorisation, user behaviour, and review sentiment by leveraging joins, aggregation, window functions, and filtering logic. Insights include the most common business categories, top reviewers of restaurants, review volumes by category and city, recent activity per business, and monthly trends. It also calculates 5-star review percentages, highlights high-performing businesses based on sentiment, and focuses on those with substantial review counts to ensure reliability. Each query is designed to surface actionable insights from the dataset’s structure and content.


### 1. Count the number of businesses in each category.

<details>
<summary>SQL Code</summary>

```sql
with cte as (
  select business_id, trim(A.value) as category
  from tbl_yelp_businesses
  , lateral split_to_table(categories, ',') A
)
select category, count(*) as no_of_business
from cte
group by 1;
```

</details>

<details>
<summary>Output</summary>

![q1](https://github.com/user-attachments/assets/814c6417-6f46-46f8-b87e-8043da5a1750)


</details>

---

### 2. Identify the top 10 users who have reviewed the most businesses in the "Restaurants" category.

<details>
<summary>SQL Code</summary>

```sql
select r.user_id, count(distinct r.business_id)
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id = b.business_id
where b.categories ilike '%restaurant%'
group by 1
order by 2 desc
limit 10;
```

</details>

<details>
<summary>Output</summary>

![q2](https://github.com/user-attachments/assets/49765367-416b-48ed-a371-da02fa124f5b)


</details>

---

### 3. Determine the most popular categories based on the total number of reviews.

<details>
<summary>SQL Code</summary>

```sql
with cte as (
  select business_id, trim(A.value) as category
  from tbl_yelp_businesses
  , lateral split_to_table(categories, ',') A
)
select category, count(*) as no_of_reviews
from cte
inner join tbl_yelp_reviews r on cte.business_id = r.business_id
group by 1;
```

</details>

<details>
<summary>Output</summary>

![q3](https://github.com/user-attachments/assets/d2557125-cc41-44d0-ae79-1f3d5d09eaf4)


</details>

---

### 4. Retrieve the top 3 most recent reviews for each business.

<details>
<summary>SQL Code</summary>

```sql
with cte as (
  select r.*, b.name
  , row_number() over(partition by r.business_id order by review_date desc) as rn
  from tbl_yelp_reviews r
  inner join tbl_yelp_businesses b on r.business_id = b.business_id
)
select * from cte
where rn <= 3;
```

</details>

<details>
<summary>Output</summary>

![q4](https://github.com/user-attachments/assets/0b98fe26-813c-445d-b2fd-a828f39429f9)


</details>

---

### 5. Find the month with the highest number of reviews.

<details>
<summary>SQL Code</summary>

```sql
select month(review_date) as review_month, count(*) as no_of_reviews
from tbl_yelp_reviews
group by 1
order by 2 desc;
```

</details>

<details>
<summary>Output</summary>

![q5](https://github.com/user-attachments/assets/a07d8f07-36b4-4037-bbb8-00cc532d5271)


</details>

---

### 6. Calculate the percentage of 5-star reviews for each business.

<details>
<summary>SQL Code</summary>

```sql
select b.business_id, b.name, count(*) as total_reviews
, sum(case when r.review_stars = 5 then 1 else 0 end) as star5_reviews
, star5_reviews * 100 / total_reviews as percent_5_star
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id = b.business_id
group by 1, 2;
```

</details>

<details>
<summary>Output</summary>

![q6](https://github.com/user-attachments/assets/b3885a74-d022-4e40-bd26-ac0691a64632)


</details>

---

### 7. Find the top 5 most reviewed businesses in each city.

<details>
<summary>SQL Code</summary>

```sql
with cte as (
  select b.city, b.business_id, b.name, count(*) as total_reviews
  from tbl_yelp_reviews r
  inner join tbl_yelp_businesses b on r.business_id = b.business_id
  group by 1, 2, 3
)
select *
from cte
qualify row_number() over (partition by city order by total_reviews desc) <= 5;
```

</details>

<details>
<summary>Output</summary>

![q7](https://github.com/user-attachments/assets/ac7b46cb-dd37-4ac4-b176-28e1c0f55242)


</details>

---

### 8. Compute the average rating of businesses with at least 100 reviews.

<details>
<summary>SQL Code</summary>

```sql
select b.business_id, b.name, count(*) as total_reviews,
       avg(review_stars) as avg_rating
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id = b.business_id
group by 1, 2
having count(*) >= 100;
```

</details>

<details>
<summary>Output</summary>

![q8](https://github.com/user-attachments/assets/ce4b4a44-7025-4bda-8261-5ea9a0ce8308)


</details>

---

### 9. Identify the top 10 businesses with the highest number of positive sentiment reviews.

<details>
<summary>SQL Code</summary>

```sql
select r.business_id, b.name, count(*) as total_reviews
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id = b.business_id
where sentiments = 'Positive'
group by 1, 2
order by 3 desc
limit 10;
```

</details>

<details>
<summary>Output</summary>

![q9](https://github.com/user-attachments/assets/c9f91031-709a-4a17-874c-39b75fa10c57)


</details>
