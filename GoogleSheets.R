# Google docs

#devtools::install_github("tidyverse/googlesheets4")
library(googlesheets4)
library(dplyr)
library(stringr)
loadNamespace("scholar")

ACEMS_people <-
  googlesheets4::read_sheet(ss = "https://docs.google.com/spreadsheets/d/1g1HP35bvlaOdDmx5zvDkI2e1diHOePkzgQPaEqmGnLk/edit?usp=sharing")

GoogleIDs <-
  ACEMS_people %>% select(`Google Scholar ID`) %>% filter(stringr::str_detect(`Google Scholar ID`, "AAAAJ")) %>%
  mutate(scholarstr = `Google Scholar ID`) %>%
  group_by(scholarstr) %>%
  mutate(scholarID = substr(scholarstr, str_locate(pattern = "AAAAJ", scholarstr)[1] - 7, str_locate(pattern = "AAAAJ", scholarstr)[2])) %>%
  ungroup() %>%
  select(scholarID)

Publication_list <- GoogleIDs[1:5,] %>% group_by(scholarID) %>% do(scholar::get_publications(.$scholarID))
