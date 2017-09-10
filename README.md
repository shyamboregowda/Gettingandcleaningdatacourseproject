### Getting and Cleaning Data Course Project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.

### Introduction
One of the most exciting areas in all of data science right now is wearable computing - 
see for example [this article](http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/). Companies like Fitbit, Nike, and Jawbone Up are racing to 
develop the most advanced algorithms to attract new users. The data linked to from the 
course website represent data collected from the accelerometers from the Samsung Galaxy S 
smartphone. 

A full description is available at the site where the data was obtained:
[Human Activity Recognition Using Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

Here are the data for the project:
[UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

### Assignment Function: `run_analysis`

The goal of the script is to prepare tidy data that can be used for later analysis. 

The function, `run_analysis` performs the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

<!-- -->
    run_analysis <- function() {
    rm(list = ls())
    downloadfile()
    filepath <- file.path("./data" , "UCI HAR Dataset")
    
    #Read Files
    features <-
        read.table(file.path(filepath, 'features.txt'), header = FALSE)
    activitylabels = read.table(file.path(filepath, 'activity_labels.txt'), header = FALSE)
    traininglabels <-
        read.table(file.path(filepath, "train/y_train.txt"), header = FALSE)
    testlabels  <-
        read.table(file.path(filepath, "test/y_test.txt"), header = FALSE)
    testfeature  <-
        read.table(file.path(filepath, "test/X_test.txt"), header = FALSE)
    trainingfeature <-
        read.table(file.path(filepath, "train/X_train.txt"), header = FALSE)
    trainingsubject <-
        read.table(file.path(filepath, "train/subject_train.txt"), header = FALSE)
    testsubject  <-
        read.table(file.path(filepath, "test/subject_test.txt"), header = FALSE)
    
    #Merges the training and the test sets to create one data set.
    completefeautres <-  rbind(testfeature, trainingfeature)
    completelabels <- rbind(testlabels, traininglabels)
    completesubjects <- rbind(testsubject, trainingsubject)
    
    completedata <-
        cbind(completelabels, completesubjects, completefeautres)
    

    names(completedata) <- c( "activityid","subject", as.character(features[, 2]) )
    
    #Extract only the measurements on the mean and standard deviation for each measurement. 
    mean_sd_columns<-features$V2[grep("mean\\(\\)|std\\(\\)", features[,2])]
    cloumnnames<-c( "activityid","subject", as.character(mean_sd_columns) )
    completedata<-subset(completedata,select=cloumnnames)
    library(plyr)
    library(dplyr)
    #Use descriptive activity names to name the activities in the data set
    completedata <- completedata %>%  mutate(activity = activitylabels[activityid, 2])
   
    #Appropriately labels the data set with descriptive variable names.
    names(completedata)<-gsub("^t", "time", names(completedata))
    names(completedata)<-gsub("^f", "frequency", names(completedata))
    names(completedata)<-gsub("Acc", "accelerometer", names(completedata))
    names(completedata)<-gsub("Gyro", "gyroscope", names(completedata))
    names(completedata)<-gsub("Mag", "magnitude", names(completedata))
    names(completedata)<-gsub("BodyBody", "body", names(completedata))
    names(completedata)<-gsub("\\(|\\)", "", names(completedata))
    names(completedata)<-gsub("-", "", names(completedata))
    names(completedata) <- tolower(names(completedata))
    
    tidydata  <- ddply(completedata, .(subject, activityid, activity), function(x) colMeans(x[, 3:68]))
    
    #independent tidy data set with the average of each variable for each activity and each subject.
    write.table(tidydata, file.path(filepath,"tidydataset.txt"), row.name=FALSE)
    }



### Utility Function: `downloadfile`

The function, `downloadfile` downloads the zip file from given url and unzip the data set.

    downloadfile <- function() {
    if (!file.exists("./data")) {
        dir.create("./data")
    }
    fileurl <-
        "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileurl, destfile = "./data/Dataset.zip", method = "curl")
    unzip(zipfile = "./data/Dataset.zip", exdir = "./data")
    }
   
### Code Book
GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.

