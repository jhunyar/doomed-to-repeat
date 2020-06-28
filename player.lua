player = {}
player.body = love.physics.newBody(myWorld, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 'dynamic')
player.shape = love.physics.newRectangleShape(90, 90)
player.fixture = love.physics.newFixture(player.body, player.shape)

player.body:setMass(1)
player.body:setLinearDamping(0.75)

player.maxSpeed = 180
player.speed = 250
player.maxFear = 70
player.fear = 0
player.maxAmmo = 100
player.ammo = 100
player.sprite = sprites.shipStatic