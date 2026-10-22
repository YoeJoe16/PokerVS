"""Build the original compact bitmap font used throughout the UI (Pillow only)."""
from pathlib import Path
from PIL import Image, ImageDraw
import unicodedata
OUT=Path(__file__).resolve().parents[1]/'assets'/'pixel'
# Compact upper-case glyphs, drawn explicitly on a pixel grid; lowercase shares
# the same shapes. Accents/punctuation have their own Unicode character entries.
PATTERNS={
'A':'010/101/111/101/101','B':'110/101/110/101/110','C':'011/100/100/100/011',
'D':'110/101/101/101/110','E':'111/100/110/100/111','F':'111/100/110/100/100',
'G':'011/100/101/101/011','H':'101/101/111/101/101','I':'111/010/010/010/111',
'J':'001/001/001/101/010','K':'101/101/110/101/101','L':'100/100/100/100/111',
'M':'10001/11011/10101/10001/10001','N':'1001/1101/1011/1001/1001','O':'010/101/101/101/010',
'P':'110/101/110/100/100','Q':'010/101/101/011/001','R':'110/101/110/101/101',
'S':'011/100/010/001/110','T':'111/010/010/010/010','U':'101/101/101/101/111',
'V':'101/101/101/101/010','W':'10001/10001/10101/11011/10001','X':'101/101/010/101/101',
'Y':'101/101/010/010/010','Z':'111/001/010/100/111',
'0':'111/101/101/101/111','1':'010/110/010/010/111','2':'110/001/010/100/111',
'3':'110/001/010/001/110','4':'101/101/111/001/001','5':'111/100/110/001/110',
'6':'011/100/111/101/111','7':'111/001/010/010/010','8':'111/101/111/101/111','9':'111/101/111/001/110',
'.':'0/0/0/0/1',',':'0/0/0/1/1',':':'0/1/0/1/0',';':'0/1/0/1/1',
'!':'1/1/1/0/1','?':'110/001/010/000/010','¡':'1/0/1/1/1','¿':'010/000/010/100/011',
'-':'000/000/111/000/000','+':'000/010/111/010/000','/':'001/001/010/100/100',
'(':'01/10/10/10/01',')':'10/01/01/01/10','[':'11/10/10/10/11',']':'11/01/01/01/11',
'=':'000/111/000/111/000','%':'101/001/010/100/101','·':'0/0/1/0/0',
'…':'00000/00000/00000/00000/10101','\"':'101/101/000/000/000',"'":'1/1/0/0/0',
'<':'001/010/100/010/001','>':'100/010/001/010/100','_':'000/000/000/000/111',
'|':'1/1/1/1/1','*':'101/010/111/010/101','×':'000/101/010/101/000',
}
chars=[chr(i) for i in range(32,127)]+list('ÁÉÍÓÚÜÑáéíóúüñ¡¿·…–—−×«»')
atlas=Image.new('RGBA',(128,((len(chars)+15)//16)*10))
d=ImageDraw.Draw(atlas)
entries=[]
for i,c in enumerate(chars):
    base=unicodedata.normalize('NFD',c.upper())[0]
    base={'–':'-','—':'-','−':'-','«':'<','»':'>'}.get(base,base)
    rows=PATTERNS.get(base,PATTERNS['?']).split('/')
    width=max(len(r) for r in rows) if c!=' ' else 2
    x,y=(i%16)*8,(i//16)*10
    if c!=' ':
        for ry,row in enumerate(rows):
            for rx,bit in enumerate(row):
                if bit=='1': d.point((x+rx,y+ry+2),fill='white')
        accent=unicodedata.normalize('NFD',c.upper())[1:]
        if '\u0301' in accent:
            d.point((x+1,y+1),fill='white');d.point((x+2,y),fill='white')
        if '\u0303' in accent:
            d.point((x,y+1),fill='white');d.point((x+1,y),fill='white');d.point((x+2,y+1),fill='white')
        if '\u0308' in accent:
            d.point((x,y),fill='white');d.point((x+2,y),fill='white')
    entries.append(f'char id={ord(c)} x={x} y={y} width={width} height=7 xoffset=0 yoffset=0 xadvance={width+1} page=0 chnl=15')
atlas.save(OUT/'rune_font.png')
(OUT/'rune_font.fnt').write_text('info face="RuneCompact" size=8 bold=0 italic=0 unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=0,0\n'+f'common lineHeight=8 base=7 scaleW=128 scaleH={atlas.height} pages=1 packed=0\npage id=0 file="rune_font.png"\nchars count={len(chars)}\n'+'\n'.join(entries)+'\nkernings count=0\n')
print('Built original pixel font with Spanish accents.')
