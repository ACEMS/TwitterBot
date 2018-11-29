# Google docs

#devtools::install_github("tidyverse/googlesheets4")
library(googlesheets4)
library(dplyr)
library(stringr)
loadNamespace("scholar")

ACEMS_people <-
  googlesheets4::read_sheet(ss = "https://docs.google.com/spreadsheets/d/1g1HP35bvlaOdDmx5zvDkI2e1diHOePkzgQPaEqmGnLk/edit?usp=sharing") %>%
  filter(Given != "Thiyanga")

GoogleIDs <-
  ACEMS_people %>% select(`Google Scholar ID`) %>% filter(stringr::str_detect(`Google Scholar ID`, "AAAAJ")) %>%
  mutate(scholarstr = `Google Scholar ID`) %>%
  group_by(scholarstr) %>%
  mutate(scholarID = substr(scholarstr, str_locate(pattern = "AAAAJ", scholarstr)[1] - 7, str_locate(pattern = "AAAAJ", scholarstr)[2])) %>%
  ungroup() %>%
  select(scholarID)

new_func <- function(...){return(scholar::get_publications(..., flush = TRUE))}

#max_n <- 6
max_n <- ceiling(dim(GoogleIDs)[1])

Pubs_df <- NULL

i = 1
condition <- TRUE
errored <- FALSE

while(condition){

  Pubs <- try(GoogleIDs[i,] %>% do(new_func(.$scholarID, pagesize = 1, cstart = 0, cstop = 0, sortby = "year")))
  
  R.cache::clearCache(prompt = FALSE)
  
  if(i == max_n){
    condition <- FALSE
  }
  
  i = i + 1
  
  if(class(Pubs) == "try-error"){
    if(errored){
      Sys.sleep(1800)
      i = i - 1
    }
    errored <- TRUE
    next
  } else {
    Pubs_df <- rbind(Pubs, Pubs_df)
    print(i)
  }
}

if(file.exists("pub.RData")){

  load("pub.RData")
  old_df <- new_df
  new_df <- Pubs_df
  
  write.csv(dplyr::setdiff(new_df, old_df), file = "setdiff.csv")
  
  new_df <- union(new_df, old_df)
} else {
  new_df <- Pubs_df
}
  
save(new_df, file = "pub.RData")

