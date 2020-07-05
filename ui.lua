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

function drawMinimap()
  if showMap == true then
    love.graphics.setColor(0.42,0.11,0.27,0.2)
    love.graphics.rectangle('fill', love.graphics:getWidth() -510, love.graphics:getHeight() - 510, mapw/2000, maph/2000)
    love.graphics.setColor(1,1,1)
    for i,o in ipairs(star.orbits) do
      if o.planet then
        if o.planet.discovered == false or o.planet.discovered == true then
          love.graphics.setColor(1, 1, 1, 0.2)
          love.graphics.circle('line', love.graphics:getWidth() -510 + star.body:getX()/2000, love.graphics.getHeight() - 510 + star.body:getY()/2000, o.radius/2000)
          love.graphics.setColor(1, 1, 1)
          if o.planet.owner == 'player' then
            love.graphics.setColor(0, 0.2, 1)
          elseif o.planet.owner == 'enemy' then
            love.graphics.setColor(1, 0, 0)
          end

          love.graphics.circle('fill', love.graphics:getWidth() -510 + o.planet.body:getX()/2000, love.graphics.getHeight() - 510 + o.planet.body:getY()/2000, 4)
          love.graphics.setColor(1, 1, 1)
        end

        -- for j,m in ipairs(p.moons) do
        --   if m.discovered == true then
        --     love.graphics.circle('fill', love.graphics.getWidth() -510 + m.body:getX()/2000, love.graphics.getHeight() - 510 + m.body:getY()/2000, 2) 
        --   end
        -- end
      end
    end

    love.graphics.draw(sprites.miniShip, love.graphics:getWidth() -510 + player.body:getX()/2000, love.graphics.getHeight() - 510 + player.body:getY()/2000, player.body:getAngle(), nil, nil, sprites.miniShip:getWidth()/2, sprites.miniShip:getHeight()/2)
  end
end