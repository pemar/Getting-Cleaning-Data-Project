## Author:  Pedro Marquez
## Date:    February 2015
## File:    run_analysis.R
## Version: 1.0
## 
## From data collected from the accelerometers of a Samsung Galaxy S smartphone
## the program obtains a tidy clean data set.

# load R packages required
library(data.table)

## PHASE 1:
# Read all data sets from corresponding data files into appropriate data tables.
# Data sets are stored in files kept in a folder structure as follows:
# <working folder>--+
#                   +-- features.txt
#                   +-- train +
#                             +--X_train.txt
#                             +--Y_train.txt
#                             +--subject_train.txt
#                   +-- test  +                           
#                             +--X_test.txt
#                             +--Y_test.txt
#                             +--subject_test.txt

# load variable name table ('features'), which is common to both 'training'
# and 'test' data sets. Features table has two columns: feature no., and
# feature name.
f_tbl <- read.table("features.txt")

# load 'training' related data sets
x_trn <- read.table("./train/X_train.txt")
y_trn <- read.table("./train/Y_train.txt")
s_trn <- read.table("./train/subject_train.txt")

# label 'training' data sets variables with significative names
colnames(s_trn)[1] <- "Subject_ID"
colnames(y_trn)[1] <- "Activity_ID"
names(x_trn) <- t(f_tbl[2]) # transpose of...

# load 'test' related data sets
x_tst <- read.table("./test/X_test.txt")
y_tst <- read.table("./test/Y_test.txt")
s_tst <- read.table("./test/subject_test.txt")

# label 'test' data sets variables with significative names
colnames(s_tst)[1] <- "Subject_ID"
colnames(y_tst)[1] <- "Activity_ID"
names(x_tst) <- t(f_tbl[2])

# merge by rows, corresponding x, y and subject data sets 
# from 'training' and 'test' data sets.
xs_tbl <- rbind(x_tst,x_trn)
ys_tbl <- rbind(y_tst,y_trn)
ss_tbl <- rbind(s_tst,s_trn)

# merge  by columns previous three tables to get one data table with all the
# information for all subjects, activities and features.
data_tbl <- cbind(ss_tbl,ys_tbl,xs_tbl)

## END OF PHASE 1
# load 'activity' table, which contains pairs <activity No.>-<activity name>,
# in order to change from the previous data table its activity coding numbers 
# to their corresponding more significative names.
# 'data_tbl' is the first data table looked for.
act_tbl <- read.table("activity_labels.txt")
for(i in 1:length(data_tbl[,1])) {
    data_tbl[i,2] <- as.character(act_tbl[data_tbl[i,2],2])
}

## PHASE 2: Getting a summarized tidy data set containing the average of just
## '-mean()' and '-std()' features for each subject and each activity.
# extract from total data table all variables corresponding to all and only 
# 'mean' and 'standard deviation' features, for all subjects and activities.
sub_tbl <- cbind(data_tbl[,1:2],
                  subset(data_tbl,select=grep("-mean()",names(data_tbl),
                                             fixed=TRUE)),
                  subset(data_tbl,select=grep("-std()",names(data_tbl),
                                             fixed=TRUE))
                  )

# create an empty data table containing only the variable names of all
# selected features in the 'tidy_tbl' created in the previous step, in order
# to enable gradual adding of rows in the summary table being constructed.
# Note: 'smy_tbl' stands for "summary table"
smy_tbl <- as.data.table(setNames(replicate(length(names(sub_tbl)),
                                            numeric(0),
                                            simplify = FALSE),
                                  names(sub_tbl)
                                  )
                         )

# Final step. Fill in summary table 'smy_tbl' as follows:
# For each 'subject' and each 'activity':
#     extract the corresponding subtable,
#     create an auxiliary table with the average of each feature, and
#     append this auxiliary table to the summary table
# Note: The follwing table shows the meaning of each variable used in the
#       the next code fragment
#  name | meaning
# ------+------------
#  sbj  |"subject"
#  act  | "activity"
#  ssa  | "subset subject-activity"
#  som  | "summary of means"
for (sbj in 1:30){
    for (act in act_tbl[,2]){
        # extract data by 'subject' and 'activity'
        ssa <- subset(sub_tbl,Subject_ID==sbj & Activity_ID==act)
        # create table with average of each feature
        som <- data.table(Subject_ID=sbj, Activity_ID=act,
                          matrix(apply(ssa[-c(1:2)], 2, mean),
                                 ncol=length(names(sub_tbl))-2
                                 )
                          )
        # set variable names to 'som' table
        setnames(som,names(sub_tbl))
        # append 'som' table to summary table 'smy_tbl'
        smy_tbl <- rbind(smy_tbl,som,use.names=TRUE)
    }
}
## END: 'smy_tbl' is the data table looked for.
