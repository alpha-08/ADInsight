# Copyright (c) 2024 Shahzeb Haider
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

Write-Output "Desired files are being downloaded.."

# Downloaded files original source: https://github.com/samratashok/ADModule/blob/master/Import-ActiveDirectory.ps1

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/alpha-08/ADEnum/master/admod.ps1" -OutFile "admod.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/alpha-08/ADEnum/master/Microsoft.ActiveDirectory.Management.dll" -OutFile "Microsoft.ActiveDirectory.Management.dll"


Write-Output " "
Write-Output "Status: 200 OK"

# Dot-source the PowerShell script if it's a script file, not a module
# if you're importing a module manually, use command 'import-module -Name <moduleName>

. .\admod.ps1

# Load the DLL
Add-Type -Path .\Microsoft.ActiveDirectory.Management.dll

Write-Output " "
Write-Output "Status: 200 OK"
Write-Output ""

function Write-Bold {
    param (
        [string]$text
    )
    Write-Host $text -ForegroundColor Yellow
}


# Start the while loop
while ($true) {

    Write-Output "-------------------------------------------------------------------------------------------------------"

    Write-Bold "1. Forest Info"
    Write-Bold "2. Domain Controller Info"
    Write-Bold "3. Groups Info"
    Write-Bold "4. Group Members Info"
    Write-Bold "5. Kerberoastable Accounts"
    Write-Bold "6. ASReproastable Accounts"
    Write-Bold "7. All Computer Accounts Info"
    Write-Bold "8. All User Accounts Info"
    Write-Bold "9. All available Windows Servers Info"
    Write-Bold "10. All Users/Groups protected by AdminSDHolder"
    Write-Output "   Ctrl+C to exit"

    # Prompt user for input
    Write-Output " "
    Write-Bold "Select Option"
    $userInput = Read-Host -Prompt ">"
    Write-Output " "
    # Process user input
    switch ($userInput) {
        

        '1' {

            Write-Bold "Enter Forest name <xyz.com/edu> OR press Enter to go with the default info"
            $condition=Read-Host -Prompt ">"
            if ([string]::IsNullOrEmpty($condition)){

                $defaultForestInfo=Get-ADForest
                Write-Output $defaultForestInfo
                
            } else {
                
#                $getForestName = Read-Host -Prompt "Forest Name"
                
                try {
                    $ForestName=Get-ADForest -Identity $condition
                    Write-Output $ForestName
                } catch {
                    Write-Host "Error: Unable to retrieve forest information for $condition" -ForegroundColor Red
                }
             }
         }
        '2' {
            
            Write-Bold "Enter Domain Controller IP address OR press Enter to go with the default info"
            Read-Host -Prompt ">"
            Write-Host " "
            Write-Output "Fetching Domain Controller Info..."
            Write-Host " "
            $domainControllers = Get-ADDomainController
            Write-Output $domainControllers
        }
        '3' {
            Write-Output "Fetching AD Group Info..."
            $adGroups = Get-ADGroup -Filter *
            Write-Output $adGroups > adgroups.txt
            Write-Output "adgroups info saved to disk as 'adgroups.txt'"
        }
        '4' {
            Write-Output "Fetching AD Group Members Info..."
            $groupName = Read-Host -Prompt "Enter the group name"
            $groupMembers = Get-ADGroupMember -Identity $groupName
            Write-Output $groupMembers
        }
        '5' {
             Write-Bold "For details press 'd' or press Enter to go with only account names"
             $condition=Read-Host -Prompt ">"
             
             Write-Output " "

            if ($condition -eq 'd') {
                Write-Output "Fetching users that're associated with any SPN"
                $spnAccounts=Get-ADUser -Filter {ServicePrincipalName -ne "null"} -Properties *
                Write-Output $spnAccounts
            } else {
            $spnAccountNames=Get-ADUser -Filter {ServicePrincipalName -ne "null"} -Properties ServicePrincipalName | select SamAccountName,Name
            Write-Output $spnAccountNames
            }

            Write-Output " "
            Write-Output "Note: Kerberoasting targets service accounts that have Service Principal Names (SPNs) associated with them and very helpful in lateral movements within the network once an attacker gets initial access. If you cannot disable SPN with any user due to work requirements, make the password long and complex so that the password cannot be break with hashcat or other cracking tools"
            Write-Output "Vulnerability: Service accounts with weak passwords are susceptible to Kerberoasting because their service tickets can be cracked relatively easily."
            Write-Output "Tools: Rubeus and Impacket can be used to perform Kerberoasting attacks"

        Write-Output " "
        }
        '6' {
            
            Write-Output "Note: ASREPRoasting targets user accounts that have the property 'Do not require Kerberos preauthentication' enabled. To get more info, visit: https://medium.com/@haidershahzeb08/as-rep-roasting-74a958b1bedf"
            Write-Output "User accounts without preauthentication enabled and with weak passwords are susceptible because their AS-REP responses can be cracked relatively easily"
            Write-Output "Tools: Rubeus and Impacket can be used to perform ASREPRoasting attacks."
            Write-Output "Fetching ASReprostable Accounts Info..."
            $ASreproastable = Get-ADUser -Filter * -Properties DoesNotRequirePreAuth | Where-Object { $_.DoesNotRequirePreAuth -eq $true}
            Write-Output $ASreproastable
        }
        '7' {
            Write-Bold "Press 'd' for detailed info about all computers or Enter specific computer Name"
            $compAccCondition=Read-Host -Prompt ">"
             
             Write-Output " "

            if ($compAccCondition -eq 'd') {
                Write-Output "Fetching detailed information about all computer accounts"
                $computerAccounts=Get-ADComputer -Filter * -Properties *
                Write-Output $computerAccounts > allCompAccounts.txt
                Write-Output "All computer accounts information is saved to disk as 'allCompAccounts.txt'"
                Write-Output " "
            } else {
            $basicInfoComps=Get-ADComputer -Filter {Name -eq $compAccCondition} -Properties *
            Write-Output $basicInfoComps
            }

            Write-Output " "
            Write-Output "Note: Put the notes here for ASReproasting"

        Write-Output " "
        }
        '8' {
            Write-Bold "For all user account details press 'd' or enter specific user name"
            $userAccCondition=Read-Host -Prompt ">"
             
             Write-Output " "

            if ($userAccCondition -eq 'd') {
                Write-Output "Fetching detailed information about computer accounts"
                $userAccounts=Get-ADUser -Filter * -Properties *
                Write-Output $userAccounts
            } else {
            $specificUser=Read-Host -Prompt "Enter Username"
            $singleUserInfo=Get-ADUser -Filter {SamAccountName -eq $specificUser} -Properties *
            Write-Output $singleUserInfo
            }

            Write-Output " "

        Write-Output " "
        }
        '9' {
            Write-Bold "To get a list of all Windows Servers, press 'A' or enter specific version '2008, 2012, 2016 etc"
            $allServers=Read-Host -Prompt ">"
             
             Write-Output " "

            if ($allServers -eq 'A') {
                Write-Bold "Fetching basic information about all available windows servers i.e., 2008, 2012, 2016 etc"
                $winServersList=Get-ADComputer -Filter * -Properties * | select SamAccountName, IPv4Address, OperatingSystem | Select-String "Windows Server"
                Write-Output $winServersList
            } 
            elseif ($allServers -eq '2008') {
            Write-Output "Searching ... Please wait.."
            Write-Output " "
            $server2008=Get-ADComputer -Filter * -Properties * | select Name, IPv4Address, OperatingSystem | Select-String "Windows Server 2008"
            Write-Output $server2008 -Verbose
            }

            elseif ($allServers -eq '2012') {
            Write-Output "Searching ... Please wait.."
            Write-Output " "            
            $server2012=Get-ADComputer -Filter * -Properties * | select Name, IPv4Address, OperatingSystem | Select-String "Windows Server 2012"
            Write-Output $server2012 -Verbose
            }

            elseif ($allServers -eq '2016') {
            Write-Output "Searching ... Please wait.."
            Write-Output " "
            $server2016=Get-ADComputer -Filter * -Properties * | select Name, IPv4Address, OperatingSystem | Select-String "Windows Server 2016"
            Write-Output $server2016 -Verbose
            }

            elseif ($allServers -eq '2019') {
            Write-Output "Searching ... Please wait.."
            Write-Output " "
            $server2019=Get-ADComputer -Filter * -Properties * | select Name, IPv4Address, OperatingSystem | Select-String "Windows Server 2019"
            Write-Output $server2019 -Verbose
            }

            elseif ($allServers -eq '2022') {
            Write-Output "Searching ... Please wait.."
            Write-Output " "
            $server2022=Get-ADComputer -Filter * -Properties * | select Name, IPv4Address, OperatingSystem | Select-String "Windows Server 2022"
            Write-Output $server2022 -Verbose
            }

            Write-Output " "

        Write-Output " "
        }

        '10' {
             Write-Bold "Press 'd' for detailed info or press Enter to list only user accounts/groups"
             $condition=Read-Host -Prompt ">"
             #$condition=Read-Host -Prompt "Press 'd' for detailed info or press Enter to list only user accounts/groups"
             
             Write-Output " "

            if ($condition -eq 'd') {
                Write-Output "Fetching detailed info of all Users and Groups protected by AdminSDHolder"
                Write-Output " "
                $AllAdminSDHolder=Get-ADObject -Filter { AdminCount -eq 1 } -Properties *
                Write-Output $AllAdminSDHolder
            } else {
            $ShortAdminSDHolder=Get-ADObject -Filter { AdminCount -eq 1 } -Properties * | select SamAccountName, ObjectClass, MemberOf
            Write-Output $ShortAdminSDHolder
#            Write-Bold "(Note: AdminSDHolder Object is used to protect high privilege accounts.\n In case of DA is compromised, an attacker can provide full privileges to any compromised user account without adding it to the domain admin group because DA accounts are often investigated/auditd and remains undetected unle)"
            }

            Write-Output " "
            Write-Bold "Note"
            Write-Output "AdminSDHolder Object is used to protect high privilege accounts.\n In case of DA is compromised, an attacker can provide full privileges to any compromised user account without adding it to the domain admin group because DA accounts are often investigated/auditd and remains undetected unless ACLs are investigated."
            Write-Output "Read Article here: https://adsecurity.org/?p=1906"

        Write-Output " "
        }
        

        default {
            Write-Output "Invalid selection. Please enter 1, 2, 3, or 4."
        }
    }

    Write-Output " "
}
