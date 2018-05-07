-- this is a local group on the svr with 21 worker users.
declare @login_name nvarchar(255) = CONCAT(cast(SERVERPROPERTY('MachineName') as nvarchar(128)), '\SQLRUserGroup', CAST(serverproperty('InstanceName') as nvarchar(128)));
if SUSER_ID(@login_name) is null
begin
	set @login_name = QUOTENAME(@login_name);
	exec('create login ' + @login_name + ' from windows;');
	print('create login ' + @login_name + ' from windows; --done');
end
go
declare @login_name nvarchar(255) = CONCAT(cast(SERVERPROPERTY('MachineName') as nvarchar(128)), '\SQLRUserGroup', CAST(serverproperty('InstanceName') as nvarchar(128)));
if SUSER_ID(@login_name) is not null
begin
	set @login_name = QUOTENAME(@login_name);
	exec('alter server role sysadmin add member ' + @login_name + ';');
	print('alter server role sysadmin add member ' + @login_name + '; --done');
end;
