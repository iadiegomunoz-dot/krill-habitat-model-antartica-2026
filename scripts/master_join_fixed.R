
library(terra)
library(tidyverse)
library(zoo)

setwd("C:/Users/munoz/Downloads/antartica para el agente")

# 1. Krillbase
cat("Loading Krillbase...\n")
df_krill <- read.csv("datasets/krillbase/krillbase_data.csv", fileEncoding = "latin1")
df_krill_processed <- df_krill %>%
  filter(LATITUDE >= -75 & LATITUDE <= -55,
         LONGITUDE >= -70 & LONGITUDE <= -20,
         SEASON >= 2002 & SEASON <= 2016) %>%
  mutate(
    presence = ifelse(STANDARDISED_KRILL_UNDER_1M2 > 0, 1, 0),
    net_depth = log10(BOTTOM_SAMPLING_DEPTH_M + 1),
    date_clean = as.Date(DATE, format="%d/%m/%Y"),
    year = as.numeric(format(date_clean, "%Y")),
    month = as.numeric(format(date_clean, "%m")),
    SEASON = as.numeric(SEASON)
  ) %>%
  filter(!is.na(year))

cat("Krillbase records:", nrow(df_krill_processed), "\n")

# 2. GEBCO
cat("Loading GEBCO rasters...\n")
r_talud       <- rast("datasets/processed/gebco_analysis/distancia_talud_48_1.nc")
r_pendiente   <- rast("datasets/processed/gebco_analysis/pendiente_gebco_48_1.nc")
r_profundidad <- rast("datasets/processed/gebco_analysis/profundidad_025_48_1.nc")

coords_sf <- df_krill_processed %>% select(LONGITUDE, LATITUDE)
df_krill_processed$dist_talud  <- terra::extract(r_talud, coords_sf, method="bilinear")[, 2]
df_krill_processed$pendiente   <- terra::extract(r_pendiente, coords_sf, method="bilinear")[, 2]
df_krill_processed$profundidad <- terra::extract(r_profundidad, coords_sf, method="bilinear")[, 2]

# 3. SST (Fixed)
cat("Processing SST stack...\n")
sst_files <- list.files("datasets/nasa_giovanni/sst", pattern = "*.nc", full.names = TRUE)
if(length(sst_files) > 0) {
  r_sst_list <- lapply(sst_files, function(f) {
    # NASA Giovanni files often have 'sst' as a subdataset
    # We use subds="sst" to avoid the geometry mismatch error
    r <- try(rast(f, subds="sst"), silent = TRUE)
    if(inherits(r, "try-error")) return(NULL)
    
    fname <- basename(f)
    # Extract YYYYMM from AQUA_MODIS.20020801...
    date_str <- substr(fname, 12, 17)
    names(r) <- paste0("X", date_str)
    return(r)
  })
  # Remove NULLs
  r_sst_list <- r_sst_list[!sapply(r_sst_list, is.null)]
  r_sst_stack <- rast(r_sst_list)
  
  cat("Extracting SST for Krillbase points...\n")
  sst_all <- terra::extract(r_sst_stack, coords_sf)
  
  df_krill_processed$sst_local <- sapply(1:nrow(df_krill_processed), function(i) {
    pattern <- paste0("X", df_krill_processed$year[i], sprintf("%02d", df_krill_processed$month[i]))
    col_idx <- which(names(r_sst_stack) == pattern)
    if(length(col_idx) > 0) return(as.numeric(sst_all[i, col_idx + 1])) else return(NA)
  })
} else {
  cat("WARNING: No SST files found!\n")
  df_krill_processed$sst_local <- NA
}

# 4. Joins
cat("Joining environmental series...\n")
df_ice   <- read.csv("datasets/processed/sea_ice_monthly_48_1.csv")
df_sam   <- read.csv("datasets/sam_index/sam_index_procesado.csv")
df_photo <- read.csv("datasets/fotoperiodo/fotoperiodo_antartico.csv")
df_clima_chl <- read.csv("datasets/processed/eda_nasa_chl_48_1.csv") %>%
  mutate(month = as.numeric(format(as.Date(date), "%m"))) %>%
  group_by(month) %>%
  summarise(climatology_chl = mean(mean_chl, na.rm = TRUE), .groups = 'drop')

df_sam_rolling <- df_sam %>%
  arrange(year, month) %>%
  mutate(SAM_9m = zoo::rollmean(SAM_index, k=9, fill=NA, align="right"))

# Photoperiod handling: ensuring we have a value for each month/lat
# If df_photo is sparse, we might need to be careful.
# Let's check how many unique latitudes it has.
unique_lats_photo <- unique(df_photo$lat)
cat("Unique latitudes in Photoperiod:", length(unique_lats_photo), "\n")

df_photo_processed <- df_photo %>%
  mutate(lat_round = round(lat)) %>%
  group_by(year, month, lat_round) %>%
  summarise(daylight_hours_mean = mean(daylight_hours, na.rm = TRUE), .groups = 'drop')

df_master <- df_krill_processed %>%
  left_join(df_ice, by = c("year", "month")) %>%
  left_join(df_sam_rolling, by = c("year", "month")) %>%
  left_join(df_clima_chl, by = "month") %>%
  mutate(lat_round = round(LATITUDE)) %>%
  left_join(df_photo_processed, by = c("year", "month", "lat_round")) %>%
  mutate(prev_year_ice = SEASON - 1) %>%
  left_join(df_ice %>% select(year, month, ice_anomaly) %>% rename(ice_anomaly_prev = ice_anomaly),
            by = c("prev_year_ice" = "year", "month" = "month")) %>%
  mutate(chl_final = ifelse((is.na(daylight_hours_mean) | daylight_hours_mean == 0) & month %in% c(5, 6, 7, 8), 0.01, climatology_chl))

# Diagnostic before final drop
cat("\nFinal NA counts:\n")
colSums(is.na(df_master %>% select(dist_talud, pendiente, profundidad, sst_local, ice_extent_mean, ice_anomaly_prev, SAM_9m, daylight_hours_mean, chl_final))) %>% print()

# Final Clean
df_master_final <- df_master %>%
  drop_na(dist_talud, pendiente, profundidad, sst_local, ice_extent_mean, ice_anomaly_prev, SAM_9m, chl_final)

cat("Final records for model:", nrow(df_master_final), "\n")

# Save
write.csv(df_master_final, "datasets/processed/krill_master_binomial_FINAL.csv", row.names = FALSE)
cat("Saved to datasets/processed/krill_master_binomial_FINAL.csv\n")
