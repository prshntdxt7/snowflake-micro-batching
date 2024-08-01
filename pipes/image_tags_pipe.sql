create or replace pipe APP_DB.APP_SCHEMA.IMAGE_TAGS_PIPE auto_ingest=true as COPY INTO APP_DB.APP_SCHEMA.IMAGE_TAGS_RAW
FROM @APP_DB_STAGE
PATTERN='image_tags[0-9]+\\.jsonl$'
FILE_FORMAT = (FORMAT_NAME = 'APP_DB.APP_SCHEMA.json_format');