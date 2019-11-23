# Set wd
setwd("D:/Year 2 Quarter 1/EPA1315 Data Analytics/Final Project/Modelling")

# Read the data in correctly
mydata_utf8 = read.table("WDIData.csv",sep=",",fileEncoding="UTF-8-BOM",header=TRUE)  
country_code = read.table("country_code.csv",sep=",",header=TRUE)

# drop off the final blank column
mydata = mydata_utf8[,1:63]

# find the right correlated variables
my_var_corr = c("NV.SRV.EMPL.KD","SL.AGR.EMPL.ZS","NV.AGR.EMPL.KD","NV.IND.EMPL.KD",
                "SL.SRV.EMPL.ZS","SL.IND.EMPL.ZS","EN.ATM.CO2E.PC")

# subset the data 
country_data = subset(mydata,mydata$Country.Code %in% country_code$Country.Code)
main_data = subset(country_data,country_data$Indicator.Code %in% my_var_corr)
# find the columns with the year we want
main_idx <- match(c("Country.Code","Indicator.Code","X2014"), names(mydata))
# peel off only the column we want from 2014
main_data <- main_data[,main_idx]

# Name the columns
names(main_data) <- c("Country","Indicator","Value")

#install.packages('reshape')
library('reshape')

# Reshaping
combined_melt = melt(main_data, id=c("Country","Indicator","Value"))
combined_cast = cast(combined_melt, value = "Value", Country  ~ Indicator)
final_data <- combined_cast

# remove NA data:
final_data = na.omit(final_data)

final_data$y <- log(final_data$EN.ATM.CO2E.PC)
final_data$x1 <- log(final_data$NV.AGR.EMPL.KD)
final_data$x2 <- log(final_data$NV.IND.EMPL.KD)
final_data$x3 <- log(final_data$NV.SRV.EMPL.KD)
final_data$x4 <- log(final_data$SL.AGR.EMPL.ZS)
final_data$x5 <- log(final_data$SL.IND.EMPL.ZS)
final_data$x6 <- log(final_data$SL.SRV.EMPL.ZS)
library(lattice)
splom(final_data[2:8])
splom(final_data[9:15])

