#!/bin/csh -f

#get metservice wind data from geonet inward ftp server
#three files, one for each model
#file times 0630 and 1830
#gns_wind_model_data_ecmwf_20111213_0630.txt
#gns_wind_model_data_gfs_20111213_0630.txt
#gns_wind_model_data_ukmo_20111213_0630.txt

set usc = _

#set default directories and filenames, etc
set temp_dir = /home/volcano/programs/new_ashfall
set source_machine = inward.geonet.org.nz
set data_directory = /home/volcano/data/new_ashfall

foreach model (ecmwf gfs ukmo)
	foreach time (0630 1830)

		set met_file = gns_wind_model_data_$model$usc`/bin/date +%Y%m%d`_$time.txt
		set wind_file = $data_directory/$met_file
		echo $met_file
		#echo $wind_file

		#ping source_machine to check alive before ftp
		/bin/ping $source_machine -c 5 > /dev/null    # ping timeout 5 sec
		if ($status != 0) then                          # dead so exit
			echo cannot talk to $source_machine
			exit 1
		endif

		#do the ftp
		echo open $source_machine >! $temp_dir/ftpfile
		echo ascii >> $temp_dir/ftpfile
		echo get $met_file $wind_file >> $temp_dir/ftpfile
		ftp < $temp_dir/ftpfile
		\rm $temp_dir/ftpfile

		#check if wind_file exists on local machine, if so delete met_file on remote machine
		if (-e $wind_file) then
			echo open $source_machine  >! $temp_dir/ftpfile
			echo del $met_file >> $temp_dir/ftpfile
			ftp < $temp_dir/ftpfile
			\rm $temp_dir/ftpfile
		endif

		nextloop:
	end
end
