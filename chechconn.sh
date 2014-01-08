#!/bin/bash

# Directory where the connectors are installed
CONN_DIR='/opt/arcsight/connectors'
# Subdirectorory where the pid files are stored
PID_DIR='current/run'
#Subdirectory where the connectors log are
LOG_DIR='current/logs'
LOG_FILE='agent.out.wrapper.log'

# Print the hostname we are checking
echo
echo -e "\e[33m*********    `hostname`    *********\e[0m"

# Check the connectors installed, and their status
for c in ${CONN_DIR}/*
do
    echo
    #Show name of the connector installed
    conn_name=`basename $c`
    echo -e "\t\e[32m--> $conn_name <--\e[0m"
    
    # Check the pid file
    pid_file=`ls ${CONN_DIR}/${conn_name}/${PID_DIR}/*.pid 2>/dev/null |grep -v java`
    # if ls doesn't get anything, it throws a RC of 1
    # A 0 value means a pid file has been found
    pid_status=$? 
    # echo $pid_file
    
    # If the pid file is not found, then there is something wrong
    # with the connector
    if [[ ! -f $pid_file ]]; then
        echo -e "\t\t\e[91m*** [ERROR] We cannot find the PID file for the connector!!! ***\e[0m"
        echo -e "\t\t\e[91m*** Please, check connector status!!! ***\e[0m"
        echo
        continue
    else
        #Show location of the PID file
        echo -e "\t* PID file is located at $pid_file"
        # Show the timestamp of the PID file
        time_start=`ls -l $pid_file | cut -d" " -f5-9`
        echo -e "\t* According to PID file, start time of the connector seems to be $time_start"
        #Check the process is running
        pid_number=`cat $pid_file`
        ps_out=`ps aux |grep $(cat $pid_file)|grep -v grep |grep $(basename $pid_file)`
        ps_rc=$?
        #If process is not running with that PID, or it is assigned to another process,
        # throw an error, and check the next connector.
        if [[ $ps_rc != 0 ]];then
            echo -e "\t\t\e[91m*** [ERROR] Process not found. ***\e[0m"
            echo -e "\t\t\e[91m*** Please, check connector status. ***\e[0m"
            echo
            continue
        fi
        # Show some PID and process output
        echo -e "\t* Process seems to be running with PID `cat $pid_file`."
        echo -e "\t* ps output for that PID is:"
        echo -e "\t\t $ps_out"
        echo
                # Check the Eps throughput
        echo 
        echo -e "\t* Last EPS count"
        grep "{Eps" -A +1 ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE} | tail -2
        echo
        # Check the logs
        echo -e "\t* Last 20 lines from ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE}:"
        tail -20 ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE}

        # Check errors in the log file
        echo 
        echo -e "\t* Errors in the log file"
        grep -i error ${CONN_DIR}/${conn_name}/${LOG_DIR}/${LOG_FILE}

    fi        
    
done
