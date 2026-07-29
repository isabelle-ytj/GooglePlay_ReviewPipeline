CREATE DATABASE IF NOT EXISTS review_collection;
USE review_collection;

CREATE TABLE app_info (
    app_id VARCHAR(255),
    platform VARCHAR(50),
    app_name VARCHAR(255),

    PRIMARY KEY (app_id, platform)
);

CREATE TABLE ingestion_run (
    run_id INT AUTO_INCREMENT,
    app_id VARCHAR(255),
    platform VARCHAR(50),
    collect_at DATETIME,
    language VARCHAR(50),
    country VARCHAR(50),
    sort_method VARCHAR(50),
    target_review_count INT,
    actual_review_count INT,
    skipped_duplicates INT,
    inserted_records INT,
    status VARCHAR(50),
    error_message TEXT,

    PRIMARY KEY (run_id),
    FOREIGN KEY (app_id, platform)
	REFERENCES app_info(app_id, platform)
);

CREATE TABLE raw_review (
    raw_id INT AUTO_INCREMENT,
    review_id VARCHAR(255) NOT NULL,
    app_id VARCHAR(255) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    user_name TEXT,
    content TEXT,
    rating INT,
    thumbs_up_count INT,
    review_time DATETIME,
    developer_reply TEXT,
    developer_reply_time DATETIME,
    app_version VARCHAR(50),
    review_created_version VARCHAR(50),
    ingested_at DATETIME,

	PRIMARY KEY (raw_id),
    FOREIGN KEY (app_id, platform)
    REFERENCES app_info(app_id, platform),

    UNIQUE(platform, app_id, review_id)
);

CREATE TABLE review_ingestion (
    raw_id INT,
    run_id INT,
    record_status VARCHAR(50),

    PRIMARY KEY(raw_id, run_id),
    FOREIGN KEY(raw_id)
    REFERENCES raw_review(raw_id),
    FOREIGN KEY(run_id)
    REFERENCES ingestion_run(run_id)
);

CREATE TABLE processed_review (
    raw_id INT,
    cleaned_content TEXT,
    content_length INT,

    PRIMARY KEY (raw_id),
    FOREIGN KEY (raw_id)
	REFERENCES raw_review(raw_id)
);

CREATE TABLE review_quality (
    raw_id INT,
    is_empty_content BOOLEAN,
    is_repeated_text BOOLEAN,
    is_low_signal BOOLEAN,
    is_missing_created_version BOOLEAN,
    is_missing_app_version BOOLEAN,
    is_missing_developer_reply BOOLEAN,
    is_missing_developer_reply_time BOOLEAN,

    PRIMARY KEY (raw_id),
    FOREIGN KEY (raw_id)
        REFERENCES raw_review(raw_id)
);

SHOW TABLES;
