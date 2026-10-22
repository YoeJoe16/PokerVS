"""Original fullscreen pixel-art cell and seated apprentice layers. Requires Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw
import random

OUT = Path(__file__).resolve().parents[1] / 'assets' / 'pixel'
OUT.mkdir(parents=True, exist_ok=True)
INK = '#111a2b'
rng = random.Random(81)
room = Image.new('RGB', (240, 450), '#182332')
d = ImageDraw.Draw(room)
# Back wall, recessed bricks and worn lower paint.
d.rectangle((0, 50, 239, 265), fill='#293846')
for y in range(58, 265, 19):
    d.line((0, y, 239, y), fill='#1f2d3b')
    for x in range(-23 if (y//19)%2 else 0,240,46):
        d.line((x,y,x,y+18), fill='#22303e')
for _ in range(280):
    x,y=rng.randrange(240),rng.randrange(58,266)
    d.point((x,y),fill=rng.choice(['#31404c','#23323f']))
d.rectangle((0,215,239,264),fill='#263b40')
for _ in range(95):
    x,y=rng.randrange(240),rng.randrange(214,220)
    d.rectangle((x,y,x+2,y+2),fill='#32464a')
d.rectangle((0,262,239,269),fill='#142631')
d.line((0,270,239,270),fill='#4b5f61')
# Ceiling and thick corroded water pipes, including the three leak outlets.
d.polygon([(0,0),(239,0),(239,53),(0,70)],fill='#111d2a')
d.line((0,69,239,52),fill='#394854',width=2)
d.rectangle((18,52,218,60),fill='#192732')
d.rectangle((18,53,218,56),fill='#65736f')
d.line((18,57,218,57),fill='#394b52',width=2)
for x in (24,66,146,198):
    d.rectangle((x,50,x+7,61),fill='#293b43')
    d.rectangle((x+1,51,x+5,53),fill='#869184')
    d.point((x+3,60),fill='#a6b6a0')
for x,y in [(69,76),(201,90),(27,117)]:
    d.rectangle((x-3,60,x+3,y-3),fill='#263b45')
    d.line((x-2,61,x-2,y-4),fill='#637870')
    d.rectangle((x-5,y-5,x+4,y-2),fill='#374f56')
    d.line((x-3,y-2,x+2,y-2),fill='#91b2a7')
# Cold light coming through a barred window. Deliberately stepped flat colors.
d.polygon([(136,151),(192,151),(145,291),(66,291)],fill='#30454e')
d.polygon([(146,151),(158,151),(106,291),(89,291)],fill='#3b5358')
d.rectangle((129,95,195,159),fill='#14222e')
d.rectangle((132,98,192,156),fill='#687a7a')
d.rectangle((135,101,189,153),fill='#263e53')
d.rectangle((136,102,188,123),fill='#345169')
d.rectangle((136,124,188,152),fill='#466878')
# Distant city lights, obscured by a frosted prison window.
for x,y in [(139,145),(149,138),(167,146),(181,140)]:
    d.rectangle((x,y,x+3,151),fill='#2c455b')
    d.point((x+1,y+2),fill='#c4c3a1')
for x in (143,158,173,187):
    d.rectangle((x,100,x+2,154),fill='#182c3b')
    d.line((x,101,x,153),fill='#859c96')
d.rectangle((133,125,191,128),fill='#334c59')
d.rectangle((127,156,198,160),fill='#8a9b91')
d.rectangle((127,161,198,165),fill='#1c303b')
# Damp wall staining, cracks and a suppressed rune scratched into concrete.
for x in (26,69,200):
    d.line((x,122,x+2,180),fill='#243b3d',width=3)
    d.line((x+3,134,x+3,164),fill='#47605a')
d.line([(80,105),(77,115),(82,120),(78,128)],fill='#121f2d')
d.line([(101,165),(109,157),(117,165),(109,176),(101,165)],fill='#718d81')
d.line((109,158,109,175),fill='#91aa94')
for x in (45,49,53,57): d.line((x,176,x-1,184),fill='#63756b')
d.line((42,183,59,178),fill='#63756b')
# Floor tiles in perspective, litter, water and shadows.
d.rectangle((0,271,239,449),fill='#253641')
for y in (289,319,361,417):
    d.line((0,y,239,y),fill='#152735')
    d.line((0,y+1,239,y+1),fill='#344751')
for x in range(-250,550,90):
    d.line((120+(x-120)//4,270,x,449),fill='#172a38')
for x,y in [(69,347),(201,323),(27,298)]:
    d.ellipse((x-17,y-4,x+19,y+5),fill='#172c3a')
    d.line((x-10,y+2,x+8,y+2),fill='#435d66')
    d.line((x-5,y-2,x+4,y-2),fill='#6a8885')
# Bed frame and mattress. The character's hips sit on the near mattress edge.
d.polygon([(55,249),(171,233),(194,263),(80,282)],fill='#142432')
for x,y in [(60,243),(181,229),(83,271),(192,255)]:
    d.rectangle((x,y,x+3,y+48),fill='#112130')
    d.line((x,y,x,y+45),fill='#677c79')
d.polygon([(57,233),(172,218),(192,234),(77,252)],fill='#182b36')
d.polygon([(58,234),(173,221),(188,234),(78,250)],fill='#87988c')
d.polygon([(78,250),(188,234),(188,244),(78,261)],fill='#536c69')
d.line((79,252,187,236),fill='#b4b69a')
# Pillow at the far end and an uneven folded blanket.
d.polygon([(149,224),(169,222),(178,228),(158,232),(148,229)],fill='#bdbaa0')
d.line((151,226,168,224),fill='#e0d0ac')
d.polygon([(60,236),(92,232),(110,246),(80,251)],fill='#416674')
d.polygon([(80,251),(110,246),(110,263),(80,270)],fill='#385461')
for x in (83,92,101):
    d.line((x,252,x,264),fill='#66858b')
# Headboard visible behind the pillow.
d.line([(179,232),(179,209),(194,208),(194,251)],fill='#162a36',width=4)
d.line((180,210,193,209),fill='#7c8f88')
# Stool, cup, tiny shelf and a sliver of a sealed cell door.
d.rectangle((31,200,60,204),fill='#192b37')
d.line((31,200,59,200),fill='#a39d80')
d.rectangle((39,190,44,199),fill='#879c94')
d.rectangle((45,192,47,196),outline='#879c94')
d.rectangle((212,185,239,264),fill='#162734')
for y in range(195,227,6): d.line((218,y,234,y),fill='#3c535c',width=2)
d.rectangle((217,239,224,243),fill='#889780')
# Darkness at the threshold is built out of solid pixel bands.
for y,col in [(395,'#22323f'),(410,'#1c2c39'),(427,'#172432'),(440,'#121e2b')]:
    d.rectangle((0,y,239,449),fill=col)
room.save(OUT/'menu_cell.png')

# Foreground bars form a separate layer, in front of the seated hero and leaks.
bars=Image.new('RGBA',(240,450)); b=ImageDraw.Draw(bars)
for x in (12,49,88,177,221):
    b.rectangle((x,0,x+5,449),fill='#0d1926')
    b.line((x+1,0,x+1,449),fill='#465c65')
    b.line((x+2,0,x+2,449),fill='#2e424f')
    b.line((x+5,0,x+5,449),fill='#091421')
    for y in (126,326):
        b.rectangle((x-1,y-2,x+6,y+7),fill='#263b47')
        b.point((x+1,y),fill='#8b9a91')
        b.point((x+4,y+5),fill='#4b626b')
for y in (126,326):
    b.rectangle((0,y,239,y+5),fill='#0b1927')
    b.line((0,y,239,y),fill='#536a70')
    b.line((0,y+1,239,y+1),fill='#314954')
bars.save(OUT/'menu_bars.png')

# Seated torso with crossed arms. Four breathing frames keep hips/feet fixed.
bodies=Image.new('RGBA',(64*4,80))
for frame,breath in enumerate((0,1,2,1)):
    im=Image.new('RGBA',(64,80)); q=ImageDraw.Draw(im)
    # Bent thighs, knees, shins and boots: the pose is seated, never standing.
    q.polygon([(22,28),(40,28),(49,37),(45,44),(32,37),(20,42),(14,36)],fill=INK)
    q.polygon([(23,30),(38,30),(46,37),(43,40),(32,34),(21,39),(17,36)],fill='#455666')
    q.line((20,35,28,32),fill='#6d7e86',width=2)
    q.polygon([(16,38),(25,39),(25,60),(20,65),(12,64),(13,58)],fill=INK)
    q.polygon([(17,40),(23,41),(22,60),(15,61)],fill='#35495b')
    q.line((17,42,16,58),fill='#607782',width=2)
    q.polygon([(39,39),(48,37),(48,61),(52,64),(52,68),(39,68)],fill=INK)
    q.rectangle((41,41,46,60),fill='#465a6a')
    q.rectangle((12,62,23,66),fill='#172532');q.line((12,67,24,67),fill='#8b9992')
    q.rectangle((40,63,51,67),fill='#172532');q.line((40,68,52,68),fill='#8b9992')
    # Breathing only affects shoulders/arms/neck; hips remain on the mattress.
    q.polygon([(22,4+breath),(40,4+breath),(46,15+breath),(42,32),(20,32),(16,16+breath)],fill=INK)
    q.polygon([(23,6+breath),(39,6+breath),(43,16+breath),(40,30),(22,30),(19,16+breath)],fill='#ba7454')
    q.polygon([(22,7+breath),(25,7+breath),(25,29),(21,29)],fill='#80514f')
    q.line((30,7+breath,30,29),fill='#e5aa75',width=2)
    q.rectangle((34,9+breath,39,12+breath),fill='#e3cea0')
    q.line((21,28,41,28),fill='#775052',width=2)
    q.rectangle((28,0+breath,35,5+breath),fill='#c69d83')
    q.polygon([(25,3+breath),(37,2+breath),(40,7+breath),(29,11+breath),(23,7+breath)],fill='#32797e',outline=INK)
    q.line((27,5+breath,37,5+breath),fill='#82c5b4',width=2)
    # Crossed hands rest over the chest because this menu pose faces the camera.
    q.line([(20,11+breath),(18,20+breath),(38,13+breath)],fill=INK,width=7)
    q.line([(20,11+breath),(19,18+breath)],fill='#c8845b',width=5)
    q.line([(19,19+breath),(37,13+breath)],fill='#8e6159',width=4)
    q.line([(41,10+breath),(44,20+breath),(24,15+breath)],fill=INK,width=7)
    q.line([(41,10+breath),(43,18+breath)],fill='#ce8e62',width=5)
    q.line([(43,20+breath),(25,15+breath)],fill='#d5a486',width=4)
    q.rectangle((22,13+breath,26,16+breath),fill='#dfb696')
    q.rectangle((36,11+breath,39,14+breath),fill='#c49a81')
    q.line((22,14+breath,25,14+breath),fill='#8d665d')
    bodies.alpha_composite(im,(frame*64,0))
bodies.save(OUT/'menu_body.png')
# The head is independent: three directions, each with an optional blink.
heads=Image.new('RGBA',(32*6,32))
for direction in range(3):
    shift=direction-1
    for blink in range(2):
        im=Image.new('RGBA',(32,32)); q=ImageDraw.Draw(im)
        q.polygon([(8,8),(22,7),(26,14),(25,23),(21,28),(11,28),(6,22),(6,14)],fill=INK)
        q.polygon([(10,10),(21,9),(24,15),(23,23),(20,26),(12,26),(8,21),(8,15)],fill='#cca68b')
        q.polygon([(8,15),(11,16),(12,25),(9,22)],fill='#8d6870')
        # Side profile changes nose, jaw and ear position as well as eye direction.
        if shift < 0:
            q.rectangle((5,17,9,21),fill='#d8ae8d')
            q.rectangle((22,17,25,20),fill='#9e7875')
        elif shift > 0:
            q.rectangle((22,17,26,21),fill='#dfb594')
            q.rectangle((6,17,9,20),fill='#9e7875')
        else:
            q.line((16,18,16,22),fill='#a57b70',width=2)
        q.polygon([(5,17),(4,10),(8,10),(7,5),(12,7),(14,2),(17,6),(22,4),(24,8),(28,10),(24,15),(8,15)],fill='#29374c',outline=INK)
        q.polygon([(9,10),(13,8),(17,8),(21,7),(24,10),(21,12),(10,12)],fill='#4d6174')
        q.rectangle((7,13,24,15),fill='#b5b38d');q.line((8,15,23,15),fill='#7c8d81')
        eye=shift*2
        for x in (11+eye,19+eye):
            q.line((x-1,17,x+2,17),fill='#33414e')
            if not blink:
                q.rectangle((x,18,x+2,19),fill='#e4d4b4')
                q.point((x+1+shift,18),fill='#172735')
            else:
                q.line((x,19,x+2,19),fill='#354552')
        q.line((13+shift,24,18+shift,24),fill='#936e69')
        heads.alpha_composite(im,((direction*2+blink)*32,0))
heads.save(OUT/'menu_head.png')
print('Generated cell, bars, four seated body frames and six head frames.')
