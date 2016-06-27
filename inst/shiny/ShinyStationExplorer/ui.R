## Adapted from http://shiny.rstudio.com/gallery/basic-datatable.html

library(shiny)

# Define the overall UI
shinyUI(
  fluidPage(
    titlePanel("Senamhi station catalogue"),
    
    # Create a new Row in the UI for selectInputs
    fluidRow(
      column(2,
             selectInput("config",
                         "Configuration:",
                         c("All",
                           unique(as.character(catalogue$Configuration))))
      ),
      column(2,
             selectInput("type",
                         "Type:",
                         c("All",
                           unique(as.character(catalogue$Type))))
      ),
      column(2,
             selectInput("sta",
                         "Station Status:",
                         c("All",
                           unique(as.character(catalogue$`Station Status`))))
      ),
      column(2,
             selectInput("reg",
                         "Region:",
                         c("All",
                           unique(as.character(catalogue$Region))))
      )
    ),
    # Create a new row for the table.
    fluidRow(
      DT::dataTableOutput("table")),
    fluidRow(br(em(comment(catalogue))))
  )
)
