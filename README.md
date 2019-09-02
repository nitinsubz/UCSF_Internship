# UCSF Internship - Vaccine Response Analysis

During Summer '19, I was fortunate enough to intern as at *[UCSF's Butte Lab](http://buttelab.ucsf.edu)*. This repository contains all the relevant code from my research in the lab.


### The Data & Database
> The data we used came directly from *[ImmPort](https://immport.org)* Their database schema can be found [here](https://www.immport.org/shared/dataModel). At the time of research, their were a total of 370 studies in the database. 
>
> This was the criteria we used to evaluate relevant studies:
> - Studies centered around analyzing responses of different vaccines<br>
> - Studies that used only humans as subjects
>
> Here are some assumptions to keep in mind:
> - All Measurement Assays are listed no more than one time per study even if it was used multiple times
> - 'Smallpox' and 'Eczema Vaccinatum' are classified as separate diseases 
> - Studies that did not take a measurement after T<sub>0</sub> are categorized as 'Not Listed' under the outcomes file
> - 'Diabetes', 'Ebola', 'HIV',  'Newcastle', 'Palmoplantar Pustulosis', 'Pneumococcal', & 'Pneumovax' are listed as **'Other'** under disease type since each of them were present in fewer than 2 studies

### Analysis
> Under the analysis folder there are 7 visuals representing the data
> - corrplot_studies.pdf: Every study correlated with the measurement assays that were used. 
> - corrplot_studies_clustered.pdf: The same as above, except with clustering to identify the most prevalent assay types.
> - corrplot_studies_simplified.pdf: The top 12 most common Measurement Assays correlated with each study that uses them
> - corrplot_simplified_clustered.pdf: The same as above except with clustering.
> - study_diseases_117.pdf: A Bar chart identifying the amount studies analyzing each disease 
> - study_measurements.pdf: A Bar chart showing the amount of measurements taken per study

### Code & Variables
> arms (Data Frame) - Master Data Table
> - STUDY_ACCESSION 
> - ARM_ACCESSION
> - DESCRIPTION
> - MEASUREMENT_TECHNIQUE
> - ACTUAL_ENROLLMENT
> - DISEASE_TYPE
> - OUTCOME 

> diseases (Data Frame)
> - STUDY_ACCESSION
> - DISEASE_TYPE
>
> outcome (Data Frame)
> - STUDY_ACCESSION
> - OUTCOME
> 
> subjects (Data Frame)
> - *This was used to determine if the study used humans as their subjects*
> - SUBJCET_ACCESSION
> - SPECIES
> 
> study (Data Frame)
> - *This data frame was used to identify releavent studies by grepping for keywords*
>
> lab1 (Data Frame)
> - *This data frame contains all lab tests that were added as measurement assays to the master table*
> - STUDY_ACCESSION
> - MEASUREMENT_TECHNIQUE

### Queries
> - count(arms %>% select(STUDY_ACCESSION, MEASUREMENT_TECHNIQUE) %>% unique(), MEASUREMENT_TECHNIQUE)
>   - Returns the amount of times each measurement assay is used in the data


