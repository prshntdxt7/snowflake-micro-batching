create or replace pipe APP_DB.APP_SCHEMA.IMAGES_PIPE auto_ingest=true as COPY INTO APP_DB.APP_SCHEMA.IMAGES_RAW
FROM @APP_DB_STAGE
PATTERN='images[0-9]+\\.jsonl$'
FILE_FORMAT = (FORMAT_NAME = 'APP_DB.APP_SCHEMA.json_format');