CREATE OR REPLACE PROCEDURE APP_DB.APP_SCHEMA.UPDATE_MAIN_IMAGES()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS OWNER
AS '
DECLARE
  -- Variables for metrics
  num_images_processed INTEGER;
  num_hotels_with_images INTEGER;
  num_main_images INTEGER;
  num_new_main_images INTEGER;
  num_updated_main_images INTEGER;
BEGIN
  MERGE INTO APP_DB.APP_SCHEMA.MAIN_IMAGES AS target
  USING (
    SELECT hotel_id, image_id, cdn_url
    FROM APP_DB.APP_SCHEMA.RANKED_IMAGES
  ) AS source
  ON target.hotel_id = source.hotel_id
  WHEN MATCHED AND target.image_id != source.image_id THEN
    UPDATE SET target.image_id = source.image_id,
               target.cdn_url = source.cdn_url
  WHEN NOT MATCHED THEN
    INSERT (hotel_id, image_id, cdn_url)
    VALUES (source.hotel_id, source.image_id, source.cdn_url);

  -- Step 2: Calculate metrics
  -- Number of active images
  SELECT COUNT(*) INTO :num_images_processed
  FROM APP_DB.APP_SCHEMA.IMAGES
  WHERE is_active = TRUE;

  -- Number of hotels with active images
  SELECT COUNT(DISTINCT hotel_id) INTO :num_hotels_with_images
  FROM APP_DB.APP_SCHEMA.IMAGES
  WHERE is_active = TRUE;

  -- Number of main images
  SELECT COUNT(*) INTO :num_main_images
  FROM APP_DB.APP_SCHEMA.MAIN_IMAGES;

  -- Number of new main images (added in the current execution)
  SELECT
    COUNT(*) INTO :num_new_main_images
  FROM APP_DB.APP_SCHEMA.MAIN_IMAGES;

  -- Number of updated main images (updated in the current execution)
  SELECT
    COUNT(*) INTO :num_updated_main_images
  FROM APP_DB.APP_SCHEMA.MAIN_IMAGES;

  -- Step 3: Store metrics in a metrics table
  INSERT INTO APP_DB.APP_SCHEMA.METRICS_TABLE (
    num_images_processed,
    num_hotels_with_images,
    num_main_images,
    num_new_main_images,
    num_updated_main_images,
    processed_at
  ) VALUES (
    :num_images_processed,
    :num_hotels_with_images,
    :num_main_images,
    :num_new_main_images,
    :num_updated_main_images,
    CURRENT_TIMESTAMP()
  );

  RETURN ''Main image update completed with metrics calculated'';
END;
';