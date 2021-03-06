
library(dplyr)
#library(plyr)
library(tidyr)
library(ggplot2)
library(epiR)
print("Hello World!")

# my name jeff

# hallo
rm(list=ls())
#Datenanpassung 

#1.read csv file 
initial_data <- read.csv("cancer_data.csv",sep=",",header = TRUE)
filter(initial_data,gender==0&smoking==1)
str(data_final)
#2.add new columns 

#2.1 add altersgrppe 
table(initial_data$age)                                              # see frequency table of age
summary(initial_data$age)   
# see the Characteristic values


data_01 <- initial_data%>%mutate(altersgruppe=case_when(     # add new column for age class based on Characteristic values 
  between(age,18,29) ~ "under 30 ",
  between(age,30,44) ~ "30-44",
  between(age,45,59) ~ "45-59 ",
  between(age,60,100) ~ "above 60"))



#2.2 add tumor_size_dichotom 
summary(initial_data$tumour_size)                             # see the Characteristic values
data_01 <- data_01%>%mutate(tumor_size_dichotom=case_when(                                          # add new column for tumor_size_dichotom based on Characteristic values 
 
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
data_final_m<-data_final%>%filter(gender=="männlich") %>% 
  complete(chol , fill = list(chol = chol_mean_maenlich[[1]]))


data_final_w<-data_final%>%filter(gender=="weiblich") %>%
  complete(chol , fill = list(chol = chol_mean_weiblich[[1]]))

#merge completed datframes
data_final<-rbind(data_final_m, data_final_w)

#2.6 add chol_dichotom 
#reference :https://www.praktischarzt.de/untersuchungen/blutuntersuchung/cholesterinwerte/
data_final <- data_final%>%mutate(chol_dichotom=case_when(               # add new column for tumor_size_dichotom based on Characteristic values 
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
homogen <-chisq.test(data_final$tumor_size_dichotom,data_final$chol_dichotom)
homogen$p.value
#check cleaned data 
View(data_final)
write.csv(data_final,"datensatz.csv", row.names = FALSE)
sss <- data_final[,  chol]
ss <- data_final[, c("chol"), drop = FALSE]
class(data_final["chol"])
class(as.col_spec(ss))

########################################################################################################################
#1. Scatterplot zwischen Bmi und Tumorgröße
Sctplt<-ggplot(data = data_final) +
  geom_point(mapping = aes(x = BMI, y = tumour_size, color = gender)) +
  labs(title = "Scatterplot",
       x = "BMI",
       y = "Tumorgröße")+geom_smooth(mapping = aes(x = BMI, y = tumour_size),se = FALSE)
Sctplt
class(data_final$chol)
cor(data_final$tumour_size,data_final$BMI)
#positive Koerrilation

#2.Boxplot um die Häufigkeit zu untersuchen
Boxplt<-ggplot(data = data_final, aes(x=gender, y= tumour_size, fill = gender)) +
  geom_boxplot()+
  labs(title = "Boxplot",
       x = "Geschlecht",
       
       y = "Tumorgröße")
Boxplt


Boxplt1<-ggplot(data = data_final, aes(x=smoking, y= tumour_size, fill = smoking)) +
  geom_boxplot()+
  labs(title = "Boxplot",
       x = "Rauchen Verhältnis",
       y = "Tumorgröße")
Boxplt1

#3.
#Auf Y Achse in Säulendiagram wichtig zu wissen ,wird nur die Häufigkeit der 
#Gruppen dargestellt .
#Säulendiagramm, eingeteilt in Altersgruppen
barbplt<-ggplot(data = data_final,aes(x = altersgruppe ,fill=tumor_size_dichotom)) +
  geom_bar( ) +
  labs(title = "Säulendiagram",
       x = "Altersgruppen",
       y = "Count")+
  geom_text(aes(label=scales::percent(..count../sum(..count..))),
            stat='count',size = 3, hjust = 0.5, vjust = 0.5, position ="stack")
barbplt
#####################################################################################
#1.Altersgruppen mit Tumour size dichotom
tab_01 <-  xtabs(~tumor_size_dichotom+altersgruppe  ,data=data_final)                                                                                    
tab_01
#1.1 Fisher Test ausgewählt ,mehrere Werte kleiner als 5 ,die Voraussetzung des CHISQ Tests nicht erfüllt :
#Nullhypothese : Alter & Tumorgröße unabhängig
#Alternative Hypothese : Alter & Tumorgröße sind abhängig
f<-fisher.test(data_final$tumor_size_dichotom , data_final$altersgruppe)
fs <-toString(f)
fs
str(f)
html1 <- paste0('<p>
         The Chi quadrad Test kann nicht angewendet werden , um die Abhängigkeit zu untersuchen .weil die 
         mehr als 20% aller Zellen der Tabelle sind kleiner als 5. Deswegen sollte Exakter fisher Test durchgeführt werden
         </p>',"<br>")
class(html1)
#2.Rauchen vs Tumorsize_dichotom:
tab_02 <-  xtabs(~smoking + tumor_size_dichotom ,data=data_final)                                                                                    
tab_02
e <-epi.2by2(tab_02,conf.level = 0.90)
str(e$massoc.detail$OR.strata.score)
#OR=0.46
#3.tumor_size_dichotom vs chol_dichotom
#Homgenitätstest : 80% von der Kreuztabellwerten sind kleiner als 5 ,die Voraussetzung ist erfüllt :
#Nullhypothese:p(T1,niedrig)=p(T1,normal)=p(T1,hoch)
#Alernative Hypothese :p(i,j)!=p(i,j) ,für mind. ein(i,j) ,i:{T1,T2} ,j:{niedrig ,normal ,hoch}
tab_03 <-  xtabs(~tumor_size_dichotom+ chol_dichotom ,data=data_final)                                                                                    
tab_03
n <- sum(tab_03)
expected <- outer(rowSums(tab_03),colSums(tab_03))/n
library(data.table)
expected<-as.data.table(expected)
class(expected)
chisq.test(data_final$tumor_size_dichotom,data_final$chol_dichotom)
#4. BMI_dichotom  vs chol_dichotom (unverständliches Ergebnis)
tab_04 <-  xtabs(~BMI_dichotom + chol_dichotom ,data=data_final)                                                                                    
tab_04
summary(data_final$BMI)


