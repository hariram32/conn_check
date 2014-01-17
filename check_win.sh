#!/bin/bash
#
# Check wintel connector files and destinations

# Directory where the connectors are installed
CONN_DIR='/opt/arcsight/connectors'
# subdirectory where the config files are
CONFIG_DIR='current/user/agent'

# Print the hostname we are checking
echo
echo -e "\e[33m*********    `hostname`    *********\e[0m"

# Check directories where WINTEL connectors are installed
for c in ${CONN_DIR}/wintel*
do
    echo
    # Show connector name
    echo -e " --> $c <--"
    # Check if the agent.properties file is present
    if [[ ! -f ${CONN_DIR}/${c}/${CONFIG_DIR}/agent.properties ]]; then
        echo -e "\t\t e[91m*** [ERROR] This connector has no agent.properties \e[0m"
        echo -e "\t\t e[91m*** Please, check if this connector is properly installed ***\e[0m"
        echo
        continue
    else
        # Once the file agent.properties is present, check the servers assigned and the destinations
        # Check servers assigned to the connector
        grep -e "agents\[[0-9]*\].windowshoststable\[[0-9]*\].[hostname|windowsversion]" ${CONN_DIR}/${c}/${CONFIG_DIR}/agent.properties
        
        # Check for destinations, and loop them
        dest_array=`grep -i agentid ${CONN_DIR}/${c}/${CONFIG_DIR}/agent.properties`
        for dest in $dest_array
        do
            # get the name of the destination, and add the xml extension
            dest_name=`echo $dest | cut -d'=' -f2-`
            xml_name=${dest_name}.xml
            
            
            
        done
    fi
done