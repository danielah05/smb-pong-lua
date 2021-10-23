-------------------------------------------
--  PONG SMB - A LUA SCRIPT FOR MESEN    --
-- created by danielah05 - @flstudiodemo --
-------------------------------------------
-- i really need to clean up this code :/--
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
-- bunch of settings stuff do not touch (just like how you shouldnt touch anything in general)
settings_menu_open = 0 -- should be 0
settings_selected = 11 -- should be toggled to 11 on menu open
settings_menu_delay = 0
settings_pong_only = 0
settings_hard_mode = 0
----------------------------------------

function main()
  state = emu.getState()
  
  gamestarted = emu.read(0x0770, emu.memType.cpu)
  is2player = emu.read(0x77A, emu.memType.cpu)
  
  input = emu.getInput(0)
  input2 = emu.getInput(1)
  
  mario_powerstate = emu.read(0x0754, emu.memType.cpu)
  mario_x = emu.read(0x03AD, emu.memType.cpu)
  if mario_powerstate == 0 then mario_y = emu.read(0x03B8, emu.memType.cpu) end
  if mario_powerstate == 1 then mario_y = emu.read(0x03B8, emu.memType.cpu)+16 end
  mario_width = 16
  if mario_powerstate == 0 then mario_height = 32 end
  if mario_powerstate == 1 then mario_height = 16 end
  
  if gamestarted == 0 then
    emu.drawRectangle(0+20, 208+5, 256-40, 32-10, 0x33000000, true, 1)
    emu.drawRectangle(1+20, 209+5, 254-40, 30-10, 0x2264b0ff, true, 1)
    emu.drawString(31, 220, "PONG SMB - A Lua Script by danielah05", 0xffffff, 0xFF000000, 1)
    
    if input.b then
      if settings_menu_delay == 0 then
        settings_menu_open = settings_menu_open == 1 and 0 or 1
        settings_menu_delay = 10
      end
    end
    
    if settings_menu_open == 0 then
      settings_menu_delay = math.max(0, settings_menu_delay - 1)
      emu.drawRectangle(0, 0, 114, 11, 0x33000000, true, 1)
      emu.drawRectangle(1, 1, 112, 9, 0x2264b0ff, true, 1)
      emu.drawString(2, 2, "Settings - Open with B", 0xffffff, 0xFF000000, 1)
    end
    
    if settings_menu_open == 1 then
      if settings_menu_delay == 0 then
        if input.down then
          settings_menu_delay = 10
          settings_selected = math.min(21, settings_selected + 10)
        end
    
        if input.up then
          settings_menu_delay = 10
          settings_selected = math.max(11, settings_selected - 10)
        end
        
        if input.a then
          settings_menu_delay = 20
            if settings_selected == 11 then settings_pong_only = settings_pong_only == 1 and 0 or 1 end
            if settings_selected == 21 then settings_hard_mode = settings_hard_mode == 1 and 0 or 1 end
        end
      end
      
      settings_menu_delay = math.max(0, settings_menu_delay - 1)
      emu.drawRectangle(0, 0, 114, 11, 0x33000000, true, 1)
      emu.drawRectangle(1, 1, 112, 9, 0x2264b0ff, true, 1)
      emu.drawRectangle(0, 11, 114, 30-2, 0x33000000, true, 1)
      emu.drawRectangle(1, 11, 112, 27, 0x2264b0ff, true, 1)
      emu.drawRectangle(114, 0, 142, 39, 0x33000000, true, 1)
      emu.drawRectangle(114, 1, 141, 37, 0x2264b0ff, true, 1)
      emu.drawRectangle(1, settings_selected, 112, 10, 0x1100b0ff, true, 1)
      emu.drawString(2, 2, "Settings - Close with B", 0xffffff, 0xFF000000, 1)
      emu.drawString(2, 12, "Pong Only: " .. settings_pong_only, 0xffffff, 0xFF000000, 1)
      emu.drawString(2, 22, "Hard Mode: " .. settings_hard_mode, 0xffffff, 0xFF000000, 1)
      if settings_selected == 11 then emu.drawString(115, 2, "Disables anything SMB to\nallow a normal and fun game\nof Pong! (Includes 2 Player)", 0xffffff, 0xFF000000, 1) end
      if settings_selected == 21 then emu.drawString(115, 2, "Tired of having fun?\nTry Hard Mode instead!\nDon't let the Ball get Mario,\nor something bad happends!", 0xffffff, 0xFF000000, 1) end
    end
  end
 
  if gamestarted > 0 then
    if settings_pong_only == 1 then
      emu.write(0x000E, 0x08, emu.memType.cpu)
    end
    
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
    
    -- no hard mode
    if settings_hard_mode == 0 then
      ball_x = ball_x + ball_dx
      ball_y = ball_y + ball_dy
    end
    -- hard mode
    if settings_hard_mode == 1 then
      ball_x = ball_x + ball_dx + ball_dx + ball_dx
      ball_y = ball_y + ball_dy + ball_dy + ball_dy
    end
    
    
    if (ball_y < 0 or ball_y > 231) then
      emu.write(0x00FF, 0x02, emu.memType.cpu)
      ball_dy = -ball_dy
    end
    
    if (p1_x < ball_x + ball_width and p1_x + p1_width > ball_x and p1_y < ball_y + ball_height and p1_y + p1_height > ball_y) then
      emu.write(0x00FF, 0x02, emu.memType.cpu)
      ball_x = p1_x+16
      ball_dx = -ball_dx
    end
    
    if settings_hard_mode == 1 then
      if (mario_x < ball_x + ball_width and mario_x + mario_width > ball_x and mario_y < ball_y + ball_height and mario_y + mario_height > ball_y) then
        emu.write(0x000E, 0x06, emu.memType.cpu)
      end
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
        if settings_pong_only == 0 then emu.reset() end
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
        if settings_pong_only == 0 then emu.reset() end
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
    emu.drawRectangle(mario_x, mario_y, mario_width, mario_height, 0xFF000000, true, 1)
  end
end

emu.addEventCallback(main, emu.eventType.endFrame)
