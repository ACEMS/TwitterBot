# Google docs

#devtools::install_github("tidyverse/googlesheets4")
library(googlesheets4)
library(dplyr)
library(stringr)

ACEMS_people <-
  googlesheets4::read_sheet(ss = "https://docs.google.com/spreadsheets/d/1g1HP35bvlaOdDmx5zvDkI2e1diHOePkzgQPaEqmGnLk/edit?usp=sharing")

GoogleIDs <-
  ACEMS_people %>% select(`Google Scholar ID`) %>% filter(stringr::str_detect(`Google Scholar ID`, "AAAAJ"))
                                                          