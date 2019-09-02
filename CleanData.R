library(dplyr)
library(tidyr)
library(tidyverse)
library(ggplot2)

study <- read.delim('ALLSTUDIES-DR30_Metadata/study.txt')
data <- read.delim('ALLSTUDIES-DR30_Metadata/experiment.txt')
subjects <- read.delim('ALLSTUDIES-DR30_Metadata/subject.txt')
biosample <- read.delim('ALLSTUDIES-DR30_Metadata/biosample.txt')

#Filter for vaccines only in all of the data (147 of 370 Studies)
study <- study %>% filter(str_detect(BRIEF_TITLE, 'vacc|Vacc') |
                            str_detect(BRIEF_DESCRIPTION, 'vacc|Vacc') | 
                            str_detect(CONDITION_STUDIED, 'vacc|Vacc') | 
                            str_detect(DESCRIPTION, 'vacc|Vacc') | 
                            str_detect(HYPOTHESIS, 'vacc|Vacc') | 
                            str_detect(ENDPOINTS, 'vacc|Vacc')| 
                            str_detect(INTERVENTION_AGENT, 'vacc|Vacc')| 
                            str_detect(OBJECTIVES, 'vacc|Vacc') | 
                            str_detect(OFFICIAL_TITLE, 'vacc|Vacc'))


biosample <- biosample %>% select(BIOSAMPLE_ACCESSION, STUDY_ACCESSION, SUBJECT_ACCESSION)

#Filter for humans only in the data
subjects <- subjects %>% filter(SPECIES == 'Homo sapiens')
subjects <- subjects %>% select(SUBJECT_ACCESSION,SPECIES)
biosample <- biosample %>% filter(biosample$SUBJECT_ACCESSION %in% subjects$SUBJECT_ACCESSION)
study <- study %>% filter(study$STUDY_ACCESSION %in% biosample$STUDY_ACCESSION)

#### UP TO HERE 129 ROWS IN STUDY

# ALL HUMANS, ALL VACCINES

data <- data %>% select(STUDY_ACCESSION, MEASUREMENT_TECHNIQUE)

#delete duplicate rows
data <- unique(data)

data <- data %>% filter(data$STUDY_ACCESSION %in% study$STUDY_ACCESSION)


study <- study %>% select(-WORKSPACE_ID, -TARGET_ENROLLMENT, -SPONSORING_ORGANIZATION, 
                          -MINIMUM_AGE, -MAXIMUM_AGE, -ACTUAL_COMPLETION_DATE, 
                          -ACTUAL_START_DATE, -AGE_UNIT, -CLINICAL_TRIAL, 
                          -DCL_ID, -DOI, -GENDER_INCLUDED, -INITIAL_DATA_RELEASE_DATE, 
                          -INITIAL_DATA_RELEASE_VERSION, -INTERVENTION_AGENT, 
                          -LATEST_DATA_RELEASE_DATE, -LATEST_DATA_RELEASE_VERSION)


arms <- read.delim('ALLSTUDIES-DR30_Metadata/arm_or_cohort.txt', stringsAsFactors = FALSE)


arms <- arms %>% filter(arms$STUDY_ACCESSION %in% study$STUDY_ACCESSION)
arms <- arms  %>% select(STUDY_ACCESSION, ARM_ACCESSION, NAME, DESCRIPTION)
arms <- arms %>% rename(DISEASE_TYPE = NAME)




lab1 = read.delim("ALLSTUDIES-DR30_Metadata/lab_test_panel.txt")

lab1 <- lab1 %>% select(STUDY_ACCESSION, NAME_REPORTED)
lab1 <- lab1 %>% filter(lab1$STUDY_ACCESSION %in% study$STUDY_ACCESSION)
# 
# 
# arms <- full_join(arms, lab1, by="STUDY_ACCESSION")
# 
# arms$MEASUREMENT <- paste(arms$MEASUREMENT_TECHNIQUE, arms$NAME_REPORTED, sep=" ")

lab1 <- lab1 %>% rename(MEASUREMENT_TECHNIQUE = NAME_REPORTED)


data <- rbind(data, lab1)
arms <- full_join(arms, data, by="STUDY_ACCESSION")


arms <- full_join(arms, study%>%select(STUDY_ACCESSION, ACTUAL_ENROLLMENT), by = "STUDY_ACCESSION")


arms <- arms %>%  filter(STUDY_ACCESSION != "SDY14")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY3")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY131")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY597")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY194")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY720")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY282")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY746")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY26")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY23")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY22")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY26")
arms <- arms %>%  filter(STUDY_ACCESSION != "SDY4")


data <- data %>% filter(data$STUDY_ACCESSION%in%arms$STUDY_ACCESSION)
study <- study %>% filter(study$STUDY_ACCESSION%in%arms$STUDY_ACCESSION)

##Merge Diseases From Spreadsheet!
diseases <- study %>% select(STUDY_ACCESSION)
diseases <- diseases %>% mutate('DISEASE_TYPE' ='')

diseases<- read.csv(file='data/diseases.csv',header = TRUE, sep=',')
diseases <- diseases %>% filter(diseases$STUDY_ACCESSION %in% arms$STUDY_ACCESSION)

arms <- arms  %>% select(-DISEASE_TYPE)
arms <- full_join(arms, diseases, by ="STUDY_ACCESSION") %>%
  as.data.frame(stringsAsFactors = FALSE)

unique_table <- arms %>% select(STUDY_ACCESSION,DISEASE_TYPE) %>% unique()
unique_table <- unique_table$DISEASE_TYPE %>% table() %>% sort()

temp <- (arms%>%filter(DISEASE_TYPE  %in% c( 'Diabetes', 'Ebola', 'HIV',  'Newcastle','Palmoplantar Pustulosis','Pneumococcal','Pneumovax' ))) 
temp$DISEASE_TYPE <- "Other"

arms <- arms%>%filter(!(DISEASE_TYPE  %in% c( 'Diabetes', 'Ebola', 'HIV',  'Newcastle','Palmoplantar Pustulosis','Pneumococcal','Pneumovax')))
arms <- rbind(arms, temp)

temp2 <- (diseases%>%filter(DISEASE_TYPE  %in% c('Diabetes', 'Ebola', 'HIV',  'Newcastle','Palmoplantar Pustulosis','Pneumococcal','Pneumovax' ))) 
temp2$DISEASE_TYPE <- "Other"

diseases <- diseases %>% filter(!(DISEASE_TYPE  %in% c('Diabetes', 'Ebola', 'HIV',  'Newcastle','Palmoplantar Pustulosis','Pneumococcal','Pneumovax')))
diseases <- rbind(diseases, temp2)


pie(table(arms$DISEASE_TYPE))
pie(table((arms%>%filter(DISEASE_TYPE != 'Influenza'))$DISEASE_TYPE))
tab <- data.frame(table(arms$DISEASE_TYPE))



## Corr Plots of Data
library(corrplot)

wide <- data %>% mutate(USED=1)

long <- wide %>% unique() %>% spread(MEASUREMENT_TECHNIQUE, USED, fill = 0)
long <- long %>% remove_rownames %>% column_to_rownames(var="STUDY_ACCESSION")
long <- t(long)

pdf("Analysis/corrplot_studies.pdf", width = 30, height = 20)
corrplot(as.matrix(long), method="circle",is.corr = F, tl.col = "black")
dev.off()


rclust = hclust(d = dist(long))
cclust = hclust(d = dist(t(long)))
long2 = long[rclust$order,cclust$order]
pdf("Analysis/corrplot_studies_clustered.pdf", width = 30, height = 20)
corrplot(as.matrix(long2), method="circle",is.corr = F,tl.col = "black")
dev.off()


##Simplifying to only top Assay types

simplified <- wide %>% unique() %>% spread(MEASUREMENT_TECHNIQUE, USED, fill = 0)
simplified <- simplified %>% filter(rowSums(simplified %>% select(`Flow Cytometry`, `Hemagglutination Inhibition`, ELISA, `DNA microarray`, `Transcription profiling by array`, ELISPOT, `Virus Neutralization`, `Immunology Test`, `Luminex xMAP`, Sequencing, `Q-PCR`, CyTOF, `HLA Typing`))!=0)
simplified <- simplified %>% select(STUDY_ACCESSION, `Flow Cytometry`, `Hemagglutination Inhibition`, ELISA, `DNA microarray`, `Transcription profiling by array`, ELISPOT, `Virus Neutralization`, `Immunology Test`, `Luminex xMAP`, Sequencing, `Q-PCR`, CyTOF, `HLA Typing`)
simplified <- simplified %>% remove_rownames %>% column_to_rownames(var="STUDY_ACCESSION")
simplified <- t(simplified)
pdf("Analysis/corrplot_studies_simplified.pdf", width = 35, height = 10)
corrplot(as.matrix(simplified), method="circle",is.corr = F, tl.col = "black")
dev.off()

#with clustering
rclust2 = hclust(d = dist(simplified))
cclust2 = hclust(d = dist(t(simplified)))
simplified2 = simplified[rclust2$order,cclust2$order]
pdf("Analysis/corrplot_simplified_clustered.pdf", width = 35, height = 10)
corrplot(as.matrix(simplified2), method="circle",is.corr = F,tl.col = "black")
dev.off()


#OUTCOMES
outcome <- study %>% select(STUDY_ACCESSION)
outcome <- outcome %>% mutate('OUTCOME' ='')


outcome<- read.csv(file='data/outcomes.csv',header = TRUE, sep=',')
outcome <- outcome %>% filter(outcome$STUDY_ACCESSION %in% arms$STUDY_ACCESSION)
arms <- full_join(arms, outcome, by ="STUDY_ACCESSION")


library(ggplot2)

gp <- count(arms, STUDY_ACCESSION)
pdf("Analysis/study_measurements.pdf", width = 40, height = 20)
ggplot(gp,  aes(x=reorder(STUDY_ACCESSION, -n), y=n))+
  geom_bar(stat="identity", width=0.7, color = "blue", fill="cadetblue1")+
  theme(axis.text.x = element_text(angle=45, hjust = 1, size=15), panel.background = element_rect(fill='aliceblue',color = 'green'), axis.title.x = element_text(size = 30), axis.text.y = element_text(size = 20), axis.title.y = element_text(size = 30)) +
  labs(x = "Study Number", y = "Number of Measurements")
dev.off()

gd <- count(arms, DISEASE_TYPE)
pdf("Analysis/study_diseases.pdf", width = 40, height = 20)
ggplot(gd,  aes(x=reorder(DISEASE_TYPE, -n), y=n))+
  geom_bar(stat="identity", width=.9, color = "blue", fill="cadetblue1")+
  theme(panel.background = element_rect(fill='aliceblue',color = 'green'), axis.title.x = element_text(size = 30), axis.text.x = element_text(size = 20, angle = 45, hjust = 1), axis.text.y = element_text(size = 20), axis.title.y = element_text(size = 30))+
  labs(x = "Disease Type", y = "Number")
dev.off()

study_dis <- count(diseases, DISEASE_TYPE)
pdf("Analysis/study_diseases_117.pdf", width = 40, height = 20)
ggplot(study_dis,  aes(x=reorder(DISEASE_TYPE, -n), y=n))+
  geom_bar(stat="identity", width=.9, color = "blue", fill="cadetblue1")+
  theme(panel.background = element_rect(fill='aliceblue',color = 'green'), axis.title.x = element_text(size = 30), axis.text.x = element_text(size = 20, angle = 45, hjust = 1), axis.text.y = element_text(size = 20), axis.title.y = element_text(size = 30))+
  labs(x = "Disease Type", y = "Number")
dev.off()


allData <- arms

