import re

with open('resources/views/admin/pages/kost.blade.php', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the pickWilayah call
content = content.replace(
    '''onclick="pickWilayah('', '', '', this.textContent)"''',
    '''onclick="pickWilayah('', '', this.textContent)"'''
)

with open('resources/views/admin/pages/kost.blade.php', 'w', encoding='utf-8') as f:
    f.write(content)
