library(shiny)
library(ggplot2)
library(dplyr)
library(maps)
library(tidyr)

# Can't get year isolated in ObserveEvent
# Want "selected" to be on multiple lines


### Read in and Clean Data

# counties <- read.csv("data/evictionlab-us-counties.csv", stringsAsFactors = FALSE)
# 
# 
# # WA counties
# counties <- counties %>%
#   filter(parent.location == "Washington") %>% 
#   select(year, name, population, poverty.rate, rent.burden, eviction.rate)
# 
# years <- unique(counties$year)
# 
# eviction_rate_range <- range(counties$eviction.rate, na.rm = TRUE)


server <- function(input, output) {
  
  data <- reactiveValues()
  data$selected_county <- ""
  
  output$plot <- renderPlot({
    
    
    
    results_data <- counties[counties$year == input$year, ] 
    
    results_data <- results_data %>%
      filter(eviction.rate >= input$eviction_rate[1] & eviction.rate <= input$eviction_rate[2])
    
    ggplot(data = results_data, mapping = aes(x = rent.burden, y = eviction.rate)) +
      geom_point(aes(color = (name %in% data$selected_county)), size = 3) +
      guides(color = FALSE) +
      labs(title = "Relationship Between Rent Burden and Eviction Rate") +
      
      xlab("Rent Burden") +
      ylab("Eviction Rate") +
      theme(plot.title = element_text(size = 20), 
            axis.title.x = element_text(size = 15),  
            axis.title.y = element_text(size = 15)) 
    
    
  })
  
  output$table <- renderDataTable({
    results_data <- counties[counties$year == input$year, ]
    
    results_data <- results_data %>%
      filter(eviction.rate >= input$eviction_rate[1] & eviction.rate <= input$eviction_rate[2])
    
    results_data
    
    
  })
  
  output$selected_year_plot <- renderText({input$year})
  output$selected_year_table <- renderText({input$year})
  
  
  output$selected <- renderText({
    data$selected_county
    
  })
  
  observeEvent(input$plot_brush, {
    selected <- brushedPoints(counties, input$plot_brush)
    selected <- filter(selected, year == input$year)
    selected <- as.vector(selected)
    
    
    
    data$selected_county <-
      paste(selected[2], 
            "Population: ", selected[3],
            "Poverty Rate: ", selected[4],
            "Rent Burden: ", selected[5], 
            "Eviction Rate: ", selected[6])
    
  })
  
  
  
}

#shinyServer(server)