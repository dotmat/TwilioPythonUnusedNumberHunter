# This scripts jobs is to: 
# Get the list of phone numbers for an account, Get the list of call logs for a certain date period
# Compare the phone numbers against the call list to see what numbers have not been used in that period
# Present back to the user, the list of 'unused numbers'

# Imports
import sys, getopt
from twilio.rest import TwilioRestClient 
import datetime
import itertools
import re
import hashlib
from collections import defaultdict
import os
import gc
import json

# Create a dictionary, for phone numbers to be hashed
phoneNumberDictionary = {}
unusedSIDdictionary = []

# Put Accountsid, AuthKey

AccountSID = "AC..."
AuthKey = "ABC123XXX..."

NummberOfCallRecordsToExamine = 100 # How many calls should we examine. Please adjust this as you need to.
# NOTE, It typically takes about 8 hours to get details on 1,000,000 records so be sure to take that into account.

print 'Getting details for Account: ' + AccountSID

# Part One, we need to get all the phone numbers for an account.
# This involves making an API request, paging all the phone number pages and saving all the numbers into a text file for use later.

print 'Gathering Phone numbers for this account, the start time is: ' + str(datetime.datetime.now().time())

client = TwilioRestClient(AccountSID, AuthKey)
 
phoneNumbers = client.phone_numbers.iter()
 
#for each number in the account, write the number to a new line
with open("TwilioNumbersInAccount.txt", "w") as text_file:
    for p in phoneNumbers:
        twilioPhoneNumber = p.phone_number.replace("+","")
        phoneNumberDictionary[int(twilioPhoneNumber)] = {'PhoneSID': p.sid, 'Frequency': 0}
        text_file.write(twilioPhoneNumber+":{'PhoneSID':'"+p.sid+"}\n")

print 'Gathered all the phone numbers, stop time is: ' + str(datetime.datetime.now().time())

# Part two involves getting the call data for a certain date range  
# Get the call logs from the account.

calls = client.calls.iter()

count = 0
try:
    while count < NummberOfCallRecordsToExamine:
        with open("TwilioCallLog.txt", "w") as text_file:
            print 'Gathering Call logs for this account, the start time is: ' + str(datetime.datetime.now().time())
            for c in calls:
            # Add each called and callerID to our callLogDictionary
                text_file.write(c.to+"\n")
                text_file.write(c.from_+"\n")
                count = count + 1
                gc.collect()
except:
    print 'An error occurred, managed to get ' + str(count) + ' numbers from the request.'
print 'Gathered all the call logs, stop time is: ' + str(datetime.datetime.now().time())

# Now we have all the call logs and all the numbers in the account.
# So we need to know if any of the numbers were NOT used to make or receive calls

print 'Scanning for matching phone numbers.'
# Load the callLog file and begin comparing each number against our phoneNumberDictionary
with open("TwilioCallLog.txt") as connectedNumbers:
    for line in connectedNumbers:
        #Each time we load a line, we want to compare this number with whats in the dictionary
        #If the number is in the dictionary, we want to add 1 to the value for that number.
        # We also need to strip the + symbol from the log
            line = line.replace("\n","")
            line = line.replace("+","")
            try:
                phoneNumberDictionary[int(line)]['Frequency'] += 1
            except KeyError:
                pass

# Now we have a dictionary of Phone numbers and the number of times those numbers have been used.
# As part of the dictionary, we also know which numbers have not been used.

# Create a new file consisting of unused numbers
with open("unusedTwilioNumbers.txt", "w") as text_file:
    for phoneNumber, inner_dict in phoneNumberDictionary.iteritems():
        if inner_dict['Frequency'] == 0:
            text_file.write(str(phoneNumber) + "," + inner_dict['PhoneSID'] + "\n")
            #print str(phoneNumber) + inner_dict['PhoneSID']
            #Add the PhoneNumberSID to the unusedSIDdictionary
            unusedSIDdictionary.append(inner_dict['PhoneSID'])

# Now we have a dictionary of PhoneNumberSID's that have not been used
# We want to report to the user they have X many unused numbers
print 'Found ' + str(len(unusedSIDdictionary)) + ' unused numbers in account ' + AccountSID

# Ask the user if we can remove these numbers from their account.
numberRemoveAnswer = raw_input("Should I delete these unused numbers from the account? Y or N ")
if (numberRemoveAnswer == 'Y') or (numberRemoveAnswer == 'y'):
    print 'Removing unwanted numbers from your account, this may take a while...'
    for NumberSIDToRemove in unusedSIDdictionary:
        print 'Removing ' + NumberSIDToRemove
        client.phone_numbers.delete(NumberSIDToRemove)

    print 'Finished removing unused numbers'
print 'Script Finished running at: '+ str(datetime.datetime.now().time())
