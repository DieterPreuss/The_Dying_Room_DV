pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--the dying room

objs = {}                    --a list of all the objects in the game (starts empty)

function _init()

	player={
	 x=7,
	 y=10,
	 dx=0,
	 dy=0,
	 d="idle",
  sh=2,
  sw=2,
  --------------
  bounce=0.3,
  -- half-width and half-height
		-- slightly less than 0.5 so
		-- that will fit through 1-wide
		-- holes.
		w=0.4,
		h=0.4,
  -------------
  f=0,
  hp=4,
  anims={
	  idle={fr=1,0},
			walkdown={fr=5,0,2,4,0,2,4},
			walkup={fr=5,32,34,36,32,34,36},
			walkleft={fr=5,6,8,10,6,8,10},
			walkright={fr=5,6,8,10,6,8,10},
  }
 }
 add(objs,player) 
	
end

function _draw()
 cls()
	
	-- move camera to current room
	room_x = flr(player.x/16)
	room_y = flr(player.y/16)
	camera(room_x*128,room_y*128)
	
	-- draw the whole map (128⁙32)
	map()
	--map(0,0,0,0,7,7)
	
	-- draw the player
	spr(player.anims[player.d][2+(flr(player.f))],--*2)],      -- frame index
	 player.x*8-4,player.y*8-4, -- x,y (pixels)
	 2,2,player.d=="walkright"    -- w,h, flip
	)
	
	draw_gui()
	
--	draw_spear()
	
end

function _update()
    
 ac=0.1 -- acceleration
 
	
	if (btn(⬅️)) then
		player.dx-= ac 
		player.d= "walkleft"
	end
	if (btn(➡️)) then
		player.dx+= ac 
		player.d= "walkright"
	end
	if (btn(⬆️)) then
		player.dy-= ac 
		player.d= "walkup"
	end	
	if (btn(⬇️)) then
		player.dy+= ac 
		player.d= "walkdown"
	end	
	
	-- move (add velocity)
	----------viejo-------------
	--player.x+=player.dx player.y+=player.dy
	---------------------------
	----------nuevo-----------------
	-- only move actor along x
	-- if the resulting position
	-- will not overlap with a wall

	if not solid_a(player, player.dx, 0) then
		player.x += player.dx
	else
		player.dx *= -player.bounce
	end

	-- ditto for y

	if not solid_a(player, 0, player.dy) then
		player.y += player.dy
	else
		player.dy *= -player.bounce
	end
	---------------------------
	
	-- friction (lower for more)
	player.dx *=.7
	player.dy *=.7
	
	
	
	-- advance animation according
	-- to speed (or reset when
	-- standing almost still)
	spd=sqrt(player.dx*player.dx+player.dy*player.dy)
	player.f= (player.f+spd*2) % player.anims[player.d].fr -- 6 frames
	if (spd < 0.05) f=0
	
	-- collect apple
	if (mget(player.x,player.y)==10) then
		mset(player.x,player.y,14)
		sfx(0)
	end
    
    
end

function print_centered(str)
  print(str, player.x,player.y, 8) 
end

function draw_gui()

			--character
   spr(135,0,0,2,2)
   
   --healthbar
   spr(187-((player.hp-1)*16),14,8,4,1) 
	 
end

function draw_spear()

			--character
   spr(104,
   player.x*8+2,
   player.y*8+1,
   2,2,player.d=="walkright")
	 
end
-->8
--collisions

-- for any given point on the
-- map, true if there is wall
-- there.

function solid(x, y)
	-- grab the cel value
	val=mget(x, y)
	
	-- check if flag 1 is set (the
	-- orange toggle button in the 
	-- sprite editor)
	return fget(val, 1)
	
end

-- solid_area
-- check if a rectangle overlaps
-- with any walls

--(this version only works for
--actors less than one tile big)

function solid_area(x,y,w,h)
	return 
		solid(x-w,y-h) or
		solid(x+w,y-h) or
		solid(x-w,y+h) or
		solid(x+w,y+h)
end


-- true if [a] will hit another
-- actor after moving dx,dy

-- also handle bounce response
-- (cheat version: both actors
-- end up with the velocity of
-- the fastest moving actor)

function solid_actor(a, dx, dy)
	for a2 in all(actor) do
		if a2 != a then
		
			local x=(a.x+dx) - a2.x
			local y=(a.y+dy) - a2.y
			
			if ((abs(x) < (a.w+a2.w)) and
					 (abs(y) < (a.h+a2.h)))
			then
				
				-- moving together?
				-- this allows actors to
				-- overlap initially 
				-- without sticking together    
				
				-- process each axis separately
				
				-- along x
				
				if (dx != 0 and abs(x) <
				    abs(a.x-a2.x))
				then
					
					v=abs(a.dx)>abs(a2.dx) and 
					  a.dx or a2.dx
					a.dx,a2.dx = v,v
					
					local ca=
					 collide_event(a,a2) or
					 collide_event(a2,a)
					return not ca
				end
				
				-- along y
				
				if (dy != 0 and abs(y) <
					   abs(a.y-a2.y)) then
					v=abs(a.dy)>abs(a2.dy) and 
					  a.dy or a2.dy
					a.dy,a2.dy = v,v
					
					local ca=
					 collide_event(a,a2) or
					 collide_event(a2,a)
					return not ca
				end
				
			end
		end
	end
	
	return false
end


-- checks both walls and actors
function solid_a(a, dx, dy)
	if solid_area(a.x+dx,a.y+dy,
				a.w,a.h) then
				return true end
	return solid_actor(a, dx, dy) 
end

-- return true when something
-- was collected / destroyed,
-- indicating that the two
-- actors shouldn't bounce off
-- each other

function collide_event(a1,a2)
	
	-- player collects treasure
	if (a1==pl and a2.k==35) then
		del(actor,a2)
		sfx(3)
		return true
	end
	
	sfx(2) -- generic bump sound
	
	return false
end
__gfx__
00000008800000000000000880000000000000088000000000000008800000000000000880000000000000088000000000000000a000000000000000a0000000
0000009888a000000000009888900000000000988890000000000009888000000000000988800000000000098880000000000a0a9a0a000000000a0a9a0a0000
00000999899a0000000009998999000000000999899900000000009999aa00000000009999aa00000000009999aa000000000999b999000000000999b9990000
000009ff9ff90000000009ff9ff90000000009ff9ff9000000000999999a800000000999999a800000000999999a800000000119b911000000000119b9110000
00009fffffff900000009fffffff900000009fffffff900000000009999980000000000999998000000000099999800000001111a111100000001111a1111000
000099c7fc799000000099c7fc799000000099c7fc79900000000999999900000000099999990000000009999999000000001100000110000000110000011000
0000999cfc9990000000999cfc9990000000999cfc99900000000999999900000000099999990000000009999999000000001110001110000000111000111000
00a0099fff9900a000a0099fff9900a000a0099fff9900a0000009999a9900000000099a99990000000009999a99000000000211011200000000021101120000
009aa09444909a900099909444909a90009aa09444909a9000000994aaa000000000099aaa90000000000994aaa0000000001021012010000000002101200000
00099f11911f990000099f11911f990000099f11911f99000000090a99a00000000009059aa000000000090a99a0000000021165151112000002116515111200
00099999999999000009999999999900000999999999990000000009999000000000000599a00000000000099990000000021152511112000002115251111200
000f8f99999f8f00000f8f99999f8f00000f8f99999f8f000000000f89900000000000595f8f0000000000ff8990000000011515251511000001151525151100
000f80199910f800000ff0199910f800000f80199910ff000000000f8f0000000000055995f8f00000000ff89f50000000011011156011000001101115605500
000ff0119110ff00000000119110f800000f8011911000000000000ff10000000000055ff10ff00000000ff99155000000055021112055000000002111205500
000000ff1ff00000000000ff1ff0ff00000ff0ff1ff0000000000001110000000000000111d00000000000011fd5000000000021012000000000001101200000
000000dd0dd00000000000000dd00000000000dd000000000000000ddd000000000000550dd00000000000dd0dd0000000000011011000000000000001100000
00000000800000000000000080000000000000008000000000000000a000000000000000a000000000000000a000000000000000a000000000000000a0000000
0000009888a000000000009888a000000000009888a0000000000a0a9a0a000000000a0a9a0a000000000a0a9a0a000000000a0a9a0a000000000a0a9a0a0000
00000999899a000000000999899a000000000999899a000000000b999999000000000b999999000000000b999999000000000999999900000000099999990000
00000999999a000000000999999a000000000999999a000000000119991900000000011999190000000001199919000000000119991100000000011999110000
000099999999a0000000999999999000000099999999900000000001a111000000000001a111000000000001a111000000001111a111100000001111a1111000
00009999999990000000999999999000000099999999900000000111111100000000011111110000000001111111000000001111111110000000111111111000
00009999999990000000999999999000000099999999900000000111551200000000011111110000000001111111000000001111111110000000111111111000
00a00999999900a000a00999999900a000a00999999900a000000115225000000000011551110000000001111551000000000211111200000000021111120000
0099909555909a90009990955590aa90009990955590aa9000000125225000000000015225100000000001115225000000001022222010000000102222201000
00099959995999000009995999599900000999599959990000000001221000000000005222500000000000052225000000021111157112000002111115711200
00099599999599000009959999959900000995999995990000000001111000000000000522100000000000012250000000021111525112000002111152511200
000f859999958f00000f859999958f00000f859999958f0000000005115000000000005511110000000000111510000000011555251511000001155525151100
0008f01111108f00000ff01111108f000008f0111110ff0000000001550000000000055151115000000005111115000000011075511011000001107551101100
000ff0111110ff000000001111108f000008f0111110000000000001210000000000055121055000000005512115000000055021112055000000002111205500
000000ff9ff00000000000ff9ff0ff00000ff0ff9ff0000000000001210000000000000112100000000000021150000000000021012000000000001101205500
000000dd0dd00000000000000dd00000000000dd0000000000000001110000000000005501100000000000110550000000000011011000000000000001100000
00000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055550
00000a0a9a0a000000000000000000000000000000000000000000000000a000000000000000555000000444400000000000000000000000000000000054bb35
00000999b9990000000000000000000000000000000000000000000000779a00000000000055525000004444444000000000000a700000000000000005433350
00000119b911000000000000000000000000000000000000000000000770a0000000000005662550000445555444000000400049a40004000000000555455500
00001111a11110000000000000000006000000000000000000000000770000000000000056626500000477755554000004490474474049400000005888582250
000011000001100000000000000006660000000000000000000000066660000000000005662665000004780780540000044404b44b4044400000058788888225
00001110001110000000000000666760000000000000000000000055556600000000005662665000000477777774000044944044440444440000058878888825
0000021101120000000000000677760000000000000000000000055555566000000005662665000000a44676764400005444545aa54544940000058888888825
000000210120000000000000677776000000000000000000000005555555600000a056626650000007ea476767440000544454ab7a4544440000058888888225
00021165151112000000000677776000000000000600000000000555555560000aa56626650000009e2a4404444000005494559bba5544940000005288882250
000211525111120000000067777600000000000006600000000000555555000000a9626650000000099aa4004440000054440593ba5044440000000522222500
0001151525151100000006777776000000000000066000000000000555500000000ab665000000000009a7404740000055400559a55004440000000055555000
00055011156011000000677777600000000000000666000000000000000000000055a9500000000000007a400770000055400445555004440000000000000000
000550211120000000006777776000000000000066760000000000000000000005440aaa00000000000004a77440000055400440054004440000000000000000
0000002101100000000067777760000000000000677660000000000000000000554000a000000000000004477444000055500440054005440000000000000000
00000011000000000006777777600000000000066777600000000000000000005400000000000000000004444a44400005500044044005400000000000000000
00000000a0000000000677777760000000000006677760000000000000000000000000000000000000000005500000000005555a000000000000000000005500
00000a0a9a0a000000067777776000000000006667776000000000745700000000000000000000000000005075500000000fff5aa00000000000000000057750
000009999999000000067777776000000000006777776000000007754770000000000000000000000000333003350000000bfb50aa0000000000000000057f75
000001199911000000067777776000000000006777776000000000777700000000000000004000000000833333350000000ffff0000000000000000000577ff5
00001111a11110000006777777600000000006777776000000000070b7000000000000000454000000080000335500000055ff55f0000000000000055577f550
0000111111111000000677777760000000000677777600000000007007000000000000004540000000000000335000000f05555ff00000000000555994495000
00001111111110000006777777760000000067777776000000000770077000000000000d5400000000000000035000001ff556ff100000000005999949445000
000002111112000000067777777600000000677777600000000070bb000700000000005dd0000000000000000350000011f56551100000000059494999445000
0000102222201000000677777777600000667777776000000007bbbbbbbb700000000567700000000000000035000000011611114444a0000059999949450000
0002111115711200000067777777600006777777760000000007bbbbbbbb70000000567700000000000000035500000000611f4444444a000059949994450000
0002111152511200000067777777766667777777600000000007bbbbbbbb7000000567700000000000000005500000000704444444444aa00054994444500000
00011555251511000000066677777777777777750000000000007bbbbbb700000056770000000000000000333300000000040440554440a00005444445000000
00011075511011000000000066677777777766600000000000000777777000000567700000000000000005555550000500440440055440000000555550000000
00055021112000000000000000066666666600000000000000000000000000000777000000000000000003333333005400400400004044000000000000000000
00055021011000000000000000000000000000000000000000000000000000000000000000000000000555555555504000400400004004000000000000000000
00000011000000000000000000000000000000000000000000000000000000000000000000000000000333333333330000000400000004000000000000000000
66666666666666664444444466666666666006666666666666666666011111111111110011111111111111110111111111011111111101111111100000000000
55556555555565554599995454444445579999755555655555556555017707070707710077070771177070771bbbbbbbbb1bbbbbbbbb1bbbbbbbb10000000000
55556555555565559666666949999994506666055555655555556555017000880000710070000071170000071bbbbbbbbb1bbbbbbbbb1bbbbbbbbb1000000000
555565555555655504444440f999999f506366055444444444444445010009888a00010000000001100000001bbbbbbbbb1bbbbbbbbb1bbbbbbbb10000000000
6666666666333366040000400ffffff06066760649999999999999940170999899a0710070000071170000070111111111011111111101111111100000000000
55555556536666360481c3400444444050766d06499999999999999401009ff9ff90010000000001100000000000000000000000000000000000000000000000
5555555653b66b36045555400400004050d766069ffffffffffffff90179fffffff9710070000071170000070000000000000000000000000000000000000000
5555555653bbbb36044444400405504050000006044444444444444001099c7fc799010077070771170000070000000000000000000000000000000000000000
0000000063bbbb360400004000000000000000000444444004444440017999cfc999710011111111100000000111111111011111111101111111100000000000
00000000553333550481c34000700000000000000444444444444440010099fff990010071717771170000071bbbbbbbbb1bbbbbbbbb18888888810000000000
00000000555335550455554000770000000000000000000000000000017009444900710077717071100000001bbbbbbbbb1bbbbbbbbb18888888881000000000
00000000559aa9550444444000767000000000000444444444444440017707070707710071717711170000071bbbbbbbbb1bbbbbbbbb18888888810000000000
00000000660440660400004000767000000000000444444004444440011111111111110071717110177070770111111111011111111101111111100000000000
00000000550440560481c34000767000000000000444444444444440000000000000000011111100111111110000000000000000000000000000000000000000
00000000550440560455554000767000000000000500000000000050000000000000000000000000000000000000000000000000000000000000000000000000
00000000555005560400004000767000000000000405555555555040000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000007a7000000000000000000000000000000000000000000000000000000000000111111111011111111101111111100000000000
0000000000000090000000000998aa00000000000000000000000000000000000000000000000000000000001bbbbbbbbb188888888818888888810000000000
0900000000000997777777700099a000000000000000000000000000000000000000000000000000000000001bbbbbbbbb188888888818888888881000000000
99999999999aa98a66666700000a0000000000000000000000000000000000000000000000000000000000001bbbbbbbbb188888888818888888810000000000
0a00000000000aa777777000000a0000000000000000000000000000000000000000000000000000000000000111111111011111111101111111100000000000
00000000000000a00000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000000111111111011111111101111111100000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000001888888888188888888818888888810000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000001888888888188888888818888888881000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000001888888888188888888818888888810000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000000111111111011111111101111111100000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000099a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000a5a5a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000aabaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000e99b99eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000eeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ee22ee22eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000040000ee2f22f22eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004000000fffffff222e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004500000f0ff0ff2f2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000054500000f0ff0fffa2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000054500000ecfffef2aeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f054500000ff88ff2eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaf4440ff0000ff22e11eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00faaaaaa55511111111111eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aa9ab995f555111111111eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f562655fff551111111eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005626555fff5111fffeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000056265f555fff1ffffeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000005265fff55ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000565555ff5fff55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000056500000f555ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000005265000011f11f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000052650000f11111ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000055265000ff111fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005626500ffff1ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000562650ffff5ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000562655fff5ffffff000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000056265fff5fffff550ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050055255ff5fffff5fff5ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
066505550fff5ffffffffff00f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
a489898989898989898989898989898989000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a481828080808080808080808080858689000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a491928080808080808080808080959689000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808089000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a480808080808080808080808080808289000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a483808080808080808080808084809289000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
