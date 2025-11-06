
# Szoftverfejlesztési Módszertanok

## Követelmény Specifikáció

### CSK2

#### *Zsibók Bence, Kiss Álmos, Szabó Balázs, Majoros Máté*

### Áttekintés

Az alkalmazás célja egy olyan felülnézetes körökre osztott 2D stratégiai szerepjáték, ahol a játékosok egy nehéz nap után, egy jót tudnak játszani, egy izgalmas játékkal, és úgy tudjanak felállni a számítógépük elől, hogy egy jót szórakoztak játék közben.

### Jelenlegi helyzet

Jelenleg kevés 2D-s stratégiai játék található a piacon

### Vágyálom rendszer

Egy olyan játék elkészítése a célunk, melyben a felhasználó képes egy megadott nehézségi szinten, a meglévő csapatával felvenni a harcot az ellenséges fajokkal. A játékot lehet botok ellen, illetve egy szerverre felcsatlakozva egymás ellen is játszani. A játékban a karakter tud fejlődni, új eszközöket/fegyvereket/felszereléseket szerezni ezzel megkönnyítve az előrehaladást. Egyszerre több karakter is lehet a játékos csapatában. Minden fajnak van egy szuperképessége.

### Követelménylista

|Modul|ID|Név|Verzió|Kifejtés|
|-----|--|---|------|--------|
|Felület|K1|Főmenü|v1.0|Új játék kezdése és a beállítások módosítása|
|Felület|K2|Pálya|v1.0|A felhasználó különböző kinézetű és különböző elemekből álló pályákon tud játszani|
|Felület|K3|Karakter|v1.0|A felhasználó képes különböző típusú, fajú  és kinézetű karaktereket irányítani csaták során|
|Játékmenet|K4|Nehézségi szint|v1.0|A felhasználó több különböző nehézségi szintből tud választani|
|Játékmenet|K5|Támadás|v1.0|A felhasználó minden körben tud bizonyos erősségű támadás intézni az ellenség felé|
|Játékmenet|K6|Fejlődés|v1.0|A felhasználó csapatában lévő karakterek minden csata után tapasztalati pontokat kapnak melyekből fejlődni tudnak|
|Felület|K7|Csata vége|v1.0|Minden csata után egy kijelzés, hogy győztes vagy vesztes volt az adott csata|
|Felület|K8|Játék vége|v1.0|A teljes játék végeztével bejön egy gratuláció és köszönetnyilvánítás, hogy végigvitte és játszott a játékkal|
|Mentés|K9|Játék mentése|v1.0|Az aktuális játékállás elmentése|
|Mentés|K10|Játék betöltése|v1.0|Egy korábban elmentett játékállás betöltése|
|Játékmenet|K11|Csata kiválasztása|v1.0|A térképen/listában megjelenő csaták egyikének kiválasztása|

### Igényelt üzleti folyamatok

A felhasználó a játékba lépést követően ki tudja választani a nehézségi szintet, majd kezdésként kap egy alap karakterekt tartalmazó sereget. A tutorial végigjátsása után ki tudja választani, hogy hol szeretne csatázni. A csata végeztével láthatja a csata eredményét.

### Riportok

#### Hogyan lehet új játékot kezdeni?

    * A felhasználó belép a játékba, kiválasztja a hozzá passzoló nehézségi szintet, majd elkezdődik a tutorial utánna meg a tényleges játék.

#### Hogyan lehet csatát kezdeni?

    * A felhasználó kiválasztja egy listából/térképről a kívánt harcot amiben részt szeretne venni.

#### Hogyan lehet csatázni?

    * A felhasználó minden körben eldönthet, hogy mit szeretne csinálni karaktereivel. Miután vége a körének, az ellenfél következik

#### Hogyan lehet a karakterünket fejleszteni?

    * Győztes csaták után, a csatában lévő összes saját karakter automatikusan szintet lép

#### Hogyan lehet végigjátszani a játékot?

    * Az összes csatát végigcsinálva győztesen.

### Fogalomtár

* Stratégiai játék: A stratégiai játék egy videojáték-műfaj, ami gondolkodást és megfontolt tervezést igényel a győzelem eléréséhez.
* Szerepjáték: A szerepjáték olyan tevékenységek megnevezése, amelyben a résztvevők egyénként vagy csoportban különböző szerepeket játszanak el, a tevékenység időtartama alatt a játékok lényegét jelentő szerepvállalásoknak megfelelően viselkednek.
* Nehézségi szint: A játék nehézségi szintje egy olyan, a játékos képességeitől és tapasztalatától függő paraméter, amely a játék kihívásának mértékét határozza meg, például a ellenségek erőssége, az erőforrások mennyisége vagy az összetett feladatok gyakorisága befolyásolásáva

