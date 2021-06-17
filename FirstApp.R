library(shiny)
library(tidyverse)

# Version 1.0

FirstApp <-fluidPage(
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
        tabPanel("Tabellen",tabsetPanel(tabPanel("Tabelle 1",tags$p("Erste Tabelle ist eine Kreuztabelle zwischen die nach TNM klassifizierte Tumorgrößen und Altersgruppen :"), tableOutput("tab_01")
                                                 ,tags$p("Anschaulich gibt es keine Patient über 45 Lebensjahr , deren Tumoren T1(<2 cm) nach TNM klassifiziert .Sowie besteht es keine junge Patienten an T2 Tumoren betroffen .")
                                                 ,br(), actionButton("but_01", "Abhängigkeit testen")), tabPanel("Tabelle 2 ","Zweite Tabelle ist eine Kreuztabelle zwischen Rauchen und Tumorgrößen", tableOutput("tab_02"),
                                                                                                                 tags$p("Hier ist die Gleichheit der Risiko in beiden Gruppen zu untersuchen. Ein sinvolles Maß ist ODDS RATIO.")
                                                                                                                 ,br(), actionButton("but_02", "Risiko vergleichen")
                                                 ),tabPanel("Tabelle 3",tags$p("Dritte Tabelle ist eine Kreuztabelle zwischen Cholesterinwerte und Tumorgrößen : "),tableOutput("tab_03"),
                                                 tags$p("Es gibt keine Patienten ,die höhe Cholesterinwerte und große Tumoren haben . Hier ist festzustellen , dass die Tumorgrößen bei allen Cholesterin-Gruppen gleich ist ."), 
                                                br(),tags$p("Die erwartete Häufigkeiten"), tableOutput("expected"),
                                                          br(), actionButton("but_03", "Homogenität testen")))),
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
#c,tags$p("Dritte Tabelle ist eine Kreuztabelle zwischen Cholesterinwerte und Tumorgrößen"), tableOutput("tab_03"),
#          tags$p( "Hier ist festzustellen , dass die Tumorgrößen bei allen Cholesterin-Gruppen gleich ist . ")
#          ,br(), actionButton("but_03", "Homogenität testen"))
