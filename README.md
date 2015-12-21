Unused number hunter is Pyton based script to help you release (and save some $$$'s) on unused numbers that may be sitting in your Twilio account. 

If you are in the habbit of buying Twlio numbers, using them for a project and then not relasing them this script will be the tool for you. 

How to use: 
- Download the python script to a directory
- Ensure you have the Twilio Python helper library installed, you can find this at: https://github.com/twilio/twilio-python
- Edit the Accountsid, Authkey and number of call records you want to examine, saving the script.
- Run: python /directory/NumberHunter.py

What will happen:
 - NumberHunter will grab all the phone numbers from your Twilio account, storing the numbers in a txt file called: TwilioNumbersInAccount.txt
 - NumberHunter will grab a copy of the call records up to the number (default is 100) you want to examine. (Saved in TwilioCallLog.txt)
 - NumberHunter will compare numbers in your call log against your Twilio numbers
 - NumberHunter will save a copy of your unused numbers in a file called unusedTwilioNumbers.txt
 - NumberHunter will ask you if you want to release these numbers - If you select Y it WILL REMOVE these numbers from your account immediately. 
 
Happy Hunting!


# TwilioPythonUnusedNumberHunter
Python based script to search your account for unused numbers and release them.
