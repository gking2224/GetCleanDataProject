README
======

Introduction
------------
This is the README guide of my Course Project submission for the [John Hopkins Bloomberg School of Public Health](https://www.coursera.org/jhu) course [Getting And Cleaning Data](https://www.coursera.org/course/getdata), hosted on [Coursera](https://www.coursera.org).

This file describes the function of the script `run_analysis.R`

The purpose of this script is to create a file (`subject.activity.variable.means.txt`) summarising the combined test and training datasets for all mean and standard deviation variables recorded by 30 subjects in the [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) project.

The source dataset consists of 561 different measurements recorded using the accelerometer and gyroscope of a Samsung Galaxy S II smartphone device strapped to the subject's waist. Multiple observations of the 561 variables output by the device were taken over a timeframe, during which the subject was taking part in one of six different activities (walking, walking upstairs, walking downstairs, sitting, standing, laying). Measurements were taken for 30 different subjects, who were randomly divided into two groups, split 70% and 30% between the training and test groups respectively.

As such, the measurement data consists of many thousands of observations that can be grouped by dataset (training/test), subject (1-30), activity (1-6), with between 36 and 95 observations of the 561 measurement (features) for each combination of these factors.

The file created contains the mean value of 66 of the total 561 measures, grouped by subject and activity.

Overview of source files used
-----------------------------
The full dataset was downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

This zip contained several files that were used to generate the sample file:

* UCI Har Dataset/activity_labels.txt  
  This file provides the activity names corresponding to the activity ids in the y_train.txt and y_test.txt files (1=WALKING, 3=WALKING_UPSTAIRS etc.)
* UCI Har Dataset/features.txt  
  This file describes what each of the variables of each observation found in files X_train.txt and X_test.txt correspond to (e.g. variable in column 1=tBodyAcc-mean()-X). Further detail on the meaning of each of these variables can be found in the file features_info.txt
* UCI Har Dataset/train/subject_train.txt  
  This file gives the subject id (1-30) for each of the observations in the training dataset. As such, it has dimensions of (7352,1)
* UCI Har Dataset/train/y_train.txt  
  This file contains the activity id (1-6) corresponding to each of the 7352 observations in X_train.txt. Dimensions of this file are also (7352,1)
* UCI Har Dataset/train/X_train.txt  
  This file contains 7352 observations of the training group of subjects, each observation consisting of a measure of the 561 variables described in features.txt. Dimensions of this file are (7352,561)
* UCI Har Dataset/test/subject_test.txt  
  This file gives the subject id (1-30) for each of the observations in the test dataset. As such, it has dimensions of (2947,1)
* UCI Har Dataset/test/y_test.txt  
  This file contains the activity id (1-6) corresponding to each of the 2947 observations in X_test.txt. Dimensions of this file are also (2947,1)
* UCI Har Dataset/test/X_test.txt  
  This file contains 2947 observations of the test group of subjects, each observation consisting of a measure of the 561 variables described in features.txt. Dimensions of this file are (2947,561)

Selection of mean() and std() measurements
------------------------------------------
The requirement for this assignment was to extract only the mean and standard deviation for each measurement. This left some ambiguity about exactly which of the 561 measurements to include. My approach was to select all the mean() and std() named measurements using a regular expression matching "-mean()" and "-std()".

This included 3 mean() and std() measures for all of the tri-axial variables (e.g. `tBodyAcc`, `fBodyAccJerk`); 1 each for all of the uni-axial variables (e.g. `tBodyAccMag`, `fBodyAccMag`); it also excluded variables such as `angle(tBodyAccMean,gravity)`, on the basis that although it is a mean of sorts, there is no corresponding standard deviation measurement for this variable.

As such, 66 columns in total were selected from the raw dataset, resulting from 5x 't' tri-axial variables, 5x 't' uni-axial variables, 3x 'f' tri-axial variables and 4x 'f' uni-axial variables.

The selected feature names were normalised in the dataset by removing any punctuation characters (i.e. brackets and hyphens) and converting to lower case. In this way, `tBodyAcc-mean()-X` becomes `tbodyaccmeanx`

Data processing steps
---------------------
The data processing steps taken are:

1. read activities and feature names meta-data  
_Activites data is used later to give a meaningful name to the activity ids (1-6)._
2. use regular expression to decide column indices and names  
_Regular expression `-mean\\(\\)|-std\\(\\)` applied to the features names results in column indices (`colIndices`) of the features (in the X\_train.txt and X\_test.txt datasets) that we are interested in. The names of these features are transformed as described above and stored in `colNames` variable_
3. load train datasets (measures, activity ids and subject ids)  
_The measures dataset is subset using `colIndices` variable, and named using `colNames` variable. Other datasets are given appropriate names_
4. combine train datasets using cbind  
_The three train datasets are combined and given appropriate names. An additional factor variable ('dataset') is added to all observations to identify this set as 'train' data. This is because it will be merged with 'test' data later, and it might be useful to differentiate between the two._
5. load test datasets (measures, activity ids and subject ids)  
_Repeat step 3 but for 'test' dataset_
6. combine test datasets using cbind  
_Repeat step 4 but for 'test' dataset. Additional 'dataset' variable is given value 'test'_
7. combine test and training datasets and then merge in the activity name  
_Use `rbind` to concatenate the two datasets. The dataset is enriched with the activity names loaded in step 1 with `merge` function, using 'activityid' column as a key._
8. reshape the data with the 66 measures melted into two columns: variable and value  
_Full dataset is now turned from short and wide into long and skinny using `melt` function.`
9. grouping by subject and activityname, create dataset of the means of each measure  
_`dcast` is used to create a short and wide dataset of measure means, grouped by activityname and subject. Finally, this data is then re-melted to a tall, skinny dataset before writing to a file, for no other reason that in makes writing the codebook a bit easier!_

These steps are correspondingly marked in the script file.

The resulting file ("subject.activity.variable.means.txt") can be read using this code:
```
read.table(averages.file, header=TRUE)
```