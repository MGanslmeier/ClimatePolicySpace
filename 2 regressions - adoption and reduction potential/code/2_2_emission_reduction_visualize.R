setwd("~/Dropbox/ClimatePossibilitySpace2/replication/Github/regressions")
pacman::p_load(plyr, dplyr, tidytext, foreign, haven, countrycode, stringr, e1071,
               ggplot2, tidyr, plotly, ggthemes, gridExtra, grid, spatialEco, 
               gmodels, tidymodels, openxlsx, wbstats, rvest, readr, readxl)
rm(list = ls())

###

# LOAD VARIABLE LABELS
labels <- read_excel('data/policy_cat_labels.xlsx') %>% 
  set_names('independent', 'labels') %>% 
  mutate(independent = str_sub(independent, 1, 23))

###

# function to extract coefficients
StarCounter <- function(path){
  
  # get all file paths and define objects
  files <- list.files(path, full.names = T, recursive = T) %>% subset(.,grepl('.txt',.)) %>% subset(., grepl('wo_pval', .))
  df <- data.frame(stringsAsFactors = F)
  
  # load files and reshape
  for(i in 1:length(files)){
    temp <- read.delim(files[i], header = FALSE)
    index <- temp %>% subset(., V1 == 'Observations' | V1 == 'VARIABLES') %>% row.names(.) %>% as.numeric(.) %>% sort(.)
    colnames(temp) <- t(temp[index[1],])[,1] %>% as.character(.) %>% make.names(., unique = T)
    temp <- temp[(index[1]+2):(index[2]-2), ] %>% as.data.frame() %>%
      mutate(VARIABLES = replace(VARIABLES, VARIABLES == '', NA)) %>%
      fill(VARIABLES, .direction = 'down') %>%
      gather(., dependent, coeff, -VARIABLES) %>%
      dplyr::rename(independent = VARIABLES) %>%
      mutate(type = case_when(grepl('\\(', coeff) ~ 'se', T ~ 'coef')) %>%
      subset(., coeff != '') %>%
      spread(., type, coeff) %>%
      mutate(filename = basename(files[i])) %>%
      mutate(dependent = gsub("\\..*", "", dependent))
    df <- rbind.fill(df, temp)
  }
  res <- df %>%
    mutate(coef = coef %>% gsub('\\*', '', .) %>% as.numeric(),
           se = se %>% gsub('\\(|\\)', '', .) %>% as.numeric()) %>%
    mutate(cil95 = coef-(1.960*se), ciu95 = coef+(1.960*se),
           cil99 = coef-(2.576*se), ciu99 = coef+(2.576*se)) %>%
    rename(estimate = coef)
  return(res)
}

df <- StarCounter(path = 'results') %>%
  subset(., str_sub(independent, 1, 4) == 'L.P_') %>%
  mutate(independent = gsub('L.P_', '', independent)) %>%
  separate(., col = 'independent', into = c('independent', 'duration'), sep = '_') %>%
  mutate(duration = case_when(duration == 'CmY3R' ~ 'stock of older policies (long-term)', 
                              T ~ 'stock of policies in last 3 years (short-term)')) %>%
  mutate(dependent = case_when(dependent == 'lnco2' ~ '(log) CO2 emissions per unit of economic output (MtCO2e/GDP)', 
                               T ~ '(log) other greenhouse emissions per unit of economic output (MtCO2e/GDP)')) %>%
  left_join(., labels, by = 'independent') %>%
  mutate(independent = labels)

###

# CREATE COEFFICIENT PLOT
plot_df <- df %>% subset(., filename == 'figure2_&_table_S6_1_wo_pval.txt')
ggplot() +
  geom_vline(xintercept = c(0)) +
  geom_linerange(data = plot_df, aes(xmin = cil95, xmax = ciu95, y = reorder(independent, -estimate), color = duration), 
                 linewidth = 1.5, position = position_dodge(width = 0), alpha = 1) +
  geom_linerange(data = plot_df, aes(xmin = cil99, xmax = ciu99, y = reorder(independent, -estimate), color = duration), 
                 linewidth = 0.75, position = position_dodge(width = 0), alpha = 1) +
  geom_point(data = plot_df, aes(x = estimate, y = reorder(independent, -estimate), color = duration), 
             size = 2, stroke = 1.5, position = position_dodge(width = 0), fill = 'white') +
  ggsci::scale_color_jama() +
  xlab('treatment effect (coefficient size)') + ylab('independent variable') +
  ggtitle('Effect of number of policies on emission reduction', subtitle = 'two-way fixed effects and controls included') +
  guides(col = guide_legend(nrow = 1, byrow = TRUE, reverse = T),
         shape = guide_legend(nrow = 1, byrow = TRUE, reverse = T)) +
  theme_bw() + theme(legend.title = element_blank(), legend.position = 'bottom') +
  facet_wrap(~dependent, scales = 'free_x', ncol = 1)
ggsave('results/figure2.png', width = 10, height = 8)
ggsave('results/figure2.eps', width = 10, height = 8)
