#!/bin/bash

# This script generates the correct Dart code with all image paths fixed
# Based on the actual files in assets/images/

echo "Generating fixed photo_quiz_data.dart..."

cat > lib/data/photo_quiz_data_fixed_temp.dart << 'DARTCODE'
// This file will contain all the image paths with correct extensions
// To be manually inserted into photo_quiz_data.dart

Animals paths (add 'assets/images/' prefix and extensions):
ram.jpg, cow.jpg, horse.jpg, goat.jpeg, camel.jpg, donkey.jpg, chicken.jpg, dog.jpg
damisa.jpg, biri.jpg, giwa.jpeg, zaki.jpg, kura.jpeg, dila.jpeg, jeji.jpeg, ragon_daji.jpg
kunkuru.jpg, macji.jpeg, kada.jpg, hawainiya.jpeg, agwagwa.jpeg, jemage.jpg, barewa.png
tantabara.jpg, tsuntsu.jpg (MISSING - needs to be added), bera.jpeg, shaho.jpeg, zakara.jpg, zomo.jpg

Food paths:
tuwo.webp, miyar_kuka.webp, fura_nono.jpg, masa.webp, tsire.jpeg, dankali.jpeg
dan_wake.jpeg, kosai.jpg, funkaso.jpg, kuli_kuli.jpeg, dambu.jpg, miyar_taushe.jpg
garin_kwaki.jpeg, faten_wake.jpeg, kilishi.jpg, waina.jpeg, miyar_kubewa.jpeg
miyar-agushi.jpg (note: hyphen, not underscore), shayi.jpeg, kunun_tsamiya.jpeg
zobo.jpeg, doya.jpeg, wake.jpeg, shinkafa.jpg, gyada.jpeg, rogo.jpeg

Traditional paths:
hula.webp, babbar_riga.jpeg, tagiya.jpg, kalangu.jpeg, atamfa.jpeg (MISSING - should be zane?)
randa.jpg, ganga.jpg, algaita.webp, kalankuwa.webp, lalle.jpeg
tabarma.jpeg, kwarya.jpeg, ludayi.jpg, tulu.jpeg, kwando.jpeg
kansakali.jpg, bukka.jpg, buta.jpeg, kwatanniya.jpeg, matankadi.jpeg
murhu.jpg, tabarya.webp, takalmi.webp, rawani.jpeg, alkyabba.jpeg

Plants paths:
kuka.webp, dorawa.jpg, mangwaro.jpeg, rogo.jpeg, masara.jpg
gwanda.jpg, taura.jpg, tsamiya.jpg, bagaruwa.jpeg, giginya.jpeg
gawasa.jpeg, madaci.jpeg, goriba.jpeg, dabino_tree.jpg, auduga.jpg
rimi.jpg, zogale.jpeg, bagayi.jpg, lemon_tsami.webp, lemu.jpg
aya.jpg, kabewa.jpg, ganye.jpg, kankana.jpg, albasa.jpg

DARTCODE

echo "File generated. Check lib/data/photo_quiz_data_fixed_temp.dart for reference"