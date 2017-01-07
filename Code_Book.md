Project Summary
---------------
#Getting and Cleaning Data Course Project - Code Book
Paweł Dębiec

The purpose of course project was demonstrating ability to collect and clean data sets. The goal was to preapare a tidy data set, according to instructions given, based on real case data obtained from UCI Machine Learning Repository: Human Activity Recognition Using Smartphones Data Set.

Source Data Set
---------------

The original data set represents the recordings of 30 subjects performing 6 selected activities of daily living while carrying waist-mounted smartphone with embedded inertial sensors. The detailed description of the dataset is available here: \[Source Dataset\] (<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>)

The observations within source data were originally partitioned into training and test data sets (70% observations forming a training dataset, and 30% forming test data set). For each observation it was provided:

-   A 561-feature vector (all numerics normalized to the range of -1:1)
-   An Identifier of the subject who carried out the activities
-   An Identifier of the Activity performed within observation
-   Set of triaxial inertial signals - (acceleration from the accelerometer, estimated body acceleration and angular velocity from the gyroscope)

We start with downloading and unziping the source data.

``` r
if(!file.exists(".\\data")) dir.create(".\\data")
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/GACDProjectData.zip")
unzip(zipfile=".\\data\\GACDProjectData.zip",exdir=".\\data")
```

The source data is stored in following files:

``` r
list.files(".\\data\\UCI HAR Dataset", recursive=TRUE)
```

    ##  [1] "activity_labels.txt"                         
    ##  [2] "features.txt"                                
    ##  [3] "features_info.txt"                           
    ##  [4] "README.txt"                                  
    ##  [5] "test/Inertial Signals/body_acc_x_test.txt"   
    ##  [6] "test/Inertial Signals/body_acc_y_test.txt"   
    ##  [7] "test/Inertial Signals/body_acc_z_test.txt"   
    ##  [8] "test/Inertial Signals/body_gyro_x_test.txt"  
    ##  [9] "test/Inertial Signals/body_gyro_y_test.txt"  
    ## [10] "test/Inertial Signals/body_gyro_z_test.txt"  
    ## [11] "test/Inertial Signals/total_acc_x_test.txt"  
    ## [12] "test/Inertial Signals/total_acc_y_test.txt"  
    ## [13] "test/Inertial Signals/total_acc_z_test.txt"  
    ## [14] "test/subject_test.txt"                       
    ## [15] "test/X_test.txt"                             
    ## [16] "test/y_test.txt"                             
    ## [17] "train/Inertial Signals/body_acc_x_train.txt" 
    ## [18] "train/Inertial Signals/body_acc_y_train.txt" 
    ## [19] "train/Inertial Signals/body_acc_z_train.txt" 
    ## [20] "train/Inertial Signals/body_gyro_x_train.txt"
    ## [21] "train/Inertial Signals/body_gyro_y_train.txt"
    ## [22] "train/Inertial Signals/body_gyro_z_train.txt"
    ## [23] "train/Inertial Signals/total_acc_x_train.txt"
    ## [24] "train/Inertial Signals/total_acc_y_train.txt"
    ## [25] "train/Inertial Signals/total_acc_z_train.txt"
    ## [26] "train/subject_train.txt"                     
    ## [27] "train/X_train.txt"                           
    ## [28] "train/y_train.txt"

As we will not use data from Inertial Signals folders, only the followign files will be loaded:

-   "activity\_labels.txt" - resolves the activities codes into decriptive names
-   "features.txt" - provides names of 561 numeric features
-   "test/subject\_test.txt" - identifier of subject performing activities within test set - one column, 2947 observations
-   "test/X\_test.txt" - set of 561 numeric features for test set - 2947 observations.
-   "test/y\_test.txt" - code of activity performed within test set- one column, 2947 observations.
-   "train/subject\_train.txt" - identifier of subject performing activities within training set - one column, 7352 observations
-   "train/X\_train.txt" - set of 561 numeric features for training set - 7352 observations.
-   "train/y\_train.txt" - code of activity performed within training set- one column, 7352 observations.

Actions Performed
-----------------

We proceed with loading above files. For x datasets we apply column names based on list from features file, we also name the columns for subject and activity codes in rest of datasets.

``` r
features <- read.delim(".\\data\\UCI HAR Dataset\\features.txt", sep=" ", header=FALSE, col.names=c("order", "feature"))

activity_labels <- read.delim(".\\data\\UCI HAR Dataset\\activity_labels.txt", sep=" ", header=FALSE, col.names=c("activityCode", "activity"))

x_train <- read.fwf(file=".\\data\\UCI HAR Dataset\\train\\X_train.txt", widths= rep(16,561), header=FALSE)
names(x_train) <- features[,2]

x_test <- read.fwf(file=".\\data\\UCI HAR Dataset\\test\\X_test.txt", widths= rep(16,561), header=FALSE)
names(x_test) <- features[,2]

y_train <- read.delim(".\\data\\UCI HAR Dataset\\train\\y_train.txt", sep=";", header=FALSE, col.names=c("activityCode"))

y_test <- read.delim(".\\data\\UCI HAR Dataset\\test\\y_test.txt", sep=";", header=FALSE, col.names=c("activityCode"))

subject_train <- read.delim(".\\data\\UCI HAR Dataset\\train\\subject_train.txt", sep=";", header=FALSE, col.names=c("subject"))

subject_test <- read.delim(".\\data\\UCI HAR Dataset\\test\\subject_test.txt", sep=";", header=FALSE, col.names=c("subject"))
```

Having everything loaded we bind the columns of training dataset together and do the same with test dataset

``` r
train <- cbind(subject_train, x_train, y_train)
test <- cbind(subject_test, x_test, y_test)
```

Then we stack the train and test datasets together as requested (Point1)

``` r
full <-rbind(train, test)
```

As it was requrested to only select measurements on the mean and standard deviation (point2), we build a logical vector indicating which measures contain mean() or std() in their names.

``` r
stdOrMean <- grepl("([mM]ean\\(\\))|([sS]td\\(\\))", features[,2])
```

And we create a dataset with only selected measures + *activityCode* and *subject* attributes

``` r
selected <- full[, c(TRUE, stdOrMean, TRUE)]
```

Then we join descriptive activity labels (point3). (I decided to keep the activity codes as well)

``` r
readyDataSet4 <- merge(x=selected, y=activity_labels, by = "activityCode", all.x = TRUE)
```

Additionally, just to indicate the column doesn't reflect numeric value but a categor, we turn subjects into factors

``` r
readyDataSet4$subject <- as.factor(readyDataSet4$subject)
```

As we took care of the varaible names just after loading file and used the descriptive variable names as specified in features\_Info of the original dataset we consider point 4 satisfied

``` r
names(readyDataSet4)
 [1] "activityCode"                "subject"                     "tBodyAcc-mean()-X"          
 [4] "tBodyAcc-mean()-Y"           "tBodyAcc-mean()-Z"           "tBodyAcc-std()-X"           
 [7] "tBodyAcc-std()-Y"            "tBodyAcc-std()-Z"            "tGravityAcc-mean()-X"       
[10] "tGravityAcc-mean()-Y"        "tGravityAcc-mean()-Z"        "tGravityAcc-std()-X"        
[13] "tGravityAcc-std()-Y"         "tGravityAcc-std()-Z"         "tBodyAccJerk-mean()-X"      
[16] "tBodyAccJerk-mean()-Y"       "tBodyAccJerk-mean()-Z"       "tBodyAccJerk-std()-X"       
[19] "tBodyAccJerk-std()-Y"        "tBodyAccJerk-std()-Z"        "tBodyGyro-mean()-X"         
[22] "tBodyGyro-mean()-Y"          "tBodyGyro-mean()-Z"          "tBodyGyro-std()-X"          
[25] "tBodyGyro-std()-Y"           "tBodyGyro-std()-Z"           "tBodyGyroJerk-mean()-X"     
[28] "tBodyGyroJerk-mean()-Y"      "tBodyGyroJerk-mean()-Z"      "tBodyGyroJerk-std()-X"      
[31] "tBodyGyroJerk-std()-Y"       "tBodyGyroJerk-std()-Z"       "tBodyAccMag-mean()"         
[34] "tBodyAccMag-std()"           "tGravityAccMag-mean()"       "tGravityAccMag-std()"       
[37] "tBodyAccJerkMag-mean()"      "tBodyAccJerkMag-std()"       "tBodyGyroMag-mean()"        
[40] "tBodyGyroMag-std()"          "tBodyGyroJerkMag-mean()"     "tBodyGyroJerkMag-std()"     
[43] "fBodyAcc-mean()-X"           "fBodyAcc-mean()-Y"           "fBodyAcc-mean()-Z"          
[46] "fBodyAcc-std()-X"            "fBodyAcc-std()-Y"            "fBodyAcc-std()-Z"           
[49] "fBodyAccJerk-mean()-X"       "fBodyAccJerk-mean()-Y"       "fBodyAccJerk-mean()-Z"      
[52] "fBodyAccJerk-std()-X"        "fBodyAccJerk-std()-Y"        "fBodyAccJerk-std()-Z"       
[55] "fBodyGyro-mean()-X"          "fBodyGyro-mean()-Y"          "fBodyGyro-mean()-Z"         
[58] "fBodyGyro-std()-X"           "fBodyGyro-std()-Y"           "fBodyGyro-std()-Z"          
[61] "fBodyAccMag-mean()"          "fBodyAccMag-std()"           "fBodyBodyAccJerkMag-mean()" 
[64] "fBodyBodyAccJerkMag-std()"   "fBodyBodyGyroMag-mean()"     "fBodyBodyGyroMag-std()"     
[67] "fBodyBodyGyroJerkMag-mean()" "fBodyBodyGyroJerkMag-std()"  "activity"  
```

As the last step (point5) we group the dataset by subject and activity (+ activity code as we left it) and we calculate mean over all measures, creating a separate dataset

``` r
groupedMeans <- readyDataSet4 %>% group_by(subject, activityCode, activity) %>% summarize_each(funs(mean))
```

We save results to a data.frame and reload the column names as some characters were replaced with dots which in this case we don't like:

``` r
means <- data.frame(groupedMeans)
names(means) <- names(groupedMeans)
```

Such a dataset gets extracted to the *means.txt* file. It has 180 observations of 69 variables. Below is the command with which you can load it to R for review (please note that this reading function will replace *(*, *)* and *-* in the column names with dots as those are usually not wanted in names )

``` r
data <- read.delim("means.txt", sep=" ", header=TRUE)
```

The End :)
