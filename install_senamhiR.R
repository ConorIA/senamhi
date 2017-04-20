cat("##### PSA ##### \n 
You are about to run remote code! It is always a good idea to review remote code \
before running, as a malicious actor could use a script like this to do naughty \
things on your computer.\n \
In this case, we are going to install the senamhiR package, and a couple of \
packages that we need to install it.\n\n")

proceed <- readline(prompt = "Would you like to proceed? (y/N)")

if (proceed == "Y" || proceed == "y") {
  if("git2r" %in% rownames(installed.packages()) == FALSE) {
    install.packages("git2r", repos = "https://cran.rstudio.com")
  }
  if("devtools" %in% rownames(installed.packages()) == TRUE) {
    devtools::install_git("https://gitlab.com/ConorIA/senamhiR.git")
  } else if("remotes" %in% rownames(installed.packages()) == TRUE) {
    remotes::install_github("r-pkgs/remotes")
  } else {
    source("https://raw.githubusercontent.com/r-pkgs/remotes/master/install-github.R")$value("r-pkgs/remotes")
  } 
  remotes::install_git("https://gitlab.com/ConorIA/senamhiR.git")
} else {
  stop("Review the remote code and try again.")
}
