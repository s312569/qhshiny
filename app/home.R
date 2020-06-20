######################################################################
## plots
######################################################################

plotTotalUsage <- function(data, options) {
    d <- group_by(data, date) %>%
        summarise(total = sum(usage)) %>%
        mutate(sdev = sd(total)*2) %>%
        mutate(contlim = total + sdev)

    p <- ggplot(data = d, aes(x = date, y = total)) +
        scale_x_date(date_breaks = "1 year", date_labels = "%b-%Y",
                     name = "Month - Year") +
        scale_y_continuous(name = "DDD / 1000 patient-days")

    print(options)
    if("points" %in% options) p <- p + geom_point()
    if("smooth" %in% options) p <- p + stat_smooth(colour = 'red')
    if("line" %in% options) p <- p + geom_line()
    if("controlLimit" %in% options) {
        p <- p + geom_smooth(se = FALSE, aes(y = contlim), color = 'orange')
    }
    p
}

######################################################################
## UI
######################################################################

checkboxesPlot <- function() {

}

homeUI <- function() {
    sidebarLayout(
        sidebarPanel(width = 2,
                     selectizeInput("hospitalIn", "Select hospital", getHospitals()),
                     htmlOutput("tlDateRangeUI"),
                     htmlOutput("resetDatesUI"),
                     checkboxGroupInput(
                         'plotOptions',
                         "Plot Options:",
                         choiceNames = c("Points", "Smooth", "Line", "Control Limit"),
                         choiceValues = c("points", "smooth", "line", "controlLimit"),
                         selected = "smooth"
                     )),
        mainPanel(
            tabsetPanel(
                type = "tabs",
                tabPanel("By Date",
                         column(12, withSpinner(plotlyOutput("totalUsagePlot")))
                                 ## column(12, div(style = "font-size: 80%",
                         ##                DT::dataTableOutput("historyWOs"))),
                         ## column(12, withSpinner(plotlyOutput("tlSMUHoursPlot"))),
                         ## br(),
                         ## column(12, verbatimTextOutput("tlSMUHoursSum")))
                         )
            )
        )
    )
}

######################################################################
## server functions
######################################################################

registerHomePlot <- function(session, rvs, input, output) {

    observe({
        req(input$hospitalIn)
        rvs$data <- filterDates(input$hospitalIn)
    })

    observeEvent(input$resetDates, {
        rvs$data <- filterDates(input$hospitalIn)
    }, ignoreInit = TRUE)

    output$tlDateRangeUI <- renderUI({
        s <- ymd(min(isolate(data$date)))
        e <- ymd(max(isolate(data$date)))
        dateRangeInput("tlDateRangeIn", "Date Range:", start = s, end = e)
    })

    output$resetDatesUI <- renderUI({
        req(rvs$data)
        actionButton("resetDates", "Reset")
    })

    observe({
        req(input$tlDateRangeIn)
        rvs$data <- filterDates(input$hospitalIn,
                                input$tlDateRangeIn[1],
                                input$tlDateRangeIn[2])
    })

    output$totalUsagePlot <- renderPlotly({
        req(rvs$data)
        plotTotalUsage(rvs$data, input$plotOptions)
    })

}
