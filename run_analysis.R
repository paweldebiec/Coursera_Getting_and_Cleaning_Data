
library(dplyr)


#Download the source data and save it in data folder.
if(!file.exists(".\\data")) dir.create(".\\data")
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/GACDProjectData.zip")

# Unzip the package to data folder
unzip(zipfile=".\\data\\GACDProjectData.zip",exdir=".\\data")

list.files(".\\data\\UCI HAR Dataset", recursive=TRUE)



##Loading datasets
features <- read.delim(".\\data\\UCI HAR Dataset\\features.txt", sep=" ", header=FALSE, col.names=c("order", "feature"))

activity_labels <- read.delim(".\\data\\UCI HAR Dataset\\activity_labels.txt", sep=" ", header=FALSE, col.names=c("activityCode", "activity"))

x_train <- read.fwf(file=".\\data\\UCI HAR Dataset\\train\\X_train.txt", widths= rep(16,561), header=FALSE)
#applying column names based on features file
names(x_train) <- features[,2]

x_test <- read.fwf(file=".\\data\\UCI HAR Dataset\\test\\X_test.txt", widths= rep(16,561), header=FALSE)
#applying column names based on features file
names(x_test) <- features[,2]

y_train <- read.delim(".\\data\\UCI HAR Dataset\\train\\y_train.txt", sep=";", header=FALSE, col.names=c("activityCode"))

y_test <- read.delim(".\\data\\UCI HAR Dataset\\test\\y_test.txt", sep=";", header=FALSE, col.names=c("activityCode"))

subject_train <- read.delim(".\\data\\UCI HAR Dataset\\train\\subject_train.txt", sep=";", header=FALSE, col.names=c("subject"))

subject_test <- read.delim(".\\data\\UCI HAR Dataset\\test\\subject_test.txt", sep=";", header=FALSE, col.names=c("subject"))

#binding train dataset
train <- cbind(subject_train, x_train, y_train)

#binding test dataset
test <- cbind(subject_test, x_test, y_test)

#stacking train and test together
full <-rbind(train, test)

#selecting indexes of mean() or std() measures
stdOrMean <- grepl("([mM]ean\\(\\))|([sS]td\\(\\))", features[,2])

#Creating a new dataset with only mean and STD features + activityCode + subject
selected <- full[, c(TRUE, stdOrMean, TRUE)]

#joining descriptive activity labels
readyDataSet4 <- merge(x=selected, y=activity_labels, by = "activityCode", all.x = TRUE)

#turning subjects into factors - just to indicate the column doesn't reflect numeric value but a category (person)
readyDataSet4$subject <- as.factor(readyDataSet4$subject)

#calculating averages of each variables by each subject and activity
groupedMeans <- readyDataSet4 %>% group_by(subject, activityCode, activity) %>% summarize_each(funs(mean))

#storing result in data.frame
means <- data.frame(groupedMeans)
#fixing column names (special characters were replaced with dots by data.frame function, but we liked them and want them back)
names(means) <- names(groupedMeans)

#storing the mean dataset into the file.
write.table(means, "means.txt", row.names = FALSE, quote = FALSE)

