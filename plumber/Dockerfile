FROM trestletech/plumber
MAINTAINER Conor Anderson <conor@conr.ca>

COPY plumber.R /api/plumber.R
COPY catalogue.rds /catalogue.rds

RUN apt-get update &&\
  apt-get install -y --no-install-recommends curl libmariadb-dev &&\
  apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/*

RUN cd /api &&\
  sed -rn 's/library\((.*)\)/\1/p' plumber.R | sort | uniq > needed_packages &&\
  curl https://gitlab.com/ConorIA/conjuntool/snippets/1788463/raw?inline=false > install_pkgs.R &&\
  Rscript install_pkgs.R &&\
  rm -rf /tmp/* needed_packages install_pkgs.R

CMD ["/api/plumber.R"]
