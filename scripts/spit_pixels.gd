# Continuous meat geometry remains editable code: cuts, roast and rotation are never frozen.
# Reuse radius tables; avoid thousands of dynamic compatibility calls per frame.
extends RefCounted
var radius_tables: Dictionary = {}

func table(game: Variant, radius: int) -> Array:
	if radius_tables.has(radius): return radius_tables[radius]
	var values: Array = []
	for x in range(-radius, radius+1):
		var nx := float(x)/radius
		var shade := .52 if nx < -.78 else (.66 if nx < -.55 else (.8 if nx < -.25 else (.95 if nx < .1 else (1.12 if nx < .38 else (1.3 if nx < .62 else (1.12 if nx < .86 else .86))))))
		values.append(Vector3(shade,game.f_asinF(nx)*1.9, .84+.3*(nx*.5+.5)))
	radius_tables[radius] = values
	return values

func draw_rows(game: Variant, sp: Dictionary, height: float, scale_r: float, cx: float, top: float) -> void:
	var ctx: Variant = game.j_ctx
	var rotation: float = sp.rot
	var roast: float = sp.roast
	var cut: float = sp.cutDepth
	for y in int(ceil(height)):
		var yf := float(y)
		var ty := yf/height
		var rjit := (1 if sin(yf*.21+rotation*1.3)>.25 else 0) - (1 if sin(yf*.29+2.1+rotation)>.55 else 0)
		var r := maxi(1, int(floor(19.0*scale_r*game.f_coneProfile(ty)+.5))+(rjit if ty>.06 and ty<.95 else 0))
		var yy := top+yf
		var cut_amount := int(floor(cut*(1.0-absf(ty-.45))+.5)) if cut>0 and y>8 and yf<height*.8 else 0
		var layer := 1.0+sin(yf*.62+sin(yf*.19)*1.6)*.028
		var lookup := table(game,r)
		var run_key := -1
		var run_x := 0
		for x in range(-r,r+1):
			if cut_amount>0 and x<0 and -x>r-cut_amount: continue
			var row: Vector3 = lookup[x+r]
			var shade := row.x
			var seam := (row.y+rotation*2.2)/PI
			seam -= floor(seam)
			if seam<.1: shade *= .8
			elif seam<.16: shade *= 1.1
			shade *= layer
			var local_roast := roast*row.z
			if ty<.05: local_roast *= .82
			var key := int(local_roast*15)*40+int(shade*12)
			if key != run_key:
				if run_key>=0:
					ctx.fillStyle = game.f_meatColQ(run_key)
					ctx.fillRect(cx+run_x,yy,x-run_x,1)
				run_key=key; run_x=x
		if run_key>=0:
			ctx.fillStyle=game.f_meatColQ(run_key)
			ctx.fillRect(cx+run_x,yy,r+1-run_x,1)
		game.f_px(cx-r-1+cut_amount,yy,"rgba(30,18,10,.45)")
		game.f_px(cx+r+1,yy,"rgba(30,18,10,.40)")
		game.f_px(cx+r,yy,game.f_meatCol(roast*1.05,.8))
		game.f_px(cx+r-1,yy,game.f_meatCol(roast,1.22))
		game.f_px(cx-r+cut_amount,yy,game.f_meatCol(roast*.78,.6))
		if cut_amount==0: game.f_px(cx-r-1,yy,"rgba(20,12,8,.35)")
		if fmod(yf+floor(rotation*2),12)==0:
			for x2 in range(-r+2+cut_amount,r-1):
				if game.f_hash1(x2*3.1+yf*1.7)>.38:
					game.f_px(cx+x2,yy,game.f_meatCol(roast*.92,.78))
		if game.f_hash1(yf*4.7+floor(rotation*1.5))>.8:
			var gx: float = floor(game.math_utils.f_rnd(r*.05,r*.7)+.5)
			game.f_px(cx+gx,yy,game.f_meatCol(roast*.9,1.55))
			game.f_px(cx+gx,yy+1,game.f_meatCol(roast,1.25))
		if roast>1.02 and game.f_hash1(yf*2.3+floor(rotation))>.7:
			var bx: float = floor(game.math_utils.f_rnd(-r*.3,r*.9)+.5)
			game.f_px(cx+bx,yy,"#33231a")
			game.f_px(cx+bx+1,yy,"#4a3226")
