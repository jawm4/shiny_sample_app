library(shiny)
library(ggplot2)
library(reshape)
library(lattice)
library(corrplot)
library(knitr)
library(rmarkdown)


shinyServer(function(input, output) {

    # Data import
    dataIn <- reactive({
        inFile <- input$fileInPath
        
        if (is.null(inFile)) {
            return(NULL)
        }
        read.table(file=inFile$datapath,sep=";",dec=",",header=T,stringsAsFactors=FALSE)
    })
    
    # Choose variables to correlation matrix
    output$choose_columns <- renderUI({
      
      if(is.null(input$fileInPath)){
        return()}
      
      else {
      dat <- dataIn()
      col <- colnames(dat[,-1])
      
      checkboxGroupInput("kolumny", "Choose columns to correlation matrix", 
                         choices  = col,
                         selected = col,
                         inline = TRUE)}
    })
    
    # Viewing sample data (first and last five observations)
    output$daneIn <- renderTable({
        ret <- rbind(
            head(dataIn(),5),
            tail(dataIn(),5)
        )
    
        return(ret)
    
    },include.rownames=FALSE)
    
    
    # Display distribution plot
    output$plot <- renderPlot({
      if(is.null(input$fileInPath)){
        return()}
      else {
      plotInput()}
        })
    
    # Function for displaying distribution plot
    # It will be used for reporting too
    plotInput <- function(){
      
      # Data wrangling
      d <- dataIn()
      d <- melt(d,id.vars="ID")
      
      # Conditional display - ggplot or lattice
      if (input$pType=="ggplot"){
        wyk <- (
          ggplot(d,aes(x=variable,y=value)) 
          + geom_boxplot(fill="gold") + coord_flip() + theme_bw()+
            labs(y="VAR", 
                 x="Value", 
                 title="ggplot")
        ) 
      }
      else if (input$pType=="lattice"){
        wyk <- bwplot(variable~value,d,
                      main="lattice",
                      ylab="VAR",
                      xlab="Value")
      }
      return(wyk)  
    }
    
    # Function generating correlation matrix
    generateCor <- function(){
      dat <- dataIn()
      x <- cor(dat[,input$kolumny])
      return(x)
    }
    
    # Rendering table based using generateCor function
    output$kor_ob <- renderTable({
      if(is.null(input$fileInPath)){
        return()}
      else {
        generateCor()
      }
      
    })
    
    # Generating correlation plot using generateCor function
    output$kor_wyk <- renderPlot({
      if(is.null(input$fileInPath)){
        return()}
      else {
        dat <- dataIn()
        corrplot(generateCor())
      }
      
    })
    
    
    # Save the plot that is currently being displayed: lattice or ggplot
    output$rozklad <- downloadHandler(
        filename = function() { 
            paste0(input$fName, ".png") 
        },
        content = function(file) {
          png(file)
          print(plotInput())
          dev.off()
        }
    )
    
    # Save correlation matrix to .csv
    output$kor_mac <- downloadHandler(
      filename = function() { 
        paste0("corr_matrix.csv") 
      },
      content = function(file) {
        write.table(generateCor(),
                    file,sep=";",dec=".",row.names=F,col.names=F)
      }
    )
    
    # Save correlation plot to .png file
    output$kor_heat <- downloadHandler(
      filename = function() { 
        paste0("corr_viz.png") 
      },
      content = function(file) {
        png(file)
        print(corrplot(generateCor()))
        dev.off()
      }
    )
    
    # Pass arguments to R Markdown in order to generate reports (word or html), then download it
    output$downloadReport1 <- downloadHandler(
      filename = paste("report.html"),
      
      content = function(file) {
        
        tempReport <- file.path("report.Rmd")
        params <- list(a = plotInput(), b=generateCor())
        file.copy("report.Rmd", tempReport)
        
        rmarkdown::render(tempReport, output_file = file, params = params)
        
      }
    )
    
    output$downloadReport2 <- downloadHandler(
      filename = paste("report.doc"),
      
      content = function(file) {
        
        tempReport <- file.path("report_doc.Rmd")
        params <- list(a = plotInput(), b=generateCor())
        file.copy("report_doc.Rmd", tempReport)
        
        rmarkdown::render(tempReport, output_file = file, params = params)
        
      }
    )

})
