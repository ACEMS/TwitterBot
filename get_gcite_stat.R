# Function to create one row data frame for Google citations
get_gcite_stat <- function(Name, Role, Campus, GS_link) {
  if (!is.na(GS_link)) {
    GS_link %>%
      gcite::gcite_url() %>%
      gcite::gcite_citation_index() %>%
      gather(key = "Period", value = "count", -index) %>%
      mutate(Measure = c("Citations", "hindex", "i10index",
                         "Citations_5yr", "hindex_5yr", "i10index_5yr")) %>%
      select(Measure, count) %>%
      spread(Measure, count) %>%
      mutate(Name = Name, Role = Role, Campus = Campus)
  }
}
# Read list of names and GS URLs
rawdata <- read_csv("database.csv")

gcite <- rawdata %>%
  pmap(get_gcite_stat) %>%
  bind_rows() %>%
  select(Name, Role, Campus, everything())

# Order by roles and citations
gcite <- gcite %>%
  mutate(
    Role = factor(Role, levels = c(
      "Assistant Lecturer",
      "Lecturer",
      "Senior Lecturer",
      "Associate Professor",
      "Professor",
      "Emeritus Professor"))
  ) %>%
  arrange(desc(Role), desc(Citations))