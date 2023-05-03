$who = 'lucotl'
Select-String -Path 'C:\Windows\system32\LogFiles\*.log' -Pattern $who | Export-Csv -Path "C:\Users\admshord\Desktop\$who.csv" -NoTypeInformation