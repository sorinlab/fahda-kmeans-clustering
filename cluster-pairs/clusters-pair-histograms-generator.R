cluster_pair_histo_maker <- function(filename1, filename2)
{
	# read cluster file
	a = read.table(filename1, sep="\t")
	b = read.table(filename2, sep="\t")
	library(ggplot2) # library for parcoord function
	
	# loop through the dimensions (first 7 columns)
	for ( d in 1:7 ) {
		dim_i = a[,d]
		dim_j = b[,d]
		# ensure that dim_i and dim_j have the same length
		# by filling the shorter one with NA's
		max_len = max(length(dim_i), length(dim_j))
		if (length(dim_i) > length(dim_j)) {
			dim_j = c(dim_j, rep(NA, max_len - length(dim_j)))
		} else {
			dim_i = c(dim_i, rep(NA, max_len - length(dim_i)))
		}
		# make data frame
		dim_i = data.frame(rep(filename1, length(dim_i)), dim_i)
		dim_j = data.frame(rep(filename2, length(dim_j)), dim_j)
		names(dim_i) = c("ID", "Dim")
		names(dim_j) = c("ID", "Dim")
		dim_pair = rbind(dim_i, dim_j)
		
		# generator plots
		output = paste(sub(".cluster","", filename1),"-",
					   sub(".cluster","", filename2), "-", d, ".png", sep="")
		png(filename=output)
		print({
			ggplot(dim_pair, aes(x=Dim, fill=ID)) +
				geom_histogram(binwidth=0.3, alpha=0.5, position="identity") +
				theme(
					axis.title = element_blank() # Removes y-axis title
			#		axis.text = element_blank()  # Removes y-axis texts
					# axis.ticks.y = element_blank(), # Removes y-axis ticks
				)
		})
		
		dev.off()
	} # end of loop
}

run = function()
{
	WD <- getwd()
	for (dir in 1:110)
	{
		setwd(dir)
		
		# print(paste("Starting working directory: ",cwd) )
		files = readLines(pipe("ls | grep cluster"))
		print(files)
		
		for (i in 1:length(files)) 
		{
			for (j in (i+1):length(files)) 
			{
				cluster_pair_histo_maker(files[i], files[j])
			} # End inner loop
		} # End outter loop

		setwd(WD)
	}	
}
