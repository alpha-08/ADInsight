Write-Output "Desired files are being downloaded.."

# Download files
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

# Start the while loop
while ($true) {
    Write-Output "1. Get Domain Controller Info"
    Write-Output "2. Get ADGroup Info"
    Write-Output "3. Get ADGroupMember Info"
    Write-Output "4. Get Kerberoastable Accounts"
    Write-Output "5. Get ASReproastable Accounts"
    Write-Output "6. Get All Computer Accounts"
    Write-Output "   Press Ctrl+C to exit"

    # Prompt user for input
    Write-Output " "
    $userInput = Read-Host -Prompt "Press the desired info: "

    # Process user input
    switch ($userInput) {
        '1' {
            Write-Output "Fetching Domain Controller Info..."
            $domainControllers = Get-ADDomainController
            Write-Output $domainControllers
        }
        '2' {
            Write-Output "Fetching AD Group Info..."
            $adGroups = Get-ADGroup -Filter *
            Write-Output $adGroups > adgroups.txt
            Write-Output "adgroups info saved to disk as 'adgroups.txt'"
        }
        '3' {
            Write-Output "Fetching AD Group Members Info..."
            $groupName = Read-Host -Prompt "Enter the group name"
            $groupMembers = Get-ADGroupMember -Identity $groupName
            Write-Output $groupMembers
        }
        '4' {
             $condition=Read-Host -Prompt "For details press 'd' or press Enter to go with only account names"
             
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
            Write-Output "Note: Remember that only the users, associated with any SPN, are vulnerable to Kerberoasting Attack and very helpful in lateral movements within the network once an attacker gets initial access. If you cannot disable SPN with any user due to work requirements, make the password long and complex so that the password cannot be break with hashcat or other cracking tools"

        Write-Output " "
        }
        '5' {
    
            Write-Output "Fetching ASReprostable Accounts Info..."
            $ASreproastable = Get-ADUser -Filter * -Properties DoesNotRequirePreAuth | Where-Object { $_.DoesNotRequirePreAuth -eq $true}
            Write-Output $ASreproastable
        }
        '6' {
            $condition=Read-Host -Prompt "For details press 'd' or press Enter to go with only account names"
             
             Write-Output " "

            if ($condition -eq 'd') {
                Write-Output "Fetching detailed information about computer accounts"
                $computerAccounts=Get-ADComputer -Filter * -Properties *
                Write-Output $computerAccounts
            } else {
            $basicInfoComps=Get-ADComputer -Filter * -Properties * | select Name, Description, Enabled
            Write-Output $basicInfoComps
            }

            Write-Output " "
            Write-Output "Note: Remember that only the users, associated with any SPN, are vulnerable to Kerberoasting Attack and very helpful in lateral movements within the network once an attacker gets initial access. If you cannot disable SPN with any user due to work requirements, make the password long and complex so that the password cannot be break with hashcat or other cracking tools"

        Write-Output " "

            Write-Output "Fetching AD Computer Accounts Info..."
            $compAccounts = Get-ADComputer
            Write-Output $compAccounts
        }
        default {
            Write-Output "Invalid selection. Please enter 1, 2, 3, or 4."
        }
    }

    Write-Output " "
}
