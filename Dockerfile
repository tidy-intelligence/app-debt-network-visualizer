FROM rocker/shiny

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Ensure R can access the correct package repository
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site

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
RUN mkdir -p /srv/shiny-server/app
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY app.R /srv/shiny-server/app/app.R

# Ensure correct permissions
RUN chown -R shiny:shiny /srv/shiny-server
RUN mkdir -p /var/log/shiny-server && \
    chown -R shiny:shiny /var/log/shiny-server && \
    chmod -R 755 /var/log/shiny-server

# Expose port for Shiny
EXPOSE 8080

# Run the Shiny app
CMD ["/usr/bin/shiny-server"]