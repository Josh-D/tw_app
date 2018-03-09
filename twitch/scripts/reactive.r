get_data <- reactive({
  
  # variables
  start_date <- input$dateRange[1]
  end_date <- input$dateRange[2]
  
  # data frames
  requests <- subset(data, the_date >= start_date & the_date < end_date)
  
  info <- list(calls = calls)
  
  return(info)
  
})