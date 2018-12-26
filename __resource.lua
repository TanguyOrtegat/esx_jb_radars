description 'Script made by Jager Bom'
dependency 'ft_libs'
client_script { 
	"esx_jb_radars_cl.lua",
	"config.lua"
}
	
server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"esx_jb_radars_sv.lua",
	"config.lua",
	'version.lua',
}