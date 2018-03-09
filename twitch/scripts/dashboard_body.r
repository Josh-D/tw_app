body <- dashboardBody(
  
  fluidRow(
    
    box(
      plotlyOutput("author.calls.plot"),
      title = "API Requests by Developer",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12
    )
  ),  
  
  fluidRow(
    
    box(
      plotlyOutput("app.calls.plot"),
      title = "API Requests by Application",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12
    )
  ),
  
  fluidRow(
    
    box(
      tableOutput("app.calls.table"),
      title = "Top 10 Apps by Requests",
      solidHeader = TRUE,
      collapsible = TRUE,
      status = "primary",
      width = 5
    ),
    
    box(
      tableOutput("endpoint.method.calls"),
      title = "Top 10 Endpoints by Requests",
      solidHeader = TRUE,
      collapsible = TRUE,
      status = "primary",
      width = 7
    )
  ),  
  
  # fluidRow(
  #   
  #   box(
  #     plotlyOutput("endpoint.method.plot"),
  #     title = "Endpoint Daily Usage",
  #     solidHeader = TRUE,
  #     collapsible = TRUE,
  #     width = 12
  #   )
  # ),
  
  fluidRow(
    
    box(
      plotlyOutput("box.plot"), # placeholder plot
      title = "Latency Distributions",
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12
    )
  )
  
  # tabItems(
  #   
  #   tabItem(
  #     
  #     tabName = "developers",
  #     
  #     fluidRow(
  #       
  #       box(
  #         plotlyOutput("calls.plot"),
  #         title = "API Requests",
  #         solidHeader = TRUE,
  #         collapsible = TRUE,
  #         width = 12
  #       )
  #     )
  #   ),
  #   tabItem(
  #     
  #     tabName = "endpoints",
  #     
  #     fluidRow(
  #       
  #       box(
  #         plotlyOutput("box.plot"), # placeholder plot
  #         title = "Latency Distributions",
  #         solidHeader = TRUE,
  #         collapsible = TRUE,
  #         width = 12
  #       )
  #     )
  #   )
  # )
)
