sti = require('sti/sti')
gameMap = sti('maps/map.lua')

mapw = gameMap.width * gameMap.tilewidth
maph = gameMap.height * gameMap.tileheight

player = {}
player.body = love.physics.newBody(myWorld, mapw/2, maph/2, 'dynamic')
player.shape = love.physics.newRectangleShape(90, 90)
player.fixture = love.physics.newFixture(player.body, player.shape)

player.body:setMass(1)
player.body:setLinearDamping(0.75)

player.maxSpeed = 1000
player.speed = 1000
player.maxFear = 70
player.fear = 0
player.maxAmmo = 100
player.ammo = 100
player.sprite = sprites.shipStatic