library(ggplot2)

#ScatterPlot = bmi vs tumor_size

Sctplt<-ggplot(data = cancer_data.csv) +
  geom_point(mapping = aes(x = bmi, y = tumor_size, color = gender)) +
  labs(title = "Scatterplot",
       x = "BMI",
       y = "Tumorgröße")


#Boxplot = gender vs tumor_size

Boxplt<-ggplot(data = cancer_data.csv, aes(x=geschlecht, y= tumor_size,)) +
  geom_boxplot()+
  labs(title = "Boxplot",
       x = "Geschlecht",
       y = "Tumorgröße")


#Barplot = agegroup vs chol

barbplt<-ggplot(data = cancer_data.csv) +
  geom_bar(mapping = aes(x = agegroup ,y= chol)) +
  labs(title = "Säulendiagram",
       x = "Altersgruppen",
       y = "Cholesterine")
