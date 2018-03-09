####################
  # format data
####################

# import
daily.logs <- read.csv("daily_logs.csv", stringsAsFactors = FALSE)
app.metadata <- read.csv("app_metadata.csv", stringsAsFactors = FALSE)

# merge
data <- merge(daily.logs, app.metadata, by = "client_id")

# format the_date column
data$the_date <- as.Date(format(as.POSIXct(data$the_date, format='%m/%d/%y %H:%M'), format='%Y-%m-%d'))

# explode api_endpoint column
data <- separate(data, api_endpoint, c("request_method", "api_version", "endpoint_method"), sep = "/", extra = "merge")

# clean up endpoint method for better grouping (remove trailing '/')



################################
  # exploratory data analysis
################################

View(data)

# counts
length(unique(data$endpoint_method)) # 42
length(unique(data$application_name))  # 22
length(unique(data$application_author)) # 4

# app version counts
app.version <- count(data, c("application_author", "application_name", "api_version"))
app.version[order(-app.version$freq), ]


# histogram - endpoint method
endpoint.methods <- count(data, "endpoint_method")

ggplot(endpoint.methods) +
  geom_bar(aes(reorder(endpoint_method, freq), freq), stat="identity") +
  labs(x="endpoint method") +
  coord_flip()


# stacked bar - endpoint method ~ application author
endpoint.methods.author <- count(data, c("endpoint_method", "application_author"))

ggplot(endpoint.methods.author) +
  geom_bar(aes(reorder(endpoint_method, freq), freq, fill = application_author), stat="identity") +
  labs(x="endpoint method") +
  coord_flip()

# which endpoint_methods are used by all four application authors?
sqldf("select endpoint_method
       from data
       group by endpoint_method
       having count(distinct application_author) = 4")

# which applications use the most endpoint methods?
app.endpoint <- sqldf("select application_author, application_name, count(distinct endpoint_method) cnt
                       from data
                       group by application_author, application_name")

app.endpoint[order(-app.endpoint$cnt), ]



# latency
summary(data$avg_latency)

# boxplot - avg_latency ~ endpoint_method
ggplot(data, aes(endpoint_method, avg_latency))+
  geom_boxplot() +
  coord_flip()


# boxplot - avg_latency ~ application_author
ggplot(data, aes(application_author, avg_latency))+
  geom_boxplot() +
  coord_flip()

# meh
ggplot(data, aes(x = avg_latency, fill = application_author)) +
  geom_histogram() +
  scale_x_continuous(lim=c(0,600))