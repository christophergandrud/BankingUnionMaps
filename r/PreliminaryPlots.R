######################################
# Banking Union Preliminary Data Plots
# Christopher Gandrud
# 4 January 2015
######################################

# Set working directory. Change as needed.
setwd('/git_repositories/BankingUnionMaps/')

# Load packages
library(dplyr)
library(ggplot2)
library(gridExtra)

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
main$domestic_credit_100 <- standardise100(main, variable = 'wdi_domestic_credit',
                          times = 2005:2013)

main_domestic_credit <- select(main, country, year, membership, domestic_credit_100)

ssm_average <- main %>% filter(membership == 'SSM') %>% group_by(year) %>%
                summarize(domestic_credit_100 =
                          median(domestic_credit_100, na.rm = TRUE))
ssm_average$country <- "SSM Median"
ssm_average$membership <- "SSM"

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

#### GDP Growth ####
gg_group <- function(data, group, variable) {
    temp <- subset(data, grouping == group)
    names(temp)[names(temp)==variable] <- "temp_var"

    ggplot(temp, aes(year, temp_var, group = country, color = country)) +
        geom_line() +
        geom_hline(yintercept = 0, linetype = 'dotted') +
        scale_colour_brewer(palette = "Paired") +
        xlab('') + ylab('') + ggtitle(group) +
        guides(color = guide_legend(title=NULL)) +
        theme_bw()
}

gdp <- list()
for (i in unique(main$grouping)){
    message(i)
    gdp[[i]] <- suppressMessages(gg_group(main, group = i,
                                          variable = 'wdi_gdp_growth'))
}

do.call(grid.arrange, gdp)

#### Capital/Assets ####
capital_assets <- list()
for (i in unique(main$grouping)){
    message(i)
    capital_assets[[i]] <- suppressMessages(gg_group(main, group = i,
        variable = 'wdi_capital_assets'))
}

png(file = 'figures/capital_assets_ratio.png', width = 1250, height=750)
    do.call(grid.arrange, capital_assets)
dev.off()


#### NPL Ratio ####
npl <- list()
for (i in unique(main$grouping)){
    message(i)
    npl[[i]] <- suppressMessages(gg_group(main, group = i,
                                          variable = 'wdi_npl_ratio'))
}

do.call(grid.arrange, npl)

#### Domestic Credit Provided by the financial sector (% GDP) ####
credit <- list()
for (i in unique(main$grouping)){
    message(i)
    credit[[i]] <- suppressMessages(gg_group(main, group = i,
                                          variable = 'wdi_domestic_credit'))
}

do.call(grid.arrange, credit)

#### Liquid reserve ratio ####
liquid <- list()
for (i in unique(main$grouping)){
    message(i)
    liquid[[i]] <- suppressMessages(gg_group(main, group = i,
        variable = 'wdi_liquid_reserves_ratio'))
    }

do.call(grid.arrange, liquid)
