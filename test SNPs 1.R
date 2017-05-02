rm(list = ls())
library(swfscMisc)
library(rmetasim)
library(strataG)
library(parallel)
library(tidyverse)

source("simulateSNPS.R")
source("summarizeSims.R")
source("rms funcs.R")

folder <- simulateSNPs()
summarizeSims(folder)
