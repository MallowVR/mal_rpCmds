-- FX Information
fx_version 'cerulean'
game 'gta5'

-- Resource Information
name 'mal_rpCmds'
author 'Mallow'
version '0.1'
repository ''
description ''

-- Manifest

shared_scripts {
    'config/client.lua',
    '@ox_lib/init.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua',
}

files {
	'config/client.lua',
}

dependency 'ox_lib'
dependency 'ox_target'

lua54 'yes'
use_experimental_fxv2_oal 'yes'
