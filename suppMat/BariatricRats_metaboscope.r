
# to install hastaLaVista package use the following:
# devtools::install_github("jwist/hastaLaVista")
# the simply load the library
library(hastaLaVista)

# we use the MetaboMate package for normalization
# and for multivariate analysis
# to install it use:
# devtools::install_github("kimsche/MetaboMate")
library(MetaboMate)
library(car)

# load demo dataset
data("bariatricRat")
X <- bariatricRat$X
ppm <- bariatricRat$ppm
metadata <- bariatricRat$metadata

# normalisation of data
Xn=pqn(X)
matspec(ppm, Xn, shift=c(7,8))

# preparation of the dataset to create the data.json file
ID <- metadata$Sample.Label
group <- metadata$Class
metadata <- data.frame(metadata)
x <- matrix(Xn, dim(X)[1], dim(X)[2])
x_axis <- as.numeric( ppm )
color = sapply(group, function(x) getColor2(as.character(x)))

d = list()
c <- data.frame(ID = ID,
                group = group,
                color = color,
                "_highlight" = seq_along(group) - 1,
                dataMatrix = I(matrix( c(rbind(repRow(x_axis, nrow(x)), x)), nrow(x), ncol(x)*2)),
                metadata = I(metadata),
                check.names = FALSE
)

# do not modify variableName, the view is expecting it! 
d <- appendData(data = d, variableName = "data", variable = c, type = "table")

# performing multivariate analysis
smod=opls(Xn, group)
plotscores(smod, an=list(Class=group), cv.scores = F)
plotload(smod, Xn, ppm, title='oPLS loadings')

chart12 <- data.frame("x" = smod@t_pred,
                      "y" = smod@t_orth,
                      "highlight" = seq_along(group) - 1,
                      "info"= ID,
                      "group" = as.numeric( group ),
                      "color" = color
)

plot(smod@t_pred, smod@t_orth)

# do not modify variableName, the view is expecting it! 
d <- appendData( data = d, variableName = "score12", variable = chart12, type = "score")

d[['scores']] <- smod@t_pred
d[['loadings']] <- cov(smod@t_pred, x)
d[['loadingsColor']] <- abs(cor(smod@t_pred, x))

# calculating ellipses
ellipse <- dataEllipse(as.numeric(smod@t_pred), as.numeric(smod@t_orth), levels=0.80)

ellipseChart <- data.frame("x" = ellipse[,1],
                           "y" = ellipse[,2],
                           "color" = rep('black', length(ellipse[,1])))

# do not modify variableName, the view is expecting it! 
d <- appendData( data = d, variableName = "ellipse", variable = ellipseChart, type = "color")


v2 <- new("visualization")
v2@data <- "rat_bariatric_metaboscope.data.json"
v2@view <- "metaboscope_1_0.view.json"
push(v2, type="data", d)
visualize(v2)
