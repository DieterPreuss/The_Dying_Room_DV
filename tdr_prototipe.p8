pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--the dying room

objs = {}  --a list of all the objects in the game (starts empty)
actor = {} -- all actors
wpns = {}  --list of weapons


function _init()

	--create player
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
 add(actor,player)
 
 --create spear

 spear={
 	x=player.x,
 	y=player.y,
 	sprt={
 		h={160,w=3,h=1},
 		v={147,w=1,h=3},
 	},
 }
 
 add(wpns, spear)  
	
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
	
 draw_spear()
	
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
	if (btn(🅾️)) then
		spear_attack()
	end
	if (btn(❎)) then

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
	player.dx *=.3
	player.dy *=.3
	
	-----------------------------
	
	-----------------------------
	
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
			
			--------------sprite and position---------------
			spear.x=player.x
 		spear.y=player.y
 		if (player.d== "walkleft") then
				sprt=spear.sprt.h
				switch=true
			elseif(player.d== "walkright") then
				sprt=spear.sprt.h
				switch=false
			elseif(player.d== "walkup") then
				sprt=spear.sprt.v
				switch=false
			elseif(player.d== "walkdown") then
				sprt=spear.sprt.v
				switch=true
			else
				sprt=spear.sprt.v
				switch=true
			end
			-----------------------------	
			
			--character
   spr(sprt[1],
   spear.x*8+2,
   spear.y*8+1,
   sprt.w,sprt.h,switch)
	 
end

function spear_attack()

	for i=0,15 do
  if (player.d== "walkleft") then
  	spear.x=spear.x+i
  end
  if (player.d== "walkright") then
  	spear.x=spear.x-i
  end
  if (player.d== "walkup") then
  	spear.y=spear.y+i
  end
  if (player.d== "walkdown") then
  	spear.y=spear.y-i
  end
  if (player.d== "idle") then
  	spear.y=spear.y-i
  end
	end
	 
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
00020028820022000020002882200002000000288220022000200028822000200000002882200020000000288220000200000000a000000000000000a0000000
0002029888a202000200029888920020000002988892020000020029888202000000002988820200000000298882002000000a0a9a0a000000000a0a9a0a0000
00002999899a2000002029998999200200002999899920020022029999aa20200000029999aa20200000029999aa202200000999b999000000000999b9990000
000229ff9ff92000002029ff9ff92020000029ff9ff9202000002999999a820000002999999a820000002999999a820000000119b911000000000119b9110000
20029fffffff920000029fffffff920202029fffffff920200000229999982000000022999998200000002299999820000001111a111100000001111a1111000
220299c7fc799200000299c7fc799202200299c7fc79920200002999999920000000299999992000000029999999200000001100000110000000110000011000
2222999cfc9992200022999cfc9992200222999cfc99922000002999999920000000299999992000000029999999200000001110001110000000111000111000
02a2299fff9922a202a2299fff9922a202a2299fff9922a2000029999a9920000000299a99992000000029999a99200000000211011200000000021101120000
029aa29444929a920299929444929a92029aa29444929a9200002994aaa200000000299aaa92000000002994aaa2000000001021012010000000002101200000
00299f11911f992000299f11911f992000299f11911f99200000292a99a20000000029259aa200020000292a99a2000000021165151112000002116515111200
00299999999999200029999999999920002999999999992000000229999200000020022599a20020002002299992000000021152511112000002115251111200
002f8f99999f8f22022f8f99999f8f20002f8f99999f8f200000002f89920000002002595f8f2020002202ff8992002000011515251511000001151525151100
002f82199912f820002ff2199912f820202f82199912ff200000002f8f2000000002255995f8f20000002ff89f52020000011011156011000001101115605500
002ff2119112ff20000222119112f822022f8211911222000000002ff12020000000255ff12ff20000002ff99155220000055021112055000000002111205500
000222ff1ff22200000002ff1ff2ff20002ff2ff1ff2000000000021112200000000022111d22000000002211fd5200000000021012000000000001101200000
000002dd7dd20000000000222dd22200000222dd222000000000002ddd200000000002552dd20000000002dd2dd2000000000011011000000000000001100000
00000022822000200000002282200000000000228220002000000000a000000000000000a000000000000000a000000000000000a000000000000000a0000000
0000029888a202000000029888a200020200029888a2020000000a0a9a0a000000000a0a9a0a000000000a0a9a0a000000000a0a9a0a000000000a0a9a0a0000
00002999899a200000002999899a202002002999899a200000000b999999000000000b999999000000000b999999000000000999999900000000099999990000
02002999999a200220002999999a202000202999999a202000000119991900000000011999190000000001199919000000000119991100000000011999110000
200299999999a2020202999999999200000299999999920200000001a111000000000001a111000000000001a111000000001111a111100000001111a1111000
02029999999992020202999999999200000299999999920200000111111100000000011111110000000001111111000000001111111110000000111111111000
20229999999992202022999999999220202299999999922000000111551200000000011111110000000001111111000000001111111110000000111111111000
02a22999999922a202a22999999922a202a22999999922a200000115225000000000011551110000000001111551000000000211111200000000021111120000
0299929555929a92029992955592aa92029992955592aa9200000125225000000000015225100000000001115225000000001022222010000000102222201000
00299959995999200029995999599920002999599959992000000001221000000000005222500000000000052225000000021111157112000002111115711200
00299599999599200229959999959920002995999995992000000001111000000000000522100000000000012250000000021111525112000002111152511200
022f859999958f20002f859999958f20002f859999958f2200000005115000000000005511110000000000111510000000011555251511000001155525151100
0028f21111128f20002ff21111128f220028f2111112ff2000000001550000000000055151115000000005111115000000011075511011000001107551101100
002ff2111112ff220002221111128f200228f2111112220000000001210000000000055121055000000005512115000000055021112055000000002111205500
000222ff9ff22200000002ff9ff2ff20002ff2ff9ff2000000000001210000000000000112100000000000021150000000000021012000000000001101205500
000002dd2dd20000000000222dd22200000222dd2220000000000001110000000000005501100000000000110550000000000011011000000000000001100000
00000000a00000000000000000000000000000000000000000000000000000000000000202002222000002222200200000000000000000000000000000055550
00000a0a9a0a000000000000000000000000000000000000000000000000a000000000002022555220202444422002000000000000000000000000000054bb35
00000999b9990000000000000000000000000000000000000000000000779a00000022000255525220024444444220000000000a700000000000000005433350
00000119b911000000000000000000000000000000000000000000000770a0000000200025662552022445555444200000400049a40004000000000555455500
00001111a11110000000000000000006000000000000000000000000770000000000020256626522002477755554200004490474474049400000005888582250
000011000001100000000000000006660000000000000000000000066660000000002025662665200024780780542000044404b44b4044400000058788888225
00001110001110000000000000666760000000000000000000000055556600000000025662665200002477777774202044944044440444440000058878888825
0000021101120000000000000677760000000000000000000000055555566000000025662665200002a44676764422005444545aa54544940000058888888825
000000210120000000000000677776000000000000000000000005555555600000a256626652200027ea476767442000544454ab7a4544440000058888888225
00021165151112000000000677776000000000000600000000000555555560000aa56626652000009e2a4404444200005494559bba5544940000005288882250
000211525111120000000067777600000000000006600000000000555555000000a9626652020000299aa4004442000054440593ba5044440000000522222500
0001151525151100000006777776000000000000066000000000000555500000000ab665200000000229a7404742020055400559a55004440000000055555000
00055011156011000000677777600000000000000666000000000000000000000055a9520000000000027a400772002055400445555004440000000000000000
000550211120000000006777776000000000000066760000000000000000000005440aaa00000000000024a77442020055400440054004440000000000000000
0000002101100000000067777760000000000000677660000000000000000000554000a000000000000024477444200055500440054005440000000000000000
00000011000000000006777777600000000000066777600000000000000000005400000000000000000024444a44420005500044044005400000000000000000
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
66666666666666664444444466666666666006665555556555555565022222222222220022222222222222220777777777077777777707777777700000000000
55556555555565554599995454444445579999755555556555555565027707070707720077070772277070777bbbbbbbbb7bbbbbbbbb7bbbbbbbb70000000000
55556555555565559666666949999994506666055555556555555565027000880000720070000072270000077bbbbbbbbb7bbbbbbbbb7bbbbbbbb70000000000
555565555555655504444440f999999f506366056444444444444446020009888a00020000000002200000007bbbbbbbbb7bbbbbbbbb7bbbbbbbb70000000000
6666666666333366040000400ffffff06066760649999999999999940270999899a0720070000072270000070777777777077777777707777777700000000000
55555556536666360481c3400444444050766d06499999999999999402009ff9ff90020000000002200000000000000000000000000000000000000000000000
5555555653b66b36045555400400004050d766069ffffffffffffff90279fffffff9720070000072270000070000000000000000000000000000000000000000
5555555653bbbb36044444400405504050000006044444444444444002099c7fc799020077070772270000070000000000000000000000000000000000000000
0000000063bbbb360400004000000000000090000444444004444440027999cfc999720022222222200000000777777777077777777701111111100000000000
00000000553333550481c34000700000000a99000444444444444440020099fff990020072727772270000077bbbbbbbbb7bbbbbbbbb78888888810000000000
00000000555335550455554000770000000090000000000000000000027009444900720077727072200000007bbbbbbbbb7bbbbbbbbb78888888810000000000
00000000559aa9550444444000767000000090000444444444444440027707070707720072727722270000077bbbbbbbbb7bbbbbbbbb78888888810000000000
00000000660440660400004000767000000090000444444004444440022222222222220072727220277070770777777777077777777701111111100000000000
00000000550440560481c34000767000000090000444444444444440000000000000000022222200222222220000000000000000000000000000000000000000
00000000550440560455554000767000000090000500000000000050000000000000000000000000000000000000000000000000000000000000000000000000
00000000555005560400004000767000000090000405555555555040000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000007a7000000090000655556555555560555555655556556000000000065565550777777777011111111101111111100000000000
0000000000000090000000000998aa00000090006065556555555606555555656666556066666666065565557bbbbbbbbb788888888818888888810000000000
0900000000000997777777700099a000000090005606556555556065555555655556556055556555065565557bbbbbbbbb788888888818888888810000000000
99999999999aa98a66666700000a00000000a0005560666666660655666666665556556055556555066665557bbbbbbbbb788888888818888888810000000000
0a00000000000aa777777000000a00000000a0005556065555606555555655555556666066666666065565550777777777011111111101111111100000000000
00000000000000a00000000000090000000a99005556606556066555555655555556556056555555065565550000000000000000000000000000000000000000
0000000000000000000000000009000000aa89905556560660656666666666665556556056555555065566660000000000000000000000000000000000000000
000000000000000000000000000900000007a7005556556006556555000000005556556056555555065565550000000000000000000000000000000000000000
00000000000000000000000000090000000767005556556006556555222222222222222222222222000000000111111111011111111101111111100000000000
00000000000000000000000000090000000767006666560660656555770707727707077277070772000000001888888888188888888818888888810000000000
000000000000000000000000000900000007670055566065560665557000a0727064607270005472000000001888888888188888888818888888810000000000
00000000000000000000000000090000000767005556065555606555000600020006000200054502000000001888888888188888888818888888810000000000
00000000000000000000000000090000000767005560666666660655705550727066607270567572000000000111111111011111111101111111100000000000
000000000000000000000000000900000000770056065555565560650055500206bbb60205675002000000000000000000000000000000000000000000000000
0000000000000000000000000099a000000007006065555556555606705550727066607276750072000000000000000000000000000000000000000000000000
00000000000000000000000000090000000000000655555556555560770707727707077277570772000000000000000000000000000000000000000000000000
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
0000000202000000000000000000000000000000000202000000000000000000000000000000000202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
a5a7a7a7a7a7a7a7a7a7a7a7a78586a600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88182808080808080808080809596aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a89192808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a88483808080808080808080808080aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b5a9a9a9a9a9a9a9a9a9a9a9a9a9a9b600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
