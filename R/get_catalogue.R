#' Get updated table from SQL
#'
#' @return tbl_df
#' 
#' @importFrom httr content GET stop_for_status
#' 
#' @keywords internal
#'
#' @author Conor I. Anderson

.get_catalogue <- function() {
  r <- GET("https://api.conr.ca/pcd/catalogue", 
           config = list(add_headers(accept = "application/octet-stream")))
  stop_for_status(r)
  unserialize(content(r))
}