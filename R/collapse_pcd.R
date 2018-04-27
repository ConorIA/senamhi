#' Collapse Senamhi stations with common variables
#'
#' @param datain a list of individual station tables acquired through the \code{senamhiR} function.
#' 
#' @importFrom dplyr bind_rows
#'
#' @return a list of collapsed stations
#' @export
#'

collapse_pcd <- function(datain) {
  dataout <- mapply(add_column, .data = datain, StationID = lapply(datain, attr, "StationID"), MoreArgs = list(.before = 1), SIMPLIFY = FALSE, USE.NAMES = FALSE)
  name_groups <- sapply(dataout, function(x) {paste(names(x), collapse = ", ")})
  name_groups <- sapply(name_groups, function(x, name_groups) {which(name_groups == x)}, unique(name_groups))
  dataout <- lapply(unique(name_groups), function(x, dataout, name_groups) {do.call("bind_rows", dataout[name_groups == x])}, dataout, name_groups)
  if(length(dataout) == 1) return(dataout[[1]])
  dataout
}