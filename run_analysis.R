
# create variables for file locations and names
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest.dir <- "data"
dest.filename <- "HCI_HAR_Dataset.zip"
dest.file <- paste(dest.dir, dest.filename, sep="/")
unzipped.dir <- "UCI HAR Dataset"
X.train.file <- paste(
    dest.dir, unzipped.dir, "train", "X_train.txt", sep="/")
y.train.file <- paste(
    dest.dir, unzipped.dir, "train", "y_train.txt", sep="/")
subject.train.file <- paste(
    dest.dir, unzipped.dir, "train", "subject_train.txt", sep="/")
X.test.file <- paste(
    dest.dir, unzipped.dir, "test", "X_test.txt", sep="/")
y.test.file <- paste(
    dest.dir, unzipped.dir, "test", "y_test.txt", sep="/")
subject.test.file <- paste(
    dest.dir, unzipped.dir, "test", "subject_test.txt", sep="/")
activities.file <- paste(
    dest.dir, unzipped.dir, "activity_labels.txt", sep="/")
features.file <- paste(
    dest.dir, unzipped.dir, "features.txt", sep="/")
averages.file <- "subject.activity.variable.means.txt"

# download and unzip file
if (!file.exists(dest.dir)) dir.create(dest.dir)
if (!file.exists(dest.file)) download.file(
    url=url, destfile = dest.file,
    method="curl")
if (!file.exists(unzipped.dir)) unzip(dest.file, exdir = dest.dir)

# 1. read activities and feature names meta-data
activities <- read.table(
    file = activities.file, col.names = c("activityid", "activityname"))
features <- read.table(file = features.file)

# 2.  use regular expression to decide column indices and names
colIndices <- which(regexpr("-mean\\(\\)|-std\\(\\)", features$V2) != -1)
colNames <- tolower(
    sub("BodyBody", "Body",
        gsub("-","",
             sub("\\(\\)","",
                 features[colIndices,"V2"]))))

rm(features)

dataset.levels <- c("train", "test")

# 3. load train datasets (measures, activity ids and subject ids)
X.train.full <- read.table(file = X.train.file)
X.train <- X.train.full[,colIndices]
names(X.train) <- colNames
y.train <- read.table(file = y.train.file, col.names = "activityid")
subject.train <- read.table(file = subject.train.file, col.names="subject")

# 4. combine train datasets using cbind
train.cmb <- cbind(
    subject.train, y.train, X.train, factor("train", levels = dataset.levels))
names(train.cmb) <- c(
    names(subject.train), names(y.train), names(X.train), "dataset")
rm(X.train.full, X.train, y.train, subject.train)

# 5. load test datasets (measures, activity ids and subject ids)
X.test.full <- read.table(file = X.test.file)
X.test <- X.test.full[,colIndices]
names(X.test) <- colNames
y.test <- read.table(file = y.test.file, col.names = "activityid")
subject.test <- read.table(file = subject.test.file, col.names="subject")

# 6. combine test datasets using cbind
test.cmb <- cbind(
    subject.test, y.test, X.test, factor("test", levels = dataset.levels))
names(test.cmb) <- c(
    names(subject.test), names(y.test), names(X.test), "dataset")
rm(X.test.full, X.test, y.test, subject.test)

# 7. combine test and training datasets and then merge in the activity name
#    using activityid as key
all.data <- rbind(train.cmb, test.cmb)
all.data <- merge(all.data, activities, by = "activityid")
rm(test.cmb, train.cmb, activities)

library(reshape2)
# 8. reshape the data with the 66 measures melted into two columns: variable
#    and value
data.melted <- melt(
    all.data, variable.name = "variable", measure.vars = 3:68, id.vars=c(2,70))
rm(all.data)

# 9. grouping by subject and activityname, create final dataset of the means
#    of each mean and std measure
subject.activity.means <- dcast(
    data.melted, subject + activityname ~ variable, mean)
melted.means <- melt(
    subject.activity.means, variable.name = "variable",
    value.name = "mean",
    measure.vars = 3:68, id.vars = 1:2)
write.table(melted.means, file = averages.file, row.name=FALSE)
