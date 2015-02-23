## A program to process
## Human Activity Recognition Using Smartphones Dataset

### Pedro Márquez
### February  2015
### Version 1.0

A series of experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (**WALKING**, **WALKING_UPSTAIRS**, **WALKING_DOWNSTAIRS**, **SITTING**, **STANDING**, **LAYING**) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 


The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See **features_info.txt** for more details. 


For each record it is provided:

* Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
* Triaxial Angular velocity from the gyroscope. 
* A 561-feature vector with time and frequency domain variables. 
* Its activity label. 
* An identifier of the subject who carried out the experiment.


The dataset includes the following files:

* **README.txt**: This file.

* **features_info.txt**: Shows information about the variables used on the feature vector.

* **features.txt**: List of all features.

* **activity_labels.txt**: Links the class labels with their activity name.

* **train/X_train.txt**: Training set.

* **train/Y_train.txt**: Training labels.

* **test/X_test.txt**: Test set.

* **test/Y_test.txt**: Test labels.


The following files are available for the train and test data. Their descriptions are equivalent. 

* **train/subject_train.txt**: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

* **train/Inertial_Signals/total_acc_x_train.txt**: The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

* **train/Inertial Signals/body_acc_x_train.txt**: The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

* **train/Inertial Signals/body_gyro_x_train.txt**: The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second.


This study has been reported in [1].

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012



Program Requirements
====================

The program should do basically the following:

1. Merge the __training__ and the __test__ sets to create one data set.
2. Extract only the measurements on the __mean__ and __standard deviation__ for each measurement.
3. Use descriptive activity names to name the activities in the data set
4. Appropriately label the data set with descriptive variable names.
5. From the data set in step 4, create a second, independent tidy data set with the _average_ of each variable for each activity and each subject.

Tables Returned
===============

The program basically creates two tables, although it also creates other ancillary
tables in the process. The two final tables created by the program have been named
`data_tbl` and `smy_tbl`. The first one contains all information from the _training_
and _test_ 
data sets, while the second one contains a summary of all "mean" and "standard deviation"
features averaged by subject and activity.

Program Code Explanation
========================
The following section explains the program code as it is in the run_analysis.R script,
except for the `dim()` instructions.

## Preamble
Load all R packages required
```r
library(data.table)
```

Phase 1:
-----------
 Read all data sets from corresponding data files into appropriate data tables.
 Data sets are stored in files kept in a folder structure as follows:
 
     <working folder>--+
                       +-- features.txt
                       +-- train +
                                 +--X_train.txt
                                 +--Y_train.txt
                                 +--subject_train.txt
                       +-- test  +                           
                                 +--X_test.txt
                                 +--Y_test.txt
                                 +--subject_test.txt

### Step 1.1
Load variables' names table (`features`), used in both `training`
 and `test` data sets. This feature table has two columns: `<feature no.>`, and
`<feature name>`.

```r
f_tbl <- read.table("features.txt")
```

### Step 1.2
Load `training` related data sets. Table names are self-explanatory.

```r
x_trn <- read.table("./train/X_train.txt")
y_trn <- read.table("./train/Y_train.txt")
s_trn <- read.table("./train/subject_train.txt")
```

### Step 1.3
Label `training` data sets variables with significative names.

```r
colnames(s_trn)[1] <- "Subject_ID"
colnames(y_trn)[1] <- "Activity_ID"
names(x_trn) <- t(f_tbl[2])    # transpose column vector of names to make it a row
```


### Step 1.4
Load `test` related data sets. Table names are self-explanatory.

```r
x_tst <- read.table("./test/X_test.txt")
y_tst <- read.table("./test/Y_test.txt")
s_tst <- read.table("./test/subject_test.txt")
```

### Step 1.5
Label `test` data sets variables with significative names.

```r
colnames(s_tst)[1] <- "Subject_ID"
colnames(y_tst)[1] <- "Activity_ID"
names(x_tst) <- t(f_tbl[2])    # transpose column vector of names to make it a row
```

### Step 1.6
Append row-wise, corresponding x, y and subject data sets
from `training` and `test` data sets. Table names are self-explanatory.

```r
xs_tbl <- rbind(x_tst,x_trn)
ys_tbl <- rbind(y_tst,y_trn)
ss_tbl <- rbind(s_tst,s_trn)
```

### Step 1.7
Merge  by columns the three previous  tables so as to get one big data table 
with all the information from all subjects, activities and features.

```r
data_tbl <- cbind(ss_tbl,ys_tbl,xs_tbl)
```

### Step 1.8. End of Phase 1
Load `activity` table, which has columns `<activity No.>` and ` <activity name>`,
 and change `data_tbl` activity coding numbers to significative names.
 **data_tbl** is the first data table looked for.
 
```r
act_tbl <- read.table("activity_labels.txt")    # columns of table are <number> and <name>
for(i in 1:length(data_tbl[,2])) {    # column 2 of 'data_tbl' is "Activity_ID"
    data_tbl[i,2] <- as.character(act_tbl[data_tbl[i,2],2])    # change activity number to activity name
}
```

Let's check the dimensions out of this table, just to verify we have all valid data.
Note that the number of observations corresponds to the sum of the number of
observations in the `trainig` data set + the number of observations in the `test`
data set. Also, the number of columns corresponds to the sum of the  number
of features + one column for the subjects and one column for the activities.

```r
dim(data_tbl)
```

Phase 2:
-----------
Get a summarized tidy data set containing the average of all and only
 `-mean()` and `-std()` features for each subject and each activity.

### Step 2.1
Extract from total data table `data_tbl` all variables corresponding to all and only 
 `mean` and `standard deviation` features, for all subjects and activities. We name
 this table `sub_tbl`.
 
 
```r
sub_tbl <- cbind(data_tbl[,1:2],    # columns 1 and 2 of 'data_tbl' are "Subject_ID" and "Activity_ID"
                  subset(data_tbl,select=grep("-mean()",names(data_tbl),    # "mean" features
                                             fixed=TRUE)),
                  subset(data_tbl,select=grep("-std()",names(data_tbl),    # "standard deviation" features
                                             fixed=TRUE))
                  )
```

### Step 2.2
Create an empty data table containing only the variable names of all
selected features in the `sub_tbl` created in the previous step, 
 to enable gradual appending of value rows in the summary table `smy_tbl`
 being constructed.
 Note: `smy_tbl` stands for "summary table".
 
```r
smy_tbl <- as.data.table(setNames(replicate(length(names(sub_tbl)),
                                            numeric(0),
                                            simplify = FALSE),
                                  names(sub_tbl)
                                  )
                         )
```

### Step 2.3
Final step. Fill in the summary table `smy_tbl` as follows:

     For each `subject` and each `activity`:
         extract the corresponding subtable,
         create an auxiliary table with the average of each feature, and
         append this auxiliary table to the end of the summary table

Note: The follwing table shows the meaning of each variable used in the
       the next code fragment.
       
       
 | name | meaning                         |
 |------|:------------------------------- |
 | sbj  |"subject"                        |
 | act  | "activity"                      |
 | ssa  | "subset subject-activity"       |
 | som  | "summary of means (_averages_)" |


```r
for (sbj in 1:30){
    for (act in act_tbl[,2]){    # column 2 of 'act_tbl' has the activity names
        # subset table by 'subject' and 'activity'
        ssa <- subset(sub_tbl,Subject_ID==sbj & Activity_ID==act)
        # create auxiliary table with the average value of each feature
        som <- data.table(Subject_ID=sbj, Activity_ID=act,
                          matrix(apply(ssa[-c(1:2)], 2, mean),
                                 ncol=length(names(sub_tbl))-2
                                 )
                          )
        # set significant variable names to 'som' table just created
        setnames(som,names(sub_tbl))
        # append 'som' table to the end of the summary table 'smy_tbl'
        smy_tbl <- rbind(smy_tbl,som,use.names=TRUE)
    }
}
```

## End of Phase 2
**`smy_tbl`** is the final data table looked for.

Finally, we could check the dimensions out of this table, just to verify we have all valid data.
Note that the  number of rows corresponds to number of subjects times the number of 
activities, i.e. 30*6=180, while the numbers of columns corresponds to the sum
of the number of features having `-mean()` and `-std()` in their names.

```r
dim(smy_tbl)
```

