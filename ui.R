library(shiny)

# Interface definition
shinyUI(fluidPage(
  
	titlePanel("Shiny Sample App"),
    br(),
    sidebarLayout(

        sidebarPanel(
            # Loading data panel
            fileInput("fileInPath", 
                label= h4("Import your data")
            ),
            # Choose the type of displayed plot
            radioButtons("pType", "Plot type:",
                         list("ggplot", "lattice")),
            # Choose variables to be included in analysis
            uiOutput("choose_columns"),
            # Input filename that has to be saved
            textInput("fName", "Filename"),
  
            verticalLayout(
            downloadButton("rozklad", 
                label = "Download data distribution plot"),
            
            br(),
            
          
            # R Markdown download panel
            h4("Download reports"),
            fluidRow(
              column(3,
                     downloadButton("downloadReport1", "HTML")),
              column(3,
                     downloadButton("downloadReport2", "WORD")))
            )
            

        ),
        
        
        mainPanel(

            # Main tabs 
            tabsetPanel(type = "tabs",
                
                tabPanel("Raw data", tableOutput("daneIn")),
                
                tabPanel("Distribution", plotOutput("plot")),
                
                tabPanel("Correlation matrix",  
                         downloadButton("kor_mac", 
                         label = "Download correlation matrix"),
                         tableOutput("kor_ob")),
                
                tabPanel("Correlation plot",
                         downloadButton("kor_heat", 
                         label = "Download correlation plot"), 
                         plotOutput("kor_wyk"))
            
            
            )
        
             

        )

    )

))
