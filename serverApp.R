#Version 1.0

function(input, output){
  theData <- reactive(iris %>% filter(Species == input$species))
  
  #generat the table output
  output$table <- renderTable(head(theData()))
  
  output$plot <- renderPlot({
    theData() %>% 
      ggplot(aes(x=Sepal.Length, y=Sepal.Width))+
      geom_point()+
      theme_bw()+
      labs(x="Irirs Sepal Length",
           y="Iris Sepal Width")
    })
  
}