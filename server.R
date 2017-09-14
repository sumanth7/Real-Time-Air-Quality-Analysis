library(jsonlite)
library(dplyr)
library(lubridate)
library(curl)
library(chron)
library(magrittr)
library(leaflet)

function(input, output, session) {
        transdata = function() {
                data <- fromJSON(
                        paste(readLines(
                                "https://android-hc05-app-arduino-c5f17.firebaseio.com/.json"), collapse=""))
                
                data <- as.data.frame(data, stringsAsFactors = FALSE)
                data <- as.data.frame(t(data), stringsAsFactors = FALSE)
                data <- add_rownames(data, "Time")
                data <- data[-(1:10), ]
                names(data) <- c("Time", "Values")
                
                ## Extract date and hour
                dat <- read.table(text = data$Time,
                                  sep = ".",
                                  col.names = c(
                                          "id", "2", "3", "4", "5", "6", "yr", "month", 
                                          "day", "st2", "hr", "min", "sec", "extra"),
                                  fill = TRUE)
                dat$id <- paste(dat$id, dat$X2, dat$X3, dat$X4, dat$X5, dat$X6, sep = ".")
                dat <- dat[, c("id", "yr","month","day", "hr", "min", "sec")]
                dat <- tail(dat, 210)
                
                ## Extract coordinates and choose the current location
                coord <- read.table(text = data$Values,
                                    sep = ",",
                                    col.names = c("t1", "t2", "PPM", "lng", "lat", "t6"),
                                    stringsAsFactors = FALSE, fill = TRUE)
                coord <- coord[, c("PPM", "lng", "lat")]
                coord <- tail(coord, 210)
                
                ## Convert to date and hour
                dat$Date <- as.Date(with(dat, paste(yr, month, day, sep = "-")), "%Y-%m-%d")
                hour <- c(paste(dat$hr, dat$min, dat$sec, sep = ":"))
                dat$Hour <- chron(times = hour)
                dat$Time <- as.POSIXct(paste(dat$Date, dat$Hour), format="%Y-%m-%d %H:%M:%S")
                
                ## change this logic
                
                ## Data frame for visualization
                sensor <- cbind(dat, coord)
                sensor <- sensor[, c("id", "Time", "PPM", "lng", "lat")]
                sensors <- sensor
                sensors <- sensors[complete.cases(sensors), ]
                sensors <- sensors %>% 
                        group_by(id) %>% slice(n()) %>%
                        ungroup()
                return(sensors)
        }
        
        output$map <- renderLeaflet({
                invalidateLater(60000)
                transdata() %>% 
                        leaflet() %>%
                        addTiles(
                                urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png" 
                                ) %>% 
                        addCircleMarkers(lat = ~lng, lng = ~lat, 
                                         popup = paste("ID:", transdata()$id, "<br>", 
                                                       "PPM:", transdata()$PPM, "<br>", 
                                                       "Time:", transdata()$Time),
                                         radius = 5, 
                                         color = "black", 
                                         stroke = FALSE, 
                                         fillOpacity = 0.8)
        })
        
}