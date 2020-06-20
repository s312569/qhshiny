library(dplyr)
library(shiny)
library(stringr)
library(lubridate)
library(ggplot2)
library(plotly)
library(shinycssloaders)
library(survival)
library(survminer)
library(broom)
library(rio)
library(whisker)
library(condusco)
library(DBI)
library(data.table)
library(tidyverse)
source("./config.R")
source("./utilities.R")
source("./data.R")
source("./home.R")

######################################################################
## UI
######################################################################

ui <- function() {
    navbarPage(
        "Cairns AMS Data",
        tabPanel("Home", homeUI())
    )
}

######################################################################
## server
######################################################################

server <- function(session, input, output) {
    rvs <- reactiveValues()
    registerHomePlot(session, rvs, input, output)
}

######################################################################
## app
######################################################################

shinyApp(ui = ui, server = server)
