cat("##### PSA ##### \n 
You are about to run remote code! It is always a good idea to review remote code \
before running, as a malicious actor could use a script like this to do naughty \
things on your computer.\n \
In this case, we are going to install the senamhiR package, and a couple of \
packages that we need to install it.\n\n")

proceed <- readline(prompt = "Would you like to proceed? (y/N)")

if (proceed == "Y" || proceed == "y") {
  if (!any(c("devtools", "remotes") %in% rownames(installed.packages()))) {
    install.packages("devtools")
  }
  if("devtools" %in% rownames(installed.packages()) == TRUE) {
    devtools::install_gitlab("ConorIA/senamhiR")
  } else {
    remotes::install_gitlab("ConorIA/senamhiR")
  }
} else {
  stop("Review the remote code and try again.")
}
