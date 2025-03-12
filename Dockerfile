FROM rocker/r2u

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    pkg-config \
    gdebi-core \
    wget \
    && wget https://download3.rstudio.org/ubuntu-20.04/x86_64/shiny-server-1.5.23.1030-amd64.deb \
    && gdebi -n shiny-server-1.5.23.1030-amd64.deb \
    && rm shiny-server-1.5.23.1030-amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure R can access the correct package repository
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/

# Install baseline R packages for golem
RUN R -e "install.packages(c('remotes', 'shiny', 'bslib', 'config', 'testthat', 'spelling', 'golem'))"

# Install additional R packages for app
RUN R -e "install.packages(c('shinycssloaders', 'visNetwork', 'shinyjs', 'stringr', 'duckdb', 'DBI', 'dplyr'))"

# Create a build directory
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone

# Install app as local R package
RUN R -e 'remotes::install_local(upgrade="never")'

# Cleanup build files
RUN rm -rf /build_zone

# Configure Shiny Server
RUN mkdir -p /srv/shiny-server/app && \
    chown -R shiny:shiny /srv/shiny-server
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY app.R /srv/shiny-server/app/app.R
COPY

# Ensure correct permissions to delete logs
RUN mkdir -p /var/log/shiny-server && \
    chown -R /var/log/shiny-server && \
    chmod -R 777 /var/log/shiny-server

# Grant read access to all files in R package library for the shiny user
RUN chown -R shiny:shiny /usr/local/lib/R/site-library/ && \
    chmod -R 755 /usr/local/lib/R/site-library/

# Expose port for Shiny
EXPOSE 8080

# Run the Shiny app
CMD ["/usr/bin/shiny-server"]