#Version 1.0
library(epiR)
library(ggplot2)

server<-function(input, output){
  initial_data <- read.csv("cancer_data.csv",sep=",",header = TRUE)
  
  
  #2.add new columns 
  
  #2.1 add altersgrppe 
  table(initial_data$age) # see frequency table of age
  summary(initial_data$age) # see the Characteristic values 
  data_01 <- initial_data%>%mutate(altersgruppe=case_when( # add new column for age class based on Characteristic values 
    between(age,18,29) ~ "under 30 ",
    between(age,30,44) ~ "30-44",
    between(age,45,59) ~ "45-59 ",
    between(age,60,100) ~ "above 60"))
  
  #2.2 add tumor_size_dichotom 
  summary(initial_data$tumour_size) # see the Characteristic values
  data_01 <- data_01%>%mutate(tumor_size_dichotom=case_when( # add new column for tumor_size_dichotom based on Characteristic values 
    between(tumour_size,1.6,2) ~ "T1 ",
    between(tumour_size,2,5) ~ "T2"))
  
  #2.3 round height to whole numbers
  data_01$height <- round(data_01$height) 
  
  #2.4 round weight to whole numbers
  data_01$weight <- round(data_01$weight) 
  
  #2.5 add BMI column acorrding to formula
  data_01 <- data_01%>%mutate(BMI=weight/(height/100)^2)
  
  #3 encoding 0,1 variables (Gender, Smoking)
  data_01$gender <- factor(data_01$gender,
                           levels = c(0,1),
                           labels = c("männlich", "weiblich"))
  
  #source :https://www.statmethods.net/input/valuelabels.html
  data_01$smoking <- factor(data_01$smoking,
                            levels = c(0,1),
                            labels = c("nicht-raucher", "raucher"))
  
  # select columns which are required for analysis and visualising 
  data_final <- select(data_01,c(ID,age,chol,gender,weight,height,smoking,tumour_size,tumor_size_dichotom,altersgruppe,BMI))
  
  #missing values handling : complete the missing values with by gender distributred averages
  chol_mean_weiblich <- data_final%>%select(chol,gender)%>%filter(gender=="weiblich") %>%select(chol)%>% sapply(FUN=mean,na.rm=TRUE)
  chol_mean_maenlich <- data_final%>%select(chol,gender)%>%filter(gender=="männlich") %>%select(chol)%>% sapply(FUN=mean,na.rm=TRUE)
  
  #complete the missing values in sub-dataframes
  data_final_m<-data_final%>%filter(gender=="männlich") %>%complete(chol , fill = list(chol = chol_mean_maenlich[[1]]))
  data_final_w<-data_final%>%filter(gender=="weiblich") %>%complete(chol , fill = list(chol = chol_mean_weiblich[[1]]))
  
  #merge completed datframes
  data_final<-rbind(data_final_m, data_final_w)
  
  #2.6 add chol_dichotom 
  #reference :https://www.praktischarzt.de/untersuchungen/blutuntersuchung/cholesterinwerte/
  data_final <- data_final%>%mutate(chol_dichotom=case_when( # add new column for tumor_size_dichotom based on Characteristic values 
    between(chol,146,199.286331116283) ~ "niedrig",
    between(chol,200,220.944676112364) ~ "normal",
    between(chol,221,282) ~ "hoch"))
  
  #2.7 BMI dichotom 
  #https://schlaganfallbegleitung.de/wissen/bmi
  data_final <- data_final%>%mutate(BMI_dichotom=case_when( # add new column for tumor_size_dichotom based on Characteristic values 
    BMI <18.5 ~ "untergewicht",
    between(BMI,18.5,25) ~ "normal",
    BMI>25 ~ "Übergewicht"))
  
  # ID relocate in data frame
  data_final <- data_final%>%relocate(ID,chol)
  
  #sort values in data frame by ID using order
  data_final <-data_final[order(data_final$ID),]
  #datasetInput <- reactive(input$checkGroup,{
  #  perm.vector <- as.vector(input$checkGroup)
   # perm.vector
  #}) 
  observe({
    input$selectvals
    valsk<- eventReactive(input$refreshbut, {
      input$selectvals
    })
    k<-valsk()
    if(k=="Alle Beobachtungen"){output$value <-renderTable(data_final)}
    else if(k=="Alle Raucher"){output$value <-renderTable(filter(data_final,smoking=="raucher"))}
    else if (k=="Alle NichtRaucher"){output$value <-renderTable(filter(data_final,smoking=="nicht-raucher"))}
    else if (k=="Alle Männer"){output$value <-renderTable(filter(data_final,gender=="männlich"))}
    else if (k=="Alle Frauen"){output$value <-renderTable(filter(data_final,gender=="weiblich"))}
    else if (k=="Alle Frauen Raucher"){output$value <-renderTable(filter(data_final,gender=="weiblich"&smoking=="raucher"))}
    else if (k=="Alle Männer Raucher"){output$value <-renderTable(filter(data_final,gender=="männlich"&smoking=="raucher"))}
    else{output$value <-renderTable()}
  })
  
  
  
    
  #####################################################################################
  #1.Altersgruppen mit Tumour size dichotom
  tab_01 <-  xtabs(~tumor_size_dichotom+altersgruppe  ,data=data_final)                                                                                    
  tab_01
  #1.1 Fisher Test ausgewählt ,mehrere Werte kleiner als 5 ,die Voraussetzung des CHISQ Tests nicht erfüllt :
  #Nullhypothese : Alter & Tumorgröße unabhängig
  #Alternative Hypothese : Alter & Tumorgröße sind abhängig
  fisher.test(data_final$tumor_size_dichotom , data_final$altersgruppe)
  #2.Rauchen vs Tumorsize_dichotom:
  tab_02 <-  xtabs(~smoking + tumor_size_dichotom ,data=data_final)                                                                                    
  tab_02
  e <-epi.2by2(tab_02,conf.level = 0.90)
  e$massoc.detail$OR.strata.score
  #OR=0.46
  #3.tumor_size_dichotom vs chol_dichotom
  #Homgenitätstest : 80% von der Kreuztabellwerten sind kleiner als 5 ,die Voraussetzung ist erfüllt :
  #Nullhypothese:p(T1,niedrig)=p(T1,normal)=p(T1,hoch)
  #Alernative Hypothese :p(i,j)!=p(i,j) ,für mind. ein(i,j) ,i:{T1,T2} ,j:{niedrig ,normal ,hoch}
  tab_03 <-  xtabs(~tumor_size_dichotom+ chol_dichotom ,data=data_final)                                                                                    
  tab_03
  n <- sum(tab_03)
  expected <- outer(rowSums(tab_03),colSums(tab_03))/n
  expected
  library(data.table)
  expected<-as.data.table(expected)
  chisq.test(data_final$tumor_size_dichotom,data_final$chol_dichotom)
  #4. BMI_dichotom  vs chol_dichotom (unverständliches Ergebnis)
  tab_04 <-  xtabs(~BMI_dichotom + chol_dichotom ,data=data_final)                                                                                    
  tab_04
  

  #generate the plot output 
  
    x_var<- eventReactive(input$goButton, {
      input$var1
    })
    y_var <- eventReactive(input$goButton,{
      input$var2
    })
    output$plot1 <- renderPlot({
      x <- x_var()
      y <- y_var()
      coloring <- switch(input$color,
                     gender = data_final$gender,
                     smoking = data_final$smoking,
                     None = FALSE)
     ggplot(data=data_final) +
      geom_point(aes_string(x =x, y =y,colour="coloring")) +
      labs(title = "Scatterplot",
           x = x,y = y)+geom_smooth(aes_string(x = x, y = y),se = FALSE)
    })
    output$plotLabeling <-renderText({
      x <- x_var()
      y <- y_var()
      paste0("Das Scatterplot zeigt uns, ob es eine Koerrilation zwsichen ",x," und ",y  ," gibt ,Färbung nach: ",input$color)}) 
  
  output$plot2 <- renderPlot({
    coloring <- switch(input$dist,
                       gender = data_final$gender,
                       smoking = data_final$smoking,
                       None = FALSE)
      ggplot(data = data_final, aes_string(x=input$dist, y= "tumour_size", fill = input$dist)) +
      geom_boxplot()+
      labs(title = "Boxplot",
           x = "Geschlecht",
           
           y = "Tumorgröße")
  })
  
  output$plotLabeling1 <-renderText({
    lab <- input$dist
    print(lab)
    if(lab=="gender"){paste0("Der Boxplot zeigt uns die Verteilung der Werte von Tumorgrößen zwischen männlichen und weiblichen Patienten")}
    if(lab=="smoking"){paste0("Der Boxplot zeigt uns die Verteilung der Werte von Tumorgrößen zwischen Rauchern und Nichtrauchern Patienten")}
    else{paste0("Der Boxplot zeigt uns die Verteilung der Werte von Tumorgrößen zwischen männlichen und weiblichen Patienten")}
    })
  output$plot4 <- renderPlot({
      ggplot(data = data_final,aes_string(x = "altersgruppe" ,fill=input$befuellen)) +
      geom_bar( ) +
      labs(title = "Säulendiagram",
           x = "Altersgruppen",
           y = "Count")+
      geom_text(aes(label=scales::percent(..count../sum(..count..))),
                stat='count',size = 3, hjust = 0.5, vjust = 0.5, position ="stack")
  }) 
  
  
  
  output$tab_01 <- renderTable(as.data.frame.matrix(tab_01), striped=TRUE, bordered = TRUE,rownames = TRUE)
  output$tab_02 <- renderTable(as.data.frame.matrix(tab_02), striped=TRUE, bordered = TRUE,rownames = TRUE)
  output$tab_03 <- renderTable(as.data.frame.matrix(tab_03), striped=TRUE, bordered = TRUE,rownames = TRUE)
  output$expected <- renderTable(as.data.frame.matrix(expected), striped=TRUE, bordered = TRUE,rownames = TRUE)
  f<-fisher.test(data_final$tumor_size_dichotom , data_final$altersgruppe)
  homogen <-chisq.test(data_final$tumor_size_dichotom,data_final$chol_dichotom)
  observeEvent(input$but_01, {
    insertUI(
      selector = "#but_01",
      where = "afterEnd",
      ui =   fluidPage(
        
        titlePanel("Unabhängigkeitstest"),
        tags$div(
          hr(),
          HTML(paste0('<p>
         Der Chi quadrad Test kann nicht angewendet werden , um die Abhängigkeit zu untersuchen .weil die 
         mehr als 20% aller Zellen der Tabelle sind kleiner als 5. Deswegen sollte Exakter fisher Test durchgeführt werden
         </p>',"<br><br><br><span style=\"padding-left:120px\"><span style=\"font-size:18pt\">",f$method,
                      "</span><br> <br>H<sub>0</sub> : Alter und Tumorgrößen sind voneinander unabhägig"
                      ,"<br> <br>H<sub>1</sub> : Alter und Tumorgrößen sind voneinander abhägig","<br> <br>  Variablnamen : ",f$data.name ,"<br> <br> P Wert =",
                      f$p.value," < 0.05 . <br> Interpretation : Die Nullhypothese kann abgelehnet werden . Der Zusammenhan zwischen Alter und Tumorgrößen ist nachweisbar"))
        )
        
        )
    )
  })
  observeEvent(input$but_02, {
    insertUI(
      selector = "#but_02",
      where = "afterEnd",
      ui =   fluidPage(
        
        titlePanel("Der Vergleich der Tumorgrößen zwischen Rauchen und Nicht-Rauchen"),
        tags$div(
          hr(),
          HTML(paste0("<p>
         Mit dem Odds Ratio können wir die Chance an größeren Tumoren bei Rauchen zu erkranken ist höher als
         als bei den Nicht-Rauchern .<br>
         Risiko Beurteilung : <br>
         ODDS Ratio beträgt ",e$massoc.detail$OR.strata.score$est ,"<br>
                      Interpretation : Das Risiko bei Raucheren an großen Tumoren zu erkranken ist um 54 % höher als 
                      bei den Nicht-Raucheren .<br> 1 &isin; KI : [",e$massoc.detail$OR.strata.score$lower,",",e$massoc.detail$OR.strata.score$upper,"] <br> Interpretation :
                      Ein signifikanter Unterschied zwischen Gruppen hinsichtlich der Chancen nicht nachgewiesen werden kann ."))
        )
        
      )
    )
  })
  observeEvent(input$but_03, {
    insertUI(
      selector = "#but_03",
      where = "afterEnd",
      ui =   fluidPage(
        
        titlePanel("Der Homogenitätstest"),
        tags$div(
          hr(),
          HTML(paste0("<p>
         Der Chi quadrad Test kann dazu angewendet werden , da alle erwartete Häufigkeiten gößer als 1 .",br(),"H<sub>0</sub> : P(hoch,T1)=P(normal,T1)=P(hoch,T1) <br>
                    , P(niedrig,T2)=P(normal,T2)=P(hoch,T2) "
                      ,"<br> <br>H<sub>1</sub> : P(i,j) &ne;  P(i,j) ,für mindestens ein(i,j) wobei i &isin;{hoch,mittel,niedrig},j &isin;	{T1,T2} </p> <br> 
                         P Wert =",homogen$p.value,"> 0.05 .",br(),"H<sub>0</sub> kann nicht abgelehnet werden .Es spricht nichts gegene die Gleichheit der Tumorgrößen in allen Cholesteringruppen ."))
        )
        
      )
    )
  })
    
}
shinyApp(ui=FirstApp,server = server)
