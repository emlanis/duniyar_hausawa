#!/usr/bin/env python3
"""
Automatically fix all image paths in photo_quiz_data.dart
"""

# Image path mappings from the actual assets directory
# Format: 'shortname': 'actual_filename_with_extension'

ANIMALS_MAP = {
    'ram': 'ram.jpg',
    'cow': 'cow.jpg',
    'horse': 'horse.jpg',
    'goat': 'goat.jpeg',
    'camel': 'camel.jpg',
    'donkey': 'donkey.jpg',
    'chicken': 'chicken.jpg',
    'dog': 'dog.jpg',
    'damisa': 'damisa.jpg',
    'biri': 'biri.jpg',
    'giwa': 'giwa.jpeg',
    'zaki': 'zaki.jpg',
    'kura': 'kura.jpeg',
    'dila': 'dila.jpeg',
    'jeji': 'jeji.jpeg',
    'ragon_daji': 'ragon_daji.jpg',
    'kunkuru': 'kunkuru.jpg',
    'macji': 'macji.jpeg',
    'kada': 'kada.jpg',
    'hawainiya': 'hawainiya.jpeg',
    'agwagwa': 'agwagwa.jpeg',
    'jemage': 'jemage.jpg',
    'barewa': 'barewa.png',
    'tantabara': 'tantabara.jpg',
    'bera': 'bera.jpeg',
    'shaho': 'shaho.jpeg',
    'zakara': 'zakara.jpg',
    'zomo': 'zomo.jpg',
}

FOOD_MAP = {
    'tuwo': 'tuwo.webp',
    'miyar_kuka': 'miyar_kuka.webp',
    'fura_nono': 'fura_nono.jpg',
    'masa': 'masa.webp',
    'tsire': 'tsire.jpeg',
    'dankali': 'dankali.jpeg',
    'dan_wake': 'dan_wake.jpeg',
    'kosai': 'kosai.jpg',
    'funkaso': 'funkaso.jpg',
    'kuli_kuli': 'kuli_kuli.jpeg',
    'dambu': 'dambu.jpg',
    'miyar_taushe': 'miyar_taushe.jpg',
    'garin_kwaki': 'garin_kwaki.jpeg',
    'faten_wake': 'faten_wake.jpeg',
    'kilishi': 'kilishi.jpg',
    'waina': 'waina.jpeg',
    'miyar_kubewa': 'miyar_kubewa.jpeg',
    'miyar-agushi': 'miyar-agushi.jpg',  # Note: hyphen, not underscore
    'shayi': 'shayi.jpeg',
    'kunun_tsamiya': 'kunun_tsamiya.jpeg',
    'zobo': 'zobo.jpeg',
    'doya': 'doya.jpeg',
    'wake': 'wake.jpeg',
    'shinkafa': 'shinkafa.jpg',
    'gyada': 'gyada.jpeg',
    'rogo': 'rogo.jpeg',
}

TRADITIONAL_MAP = {
    'hula': 'hula.webp',
    'babbar_riga': 'babbar_riga.jpeg',
    'tagiya': 'tagiya.jpg',
    'kalangu': 'kalangu.jpeg',
    'zane': 'atamfa.jpeg',  # atamfa maps to zane image
    'randa': 'randa.jpg',
    'ganga': 'ganga.jpg',
    'algaita': 'algaita.webp',
    'kalankuwa': 'kalankuwa.webp',
    'lalle': 'lalle.jpeg',
    'tabarma': 'tabarma.jpeg',
    'kwarya': 'kwarya.jpeg',
    'ludayi': 'ludayi.jpg',
    'tulu': 'tulu.jpeg',
    'kwando': 'kwando.jpeg',
    'kansakali': 'kansakali.jpg',
    'bukka': 'bukka.jpg',
    'buta': 'buta.jpeg',
    'kwatanniya': 'kwatanniya.jpeg',
    'matankadi': 'matankadi.jpeg',
    'murhu': 'murhu.jpg',
    'tabarya': 'tabarya.webp',
    'takalmi': 'takalmi.webp',
    'rawani': 'rawani.jpeg',
    'alkyabba': 'alkyabba.jpeg',
}

PLANTS_MAP = {
    'kuka': 'kuka.webp',
    'dorawa': 'dorawa.jpg',
    'mangwaro': 'mangwaro.jpeg',
    'rogo': 'rogo.jpeg',
    'masara': 'masara.jpg',
    'gwanda': 'gwanda.jpg',
    'taura': 'taura.jpg',
    'tsamiya': 'tsamiya.jpg',
    'bagaruwa': 'bagaruwa.jpeg',
    'giginya': 'giginya.jpeg',
    'gawasa': 'gawasa.jpeg',
    'madaci': 'madaci.jpeg',
    'goriba': 'goriba.jpeg',
    'dabino_tree': 'dabino_tree.jpg',
    'auduga': 'auduga.jpg',
    'rimi': 'rimi.jpg',
    'zogale': 'zogale.jpeg',
    'bagayi': 'bagayi.jpg',
    'lemon_tsami': 'lemon_tsami.webp',
    'lemu': 'lemu.jpg',
    'aya': 'aya.jpg',
    'kabewa': 'kabewa.jpg',
    'ganye': 'ganye.jpg',
    'kankana': 'kankana.jpg',
    'albasa': 'albasa.jpg',
}

def fix_image_paths():
    """Read the Dart file and fix all image paths"""
    file_path = 'lib/data/photo_quiz_data.dart'

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Track replacements
    replacements = []

    # Fix Animals
    for short_name, full_name in ANIMALS_MAP.items():
        old_path = f"'animals/{short_name}'"
        new_path = f"'assets/images/animals/{full_name}'"
        if old_path in content:
            content = content.replace(old_path, new_path)
            replacements.append(f"✓ animals/{short_name} → {full_name}")

    # Fix Food
    for short_name, full_name in FOOD_MAP.items():
        old_path = f"'food/{short_name}'"
        new_path = f"'assets/images/food/{full_name}'"
        if old_path in content:
            content = content.replace(old_path, new_path)
            replacements.append(f"✓ food/{short_name} → {full_name}")

    # Fix Traditional
    for short_name, full_name in TRADITIONAL_MAP.items():
        old_path = f"'traditional/{short_name}'"
        new_path = f"'assets/images/traditional/{full_name}'"
        if old_path in content:
            content = content.replace(old_path, new_path)
            replacements.append(f"✓ traditional/{short_name} → {full_name}")

    # Fix Plants
    for short_name, full_name in PLANTS_MAP.items():
        old_path = f"'plants/{short_name}'"
        new_path = f"'assets/images/plants/{full_name}'"
        if old_path in content:
            content = content.replace(old_path, new_path)
            replacements.append(f"✓ plants/{short_name} → {full_name}")

    # Write the fixed content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"\n✅ Fixed {len(replacements)} image paths!\n")
    for r in replacements[:10]:  # Show first 10
        print(r)
    if len(replacements) > 10:
        print(f"... and {len(replacements) - 10} more")

    print(f"\n📝 File updated: {file_path}")

if __name__ == '__main__':
    fix_image_paths()