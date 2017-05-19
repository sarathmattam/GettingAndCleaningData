# Loading required libraries
library(reshape2)

# Download the file 
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "./SmartPhoneDataset.zip")
 
# Unzip the file 
unzip("SmartPhoneDataset.zip") 

# Load Activity Labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Load Features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extracts mean and standard deviation variables 
featuresSubset <- grep(".*mean.*|.*std.*", features[,2])
featuresSubsetLabels <- features[featuresSubset,2]
# Apply gsub to replace -mean with Mean
featuresSubsetLabels <- gsub('-mean', 'Mean', featuresSubsetLabels)
# Apply gsub to replace -std with StandardDeviation
featuresSubsetLabels <- gsub('-std', 'Std', featuresSubsetLabels)
# Apply gsub to replace [-()] with null
featuresSubsetLabels <- gsub('[-()]', '', featuresSubsetLabels)


# Load the datasets
trainData <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresSubset]
trainLabels <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
# Joining data
trainCombined <- cbind(trainSubjects, trainLabels, trainData)

testData <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresSubset]
testLabels <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
# Joining data
testCombined <- cbind(testSubjects, testLabels, testData)

# Joining both train and test data
MergedData <- rbind(trainCombined, testCombined)
names(MergedData) <- c("Subjects", "Labels", featuresSubsetLabels)

# Setting factors
MergedData$Labels <- factor(MergedData$Labels, levels = activityLabels[,1], labels = activityLabels[,2])
MergedData$Subjects <- as.factor(MergedData$Subjects)
#mergin data to long format
MergedData.Melt <- melt(MergedData, id = c("Subjects", "Labels"), variable.name = "Measures")
MergedData.Mean <- dcast(MergedData.Melt, Subjects + Labels ~ Measures, mean)
#wrting to formtted data to tidy.txt
write.table(MergedData.Mean, "tidy.txt", row.names = FALSE, quote = FALSE)