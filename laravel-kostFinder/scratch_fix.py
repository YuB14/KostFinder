import codecs
with codecs.open('resources/views/admin/pages/kost.blade.php', 'r', 'utf-8') as f:
    content = f.read()

target = '<td><b></b></td><td></td>\r\n<td><span class=\"pill \"></span></td>'
target_alt = '<td><b></b></td><td></td>\n<td><span class=\"pill \"></span></td>'
replacement = '<td><b></b></td><td></td>\n<td><span class=\"pill\" style=\"background:var(--bg2);color:var(--text);border:1px solid var(--border)\"></span></td>\n<td><span class=\"pill \"></span></td>'

if target in content:
    content = content.replace(target, replacement)
    debugPrint("Replaced with CRLF")
elif target_alt in content:
    content = content.replace(target_alt, replacement)
    debugPrint("Replaced with LF")
else:
    debugPrint("Target not found!")

with codecs.open('resources/views/admin/pages/kost.blade.php', 'w', 'utf-8') as f:
    f.write(content)
