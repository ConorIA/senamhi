##' @title Curl helper
##' 
##' @description A helper function to execute download actions using curl.
##'
##' @param url character; address to be downloaded.
##' @param filename character; name to save the downloaded file under.
##' @param write_mode character; if set to 'overwrite' the script will overwrite file if it exists.
##'
##' @return None
##' 
##' @keywords internal
##'
##' @author Conor I. Anderson
##'
##' @importFrom curl curl_download

.download_action <- function(url, filename, write_mode = "z") {
  if (!file.exists(filename) | write_mode == "overwrite" | file.info(filename)$size == 
    0) {
    download <- try(curl_download(url, filename))
    if (inherits(download, "try-error")) {
      warning("Caught an error. Retrying file.", immediate. = TRUE)
      unlink(filename)
      download <- try(curl_download(url, filename))
      if (inherits(download, "try-error")) {
        stop("Could not download the requested file.")
      }
    }
  }
}
