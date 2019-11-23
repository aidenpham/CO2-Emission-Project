# Read the data in correctly
mydata_utf8 = read.table("WDIData.csv",sep=",",fileEncoding="UTF-8-BOM",header=TRUE)  
country_code = read.table("country_code.csv",sep=",",header=TRUE)

# drop off the final blank column
mydata = mydata_utf8[,1:63]

# find the right variables
my_var = c("EN.ATM.CO2E.PC","BX.KLT.DINV.CD.WD","BX.TRF.PWKR.DT.GD.ZS",
           "DT.ODA.ODAT.CD","NE.EXP.GNFS.ZS","NV.AGR.EMPL.KD",
           "NV.IND.EMPL.KD","NV.IND.MANF.CD","NV.MNF.TECH.ZS.UN","NV.SRV.EMPL.KD",
           "NY.ADJ.SVNX.GN.ZS","SL.AGR.EMPL.ZS","SL.IND.EMPL.ZS",
           "SL.ISV.IFRM.ZS","SL.SRV.EMPL.ZS")

# subset the data 
country_data = subset(mydata,mydata$Country.Code %in% country_code$Country.Code)
main_data = subset(country_data,country_data$Indicator.Code %in% my_var)
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

final_data <- na.omit(final_data)

final_data$y <- log(final_data$EN.ATM.CO2E.PC)
final_data$x1 <- log(final_data$NV.AGR.EMPL.KD)
final_data$x2 <- log(final_data$NV.IND.EMPL.KD)
final_data$x3 <- log(final_data$NV.SRV.EMPL.KD)
final_data$x4 <- log(final_data$SL.AGR.EMPL.ZS)
final_data$x5 <- log(final_data$SL.IND.EMPL.ZS)
final_data$x6 <- log(final_data$SL.SRV.EMPL.ZS)

#install.packages("ggpubr")
library("ggpubr")

#install.packages('tidyverse')
library('tidyverse')

# Try plotting an indicator against CO2/capita:
ggscatter(final_data, x = "x2", y = "y", 
           add = "reg.line", conf.int = TRUE, 
           cor.coef = TRUE, cor.method = "kendall", color = "sky blue",
           cor.coef.coord = c(7,3), xlim=c(6.6,12.7),
           xlab = "Productivity in Industry (log scale)", ylab="CO2/capita (log scale)",
           main = "                 (Productivity in Industry) vs (CO2/capita)")

# Create a dataframe for the result of the analysis:
correlation_table=data.frame(matrix(ncol=3,nrow=15))
names(correlation_table) <- c("Indicator","p_value","Cor_coefficient")
correlation_table$Indicator <- my_var

# Run the correlation analysis:
i=1
for (indicator in my_var) {
  result <- cor.test(final_data1 %>% pull(indicator), final_data1 %>% pull(EN.ATM.CO2E.PC),  
                     use="pairwise.complete.obs",method="kendall")
  correlation_table[i,2] <-  result$p.value
  correlation_table[i,3] <-  result$estimate
  i=i+1
}

#install.packages("writexl")
library("writexl")
write_xlsx(correlation_table,"correlation_table_kendall.xlsx")
write_xlsx(final_data1,"final_data_excel.xlsx")

# To plot Q-Q plot and Density plot
library(ggpubr)
ggqqplot(log(combined_cast$EN.ATM.CO2E.PC), main="Q-Q plot of log(CO2/capita)", color = "royal blue")
ggdensity(log(combined_cast$EN.ATM.CO2E.PC), 
          main = "Density plot of log(CO2/capita)",
          xlab = "log(CO2/capita)")
# To test whether the CO2 data follows normal distribution:
shapiro.test(log(combined_cast$EN.ATM.CO2E.PC))