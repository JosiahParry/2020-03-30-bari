library(rvest)
library(dplyr)
library(stringr)
library(purrr)

session <- html_session("http://insideairbnb.com/get-the-data.html")

all_downloads <- session %>% 
  html_nodes("table.table-hover.table-striped.boston a")

# construct download files and destination files
paths <- tibble(
  f_names = html_text(all_downloads), 
  fpaths = html_attr(all_downloads, "href")
  ) %>% 
  filter(str_detect(f_names, "listings.csv.gz")) %>% 
  mutate(dest_path = glue::glue("data-raw/{str_extract(fpaths, '[0-9]{4}-[0-9]{2}-[0-9]{2}')}-listings.csv.gz"))

# download all of the files
map2(paths$fpaths, paths$dest_path, download.file)



#-------------------------------- combine data --------------------------------#
fps <- list.files("data-raw", full.names = TRUE)

all_listings <- map_dfr(fps, readr::read_csv)

#readr::write_csv(all_listings, glue::glue("data/{Sys.date}-historical-airbnb.csv"))

