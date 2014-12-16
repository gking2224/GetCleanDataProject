
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

# download and unzip file
if (!file.exists(dest.dir)) dir.create(dest.dir)
if (!file.exists(dest.file)) download.file(
    url=url, destfile = dest.file,
    method="curl")
if (!file.exists(unzipped.dir)) unzip(dest.file, exdir = dest.dir)

# read activities
activities <- read.table(
    file = activities.file, col.names = c("activityid", "activityname"))
# read feature names
features <- read.table(file = features.file)
cols <- which(regexpr("-mean\\(\\)|-std\\(\\)", features$V2) != -1)
colNames <- tolower(gsub("-","",sub("\\(\\)","",features[cols,"V2"])))
rm(features)

dataset.levels <- c("train", "test")

# load train dataset
X.train.full <- read.table(file = X.train.file)
X.train <- X.train.full[,cols]
names(X.train) <- colNames
y.train <- read.table(file = y.train.file, col.names = "activityid")
subject.train <- read.table(file = subject.train.file, col.names="subject")

# combine train files
train.full <- cbind(
    subject.train, y.train, X.train, factor("train", levels = dataset.levels))
names(train.full) <- c(
    names(subject.train), names(y.train), names(X.train), "dataset")
rm(X.train.full, X.train, y.train, subject.train)

# load test dataset
X.test.full <- read.table(file = X.test.file)
X.test <- X.test.full[,cols]
names(X.test) <- colNames
y.test <- read.table(file = y.test.file, col.names = "activityid")
subject.test <- read.table(file = subject.test.file, col.names="subject")

# combine test files
test.full <- cbind(
    subject.test, y.test, X.test, factor("test", levels = dataset.levels))
names(test.full) <- c(
    names(subject.test), names(y.test), names(X.test), "dataset")
rm(X.test.full, X.test, y.test, subject.test)

all.data <- rbind(train.full, test.full)
all.data <- merge(all.data, activities, by = "activityid")
rm(test.full, train.full, activities)

library(reshape2)
data.melted <- melt(
    all.data, variable.name = "variable", measure.vars = 3:68, id.vars=c(2,70))
rm(all.data)

subject.activity.means <- dcast(data.melted, subject + activityname ~ variable, mean)
write.table(subject.activity.means, file="subject.activity.means.txt", row.name=FALSE)
