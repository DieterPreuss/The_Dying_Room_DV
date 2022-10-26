pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--the dying room

objs = {}  	-- a list of all the objects in the game (starts empty)
actor = {} 	-- all actors
wpns = {}  	-- list of weapons
wind = {}   -- list of text windows
scene=true -- keeps track of scenes playing at the moment
boss={ 					-- keeps track of the boss on screen
	number=1,
	alive=false
}
dirx={-1,1,0,0,1,1,-1,-1}
diry={0,0,-1,1,-1,1,1,-1} 

function _init()

	--create player
	player={
		name="aleksandr",
	 x=7,
	 y=10,
	 dx=0,
	 dy=0,
	 d="idle",
  sh=2,
  sw=2,
  --------------
  bounce=1,
  -- half-width and half-height
		-- slightly less than 0.5 so
		-- that will fit through 1-wide
		-- holes.
		w=0.4,
		h=0.4,
  -------------
  f=0,
  hp=4,
  dmg=0,
  dmg_cooldown=0,
  item="potion",
  weapon="spear",
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
 	name="spear",
 	x=player.x,
 	y=player.y,
 	cooldown=0,
 	dmg=1,
 	w=0.4,
		h=0.4,
 	sprt={
 		h={114,w=3,h=1}, 		
 		vu={66,w=1,h=3},
 		vd={67,w=1,h=3},
 	},
 }
 
 add(actor, spear)
 
 healthbar={
 	four={185,140,169},
 	three={185,140,141},
 	two={185,139,141},
 	one={155,132,141},
 	zero={0}
 }
 
 itembox={
 	potion={
 		sprt=171,
 		cooldown=0
 	},
 	bomb={
 		sprt=170,
 		cooldown=0
 	},
 	knife={
 		sprt=144,
 		cooldown=0
 	}
 }
 
 wpnbox={
 	spear={156, w=1, h=2},
 	sword={157, w=1, h=2}
 } 
 
 --create boss
 if (boss.alive==false and scene==false) then
 	spawn_boss(boss.number)
 	boss.alive=true
 	boss.number=boss.number+1 
 end
 
 --addwind(4*8, 12*8, 48, 20, {"linea1", "linea2"})
	--showmsg({"this is the 1st message", "", "this is the 2nd message"})
	
end

function _draw()
 
 if (scene==false) then
 cls()
	
	-- move camera to current room
	room_x = flr(player.x/16)
	room_y = flr(player.y/16)
	camera(room_x*128,room_y*128)
	
	-- draw the whole map (128⁙32)
	map()
	--map(0,0,0,0,7,7)
	print_centered(player.hp)
	print("dx: ", 10*8, 0)
	print(player.dx, 13*8, 0)
	print("dy: ", 10*8, 8)
	print(player.dy, 13*8, 8)
	print("x: ", 10*8, 16)
	print(player.x, 13*8, 16)
	print("y: ", 10*8, 24)
	print(player.y, 13*8, 24)
	--print_centered(spear.cooldown)
	--print_centered(wpnbox[player.weapon])
	
	-- draw the player
	if (player.hp!="0") then	
		spr(player.anims[player.d][2+(flr(player.f))],--*2)],      -- frame index
	 	player.x*8-4,player.y*8-4, -- x,y (pixels)
	 	2,2,player.d=="walkright"    -- w,h, flip
		)
	end
	
	draw_boss(1)
	
	draw_weapon()
	
	draw_gui()  
	
	drawind()
	
	end
	----prueba de escenas-------
	--[[
		cls()
		map(52, 0, 0, 0, 16, 16)
		addwind(0*8, 0*8, 48, 20, {"linea1", "linea2"})
	]]
	--escena derrota caballero--
	--[[
		cls()
		map(32, 0, 0, 0, 16, 16)
		--dark knight--
 	sspr( 0, 96, 32, 32, 65, 2, 60, 60 )
 	--spear--------
 	sspr( 32, 96, 32, 16, 45, 70, 60, 60,true)
	]]
	--escena despertar segunda fase-
		cls()
		map(72, 0, 0, 0, 16, 16)
		--first panel--
			--sword---
				sspr( 80, 88, 16, 8, 10, 40, 25, 15 )
				sspr( 96, 112, 8, 8, 35, 40, 15, 15 )
			--helmet--		
				sspr( 80, 96, 16, 16, 8, 6, 40, 40,true )
			--tears---
				sspr( 96, 120, 8, 8, 10, 15, 10, 5)
				sspr( 96, 120, 8, 8, 40, 35, 10, 5)
				sspr( 96, 120, 8, 8, 8, 59, 48, 5)
		----------------
		--second panel--
			--body--
				sspr( 80, 112, 16, 16, 62, 2, 60, 60)
			--sword edges--
				--sspr( 48, 96, 8, 8, 58, 50, 15, 15)
				sspr( 56, 96, 8, 8, 115, 40, 15, 15)
				sspr( 56, 104, 8, 8, 58, 45, 15, 15)
				sspr( 56, 112, 8, 8, 74, 52, 15, 15)
		----------------
		--third panel--
			--face----------
				sspr( 64, 96, 16, 16, 40, 74, 45, 45)
			--sword edges---
				sspr( 48, 96, 8, 8, 20, 74, 15, 15)
				sspr( 56, 96, 8, 8, 95, 74, 15, 15)
				sspr( 56, 104, 8, 8, 10, 94, 15, 15)
				sspr( 56, 112, 8, 8, 100, 104, 15, 15)
		----------------
	----------------------------
	
end

function _update()

 if(scene==false) then
    
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

	if (btn(🅾️) and spear.x<player.x+1 and spear.y<player.y+1 and spear.x>player.x-3 and spear.y>player.y-2 and spear.cooldown==0) then
		spear_attack()
		spear.cooldown=10
	end
	
	if (btn(❎) and itembox[player.item].cooldown==0) then		
		use_item(player.item)		
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
	------damage control-------

	---------------------------
	---------------------------
	
	-- friction (lower for more)
	player.dx *=.3
	player.dy *=.3
	
	------------cooldowns-----------------
	if(spear.cooldown!=0) spear.cooldown=spear.cooldown-1
	if(player.dmg_cooldown!=0) player.dmg_cooldown=player.dmg_cooldown-1
	if(itembox[player.item].cooldown!=0) itembox[player.item].cooldown=itembox[player.item].cooldown-1
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
        
end

function print_centered(str)
  print(str, player.x*8,player.y*8-9, 8) 
end

function draw_gui()
			
			
			--character
   spr(135,0,0,2,2)
   
   --healthbar
   vacumx=23
   if(player.hp==4) auxhp="four"
   if(player.hp==3) auxhp="three"
   if(player.hp==2) auxhp="two"
   if(player.hp==1) auxhp="one"
   
	 	if (player.hp!="0") then
				for v in all(healthbar[auxhp]) do
  			vacumx=vacumx+8
  			spr(v,vacumx,8,1,1)
				end 	
	 	else
	 		cls(6)
	 		print_centered('has muerto')
	 	end
	 	
	 	--itembox
	 	spr(itembox[player.item].sprt,22,0,1,1)
	 	if(itembox[player.item].cooldown!=0) print(itembox[player.item].cooldown, 22, 2)
	 	
	 	--hp
	 	spr(153,22,8,1,1)
	 	
	 	--weaponbox
	 	spr(wpnbox[player.weapon][1],14,0,1,2)
	 	if(spear.cooldown!=0) print(spear.cooldown, 16, 5)
	 
end

function draw_weapon()
			
			----sprite and position--------
			if (player.weapon=="spear") then
			
 			if (player.d== "walkleft") then
					if(spear.cooldown==0) then
						spear.x=player.x-2.5
 					spear.y=player.y
 				end
					sprt=spear.sprt.h
					switch=true
				elseif(player.d== "walkright") then
					if(spear.cooldown==0) then
						spear.x=player.x+0.1
						spear.y=player.y+0.5
					end
					sprt=spear.sprt.h
					switch=false
				elseif(player.d== "walkup") then
					if(spear.cooldown==0) then
						spear.x=player.x-1
 					spear.y=player.y-1.7
 				end
					sprt=spear.sprt.vu
					switch=false
				elseif(player.d== "walkdown") then
					if(spear.cooldown==0) then
						spear.x=player.x+0.6
 					spear.y=player.y+0.3
 				end
					sprt=spear.sprt.vd
					switch=true
				else
					if(spear.cooldown==0) then
						spear.x=player.x+0.6
 					spear.y=player.y+0.3
 				end
					sprt=spear.sprt.vd
					switch=true
				end
				-----------------------------	
			
				--spear
   	spr(sprt[1],
   	spear.x*8+2,
   	spear.y*8+1,
   	sprt.w,sprt.h,switch)
   end
	 
end

function spear_attack()

	for i=0,15 do
  if (player.d== "walkleft") then
  	spear.x=spear.x-(i*0.01) 
  end
  if (player.d== "walkright") then
  	spear.x=spear.x+(i*0.01) 
  end
  if (player.d== "walkup") then
  	spear.y=spear.y-(i*0.01) 
  end
  if (player.d== "walkdown") then
  	spear.y=spear.y+(i*0.01) 
  end
  if (player.d== "idle") then
  	spear.y=spear.y+(i*0.01) 
  end
	end
	 
end

function use_item(i)

	if(i=="potion") then
			player.hp=player.hp+1
			itembox[player.item].cooldown=60
	elseif(i=="bomb") then
			
			itembox[player.item].cooldown=120
	elseif(i=="knife") then
			
			itembox[player.item].cooldown=120
	end
		 
end


-->8
--collisions and damage

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
				if not ((a.name=="aleksandr" and a2.name=="spear") or (a.name=="dullahan" and a2.name=="sword")) then
					if (a.dmg_cooldown==0) then
						a.hp=a.hp-a2.dmg
						a.dmg_cooldown=20
					end	
				end
				-- moving together?
				-- this allows actors to
				-- overlap initially 
				-- without sticking together    
				
				-- process each axis separately
				
				-- along x
				if not ((a.name=="aleksandr" and a2.name=="spear") or a2.name=="sword") then
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


-------------------------------
------------damage dealing-------------------

--[[function damaging(x, y)
	-- grab the cel value
	val=mget(x, y)
	
	-- check if flag 1 is set (the
	-- orange toggle button in the 
	-- sprite editor)
	return fget(val, 2)
	
end

function damage_area(x,y,w,h)
	return 
		damaging(x-w,y-h) or
		damaging(x+w,y-h) or
		damaging(x-w,y+h) or
		damaging(x+w,y+h)
end

function check_damage(a, dx, dy)
	for a2 in all(wpns) do
			
		if (
			((abs(a.x) < (a2.x+a2.w)) and	(abs(a.x) > (a2.x-a2.w)))
			and
			((abs(a.y) < (a2.y+a2.h)) and	(abs(a.y) > (a2.y-a2.h))))
		then			
				-----------------------------
				a.hp=a.hp-a2.dmg
				-----------------------------		
		end
	end

end

function damage_a(a, dx, dy)
	if damage_area(a.x+dx,a.y+dy,
				a.w,a.h) then
				return true end
	return check_damage(a, dx, dy) 
end

function damage(a, dx, dy)
	if damage_area(a.x+dx,a.y+dy,a.w,a.h) then
				check_damage(a, dx, dy)
				return true 			
	else
	return false
	end
end
]]
-->8
--bosses

function spawn_boss(n)

	if (n==1) then
		--create boss 1
	boss1={
		name="dullahan",
	 x=7,
	 y=2,
	 dx=0,
	 dy=0,
	 d="idle",
  sh=2,
  sw=2,
  --------------
  bounce=2,
  -- half-width and half-height
		-- slightly less than 0.5 so
		-- that will fit through 1-wide
		-- holes.
		w=0.2,
		h=0.2,
  -------------
  f=0,
  hp=8,
  dmg=0.5,
  dmg_cooldown=0,
  cooldown={
  	attack1=0,
  	attack2=0
  },
  anims={
	  idle={fr=1,12,12,12,12,12},
			walkdown={fr=5,12,14,64,12,14,64},
			walkup={fr=5,44,46,96,44,46,96},
			walkleft={fr=5,38,40,42,38,40,42},
			walkright={fr=5,38,40,42,38,40,42},
  }
 }
 add(actor,boss1)
 
 -------------------------
 sword={
 	name="sword",
 	x=boss1.x,
 	y=boss1.y,
 	cooldown=0,
 	dmg=1,
 	w=0.5,
		h=3,
 	sprt={
 		h={186,w=4,h=1}, 		
 		vu={143,w=1,h=4},
 		vd={142,w=1,h=4},
 	},
 }
 
 add(actor, sword)
 
	end

end

function draw_boss(n)
	if (n==1) then
		
		ac=0.1 -- acceleration
		
		if not solid_a(boss1, boss1.dx, 0) then
			boss1.x += boss1.dx
		else
			boss1.dx *= -boss1.bounce
		end

		if not solid_a(boss1, 0, boss1.dy) then
			boss1.y += boss1.dy
		else
			boss1.dy *= -boss1.bounce
		end
		
		----------------------------
		----------------------------
		boss1_ia()
		----------------------------
		----------------------------
		
		-- friction (lower for more)
		boss1.dx *=.5
		boss1.dy *=.5
	
		spd=sqrt(boss1.dx*boss1.dx+boss1.dy*boss1.dy)
		boss1.f= (boss1.f+spd*2) % boss1.anims[boss1.d].fr -- 6 frames
		if (spd < 0.05) f=0
	
		------------cooldowns----------
		if(boss1.cooldown.attack1!=0) boss1.cooldown.attack1=boss1.cooldown.attack1-1
		if(boss1.dmg_cooldown!=0) boss1.dmg_cooldown=boss1.dmg_cooldown-1
		-------------------------------
	
		--------draw sprite------------
		if (boss1.hp>0) then
			spr(boss1.anims[boss1.d][2+(flr(boss1.f))],--*2)],      -- frame index
	 		boss1.x*8-4,boss1.y*8-4, -- x,y (pixels)
	 		2,2,boss1.d=="walkright"    -- w,h, flip
			)	
		else
			spr(192,
	 		boss1.x*8-4,boss1.y*8-4, -- x,y (pixels)
	 		4,4,boss1.d=="walkright"    -- w,h, flip
			)
		end
		-------------------------------		
	
		------------
		draw_boss_weapon(1)	
		------------
		
	end
end

function draw_boss_weapon(n)

	if (n==1) then
	
		if (boss1.d== "walkleft") then
				if(sword.cooldown==0) then
				--if not btn(🅾️) then
					sword.x=boss1.x-2.5
 				sword.y=boss1.y
 			end
				sprt=sword.sprt.h
				switch=true
			elseif(boss1.d== "walkright") then
				if(sword.cooldown==0) then
					sword.x=boss1.x+0.1
					sword.y=boss1.y+0.5
				end
				sprt=sword.sprt.h
				switch=false
			elseif(boss1.d== "walkup") then
				if(sword.cooldown==0) then
					sword.x=boss1.x-1
 				sword.y=boss1.y-1.7
 			end
				sprt=sword.sprt.vu
				switch=false
			elseif(boss1.d== "walkdown") then
				if(sword.cooldown==0) then
					sword.x=boss1.x+0.6
 				sword.y=boss1.y+0.3
 			end
				sprt=sword.sprt.vd
				switch=true
			else
				if(sword.cooldown==0) then
					sword.x=boss1.x+0.6
 				sword.y=boss1.y+0.3
 			end
				sprt=sword.sprt.vd
				switch=true
			end
			-----------------------------	
			
			--draw sword
			if(boss1.hp>0) then
   	spr(sprt[1],
   	sword.x*8+2,
   	sword.y*8+1,
   	sprt.w,sprt.h,switch)
   end
	
	end

end

function sword_attack()

	for j=0,15 do
  if (boss1.d== "walkleft") then
  	sword.x=sword.x-(j*0.01) 
  end
  if (boss1.d== "walkright") then
  	sword.x=sword.x+(j*0.01) 
  end
  if (boss1.d== "walkup") then
  	sword.y=sword.y-(j*0.01) 
  end
  if (boss1.d== "walkdown") then
  	sword.y=sword.y+(j*0.01) 
  end
  if (boss1.d== "idle") then
  	sword.y=sword.y+(j*0.01) 
  end
	end
	 
end

function boss1_ia()
	
	if(flr(boss1.x)!=flr(player.x))then
			if(
			(flr(boss1.x)<flr(player.x)) 
			and 
			((flr(player.x)-flr(boss1.x))>1)
			)then										
					boss1.dx+= ac
					boss1.d= "walkright"					
			elseif(
			(flr(boss1.x)>flr(player.x)) 
			and 
			((flr(boss1.x)-flr(player.x))>1)
			) then
					boss1.dx-= ac
					boss1.d= "walkleft"
			else --is in the right position and distance for atack
					if (sword.cooldown==0) then
							sword_attack()
							sword.cooldown=10
					end	
			end
	elseif(flr(boss1.y)!=flr(player.y)) then
			if(
			(flr(boss1.y)<flr(player.y)) 
			and 
			((flr(player.y)-flr(boss1.y))>1)
			)then
					boss1.dy+= ac
					boss1.d= "walkdown"
			elseif(
			(flr(boss1.y)>flr(player.y)) 
			and 
			((flr(boss1.y)-flr(player.y))>1)
			) then
					boss1.dy-= ac 
					boss1.d= "walkup"
			else
					if (sword.cooldown==0) then
							sword_attack()
							sword.cooldown=10
					end
			end 
	end
	
	if (sword.cooldown!=0) sword.cooldown=sword.cooldown-1
	
end
-->8
--scenes

function addwind(_x, _y, _w, _h, _txt)

	local w={
	x=_x, 
	y=_y, 
	w=_w, 
	h=_h, 
	txt=_txt
	}
	
	add(wind, w)
	return w

end

function rectfill2(_x,_y,_w,_h,_c)
 
 rectfill(_x,_y,_x+_w-1,_y+_h-1,_c)

end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end 
 print(_t,_x,_y,_c)
end

function drawind()

	for w in all(wind) do
	
		local wx, wy, ww, wh= w.x, w.y, w.w, w.h
		rectfill2(wx, wy, ww, wh, 0)
		rectfill2(wx+1, wy+1, ww-2, wh-2, 6)
		rectfill2(wx+2, wy+2, ww-4, wh-4, 1)
		
		wx+=4
		wy+=4
		clip(wx, wy, ww-8, wh-8)
		
		for i=1,#w.txt do
			
			local txt=w.txt[i]
			print(txt, wx, wy, 6)
			wy+=6
		
		end
		
		clip()
 
  if w.dur!=nil then
   w.dur-=1
   if w.dur<=0 then
    local dif=w.h/4
    w.y+=dif/2
    w.h-=dif
    if w.h<3 then
     del(wind,w)
    end
   end
  else
   if w.butt then
    oprint8("❎",wx+ww-15,wy-1+sin(time()),6,0)
   end
  end
 end
end

function showmsg(txt,dur)

 local wid=(#txt+2)*4+7 --50
 local w=addwind(63-wid/2,50,wid,13,{" "..txt})
 w.dur=dur
 
end
 
function showmsg(txt)

 talkwind=addwind(16,50,96,#txt*6+7,txt)
 talkwind.butt=true
 
end
__gfx__
00020028820022000020002882200002000000288220022000200028822000200000002882200020000000288220000200800808a808008000880808a8080008
0002029888a202000200029888920020000002988892020000020029888202000000002988820200000000298882002008808a8a9a8a808800088a8a9a8a8088
00002999899a2000002029998999200200002999899920020022029999aa20200000029999aa20200000029999aa202208808999b999808808008999b9998088
000229ff9ff92000002029ff9ff92020000029ff9ff9202000002999999a820000002999999a820000002999999a820000808119b911808088808119b9118080
20029fffffff920000029fffffff920202029fffffff920200000229999982000000022999998200000002299999820000081111a111180008881111a1111800
220299c7fc799200000299c7fc799202200299c7fc79920200002999999920000000299999992000000029999999200080081188288118000008118828811808
2222999cfc9992200022999cfc9992200222999cfc99922000002999999920000000299999992000000029999999200088081112221118088008111222111888
02a2299fff9922a202a2299fff9922a202a2299fff9922a2000029999a9920000000299a99992000000029999a99200088008211211280888800821121128008
029aa29444929a920299929444929a92029aa29444929a9200002994aaa200000000299aaa92000000002994aaa2000008081821112818088808882111288808
00299f11911f992000299f11911f992000299f11911f99200000292a99a20000000029259aa200020000292a99a2000000821165151112800882116515111280
00299999999999200029999999999920002999999999992000000229999200000020022599a20020002002299992000000821152511112800082115251111280
002f8f99999f8f22022f8f99999f8f20002f8f99999f8f200000002f89920000002002595f8f2020002202ff8992002000811515251511800081151525151180
002f82199912f820002ff2199912f820202f82199912ff200000002f8f2000000002255995f8f20000002ff89f52020000811811156811800081181115685580
002ff2119112ff20000222119112f822022f8211911222000000002ff12020000000255ff12ff20000002ff99155220000855821112855800008882111285580
000222ff1ff22200000002ff1ff2ff20002ff2ff1ff2000000000021112200000000022111d22000000002211fd5200000088821812888000000081181288800
000002dd2dd20000000000222dd22200000222dd222000000000002ddd200000000002552dd20000000002dd2dd2000000000811811800000000008881180000
00000022822000200000002282200000000000228220002000080808a808080000000808a808088000000808a808000008000808a808000008000808a8080000
0000029888a202000000029888a200020200029888a2020000888a8a9a8a800000008a8a9a8a880000008a8a9a8a800008808a8a9a8a800808808a8a9a8a8008
00002999899a200000002999899a202002002999899a200000088b999999800000008b999999800000008b999999800808808999999980880880899999998088
02002999999a200220002999999a202000202999999a202000008119991980000000811999198000000081199919808800808119991180880080811999118080
200299999999a2020202999999999200000299999999920200000881a111800000000881a111800000000881a111808800081111a111180000081111a1111800
02029999999992020202999999999200000299999999920200008111111180800000811111118000000081111111888000081111111118000008111111111800
20229999999992202022999999999220202299999999922000008111551288800000811111118000000081111111800080081111111118088008111111111800
02a22999999922a202a22999999922a202a22999999922a200008115225888000000811551118000000081111551800088008211111280888800821111128008
0299929555929a92029992955592aa92029992955592aa9200008125225880000000815225180008000081115225800088081822222818088808182222281808
00299959995999200029995999599920002999599959992000000881221800000008085222580088000808852225800800821111157112800082111115711280
00299599999599200229959999959920002995999995992000000081111800000088008522180088008800812258088800821111525112800082111152511280
022f859999958f20002f859999958f20002f859999958f2200000085115800000088085511118080008808111518088000811555251511800081155525151180
0028f21111128f20002ff21111128f220028f2111112ff2000000081558000000008855151115800000085111115880000811875511811800081187551181180
002ff2111112ff220002221111128f200228f2111112220000000081218000000000855121855800000085512115800000855821112855800008882111285580
000222ff9ff22200000002ff9ff2ff20002ff2ff9ff2000000000081218000000000088112188000000008821158000000088821812888000000081181285580
000002dd2dd20000000000222dd22200000222dd2220000000000081118000000000085581180000000008118558000000000811811800000000008881188800
00000808a80800080000000000009000000000000000000000000000000000000000000202002222000002222200200000000000000000000000000000000000
08008a8a9a8a808800700000000a9900000000000000a00000000074570000000000000020225552202024444220020000000000000000000000000000000000
08808999b999808800770000000090000000000000779a000000077547700000000022000255525220024444444220000000000a700000000000000000000000
00808119b91180800076700000009000000000000770a00000000077770000000000200025662552022445555444200000400049a40004000000000000000000
00081111a11118000076700000009000000000007700000000000070b70000000000020256626522002477755554200004490474474049400000000000000000
000811882881180000767000000090000000000666600000000000700700000000002025662665200024780780542000044404b44b4044400000000000000000
08081112221118000076700000009000000000555566000000000770077000000000025662665200002477777774202044944044440444440000000000000000
880082112112800000767000000090000000055555566000000070bb00070000000025662665200002a44676764422005444545aa54544940000000000000000
8808882111288808007a70000000900000000555555560000007bbbbbbbb700000a256626652200027ea476767442000544454ab7a4544440000000000000000
08821165151112800998aa000000900000000555555560000007bbbbbbbb70000aa56626652000009e2a4404444200005494559bba5544940000000000000000
00821152511112800099a000000090000000005555550000000733bbbb33700000a9626652020000299aa4004442000054440593ba5044440000000000000000
0081151525151180000a00000000a00000000005555000000000733333370000000ab665200000000229a7404742020055400559a55004440000000000000000
0085581115681180000a00000000a000000000000000000000000777777000000055a9520000000000027a400772002055400445555004440000000000000000
008558211128880000090000000a99000000000000000000000000000000000005440aaa00000000000024a77442020055400440054004440000000000000000
00088821811800000009000000aa899000000000000000000000000000000000554000a000000000000024477444200055500440054005440000000000000000
0000081188800000000900000007a700000000000000000000000000000000005400000000000000000024444a44420005500044044005400000000000000000
00000808a8080000000900000007670000000000000000000000000000000000000000000000000000000005500000000005555a000000000000000000000000
00008a8a9a8a800800090000000767000000000000000000000000000000000000000000000000000000005075500000000fff5aa00000000000000000007700
000089999999808800090000000767000000000000000000000000000000000000000000000000000000333003350000000bfb50aa0000000000000000007f70
000081199911808000090000000767000000000000000000000000004bb3000000000000004000000000833333350000000ffff0000000000000000000077ff0
00081111a1111800000900000007670000000000000000000000000433300000000000000454000000080000335500000055ff55f0000000000000000077f000
8008111111111800000900000000770000000000000000000000000400000000000000004540000000000000335000000f05555ff00000000000000994490000
88081111111118000099a00000000700000000000000000000008885822000000000000d5400000000000000035000001ff556ff100000000000999949440000
88008211111280000009000000000000000000000000000000087888882200000000005dd0000000000000000350000011f56551100000000009494999440000
080818222228180000000000000000000000000000000000000887888882000000000567700000000000000035000000011611114444a0000009999949400000
00821111157112800000000000000090000000000000000000088888888200000000567700000000000000035500000000611f4444444a000009949994400000
0082111152511280090000000000099777777770000000000008888888220000000567700000000000000005500000000704444444444aa00004994444000000
808115552515118099999999999aa98a666667000000000000002888822000000056770000000000000000333300000000040440554440a00000444440000000
80811875511811800a00000000000aa7777770000000000000000222220000000567700000000000000005555550000500440440055440000000000000000000
088558211128880000000000000000a0000000000000000000000000000000000777000000000000000003333333005400400400004044000000000000000000
00855821811800000000000000000000000000000000000000000000000000000000000000000000000555555555504000400400004004000000000000000000
00088811888000000000000000000000000000000000000000000000000000000000000000000000000333333333330000000400000004000000000000000000
6666666655555565444444446666666601111110555555655555556502222222222222002222222222222222011111100777777011111110000a900000022000
5555655555555565459999545444444518888881555555655555556502771717171772007717177277171772788888817bbbbbb7888888810004500000255200
5555655555555565966666694999999418888881555555655555556502711188111172007111117271111172788888817bbbbbb7888888810005400002566520
555565556666666604444440f999999f188888816444444444444446021119888a1112001111111211111112788888817bbbbbb7888888810004500002526520
6666666655333355040000400ffffff00111111049999999999999940271999899a1720071111172711111720111111007777770111111100005400025662652
55555556536666350481c3400444444000000000499999999999999402119ff9ff9112001111111211111112000000000000000000000000a009900a25626652
5555555663b66b360455554004000040000000009ffffffffffffff90279fffffff972007111117271111172000000000000000000000000099b399025662652
5555555603bbbb30044444400405504000000000044444444444444002199c7fc79912007717177271111172000000000000000000000000a0a7b90a25626652
2222222263bbbb360400004066600666000000000444444004444440027999cfc99972002222222211111112011111112222222222222222026a962025662652
77171772553333550481c34057999975000000000444444444444440021199fff991120072727772711111721888888877171772771917722562665225626652
71115472555335550455554050666605000000000000000000000000027119444911720077727072111111121888888871611172711411722566265225662652
11154512559aa95504444440506366050000000004444444444444400277171717177200727277227111117218888888116611121a141a122562665225626652
71567572660440660400004060667606000000000444444004444440022222222222220072727220771717720111111171656172719b91722566265225662652
15675112550440560481c34050766d060000000004444444444444400000000000000000222222002222222200000000116561121a252a122562665225626652
76751172550440560455554050d76606000000000500000000000050000000000000000000000000000000000000000071656172712521722566265225662652
77571772555005560400004050000006000000000405555555555040000000000000000000000000000000000000000071656172712521722562665225626652
000000000000000000000000000000000000000006555565555555605555556555565560777777702222222222222222117a7112112521122562665225662652
000000000000000000000000000000000000000060655565555556065555556566665560bbbbbbb777171772771717727998aa72712521722566265225626652
600000000000000600000000000000000000000056065565555560655555556555565560bbbbbbb77111a172716461721199a112112521122562665225662652
600000000000000600000000000000000000000055606666666606556666666655565560bbbbbbb7111611121116111271191172712521722566265225626652
56000000000000650000000000000000000000005556065555606555555655555556666077777770715551727166617277191772771217722562665225662652
560000000000006500000000000000000000000055566065560665555556555555565560000000001155511216bbb61222222222222222222566265225626652
66600000000006660000000000000000000000005556560660656666666666665556556000000000715551727166617200000000000000002562665225662652
0000000000000000000000000000000000000000555655600655655500000000555655600000000077171772771717720000000000000000256626520269a620
0000000000000000000000000000000000000000555655600655655500000000065565550777777700000a0a02222222222222222222000025626652a09b7a0a
0000000000000000000000000000000000000000666656066065655566666666065565557bbbbbbb00000092255555555555555555552200256626520993b990
0000000000000000000000000000000000000000555660655606655555556555065565557bbbbbbb0000009966666666666666666666552025626652a009900a
0000000000000000000000000000000000000000555606555560655555556555066665557bbbbbbb9545493b9626262626262626262626522566265200045000
00000000000000000000000000000000000000005560666666660655666666660655655507777777a45459b7a262626262626262626266520252652000054000
000000000000000000000000000000000000000056065555565560655655555506556555000000000000009a6666666666666666666655200256652000045000
00000000000000000000000000000000000000006065555556555606565555550655666600000000000000922555555555555555555522000025520000054000
0000000000000000000000000000000000000000065555555655556056555555065565550000000000000a0a022222222222222222220000000220000009a000
000000000000000000000000000000000000000000000000808888808000008002a2002aa2002a20000000000000000088808282a28280881111111122222222
0000000000000050505000000000000077777000000000000825626808088008029a22a99a22a920000a00000000000088882a2a9a2a28881111111122222222
00000000000000a5a5a000000000000076777700000000008825662880882808029999999999992000099000099a000008882999b99928881111111122222222
00000000000000aabaa0000000000000766777700000000088256268088528800299999b79999920000110000090100000882119b91128801111111122222222
0000000000000e99b99eee00000000007566777700000000082566288865288002eee993b99eee20001111000001100000821111a11118801111111122222222
000000000000eeeeeeeeeee000000000755667777000000008256288088528002eeeee9339eeeee2001100000111000080821188288112801111111122222222
000000000000eeeeeeeeeeee00000000775566777090000008258880008828002eeee2a99a22eee2001110000120000088821112221112881111111122222222
00000000000ee22ee22eeeee00000000077556997790000000888000000880002ee22ffaaff2eee2000211000000000088088211211288881111111122222222
00000090000ee2f22f22eeee0000000000775987990000000000000000008800eee2f88ff88f2eee000000000000000088881821112818884444444488888888
0000004000000fffffff222e0000000000077928900000000000000000000080eee2f82ff28f2eee000001000000000088821165151112884444444488888888
0000004500000f0ff0ff2f2e0000000000007799900000000000000000800828ee22ffffffff2eee000001100000000088821152511112884444444488888888
0000054500000f0ff0fffa2e0000000000000790990000000000000008008528ee29ffffffff92ee000001000000000008211515251511284444444488888888
0000054500000ecffcef2aeee000000000009900099000000000000008886528ee22fff88fff22ee000000000000000008211211156211284444444488888888
000f054500000ff88ff2eeeee000000000000000009900000000000000826580ee212ffffff212ee000000000000000000255821112855284444444488888888
00aaf4440ff0000ff22e11eee000000000000000000990000000000000886580222112ffff2112e2000000000000000000822821212822804444444488888888
00faaaaaa55511111111111eee000000000000000000990000000000000888002211111111111122000000000000000000088211211288004444444488888888
00aa9ab995f555111111111eeee000000000000000000990000000000800000000800808a808008008080808a808888022222222777777776666666699999999
000f562655fff551111111eeeee000000000000000000099000000008000008008808a8a9a8a808808888a8a9a8a880855555500777777776666666699999999
00005626555fff5111fffeeeee0000000000000000000009000000008800000808808999b9998088088889999999888866665000777777776666666699999999
000056265f555fff1ffffeeee00000000000000000000000000000000888808000808ee9b9ee808000888ee999ee888826262000777777776666666699999999
000005265fff55ffffff000000000000000000000000000000000000825628000008eeffaffee8000088ee2eaeeee80062650000777777776666666699999999
000000565555ff5fff55000000000000000000000000000000000000825662808008e270f70fe8000088ee2eeeeee80066500000777777776666666699999999
00000056500000f555ff0000000000000000000000000000000000008258888088082fffffffe80888882e2eeeee288855000000777777776666666699999999
000005265000011f11f10000000000000000000000000000000000000880000088008afffffe8088888882e22222888820000000777777776666666699999999
0000052650000f11111ff000000000000000000000000000000000000000000008081821f12818088888181121181888ccccccccffffffff55555555aaaaaaaa
000055265000ff111fffff00000000000000000000000000000000000000000000821165151112800882111115711288ccccccccffffffff55555555aaaaaaaa
00005626500ffff1ffffff00000000000000000000000000000000000000000000821152511112800882111152511288ccccccccffffffff55555555aaaaaaaa
0000562650ffff5ffffff000000000000000000000000000000000000000000000811515251511800881155525151188ccccccccffffffff55555555aaaaaaaa
0000562655fff5ffffff000ff00000000000000000000000000000000000000000811811156811800881187551181188ccccccccffffffff55555555aaaaaaaa
000056265fff5fffff550ffff00000000000000000000000000000000000000000855821112855800885582111285588ccccccccffffffff55555555aaaaaaaa
050055255ff5fffff5fff5ffff0000000000000000000000000000000000000000088821812888000088882181288880ccccccccffffffff55555555aaaaaaaa
066505550fff5ffffffffff00f0000000000000000000000000000000000000000000811811800000008881181188800ccccccccffffffff55555555aaaaaaaa
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000020000000000000000000000
0000020200000000000000000000000200020202000202000000000000000006020200000000000202000000000002000000000000000002020000000202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
a58182a7a7a7a7a0a1a7a7a7a78586a600000000000000000000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000fecfcffececececec0c0ceceeefefefe00000000cececececececececececececececece00000000000000000000000000000000000000000000000000000000000000000000000000000000
a89192808080808080808080809596b800000000000000000000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000cfcececfc0c0c0c0c0c0c0ceeeeeeeee00000000cefefefeeeeefececfcfcfcfcfcfcfce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000eecfcfcecfc0c0dfdfdfc0c0fefeeefe000000c0cefefefeeeeefececfcfcfcfcfcfcfce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000c0c0c0dfdfc0c0c0c0c0c0c0c0c0c0c000000000eeeeeecfcecfc0c0dfc0c0c0eeeecfcf00000000cefefefeeeeefececfcfcfcfcfcfcfce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000c0c0dfdfdfc0c0c0c0c0c0c0c0c0c0c000000000fefeeecfcfcecec0c0c0c0c0fecfcecf00000000cefefefeeeeefececfcfcfcfcfcfcfce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000c0dfdfffffc0c0c0c0c0c0c0c0c0c0c000000000eeeeeecfdfdfcec0c0c0c0cfcfcecfee00000000ceeeeeeeeeeeeececfcfcfcfcfcfcfce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000dedfefefefffc0c0c0c0c0c0c0c0c0c000000000eefefedfdfdfcecec0cecfcececfeefe00000000ceeeeeeeeeeeeececfcfcfcfcfcfcfce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000dfefefefefefefc0cfcfcfcfcfcfcfc000000000cecedfdfffffcececececececececece00000000cefefefefefefececfcfcfcfcfcfcfce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000efefefefefefc0c0c0cfcfcfcfcfc0c000000000eededfefefefffcecececeeeeeeeeeee00000000cececececececececececececececece00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000efefefefefefefc0c0c0c0c0c0c0c0c000000000dedfefefefefefeffefefefefefefefe00000000cec0c0c0c0dfdfdfdfdfdfc0c0c0c0ce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000efefefefefefefc0c0c0c0c0c0c0c0c000000000deefefefefefefeeeeeeeeeeeeeeeeee00000000cec0c0c0c0dfdfdfdfdfdfc0c0c0c0ce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000efefefefdeffffffffffc0c0c0c0c0c000000000deefefefefefefeffefefefefefefefe00000000cec0c0c0dfdfdfdfdfdfdfdfc0c0c0ce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000deefdededeefefefffc0c0c0c0c0c0c000000000deefefefefefefefeeeeeeeeeeeeeeee00000000cec0c0c0dfdfdfdfdfdfdfdfc0c0c0ce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a88080808080808080808080808080b800000000000000000000000000000000efdeefefdeefefefffc0c0c0c0c0c0c000000000ffefefefefeffffffffffffefefefefe00000000cec0c0c0dfdfdfdfdfdfdfdfc0c0c0ce00000000000000000000000000000000000000000000000000000000000000000000000000000000
a89383808080808080808080808080b800000000000000000000000000000000efefefefefdedffdfdc0c0c0c0c0c0c000000000dedeefdedeefefefefffeeeeeeeeeeee00000000cec0c0c0dfdfdfdfdfdfdfdfc0c0c0ce00000000000000000000000000000000000000000000000000000000000000000000000000000000
b5b7b7b7b7b7b7b7b7b7b7b7b7b7b7b600000000000000000000000000000000efefefefefc0dfdffdc0c0c0c0c0c0c000000000efefdeefefefefefefffcfcfcfcfcfcf00000000cececececececececececececececece00000000000000000000000000000000000000000000000000000000000000000000000000000000
