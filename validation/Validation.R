

# Alfor <- R.matlab::readMat("D:/INRAE-montpllier/Code/streamflow_generator/Seine/validation/synthetic/Alfor-1000x1-daily.mat")

synth <- read.csv("D:/INRAE-montpllier/Code/streamflow_generator/Seine/validation/synthetic/synth_gen_daily_1000ys.csv")
obs  <- dplyr::select(read.csv("D:/INRAE-montpllier/Data/Q_NAT_1900-2009.csv"),-1)

station = 1

mean.synth <- mean(synth[,station])
stand.synth <- sd(synth[,station])
mean.obs <- mean(obs[,station])
stand.obs <- sd(obs[,station])

x <-seq(0,500, by =1)
lognormal<- function (mean, stand, data){
  logy <- dlnorm(x, meanlog = log(mean), sdlog = log(stand), log = F)
  hist(as.numeric(data), border = 0, freq = F, xlim = c(0, 100),ylim = c(0,0.08), main = name, xlab = "Streamflow (m3/s)", 
       ylab = "PDF (log-normal)",cex.main=1.8, cex.lab=1.5, cex.axis=1.2)
  lines(x, logy, type = "o", col ="red" , lwd = 1.8)
  }
dataset <- data.frame(synth[1:length(obs[,1]),station], obs[,station])
names(dataset)[1] <-"Synthetic"
names(dataset)[2] <-"Historical"
par(mfrow=c(2,2)) 
name <- "Synthetic"
lognormal(mean.synth,stand.synth, synth[,station])
name <- "Historical"
lognormal(mean.obs,stand.obs, obs[,station])
# boxplot(synth[,station],obs[,station], main = "Boxplot", cex.main=1.8, cex.lab=1.5, cex.axis=1.2,ylab = "Streamflow(m3/s)")
plot(dataset$Synthetic, dataset$Historical,  xlab = "Synthetic", ylab = "Historical", main = "Scatter",cex.main=1.8, cex.lab=1.5, cex.axis=1.2)
abline(fit<- lm(Historical~Synthetic, data = dataset), lwd = 2,col="red")
legend("topright", bty="n", legend=paste("R2 = ", 
     format(summary(fit)$adj.r.squared, digits=4)))
qqplot(dataset$Synthetic, dataset$Historical,  xlab = "Synthetic", ylab = "Historical", main = "QQplot",cex.main=1.8, cex.lab=1.5, cex.axis=1.2)
lines(c(0,2400), c(0,2400), col = "blue")
       cor.test(dataset$Synthetic, dataset$Historical,  method = "pearson")


