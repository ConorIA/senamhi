## Adapted from http://shiny.rstudio.com/gallery/basic-datatable.html

library(shiny)

# Define the overall UI
shinyUI(
  fluidPage(
    titlePanel("Senamhi station catalogue"),
    
    # Create a new Row in the UI for selectInputs
    fluidRow(
      column(4,
             selectInput("config",
                         "Configuration:",
                         c("All",
                           unique(as.character(catalogue$Configuration))))
      ),
      column(4,
             selectInput("type",
                         "Type:",
                         c("All",
                           unique(as.character(catalogue$Type))))
      ),
      column(4,
             selectInput("reg",
                         "Region:",
                         c("All",
                           unique(as.character(catalogue$Region))))
      )
    ),
    # Create a new row for the table.
    fluidRow(
      DT::dataTableOutput("table")
    )
  )
)
