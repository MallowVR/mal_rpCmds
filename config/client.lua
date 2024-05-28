Config = {}

Config.radius = 10
Config.color = vec4(1,255,158,255) -- color of 3d text (/me /action /status /do)
Config.successColor = vec4(1,255,158,255)
Config.failureColor = vec4(255,15,1,255)
Config.font = 4
Config.duration = 5000 -- ms duration of /action

Config.weight = 50 -- percent change for success or failure
Config.crits = true -- true enabled critical success and falures
Config.critRange = 5 -- percent chance for a critical success or failure 

-- easy command name changes (in case things conflict, like /status conflicts with qbx_ambulancejob)
Config.statusCommand = 'status'
Config.actionCommand = 'action'
Config.meCommand = 'me'
Config.doCommand = 'do'
Config.rollCommand = 'roll'

Config.maxDice = 6
Config.maxSides = 999
