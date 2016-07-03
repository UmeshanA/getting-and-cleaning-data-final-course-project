## Downloading and unzipping the dataset:
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/Dataset.zip", method = "curl")

unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

## Setting up path reference to unzipped folder

path_reference <- file.path("./data", "UCI HAR Dataset")
files <- list.files(path_reference, recursive = TRUE)
files

## Reading data from the files into the variables
activityTestData <-  read.table(file.path(path_reference, "test", "Y_test.txt") , header = FALSE)
activityTrainData <- read.table(file.path(path_reference, "train", "Y_train.txt") , header = FALSE)
subjectTrainData <- read.table(file.path(path_reference, "train", "subject_train.txt") , header = FALSE)
subjectTestData <- read.table(file.path(path_reference, "test", "subject_test.txt") , header = FALSE)
featuresTestData <- read.table(file.path(path_reference, "test", "X_test.txt") , header = FALSE)
featuresTrainData <- read.table(file.path(path_reference, "train", "X_train.txt") , header = FALSE)

## Merging the training and test data sets
subjectData <- rbind(subjectTrainData, subjectTestData)
activityData <- rbind(activityTestData, activityTrainData)
featuresData <-  rbind(featuresTestData, featuresTrainData)

names(subjectData) <- c("subject")
names(activityData) <- c("activity")
dataFeaturesNames <- read.table(file.path(path_reference, "features.txt"), head = FALSE)
names(featuresData) <-  dataFeaturesNames$V2

mergeData <-  cbind(subjectData, activityData)
finalActivityData <-  cbind(featuresData, mergeData)

##Extracting measurements on mean and standard deviation
subdataFeaturesNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
namesSelected <- c(as.character(subdataFeaturesNames), "subject", "activity" )
finalActivityData <- subset(finalActivityData, select = namesSelected)

## Use of descriptive activity names to name the activities in the dataset

activityLabels <- read.table(file.path(path_reference, "activity_labels.txt"), header = FALSE)
finalActivityData$activity <- factor(finalActivityData$activity, levels = activityLabels[,1], labels = activityLabels[,2])

## Appropriate Labeling of data set with descriptive variable names, using the gsub function
## Replacing t with time
names(finalActivityData) <- gsub("^t", "time", names(finalActivityData))

## Replacing f with frequency
names(finalActivityData) <- gsub("^f", "Frequency", names(finalActivityData))

## Replacing Acc with Accelerometer
names(finalActivityData) <- gsub("Acc", "Accelerometer", names(finalActivityData))

## Replacing Gyro with Gyroscope
names(finalActivityData) <- gsub("Gyro", "Gyroscope", names(finalActivityData))

## Replacing Mag with Magnitude
names(finalActivityData) <- gsub("Mag", "Magnitude", names(finalActivityData))

## Replacing BodyBody with Body
names(finalActivityData) <- gsub("BodyBody", "Body", names(finalActivityData))


## Create a tidy data set and output as a separate txt file
library(plyr) ##using the plyr package

finalActivityData2 <- aggregate(.~subject +activity, finalActivityData, mean)
finalActivityData2 <- finalActivityData2[order(finalActivityData2$subject, finalActivityData2$activity), ]
write.table(finalActivityData2, file = "tidydata.txt", row.names = FALSE)
