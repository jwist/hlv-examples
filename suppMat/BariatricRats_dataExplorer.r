
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

#create url to original jcamp files and append to metadata
# files have to be accessible to the web server
# a good idea is to put the jcamp in the folder following folder:
file.path( system.file(package = "hastaLaVista"), "visu", "data", "jcamp")
# if no jcamp are available, the tool will just work as expected
# except no original data will be displayed
metadata['JcampUrl'] <- paste0('http://127.0.0.1:5474/data/jcamp/', metadata$Experiment.Number, '-1.jdx')

# normalisation of data
Xn=MetaboMate::pqn(X)
MetaboMate::matspec(ppm, Xn, shift=c(7,8))

# preparation of the dataset to create the data.json file
ID <- metadata$Sample.Label
group <- metadata$Class
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

# adding data and xAxis to the list
# do not modify variableName, the view is expecting it! 
d <- appendData(data = d, variableName = "data", variable = c, type = "table")
# do not modify variableName, the view is expecting it! 
d <- appendData(data = d, variableName = "xAxis", variable = x_axis, type = "table")

# preparing for visualization
# display may take a while, since large amount of data
# is passed to the browser
v3 <- new("visualization")
v3@data <- "rat_bariatric_dataExplorer.data.json"
v3@view <- "dataExplorer_1_0_1.view.json"
push(v3, type="data", d)
visualize(v3)


# you may want to continue and add pca results...


# performing multivariate analysis
# this step is only required for dataExplorer 1.1
mod <- MetaboMate::pca(Xn)

chart12 <- data.frame("x" = mod@t[,1],
                      "y" = mod@t[,2],
                      "highlight" = seq_along(group) - 1,
                      "info"= ID,
                      "group" = as.numeric( group ),
                      "color" = color
)

# adding score plot to the list structure
# do not modify variableName, the view is expecting it! 
d <- appendData( data = d, variableName = "score12", variable = chart12, type = "score")

# adding scores, loadings and colour-code
d[['scores']] <- mod@t
d[['loadings']] <- cov(mod@t, x)
d[['loadingsColor']] <- abs(cor(mod@t, x))

# calculating ellipse
ellipse <- dataEllipse(mod@t[,1], mod@t[,2], levels=0.80)

ellipseChart <- data.frame("x" = ellipse[,1],
                           "y" = ellipse[,2],
                           "color" = rep('black', length(ellipse[,1])))

# addit ellipse data to the list
# do not modify variableName, the view is expecting it! 
d <- appendData( data = d, variableName = "ellipse", variable = ellipseChart, type = "color")



v4 <- new("visualization")
v4@data <- "rat_bariatric_dataExplorer.data.json"
v4@view <- "dataExplorer_1_1.view.json"
push(v4, type="data", d)
visualize(v4)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
