######################################################################
## utilities
######################################################################

loadData <- function(file = "../data/2006-2020_Statedata.csv") {
    import(file) %>%
        mutate(usage = (ddd / obd) * 1) %>%
        filter(obd > 0, ddd > 0) %>%
        mutate(date = dmy(date)) %>%
        mutate(q99=quantile(usage, probs=c(.99), na.rm = FALSE),
               q01=quantile(usage, probs=c(.01), na.rm = FALSE)) %>%
        mutate(out = ifelse(usage < q99, FALSE, TRUE)) %>%
        filter(!out)
}

data <- loadData()
start <- ymd(min(data$date))

######################################################################
## api
######################################################################

getHospitals <- function() { pull(data, hospital) %>% unique() }

filterDates <- function(h, t1 = NULL, t2 = NULL) {
    t1 <- if (is.null(t1)) as_date(0) else t1
    t2 <- if (is.null(t2)) today() else t2

    filter(data, hospital == h) %>%
        filter(date >= t1, date <= t2)
}
