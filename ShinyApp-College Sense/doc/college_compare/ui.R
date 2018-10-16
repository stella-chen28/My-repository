library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tabPanel("College Comparison",
           fluidRow(
             column(3,selectInput('College 1', 'College 1',
                                   colnames(data_use),
                                   selected ="Stanford University")),
             column(3,selectInput('College 2', 'College 2',
                                  colnames(data_use),
                                  selected ="Williams College")),
             column(3,selectInput('College 3', 'College 3',
                                  c("None",colnames(data_use)),
                                  selected ="None")),
             column(3,selectInput('College 4', 'College 4',
                                  c("None",colnames(data_use)),
                                  selected ="None"))
             ),
           hr(),
           fluidRow(
             column(7,DT::dataTableOutput("compare_table"),
                    plotOutput("compare_radar",
                               width="100%",height = "650px")),
             column(5,plotOutput("compare_line_adm",
                                 width="100%", height = "300px"),
                    br(),
                    hr(),
                    br(),
                    plotOutput("compare_line_tuitionin",width="100%", height = "300px"),
                    br(),
                    hr(),
                    br(),
                    plotOutput("compare_line_tuitionout",width="100%", height = "300px")))
          
          )
                 ))
       
  

  

