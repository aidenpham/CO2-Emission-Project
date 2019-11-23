# 1. MODEL
library(rjags)

y <- log(final_data$EN.ATM.CO2E.PC)

x2 <- log(final_data$NV.IND.EMPL.KD)

x4 <- log(final_data$SL.AGR.EMPL.ZS)
x5 <- log(final_data$SL.IND.EMPL.ZS)
x6 <- log(final_data$SL.SRV.EMPL.ZS)
n <- nrow(final_data)


model_string1 <- "model{

# Priors
beta0 ~ dnorm(0,0.0001)

beta2 ~ dnorm(0,0.0001)

beta4 ~ dnorm(0,0.0001)
beta5 ~ dnorm(0,0.0001)
beta6 ~ dnorm(0,0.0001)

inv_var ~ dgamma(0.1,0.1)
std <- 1/sqrt(inv_var)

# Likelihood
for(i in 1:n){
mu[i] <- beta0 + beta2*x2[i]+beta4*x4[i]+beta5*x5[i]+beta6*x6[i]
y[i]   ~ dnorm(mu[i],inv_var)
}
}"

model <- jags.model(textConnection(model_string1), n.chains=2,
                    data = list(x2=x2,x4=x4,x5=x5,x6=x6,y=y,n=n))
update(model, 100000, progress.bar="none"); # Burnin for 100000 samples
samp <- coda.samples(model,variable.names=c("beta0","beta2","beta4","beta5","beta6","std"), 
                     n.iter=200000, thin=10, progress.bar="text")

model_output<-as.matrix(samp)
saveRDS(samp,"modelrunfinal.RDS")
write.csv(model_output,"modelrunsfinal.csv",row.names = FALSE)

summary(samp)
effectiveSize(samp)
acfplot(samp)


# 2. CHECK CONVERGENCE:
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

