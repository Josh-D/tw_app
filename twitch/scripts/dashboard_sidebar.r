sidebar <- dashboardSidebar(
  
  #width = 300,
  
  sidebarMenu(
    
    style = "position: fixed;",
    
    # input date range
    dateRangeInput('dateRange',
                   label = 'Select Date Range',
                   start = min(data$the_date),
                   end = max(data$the_date),
                   width = 225),
    
    # input - version checkbox
    checkboxGroupInput("versionGroup",
                       label = 'Select API Versions', 
                       choices = unique(data$api_version),
                       selected = unique(data$api_version),
                       inline = TRUE),
    
    # input - request method
    selectInput("requestMethodGroup",
                       label = 'Select Method', 
                       choices = unique(data$request_method),
                       selected = "GET",
                       width = 150),
    
    # input - author checkbox
    checkboxGroupInput("authorGroup",
                       label = 'Select Developers', 
                       choices = unique(data$application_author),
                       selected = unique(data$application_author))
  )
)