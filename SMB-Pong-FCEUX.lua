----------------------------------------------
--  PONG SMB - A LUA SCRIPT PORT FOR FCEUX  --
--   created by danielah05 - @flstudiodemo  --
----------------------------------------------
--  i really need to clean up this code :/  --
----------------------------------------------
local p1_x = 16
local p1_y = 90
local p1_width = 16
local p1_height = 64
local p2_x = 16*14
local p2_y = 90
local p2_width = 16
local p2_height = 64
local ball_x = 248/2
local ball_y = 231/2
local ball_dx = math.random(2) == 1 and 2 or -2
local ball_dy = math.random(2) == 1 and 2 or -2
local ball_width = 8
local ball_height = 8
local p1_score = 0
local p2_score = 0
local p1_vs_score = 0
local p2_vs_score = 0
-- bunch of settings stuff do not touch (just like how you shouldnt touch anything in general)
settings_menu_open = 0 -- should be 0
settings_selected = 11+9 -- should be toggled to 11 on menu open
settings_menu_delay = 0
settings_pong_only = 0
settings_hard_mode = 0
----------------------------------------

while true do
	gamestarted = memory.readbyte(0x0770)
	is2player = memory.readbyte(0x77A)
	
	input = joypad.read(1)
	input2 = joypad.read(2)
	
	mario_powerstate = memory.readbyte(0x0754)
	mario_x = memory.readbyte(0x03AD)
	if mario_powerstate == 0 then mario_y = memory.readbyte(0x03B8) end
	if mario_powerstate == 1 then mario_y = memory.readbyte(0x03B8)+16 end
	mario_width = 16
	if mario_powerstate == 0 then mario_height = 32 end
	if mario_powerstate == 1 then mario_height = 16 end
	
	if gamestarted == 0 then
		gui.drawbox(0+20, 210, 0+20+256-40, 208+32-11, "#33000000")
		gui.drawbox(1+20, 211, 1+20+254-40, 209+30-11, "#2264b0ff")
		gui.drawtext(31, 217, "PONG SMB - A Lua Script by danielah05", "#ffffff")
    
    if input.B then
      if settings_menu_delay == 0 then
        settings_menu_open = settings_menu_open == 1 and 0 or 1
        settings_menu_delay = 10
      end
    end
    
    if settings_menu_open == 0 then
      settings_menu_delay = math.max(0, settings_menu_delay - 1)
      gui.drawbox(0, 0+8, 114, 11+9, "#33000000")
      gui.drawbox(1, 1+8, 1+112, 1+9+9, "#2264b0ff")
      gui.drawtext(3, 2+9, "Settings - Open with B", "#ffffff")
    end
    
    if settings_menu_open == 1 then
      if settings_menu_delay == 0 then
        if input.down then
          settings_menu_delay = 10
          settings_selected = math.min(21+9, settings_selected + 10+9)
        end
    
        if input.up then
          settings_menu_delay = 10
          settings_selected = math.max(11+9, settings_selected - 10-9)
        end
        
        if input.A then
          settings_menu_delay = 20
            if settings_selected == 11+9 then settings_pong_only = settings_pong_only == 1 and 0 or 1 end
            if settings_selected == 21+9 then settings_hard_mode = settings_hard_mode == 1 and 0 or 1 end
        end
      end
      
      settings_menu_delay = math.max(0, settings_menu_delay - 1)
      gui.drawbox(0, 0+8, 114, 11+9, "#33000000")
      gui.drawbox(1, 1+8, 1+112, 1+9+9, "#2264b0ff")
      gui.drawbox(0, 11+8, 114, 11+30-2+9, "#33000000")
      gui.drawbox(1, 11+8, 1+112, 11+27+9, "#2264b0ff")
      gui.drawbox(113, 0+8, 114+141, 39+9, "#33000000")
      gui.drawbox(114, 1+8, 114+140, 1+37+9, "#2264b0ff")
      gui.drawbox(1, settings_selected, 1+112, settings_selected+10, "#1100b0ff")
      gui.drawtext(2, 2+9, "Settings - Close with B", "#ffffff")
      gui.drawtext(2, 12+9, "Pong Only: " .. settings_pong_only, "#ffffff")
      gui.drawtext(2, 22+9, "Hard Mode: " .. settings_hard_mode, "#ffffff")
      if settings_selected == 11+9 then gui.drawtext(115, 2+9, "Disables anything SMB to\nallow a normal and fun game\nof Pong! (Includes 2 Player)", "#ffffff") end
      if settings_selected == 21+9 then gui.drawtext(115, 2+9, "Tired of having fun?\nTry Hard Mode instead!\nDon't let the Ball get Mario,\nor something bad happends!", "#ffffff") end
    end
	end
	
	if gamestarted > 0 then
	    if settings_pong_only == 1 then
			memory.writebyte(0x000E, 0x08)
		end
	
		local p1col = "#ff0000"
		local p2col = "#00ff00"
		local ballcol = "#ffff00"
		
		if input.down then
			p1_y = math.min(175, p1_y + 5)
		end
		
		if input.up then
			p1_y = math.max(0, p1_y - 5)
		end
		
		if input2.down then
			p2_y = math.min(175, p2_y + 5)
		end
		
		if input2.up then
			p2_y = math.max(0, p2_y - 5)
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
		
		if (ball_y < 0) then
			ball_y = 0
			memory.writebyte(0x00FF, 0x02)
			ball_dy = -ball_dy
		end
		
		if (ball_y > 231) then
			ball_y = 231
			memory.writebyte(0x00FF, 0x02)
			ball_dy = -ball_dy
		end
		
		if (p1_x < ball_x + ball_width and p1_x + p1_width > ball_x and p1_y < ball_y + ball_height and p1_y + p1_height > ball_y) then
			memory.writebyte(0x00FF, 0x02)
			ball_x = p1_x+16
			ball_dx = -ball_dx
		end
		
		if settings_hard_mode == 1 then
			if (mario_x < ball_x + ball_width and mario_x + mario_width > ball_x and mario_y < ball_y + ball_height and mario_y + mario_height > ball_y) then
				memory.writebyte(0x000E, 0x06)
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
			if settings_pong_only == 0 then emu.softreset() end
			end
		
			if ball_x > 248 then
				ball_x = 248
				p1_score = math.min(999, p1_score + 1)
				memory.writebyte(0x00FF, 0x02)
				ball_dx = -ball_dx
			end
		end
		
		if is2player == 1 then
			if (p2_x < ball_x + ball_width and p2_x + p2_width > ball_x and p2_y < ball_y + ball_height and p2_y + p2_height > ball_y) then
				memory.writebyte(0x00FF, 0x02)
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
				if settings_pong_only == 0 then emu.softreset() end
			end
		end
		
		gui.drawbox(p1_x, p1_y, p1_x + p1_width, p1_y + p1_height, p1col)
		if is2player == 1 then
			gui.drawbox(p2_x, p2_y, p2_x + p2_width, p2_y + p2_height, p2col)
		end
		gui.drawbox(ball_x, ball_y, ball_x + ball_width, ball_y + ball_height, ballcol)
		if is2player == 0 then
			gui.drawtext(10, 219, "P1: " .. p1_score, p1col)
			gui.drawtext(10*21, 219, "P2: " .. p2_score, p2col)
		end
		if is2player == 1 then
			gui.drawtext(10, 219, "P1: " .. p1_vs_score, p1col)
			gui.drawtext(10*21, 219, "P2: " .. p2_vs_score, p2col)
		end
		gui.drawbox(mario_x, mario_y, mario_x+mario_width, mario_y+mario_height, "#FF000000",  "#FF000000")
	end
	emu.frameadvance()
end