# 1. MODEL
library(rjags)

y <- log(final_data$EN.ATM.CO2E.PC)
x1 <- log(final_data$NV.AGR.EMPL.KD)
x2 <- log(final_data$NV.IND.EMPL.KD)
x3 <- log(final_data$NV.SRV.EMPL.KD)
x4 <- log(final_data$SL.AGR.EMPL.ZS)
x5 <- log(final_data$SL.IND.EMPL.ZS)
x6 <- log(final_data$SL.SRV.EMPL.ZS)
n <- nrow(final_data)


model_string1 <- "model{

# Priors
beta0 ~ dnorm(0,0.0001)
beta1 ~ dnorm(0,0.0001)
beta2 ~ dnorm(0,0.0001)
beta3 ~ dnorm(0,0.0001)
beta4 ~ dnorm(0,0.0001)
beta5 ~ dnorm(0,0.0001)
beta6 ~ dnorm(0,0.0001)

inv_var ~ dgamma(0.1,0.1)
std <- 1/sqrt(inv_var)

# Likelihood
for(i in 1:n){
  mu[i] <- beta0 + beta1*x1[i] + beta2*x2[i]+beta3*x3[i]+beta4*x4[i]+beta5*x5[i]+beta6*x6[i]
  y[i]   ~ dnorm(mu[i],inv_var)
}
}"

model <- jags.model(textConnection(model_string1), n.chains=2,
                    data = list(x1=x1,x2=x2,x3=x3,x4=x4,x5=x5,x6=x6,y=y,n=n))
update(model, 10000, progress.bar="none"); # Burnin for 100000 samples
samp <- coda.samples(model,variable.names=c("beta0","beta1","beta2","beta3","beta4","beta5","beta6","std"), 
                     n.iter=20000, thin=1, progress.bar="text")

model_output<-as.matrix(samp)
saveRDS(samp,"modelrunfinal.RDS")
write.csv(model_output,"modelrunsfinal.csv",row.names = FALSE)

summary(samp)
effectiveSize(samp)
acfplot(samp)

# 2. HISTOGRAM PARAMETERS
library(scales)
library(lattice)
# load in the coda matrix of model runs
# this consists of slope, intercept, and noise
model_runs = read.table("modelrunsfinal.csv", sep = ",", header = TRUE)

# load in the data
emission <- log(final_data$EN.ATM.CO2E.PC)

# compute the variance
sd<-sd(emission)
pseudo_r2 <- 1-model_runs[,4]/sd
# set however many sample runs you want to display 
n <- 500

model_runs <- model_runs[1:n,1:8]
hist(model_runs[,1],col=alpha("blue",0.5),breaks=20,main="Intercept",xlab="Value",ylab="Runs")
hist(model_runs[,2],col=alpha("blue",0.5),breaks=20,main="Slope1",xlab="Value",ylab="Runs")
hist(model_runs[,3],col=alpha("blue",0.5),breaks=20,main="Slope2",xlab="Value",ylab="Runs")
hist(model_runs[,4],col=alpha("blue",0.5),breaks=20,main="Slope3",xlab="Value",ylab="Runs")
hist(model_runs[,5],col=alpha("blue",0.5),breaks=10,main="Slope4",xlab="Value",ylab="Runs")
hist(model_runs[,6],col=alpha("blue",0.5),breaks=10,main="Slope5",xlab="Value",ylab="Runs")
hist(model_runs[,7],col=alpha("blue",0.5),breaks=10,main="Slope6",xlab="Value",ylab="Runs")
hist(model_runs[,8],col=alpha("blue",0.5),breaks=16,main="Error",xlab="Value",ylab="Runs")
hist(pseudo_r2,col=alpha("blue",0.5),breaks=16,main="Pseudo R Square",xlab="Value",ylab="Runs")
splom(model_runs)
mean(pseudo_r2)

# 3. CHECK CONVERGENCE:
samp=readRDS("modelrunfinal.rds")

summary(samp)

# sometimes the gelman plot won't fit on a screen
# we have to reduce the margins
par(mar=c(3,3,1,1))
gelman.plot(samp)
gelman.diag(samp)
plot(samp, trace=FALSE, density = TRUE)
plot(samp, trace=TRUE, density = FALSE)
acfplot(samp)

# get the effective sample size
effectiveSize(samp)

# To plot correlation among the variables
library(corrgram)
final_data1 <- final_data[c(1,9:15)]
corrgram(final_data1, order=TRUE, lower.panel=panel.shade,
         upper.panel=panel.pie, text.panel=panel.txt,
         main="Correlation between economic factors and CO2/capita")
