# ADInsight
This tool/script that can gather a lot of info without any defender alerts since it leverages the built-in windows ADModule. It is useful for Penetration testers, SOC Analysts or System administrators depends how they use it.

Pentesters can use it for enumeration purposes, finding Kerberoastable, AsRepRoastable accounts if they've initial access to domain joined PC

SOC analyst or administrators can use since they're on defending side, to identify SPN associated service accounts, accounts with the property set "do not require Kerberos pre-authentication", to get a list of their windows servers (old/new) etc., again depends how they use it.

**Example Use:**
.\ADInsight.ps1

![image](https://github.com/user-attachments/assets/de1ef86b-2420-4fbc-a0d0-e27d197392d1)


**Note:** Running it first time, you may need to run below command for powershell execution policy bypass before you execute the script:
powershell -ep bypass
