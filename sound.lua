sndShoot = love.sound.newSoundData('audio/shot.ogg')
sndDestroy = love.sound.newSoundData('audio/explosion-short.ogg')
explosionLong = love.sound.newSoundData('audio/explosion-long.ogg')
sndLaunch = love.sound.newSoundData('audio/lose-4.wav')
sndThrust = love.sound.newSoundData('audio/thrust.ogg')
sndThrustStart = love.sound.newSoundData('audio/thrust-start.ogg')
sndThrustHold = love.sound.newSoundData('audio/thrust-hold.ogg')
sndThrustEnd = love.sound.newSoundData('audio/thrust-release.ogg')
-- music = love.audio.newSource('audio/Vast Surroundings (LOOP).wav', 'stream')
-- ending = love.audio.newSource('audio/ending.ogg', 'stream')

-- love.audio.setEffect('reverb', {type = 'reverb'})
-- sndLaunch:setEffect('reverb')

-- sndShoot:setVolume(0.25)
-- sndDestroy:setVolume(0.5)
-- music:setVolume(0.15)
-- music:setLooping(true)
-- ending:setVolume(0.5)

-- sndShootDt = love.sound.newSoundData('audio/explosion-short.ogg')

function playSound(sd)
  love.audio.newSource(sd, 'static'):play()
end