##' @title A Shiny interface to Senamhi weather and river stations
##'
##' @description A function to launch a shiny web app to explore Senamhi stations.
##'
##' @param local logical; if set to `TRUE`, we will show only the data that is available locally.
##'
##' @return none
##' 
##' @author Conor I. Anderson
##' 
##' @importFrom shiny br column em fluidPage fluidRow runApp selectInput shinyApp shinyUI titlePanel
##' @importFrom DT datatable dataTableOutput renderDataTable
##' 
##' @export
##' 
##' @examples
##' \dontrun{station_explorer()}

station_explorer <- function(local = FALSE) {

  if (local) {
    if (exists("localcatalogue")) {
      data <- localcatalogue
    } else {
      if (file.exists("localCatalogue.rda")) {
        load("localCatalogue.rda")
      } else {
        stop("You asked to show locally-downloaded data, but I couldn't find a local catalogue file in your environment. Please run `generate_local_catalogue()` first.")  
      }
    }
    comment(data) <- "This table lists the data that is present in your working directory, provided you have run `generate_local_catalogue()` recently."
  } else {
    data <- catalogue
  }
  
  app <- shinyApp(
  shinyUI(
    fluidPage(
      titlePanel("Senamhi station catalogue"),
      
      # Create a new Row in the UI for selectInputs
      fluidRow(
        column(2,
               selectInput("config",
                           "Configuration:",
                           c("All",
                             unique(as.character(data$Configuration))))
        ),
        column(2,
               selectInput("type",
                           "Type:",
                           c("All",
                             unique(as.character(data$Type))))
        ),
        column(2,
               selectInput("sta",
                           "Station Status:",
                           c("All",
                             unique(as.character(data$`Station Status`))))
        ),
        column(2,
               selectInput("reg",
                           "Region:",
                           c("All",
                             unique(as.character(data$Region))))
        )
      ),
      # Create a new row for the table.
      fluidRow(
        dataTableOutput("table")),
      fluidRow(br(em(comment(data))))
    )
  ),
  server = function(input, output) {
    # Filter data based on selections
    output$table <- renderDataTable(datatable({
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
  runApp(app)
}
