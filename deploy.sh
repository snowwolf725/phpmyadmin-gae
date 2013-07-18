#!/bin/bash

set -e

SCRIPT_PATH=$(realpath $(dirname $0))

collectApplicationId()
{
	read -p "Please enter your Application Id: " applicationId
	if [ "$applicationId" != '' ]; then
		true
	else
		false
	fi
}

collectDatabaseInstanceName()
{
	read -p "Please enter your Database Instance name: " databaseInstanceName
	if [ "$databaseInstanceName" != '' ]; then
		true
	else
		false
	fi
}

replaceDeploymentPlaceHolders()
{
	checkoutModifiedFiles

	echo "Replacing <project-id> <database-instance-id>"

	sed -i'' s/\<project-id\>/$applicationId/g $SCRIPT_PATH/app.yaml 2>&1
	sed -i'' s/\<project-id\>/$applicationId/g $SCRIPT_PATH/phpMyAdmin/config.inc.php 2>&1
	sed -i'' s/\<database-instance-id\>/$databaseInstanceName/g $SCRIPT_PATH/phpMyAdmin/config.inc.php 2>&1
	if [ $? = 0 ]; then
		true
	else
		false
	fi
}

checkoutModifiedFiles()
{
	git checkout app.yaml phpMyAdmin/config.inc.php
}


deployToAppEngine()
{
	appcfg.py -v -R update .
}

deployApplicationToAppEngine()
{
	if collectApplicationId && collectDatabaseInstanceName; then
		echo "Deploying to $applicationId with Database instance $databaseInstanceName"
		if ! replaceDeploymentPlaceHolders; then
			echo "Failed to replace place-holders" && exit 1
		fi
		if ! deployToAppEngine; then
			echo "Failed to Deploy to AppEngine" && exit 1
		fi

		checkoutModifiedFiles
	else
		echo "Failed Deploying"
	fi
}


while true; do
    read -p "Do you wish to deploy phpmyadmin to your App Engine account? [y/n]: " yn
    case $yn in
        [Yy]* ) deployApplicationToAppEngine; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


