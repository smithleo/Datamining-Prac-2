## Random Forest for aim(ii)
# load dataset which include remain or leave factor, this dataset will be used for classcifacation random forest
brexitData <- read.csv("data/remainORleave.csv", header = T)
head(brexitData)
table(brexitData$LeaveRemain)
breixtdata <- na.omit(brexitData)

# load dataset which use numbers to expresee remain or leave meaning, and this data will be used for regression random forest
beData <- read.csv("data/Final Downloaded Data.csv", header = T)
head(beData)

# load libraries
library(plyr)
library(randomForest)
library(dplyr)
source("Scripts/RFFunction.R")

## Create the forest
set.seed(100)
# Trying without validation ----------------------------------------------------
#ON ALL DATA
#Fit the Random Forest
original.rf = randomForest(factor(LeaveRemain)~ Voting.1+Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+Voting.7+Voting.8,data = breixtdata)
##View the forest results
print(original.rf)
round(importance(original.rf),2)
plot(original.rf)

## set train and test dataset
train.rows <- sample(1:nrow(breixtdata), 0.7*nrow(breixtdata))
train <- breixtdata[train.rows,]
test <- breixtdata[-train.rows,]

##### try to find good mtry and ntree number
# try to find the good mtry number
findgoodmtry(train[,6:13], train[,3],4,100,test)
# when the mtry number is 2, the OOB error is minimum 0.128812

# try to find the good ntree number
# via plot of random forest model to find the error minimum
findmodel.rf = randomForest(factor(LeaveRemain)~ Voting.1+Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+Voting.7+Voting.8,mtry = 2,data = breixtdata, ntree = 1000)
plot(findmodel.rf)
# when the ntree around 350 - 650,the OOB error is steable, to find a accuracy number of tree
findgoodntree(train[,6:13], train[,3],350,650,50,2,train)
# when the ntree range around 400 - 550, the accuracy is better. use the step of tree number is 20 to find better tree number
findgoodntree(train[,6:13], train[,3],400,550,20,2,train)

findgoodntree(train[,6:13], train[,3],440,540,10,2,train)
# when tree number is 480, the OOB error and accuracy are good.
# when the mtry = 2 and ntree = 480, the model is:
modeltwo.rf <- randomForest(factor(LeaveRemain)~ Voting.1+Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+Voting.7+Voting.8,mtry = 2,data = breixtdata, ntree = 480)
print(modeltwo.rf)
round(importance(modeltwo.rf),2)
plot(modeltwo.rf)
# when the random forest only use the voting data to predict, the best accuracy of random forest to predict the remain or leave of each Member of parliament is 83.72%. 

####### use party, percentage of remain/leave and voting data as X to predict Y(Reamin or leave) to build random forest

# Load dataset 
remainorleaveData <- read.csv("data/remainORleave-RF.csv", header = T)
head(remainorleaveData)
table(remainorleaveData$LeaveRemain)
remainorleavedata <- na.omit(remainorleaveData)

# Create model of randon forest
original.rf <- randomForest(factor(LeaveRemain)~ Party+Constituency+Voting.1+Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+Voting.7+Voting.8,data = remainorleavedata, ntree = 1000)
print(original.rf)
## from the model and plot, could know that the accuracy and OOB error are much better than only use voting data
## the OOB error = 2.67%, the accuracy = 98.33%

## View the forest results
print(original.rf)
round(importance(original.rf),2)
plot(original.rf)
## from the Gini could know that the constituency is very important for the model performance

## set train and test dataset
trainrf.rows <- sample(1:nrow(remainorleavedata), 0.7*nrow(remainorleavedata))
trainrf <- remainorleavedata[train.rows,]
testrf <- remainorleavedata[-train.rows,]

# try to find the good mtry number
findgoodmtry(trainrf[,4:13], trainrf[,1],7,100,test)
# when the mtry number is 2, the OOB error is minimum 0.02624136

# via plot of random forest model to find the error minimum
findmodelrf.rf = randomForest(factor(LeaveRemain)~ Party+Constituency+Voting.1+Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+Voting.7+Voting.8,mtry = 2,data = remainorleavedata, ntree = 1000)
plot(findmodelrf.rf)

# when mtry = 2, search the better tree number for model
findgoodntree(trainrf[,4:13], trainrf[,1],400,650,50,2,trainrf)
# when ntree = 500, the OOB error is small. search the accuracy number from 450 - 550
findgoodntree(trainrf[,4:13], trainrf[,1],450,550,10,2,trainrf)
# when ntree = 480 mtry = 2, the OOB error is better than others 

# create a new model by the ntree = 480 mtry = 2
modelthree.rf = randomForest(factor(LeaveRemain)~ Party+Constituency+Voting.1+
                               Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+
                               Voting.7+Voting.8,mtry = 2,data = 
                               breixtdata, ntree = 480)
print(modelthree.rf)
## the OOB = 2.84%, the accuracy = 97.16%, the misclass rate = 2.84%

## Build the confusion matrix for modelthree.lr by test dataset
prediction3 <- predict(modelthree.rf, test)
actuals3 <- test$LeaveRemain
CMtable3 <- table(actuals3, prediction3)
print(CMtable3)
# Accuracy and Misclass rate
accuracy.lr <- sum(diag(CMtable3))/sum(CMtable3)
misclass.lr <- 1-sum(diag(CMtable3))/sum(CMtable3)
print(accuracy.lr) # Accuracy = 97.34%
print(misclass.lr) # Misclass rate = 2.66%


########################################################################
### create model for percentage prediction, regression random forest ###
originalreg.rf = randomForest(Constituency~ Party+Voting.1+Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+Voting.7+Voting.8,
                            mtry = 2,data = breixtdata, ntree = 1000)
print(originalreg.rf)
plot(originalreg.rf)

tuneRF(trainrf[,c(1, 6:13)], trainrf[,5])
### Try to find out the best mtry value
findgoodmtryreg(trainrf[,c(1, 6:13)], trainrf[,5],7,123,testrf)
### when mtry = 3, the MSE is minimum

## creat the new model, mtry = 3 and try to find the best ntree
modelreg.lr <- randomForest(Constituency~ Party+Voting.1+Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+Voting.7+Voting.8,
                            mtry = 3,data = breixtdata, ntree = 1100)
print(modelreg.lr)
plot(modelreg.lr)
## from the plot, we could know when ntree around 800 - 1000 is stable.
findgoodntreereg(trainrf[,c(1, 6:13)], trainrf[,5],800,1200,50,3,testrf)
## when ntree = 950, mtry = 3, the MSE is minimum

## creat the best model of random forest for regression
modeltworeg.lr <- randomForest(Constituency~ Party+Voting.1+Voting.2+Voting.3+Voting.4+Voting.5+Voting.6+Voting.7+Voting.8,
                            mtry = 3,data = breixtdata, ntree = 950)
print(modeltworeg.lr)
plot(modeltworeg.lr)



prediction.rf <- predict(modeltworeg.lr, breixtdata)
actuals.lr <- breixtdata[,5]
result.lr <- list( 'actual' = actuals.lr, 'prediction' = prediction.rf)
tablevalue.lr <- data.frame(do.call(cbind,result.lr))

