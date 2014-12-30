######################################
# Banking Union Preliminary Data Plots
# Christopher Gandrud
# 28 December 2014
######################################

# Set working directory. Change as needed.
setwd('/git_repositories/BankingUnionMaps/')

# Load packages
library(dplyr)
library(ggplot2)

#### Standardise data at 100 function ####
standardise100 <- function(data, variable, times){
    for (u in unique(data$country)){
        begin <- data[, variable][data[, 'year'] == times[[1]] & data[, 'country'] == u]
        for (i in times){
            increment <- data[, variable][data[, 'year'] == i & data[, 'country'] == u]
            data[, variable][data[, 'year'] == i & data[, 'country'] == u] <-
                (increment / begin) * 100
        }
    }
    return(data[, variable])
}

# Load data
main <- read.csv('csv/WorldBankData.csv', stringsAsFactors = FALSE)

#### Summarize data ####
ssm <- subset(main, membership == 3 | country == "United States")

main$domestic_credit_100 <- standardise100(main, variable = 'wdi_domestic_credit', 
                          times = 2007:2013)

main_domestic_credit <- select(main, country, year, membership, domestic_credit_100)

ssm_average <- main %>% filter(membership == 3) %>% group_by(year) %>%
                summarize(domestic_credit_100 = 
                          median(domestic_credit_100, na.rm = TRUE))
ssm_average$country <- "SSM Median" 
ssm_average$membership <- 3

main_domestic_credit <- rbind(main_domestic_credit, ssm_average)

main_domestic_credit$highlight <- 'Indv. European\n Countries'
main_domestic_credit$highlight[main_domestic_credit$country == 'SSM Median'] <- 'SSM Median'
main_domestic_credit$highlight[main_domestic_credit$country == 'United States'] <- 'United States'
main_domestic_credit$highlight[main_domestic_credit$country == 'Japan'] <- 'Japan'

main_domestic_credit$thickness <- 0
main_domestic_credit$thickness[main_domestic_credit$highlight != 'Indv. European\n Countries'] <- 1

ggplot(main_domestic_credit, 
       aes(year, domestic_credit_100, group = country, color = highlight, 
           size = thickness, alpha = thickness)) +
    geom_line() +
    scale_y_continuous(breaks = c(40, 80, 100, 120, 160)) +
    scale_color_manual(values = c('Indv. European\n Countries' = '#c7c7c7',
                                  'SSM Median' = '#3182bd',
                                  'United States' = '#e6550d',
                                  'Japan' = '#31a354')) +
    geom_hline(yintercept = 100, linetype = 'dotted') +
    scale_alpha(range = c(0.3, 1)) +
    guides(colour = guide_legend(override.aes = list(size = 2), title = NULL, reverse = TRUE),
        alpha = FALSE, size = FALSE) +
    xlab('') + ylab('Change in domestic credit provided by\n financial sector\n') +
    theme_bw(base_size = 15)
