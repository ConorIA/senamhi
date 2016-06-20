##' @title Curl helper
##' 
##' @description A helper function to execute download actions using curl.
##'
##' @param url character; address to be downloaded.
##' @param filename character; name to save the downloaded file under.
##' @param overwrite logical; if true, the script will overwrite file if it exists.
##'
##' @return None
##'
##' @author Conor I. Anderson
##'
##' @importFrom curl curl_download
##'
##' @export

downloadAction <- function(url, filename, overwrite = FALSE) {
  if (!file.exists(filename) | overwrite | file.info(filename)$size == 0) {
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