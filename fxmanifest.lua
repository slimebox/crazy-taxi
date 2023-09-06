fx_version 'bodacious'
game 'gta5'

author 'Curle'
version '0.1.0'
lua54 'yes'

client_scripts { 'client/callbacks.lua', 'client/target.lua', 'client/ui.lua', 'client/client.lua' }
server_scripts { 'server/**.lua', '@es_extended/locale.lua', }
shared_scripts { '@ox_lib/init.lua', 'shared.lua', 'config/config.lua' }
