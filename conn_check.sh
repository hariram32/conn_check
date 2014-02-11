#!/bin/bash

# Script that checks the status of the connectors installed on the machine:
# PID file, running state, last EPS count, last log lines, errors logged,
#     log rotation.
#
# Author: Francisco Javier Castilla
#
# Control change:
# v1.0    11/02/2014    FJC    Initial script
#


# Definition of the script's usage
usage() {
	echo "Usage: ${0} [-t|-h]"
	echo -e "\t -t: If you want to redirect the script to a file, this option will remove the special characters (no colors)."
	echo -e "\t -h: This help."
}

# Check number of arguments
if [ $# -gt 1 ] || [ "$1" == "-h" ]; then
	usage
	exit 1
fi

# Color variable definitions
if [ "$1" == "-t" ]; then
	RED=""
	GREEN=""
	YELLOW=""
	CLEAR=""
else
	RED="\e[91m"
	GREEN="\e[32m"
	YELLOW="\e[33m"
	CLEAR="\e[0m"
fi


# Directory where the connectors are installed
CONN_DIR='/opt/arcsight/connectors'
# Subdirectorory where the pid files are stored
PID_DIR='current/run'
#Subdirectory where the connectors log are
LOG_DIR='current/logs'
LOG_FILE='agent.out.wrapper.log'


# Print the hostname we are checking
echo
echo -e "${YELLOW}*********    HOSTNAME: `hostname`    *********${CLEAR}"

# Check all connectors installed under the main directory, and their status
for c in ${CONN_DIR}/*
do
    echo
    echo -e "${YELLOW}*********************************************************************************${CLEAR}"
    #Show name of the connector installed
    conn_name=`basename $c`
    echo -e "\t${GREEN}--> Connector Name: $conn_name <--${CLEAR}"
    
    # Check if the pid file is present
    pid_file=`ls ${CONN_DIR}/${conn_name}/${PID_DIR}/*.pid 2>/dev/null |grep -v java`
    # if ls doesn't get anything, it throws a RC of 1
    # A 0 value means a pid file has been found
    pid_status=$? 
    
    # If the pid file is not found, then there is something wrong
    # with the connector
    if [[ ! -f $pid_file ]]; then
        echo -e "\t\t${RED}*** [ERROR] We cannot find the PID file for the connector!!! ***${CLEAR}"
        echo -e "\t\t${RED}*** Please, check connector status!!! ***${CLEAR}"
        echo
		# get to the next connector in the list
        continue	
    else
        #Show location of the PID file
        echo -e "\t* PID file is located at"
		echo -e "\t\t${pid_file}"
        # Show the timestamp of the PID file
        time_start=`ls -l ${pid_file} | cut -d" " -f6-8`
        echo -e "\t* According to PID file, start time of the connector seems to be ${time_start}"
        #Check the process is running
        pid_number=`cat ${pid_file}`
        ps_out=`ps aux |grep $(cat ${pid_file})|grep -v grep |grep $(basename ${pid_file})`
        ps_rc=$?
        #If process is not running with that PID, or it is assigned to another process,
        # throw an error, and check the next connector.
        if [[ $ps_rc != 0 ]];then
            echo -e "\t\t${RED}*** [ERROR] Process not found. ***${CLEAR}"
            echo -e "\t\t${RED}*** Please, check connector status. ***${CLEAR}"
            echo
            continue
        fi
        # Show some PID and process output
        echo -e "\t* Process seems to be running with PID `cat ${pid_file}`."
        echo -e "\t* ps output for that PID is:"
        echo -e "\t\t ${ps_out}"
        echo
                # Check the Eps throughput
        echo 
        echo -e "\t* ${GREEN}Last EPS count${CLEAR}"
        grep "{Eps" -A +1 ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE} | tail -2 
        echo
        # Check the logs
        echo -e "\t* Last 20 lines from ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE}:"
        tail -20 ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE}

        # Check errors in the log file
        echo 
        echo -e "\t* Errors in the log file"
        grep -i error ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE}
	echo

	# Check if there are logs rotated
	echo -e "\t* Are there any logs rotated?"
	grep -i rotated ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE} | tail -10
	echo
    fi        
    
done