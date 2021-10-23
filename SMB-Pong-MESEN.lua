-------------------------------------------
--  PONG SMB - A LUA SCRIPT FOR MESEN    --
-- created by danielah05 - @flstudiodemo --
-------------------------------------------
p1_x = 16
p1_y = 90
p1_width = 16
p1_height = 64
p2_x = 16*14
p2_y = 90
p2_width = 16
p2_height = 64
ball_x = 248/2
ball_y = 231/2
ball_dx = math.random(2) == 1 and 2 or -2
ball_dy = math.random(2) == 1 and 2 or -2
ball_width = 8
ball_height = 8
p1_score = 0
p2_score = 0
p1_vs_score = 0
p2_vs_score = 0

function main()
  state = emu.getState()
  
  gamestarted = emu.read(0x0770, emu.memType.cpu)
  is2player = emu.read(0x77A, emu.memType.cpu)
  
  input = emu.getInput(0)
  input2 = emu.getInput(1)
  
  if gamestarted == 0 then
    emu.drawRectangle(0+20, 208+5, 256-40, 32-10, 0x33000000, true, 1)
    emu.drawRectangle(1+20, 209+5, 254-40, 30-10, 0x2264b0ff, true, 1)
    emu.drawString(31, 220, "PONG SMB - A Lua Script by danielah05", 0xffffff, 0xFF000000, 1)
  end
 
  if gamestarted > 0 then
    
    p1col = 0xff0000
    p2col = 0x00ff00
    ballcol = 0xffff00
    
    if input.down then
      p1_y = math.min(175, p1_y + 5)
    end
    
    if input.up then
      p1_y = math.max(0, p1_y - 5)
    end
    
    if is2player == 1 then
      if input2.down then
        p2_y = math.min(175, p2_y + 5)
      end
    
      if input2.up then
        p2_y = math.max(0, p2_y - 5)
      end
    end
     
    ball_x = ball_x + ball_dx
    ball_y = ball_y + ball_dy
      
    if (ball_y < 0 or ball_y > 231) then
      emu.write(0x00FF, 0x02, emu.memType.cpu)
      ball_dy = -ball_dy
    end
    
    if (p1_x < ball_x + ball_width and p1_x + p1_width > ball_x and p1_y < ball_y + ball_height and p1_y + p1_height > ball_y) then
      emu.write(0x00FF, 0x02, emu.memType.cpu)
      ball_x = p1_x+16
      ball_dx = -ball_dx
    end
    
    if is2player == 0 then
      if ball_x < 0 then
        if ball_x < 126 then
          p2_score = math.min(999, p2_score + 1)
        end
        p1_score = 0
        ball_x = 248/2
        ball_y = 231/2
        p1_x = 16
        p1_y = 90
        ball_dx = math.random(2) == 1 and 2 or -2
        ball_dy = math.random(2) == 1 and 2 or -2
        emu.reset()
      end
      
      if ball_x > 248 then
        p1_score = math.min(999, p1_score + 1)
        emu.write(0x00FF, 0x02, emu.memType.cpu)
        ball_dx = -ball_dx
      end
    end
    
    if is2player == 1 then
      if (p2_x < ball_x + ball_width and p2_x + p2_width > ball_x and p2_y < ball_y + ball_height and p2_y + p2_height > ball_y) then
        emu.write(0x00FF, 0x02, emu.memType.cpu)
        ball_x = p2_x-10
        ball_dx = -ball_dx
      end

      if (ball_x < 0 or ball_x > 248) then
        if ball_x > 128 then
          p1_vs_score = math.min(999, p1_vs_score + 1)
        end
        if ball_x < 126 then
          p2_vs_score = math.min(999, p2_vs_score + 1)
        end
        ball_x = 248/2
        ball_y = 231/2
        p1_x = 16
        p1_y = 90
        p2_x = 16*14
        p2_y = 90
        ball_dx = math.random(2) == 1 and 2 or -2
        ball_dy = math.random(2) == 1 and 2 or -2
        emu.reset()
      end
    end
    
    emu.drawRectangle(p1_x, p1_y, p1_width, p1_height, p1col, true, 1)
    if is2player == 1 then
      emu.drawRectangle(p2_x, p2_y, p2_width, p2_height, p2col, true, 1)
    end
    emu.drawRectangle(ball_x, ball_y, ball_width, ball_height, ballcol, true, 1)
    emu.drawRectangle(9, 224, 40, 9, 0x2264b0ff, true, 1)
    emu.drawRectangle(10*21-1, 224, 40, 9, 0x2264b0ff, true, 1)
    if is2player == 0 then
      emu.drawString(10, 225, "P1: " .. p1_score, p1col, 0xFF000000, 1)
      emu.drawString(10*21, 225, "P2: " .. p2_score, p2col, 0xFF000000, 1)
    end
    if is2player == 1 then
      emu.drawString(10, 225, "P1: " .. p1_vs_score, p1col, 0xFF000000, 1)
      emu.drawString(10*21, 225, "P2: " .. p2_vs_score, p2col, 0xFF000000, 1)
    end
  end
end

emu.addEventCallback(main, emu.eventType.endFrame)
