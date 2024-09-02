{% set data = [
  {
    "repository": "vulcan-sql",
    "topic": ["analytics", "data-lake", "data-warehouse", "api-builder"],
    "description":"Create and share Data APIs fast! Data API framework for DuckDB, ClickHouse, Snowflake, BigQuery, PostgreSQL"
  },
  {
    "repository": "accio",
    "topic": ["data-analytics", "data-lake", "data-warehouse", "bussiness-intelligence"],
    "description": "Query Your Data Warehouse Like Exploring One Big View."
  },
  {
    "repository": "hell-word",
    "topic": [],
    "description": "Sample repository for testing"
  }
] %}

-- The source data for "huggingface_table_question_answering" needs to be an array of objects.
SELECT {{ data | huggingface_table_question_answering(query="How many repositories related to data-lake topic?") }}