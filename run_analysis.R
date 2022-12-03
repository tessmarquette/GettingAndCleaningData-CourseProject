## Getting and Cleaning Data - Course Project
## Author: Tess Woods
## Date: December 2, 2022

## Assumptions:
## 1. I have already downloaded the project data and stored it locally
## 2. I have already installed and loaded the 'data.table' and 'reshape2' packages

## set filepath
filepath <- setwd("~/Documents/R Programming/Getting and Cleaning Data/Course Project")
## print(filepath)

## load activities and features data into data tables
activities <-fread(file.path(filepath, "UCI HAR Dataset/activity_labels.txt"), col.names = c("activityID", "activityname"))
## head(activities)
features <-fread(file.path(filepath, "UCI HAR Dataset/features.txt"), col.names = c("featureID", "featurename"))
## head(features)

## grepping out the features that contain the text mean or std
vipfeatures <- grep("(mean|std)\\(\\)", features[, featurename]) 
## FYI Apparently using the optional value=TRUE argument messes with the measurements vector??? So don't do it
## head(vipfeatures)

## create the character vectore 'measurements' and use gsub to remove the "()" - resulting in measurementsclean
measurements <- features[vipfeatures, featurename]
measurementsclean <-gsub('[()]', '', measurements)
## head(measurementsclean)

## load the 'train' data sets
traindata <- fread(file.path(filepath, "UCI HAR Dataset/train/X_train.txt")) [, vipfeatures, with = FALSE]
## head(traindata)
data.table::setnames(traindata, colnames(traindata), measurementsclean)
## head(traindata)
trainactivities <- fread(file.path(filepath, "UCI HAR Dataset/train/y_train.txt"), col.names = c("activitytype"))
## head(trainingactivities)
trainsubjects <- fread(file.path(filepath, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("subjectID"))
## head(trainsubjects)

## use cbind to combine the data frames for traindata, trainactivities, and trainsubjects
traindata <- cbind(trainsubjects, trainactivities, traindata)
## head(traindata)

#load the 'test' data sets
testdata <- fread(file.path(filepath, "UCI HAR Dataset/test/X_test.txt")) [, vipfeatures, with = FALSE]
## head(testdata)
data.table::setnames(testdata, colnames(testdata), measurementsclean)
## head(testdata)
testactivities <-fread(file.path(filepath, "UCI HAR Dataset/test/y_test.txt"), col.names = c("activitytype"))
## head(testactivities)
testsubjects <-fread(file.path(filepath, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("subjectID"))
## head(testsubjects)

## use cbind to combine the data frames for testdata, testactivities, and testsubjects
testdata <- cbind(testsubjects, testactivities, testdata)
## head(testdata)

## use rbdind to merge the data sets for traindata and testdata
combineddata <-rbind(traindata, testdata)
## head(combineddata)

## So now we need to add the activity labels to our data
combineddata[["activitytype"]] <- factor(combineddata [, activitytype], levels = activities[["activityID"]], labels = activities[["activityname"]])
## head(combineddata)
## makes subjectID a factor rather than a number
combineddata[["subjectID"]] <- as.factor(combineddata[, subjectID])
## head(combineddata)

## reshape the data from wide format to long format 
combineddata <- reshape2::melt(data = combineddata, id = c("subjectID", "activitytype"))
## takes the average of each variable for each activity for each subject
combineddata <- reshape2::dcast(data = combineddata, subjectID + activitytype ~ variable, fun.aggregate = mean)
## head(combineddata)

## create new files with our tidy data in it
## txt because that's what the assignment requires
## csv because it's way easier to tell if you did it correctly
data.table::fwrite(x = combineddata, file = "courseproject_tidydata.csv", quote = FALSE)
data.table::fwrite(x = combineddata, file = "courseproject_tidydata.txt", quote = FALSE)


## Sucess!!!
## What makes this dataset tidy?
## 1. Each variable is in its own column
## 2. Each observation (or in the case the mean of several observations) is in its own row
## 3. Only one value is stored in each cell
## 4. Data labels accurately describe the data contained in their column
