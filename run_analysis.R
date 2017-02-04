#This is like run_instrucions.but mre complete 
##Set the working directory and check you are in the right place
setwd("./C3_Week4/")
getwd()

##install and load dplyr and reshape2 packages
install.packages("dplyr")
library(dplyr)

install.packages("reshape2")
library(reshape2)


##check if directory exist, otherwise Create it

if (!file.exists("PROJECT")){
dir.create("PROJECT")
}
##Download, unlink and and unzip the dataset. 
##At the end a directory is created with 2 subdirectories (test and train)
URLfile <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(URLfile, destfile="file.zip", method="curl")
  
unlink("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")

unzip(filename)


## upload the files from the "train" directory 
## the first contains a column with a number associated to each subject that ##  participated to the experiment. The second contains a column indicating the activity. The third contains the measures.  

SubjectTrain<-tbl_df(read.table("UCI HAR Dataset/train/subject_train.txt"))
Ytrain <-tbl_df(read.table("UCI HAR Dataset/train/Y_train.txt"))
Xtrain <-tbl_df(read.table("UCI HAR Dataset/train/X_train.txt"))

## Bind the columns of the  files 
trainSet<-cbind(SubjectTrain,Ytrain,Xtrain)

##Repeat the previous two steps  for the  "test" directory
SubjectTest<-tbl_df(read.table("UCI HAR Dataset/test/subject_test.txt"))
Ytest<-tbl_df(read.table("UCI HAR Dataset/test/Y_test.txt"))
Xtest <-tbl_df(read.table("UCI HAR Dataset/test/X_test.txt"))

testSet<-cbind(SubjectTest,Ytest,Xtest)

##Bind the rows of the two files
mergedFiles<-rbind(trainSet,testSet)


## Read in "features.txt" file
  
features <- read.table("UCI HAR Dataset/features.txt")
dim(features)
head(features)

## collect the names of the features from the second column of the file 
featuresNames<-as.character(features[,2])

## improve the names of the columns 
featuresNames <-gsub('[-()]', "",featuresNames)
featuresNames <-gsub('[,]', "_",featuresNames)
featuresNames <-gsub('mean', "Mean",featuresNames)
featuresNames <-gsub('std', "Std",featuresNames)

## change name of the columns in mergedFiles
colnames(mergedFiles) <- c("Subject", "Activity", featuresNames)

## Extract only the  first two columns and the columns which have "Mean" and "Std" in their name

MeanStd_mergedFiles<- mergedFiles[ , grepl("Mean|.*Std.*|.*Activity.*|.*Subject.*" , names( mergedFiles ) ) ]


## Read in the activityLabels file 
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabelsNames<- as.character(activityLabels[,2])

## Use descriptive names from the activityLabels file for the activity column

MeanStd_mergedFiles$Activity <- factor(MeanStd_mergedFiles$Activity, levels     = activityLabels[,1], labels = activityLabels[,2])

## make sure that the Subjects colums will not be used as a "numbers"
MeanStd_mergedFiles$Subject <- factor(MeanStd_mergedFiles$Subject)

## transfor the files sorting for Subject and Activity and creating only 1 column of values.

meltMeanStd_mergedFiles <- melt(MeanStd_mergedFiles, id = c("Subject", "Activity"))

## Apply dcast to file

tidy_data = dcast(meltMeanStd_mergedFiles, Subject + Activity ~ variable, mean)

## Save tidyfile. without specifying row.names and quote, the output is a file with an extra column indicating the row number

write.table(tidy_data, file = "tidy_data.txt", row.names = FALSE, quote = FALSE)

