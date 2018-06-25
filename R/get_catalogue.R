#' Get updated table from SQL
#'
#' @return tbl_df
#' 
#' @importFrom DBI dbConnect dbDisconnect dbReadTable
#' @importFrom RMySQL MySQL
#' @importFrom tibble as_tibble
#' 
#' @keywords internal
#'
#' @author Conor I. Anderson

.get_catalogue <- function() {
  conn <- dbConnect(MySQL(), user = "anonymous", host = "pcd.conr.ca", dbname = "pcd")
  on.exit(dbDisconnect(conn))
  cat <- try(as_tibble(dbReadTable(conn, "catalogue", row.names = NULL)))
  if (inherits(cat, "try-error")) {
    warning(paste("We couldn't download the catalogue.",
                  "These results might be slightly outdated."))
    return(catalogue)
  } else {
    names(cat) <- names(catalogue)
    cat
  }
}