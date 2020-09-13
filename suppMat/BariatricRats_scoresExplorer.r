
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
library(corrplot)

# load demo dataset
data("bariatricRat")
metadata <- bariatricRat$metadata

# check that folers are there
# l = list.dirs("/run/media/jul/44B6-1E16/data/Julien Bariatric Rat", recursive = FALSE)
# l = as.numeric(unlist(lapply(l, function(x) strsplit(x, "/")[[1]][8])))
# length(match(metadata$Experiment.Number, l))

write.table(file = "./bariatricRatsMetadata.csv", metadata[, c(5, 1, 2, 3, 4, 6:ncol(metadata))], quote=FALSE, sep="\t", col.names = NA)

data("bariatricRat.binned.5")
metadata['JcampUrl'] <- paste0('http://127.0.0.1:5474/data/jcamp/', metadata$Experiment.Number, '-1.jdx')

Xn.binned <- bariatricRat.binned.5$binned.data
ppm.binned <- bariatricRat.binned.5$binned.ppm
matspec(ppm.binned, Xn.binned, shift=c(7,8))

ID <- metadata$Sample.Label
group <- metadata$Class
metadata <- data.frame(metadata)
x <- matrix(Xn.binned, dim(Xn.binned)[1], dim(Xn.binned)[2])
x_axis <- as.numeric( ppm.binned )
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
# do not modify variableName, the view is expecting it! 
d <- appendData(data = d, variableName = "xAxis", variable = x_axis, type = "table")

corX <- abs(cor(x))
# do not modify variableName, the view is expecting it! 
d <- appendData(data = d, variableName = "correlationMatrix", variable = corX, type = "table")

mod <- MetaboMate::pca(x)

chart12 <- data.frame("x" = mod@t[,1],
                      "y" = mod@t[,2],
                      "highlight" = seq_along(group) - 1,
                      "info"= ID,
                      "group" = as.numeric( group ),
                      "color" = color
)
# do not modify variableName, the view is expecting it! 
d <- appendData( data = d, variableName = "score12", variable = chart12, type = "score")

d[['scores']] <- mod@t
d[['loadings']] <- cov(mod@t, x)
d[['loadingsColor']] <- abs(cor(mod@t, x))


ellipse <- dataEllipse(mod@t[,1], mod@t[,2], levels=0.80)

ellipseChart <- data.frame("x" = ellipse[,1],
                           "y" = ellipse[,2],
                           "color" = rep('black', length(ellipse[,1])))
# do not modify variableName, the view is expecting it! 
d <- appendData( data = d, variableName = "ellipse", variable = ellipseChart, type = "color")


v <- new("visualization")
v@data <- "rat_bariatric_pcaExplorer.data.json"
v@view <- "scoresExplorer_2_0.view.json"
push(v, type="data", d)
visualize(v)
