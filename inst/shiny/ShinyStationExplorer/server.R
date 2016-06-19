## Adapted from http://shiny.rstudio.com/gallery/basic-datatable.html

library(shiny)

# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- senamhi:::catalogue
    if (input$class != "All") {
      data <- data[data$Class == input$class,]
    }
    if (input$type != "All") {
      data <- data[data$Type == input$type,]
    }
    if (input$reg != "All") {
      data <- data[data$Region == input$reg,]
    }
    data
  }))
})