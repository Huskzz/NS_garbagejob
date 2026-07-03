fx_version 'cerulean'
game 'gta5'

author 'Nemesis Studios/Huskzz'
description 'A Garbagejob made by Nemesis Studios that is integrated with Esx, ox_lib, ox_target and okokNotify'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_target',
    'ox_lib'
}