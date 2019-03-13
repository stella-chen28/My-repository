
z<-read.csv("spx50_20130423to20160422.csv",header = T)

library(PortfolioAnalytics)

z.logrtn <- apply(log(z),2,diff)#50 stocks
z.rtn <- exp(z.logrtn)-1#turn logreturn into net return
std <- apply(z.rtn,2,StdDev)
cov.mat <- cov(z.rtn)
mean.rtn<-apply(z.rtn,2,mean)#daily mean return

z.rtn30<-z.rtn[,1:30]#30 stocks
std30<-std[1:30]
cov.mat30 <- cov(z.rtn30)
mean.rtn30<-apply(z.rtn30,2,mean)

z.rtn10<-z.rtn[,1:10]#10 stocks
std10<-std[1:10]
cov.mat10 <- cov(z.rtn10)
mean.rtn10<-apply(z.rtn10,2,mean)

x0 <- (1/std)/sum(1/std) #starting weights
x0_30<-(1/std30)/sum(1/std30)
x0_10<-(1/std10)/sum(1/std10)

# objective function
eval_f <- function(w,cov.mat,vol.target) {
  vol <- sqrt(as.numeric(t(w) %*% cov.mat %*% w))#sigma(w)
  marginal.contribution <- cov.mat %*% w / vol#wi
  return( sum((vol/length(w) - w * marginal.contribution)^2) )
}

# numerical gradient approximation for solver
eval_grad_f <- function(w,cov.mat,vol.target) {
  out <- w
  for (i in 0:length(w)) {
    up <- dn <- w
    up[i] <- up[i]+.0001
    dn[i] <- dn[i]-.0001
    out[i] = (eval_f(up,cov.mat=cov.mat,vol.target=vol.target) 
              - eval_f(dn,cov.mat=cov.mat,vol.target=vol.target))/.0002
  }
  return(out)
}

#do optimization
library(nloptr)

#50 stocks
res50 <- nloptr(x0=x0,
               eval_f=eval_f,
               eval_grad_f=eval_grad_f,
               eval_g_eq=function(w,cov.mat,vol.target) { sum(w) - 1 },
               eval_jac_g_eq=function(w,cov.mat,vol.target) { rep(1,length(std)) },
               lb=rep(0,length(std)),ub=rep(1,length(std)),
               opts = list("algorithm"="NLOPT_LD_SLSQP","print_level" = 3,
                           "xtol_rel"=1.0e-8,"maxeval" = 1000),
               cov.mat = cov.mat,vol.target=.02 )

weight50<-res50$solution#weights
expect.rtn50<-sum(weight50*mean.rtn)#daily return
expect.rtn50<-expect.rtn50*252# turn daily return into annual return
risk50<-sqrt((res50$solution %*% cov.mat %*% res50$solution)*252)#annual

#30 stocks
res30<-nloptr(x0=x0_30,
              eval_f=eval_f,
              eval_grad_f=eval_grad_f,
              eval_g_eq=function(w,cov.mat,vol.target) { sum(w) - 1 },
              eval_jac_g_eq=function(w,cov.mat,vol.target) { rep(1,length(std30)) },
              lb=rep(0,length(std30)),ub=rep(1,length(std30)),
              opts = list("algorithm"="NLOPT_LD_SLSQP","print_level" = 3,
                            "xtol_rel"=1.0e-8,"maxeval" = 1000),
              cov.mat = cov.mat30,vol.target=.02 )
weight30<-res30$solution#weights
expect.rtn30<-sum(weight30*mean.rtn30)
expect.rtn30<-expect.rtn30*252
risk30<-sqrt((res30$solution %*% cov.mat30 %*% res30$solution)*252)

res10<-nloptr(x0=x0_10,
              eval_f=eval_f,
              eval_grad_f=eval_grad_f,
              eval_g_eq=function(w,cov.mat,vol.target) { sum(w) - 1 },
              eval_jac_g_eq=function(w,cov.mat,vol.target) { rep(1,length(std10)) },
              lb=rep(0,length(std10)),ub=rep(1,length(std10)),
              opts = list("algorithm"="NLOPT_LD_SLSQP","print_level" = 3,
                          "xtol_rel"=1.0e-8,"maxeval" = 1000),
              cov.mat = cov.mat10,vol.target=.02 )
weight10<-res10$solution#weights
expect.rtn10<-sum(weight10*mean.rtn10)
expect.rtn10<-expect.rtn10*252
risk10<-sqrt((res10$solution %*% cov.mat10 %*% res10$solution)*252)

summary.port<-data.frame(expected.annual.rtn=c(expect.rtn10,expect.rtn30,expect.rtn50),
                         Volatility=c(risk10,risk30,risk50)) ##volatility is portfolio std
                         
rownames(summary.port)<-c("10-stock","30-stock","50-stock")

summary.port

#10-stock portfolio has max expected logreturn; 50-stock portfolio has min risk

rf<-0.0101
# choose the "best" portfolio with biggest Sharpe Ratio 

sharpe.ratio10<-(expect.rtn10-rf)/risk10
sharpe.ratio30<-(expect.rtn30-rf)/risk30
sharpe.ratio50<-(expect.rtn50-rf)/risk50
c(sharpe.ratio10,sharpe.ratio30,sharpe.ratio50)

#10-stock portfolio is the "best" 


