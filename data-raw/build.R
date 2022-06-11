pkgload::load_all()
library(dplyr)
library(tibble)
library(tidyr)
library(purrr)
library(data.table)
game_days <- get_game_days()

games <- purrr::map(game_days$GameDate,get_game_ids) |>
  data.table::rbindlist(use.names = TRUE, fill = TRUE) |>
  mutate(
    across(c(GameEffTime,Spectator,Latitude,Longitude,HomeAssociation,AwayAssociation,GameTitleID,GameTitleOrder),map_chr,1)
  ) |>
  unnest_wider(PeriodSummary,names_sep = "_") |>
  unnest_wider(PeriodSummary_PeriodGoals, names_sep = "_") |>
  mutate(
    across(c(PeriodSummary_PeriodGoals_Home,PeriodSummary_PeriodGoals_Away),~map_chr(.x,~unlist(.x) |> paste(collapse = ",")))
  )

saveRDS(games,"data/raw/games.rds")

game_events <- purrr::map(unique(games$GameID), get_game_events) |>
  set_names(games$GameID)

saveRDS(game_events,"data/raw/game_events.rds")

rosters <- purrr::map(games$GameID, get_rosters) |>
  set_names(games$GameID)

saveRDS(rosters,"data/raw/rosters.rds")
