get_game_days <- function(){
  district <- httr::POST(
    url = 'http://tulospalvelu.leijonat.fi/helpers/getDistrict.php',
    body = list(
      `season` = '0',
      `districtid` = '-1'
    ))
  httr::stop_for_status(district)

  game_days <- district |>
    httr::content(as = "text") |>
    jsonlite::parse_json() |>
    purrr::pluck("GameDays") |>
    data.table::rbindlist(use.names = TRUE, fill = TRUE)

  return(game_days)
}

get_game_ids <- function(game_date){

  games <- httr::POST(
    url = 'http://tulospalvelu.leijonat.fi/helpers/getGames.php',
    body = list(
      `season` = '0',
      `stgid` = '0',
      `teamid` = '0',
      `districtid` = '-1',
      `gamedays` = '-1',
      `dog` = as.character(game_date)
    )
  )

  httr::stop_for_status(games)

  games <- games |>
    httr::content(as = "text") |>
    jsonlite::parse_json() |>
    purrr::pluck(1,"Games") |>
    tibble::tibble() |>
    tidyr::unnest_wider(1)

  return(games)
}

get_game_events <- function(game_id){

  game_events <- httr::POST(
    url = 'http://tulospalvelu.leijonat.fi/unsync/front1/statsapi/gamereports/getgamereportdata.php',
    body = list(gameid = game_id)
  )

  httr::stop_for_status(game_events)

  game_events_list <- game_events |>
    httr::content(as = "text") |>
    jsonlite::parse_json()

  # Do more processing here, e.g. if you want to make it a data frame first, then return the dataframe

  return(game_events_list)
}

get_rosters <- function(game_id){

  rosters <- httr::POST(
    url = 'http://tulospalvelu.leijonat.fi/game/helpers/getRosters.php',
    body = list(gameid = game_id,
                season = "2022")
  )

  httr::stop_for_status(rosters)

  rosters_list <- rosters |>
    httr::content(as = "text") |>
    jsonlite::parse_json()

  # Do more processing here, e.g. if you want to make it a data frame first, then return the dataframe

  return(rosters_list)
}
