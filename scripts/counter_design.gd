# Approved counter composition. Geometry and artwork are independent of recipes.
# Coordinates use the original 480x270 game space; all input modes share j_ST.
extends "res://scripts/game_sprites.gd"
var counter_design_enabled := not "--legacy-counter" in OS.get_cmdline_user_args()
var counter_base: Variant

func _ready() -> void:
	super._ready()
	if not counter_design_enabled: return
	var positions := {
		"spit":Rect2(46,48,44,128), "uncle":Rect2(2,128,42,132),
		"phone":Rect2(4,30,26,28),
		"meat":Rect2(108,153,44,32), "pickle":Rect2(152,153,44,32),
		"yogurt":Rect2(196,153,44,32), "friesT":Rect2(240,153,44,32),
		"garnish":Rect2(284,153,44,27),
		"bread":Rect2(80,194,48,40), "board":Rect2(130,187,150,48),
		"paper":Rect2(308,208,24,27), "sauce":Rect2(288,180,44,27),
		"fryer":Rect2(336,153,51,43), "grill":Rect2(391,151,48,45),
		"cut":Rect2(336,198,51,37), "fbox":Rect2(391,199,46,36),
		"drinkM":Rect2(418,92,56,58), "ayran":Rect2(461,108,13,54),
		"sweet":Rect2(440,175,34,27), "potato":Rect2(391,241,46,28),
		"crate":Rect2(337,241,49,28), "trash":Rect2(442,218,31,50)}
	for key in positions:
		var r: Rect2 = positions[key]
		j_ST[key] = {"x":r.position.x,"y":r.position.y,"w":r.size.x,"h":r.size.y}
	j_LAY.spit = {"cx":66.0,"top":56.0,"bot":174.0}
	j_LAY.win = {"x":126.0,"y":28.0,"w":300.0,"h":103.0}
	j_LAY.glass = {"x":130.0,"y":32.0,"w":292.0,"h":95.0}
	j_ST.shutter = j_LAY.win.duplicate()
	j_LAY.ledgeY=140.0; j_LAY.ledgeH=10.0; j_LAY.surfY=150.0
	j_LAY.lipY=237.0; j_LAY.floorY=270.0
	j_CLAYER=null; j_STONEFG=null
	shop_background.f_bakeBG(equipment_system.f_UV(j_G,"paint"))
	counter_base=sprite_library.get_sprite("counter/design")

func tun_design(key: String) -> Variant: return J.method(j_TUN,key,[j_G])

func counter_theme() -> int:
	# New Game deliberately clears customization before entering the intro.
	var custom: Variant = j_G.get("custom")
	return posmod(int(custom.get("counter", 0)), j_COUNTER_PAL.size()) if custom is Dictionary else 0

func wood(x: float,y: float,w: float,h: float,light := false) -> void:
	f_fr(x,y,w,h,"#5b3822")
	f_fr(x+1,y+1,w-2,h-2,"#a96f3a" if light else "#875126")
	f_hl(x+1,y+1,w-2,"#e1b17a" if light else "#b58248")
	f_vl(x+1,y+2,h-3,"#bc8851" if light else "#9e6837")
	for i in range(4,int(w)-3,7):
		var tone := "#b8844c" if light else "#956030"
		f_vl(x+i,y+3,h-6,tone)
		var yy := y+3+fmod(i*7.0,maxf(1,h-8))
		f_vl(x+i+1,yy,minf(8,y+h-3-yy),"#c0905b" if light else "#774622")

func f_drawCounterRaw() -> Variant:
	if not counter_design_enabled: return super.f_drawCounterRaw()
	# One steel worktop, a quiet wooden fascia and two cooking-zone drawers.
	f_fr(32,148,448,121,"#392a21")
	for x in [34,101,168,235,302]:
		wood(x,241,64,29)
		f_rrect(x+43,247,14,3,1,"#393b3c")
		f_hl(x+44,247,12,"#b8b9b4")
	for y in [241,256]:
		f_fr(336,y,51,13,"#52595e")
		f_fr(337,y+1,49,10,"#90999c")
		f_hl(338,y+1,47,"#cbd0ca")
		f_fr(351,y+3,18,3,"#41484b")
	wood(391,240,46,30)
	var theme := counter_theme()
	var steel: String = "#91999b" if theme == 0 else j_COUNTER_PAL[theme].base
	f_fr(32,150,448,86,steel)
	for y in range(151,236,4):
		f_hl(33,y,446,character_draw.f_shadeCol(steel,1.02 if y%8 == 7 else 1.04))
	# Brushed metal wear is deterministic and doesn't consume game randomness.
	for i in 65:
		var x := 34+fmod(i*97.0,436)
		var y := 151+fmod(i*23.0,81)
		f_hl(x,y,minf(14,476-x),character_draw.f_shadeCol(steel,1.08 if i%2 == 0 else .97))
	f_fr(32,236,448,5,"#444e52")
	f_hl(32,236,448,"#edf0dc")
	f_hl(32,237,448,"#bcc5c3")
	f_hl(32,239,448,"#6c7a80")
	f_fr(33,140,443,10,"#bea775")
	f_hl(33,140,443,"#f3dfb4")
	f_hl(33,142,443,"#e0c593")
	f_hl(33,148,443,"#8f7950")
	# Spit drip tray and the cold rail share the same visible rim and depth.
	f_fr(40,174,63,17,"#4e585d")
	f_fr(42,176,59,10,"#7d898e")
	f_hl(40,174,63,"#e0e5d9")
	f_hl(40,190,63,"#c0c9c3")
	f_fr(104,150,182,36,"#67747b")
	f_hl(104,150,182,"#dce2d8")
	f_hl(104,185,182,"#d1d8cc")
	return null

func f_drawCounter() -> Variant:
	if counter_design_enabled and counter_base != null and counter_theme() == 0:
		j_ctx.drawImage(counter_base,0,0)
		return null
	return super.f_drawCounter()

func f_drawCounterProps(time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawCounterProps(time)
	# A narrow service bay in front of the counter keeps the complete chef visible.
	f_fr(0,128,44,142,"#44372c")
	f_fr(2,130,40,138,"#65533e")
	f_vl(42,128,141,"#ad9266")
	f_hl(2,265,40,"#b7935e")
	if shop_background.f_dayiVar() and (j_G.courier == null or j_G.courier.state == "in"):
		j_ctx.save()
		j_ctx.translate(4,130)
		j_ctx.scale(0.82,0.82)
		super.f_drawChef(0,0,j_G.chef,time)
		j_ctx.restore()
	return null

func f_drawChef(x: Variant = null,y: Variant = null,state: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawChef(x,y,state,time)
	# Draw after the counter in f_drawCounterProps, instead of behind its worktop.
	return null

func f_drawPoster(kind: Variant = null,time: Variant = null,x: Variant = null,y: Variant = null) -> Variant:
	if not counter_design_enabled or x != null: return super.f_drawPoster(kind,time,x,y)
	j_ctx.save()
	j_ctx.translate(95,53)
	j_ctx.scale(0.64,0.64)
	var result: Variant = super.f_drawPoster(kind,time,0,0)
	j_ctx.restore()
	return result

func f_lockedStation(s: Variant = null,label: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_lockedStation(s,label,time)
	return null

func f_drawTepsiCami(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawTepsiCami(x,y,w,h,time)
	return null

func f_drawPreparation(time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawPreparation(time)
	var st: Dictionary=j_ST.board
	# A single generous board rather than boxed station cells.
	f_rrect(st.x+2,st.y+3,st.w,st.h-2,2,"#505350")
	f_rrect(st.x,st.y,st.w,st.h-3,2,"#815128")
	f_rrect(st.x+1,st.y,st.w-2,st.h-7,2,"#c9975f")
	f_rrect(st.x+3,st.y+2,st.w-6,st.h-11,1,"#d7ad75")
	f_hl(st.x+3,st.y+2,st.w-6,"#f0ce93")
	for row in range(7,35,6):
		f_hl(st.x+5,st.y+row,st.w-10,"#c99b67")
	for i in int((st.w-20)/13):
		f_ln(st.x+9+i*13,st.y+8+(i%3)*7,st.x+14+i*13,st.y+12+(i%3)*7,"#c79d69")
	var count: int=tun_design("boards")
	var scale_value := 1.8 if count == 1 else (1.22 if count == 2 else 0.9)
	for i in count:
		var cx: float=wrap_system.f_boardCX(i)
		if count>1:
			if i==int(j_G.act): f_hl(cx-17,st.y+st.h-7,34,"#f3d896")
			if i>0: f_vl(st.x+i*st.w/count,st.y+5,st.h-16,"#ba8b55")
		var item: Variant=j_G.boards[i]
		if item == null: continue
		var cy: float=wrap_system.f_boardCY()-sin(float(item.get("pop",0))*PI)*2
		match item.kind:
			"pide": plate_draw.f_drawPideBoard(cx,cy,item,time,scale_value)
			"plate": plate_draw.f_drawPlate(cx,cy,item,time,scale_value)
			_:
				if item.state == "open": wrap_draw.f_drawWrapOpen(cx,cy,item,time,scale_value)
				else: wrap_draw.f_drawWrapRolled(cx,cy,item,time,scale_value)
	return null

func f_drawBreadStack(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,label: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawBreadStack(x,y,w,h,label)
	if not tun_design("iskOn"):
		f_rrect(x,y+3,w,h-5,1,"#906238")
		f_hl(x+1,y+3,w-2,"#d7ac72")
	return super.f_drawBreadStack(x+2,y-1,w-4,h,"")

func f_drawPideStack(x: Variant = null,y: Variant = null,w: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawPideStack(x,y,w)
	f_rrect(x,y+3,w,j_ST.bread.h-5,1,"#906238")
	f_hl(x+1,y+3,w-2,"#d7ac72")
	return super.f_drawPideStack(x,y,w)

func f_drawPaperStation(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,level: Variant = null,busy: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawPaperStation(x,y,w,h,level,busy,time)
	if float(level)>0:
		machine_body(x,y+3,w,h-4)
		f_fr(x+3,y+7,w-6,6,"#273237")
		f_fr(x+5,y+10,w-10,11,"#f4edda")
		f_hl(x+6,y+14,w-12,"#ce4935")
		f_fr(x+3,y+3,3,3,"#e79d38" if float(busy)>0 else "#8abc65")
		if float(level)>1: f_fr(x+w-7,y+3,4,3,"#1e413d")
		return null
	f_fr(x,y+5,w,h-5,"#657174")
	f_hl(x,y+5,w,"#d4ddd5")
	for i in range(4,-1,-1):
		f_fr(x+2,y+5+i*2,w-4,h-12,"#bbb9a5")
		f_fr(x+2,y+4+i*2,w-4,h-12,"#faf4df")
		f_hl(x+4,y+6+i*2,w-8,"#cf4832")
	return null

func f_drawFryer(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,state: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawFryer(x,y,w,h,state,time)
	machine_body(x,y+7,w,h-7)
	f_fr(x+8,y,w-16,9,"#465159"); f_hl(x+8,y,w-16,"#c8d2cb")
	f_fr(x+10,y+2,w-20,5,"#1e292b")
	f_rrect(x+4,y+10,w-8,h-21,2,"#373e37")
	f_rrect(x+6,y+12,w-12,h-25,1,"#866719")
	f_rrect(x+8,y+13,w-16,h-26,1,"#b28c24")
	for row in range(14,int(h)-13,4):
		f_hl(x+7,y+row,w-14,"#ada782")
	for col in range(8,int(w)-7,5):
		f_vl(x+col,y+12,h-25,"#b5b7a2")
	if state.state != "idle":
		for i in 14:
			var px: float=x+10+fmod(i*7.0,w-22)
			var py: float=y+15+fmod(i*3.0,maxf(1,h-31))
			f_fryStick(px,py,1.0,float(i),1.0)
	if state.state == "fry":
		for i in 5: f_px(x+12+i*6,y+15+fmod(float(time)*12+i*5,9),"#f6dc80")
	f_fr(x+w/2-2,y+5,4,12,"#343d40")
	f_fr(x+w/2-7,y+4,14,4,"#1b292c")
	f_fr(x+7,y+h-8,5,4,"#86c966" if state.state == "done" else ("#e66e38" if state.state == "fry" else "#3f5545"))
	f_disc(x+w-10,y+h-6,3,"#202d2f"); f_px(x+w-10,y+h-8,"#c7cbbb")
	return null

func machine_body(x: float,y: float,w: float,h: float) -> void:
	f_rrect(x+1,y+2,w,h,2,"#4c5557")
	f_rrect(x,y,w,h-1,2,"#b0b8b5")
	f_fr(x+3,y+3,w-6,h-7,"#8a969a")
	f_hl(x+2,y,w-4,"#ecedda")
	f_vl(x+1,y+1,h-4,"#d3dcd6")
	f_hl(x+3,y+h-3,w-6,"#5c6b73")

func f_drawGrill(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,state: Variant = null,time: Variant = null,capacity: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawGrill(x,y,w,h,state,time,capacity)
	machine_body(x,y+5,w,h-5)
	f_rrect(x+3,y+8,w-6,h-18,2,"#343f42")
	for line in range(5,int(w)-4,3):
		f_vl(x+line,y+10,h-23,"#86928e")
	f_fr(x+w/2-9,y,18,4,"#273235")
	f_vl(x+w/2-9,y+2,7,"#c1cbc7"); f_vl(x+w/2+8,y+2,7,"#727f83")
	f_fr(x+6,y+h-8,4,4,"#78b856" if not state.slots.is_empty() else "#42584b")
	f_disc(x+w-9,y+h-6,3,"#283236")
	return null

func f_drawCutBoard(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,state: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawCutBoard(x,y,w,h,state,time)
	f_rrect(x,y+3,w,h-3,2,"#986c40")
	f_rrect(x+1,y+3,w-2,h-6,2,"#d4ad73")
	for i in range(8,int(h)-5,7): f_hl(x+3,y+i,w-6,"#c89b64")
	if state.potato:
		f_ell(x+w/2,y+h/2,9,6,"#bb8841")
		f_ell(x+w/2-2,y+h/2-2,6,3,"#e5bb78")
		if state.prog>0: counter_draw.f_bar(x+5,y+h-6,w-10,3,state.prog,"#eacf88")
	elif state.raw>0:
		# Freshly cut potato is pale cream, with no browned tips or fried palette.
		for i in mini(12,int(state.raw)*2):
			var px: float=x+10+fmod(i*7.0,w-31)
			var py: float=y+12+fmod(i*5.0,h-21)
			ingredient_pixels.f_fryBar(px,py,11.0,0.25 if i%2 else -0.25,0.2,"#fff6d0","#f2e0a8","#dcc681","#e8d59a")
	var cy: float=y+h/2+(sin(float(time)*25)*3 if state.cutting else 0)
	f_fr(x+w-12,cy-6,7,13,"#dde3d5"); f_vl(x+w-12,cy-6,13,"#faf9e8")
	f_fr(x+w-10,cy+7,3,7,"#5a3927")
	return null

func f_drawPotatoBin(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawPotatoBin(x,y,w,h,time)
	f_fr(x,y,w,h,"#553c22"); f_fr(x+2,y+2,w-4,h-3,"#302719")
	for i in 12:
		var px: float=x+7+fmod(i*9.0,w-13)
		var py: float=y+7+fmod(i*7.0,h-13)
		f_ell(px,py,5,4,"#b98a49"); f_ell(px-1,py-1,3,2,"#d4aa69")
		f_px(px+2,py,"#896135")
	for yy in [h-10,h-4]:
		f_fr(x+2,y+yy,w-4,2,"#bb8b4a")
	for xx in range(3,int(w)-2,7): f_vl(x+xx,y+h-11,10,"#86632e")
	return null

func f_drawCrate(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,opened: Variant = null,time: Variant = null,progress: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawCrate(x,y,w,h,opened,time,progress)
	var shift := J.n(progress)*4
	machine_body(x,y-shift,w,h)
	f_rrect(x+w/2-9,y+6-shift,18,4,1,"#303e42")
	f_hl(x+w/2-7,y+6-shift,14,"#c1cdc5")
	# Two small jars make the supply drawer recognizable without a word label.
	for i in 2:
		f_fr(x+8+i*9,y+17-shift,6,7,"#647633" if i == 0 else "#eee5cc")
		f_hl(x+8+i*9,y+16-shift,6,"#c4d2cc")
	return null

func f_drawTrash(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,time: Variant = null,emptying: Variant = null,fullness: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawTrash(x,y,w,h,time,emptying,fullness)
	f_rrect(x+2,y+5,w-4,h-6,2,"#454e50")
	f_fr(x+5,y+8,w-10,h-10,"#303c3f")
	f_vl(x+5,y+9,h-13,"#526367")
	f_rrect(x,y,w,10,2,"#778282")
	f_rrect(x+3,y+2,w-6,6,1,"#172225")
	if J.n(fullness)>0:
		for i in mini(5,int(fullness)): f_fr(x+6+i*3,y+4+(i%2),3,2,"#c9b482")
	if J.n(emptying)>0: f_hl(x+7,y+h-3,w-14,"#e4d38e")
	return null

func f_drawTepsiKasasi(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,divisions: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawTepsiKasasi(x,y,w,h,divisions)
	return null # All four trays already sit in the same cold rail.

func f_sauceSlotX(index: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_sauceSlotX(index)
	return j_ST.sauce.x + (float(index)+0.5)*j_ST.sauce.w/3-3

func f_sauceIdxAt(mx: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_sauceIdxAt(mx)
	return clampi(int(floor((float(mx)-j_ST.sauce.x)/(j_ST.sauce.w/3))),0,2)

func f_drawSauceStation(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,on: Variant = null,isk: Variant = null,fx: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawSauceStation(x,y,w,h,on,isk,fx,time)
	for i in 3:
		if not J.truth(isk if i==2 else on): continue
		var bottle: Dictionary = j_SAUCE_DEF[i]
		var cx: float=x+(i+.5)*w/3
		var lift: float=round(sin(clampf(float(fx.get(bottle.id,0)) if fx is Dictionary else 0.0,0,1)*PI)*2)
		var by: float=y+h-2-lift
		f_ell(cx,y+h-2,6,2,"#667172")
		f_rrect(cx-5,by-14,10,14,2,bottle.c0)
		f_rrect(cx-4,by-14,7,13,1,bottle.c1)
		f_vl(cx-3,by-12,10,"#f3dab6")
		f_fr(cx-3,by-17,6,4,bottle.cap)
		f_fr(cx-1,by-22,2,5,bottle.cap)
		f_fr(cx-4,by-10,8,6,"#f5e9cb")
		if i==0: f_ell(cx,by-7,2,2,"#bd3724")
		elif i==1: f_ell(cx,by-7,2,2,"#c8bd91")
		else: f_fr(cx-2,by-9,4,3,"#dca131")
	return null

func f_drawIcecekKasasi(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,divisions: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawIcecekKasasi(x,y,w,h,divisions,time)
	var height: float=j_ST.drinkM.h
	var taps: Array=drink_system.f_icecekMusluklari()
	machine_body(x,y,w,height-1)
	f_fr(x+3,y+24,w-6,height-30,"#2c3e40")
	f_fr(x+4,y+height-6,w-8,3,"#626f71")
	for col in range(5,int(w)-4,3): f_vl(x+col,y+height-6,3,"#bdc9c3")
	for i in taps.size():
		var type: String=taps[i]
		var cx: float=x+(i+.5)*w/taps.size()
		var segment: float=w/taps.size()-4
		var color: String={"fanta":"#e59a32","cola":"#a83e2d","ayran":"#c9dcc6"}.get(type,"#c9dcc6")
		f_fr(cx-segment/2,y+4,segment,18,"#344b50")
		f_fr(cx-segment/2+1,y+5,segment-2,15,color)
		f_hl(cx-segment/2+2,y+6,segment-4,"#f0d9ac")
		f_fr(cx-2,y+10,5,8,"#faf0d9" if type=="ayran" else "#3a2920")
		f_fr(cx-1,y+8,3,3,"#e6e3c8")
		f_fr(cx-3,y+24,6,4,"#c4d0c8")
		f_fr(cx-1,y+28,2,4,"#84969a")
		f_vl(cx+3,y+25,5,"#182e32")
		if j_G.drinkM is Dictionary and j_G.drinkM.pours.get(type) != null:
			for sy in range(32,43):
				f_px(cx,y+sy,color)
				if sin(float(time)*20+sy)>0: f_px(cx-1,y+sy,"#f1d5a0" if type!="ayran" else "#fff7e3")
	return null

func f_drawDrinkMachine(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,state: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawDrinkMachine(x,y,w,h,state,time)
	if state is Dictionary and not state.has("pours"): return f_drawIcecekKasasi(x,y,j_ST.drinkM.w,j_ST.drinkM.h,0,time)
	return null

func f_drawAyranTank(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,n: Variant = null,maximum: Variant = null,state: Variant = null,time: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawAyranTank(x,y,w,h,n,maximum,state,time)
	return null

func f_drawSweetTray(x: Variant = null,y: Variant = null,w: Variant = null,h: Variant = null,n: Variant = null,maximum: Variant = null,time: Variant = null,fx: Variant = null) -> Variant:
	if not counter_design_enabled: return super.f_drawSweetTray(x,y,w,h,n,maximum,time,fx)
	f_trayBase(x,y,w,h)
	f_fr(x+3,y+3,w-6,h-6,"#80602e")
	var count: int=ceili(clampf(float(n)/maxf(1,float(maximum)),0,1)*4)
	for i in count: garnish_draw.f_drawBaklava(x+10+(i%2)*14,y+9+int(i/2)*9)
	f_hl(x+2,y+h-2,w-4,"#d2d7be")
	f_trayFlash(x,y,w,h,J.n(fx))
	return null
