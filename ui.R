library(shiny)
library(leaflet)

shinyUI(fluidPage(
        tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
        leafletOutput("map"),
        div(tableOutput("table"), style = "font-size: 80%")
))