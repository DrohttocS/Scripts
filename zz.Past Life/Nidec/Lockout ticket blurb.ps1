

$tic= "Attached lockout report.  It appears that the lockout are coming from the devices at 10.112.24.122 & 10.112.24.7. Please check for the following.

1. Mapped drives using old credentials:
Mapped drives can be configured to use user-specified credentials to connect to a shared resource. Afterwards, the user may change the password without updating the credentials in the mapped drive. The credentials may also expire, which will lead to account lockouts.

2. Systems using old cached credentials:
Some users are required to work on multiple computers. As a result, a user can be logged on to more than one computer simultaneously. These other computers may have applications that are using old, cached credentials which may result in locked accounts.

3. Applications using old credentials / Citrix / Browsers:
On the user’s system, there may be several applications which either cache the users’ credentials or explicitly define them in their configuration. If the user’s credentials are expired and are not updated in the applications, the account will be locked.

4. Windows Services using expired credentials:
Windows services can be configured to use user-specified accounts. These are known as service accounts. The credentials for these user-specified accounts may expire and Windows services will continue using the old, expired credentials; leading to account lockouts.

5. Scheduled Tasks:
The Windows task scheduler requires credentials to run a task whether the user is logged in or not. Different tasks can be created with user-specified credentials which can be domain credentials. These user-specified credentials may expire and Windows tasks will continue to use the old credentials.
"

$tic