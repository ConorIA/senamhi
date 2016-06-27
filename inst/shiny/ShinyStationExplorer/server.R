## Adapted from http://shiny.rstudio.com/gallery/basic-datatable.html

library(shiny)

# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- catalogue
    if (input$config != "All") {
      data <- data[data$Configuration == input$config,]
    }
    if (input$type != "All") {
      data <- data[data$Type == input$type,]
    }
    if (input$sta != "All") {
      data <- data[data$`Station Status` == input$sta,]
    }
    if (input$reg != "All") {
      data <- data[data$Region == input$reg,]
    }
    data
  }))
})
