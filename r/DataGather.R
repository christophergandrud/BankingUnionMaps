######################################
# Banking Union Data Gathering
# Christopher Gandrud
# 4 January 2015
######################################

# Set working directory. Change as needed.
setwd('/git_repositories/BankingUnionMaps/')

# Load packages
library(dplyr)
library(WDI)
library(DataCombine)

# Load data set of Banking Union Membership
membership <- read.csv('csv/BankingUnionMembers.csv', stringsAsFactors = FALSE)

#### Gather data from the World Bank Development Indicators ####
# GDP growth (annual %): NY.GDP.MKTP.KD.ZG
# NPLs/Performing : FB.AST.NPER.ZS
# Risk premium on lending (lending rate minus treasury bill rate, %): FR.INR.RISK
# Domestic credit provided by financial sector (% of GDP): FS.AST.DOMS.GD.ZS
# Bank liquid reserves to bank assets ratio (%): FD.RES.LIQU.AS.ZS

countries <- membership$iso2c

wdi_indicators <- c('NY.GDP.MKTP.KD.ZG', 'FB.AST.NPER.ZS', 'FR.INR.RISK', 
                    'FS.AST.DOMS.GD.ZS', 'FD.RES.LIQU.AS.ZS')

wdi <- WDI(country = countries, indicator = wdi_indicators, 
           start = 2005, end = 2013)

wdi <- rename(wdi, wdi_gdp_growth = NY.GDP.MKTP.KD.ZG, 
              wdi_npl_ratio = FB.AST.NPER.ZS, 
              wdi_risk_premium_lending = FR.INR.RISK,
              wdi_domestic_credit = FS.AST.DOMS.GD.ZS,
              wdi_liquid_reserves_ratio = FD.RES.LIQU.AS.ZS
              )

# Combine with membership data, NOTE: membership as of 1 January 2015
wdi<- inner_join(wdi, membership[, -1], by = 'iso2c') %>%
        MoveFront(c('country', 'iso2c', 'id', 'year', 'membership'))

write.csv(wdi, file = 'csv/WorldBankData.csv', row.names = FALSE)

#### ECB Consolidated Banking Data
# http://www.ecb.europa.eu/stats/money/consolidated/html/index.en.html
