
$FSMO = hostname

Move-ADDirectoryServerOperationMasterRole -Identity $FSMO -OperationMasterRole SchemaMaster, DomainNamingMaster, PDCEmulator, RIDMaster, InfrastructureMaster -Force