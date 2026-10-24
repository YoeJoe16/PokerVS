"""Original pixel sprites for Fuga Runica. Rebuild with Python + Pillow.
No resizing/antialiasing is used in source assets. 64x72 cells, 11 poses.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps
import random
import argparse

OUT = Path(__file__).resolve().parents[1] / 'assets' / 'pixel'
OUT.mkdir(parents=True, exist_ok=True)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--preview", type=Path, help="Optional contact sheet output path")
args = parser.parse_args()
INK = '#151c2f'
POSES = ['idle', 'breathe', 'gather', 'fire', 'lightning', 'shield', 'heal', 'ice', 'blast', 'hit', 'down']
PALETTES = [
    ('apprentice', '#c77553', '#86474a', '#efb979', '#d1a186', '#765460', '#283448'),
    ('collector', '#b47760', '#704857', '#dc9c73', '#bc856c', '#754f54', '#3d3546'),
    ('spark', '#ce9c51', '#8a5b48', '#f4d479', '#bc886b', '#79505c', '#42334c'),
    ('mender', '#76a293', '#465e75', '#b7c8a1', '#caa28c', '#8e6471', '#656273'),
    ('chalk', '#8c79aa', '#534f7b', '#b7a4d1', '#d0a98d', '#8e6b77', '#293a53'),
    ('mazas', '#af6556', '#694354', '#df9b6c', '#b58067', '#74535e', '#48394d'),
    ('ember', '#d29369', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('needle', '#b8c3a0', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('mist', '#85bcc6', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('stitch', '#91c3a6', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('locksmith', '#e2c27e', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('ash', '#c19b9d', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('echo', '#b6a5d0', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('wall', '#a7b6b5', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('suture', '#9ac6af', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
    ('syndic', '#d6aa78', '#485365', '#d5c5a2', '#bb977e', '#745b64', '#354253'),
]


def sprite(kind, pose):
    name, coat, shade, light, skin, skin_shade, hair = PALETTES[kind]
    variant = kind
    if kind >= 6:
        kind = [2, 3, 4, 3, 5, 1, 4, 5, 3, 5][kind - 6]
    im = Image.new('RGBA', (64, 72))
    d = ImageDraw.Draw(im)
    broad = 4 if kind == 5 else (1 if kind == 1 else 0)
    bob = -1 if pose == 'breathe' else (2 if pose in ('hit', 'down') else 0)
    def poly(points, fill, outline=None):
        d.polygon([(x, y+bob) for x,y in points], fill=fill, outline=outline)
    def rect(box, fill):
        x1,y1,x2,y2=box; d.rectangle((x1,y1+bob,x2,y2+bob), fill=fill)
    # Boots and staggered trouser legs, one deliberate pixel at each edge.
    poly([(23,47),(32,47),(31,64),(20,64),(20,60)], INK)
    poly([(33,46),(42,47),(43,62),(49,64),(49,68),(34,68)], INK)
    rect((24,48,29,61), '#394958'); rect((35,48,40,62),'#435263')
    rect((24,50,25,59),'#697783'); rect((37,50,39,59),'#536477')
    rect((20,64,30,66),'#8b9292'); rect((35,66,48,67),'#82908e')
    # Distinct silhouettes: long mender coat, hood, broad elite.
    hem = 55 if kind == 3 else 49
    poly([(23-broad,27),(39+broad,27),(44+broad,37),(42+broad,hem),(20-broad,hem),(19-broad,36)], INK)
    poly([(24-broad,29),(38+broad,29),(41+broad,37),(40+broad,hem-2),(22-broad,hem-2),(22-broad,35)], coat)
    poly([(24-broad,31),(27,31),(27,hem-3),(22-broad,hem-3)], shade)
    rect((29,33,31,hem-5),light)
    rect((23-broad,hem-4,41+broad,hem-3),shade)
    if kind == 0:
        # Back of apprentice's prison jacket: patch, tiny tally marks, torn hem.
        rect((28,34,38,43),'#323d4e'); rect((29,35,37,36),'#e8d9ad')
        for x in (30,33,36): rect((x,38,x,41),'#d2c4a6')
        rect((39,47,41,50),shade)
    else:
        rect((33,35,39,37),'#d6c9a9'); rect((33,38,35,39),shade)
        rect((30,29,31,47),shade)
    if kind == 3:
        for x,y in [(23,39),(38,44),(29,49)]:
            rect((x,y,x+3,y+3),'#c6b78c'); rect((x+1,y,x+1,y+3),shade)
    if kind == 4:
        poly([(21,28),(41,28),(38,34),(31,37),(24,34)], '#41465f')
        rect((28,32,36,33),'#b4a5d5')
    if kind == 5:
        for x in (22,38):
            for y in range(28,47,4): rect((x,y,x+2,y+2),'#b2b9b6')
        rect((21,46,45,48),'#45384c'); rect((31,45,35,49),'#d2c5a1')
    # Neck and head, pixel contours, no vector smoothing.
    rect((29,23,36,29),INK); rect((30,24,35,29),skin_shade)
    poly([(24,9),(36,7),(42,12),(43,20),(39,27),(27,27),(22,22),(22,14)],INK)
    poly([(25,11),(36,10),(40,13),(41,20),(38,25),(28,25),(24,21),(24,15)],skin)
    rect((24,17,26,22),skin_shade); rect((29,23,37,25),skin_shade)
    rect((39,18,42,20),skin); rect((39,17,40,18),'#e8bfa0')
    if kind == 0: # spiky hair viewed from behind, teal scarf
        poly([(21,20),(20,12),(23,12),(22,7),(27,9),(28,4),(32,7),(37,5),(39,9),(43,11),(40,16),(37,22),(26,23)],hair,INK)
        poly([(24,11),(28,9),(31,9),(34,8),(39,11),(36,15),(26,16)],'#45566a')
        rect((23,17,37,19),'#b9b58e'); rect((25,18,37,19),'#898e81')
        poly([(26,24),(38,23),(39,28),(29,31),(23,28)], '#327f83',INK)
        rect((28,26,37,27),'#77c5b6')
        poly([(25,27),(28,29),(20,36),(16,35),(21,29)],'#438f94',INK)
    elif kind == 1:
        poly([(24,12),(26,8),(36,8),(40,12),(38,13),(26,12)],hair)
        for x in (27,30,34,37): rect((x,10,x,11),'#787377')
        rect((28,20,38,22),'#674d4c'); rect((31,21,34,21),skin)
    elif kind == 2:
        poly([(27,12),(26,7),(30,8),(30,2),(33,5),(37,3),(36,8),(39,9),(35,14)], '#e2be71',INK)
        rect((31,7,33,10),'#f9e5a2'); rect((23,17,25,19),'#e0c897')
    elif kind == 3:
        poly([(21,22),(21,12),(24,7),(37,7),(42,12),(41,19),(38,13),(30,12),(26,18),(25,24)],hair,INK)
        rect((25,10,36,11),'#a9a0a0')
        for y in (22,26,30,34): rect((21,y,24,y+2),hair)
        rect((21,37,24,38),'#dbb98b')
    elif kind == 4:
        poly([(21,20),(20,11),(24,6),(37,5),(43,10),(43,18),(38,15),(34,11),(26,14),(24,21)], hair,INK)
        poly([(24,10),(32,8),(38,10),(35,12),(26,13)],'#4c5872')
        rect((24,22,27,24),'#a491b4')
    elif kind == 5:
        rect((27,10,36,11),'#d5aa85'); rect((24,17,27,18),skin_shade)
        rect((35,12,36,18),'#87515a'); rect((32,21,38,22),'#684a4d')
        rect((29,25,38,27),'#59434c')
    if kind:
        rect((28,16,31,17),INK); rect((36,16,39,17),INK)
        rect((29,16,30,16),'#f4e4c4'); rect((37,16,38,16),'#f4e4c4')
        rect((33,18,34,20),skin_shade)
    if variant >= 6:
        # Details stay attached to the breathing head/torso in every casting pose.
        if name == 'ember':
            rect((23,20,40,24), '#724441'); rect((26,21,37,21), '#df9e64')
        elif name == 'needle':
            poly([(38,8),(44,3),(45,13),(41,20)], hair, INK)
            rect((26,15,40,16), '#adb9bc')
        elif name == 'mist':
            rect((25,19,40,24), '#92c4ca'); rect((28,20,37,21), '#d2e9d9')
        elif name == 'stitch':
            rect((24,7,39,11), '#718d88'); rect((29,7,34,9), '#d2c798')
            rect((26,16,31,19), '#243e49'); rect((27,17,30,18), '#8bc6ba')
        elif name == 'locksmith':
            poly([(23,12),(21,4),(27,6),(32,2),(38,6),(42,4),(40,12)], '#bd9a59', INK)
            rect((32,39,36,44), '#e1c882'); rect((33,41,34,42), INK)
        elif name == 'ash':
            rect((22,12,40,14), '#c4b6ab'); rect((24,19,27,23), '#8a777b')
        elif name == 'echo':
            for x in (20,41): rect((x,14,x+3,23), '#a9a0c5')
            rect((25,8,38,10), '#a9a0c5')
        elif name == 'wall':
            rect((17,29,25,34), '#a5b4ae'); rect((39,29,47,34), '#a5b4ae')
            rect((24,12,40,15), '#748b91')
        elif name == 'suture':
            rect((24,13,40,16), '#d0c8ad'); rect((34,14,39,15), INK)
            rect((28,19,38,23), '#8cab9c')
        elif name == 'syndic':
            poly([(20,27),(28,30),(32,40),(37,30),(44,27),(42,37),(32,46),(22,37)], '#d2b47d', INK)
            rect((24,9,39,12), '#c4c1af'); rect((28,22,38,26), '#c4c1af')
            rect((26,15,31,18), '#e2c98d'); rect((35,15,40,18), '#e2c98d')
    body = im.copy()
    if kind == 0:
        im = Image.new("RGBA", (64, 72))
        d = ImageDraw.Draw(im)
    # Arm joints. Each release has genuinely different hand silhouettes.
    joints = {
        'idle': (((18-broad,37),(19-broad,43)), ((46+broad,36),(48+broad,30))),
        'breathe': (((18-broad,36),(20-broad,42)), ((46+broad,35),(48+broad,29))),
        'gather': (((22,36),(28,33)), ((44,35),(37,32))),
        'fire': (((20,40),(26,43)), ((48,31),(57,27))),
        'lightning': (((20,39),(25,43)), ((46,21),(49,10))),
        'shield': (((25,36),(39,29)), ((40,38),(26,30))),
        'heal': (((22,35),(30,34)), ((43,35),(35,34))),
        'ice': (((27,39),(44,35)), ((48,31),(56,32))),
        'blast': (((13,28),(8,19)), ((50,25),(56,17))),
        'hit': (((18,34),(17,27)), ((46,36),(45,29))),
        'down': (((18,43),(15,50)), ((45,43),(48,49))),
    }
    if kind == 0:
        joints['gather'] = (((18,35),(28,29)), ((46,34),(39,27)))
        joints['shield'] = (((17,30),(38,23)), ((48,29),(27,24)))
        joints['heal'] = (((18,31),(43,24)), ((47,30),(44,24)))
    for side,(elbow,hand) in enumerate(joints[pose]):
        shoulder=(23-broad,31) if side==0 else (40+broad,31)
        points=[(x,y+bob) for x,y in (shoulder,elbow,hand)]
        d.line(points,fill=INK,width=9)
        d.line(points[:2],fill=shade if side==0 else coat,width=6)
        d.line(points[1:],fill=skin_shade,width=5)
        x,y=hand; rect((x-2,y-2,x+2,y+2),INK); rect((x-1,y-1,x+1,y+1),skin)
        if pose == 'fire' and side==1:
            rect((x,y-6,x+2,y+2),INK); rect((x+1,y-5,x+1,y+1),'#edc6a3')
            rect((x-2,y-3,x-1,y-1),skin)
        elif pose == 'lightning' and side==1:
            rect((x,y-7,x+2,y-1),INK); rect((x+1,y-6,x+1,y),skin)
        elif pose == 'ice' and side==1:
            rect((x,y-2,x+6,y+1),INK); rect((x,y-1,x+5,y-1),skin)
            rect((x,y+1,x+5,y+3),INK); rect((x,y+2,x+4,y+2),skin)
        elif pose == 'blast':
            for dx,dy in [(-3,-4),(0,-6),(3,-4)]:
                rect((x+dx,y+dy,x+dx+1,y),skin)
        elif pose == 'heal':
            rect((x,y-4,x+1,y),skin)
        # Each forearm carries a prison suppression cuff with a broken seal.
        ex,ey=elbow; rect((ex-2,ey-1,ex+2,ey), '#3b6267')
        rect((ex-1,ey-1,ex+1,ey-1),'#a5d6c6')
    if kind == 0:
        # Back view: the entire torso/head occludes arms reaching in front.
        # Forearms remain visible only outside the body silhouette.
        im.alpha_composite(body)
    if kind:
        im=ImageOps.mirror(im) # opponent faces the apprentice at bottom left
    return im

for kind, palette in enumerate(PALETTES):
    sheet=Image.new('RGBA',(64*len(POSES),72))
    for index,pose in enumerate(POSES):
        sheet.alpha_composite(sprite(kind,pose),(index*64,0))
    sheet.save(OUT/f'{palette[0]}.png')

# A 240x148 background displayed at exactly 2x in the 480px viewport.
rng=random.Random(22)
bg=Image.new('RGB',(240,148),'#202d40'); d=ImageDraw.Draw(bg)
d.rectangle((0,0,239,76),fill='#2c3a4c')
for y in range(8,76,14):
    d.line((0,y,239,y),fill='#233144')
    for x in range(-12 if y%28 else 9,240,35): d.line((x,y,x,y+13),fill='#263448')
for _ in range(170):
    x,y=rng.randrange(240),rng.randrange(8,76)
    d.point((x,y),fill=rng.choice(['#334156','#263347']))
# Far cell doors with slatted light and runic locks.
for x in (9,65,180):
    d.rectangle((x-2,18,x+39,74),fill='#151e32')
    d.rectangle((x,20,x+37,72),fill='#4a5364')
    d.rectangle((x+3,23,x+34,70),fill='#131e30')
    d.rectangle((x+4,25,x+33,26),fill='#293947')
    for off in range(6,35,7):
        d.rectangle((x+off,23,x+off+1,70),fill='#60727b')
        d.line((x+off+2,23,x+off+2,70),fill='#303f52')
    d.rectangle((x+2,47,x+35,49),fill='#495e6b')
    d.rectangle((x+28,48,x+38,57),fill='#182b3a')
    d.line([(x+30,51),(x+33,49),(x+36,52),(x+33,55),(x+30,51)],fill='#8ac6b7')
# Electrical duct, fluorescents, wall camera, inmates' scratch marks.
d.rectangle((0,5,239,9),fill='#151f32'); d.line((0,5,239,5),fill='#526072')
for x in (44,145):
    d.rectangle((x,7,x+37,12),fill='#111b2b')
    d.rectangle((x+2,8,x+34,9),fill='#e5d6aa')
    d.rectangle((x+4,10,x+32,11),fill='#84a6a1')
d.rectangle((118,29,158,52),fill='#1d2a3d'); d.rectangle((120,31,156,50),fill='#536171')
# Pixel sign "B-01" as 3x5 glyphs.
letters=['110101110101110','000000111000000','111101101101111','010110010010111']
for n,glyph in enumerate(letters):
    for k,bit in enumerate(glyph):
        if bit=='1':
            x=123+n*8+(k%3)*2; y=35+(k//3)*2
            d.rectangle((x,y,x+1,y+1),fill='#d4cba9')
d.line((166,15,166,23),fill='#8c9b9c',width=2)
d.rectangle((157,21,173,26),fill='#778992'); d.rectangle((155,22,158,25),fill='#172c37')
d.point((155,23),fill='#92edcf')
for x in (116,120,124,128): d.line((x,59,x-1,65),fill='#7e7e81')
d.line((114,64,129,60),fill='#7e7e81')
# Tiles in perspective.
d.rectangle((0,76,239,147),fill='#354351')
d.rectangle((0,75,239,79),fill='#141f32'); d.line((0,80,239,80),fill='#68737a')
for y in (90,107,129):
    d.line((0,y,239,y),fill='#253344')
    d.line((0,y+1,239,y+1),fill='#3c4b59')
for x in range(-220,450,64):
    d.line((120+(x-120)//3,80,x,147),fill='#253344')
# Arcane conduit follows floor, discontinuous light pixels.
d.line([(0,104),(28,104),(48,119),(97,119),(113,109),(165,109),(181,96),(239,96)],fill='#1c303e',width=3)
d.line([(0,104),(28,104),(48,119),(97,119),(113,109),(165,109),(181,96),(239,96)],fill='#639a92')
# Perspective platforms, back right and near left.
for box in ((128,62,215,86),(10,108,108,137)):
    x1,y1,x2,y2=box
    d.ellipse((x1,y1+4,x2,y2+4),fill='#151d2d')
    d.ellipse(box,fill='#566071',outline='#9b9a8a',width=1)
    d.ellipse((x1+4,y1+2,x2-4,y2-2),fill='#394456',outline='#728182',width=1)
    d.ellipse((x1+12,y1+5,x2-12,y2-5),outline='#689b98',width=1)
    for x in (x1+10,x2-10):
        d.rectangle((x,(y1+y2)//2,x+2,(y1+y2)//2+1),fill='#a0cdbb')
bg.save(OUT/'cell_block.png')
# UI wall and desk: 240 x 450, integer 2x scaling at runtime.
wall=Image.new('RGB',(240,450),'#111b2b'); w=ImageDraw.Draw(wall)
for y in range(0,450,16):
    w.line((0,y,239,y),fill='#0d1625')
    for x in range(-24 if y%32 else 0,240,48):
        w.line((x,y,x,y+15),fill='#1c2a3b')
for x in (6,230):
    w.rectangle((x,0,x+3,449),fill='#304153')
    w.line((x,0,x,449),fill='#53616b')
    for y in range(12,450,38):
        w.rectangle((x-1,y,x+4,y+3),fill='#667474')
for x in (24,181):
    w.line([(x,0),(x,34),(x+20,49),(x+20,99)],fill='#263e4c',width=3)
    w.line([(x,0),(x,34),(x+20,49),(x+20,99)],fill='#739f91')
for x in (24,190):
    w.rectangle((x,401,x+27,442),fill='#0c1422')
    for off in range(3,26,6):
        w.line((x+off,403,x+off,440),fill='#3b5260',width=2)
wall.save(OUT/'ui_wall.png')
# Riveted metal frame, exported for StyleBoxTexture nine-patch controls.
frame=Image.new('RGBA',(16,16)); f=ImageDraw.Draw(frame)
f.rectangle((1,0,14,15),fill='#172638'); f.rectangle((0,1,15,14),fill='#172638')
f.line([(1,0),(14,0),(14,1),(15,1),(15,14)],fill='#9ab4ac')
f.line([(0,1),(0,14),(1,14),(1,15),(14,15)],fill='#425d6e')
f.rectangle((2,2,13,13),outline='#30485d')
for x,y in [(2,2),(12,2),(2,12),(12,12)]:
    f.point((x,y),fill='#d5c99e')
frame.resize((32,32),Image.Resampling.NEAREST).save(OUT/'ui_frame.png')
# Pixel rune for the application icon and startup splash.
icon=Image.new('RGBA',(32,32),'#111b2b'); q=ImageDraw.Draw(icon)
q.rectangle((2,2,29,29),outline='#6d958e',width=1)
q.rectangle((4,4,27,27),outline='#354b60',width=1)
q.line([(9,23),(9,9),(16,6),(23,9),(23,16),(16,20),(9,16)],fill='#e6cb94',width=2)
q.line([(16,12),(16,25)],fill='#8bd6be',width=2)
for x,y in [(2,2),(28,2),(2,28),(28,28)]: q.rectangle((x,y,x+1,y+1),fill='#d6c7a4')
icon.resize((128,128),Image.Resampling.NEAREST).save(OUT/'app_icon.png')
# Optional review contact sheet; PNG runtime assets above need no tooling at runtime.
if args.preview:
    preview=Image.new('RGB',(64*len(PALETTES),72*3),'#202d40')
    for kind in range(len(PALETTES)):
        for row,pose in enumerate(('idle','fire','blast')):
            preview.paste(sprite(kind,pose),(kind*64,row*72),sprite(kind,pose))
    args.preview.parent.mkdir(parents=True, exist_ok=True)
    preview.resize((128*len(PALETTES),432),Image.Resampling.NEAREST).save(args.preview)
print('Generated sixteen original 11-frame sheets and cell block background.')
