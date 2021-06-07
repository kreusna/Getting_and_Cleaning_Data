

# Load Packages
library(data.table)
library(dplyr)
library(tidyr)
path <- getwd()

#Download dateset and unzip
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(url, file.path(path, "dataFiles.zip"))
#unzip(zipfile = "dataFiles.zip")

# Load activity labels + features
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))

#Select needed columns
seletedFeatures <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[seletedFeatures, featureNames]
measurements <- gsub('[()]', '', measurements)

# Load train datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, seletedFeatures, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
#Load Train Activities 
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/y_train.txt")
                         , col.names = c("Activity"))
#Load Train Subject
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
#Bind subject and activities to train
train <- cbind(trainSubjects, trainActivities, train)

# Load test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, seletedFeatures, with = FALSE]
data.table::setnames(test, colnames(test), measurements)

#Load test activities
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/y_test.txt")
                        , col.names = c("Activity"))
#Load test subjects
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
#Bind test subject and activities to test
test <- cbind(testSubjects, testActivities, test)

# merge datasets
mergedData <- rbind(train, test)

# Convert classLabels to activityName basically
mergedData[["Activity"]] <- factor(mergedData[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])
mergedData[["SubjectNum"]] <- as.factor(mergedData[, SubjectNum])


#Calculate mean by group SubjectNum and Activity column
mergedData <- mergedData %>% group_by(SubjectNum,Activity) %>% summarise_each(funs(mean))

print(head(mergedData))

#Write tidy data to file
data.table::fwrite(x = mergedData, file = "tidyData.txt", quote = FALSE)