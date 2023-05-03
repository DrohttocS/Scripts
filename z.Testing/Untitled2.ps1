Search-ADAccount -lockedout | select name, LastLogonDate,BadLogonCount,badPwdCount,LockedOut | ft -AutoSize -Wrap
