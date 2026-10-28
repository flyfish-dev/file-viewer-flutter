#!/usr/bin/env python3
"""Generate small, redistributable SDK integration fixtures without user files."""
import io
import pathlib
import zipfile

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
