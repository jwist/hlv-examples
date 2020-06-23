x = rnorm(300, mean=50, sd=10)
y = rnorm(300, mean=30, sd=10)

scores = list(name = unbox("scores"), x = x, y = y, xLabel = 'x', yLabel = 'y')

conn$send(toJSON(scores))

ID = list(name = unbox("ID"), ID = paste0("id", seq_along(x)))

conn$send(toJSON(ID))
