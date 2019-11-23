# 1. MODEL
library(rjags)

y <- log(final_data$EN.ATM.CO2E.PC)

x2 <- log(final_data$NV.IND.EMPL.KD)


x5 <- log(final_data$SL.IND.EMPL.ZS)

n <- nrow(final_data)


model_string1 <- "model{

# Priors
beta0 ~ dnorm(0,0.0001)

beta2 ~ dnorm(0,0.0001)


beta5 ~ dnorm(0,0.0001)


inv_var ~ dgamma(0.1,0.1)
std <- 1/sqrt(inv_var)

# Likelihood
for(i in 1:n){
mu[i] <- beta0 + beta2*x2[i]+beta5*x5[i]
y[i]   ~ dnorm(mu[i],inv_var)
}
}"

model <- jags.model(textConnection(model_string1), n.chains=2,
                    data = list(x2=x2,x5=x5,y=y,n=n))
update(model, 100000, progress.bar="none"); # Burnin for 100000 samples
samp <- coda.samples(model,variable.names=c("beta0","beta2","beta5","std"), 
                     n.iter=200000, thin=10, progress.bar="text")

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

model_runs <- model_runs[1:n,1:4]
hist(model_runs[,1],col=alpha("blue",0.5),breaks=20,main="Intercept",xlab="Value",ylab="Runs")
hist(model_runs[,2],col=alpha("blue",0.5),breaks=20,main="Slope2",xlab="Value",ylab="Runs")
hist(model_runs[,3],col=alpha("blue",0.5),breaks=20,main="Slope5",xlab="Value",ylab="Runs")
hist(model_runs[,4],col=alpha("blue",0.5),breaks=20,main="Error",xlab="Value",ylab="Runs")
hist(pseudo_r2,col=alpha("blue",0.5),breaks=16,main="Pseudo R Square",xlab="Value",ylab="Runs")
splom(model_runs)
mean(pseudo_r2)


# 3. POSTERIORS:
#the data consists of 163 countries
code <- final_data$Country
x1 <- log(final_data$NV.AGR.EMPL.KD)
x2 <- log(final_data$NV.IND.EMPL.KD)
x3 <- log(final_data$NV.SRV.EMPL.KD)
x4 <- log(final_data$SL.AGR.EMPL.ZS)
x5 <- log(final_data$SL.IND.EMPL.ZS)
x6 <- log(final_data$SL.SRV.EMPL.ZS)
n <- length(code)
intercept <- rep(1,n)

# 80000 runs by 7 parameters
model_runsfinal = read.table("modelrunsfinal.csv", sep = ",", header = TRUE)
model_runsfinal <- as.matrix(model_runsfinal[1:7])

# 7 parameters by 163 nations
design_matrix <- t(cbind(intercept,x1,x2,x3,x4,x5,x6))

p <- model_runsfinal %*% design_matrix
posteriorsfinal <- as.data.frame(p)
names(posteriorsfinal) <- code

write.csv(posteriorsfinal,"posteriorsfinal.csv",row.names = FALSE)

# 4. CHECK CONVERGENCE:
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


# 5. VALIDATE
sampmatrix = as.matrix(samp)
# take the first seven parameters, but drop off the noise!
param <-sampmatrix[sample(nrow(sampmatrix),size = 50, replace=FALSE),1:3]
# create a design matrix
n <- nrow(final_data)
# make an intercept
intercept <- rep(1,n)
# bind your data together in the order used for modelling
data <- cbind(intercept,x2,x5)
pred <- param %*% t(data)
pred <- t(pred)
# replicate the results
act <- rep(y,50)
x11(width=10, height=10, pointsize=8)
par(mar=c(5,5,1,1))
plot(act,pred,xlab="Actual",ylab="Predicted",xlim=c(-5,4),ylim=c(-5,4))
abline(0,1,col=alpha("blue",1))




