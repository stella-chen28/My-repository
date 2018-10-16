# server.R

library(maps)
library(mapproj)
employ <- read.csv("employ.csv")
heat_index <- read.csv("heat_index.csv")
table_final <- read.csv("table_final.csv")
source("helpers.R")


shinyServer(
  function(input, output) {
    output$map <- renderPlot({
      args <- switch(input$var,
                     "Heat index" = list(heat_index$index, "orange", "Heat index"),
                     "unemployment rate" = list(employ$Rate, "black", "unemployment rate")
                     
)
      args$min <- input$range[1]
      args$max <- input$range[2]
      
      do.call(percent_map, args)
    })
    
    output$info_table<-DT::renderDataTable({
      DT::datatable(table_final
      )
    })
  }
)
