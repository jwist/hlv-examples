library(httpuv)
library(jsonlite)
library(rstudioapi)
url = "http://localhost:5474"
translatedURL = translateLocalUrl(url = url, absolute = TRUE)
view = "ws.view.json"
data = "test.data.json"
hlvURL = paste0(translatedURL, "?viewURL=", translatedURL, "view/", view, "&dataURL=", translatedURL, "data/", data)
print(hlvURL)
browseURL(hlvURL)
stopAllServers()
cat("Starting server on port 8888 \n")
s <- startServer("0.0.0.0", 8888,
  list(
    onHeaders = function(req) {
    # Print connection headers
    cat(capture.output(str(as.list(req))), sep = "\n")
    },
    onWSOpen = function(ws) {
      cat("Connection opened.\n")
      ws$onMessage(function(binary, message) {
        cat("Server received message:", message, "\n")
        ws$send('r got your message')
        assign("from", fromJSON(message), envir=.GlobalEnv)
        assign("conn", ws, envir=.GlobalEnv)
      })
      ws$onClose(function() {
        cat("Connection closed.\n")
      })
    }
  )
)
#stopAllServers()