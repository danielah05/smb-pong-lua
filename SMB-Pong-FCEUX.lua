----------------------------------------------
--  PONG SMB - A LUA SCRIPT PORT FOR FCEUX  --
--   created by danielah05 - @flstudiodemo  --
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

while true do
	gamestarted = memory.readbyte(0x0770)
	is2player = memory.readbyte(0x77A)
	
	input = joypad.read(1)
	input2 = joypad.read(2)
	
	if gamestarted == 0 then
		gui.drawbox(0+20, 210, 0+20+256-40, 208+32-11, "#33000000")
		gui.drawbox(1+20, 211, 1+20+254-40, 209+30-11, "#2264b0ff")
		gui.drawtext(31, 217, "PONG SMB - A Lua Script by danielah05", "#ffffff")
	end
	
	if gamestarted > 0 then
	
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
		
		ball_x = ball_x + ball_dx
		ball_y = ball_y + ball_dy
		
		if (ball_y < 0 or ball_y > 231) then
			memory.writebyte(0x00FF, 0x02)
			ball_dy = -ball_dy
		end
		
		if (p1_x < ball_x + ball_width and p1_x + p1_width > ball_x and p1_y < ball_y + ball_height and p1_y + p1_height > ball_y) then
			memory.writebyte(0x00FF, 0x02)
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
			emu.softreset()
			end
		
			if ball_x > 248 then
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
				emu.softreset()
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
	end
	emu.frameadvance()
end