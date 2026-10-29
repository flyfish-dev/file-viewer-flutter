#!/usr/bin/env python3
"""Generate small, redistributable SDK integration fixtures without user files."""
import io
import pathlib
import zipfile
from xml.sax.saxutils import escape

ROOT = pathlib.Path(__file__).resolve().parent.parent / 'example' / 'assets'
ROOT.mkdir(parents=True, exist_ok=True)
TEXT = 'File Viewer offline integration fixture'
(ROOT / 'sample.txt').write_text(TEXT + '\n\nThis document stays on your device.\n')

def package(filename, parts):
    with zipfile.ZipFile(ROOT / filename, 'w', zipfile.ZIP_DEFLATED) as output:
        for name, content in parts.items():
            info = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            output.writestr(info, content)

CT = 'http://schemas.openxmlformats.org/package/2006/content-types'
REL = 'http://schemas.openxmlformats.org/package/2006/relationships'
DOCREL = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
rels = lambda target, kind='officeDocument': f'<Relationships xmlns="{REL}"><Relationship Id="rId1" Type="{DOCREL}/{kind}" Target="{target}"/></Relationships>'

package('sample.docx', {
    '[Content_Types].xml': f'<Types xmlns="{CT}"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>',
    '_rels/.rels': rels('word/document.xml'),
    'word/document.xml': f'<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body><w:p><w:r><w:rPr><w:b/><w:sz w:val="36"/></w:rPr><w:t>{TEXT}</w:t></w:r></w:p><w:p><w:r><w:t>Local rendering. No conversion server.</w:t></w:r></w:p><w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr></w:body></w:document>',
})
package('sample.xlsx', {
    '[Content_Types].xml': f'<Types xmlns="{CT}"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>',
    '_rels/.rels': rels('xl/workbook.xml'),
    'xl/workbook.xml': f'<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="{DOCREL}"><sheets><sheet name="Offline" sheetId="1" r:id="rId1"/></sheets></workbook>',
    'xl/_rels/workbook.xml.rels': rels('worksheets/sheet1.xml', 'worksheet'),
    'xl/worksheets/sheet1.xml': f'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><dimension ref="A1:B3"/><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>{TEXT}</t></is></c></row><row r="2"><c r="A2" t="inlineStr"><is><t>Value</t></is></c><c r="B2"><v>42</v></c></row><row r="3"><c r="A3" t="inlineStr"><is><t>Result</t></is></c><c r="B3"><f>B2*2</f><v>84</v></c></row></sheetData></worksheet>',
})

P = 'http://schemas.openxmlformats.org/presentationml/2006/main'
A = 'http://schemas.openxmlformats.org/drawingml/2006/main'
sp_tree = f'<p:spTree><p:nvGrpSpPr><p:cNvPr id="1" name=""/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="0" cy="0"/><a:chOff x="0" y="0"/><a:chExt cx="0" cy="0"/></a:xfrm></p:grpSpPr>{{shape}}</p:spTree>'
shape = f'<p:sp><p:nvSpPr><p:cNvPr id="2" name="Title"/><p:cNvSpPr txBox="1"/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm><a:off x="914400" y="1371600"/><a:ext cx="10363200" cy="1371600"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom><a:noFill/><a:ln><a:noFill/></a:ln></p:spPr><p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:r><a:rPr lang="en-US" sz="2800"><a:solidFill><a:srgbClr val="16845B"/></a:solidFill><a:latin typeface="Arial"/></a:rPr><a:t>{TEXT}</a:t></a:r></a:p></p:txBody></p:sp>'
parts = {
    '[Content_Types].xml': f'<Types xmlns="{CT}"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/><Override PartName="/ppt/slides/slide1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/><Override PartName="/ppt/slideMasters/slideMaster1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml"/><Override PartName="/ppt/slideLayouts/slideLayout1.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml"/></Types>',
    '_rels/.rels': rels('ppt/presentation.xml'),
    'ppt/presentation.xml': f'<p:presentation xmlns:p="{P}" xmlns:a="{A}" xmlns:r="{DOCREL}"><p:sldMasterIdLst><p:sldMasterId id="2147483648" r:id="rId2"/></p:sldMasterIdLst><p:sldIdLst><p:sldId id="256" r:id="rId1"/></p:sldIdLst><p:sldSz cx="12192000" cy="6858000"/><p:notesSz cx="6858000" cy="9144000"/></p:presentation>',
    'ppt/_rels/presentation.xml.rels': f'<Relationships xmlns="{REL}"><Relationship Id="rId1" Type="{DOCREL}/slide" Target="slides/slide1.xml"/><Relationship Id="rId2" Type="{DOCREL}/slideMaster" Target="slideMasters/slideMaster1.xml"/></Relationships>',
    'ppt/slides/slide1.xml': f'<p:sld xmlns:p="{P}" xmlns:a="{A}"><p:cSld>{sp_tree.format(shape=shape)}</p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sld>',
    'ppt/slides/_rels/slide1.xml.rels': rels('../slideLayouts/slideLayout1.xml', 'slideLayout'),
    'ppt/slideLayouts/slideLayout1.xml': f'<p:sldLayout xmlns:p="{P}" xmlns:a="{A}" type="blank"><p:cSld>{sp_tree.format(shape="")}</p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sldLayout>',
    'ppt/slideLayouts/_rels/slideLayout1.xml.rels': rels('../slideMasters/slideMaster1.xml', 'slideMaster'),
    'ppt/slideMasters/slideMaster1.xml': f'<p:sldMaster xmlns:p="{P}" xmlns:a="{A}" xmlns:r="{DOCREL}"><p:cSld>{sp_tree.format(shape="")}</p:cSld><p:clrMap accent1="accent1" accent2="accent2" accent3="accent3" accent4="accent4" accent5="accent5" accent6="accent6" bg1="lt1" bg2="lt2" folHlink="folHlink" hlink="hlink" tx1="dk1" tx2="dk2"/><p:sldLayoutIdLst><p:sldLayoutId id="2147483649" r:id="rId1"/></p:sldLayoutIdLst><p:txStyles/></p:sldMaster>',
    'ppt/slideMasters/_rels/slideMaster1.xml.rels': rels('../slideLayouts/slideLayout1.xml', 'slideLayout'),
}
package('sample.pptx', parts)

# A representative, owned deck complements the unchanged one-line regression
# fixture. All content and shapes are generated locally; the logo is our shared
# project asset. No customer files, remote media, fonts or conversion service.
def emu(value):
    return str(round(value * 914400))

def box(ident, x, y, width, height, fill=None, text=None, size=20, color='172033', bold=False):
    solid = f'<a:solidFill><a:srgbClr val="{fill}"/></a:solidFill>' if fill else '<a:noFill/>'
    paragraphs = ''
    if text is not None:
        for line in text.split('\n'):
            paragraphs += f'<a:p><a:pPr><a:lnSpc><a:spcPct val="115000"/></a:lnSpc></a:pPr><a:r><a:rPr lang="en-US" sz="{round(size * 100)}" b="{int(bold)}"><a:solidFill><a:srgbClr val="{color}"/></a:solidFill><a:latin typeface="Arial"/></a:rPr><a:t>{escape(line)}</a:t></a:r></a:p>'
    body = f'<p:txBody><a:bodyPr wrap="square" lIns="0" rIns="0" tIns="0" bIns="0"/><a:lstStyle/>{paragraphs}</p:txBody>' if text is not None else ''
    return f'<p:sp><p:nvSpPr><p:cNvPr id="{ident}" name="Shape {ident}"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr><p:spPr><a:xfrm><a:off x="{emu(x)}" y="{emu(y)}"/><a:ext cx="{emu(width)}" cy="{emu(height)}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom>{solid}<a:ln><a:noFill/></a:ln></p:spPr>{body}</p:sp>'

def brand():
    return f'<p:pic><p:nvPicPr><p:cNvPr id="2" name="File Viewer logo"/><p:cNvPicPr><a:picLocks noChangeAspect="1"/></p:cNvPicPr><p:nvPr/></p:nvPicPr><p:blipFill><a:blip r:embed="rIdLogo"/><a:stretch><a:fillRect/></a:stretch></p:blipFill><p:spPr><a:xfrm><a:off x="{emu(.75)}" y="{emu(.5)}"/><a:ext cx="{emu(.48)}" cy="{emu(.48)}"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></p:spPr></p:pic>'

def tour_slide(content, number):
    header = brand() + box(3, 1.4, .57, 8, .35, text='FILE VIEWER  /  FLUTTER', size=13, color='526275', bold=True)
    footer = box(4, .8, 6.88, 10.7, .3, text='Presentation tour  ·  Generated locally  ·  Bundled offline', size=11, color='64748B')
    footer += box(5, 12.05, 6.86, .5, .32, text=f'{number:02}', size=12, color='0C989D', bold=True)
    return f'<p:sld xmlns:p="{P}" xmlns:a="{A}" xmlns:r="{DOCREL}"><p:cSld><p:bg><p:bgPr><a:solidFill><a:srgbClr val="F8FAFC"/></a:solidFill><a:effectLst/></p:bgPr></p:bg>{sp_tree.format(shape=header + content + footer)}</p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sld>'

cover = box(10, .78, 1.72, .08, 2.3, fill='0C989D')
cover += box(11, 1.08, 1.7, 8, 2.5, text='Documents that\nfit your screen.', size=43, bold=True)
cover += box(12, 1.1, 4.43, 7.65, .85, text='A Flutter presentation viewport, powered by\nthe shared File Viewer rendering engine.', size=19, color='526275')
cover += box(13, 9.5, 1.75, 2.95, 3.85, fill='E4EFF1')
cover += box(14, 9.85, 2.18, 2.25, .35, text='ONE VIEWPORT', size=12, color='0C989D', bold=True)
cover += box(15, 9.85, 2.95, 2.25, 1.1, text='Fit. Zoom.\nPresent.', size=25, color='172033', bold=True)
cover += box(16, 9.85, 4.48, 2.25, .65, text='Native surfaces.\nOffline resources.', size=14, color='526275')

layout = box(10, .8, 1.45, 11.7, .65, text='Three ways to frame a slide', size=32, bold=True)
layout += box(11, .82, 2.18, 11.5, .5, text='Use automatic fitting, or choose a view for the task at hand.', size=17, color='526275')
for index, (title, copy) in enumerate([
    ('Auto fit', 'Keep the full slide visible\ninside the available viewport.'),
    ('Fit width', 'Use the available width\nfor a closer reading view.'),
    ('Actual size', 'Inspect text and shapes\nat their natural size.'),
]):
    left = .8 + index * 4
    layout += box(20 + index * 4, left, 3.05, 3.72, 2.68, fill='FFFFFF')
    layout += box(21 + index * 4, left, 3.05, 3.72, .06, fill='0C989D')
    layout += box(22 + index * 4, left + .25, 3.5, 3.2, .55, text=title, size=24, bold=True)
    layout += box(23 + index * 4, left + .25, 4.3, 3.2, 1.25, text=copy, size=16, color='526275')

navigation = box(10, .8, 1.45, 11.7, .65, text='Move through the presentation', size=32, bold=True)
navigation += box(11, .85, 2.55, 7.2, 3.3, text='01   Browse between slides\n\n02   Keep the chosen zoom\n\n03   Enter and leave slideshow mode', size=22, color='334155')
navigation += box(12, 8.75, 2.55, 3.65, 2.9, fill='E4EFF1')
navigation += box(13, 9.05, 3.05, 3.05, .55, text='1 / 3   →   2 / 3', size=23, color='0C989D', bold=True)
navigation += box(14, 9.05, 4.03, 3.05, .8, text='Try the page controls\nand slideshow button.', size=16, color='526275')

tour = dict(parts)
tour['[Content_Types].xml'] = tour['[Content_Types].xml'].replace('</Types>', '<Default Extension="png" ContentType="image/png"/>' + ''.join(f'<Override PartName="/ppt/slides/slide{i}.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>' for i in [2, 3]) + '</Types>')
tour['ppt/presentation.xml'] = tour['ppt/presentation.xml'].replace('r:id="rId2"', 'r:id="rId10"').replace('<p:sldId id="256" r:id="rId1"/>', ''.join(f'<p:sldId id="{255+i}" r:id="rId{i}"/>' for i in [1, 2, 3]))
tour['ppt/_rels/presentation.xml.rels'] = f'<Relationships xmlns="{REL}">' + ''.join(f'<Relationship Id="rId{i}" Type="{DOCREL}/slide" Target="slides/slide{i}.xml"/>' for i in [1, 2, 3]) + f'<Relationship Id="rId10" Type="{DOCREL}/slideMaster" Target="slideMasters/slideMaster1.xml"/></Relationships>'
for index, content in enumerate([cover, layout, navigation], 1):
    tour[f'ppt/slides/slide{index}.xml'] = tour_slide(content, index)
    tour[f'ppt/slides/_rels/slide{index}.xml.rels'] = f'<Relationships xmlns="{REL}"><Relationship Id="rId1" Type="{DOCREL}/slideLayout" Target="../slideLayouts/slideLayout1.xml"/><Relationship Id="rIdLogo" Type="{DOCREL}/image" Target="../media/logo.png"/></Relationships>'
tour['ppt/media/logo.png'] = (ROOT / 'brand.png').read_bytes()
package('presentation-tour.pptx', tour)

stream = f'BT /F1 20 Tf 50 760 Td ({TEXT}) Tj ET'.encode()
objects = [b'<< /Type /Catalog /Pages 2 0 R >>', b'<< /Type /Pages /Kids [3 0 R] /Count 1 >>', b'<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>', b'<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>', b'<< /Length ' + str(len(stream)).encode() + b' >>\nstream\n' + stream + b'\nendstream']
pdf = io.BytesIO(); pdf.write(b'%PDF-1.4\n'); offsets = [0]
for number, value in enumerate(objects, start=1):
    offsets.append(pdf.tell()); pdf.write(f'{number} 0 obj\n'.encode() + value + b'\nendobj\n')
xref = pdf.tell(); pdf.write(f'xref\n0 {len(objects)+1}\n0000000000 65535 f \n'.encode())
for offset in offsets[1:]: pdf.write(f'{offset:010d} 00000 n \n'.encode())
pdf.write(f'trailer\n<< /Size {len(objects)+1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n'.encode())
(ROOT / 'sample.pdf').write_bytes(pdf.getvalue())
print('Generated owned PDF, DOCX, XLSX, PPTX, and text integration fixtures.')
