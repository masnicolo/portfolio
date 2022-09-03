#loading the necessary packages
library(tidyverse)
library(janitor)
library(readxl)


#loading the data
ship_data <- read_excel("../../dirty_data_project/task_3/raw_data/seabirds.xls", sheet = "Ship data by record ID") %>% 
  clean_names()
bird_data <- read_excel("../../dirty_data_project/task_3/raw_data/seabirds.xls", sheet = "Bird data by record ID") %>% 
  clean_names()

## rename columns and select only necessary columns
bird_data_clean <-
  bird_data %>%
  rename(
    common_name = species_common_name_taxon_age_sex_plumage_phase,
    scientific_name = species_scientific_name_taxon_age_sex_plumage_phase,
  ) %>%
  select(record_id, common_name, scientific_name, species_abbreviation, count)

## for cases when the bird has an entry in the age, wanplum, plphase or sex column this info appended on the common_name, scientific_name, species_abbreviation columns, and so when we do any groupings in the analysis these are picked up as different species when really they are the same bird of different ages, plumage phase or sex. We want to only hold this information in the separate info columns and remove from the name columns.
#the code to do this makes assumption that this 'extra' information held in the common_name & scientific_name column is held on the right of the name and all in capitals and numbers. For the species_abbreviation column (which is all in capitals) make assumption that the abbreviation has no spaces in it and therefore only take the information to the left hand side of the space. These assumptions were made from exploration of these columns. 

bird_data_clean_species <- bird_data_clean %>%
  mutate(across(common_name:scientific_name, ~str_remove(.x, "[A-Z0-9 ]+$")))  %>%
  mutate(species_abbreviation = str_extract(species_abbreviation, "[A-Z]+"))

# select the necessary columns
ship_data_clean <-
  ship_data %>%
  select(record_id, lat, long)

# join bird and ship data
bird_ship_data <-
  bird_data_clean_species %>%
  left_join(ship_data_clean, by="record_id")

# write clean data to csv
write_csv(bird_ship_data, "clean_data/bird_ship_data.csv")

