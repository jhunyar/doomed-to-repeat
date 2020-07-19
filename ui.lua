function drawHud()
  love.graphics.setFont(fontLarge)
  if gameState == 1 then
    love.graphics.print('Click LMB to begin', camX/2, camY/2)
  end

  if showHUD == true then
    local a = radToDeg(player_mouse_angle()) - radToDeg(player.body:getAngle())
    a = (a + 180) % 360-180

    love.graphics.setFont(fontTiny)
    love.graphics.setColor(0.5, 0.5, 0.5)
    -- love.graphics.print('Score: ' .. score, camX - 100, camY - 80)
    if player.warpReady == true then love.graphics.print('Warp Ready', camX - 100, camY - 100) end
    love.graphics.print('Sector: ' .. player.currentSector, camX - 100, camY - 80)
    love.graphics.print('Ammo: ' .. player.ammo, camX + 60, camY - 80)
    love.graphics.print('L.Damp: ' .. player.linearDampingStatus, camX + 60, camY + 80)
    vx, vy = player.body:getLinearVelocity()
    if vx < 0 then vx = vx * -1 end
    if vy < 0 then vy = vy * -1 end
    love.graphics.print('Velocity: ' .. math.floor(vx+vy), camX + -100, camY + 80)
    love.graphics.setColor(1, 1, 1)

    if player.scannerData[1] then
      love.graphics.printf(player.scannerData[1].data, 10, camY - 10, 200, 'left')
    end
  end
end

function drawMinimap(zoom)
  if showMap == true then
    love.graphics.setColor(0.42,0.11,0.27,0.15)
    local sX = 0
    local sY = 0
    
    local scalingFactor = 1000

    if zoom == 0 then
      scalingFactor = 2000
    end

    if zoom == 2 then
      scalingFactor = 500
    end

    if zoom == 3 then
      scalingFactor = 250
    end

    if zoom == 4 then
      scalingFactor = 125
    end

    -- draw the map as normal
    love.graphics.rectangle('fill', sX, sY, 500, 500)

    -- draw the sun in relation to the player

    love.graphics.setColor(1, 1, 0)
    love.graphics.circle(
      'fill',
      sX + 250 - ((player.body:getX() - star.body:getX())/scalingFactor),
      sY + 250 - ((player.body:getY() - star.body:getY())/scalingFactor),
      star.size/scalingFactor
    )
    love.graphics.setColor(1, 1, 1)

    for i,o in ipairs(star.orbits) do      
      if o.planet then
        if o.planet.discovered == false or o.planet.discovered == true then
          love.graphics.setColor(1, 1, 1, 0.2)
          love.graphics.circle(
            -- these orbits don't stay in their corresponding minimap location,
            -- they move at a fraction of the (Correct) speed of everything else?
            'line',
            sX + 250 - ((player.body:getX() - star.body:getX())/scalingFactor),
            sY + 250 - ((player.body:getY() - star.body:getY())/scalingFactor),
            o.radius/scalingFactor
          )
          love.graphics.setColor(1, 1, 1)
          if o.planet.owner == 'player' then
            love.graphics.setColor(0, 0.2, 1)
          elseif o.planet.owner == 'enemy' then
            love.graphics.setColor(1, 0, 0)
          end

          love.graphics.circle(
            'fill',
            sX + 250 - ((player.body:getX() - o.planet.body:getX())/scalingFactor),
            sY + 250 - ((player.body:getY() - o.planet.body:getY())/scalingFactor), 
            4
          )
          love.graphics.setColor(1, 1, 1)
        end

        for j,m in ipairs(o.planet.orbits) do
          if m.moon then
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.circle(
              'line',
              sX + 250 - ((player.body:getX() - o.planet.body:getX())/scalingFactor),
              sY + 250 - ((player.body:getY() - o.planet.body:getY())/scalingFactor),
              m.radius/scalingFactor
            )
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle(
              'fill', 
              sX + 250 - ((player.body:getX() - m.moon.body:getX())/scalingFactor), 
              sY + 250 - ((player.body:getY() - m.moon.body:getY())/scalingFactor), 
              2
            )
            love.graphics.setColor(1, 1, 1) 
          end
        end
      end
    end

    love.graphics.draw(sprites.miniShip, sX + 250, sY + 250, player.body:getAngle(), nil, nil, sprites.miniShip:getWidth()/2, sprites.miniShip:getHeight()/2)
  
    --normiecore
    -- love.graphics.setColor(1, 1, 0)
    -- love.graphics.circle('fill', sX + star.body:getX()/scalingFactor, sY + star.body:getY()/scalingFactor, star.size/scalingFactor)
    -- love.graphics.setColor(1, 1, 1)
    -- for i,o in ipairs(star.orbits) do      
    --   if o.planet then
    --     if o.planet.discovered == false or o.planet.discovered == true then
    --       love.graphics.setColor(1, 1, 1, 0.2)
    --       love.graphics.circle('line', sX + star.body:getX()/scalingFactor, sY + star.body:getY()/scalingFactor, o.radius/scalingFactor)
    --       love.graphics.setColor(1, 1, 1)
    --       if o.planet.owner == 'player' then
    --         love.graphics.setColor(0, 0.2, 1)
    --       elseif o.planet.owner == 'enemy' then
    --         love.graphics.setColor(1, 0, 0)
    --       end

    --       love.graphics.circle('fill', sX + o.planet.body:getX()/scalingFactor, sY + o.planet.body:getY()/scalingFactor, 4)
    --       love.graphics.setColor(1, 1, 1)
    --     end

    --     for j,m in ipairs(o.planet.orbits) do
    --       if m.moon then
    --         love.graphics.setColor(1, 1, 1, 0.2)
    --         love.graphics.circle('line', sX + o.planet.body:getX()/scalingFactor, sY + o.planet.body:getY()/scalingFactor, m.radius/scalingFactor)
    --         love.graphics.setColor(1, 0, 0)
    --         love.graphics.circle('fill', sX + m.moon.body:getX()/scalingFactor, sY + m.moon.body:getY()/scalingFactor, 2)
    --         love.graphics.setColor(1, 1, 1) 
    --       end
    --     end
    --   end
    -- end

    -- love.graphics.draw(sprites.miniShip, sX + player.body:getX()/scalingFactor, sY + player.body:getY()/scalingFactor, player.body:getAngle(), nil, nil, sprites.miniShip:getWidth()/2, sprites.miniShip:getHeight()/2)
  end
end

function drawConsole()
  if showConsole == true then
    local cX = 10
    local cY = love.graphics:getHeight() - 210
    local cW = love.graphics:getWidth() - 530
    local cH = 200
    
    love.graphics.setColor(0.42,0.11,0.27,0.15)
    love.graphics.rectangle('fill', cX, cY, cW, cH)
    love.graphics.setColor(1,1,1)

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle('fill', cX + 10, cY + 10, 100, 30)
    love.graphics.setColor(1, 1, 1)
    if player.scannerData[1] then
      love.graphics.printf(player.scannerData[1].sector, cX + 12, cY + 12, 100, 'center')
    end
  end
end