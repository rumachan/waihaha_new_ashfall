#!/bin/csh
#run_all.csh

#run all three ashfall components

set hour = `date +%H`
if ($hour == "06") then
	set when = 0630
endif
if ($hour == "18") then
	set when = 1830
endif

/home/volcano/programs/new_ashfall/getwind.csh

/home/volcano/programs/new_ashfall/ashfall.csh $when

/home/volcano/programs/new_ashfall/web_post.csh
