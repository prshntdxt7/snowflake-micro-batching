create or replace view APP_DB.APP_SCHEMA.RANKED_IMAGES(
	HOTEL_ID,
	IMAGE_ID,
	CDN_URL
) as
WITH active_images AS (
    SELECT * FROM images WHERE is_active = TRUE
),
image_with_tags AS (
    SELECT i.*, it.tags
    FROM active_images i
    LEFT JOIN image_tags it ON i.image_id = it.image_id
),
ranked_images AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY hotel_id ORDER BY ARRAY_SIZE(tags) DESC, (height * width) DESC) AS rank
    FROM image_with_tags
)
SELECT hotel_id, image_id, cdn_url
FROM ranked_images
WHERE rank = 1;