
source("./global.R")

navbarPage(title="College Sense",id="nav", 
           tabPanel("Home",icon = icon("home"),

                    absolutePanel(id="centered",class="panel panel-default",fixed=TRUE,
                                  draggable=F,
                                  width="auto", height="auto",
                                  strong(h1("FIND THE BEST COLLEGE FOR YOURSELF"))

                         ),

                    setBackgroundImage(src="graduation.jpg")),
           # tabPanel("Home",icon = icon("home"),
           #          h1("FIND THE BEST COLLEGE FOR YOURSELF"),
           #          img(src="graduation.jpg", width = 1450)),
           ## One #####################################################################################
           tabPanel("College Information Map",icon = icon("map-marker"),
                         div(class="outer",
                             tags$head(
                               includeCSS("styles.css"), 
                               includeScript("gomap.js")
                             ),
                             leafletOutput("map",width="100%",height="100%"),
                             absolutePanel(id="controls",class="panel panel-default",fixed=TRUE,
                                           draggable=TRUE, top=60, left=22, right="auto", bottom="auto",
                                           width=300, height="auto",
                                           #h2("College"),
                                           sliderInput(inputId = "liRank",label = "Rank",min=1,max=660,value=660),
                                           sliderInput(inputId = "tuition", label = "Annual Cost", min=9000, max=71000, value=71000),
                                           sliderInput("adm","Admission Rate",min = 0,max=1,value = 1),
                                           sliderInput("SAT","SAT",min=900,max = 1600,value=1600),
                                           sliderInput("ACT","ACT",min=18,max = 36,value = 36),
                                           selectInput(inputId = "color",label = "Color by",livars2),
                                           selectInput(inputId = "size",label = "Size by",livars)
                             )
                         ),
                         
                         useShinyjs(), 
                         hidden( 
                           div(id = "conditionalPanel",
                               fluidRow(
                                 absolutePanel(id = "controls", class = "panel panel-default", style="overflow-y:scroll; margin-top: 20px; margin-bottom: 0px;", fixed = TRUE,
                                               draggable = TRUE, top = 150, right=0, bottom = 0, #250
                                               width = 325, #400
                                               
                                               h2("Detailed Information"),
                                               
                                               selectizeInput("college", 'University',
                                                              choices = c("",universities), selected=""),
                                               tableOutput("table"),
                                               plotlyOutput("gender_bar", height = 110),
                                               plotlyOutput("race_bar", height = 110),
                                               fluidRow(
                                                 
                                               )
                                 )
                               )
                           )
                         ),
                         tags$div(id="cite",
                                  'Data compiled from',tags$em('https://collegescorecard.ed.gov/'),'by Binglun, Huiyu, Shichao, Sizhu and Yanchen (Columbia University, 2018).')),
       ## Two ##########################################################################################
       tabPanel('College Scoreboard',icon = icon("graduation-cap"),
                fluidRow(
                  column(3,
                         sliderInput("vr", label = "Sat verbal", min = 200, max = 800, value = 500), #step=10  # value=500
                         hr(),
                         sliderInput("mt", label = "Sat math", min = 200,max = 800, value = 500), #10 #value=500
                         hr(),
                         sliderInput("act", label = "ACT", min = 1, max = 36, value = 21), #value=20
                         selectInput("hd", "Highest Degree", 
                                     choices=c('Bachelor Degree','Graduate Degree',"Doesn't Matter"), selected = "Doesn't Matter"),
                         selectInput("type", "School Type", 
                                     choices=c('Public','Private nonprofit',"Doesn't Matter"), selected = "Doesn't Matter")),
                  column(9,plotOutput('cPlot',click = "pc2"),plotOutput('DPlot',click = "pc")),column(2,verbatimTextOutput("intro")))),
         
                ## Three #########################################################################################  
                tabPanel("College Comparison",icon = icon("balance-scale"),
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
                         
                ),
           
           ## Four ######################################################################################
       tabPanel("College Environment",icon = icon("heart"),
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
                             plotOutput("map3",width = "100%",height = "650px"),
                             DT::dataTableOutput("info_table")
                           )
                         )
                ),
          
           ## Five #################################################################################################
           tabPanel("Contact",icon = icon("envelope"),
                    sidebarLayout(
                      
                      sidebarPanel(
                        h2("Contact Information"),
                        tags$h5("Linkedin:",style="display: inline"),
                        tags$a(href="https://www.linkedin.com/in/binglun- zhao-421b78111/","Binglun Zhao"),
                        tags$h5("bz2342@columbia.edu"),
                        tags$h5("Linkedin:",style="display: inline"),
                        tags$a(href="https://www.linkedin.com/in/hz2497/","Huiyu Zhang"),
                        tags$h5("hz2497@columbia.edu"),
                        tags$h5("Linkedin:",style="display: inline"),
                        tags$a(href="https://www.linkedin.com/in/sizhu-stella-chen-5aab5a14b/","Sizhu Chen"),
                        tags$h5("sc4248@columbia.edu"),
                        tags$h5("Linkedin:",style="display: inline"),
                        tags$a(href="https://www.linkedin.com/in/shichao-jia-898a70b0","Shichao Jia"),
                        tags$h5("sj2854@columbia.edu"),
                        tags$h5("Linkedin:",style="display: inline"),
                        tags$a(href="https://www.linkedin.com/in/yanchen-chen","Yanchen Chen"),
                        tags$h5("yc3373@columbia.edu")),
                   
                      mainPanel(
                        img(src="name.png", width = 475)
              ###################################################################################
                        )
                      )
                    )
           )
