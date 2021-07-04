library(shiny)
library(tidyverse)

# Version 1.0

FirstApp <-fluidPage(
  titlePanel("Cancer App"),
  sidebarLayout(
    sidebarPanel(
      p('Gruppe 5'),br(),
      p('Gruppemitglieder : Benjamin Michel , Kussi Katsha , Devirm Evelik') ,
      p('Version 1.0'),br(),
      p('Dieses App wurde im Rahmen der Vorlesung Einführung in R und Shiny erstellt .'),br(),
      p('Datensatz : cancer_data.csv ')
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data Table", selectInput(
          "selectvals", 
          label = h3("AusgabeKriterien : "), 
          choices = c("Alle Raucher","Alle NichtRaucher","Alle Frauen Raucher","Alle Männer Raucher","Alle Männer","Alle Frauen","Alle Beobachtungen"),
          selected ="Alle Beobachtungen"
        ),actionButton("refreshbut", "refresh"),tableOutput("value")),
      
      

        tabPanel("Grafiken",
            
            
          
                 
               
                 tabsetPanel(tabPanel("graph1",
                                      
                                      selectInput(
                                        "var1", 
                                        label = h3("Select X variable :"), 
                                        choices = c("chol","BMI","tumour_size"),
                                        selected ="tumour_size"
                                      ),
                                      
                                      selectInput(
                                        "var2", 
                                        label = h3("Select Y Variable :"), 
                                        choices = c("chol","BMI","tumour_size"),
                                        selected ="BMI"
                                      ),
                                      radioButtons("color", "Färbung nach:",
                                                   list("Geschlecht" = "gender",
                                                     "Rauchen" = "smoking",
                                                     "None" = "Null")),actionButton("goButton", "Update"),
          plotOutput("plot1"),textOutput("plotLabeling")),tabPanel("graph2",
                                                                                                  radioButtons("dist", "Einteilung nach:",
                                                                                                         list("Geschlecht" = "gender",
                                                                                                              "Rauchen" = "smoking",
                                                                                                             "None" = "FALSE")),actionButton("goButton_01", "Update"),  
                                                                                                                 plotOutput("plot2"),textOutput("plotLabeling1")),tabPanel("graph3",
                                                                                                                                                                                  radioButtons("befuellen", "Säulenbefüllung nach:",
                                                                                                                                                                                   list("Tumorgrößen" = "tumor_size_dichotom",
                                                                                                                                                                                        "Cholesterin" = "chol_dichotom",
                                                                                                                                                                                          "Geschlecht" = "gender")),plotOutput("plot3"),
                                                                                                                                                                           textOutput("plotLabeling2")))),
         

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
                 h1('Warum Lungenkrebs ?'),br(),
                 p('Der Lungenkrebs ist eine menschenabhängige und auch eine sehr häufig auftretende Krebsart. Daher haben wir den Lungenkrebs auf unserem Projekt bezogen.
                   Dieser ist ein bösartiger Tumor, der von Bronchialschleimhautzellen oder Lungengewebezellen ausgeht. Ärzte nennen diesen Krebs auch Lungenkarzinom oder Bronchialkarzinom
                   Das Bronchialkarzinom tritt hauptsächlich im Alter zwischen 50 und 70 Jahren auf. Das durchschnittliche Erkrankungsalter bei Diagnosestellung beträgt nur 69 Jahre. 
                   Im Frühstadium von Lungenkrebs gibt es fast keine typischen Anzeichen und Symptome. Deshalb bleibt es oft lange unentdeckt. Bei Lungenröntgenuntersuchungen finden Ärzte häufig nur
                   zufällig den Lungenkrebs, da der Patient an chronischem Husten, Atemnot oder Kurzatmigkeit leidet.'),br(),
                 p('Für den Lungenkrebs ist mit weitem Abstand das Rauchen die Ursache. Ungefähr 90 Prozent aller Bronchialkarzinom-Patienten sind oder waren Raucher. Dabei hängt das Risiko vor allem davon ab,
                 wie viel der Betroffene geraucht hat. Fachleute drücken dies anhand der Packungsmenge aus: Je mehr Zigaretten geraucht wurden, desto höher ist das Krebsrisiko. 
                  Doch nicht nur selber zu rauchen macht krank, auch Passivrauchen erhöht das Risiko, an Lungenkrebs zu erkranken – und zwar um den Faktor 1,3 bis 2. Wer also das Rauchen aufgibt, kann das Risiko für Lungenkrebs deutlich senken.
                  Vor allem für sich selbst, aber auch für seine Mitmenschen.'),br(),
                 p('Shiny Visualization. R Shiny Apps, Sommersemester 2021'),br(),
                 
                 p('Version 3.0'),br(),
                 p('Last update: 04-JULY-2021'),br(),
                 p('Used packages: tidyverse(1.3.0), shiny(1.6.0)'),br(),
                 p('Author: Benjamin Michel, Kussi Katsha, Devirm Evelik')
        )
      )
    )
  
)
)
