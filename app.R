library(dash)
library(here)
library(readr)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(ggthemes)
library(ggplot2)
library(plotly)
#library(tidyverse)
library(purrr)

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

data <- readr::read_csv(here::here('data', 'bei_vita_qwl_assessment.csv'))

#data <- read.csv('E:/MDS/TERM5/DSCI_532/dashr-heroku-deployment-demo/bei_vita_qwl_assessment.csv')

data <- data %>% select('Username','Total score','Country of Residence')
data <- data %>% rename(Total_score = 'Total score', Country_of_Residence = 'Country of Residence')

app$layout(
    dbcContainer(
        list(
            htmlLabel('Country of Residence'),
            dccDropdown(
                id='col-select',
                options = unique(data$Country_of_Residence)%>% purrr::map(function(col) list(label = col, value = col)),
            value = 'Japan'
            ),
            dccGraph(id='plot-area')
        )
    )
)

app$callback(
    output('plot-area', 'figure'),
    list(input('col-select', 'value')),
    function(col){
        data_sub <- filter(data, Country_of_Residence == col)
        p <- ggplot(data_sub, aes(x= Total_score))+ 
            geom_area(stat ="count", color="darkblue",
                      fill="lightblue", size = 1) +
            ggthemes::scale_color_tableau()
        ggplotly(p) %>% layout(dragmode = 'select')
        }
)

app$callback(
    list(output('output-area', 'children'),
         output('output-area2', 'children')),
    list(input('plot-area', 'selectedData'),
         input('plot-area', 'hoverData')),
    function(selected_data, hover_data) {
        list(toString(selected_data), toString(hover_data))
    }
)

app$run_server(host = '0.0.0.0')
