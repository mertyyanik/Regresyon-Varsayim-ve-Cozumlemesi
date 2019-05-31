# Veri Okutuluşu
library(readr)
data <- read_table2("C:/Users/user/Desktop/Regresyon/data.txt")
names(data)<-c("y","x1","x2","x3","x4") 
attach(data)

data['x4'] = as.factor(x4)
attach(data)

# Normallik Varsayımı
qqnorm(y)
qqline(y)

library(nortest)
ad.test(y)

boxplot(y)

data = data[-c(49,34,70,31,98,92),]
attach(data)
ad.test(y)

plot(data)

# Aykırı, Etkin, Uç Değer
sonuc = lm(y~x1+x2+x3+x4)
aykiri = ls.diag(sonuc)

which(!(aykiri$std.res>-2 & aykiri$std.res<2))

which(!(aykiri$stud.res>-3 & aykiri$stud.res<3))

n = nrow(data)
cook = 4/n
which((aykiri$cooks>cook))

hii = (2*((ncol(data)-1)+1))/n
which((aykiri$hat>hii))

liste = c(which(!(aykiri$std.res>-2 & aykiri$std.res<2)),which(!(aykiri$stud.res>-3 & aykiri$stud.res<3)),which((aykiri$cooks>cook)),which((aykiri$hat>hii)))
unique(liste)

data = data[-unique(liste),]
attach(data)
ad.test(y)

while(TRUE){
  sonuc = lm(y~x1+x2+x3+x4)
  aykiri = ls.diag(sonuc)
  n = nrow(data)
  cook = 4/n
  hii = (2*((ncol(data)-1)+1))/n
  liste = c(which(!(aykiri$std.res>-2 & aykiri$std.res<2)),which(!(aykiri$stud.res>-3 &      aykiri$stud.res<3)),which((aykiri$cooks>cook)),which((aykiri$hat>hii)))
  if(length(liste) == 0){
    break
  }
  data = data[-unique(liste),]
  attach(data)
  normallik = ad.test(y)
  if(normallik$p.value < 0.05){
    print("Uyarı! Normallik varsayımı sağlanmıyor.")
    break
  }
  print(normallik$p.value)
}

nrow(data)

# Değişen Varyanslılık
plot(predict(sonuc), abs(aykiri$stud.res), ylab="Studentized Residuals", xlab="Predicted Value")

library(lmtest)
bptest(sonuc)

dwtest(sonuc)

library(DAAG)
vif(sonuc)

library(perturb)
colldiag(model.matrix(sonuc))

ort1<-mean(x1)
kt1<-sum((x1-ort1)^2)
skx1<-(x1-ort1)/(kt1^0.5)
ort2<-mean(x2)
kt2<-sum((x2-ort2)^2)
skx2<-(x2-ort2)/(kt2^0.5)
ort3<-mean(x3)
kt3<-sum((x3-ort3)^2)
skx3<-(x3-ort3)/(kt3^0.5)

x<-cbind(skx1,skx2,skx3)
sm<- eigen (t(x)%*%x)
signif(sm$values,3)

tersToplam = (1/signif(sm$values,3)[1]) + (1/signif(sm$values,3)[2]) + (1/signif(sm$values,3)[3])
tersToplam

signif(sm$vectors,3)

cor(data[,-5])

# Model Anlamlılılğı
summary(sonuc)

# Uyum Kestirimi
predict(sonuc, data.frame(x1=2.850419, x2=1.38953932, x3=6.486974, x4 = "1"),interval = 'confidence')

# Ön Kestirim
predict(sonuc, data.frame(x1=3, x2=1, x3=5, x4 = "3"),interval = 'confidence')

# Regresyon Katsayıları İçin Güven Aralığı
confint(sonuc, level = .99)

# Değişken Seçimi
library(stats)
lm.null <- lm(y ~ 1)
forward <- step(lm.null,y~x1+x2+x3+x4,  direction = "forward")
forward

summary(forward)

backward<-step(sonuc,direction="backward")

library(MASS)
step.model <- stepAIC(sonuc, direction = "both", trace = FALSE)
summary(step.model)

# Ridge Regresyonu
library(MASS)
ridge = lm.ridge(sonuc, lambda = seq(0, 1, 0.05))
matplot(ridge$lambda,t(ridge$coef),type = "l" ,xlab = expression(lambda),ylab = expression(hat(beta)))
abline(h=0, lwd = 2)

select(ridge)

ridge$coef[,ridge$lambda == 0.20]


