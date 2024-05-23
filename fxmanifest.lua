-- FX Information
fx_version 'cerulean'
game 'gta5'

-- Resource Information
name 'mal_rpCmds'
author 'Mallow'
version '0'
repository ''
description ''

-- Manifest

shared_scripts {
    'config/client.lua',
    '@ox_lib/init.lua',
    --'@qbx_core/modules/lib.lua',
    'ox_target/client/state.lua',
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
dependency 'qbx_core'
--dependency 'ox_target'

lua54 'yes'
use_experimental_fxv2_oal 'yes'
