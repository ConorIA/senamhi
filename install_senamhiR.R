cat("##### PSA ##### \n 
You are about to run remote code! It is always a good idea to review remote \
code before running, as a malicious actor could use a script like this to do \
naughty things on your computer.\n \
In this case, we are going to install the remotes package and use it to install\
senamhiR.\n\n")

if (readline("Would you like to proceed? (y/N)") %in% c("Y", "y")) {
  url <- "https://gitlab.com/ConorIA/senamhiR/-/archive/master/senamhiR-master.tar.gz"
  f <- tempfile()
  d <- tempdir()
  download.file(url, f)
  untar(f, exdir = d)
  devtools::install(file.path(d, "senamhiR-master"), dependencies = TRUE)
} else {
  stop("Review the remote code and try again.")
}
