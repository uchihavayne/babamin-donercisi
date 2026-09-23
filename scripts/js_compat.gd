# GDScript value helpers preserving the original game's data conventions.
extends RefCounted

static func truth(v: Variant) -> bool:
	if v == null: return false
	if v is bool: return v
	if v is float: return v != 0.0 and not is_nan(v)
	if v is int: return v != 0
	if v is String: return not v.is_empty()
	return true

static func n(v: Variant) -> float:
	if v == null: return 0.0
	if v is bool: return 1.0 if v else 0.0
	if v is String: return v.to_float()
	return float(v)

static func s(v: Variant) -> String:
	if v is String: return v
	if v == null: return "null"
	if v is bool: return "true" if v else "false"
	if v is float and is_nan(v): return "NaN"
	if v is float and is_inf(v): return "Infinity" if v > 0 else "-Infinity"
	if v is float and is_finite(v) and v == floor(v): return str(int(v))
	return str(v)

static func add(a: Variant, b: Variant) -> Variant:
	if a is String or b is String: return s(a) + s(b)
	return n(a) + n(b)

static func eq(a: Variant, b: Variant) -> bool:
	if a == null or b == null: return a == null and b == null
	if (a is float or a is int) and (b is float or b is int): return a == b
	if typeof(a) != typeof(b): return false
	return a == b

static func kind(v: Variant) -> String:
	if v == null: return "undefined"
	if v is bool: return "boolean"
	if v is String: return "string"
	if v is float or v is int: return "number"
	if v is Callable or (v is Dictionary and v.has("__fn")): return "function"
	return "object"

static func getv(o: Variant, k: Variant) -> Variant:
	if o == null: return null
	if o is Dictionary: return o.get(s(k))
	if o is Array or o is String or o is PackedByteArray:
		if k is String and k == "length": return o.size() if not o is String else o.length()
		if k is String and not k.is_valid_int(): return null
		var i: int = int(n(k))
		var count: int = o.length() if o is String else o.size()
		return o[i] if i >= 0 and i < count else null
	if o is Object: return o.get(s(k))
	return null

static func setv(o: Variant, k: Variant, v: Variant) -> Variant:
	if o is Dictionary: o[s(k)] = v
	elif o is Array:
		if k is String and k == "length": o.resize(int(n(v)))
		else:
			var i: int = int(n(k))
			if i >= o.size(): o.resize(i + 1)
			if i >= 0: o[i] = v
	elif o is Object: o.set(s(k), v)
	return v

static func delv(o: Variant, k: Variant) -> bool:
	if o is Dictionary: o.erase(s(k))
	return true

static func has(o: Variant, k: Variant) -> bool:
	return o is Dictionary and o.has(s(k))

static func keys(o: Variant) -> Array:
	return o.keys() if o is Dictionary else []

static func arg(a: Array, i: int, fallback: Variant = null) -> Variant:
	return a[i] if i < a.size() else fallback

static func ref(f: Callable, arity: int) -> Dictionary:
	return {"__fn": f, "arity": arity}

static func invoke(f: Variant, a: Array = []) -> Variant:
	if f is Callable: return f.call(a)
	if f is Dictionary and f.has("__fn"):
		var params: Array = a.duplicate()
		params.resize(int(f.arity))
		return f.__fn.callv(params)
	return null

static func array(size: Variant) -> Array:
	var a: Array = []
	a.resize(int(n(size)))
	a.fill(0.0)
	return a

static func regex(pattern: String, flags: String = "") -> Dictionary:
	var re := RegEx.new()
	re.compile(pattern)
	return {"__regex": re, "flags": flags}

static func parse_int(value: Variant, base: Variant = 10) -> float:
	var text: String = s(value).strip_edges().to_lower()
	var radix: int = int(n(base))
	var sign_value: float = 1.0
	if text.begins_with("-"): sign_value = -1.0; text = text.substr(1)
	elif text.begins_with("+"): text = text.substr(1)
	if radix == 16 and text.begins_with("0x"): text = text.substr(2)
	var result: float = 0.0
	var count: int = 0
	for character in text:
		var digit: int = "0123456789abcdefghijklmnopqrstuvwxyz".find(character)
		if digit < 0 or digit >= radix: break
		result = result * radix + digit
		count += 1
	return result * sign_value if count else NAN

static func method(o: Variant, key: String, a: Array = []) -> Variant:
	if o == null: return null
	if o is Dictionary:
		if key == "hasOwnProperty": return o.has(s(arg(a, 0)))
		if o.has("__regex") and key == "test": return o.__regex.search(s(arg(a, 0))) != null
		return invoke(o.get(key), a)
	if o is Object and o.has_method(key): return o.callv(key, a)
	if o is Array:
		match key:
			"push":
				o.append_array(a)
				return o.size()
			"pop": return o.pop_back() if not o.is_empty() else null
			"shift": return o.pop_front() if not o.is_empty() else null
			"indexOf": return o.find(arg(a, 0))
			"slice":
				var start: int = int(n(arg(a, 0, 0)))
				var end: int = int(n(arg(a, 1, o.size())))
				if start < 0: start = maxi(0, o.size() + start)
				if end < 0: end = maxi(0, o.size() + end)
				return o.slice(start, end)
			"splice":
				var start: int = int(n(arg(a, 0)))
				if start < 0: start = maxi(0, o.size() + start)
				start = mini(start, o.size())
				var removed: Array = []
				for i in range(mini(int(n(arg(a, 1, o.size()))), o.size() - start)):
					removed.append(o.pop_at(start))
				for i in range(2, a.size()): o.insert(start + i - 2, a[i])
				return removed
			"forEach", "map", "filter":
				var result: Array = []
				for i in range(o.size()):
					var v: Variant = invoke(a[0], [o[i], i, o])
					if key == "map": result.append(v)
					elif key == "filter" and truth(v): result.append(o[i])
				return result
			"sort":
				if a.is_empty(): o.sort()
				else: o.sort_custom(func(x: Variant, y: Variant) -> bool: return n(invoke(a[0], [x, y])) < 0)
				return o
			"join":
				var strings: PackedStringArray = []
				for v in o: strings.append(s(v))
				return s(arg(a, 0, ",")).join(strings)
			"concat":
				var result: Array = o.duplicate()
				for v in a:
					if v is Array: result.append_array(v)
					else: result.append(v)
				return result
	if o is String:
		match key:
			"split": return Array(o.split(s(arg(a, 0))))
			"indexOf": return o.find(s(arg(a, 0)))
			"toUpperCase": return o.to_upper()
			"toLocaleUpperCase": return o.replace("i", "İ").replace("ı", "I").to_upper()
			"trim": return o.strip_edges()
			"slice", "substr":
				var start: int = int(n(arg(a, 0, 0)))
				if start < 0: start = maxi(0, o.length() + start)
				var end: int = int(n(arg(a, 1, o.length())))
				if key == "substr": return o.substr(start, end)
				if end < 0: end = maxi(0, o.length() + end)
				return o.substr(start, maxi(0, end - start))
			"replace":
				if a[0] is Dictionary and a[0].has("__regex"):
					return a[0].__regex.sub(o, s(arg(a, 1)), "g" in a[0].flags)
				return o.replace(s(a[0]), s(arg(a, 1)))
	if key == "toFixed": return ("%." + str(int(n(arg(a, 0)))) + "f") % n(o)
	if key == "toString": return s(o)
	return null

static func lt(a: Variant, b: Variant) -> bool:
	return false if a == null or b == null else a < b
static func gt(a: Variant, b: Variant) -> bool:
	return false if a == null or b == null else a > b
static func le(a: Variant, b: Variant) -> bool:
	return false if a == null or b == null else a <= b
static func ge(a: Variant, b: Variant) -> bool:
	return false if a == null or b == null else a >= b
