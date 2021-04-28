local ROOM_H = 18
local ROOM_W = 24
-- "room mod": num rooms per
-- map row
local ROOM_M = 5

-- flag meanings
-- collide and block
local F_COLL_BLOCK = 0x1
-- collide and grab
local F_COLL_GRAB = 0x2

local SFX_COLL_BLOCK = 1
local SFX_COLL_OOB = 2
local SFX_GRAB = 3
local SFX_DROP = 4

local dbg_player = false
local dbg_items = true

-- player
local pl = {
  spr = 16,
  -- room, cell x, cell y
  pos = {0, 12, 1},
}

local objs = {
  -- indexed by sprite num
  [17] = {
    name = "sword",
    has = false,
  },
}

function _init()
 -- key repeat delay
	poke(0x5f5d, 3)
end

function do_move()
 local d = {pl.pos[2], pl.pos[3]}
 
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
	 
	local rc = {
	 pl.pos[1] % ROOM_M,
	 flr(pl.pos[1] / ROOM_M)
	}

  local dcxy = {
			rc[1]*ROOM_W + d[1], 
			rc[2]*ROOM_H + d[2]
  }

  local mspr = mget(dcxy[1], dcxy[2])
	
	local f = fget(mspr)

	if f & F_COLL_BLOCK == F_COLL_BLOCK then
	 sfx(SFX_COLL_BLOCK)
	 return
	end

	if f & F_COLL_GRAB == F_COLL_GRAB then
	 sfx(SFX_GRAB)
   objs[mspr].has = true
   mset(dcxy[1], dcxy[2], 0)
	end
	
	local d_r = -1
	if d[1] < 0 then
		d[1] = ROOM_W - 1
		d_r = room_link[pl.pos[1]]["w"]
	elseif d[1] >= ROOM_W then
	 d[1] = 0
	 d_r = room_link[pl.pos[1]]["e"]
	elseif d[2] < 0 then
	 d[2] = ROOM_H - 1
	 d_r = room_link[pl.pos[1]]["n"]
	elseif d[2] >= ROOM_H then
	 d[2] = 0
	 d_r = room_link[pl.pos[1]]["s"]
	-- todo: check coll with
	-- stairs 	
	end
	if d_r == nil then
	 sfx(SFX_COLL_OOB)
	 return
	end 
	pl.pos[2] = d[1]
	pl.pos[3] = d[2]
	if (d_r != -1) pl.pos[1] = d_r 
end

function do_action()
	if (btnp(4)) then
    local did_drop = false
    for i,v in pairs(objs) do
      if v.has then
        v.has = false
        did_drop = true
        local rc, pcxy = pos2rcxy(pl.pos)
        mset(pcxy[1], pcxy[2], i)
        sfx(SFX_DROP)
        goto done
      end
    end
    ::done::
    if not did_drop then
        sfx(SFX_COLL_OOB)
    end
  end
end

function _update()
 do_move()
 do_action()
end

-- room num, cell x, cell y -> {room row,col}, x,y
function pos2rcxy(pos) 
	local rc = {
	 pos[1] % ROOM_M,
	 flr(pos[1] / ROOM_M)
	}
	local w = {
   rc[1]*ROOM_W + pos[2],
   rc[2]*ROOM_H + pos[3],
	}
	return 
    rc,
    w
end

function _draw()
	cls()
  pal()
	
  local rc, pcxy = pos2rcxy(pl.pos)
  local pxy = {
      8*pcxy[1],
      8*pcxy[2]
  }
	local cam_bnd = {
	 (rc[1])*ROOM_W*8+64,
	 (rc[2])*ROOM_H*8+64,
	 (rc[1]+1)*ROOM_W*8-64,
	 (rc[2]+1)*ROOM_H*8-64
	}
	
	local cam_tgt = {
		max(
			min(pxy[1], cam_bnd[3]), 
			cam_bnd[1]
		),
		max(
			min(pxy[2], cam_bnd[4]), 
			cam_bnd[2]
		),
	}
	

	local mc = {
		rc[1]*ROOM_W,
		rc[2]*ROOM_H
	}		

	camera(cam_tgt[1] - 64, cam_tgt[2] - 64)
  map(0,0, 0,0, 128,64)

	spr(pl.spr, pxy[1], pxy[2])

  if dbg_player then
    camera()
    color(14)
     print(
      pl.pos[1]..","..pl.pos[2]..","..pl.pos[3]
      ..">"..pxy[1]..","..pxy[2]
       .." rc:"..rc[1]..","..rc[2],
       0,112
     )
     print(
      "mc:"..mc[1]..","..mc[2]
      .." cam:"..cam_tgt[1]..","..cam_tgt[2],
       0,120
     )
  end
  if dbg_items then
    camera()
    pal(6, 14)
    local x = 0
    for i,v in pairs(objs) do
      if v.has then
        spr(i, x*8 % 128, flr(x*8/128))
        x += 1
      end
    end
  end
end
