create or replace task APP_DB.APP_SCHEMA.PROCESS_AND_UPDATE_MAIN_IMAGES
	warehouse=COMPUTE_WH
	schedule='USING CRON 0 * * * * UTC'
	as CALL update_main_images();