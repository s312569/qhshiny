# Install R version 3.6
FROM rocker/shiny-verse:3.6.0

# Install R packages that are required
RUN R -e "install.packages(c('shiny', 'plotly', 'shinycssloaders', 'survival', 'survminer', 'broom', 'rio', 'whisker', 'condusco', 'DBI', 'data.table', 'DT'), repos='http://cran.rstudio.com/')"
RUN apt-get install -y nginx
RUN apt-get install -y apache2-utils
RUN service nginx stop
RUN htpasswd -cb  /etc/nginx/.htpasswd testuser password
COPY /nginx-default /etc/nginx/sites-available/default
COPY /shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY /run.sh run.sh
COPY /app /srv/shiny-server/app

# Make the ShinyApp available at port 3838
EXPOSE 3838

CMD ./run.sh