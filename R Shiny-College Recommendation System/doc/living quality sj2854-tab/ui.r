


shinyUI(fluidPage(
  titlePanel("living quality County Summary"),
  
  sidebarLayout(
    sidebarPanel(
      h5("Create Heat index and uneployment rate graphic."),
      h6("This is a way to show living quality in a dynamic way. "),
      
      selectInput("var", 
                  label = "Choose a variable to display",
                  choices = c("Heat index", "unemployment rate"),
                  selected = "Student Enrolled"),
      helpText("# student displayed here is adjusted"),
      sliderInput("range", 
                  label = "Range of interest:",
                  min = 0, max = 100, value = c(0, 100))
      ),
    
    mainPanel(
      plotOutput("map",width = "120%",height = "700px"),
      DT::dataTableOutput("info_table")
           
    ))))
