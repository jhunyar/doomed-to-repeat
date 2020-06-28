sndShoot = love.audio.newSource('audio/bonk-2.wav', 'static')
sndDestroy = love.audio.newSource('audio/bonk-3.wav', 'static')
sndLeap = love.audio.newSource('audio/jump-10.wav', 'static')
music = love.audio.newSource('audio/Vast Surroundings (LOOP).wav', 'stream')

love.audio.setEffect('reverb', {type = 'reverb'})

sndLeap:setEffect('reverb')

sndShoot:setVolume(0.25)
sndDestroy:setVolume(0.5)
music:setVolume(0.15)
music:setLooping(true)
music:play()