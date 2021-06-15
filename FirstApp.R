library(shiny)
library(tidyverse)

# Version 1.0

fluidPage(
  titlePanel("Iris App"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "species",
        label = h3("Select species"),
        choices = iris$species
      )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data Table", tableOutput("table")),
        tabPanel("Plot", plotOutput("plot")),
        tabPanel("About",
                   br(),h3('About this R Shiny App'),br(),
                   p('Shiny Visualization. R Shiny Apps, Sommersemester 2021'),br(),
                   p('Version 1.0'),br(),
                   p('Last update: 17-MAY-2021'),br(),
                   p('Used packages: tidyverse(1.3.0), shiny(1.6.0)'),br(),
                   p('Author: Benjamin Michel')
                   )
      )
    )
  )
)
