#####################
  # format data
#####################

# import
daily.logs <- read.csv("daily_logs.csv", stringsAsFactors = FALSE) # 13336 rows
app.metadata <- read.csv("app_metadata.csv", stringsAsFactors = FALSE) # 22 rows

# merge and remove NA
data <- merge(daily.logs, app.metadata, by = "client_id")
data <- data[complete.cases(data),] #260 rows lost

# format the_date
data$the_date <- as.Date(format(as.POSIXct(data$the_date, format='%m/%d/%y %H:%M'), format='%Y-%m-%d'))

# explode api_endpoint and clean up trailing '/'
data <- separate(data, api_endpoint, c("request_method", "api_version", "endpoint_method"), sep = "/", extra = "merge", remove = FALSE)
data$endpoint_method <- sub("/$", "", data$endpoint_method)

# one more endpoint_method cut at the root to figure out which are most used
data <- separate(data, endpoint_method, c("endpoint_root"), sep = "/", remove = FALSE)


################################
  # exploratory data analysis
################################

# View(data)

# length(unique(data$api_endpoint)) #57
# length(unique(data$request_method)) #4
# length(unique(data$endpoint_method)) #38
# length(unique(data$application_name)) #22
# length(unique(data$application_author)) #4


# # pareto charts #
# df <- count(data, "request_method")
# request.pareto <- as.numeric(df[,2])
# names(request.pareto) <- df[,1]
# pareto.chart(request.pareto, ylab = "API Calls")
# 
# 
# df <- count(data, "application_author")
# author.pareto <- as.numeric(df[,2])
# names(author.pareto) <- df[,1]
# pareto.chart(author.pareto, ylab = "Developer")
# 
# 
# df <- sqldf("select application_author,
#                     count(distinct application_name) freq
#              from data
#              group by application_author")
# author.app.pareto <- as.numeric(df[,2])
# names(author.app.pareto) <- df[,1]
# pareto.chart(author.app.pareto, ylab = "Apps")
# 
# sum(df$freq)
# df <- count(data, "application_name")
# app.pareto <- as.numeric(df[,2])
# names(app.pareto) <- df[,1]
# pareto.chart(app.pareto, ylab = "App Name")
# 
# 
# df <- count(data, "endpoint_method")
# endpoint.pareto <- as.numeric(df[,2])
# names(endpoint.pareto) <- df[,1]
# pareto.chart(endpoint.pareto, ylab = "Endpoint Method")
# 
# #channels, streams, user, users make up 80%
# df <- count(data, "endpoint_root")
# root.pareto <- as.numeric(df[,2])
# names(root.pareto) <- df[,1]
# pareto.chart(root.pareto, ylab = "Endpoint Root")
# #channels, streams, user, users make up 80%, user/users combined in
# 
# 
# # relationship between avg_latency and num_requests?
# pairs(~avg_latency + num_requests, data)
# cor(data$num_requests, data$avg_latency) # -0.05


# # endpoint request total distribution by developer
# df <- aggregate(num_requests ~ application_author + endpoint_method,
#                 data = data,
#                 FUN = sum)
# ggplot(df, aes(x = endpoint_method, y=num_requests, fill = application_author)) +
#   geom_bar(stat = 'identity') +
#   coord_flip()


# endpoint request row count by developer
# get a sense of endpoint usage by developer
# ggplot(data, aes(x = endpoint_method, fill = application_author)) +
#   geom_bar() +
#   coord_flip()

# which specific endpoints are used by everyone?
# sqldf(" select endpoint_method
#         from ( select distinct application_author, endpoint_method
#                from data ) a
#         group by endpoint_method
#         having count(distinct application_author) = 4")


# #formula for removing NaN
# is.nan.data.frame <- function(x){
#   do.call(cbind, lapply(x, is.nan))
# }

