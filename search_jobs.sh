#!/bin/bash

#################################################################################
#Functions (do not modify anything here)
#################################################################################
SEARCH_SKILLS=""

function search_jobs
{
	SEARCH_NAME=${1}
	perl craigslist.pl ${SEARCH_SKILLS}> raw_data.txt

	#create the header of an html file
	echo "<html><title>Job Search Results</title><body>" > job_data.html

	#sort the entire file contents and make sure the best matches are on top
	sort -t! -n -r -k3 raw_data.txt >> job_data.html

	#clean up the file
	perl -p -i -e "s/!/\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;/g" job_data.html

	#terminate the html file
	echo "</body></html>" >> job_data.html
	
	mv job_data.html ${SEARCH_NAME}.html
	rm -f raw_data.txt	
}

#################################################################################
#You may modify your skills below
#################################################################################
SEARCH_SKILLS="embedded, circuit, transistor, VLSI, firmware, RTOS, kernel, MacOSX, JTAG, oscilloscope, HDL, FPGA, Arduino, MSP430, OMAP3540, micro-controllers, microcontrollers, SVN, programmer, Perl, linux, Mathematica, LabVIEW, schematics, Verilog, VHDL"
SEARCH_NAME="engineering"
search_jobs ${SEARCH_NAME}

SEARCH_SKILLS="quantitative, mathematica, finance, programmer, developer, high-frequency, fpga, microcontroller"
SEARCH_NAME="finance"
search_jobs ${SEARCH_NAME}