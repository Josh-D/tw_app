library(ggplot2)
library(tidyr)
library(shinydashboard)
library(shiny)
library(plotly)
library(plyr)
library(rmarkdown)
library(sqldf)
library(qcc)
library(reshape2)

###############################################
  # format data + exploratory data analysis
###############################################

source("scripts/data.r")

# Product Manager has asked you to look into API call logs to help them get a better understanding of:
#   • which application developers are important to the developer ecosystem
#   • which API endpoints are more important to continue to maintain

# dashboard ui components
source("scripts/dashboard_header.r")
source("scripts/dashboard_sidebar.r")
source("scripts/dashboard_body.r")

ui <- dashboardPage(skin="purple", header, sidebar, body)

server <- function(input, output) { 
  
  # clicky reactive table
  get_data <- reactive({
    
    # variables
    start_date <- input$dateRange[1]
    end_date <- input$dateRange[2]
    
    # calls <- subset(data, the_date >= input$dateRange[1] & the_date < input$dateRange[2])
    author.calls <- aggregate(formula = num_requests ~ application_author + the_date,
                       data = subset(data, the_date >= start_date &
                                           the_date < end_date &
                                           api_version %in% input$versionGroup &
                                           request_method %in% input$requestMethodGroup &
                                           application_author %in% input$authorGroup),
                       FUN = sum)
    
    app.calls <- aggregate(formula = num_requests ~ application_name + application_author + the_date,
                              data = subset(data, the_date >= start_date &
                                            the_date < end_date &
                                            api_version %in% input$versionGroup &
                                            request_method %in% input$requestMethodGroup &
                                            application_author %in% input$authorGroup),
                              FUN = sum)
    
    
    # top 10 API calls by application + author
    app.calls.table <- aggregate(formula = num_requests ~ application_name + application_author,
                                 data = subset(data, the_date >= start_date &
                                                 the_date < end_date &
                                                 api_version %in% input$versionGroup &
                                                 request_method %in% input$requestMethodGroup &
                                                 application_author %in% input$authorGroup),
                                 FUN = sum)
    
    
    # top 10 endpoint methods
    endpoint.method.table <- aggregate(formula = num_requests ~ endpoint_method + endpoint_root,
                                 data = subset(data, the_date >= start_date &
                                                 the_date < end_date &
                                                 api_version %in% input$versionGroup &
                                                 request_method %in% input$requestMethodGroup &
                                                 application_author %in% input$authorGroup),
                                 FUN = sum)
    
    # endpoint_method
    endpoint.method.plot <- aggregate(formula = num_requests ~ endpoint_method + application_author,
                                      data = subset(data, the_date >= start_date &
                                                      the_date < end_date &
                                                      api_version %in% input$versionGroup &
                                                      request_method %in% input$requestMethodGroup &
                                                      application_author %in% input$authorGroup),
                                      FUN = sum)


    # nothing fancy
    general <- subset(data, the_date >= start_date &
                            the_date < end_date &
                            api_version %in% input$versionGroup &
                            request_method %in% input$requestMethodGroup &
                            application_author %in% input$authorGroup)
                        

    info <- list(author.calls = author.calls,
                 app.calls = app.calls,
                 app.calls.table = app.calls.table,
                 general = general,
                 endpoint.method.table = endpoint.method.table,
                 endpoint.method.plot = endpoint.method.plot)

    return(info)

  })
  


  output$author.calls.plot <- renderPlotly({
  
    plot_ly(data = get_data()$author.calls,
           x = ~the_date,
           y = ~num_requests,
           color = ~application_author,
           type = 'scatter',
           mode = 'lines',
           hoverinfo = 'text',
           text = ~paste('</br> Date: ', the_date,
                         '</br> Developer: ', application_author,
                         '</br> Requests: ', format(num_requests, big.mark = ',')))  %>%
      layout(xaxis = list(title = ""),
             yaxis = list(title = "Number of Requests"))
  })
  
  # application line plot
  output$app.calls.plot <- renderPlotly({
    
    plot_ly(data = get_data()$app.calls,
            x = ~the_date,
            y = ~num_requests,
            color = ~application_name,
            type = 'scatter',
            mode = 'lines',
            hoverinfo = 'text',
            text = ~paste('</br> Date: ', the_date,
                          '</br> Application: ', application_name,
                          '</br> Developer: ', application_author,
                          '</br> Requests: ', format(num_requests, big.mark = ',')))  %>%
      layout(xaxis = list(title = ""),
             yaxis = list(title = "Number of Requests"))
  })


  output$app.calls.table <- renderTable({
    
    # sort by 
    top.10.apps <- get_data()$app.calls.table[order(-get_data()$app.calls.table$num_requests),]
    top.10.apps$num_requests <- format(top.10.apps$num_requests, big.mark=',', scientific=FALSE) 
    names(top.10.apps) <- c("Application", "Developer", "# Requests")
    
    top.10.apps[1:10,]

  })
  
  
  output$endpoint.method.calls <- renderTable({
    
    # sort by 
    top.10.endpoint.methods <- get_data()$endpoint.method.table[order(-get_data()$endpoint.method.table$num_requests),]
    top.10.endpoint.methods$num_requests <- format(top.10.endpoint.methods$num_requests, big.mark=',', scientific=FALSE) 
    top.10.endpoint.methods <- top.10.endpoint.methods[c(2,1,3)]
    names(top.10.endpoint.methods) <- c("Root", "Endpoint", "# Requests")
    
    top.10.endpoint.methods[1:10,]
    
  })
  
  
  output$endpoint.method.plot <- renderPlotly({

    # p <- ggplot(df.m, aes(x = Period, y = value/1e+06,fill = Region)) + ggtitle("Migration to the United States by Source Region (1820-2006), In Millions")
    # p <- p + geom_bar(stat = "identity", position = "stack")
    
    # p <- ggplot(get_data()$endpoint.method.plot, aes(x = endpoint_method, y = num_requests, fill = application_author)) +
    #   geom_bar(stat= 'identity') + 
    #   labs(x='', y = '') +
    #   theme(axis.text.x = element_text(angle=45),
    #         legend.position = 'bottom',
    #         legend.title = element_blank())
    # 
    # ggplotly(p)
    
    # # sort by
    # plot_ly(data = get_data()$endpoint.method.plot,
    #         x = ~endpoint_method,
    #         y = ~go_purple,
    #         type = 'bar',
    #         name = 'go_purple') %>%
    #   add_trace(y = ~one_more_thing,
    #             name = 'one_more_thing') %>%
    #   add_trace(y = ~team_emote,
    #             name = 'team_emote') %>%
    #   add_trace(y = ~the_ogp,
    #             name = 'the_ogp') %>%
    #   layout(yaxis = list(title = 'Count'), barmode = 'stack')

  })
  
  
  # latency box plot
  output$box.plot <- renderPlotly({
    
    x <- list(
      title = "Average Latency (ms)"
    )
    
    y <- list(
      title = "",
      zeroline = FALSE,
      showline = FALSE,
      showticklabels = FALSE,
      showgrid = FALSE
    )
    

    
    plot_ly(data = get_data()$general,
            y = ~avg_latency,
            color = ~endpoint_method,
            type = 'box') %>%
      layout(margin = list(l = 100),
             xaxis = y,
             yaxis = x,
             showlegend = FALSE)
  })

  output$version <- renderPrint({ input$checkGroup })
      
}

shinyApp(ui, server)
