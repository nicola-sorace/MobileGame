extends ReferenceRect

var touchID = -1  #Holds touch index, or -1 if inactive.
var v = Vector2(0,0)
onready var rect = get_rect()

func _ready():
	connect("draw", self, "paint")

func _process(delta):
	if touchID != -1:
		#player.move(v)
		pass

func paint():
	draw_circle(Vector2(rect.size/2), rect.size.x/2, Color(0.5,0.5,0.5, 0.5))
	if touchID != -1:
		draw_circle((v+Vector2(1,1))*rect.size/2, 100, Color(1,1,1,0.5))

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag and (touchID == event.index or touchID == -1):
		var id = event.index
		var d = event.position - (rect.position+rect.size/2)
		
		if d.length()>rect.size.x/2:
			if touchID == event.index: v = d.normalized()
		else:
			v = d/(rect.size.x/2)
		
		if event is InputEventScreenTouch:
			if touchID == -1 and event.pressed and d.length()<rect.size.x/2:
				touchID = id
			if id == touchID and not event.pressed:
				touchID = -1
				v = Vector2(0,0)
		
		update()