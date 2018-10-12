install_via_remotes <- function() {
  print("Installing using the remotes package via install.github.me")
  source("https://install-github.me/r-lib/remotes")
  remotes::install_gitlab("ConorIA/senamhiR")
}

install_fallback <- function() {
  print("Falling back to install via devtools")
  if("devtools" %in% rownames(installed.packages()) == FALSE) {
    install.packages("devtools", repos = "https://cloud.r-project.org")
  }
  url <- "https://gitlab.com/ConorIA/senamhiR/-/archive/master/senamhiR-master.tar.gz"
  f <- tempfile()
  d <- tempdir()
  download.file(url, f)
  untar(f, exdir = d)
  devtools::install(file.path(d, "senamhiR-master"), dependencies = TRUE)
}

cat("##### PSA ##### \n 
You are about to run remote code! It is always a good idea to review remote \
code before running, as a malicious actor could use a script like this to do \
naughty things on your computer.\n \
In this case, we are going to install the remotes package and use it to install\
senamhiR.\n\n")

if (readline("Would you like to proceed? (y/N)") %in% c("Y", "y")) {
  result <- try(install_via_remotes())
  if(inherits(result, "try-error")) {
    warning(paste("There was an issue installing with remotes.", 
                  "Falling back to tarball install."))
    result <- try(install_fallback())
    if(inherits(result, "try-error")) {
      stop("We encountered an error during install. Sorry about that!")
    }
  }
} else {
  stop("Review the remote code and try again.")
}