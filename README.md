# Google Play Review Collection

## Project Introduction
This project evaluates Google Play as a potential source of user-generated review data for downstream AI and data pipeline development. The goal is to assess the feasibility of collecting, structuring, and maintaining app review data for future database storage and ingestion workflows. A review collection pipeline was developed using the `google-play-scraper` package to retrieve reviews from selected applications. The collected data was then examined through exploratory data analysis to understand dataset completeness, consistency, and usability. The findings provide insights into the strengths and limitations of Google Play as a potential long-term review data source.

## Data Source
Google Play was selected as the primary data source because it provides a large volume of publicly available user reviews across a wide range of applications. Reviews were collected using the google-play-scraper package by querying each application's package ID. 

## Related Packages Used
This project mainly used the `google-play-scraper` package for Google Play Store review collection.
Additional Python packages are used for data processing and visualization, including `pandas` and `matplotlib`.

For more information about `google-play-scraper` package, please visit [here](https://pypi.org/project/google-play-scraper/).

### Installation
```bash
pip install google-play-scraper pandas matplotlib
```

## Review Collection Procedure
A total of ten popular applications from different categories, including social media, education, productivity, entertainment, AI assistants, and utilities, were selected to provide a diverse sample for evaluating data quality. Each application was identified by its official Google Play package ID to ensure consistent and reproducible data collection.

The selected applications include: 

| Application | Package ID |
|--------------|----------|
| Snapchat | com.snapchat.android |
| Discord | com.discord |
| Duolingo | com.duolingo |
| Early Learning Academy | mobi.abcmouse.academy_goo |
| YouTube | com.google.android.youtube |
| Prime Video | com.amazon.avod.thirdpartyclient |
| WPS Office | cn.wps.moffice_eng |
| Claude | com.anthropic.claude |
| Spotify | com.spotify.music |
| DuckDuckGo | com.duckduckgo.mobile.android |

For each application, the scraper retrieved the 1,000 most recent reviews using the Sort.NEWEST option, resulting in a dataset of approximately 10,000 reviews. The returned review objects were converted into Pandas DataFrames, and an additional app column was added to identify the source app of each review. Finally, the individual DataFrames were merged into a single dataset using pd.concat(), which served as the input for the subsequent EDA.

Parameters in function `reviews()`:
| Parameters | Function |
|--------------|----------|
| appId | Unique application id for Google Play. |
| lang  | Optional, defaults to 'en', the two letter language code in which to fetch the reviews. |
| country | Optional, defaults to 'us', the two letter country code in which to fetch the reviews. |
| sort | Optional, defaults to sort.NEWEST. The way the reviews are going to be sorted. Accepted values are: sort.NEWEST, sort.RATING and sort.HELPFULNESS. |
| count | Optional, defaults to 100. Quantity of reviews to be captured. |
| filter_score_with | Defaults to None(means all score). |

For the following demonstrations, reviews were collected using lang="en" and country="us".
```python
from google_play_scraper import Sort, reviews
import pandas as pd

# app list
apps_dict = {
    "Snapchat": "com.snapchat.android", 
    "Discord": "com.discord",
    "Duolingo": "com.duolingo",
    "Early Learning Academy": "mobi.abcmouse.academy_goo",
    "YouTube": "com.google.android.youtube",
    "Prime Video": "com.amazon.avod.thirdpartyclient", 
    "WPS Office-PDF, Word, Sheet": "cn.wps.moffice_eng",
    "Claude by Anthropic": "com.anthropic.claude",
    "Spotify: Music and Podcasts": "com.spotify.music",
    "DuckDuckGo, optional Duck.ai": "com.duckduckgo.mobile.android"
}

all_reviews=[]

# review collect
for app_name, app_id in apps_dict.items():
    result, continuation_token = reviews(
        app_id,
        sort=Sort.NEWEST, 
        count=1000,
    )

    df = pd.DataFrame(result)
    print(app_name, len(df))
    df["app"] = app_name
    all_reviews.append(df)
    

review_tab = pd.concat(all_reviews, ignore_index=True)
```

## EDA
### Review Volume By App
The first step of the exploratory data analysis is to examine the number of reviews collected for each application. 
``` python
import matplotlib.pyplot as plot

# review volume by app
figure, axis = plot.subplots(figsize = (18, 6))
count_data = review_tab["app"].value_counts()

# get the x and y data
apps = count_data.index
frequencies = count_data.values
axis.bar(apps, frequencies)

axis.set_title("Review Volume by App")
axis.set_xlabel("App")
axis.set_ylabel("Number of Reviews")

plot.show()
```
#### Output
![Review Volume By App](OutputImages/review_volume.png)

Since the collection process was configured to retrieve up to 1,000 of the most recent reviews per app, this visualization is used to verify that the data collection was completed successfully and that each application contributed a comparable number of reviews. Consistent review counts across applications help reduce sampling bias in subsequent analyses.

### Rating Distribution
Below, we focus more on the distribution of review ratings across all collected Google Play reviews. 
```python
figure, axis = plot.subplots()
count_data = review_tab["score"].value_counts().sort_index()
ratings = count_data.index
frequencies = count_data.values
axis.bar(ratings, frequencies)
axis.set_title("Rating Distribution")
axis.set_xlabel("Rating")
axis.set_ylabel("Frequency")
plot.show()
```
#### Output
![Rating Distribution](OutputImages/RatingDistribution.png)

The rating distribution is highly skewed toward positive feedback. Five-star reviews account for the largest proportion of the dataset, indicating that most users report positive experiences with the selected applications. One-star reviews has the second largest population, suggesting that while dissatisfaction is less common, negative feedback is still substantial enough to support further analysis. Ratings of 2, 3, and 4 stars occur much less frequently, resulting in an imbalanced distribution that should be considered in downstream sentiment analysis and model development.

### Text Length
Review length is measured by the number of characters in each review. The boxplots summarize the median, IQR, overall spread, and potential outliers for each application, providing an overview of how detailed user reviews tend to be across different apps.
```python
review_tab["text_length"] = review_tab["content"].str.len()

figure, axis = plot.subplots(figsize = (18, 6))
review_tab.boxplot(column="text_length", by="app", ax=axis)
axis.set_title("Review Text Length by App")
axis.set_xlabel("App")
axis.set_ylabel("Number of Characters")
plot.show()

figure.savefig("TextLength.png")
```
#### Output
![TextLength](OutputImages/TextLength.png)

The boxplot below compares the distribution of review text lengths across the ten selected apps. Review text lengths vary across applications, although most reviews are relatively short. Early Learning Academy and Discord exhibit the highest median review lengths and the widest IQR ranges, suggesting that users tend to provide more detailed feedback for these applications. In contrast, Snapchat, YouTube, and WPS Office generally contain shorter reviews. All applications show a considerable number of long-text outliers, with some reviews approaching 500 characters, indicating that while most users leave concise comments, a subset provides substantially more detailed feedback.

### Timestamp Coverage
The table below summarizes the earliest and latest review timestamps for each application in the dataset. By comparing the time range covered by the collected reviews, we can evaluate how recent the data is and understand the review activity level of each application.
```python
print("Earliest Review")
display(review_tab.groupby("app")["at"].min())

print("Latest Review")
display(review_tab.groupby("app")["at"].max())
```
#### Output
![TimestampCoverage](OutputImages/timestamp_coverage.png)

The timestamp coverage varies considerably across applications. Most high-traffic applications, such as YouTube, and Spotify, have review windows spanning only a few days, indicating a high volume of recent user activity. In contrast, Early Learning Academy covers reviews dating back to January 2024, suggesting a much lower review frequency. Since the collection process retrieves the most recent 1,000 reviews for each application, the length of the time window directly reflects the review activity of each app.

### Missing Fields
The table below summarizes the number and percentage of missing values for each field in the collected dataset. Evaluating missing data helps determine whether the dataset is complete enough for downstream processing and identifies fields that may require special handling during data cleaning.
```python
missing = pd.DataFrame({
    "Missing Count": review_tab.isnull().sum(),
    "Missing Percentage": (review_tab.isnull().mean()*100).round(2)
})
missing
```
#### Output
![MissingFields](OutputImages/missing_fields.png)

Most core review fields, including `reviewId`, `userName`, `content`, `score`, `thumbsUpCount`, `at`, and `app`, contain no missing values, indicating that the dataset is complete for basic analysis. Missing values are mainly concentrated in a few metadata fields, like `replyContent` and `repliedAt` are missing for 85.14% of reviews because developer replies are only available when an application owner has responded to a review. In addition, `reviewCreatedVersion` and `appVersion` have approximately 16% missing values, suggesting that version information is unavailable for a subset of reviews. These missing values are expected and are unlikely to affect most text analysis or sentiment modeling tasks.

### Duplicate Review IDs
This check identifies whether multiple records share the same review ID. Since `reviewId` is expected to uniquely identify each review, duplicate IDs may indicate duplicated records introduced during the collection or ingestion process.
```python
review_tab["reviewId"].duplicated().sum()
```

The output here is 0. No duplicate review IDs were detected in the collected dataset. This confirms that each review is uniquely identified and suggests that the review collection process did not introduce duplicate records. As a result, `reviewId` can be reliably used as the primary key for downstream database design and data ingestion.

### Repeated Review Text
This analysis examines whether multiple reviews contain identical review text. Unlike duplicate review IDs, repeated review text does not necessarily indicate duplicate records, as different users may submit the same or very similar comments. Identifying repeated review text helps evaluate the diversity and information content of the collected dataset.
```python
# convert review text to lowercase
review_tab["content_lower"] = review_tab["content"].str.lower().str.strip()

# Number of repeated review texts
duplicate_count = review_tab["content_lower"].duplicated().sum()

# Repeated review texts
duplicate_text = review_tab[review_tab["content_lower"].duplicated()][["app", "content"]]

# Most common repeated review texts
duplicate_textCount = review_tab["content_lower"].value_counts()
duplicate_textCount = duplicate_textCount[duplicate_textCount > 1]
duplicate_textCount.head(10)
```
#### Output
![RepeatedReviewText](OutputImages/repeated_review_text.png)

Repeated review text is common in the dataset, particularly for very short comments. Frequently repeated reviews included "good", "nice", and "excellent". These comments are likely produced independently by different users rather than resulting from duplicated records, as no duplicate review IDs were detected. The results suggest that while the dataset is free from duplicated entries, it contains a substantial number of low-information reviews that may contribute limited value for downstream text analysis. Such reviews could be filtered or treated separately during preprocessing if higher-quality textual information is desired.

### Low-signal Reviews
Low-signal reviews contain very little textual information and therefore contribute limited value for downstream text analysis. In this project, reviews with fewer than 10 characters were classified as low-signal reviews. This analysis estimates the proportion of such reviews and provides examples of their content.
```python
low_signal = review_tab[review_tab["text_length"] < 10]
len(low_signal)
len(low_signal) / len(review_tab) * 100
low_signal["content"].head(20)
```
#### Output
![Low-signalReviews](OutputImages/low-signal_reviews.png)

A noticeable portion of the collected reviews contains fewer than 10 characters. Most of these reviews consist of short expressions such as "nice app", "wow", or emojis. Although these reviews often reflect positive or negative sentiment, they provide little contextual information about user experience, product features, or specific issues. Depending on the objectives of downstream tasks, these reviews may be removed or processed separately to improve the quality of text-based analyses.

### Language Issues
To verify that the `google-play-scraper` language and country parameters work as expected, an additional dataset was collected using `lang="es"` and `country="es"`. For each application, 100 of the newest reviews were retrieved and stored in a separate DataFrame. This experiment evaluates whether the scraper can reliably collect reviews from different languages.
```python
all_reviews_other = []

for app_name, app_id in apps_dict.items():
    result, continuation_token = reviews(
        app_id,
        lang="es",
        country="es",
        sort=Sort.NEWEST,
        count=100
    )

    df = pd.DataFrame(result)

    df["app"] = app_name
    df["language_setting"] = "Spanish"

    all_reviews_other.append(df)

    print(app_name, len(df))

review_other_tab = pd.concat(
    all_reviews_other,
    ignore_index=True
)

review_other_tab.head(20)
```
#### Output
Part of the output:
![LanguageIssues](OutputImages/language.png)

The collected reviews are written in Spanish, with user names, review text, and expressions consistently matching the selected language and region. Each application successfully returned 100 reviews, indicating that the language and country filters were applied correctly. This demonstrates that the scraper can support multilingual review collection, making it suitable for future cross-language analysis or international data ingestion pipelines.

### Summary EDA
- Approximately 10,000 reviews were collected from 10 popular Google Play applications using a consistent collection strategy.
- The dataset contains complete core fields (review ID, review text, rating, timestamp), making it suitable for downstream analysis.
- No duplicate review IDs were found, indicating that review IDs can serve as reliable unique identifiers.
- Most missing values occur in developer reply and app version-related fields, as expected, because not every review receives a developer response or reports an app version.
- Review text lengths and rating distributions vary across applications, while repeated review texts are primarily short, low-information comments (e.g., "good", "nice") rather than duplicated records.
- Because reviews were collected using Sort.NEWEST, high-traffic apps cover shorter time windows, whereas lower-traffic apps include reviews spanning much longer periods.

### Current Limitations
- The dataset only contains the most recent reviews and should not be treated as complete historical data. To retrieve all review data, the function `reviews()` could be replaced with `reviews_all()`.
- Data was collected only from Google Play using English (US) settings, so reviews from other regions, languages, or platforms are not included. Need additional settings to retrieve reviews from other regions or languages.
- Some metadata (e.g., app version and developer replies) is unavailable for a portion of reviews because it is not always provided by Google Play.
- Low-signal reviews (such as very short comments or emoji-only responses) remain in the raw dataset and require additional filtering for certain analyses. Need to be seperated from repeated contents.

### Next Steps
- Separate raw reviews, processed reviews, quality assessment results, and ingestion metadata into dedicated tables.
- Build a repeatable ingestion pipeline that supports scheduled review collection and timely updates.
- Apply additional preprocessing, including text normalization, and low-signal and repeated content filtering.
- Use the processed dataset for later downstream tasks.

## Schema Design
### Overview
This schema is designed to support the collection, storage, and processing of Google Play review data. The design separates raw review data from processed data and quality evaluation results while also tracking each ingestion run for reproducibility and future recurring collection. Although the current implementation focuses on Google Play, the schema includes a platform field to support future expansion to additional review sources.
![schemadiagram](GooglePlayReview_SchemaDiagram.png)

### Table Description
### `app_info`
Stores information about each application being collected from a review platform.

`app_id`: Unique application identifier (e.g., Google Play package ID)

`platform`: Review source platform (e.g., Google Play)

`app_name`: Human-readable application name

Primary Key (Composite): (`app_id`, `platform`)

Foreign Key: None

### `raw_review`
Stores immutable, original review data directly fetched from the source platform. 

`raw_id`: Internal database identifier

`review_id`: Review identifier provided by the source platform

`app_id`: Unique application identifier

`platform`: Review source platform

`user_name`: Reviewer name

`content`: Original review text

`rating`: Review rating

`thumbs_up_count`: Helpful vote count

`review_time`: Review creation time

`developer_reply`: Developer response

`developer_reply_time`: Time of developer response

`app_version`: Application version

`review_created_version`: Application version when the review was created (usually align with `app_version`

`ingested_at`: Timestamp when the review was first collected

Primary Key: `raw_id`

Foreign Key: (`platform`, `app_id`) --> app_info(`platform`, `app_id`)

### `processed_review`
Stores cleaned and standardized review text generated from the raw review table. The original review remains unchanged to preserve data provenance.

`raw_id`: Associated raw review identifier provided by the source platform.

`cleaned_content`: Normalized review text

`content_length`: Length of cleaned review text

Primary Key: `raw_id`

Foreign Key: (`raw_id`) --> raw_review(`raw_id`)

### `ingestion_run`
Stores metadata for each review collection run. Each record represents one execution of the collection pipeline for a specific application under a specific collection configuration.

`run_id`: Unique ingestion run identifier

`app_id`: Application identifier of the app collected during this run

`platform`: Source platform

`collect_at`: Collection timestamp

`language`: Language parameter used during collection

`country`: Country parameter used during collection

`sort_method`: Review sorting method (e.g., newest)

`target_review_count`: Number of reviews requested

`actual_review_count`: Number of reviews returned

`skipped_duplicates`: Number of duplicate reviews skipped

`inserted_records`: Number of new reviews inserted into the database

`status`: Overall execution status

`error_message`: Error information if the run failed

Primary Key: `run_id`

Foreign Key: (`app_id`, `platform`) --> app_info(`app_id`, `platform`)

### `review_ingestion`
Records the relationship between reviews and ingestion runs. This table enables recurring collections by tracking which reviews were observed during each collection run.

`raw_id`: Internal database identifier

`run_id`: Ingestion run identifier

`record_status`: Status of the review during this run (Inserted, Duplicate, Updated)

Primary Key (Composite): (`raw_id`, `run_id`)

Foreign Key: (`raw_id`) --> raw_review(`raw_id`), (`run_id`) --> ingestion_run(`run_id`)

### `review_quality`
Stores quality assessment results derived from the processed review data.

`raw_id`: Internal database identifier

`is_empty_content`: Indicates whether the review content is empty

`is_repeated_text`: Indicates duplicated review text

`is_low_signal`: Indicates low-information reviews

`is_missing_created_version`: Missing review creation version

`is_missing_app_version`: Missing application version

`is_missing_developer_reply`: Missing developer reply

`is_missing_developer_reply_time`: Missing developer reply timestamp

Primary Key (Composite): `raw_id`

Foreign Key: (`raw_id`) --> processed_review(`raw_id`)

### Deduplication Logic
Although no duplicate review IDs were observed in the current Google Play dataset, using the source-provided review_id alone is not considered sufficiently robust for long-term database design. The database therefore uses an internal surrogate key (raw_id) as the primary key, while review uniqueness is determined using the following composite identifier: (platform, app_id, review_id).

This composite key ensures that:
- review IDs remain unique across different applications;
- future support for multiple review platforms can be added without changing the schema;
- recurring ingestion runs can reliably identify previously collected reviews.

During each ingestion run, incoming reviews are compared against the existing composite key:
- If the combination already exists, the review is marked as duplicate.
- Otherwise, a new raw review record will be inserted.

### Quality Flag Logic


### how raw reviews connect to processed reviews

### what metadata should be stored for each ingestion run
