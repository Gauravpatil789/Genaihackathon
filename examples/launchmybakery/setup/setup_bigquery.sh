#!/bin/bash

PROJECT_ID=$(gcloud config get-value project)
DATASET_NAME="petrol"
LOCATION="US"

# Generate bucket name if not provided

if [ -z "$1" ]; then
BUCKET_NAME="gs://mcp-petrol-data-$PROJECT_ID"
echo "No bucket provided. Using default: $BUCKET_NAME"
else
BUCKET_NAME=$1
fi

echo "----------------------------------------------------------------"
echo "MCP Petrol Demo Setup"
echo "Project: $PROJECT_ID"
echo "Dataset: $DATASET_NAME"
echo "Bucket:  $BUCKET_NAME"
echo "----------------------------------------------------------------"

echo "[1/4] fuel_prices"
bq query --use_legacy_sql=false 
"CREATE OR REPLACE TABLE `$PROJECT_ID.$DATASET_NAME.fuel_prices` (
state STRING,
city STRING,
petrol_price FLOAT64,
diesel_price FLOAT64,
last_updated DATE
);"

bq load --source_format=CSV --skip_leading_rows=1 --replace 
$PROJECT_ID:$DATASET_NAME.fuel_prices 
$BUCKET_NAME/fuel_prices_india.csv

echo "[2/4] fuel_trends"
bq query --use_legacy_sql=false 
"CREATE OR REPLACE TABLE `$PROJECT_ID.$DATASET_NAME.fuel_trends` (
state STRING,
month STRING,
avg_petrol_price FLOAT64,
avg_diesel_price FLOAT64
);"

bq load --source_format=CSV --skip_leading_rows=1 --replace 
$PROJECT_ID:$DATASET_NAME.fuel_trends 
$BUCKET_NAME/fuel_trends.csv

echo "[3/4] fuel_consumption"
bq query --use_legacy_sql=false 
"CREATE OR REPLACE TABLE `$PROJECT_ID.$DATASET_NAME.fuel_consumption` (
state STRING,
fuel_type STRING,
monthly_consumption FLOAT64,
year INT64
);"

bq load --source_format=CSV --skip_leading_rows=1 --replace 
$PROJECT_ID:$DATASET_NAME.fuel_consumption 
$BUCKET_NAME/fuel_consumption.csv

echo "[4/4] fuel_tax"
bq query --use_legacy_sql=false 
"CREATE OR REPLACE TABLE `$PROJECT_ID.$DATASET_NAME.fuel_tax` (
state STRING,
petrol_tax_pct FLOAT64,
diesel_tax_pct FLOAT64
);"

bq load --source_format=CSV --skip_leading_rows=1 --replace 
$PROJECT_ID:$DATASET_NAME.fuel_tax 
$BUCKET_NAME/fuel_tax.csv

echo "All tables created and data loaded successfully!"
