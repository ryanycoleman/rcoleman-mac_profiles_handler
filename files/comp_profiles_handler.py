#!/usr/bin/python2.6
# -*- coding: utf-8 -*-#

# Hakan Hagenrud
# 2012-01-18

import os
import sys
import subprocess
import Foundation
import plistlib

#Location of profiles
proFiles = '/usr/local/comp_profiles/'
#Completed list of profiles that need to be installed
profilesToInstall = []
#List of profiles in the above mentioned directory
profilesToCheck = []

#Log funciton, unique for Apple computers, you will need to change this on other platforms.
def log(s):
	Foundation.NSLog( "se.hger.profiles_handler: %s" % str(s) )
	#print( "se.hger.profiles_handler: %s" % str(s) )

#Takes a list of files and installs them into the machine (not user)
def installProfiles(profilesToInstall):
	for allprofiles in profilesToInstall:
		try:
			command = subprocess.Popen (['/usr/bin/profiles', '-I', '-f', '-F', allprofiles], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
			command.wait()
			if command.returncode == 0:
				log(('INFO Added ') + allprofiles + (' with success'))
			elif command.returncode == 1:
				log(('ERROR Had problem with ') + allprofiles)
		except OSError, orsak:
			log('Reason:', orsak)
			log('Error number (OSError):', orsak.errno)

#Gets a list of files to check to see if they are installed
#Will also use the same lists to determine if a profile needs to be removed
def isthereinstalledProfiles(profilesToCheck):
	#Many lists to use in function
	installedProfilesID = []
	installedProfilesFiles = []
	profileToRemove = []
	#This command lists the installed _computerlevel profiles installed and gets the unique ID string
	for profiles in (os.popen('/usr/bin/profiles -C').readlines()):
		if (profiles.strip()).startswith('_computerlevel'):
			installedProfilesID.append(profiles.strip().split().pop())
	#This loop checks for the unique ID string in the directory specified above
	for id in installedProfilesID:
		try:
			command = subprocess.Popen (['/usr/bin/grep', '-r', '-l', id, proFiles], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
			command.wait()
			profile = command.communicate()[0].strip()
			#If there is a hit on the ID in the directory, append that file to a list
			if command.returncode == 0:
				installedProfilesFiles.append(profile)
			elif command.returncode == 1:
				profileToRemove.append(id)
		except OSError, orsak:
			log('Reason:', orsak)
			log('Error number (OSError):', orsak.errno)
	#If there are anyting in the list created above, some of the profiles are installed, and if so create a new list
	#that contains the files that are not listed as installed
	for files in profilesToCheck:
		if not files in installedProfilesFiles:
			profilesToInstall.append(files)
			log('INFO will install ' + files)
	if not profilesToInstall:
		log('INFO all profiles already installed, doing nothing')
	if profileToRemove:
		for profiles in profileToRemove:
			if profiles.endswith('_handler'):
				try:
					command = subprocess.Popen (['/usr/bin/profiles', '-R', '-p', profiles], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
					command.wait()
					#If there is a hit on the ID in the directory, append that file to a list
					if command.returncode == 0:
						log('INFO removed profile with ID: ' + profiles + ' with success')
					else:
						log('ERROR profile with ID: ' + profiles + ' was not removed')
				except OSError, orsak:
					log('Reason:', orsak)
					log('Error number (OSError):', orsak.errno)
	else:
		log('INFO no profiles to remove, continuing')
	return profilesToInstall

#Meaningless check to see if the direcory exists and if not create it
if not os.path.exists(proFiles):
	os.popen('/bin/mkdir ' + proFiles)
	os.popen('/bin/chmod 755 ' + proFiles)
	log('Configured system for managed profiles')
	raise SystemExit(666)

#Populate list of profiles in the directory to iterate over later
for profiles in (os.listdir(proFiles)):
	profilesToCheck.append(proFiles + profiles)

#The command below returns 0 if profiles are installed and 16 if not.
#so if there are profiles installed check and determen which to install
#if not just install them
try:
	command = subprocess.Popen (['/usr/bin/profiles', '-H'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	command.wait()
	if command.returncode == 0:
		log('INFO profiles installed, determinig what profiles to install')
		profilesToInstall = isthereinstalledProfiles(profilesToCheck)
		installProfiles(profilesToInstall)
	elif command.returncode == 16:
		log('No profiles installed, installing')
		installProfiles(profilesToCheck)
except OSError, orsak:
	log('Reason:', orsak)
	log('Error number (OSError):', orsak.errno)


