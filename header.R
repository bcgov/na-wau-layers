


#update with file of interest
spatialOutDir <- "out/"
layer_file <- file.path("data/old-growth/Map1_PriorityDeferral_2021_10_24.shp")
out_dir <- file.path("out/old-growth/")
dir.create(out_dir)
element <- 'priority_old_growth'  #underscores only, used as a file name but also column name
