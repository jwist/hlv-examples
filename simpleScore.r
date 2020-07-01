N = 500
x = rnorm(N, mean=0, sd=10)
y = rnorm(N, mean=0, sd=10)

scores = list(name = unbox("scores"), x = x, y = y, xLabel = 'x', yLabel = 'y')

conn$send(toJSON(scores))

ID = list(name = unbox("ID"), value = paste0("id", seq_along(x)))

conn$send(toJSON(ID))

group = list(name = unbox("group"), value = paste0("group", seq_along(x)))

conn$send(toJSON(group))

color = list(name = unbox("color"), value = c(rep(1,N/2), rep(2,N/2)))

conn$send(toJSON(color))
