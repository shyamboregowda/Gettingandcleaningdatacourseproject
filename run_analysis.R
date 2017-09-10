#Getting and Cleaning data to produce a Tidy Data Set.
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

#Dowland file from URL and Unzip
downloadfile <- function() {
    if (!file.exists("./data")) {
        dir.create("./data")
    }
    fileurl <-
        "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileurl, destfile = "./data/Dataset.zip", method = "curl")
    unzip(zipfile = "./data/Dataset.zip", exdir = "./data")
}