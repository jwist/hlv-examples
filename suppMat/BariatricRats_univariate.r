
# to install hastaLaVista package use the following:
# devtools::install_github("jwist/hastaLaVista")
# the simply load the library
library(hastaLaVista)

# load demo dataset
data("bariatricRat")
metadata <- bariatricRat$metadata

data("bariatricRat.binned.4")

Xn.binned <- bariatricRat.binned.4$binned.data
ppm.binned <- bariatricRat.binned.4$binned.ppm
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
d <- appendData(data = d, variableName = "data", variable = c, type = "table")
d <- appendData(data = d, variableName = "xAxis", variable = x_axis, type = "table")

imag = NULL
for (i in seq(from=2, to=5728*2, by=2)) {
  png(tf1 <- tempfile(fileext = ".png"));  boxplot( dataMatrix[,i] ~ group, data = c); dev.off()
  imag[[i/2]] <- paste0("data:image/png;base64,", base64enc::base64encode(tf1))
}
l <- data.frame("_highlight" = seq_along(x_axis),
                value = unlist(imag),
                check.names = FALSE)
d <- appendData(data = d, variableName = "img", variable = l, type = "table")

v5 <- new("visualization")
v5@view <- "univariate_1_1.view.json"
v5@data <- "univariateExplorer.data.json"
push(v5, type="data", d)
visualize(v5)
