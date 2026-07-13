# Google Play Review Collection

This project collects Google Play reviews from multiple popular applications using the `google-play-scraper` package and performs exploratory data analysis to evaluate the quality of the collected data for downstream database constructions.

## Related Projects Used
https://github.com/facundoolano/google-play-scraper

### Installation
```python
npm install google-play-scraper
```

## Review Collection Procedure
Review data was collected from Google Play using the google-play-scraper Python package. A total of ten popular applications from different categories, including social media, education, productivity, entertainment, AI assistants, and utilities, were selected to provide a diverse sample for evaluating data quality. Each application was identified by its official Google Play package ID to ensure consistent and reproducible data collection

For each application, the scraper retrieved the 1,000 most recent reviews using the Sort.NEWEST option, resulting in a dataset of approximately 10,000 reviews. The returned review objects were converted into Pandas DataFrames, and an additional app column was added to identify the source application of each review. Finally, the individual DataFrames were merged into a single dataset using pd.concat(), which served as the input for the subsequent EDA.

By default, the langauge is set as English, and the country is set to US.
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
The first step of the exploratory data analysis is to examine the number of reviews collected for each application. Since the collection process was configured to retrieve up to 1,000 of the most recent reviews per app, this visualization is used to verify that the data collection was completed successfully and that each application contributed a comparable number of reviews. Consistent review counts across applications help reduce sampling bias in subsequent analyses.
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


### Rating Distribution

### Text Length

### Timestamp Coverage

### Missing Fields

### Duplicate Review IDs

### Repeated Review Text

### Low-signal Reviews

### Language Issues






