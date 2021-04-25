local room_h = 18
local room_w = 24
-- "room mod": num rooms per
-- map row
local room_m = 5

-- flag meanings
-- collide
local f_coll = 0

-- player
pl = {}
-- room
pl.r = 0
pl.c = {12, 1}

function _init()
 -- key repeat delay
	poke(0x5f5d, 3)
end

function do_move()
 local d = {pl.c[1], pl.c[2]}
 
	if (btnp(⬆️)) then
		d[2] -= 1
	elseif (btnp(⬇️)) then
	 d[2] += 1
	elseif (btnp(⬅️)) then
	 d[1] -= 1
	elseif (btnp(➡️)) then
	 d[1] += 1
	else
	 return
	end
	 
	rc = {
	 pl.r % room_m,
	 flr(pl.r / room_m)
	}
	
	local coll = fget(mget(
			rc[1]*room_w + d[1], 
			rc[2]*room_h + d[2]
		), 
	 f_coll
	)
	if coll then
	 sfx(1, 0)
	 return
	end
	
	local d_r = -1
	if d[1] < 0 then
		d[1] = room_w - 1
		d_r = room_link[pl.r]["w"]
	elseif d[1] >= room_w then
	 d[1] = 0
	 d_r = room_link[pl.r]["e"]
	elseif d[2] < 0 then
	 d[2] = room_h - 1
	 d_r = room_link[pl.r]["n"]
	elseif d[2] >= room_h then
	 d[2] = 0
	 d_r = room_link[pl.r]["s"]
	-- todo: check coll with
	-- stairs 	
	end
	if d_r == nil then
	 sfx(2)
	 return
	end 
	pl.c[1] = d[1]
	pl.c[2] = d[2]
	if (d_r != -1) pl.r = d_r 
end

function _update()
 do_move()
end

function _draw()
	cls()
	
  -- room cell
	local rc = {
	 pl.r % room_m,
	 flr(pl.r / room_m)
	}
	
	local w = {
   rc[1]*room_w + pl.c[1],
   rc[2]*room_h + pl.c[2],
	}
	local p = {
		8*w[1],
		8*w[2]
	}
	local cam_bnd = {
	 (rc[1])*room_w*8+64,
	 (rc[2])*room_h*8+64,
	 (rc[1]+1)*room_w*8-64,
	 (rc[2]+1)*room_h*8-64
	}
	
	local cam_tgt = {
		max(
			min(p[1], cam_bnd[3]), 
			cam_bnd[1]
		),
		max(
			min(p[2], cam_bnd[4]), 
			cam_bnd[2]
		),
	}
	

	local mc = {
		rc[1]*room_w,
		rc[2]*room_h
	}		

	camera(cam_tgt[1] - 64, cam_tgt[2] - 64)
  map(0,0, 0,0, 128,64)

	spr(1, p[1], p[2])


 camera()

 color(14)

 -- print("\^p"..
 --  pl.r..","..pl.c[1]..","..pl.c[2]
 --  ..">"..w[1]..","..w[2]
 --  ..">"..p[1]..","..p[2]
 -- 	.." rc:"..rc[1]..","..rc[2],
 -- 	0,112
 -- )
 -- print(
 --  "mc:"..mc[1]..","..mc[2]
 --  .." cam:"..cam_tgt[1]..","..cam_tgt[2],
 -- 	0,120
 -- )

end
