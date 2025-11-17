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
|Felület|K2|Pálya|v1.0|A felhasználó egy pályán tud játszani|
|Felület|K3|Karakter|v1.0|A felhasználó képes különböző típusú, fajú  és kinézetű karaktereket irányítani csaták során|
|Játékmenet|K4|Támadás|v1.0|A felhasználó minden körben tud bizonyos erősségű támadás intézni az ellenség felé|
|Játékmenet|K5|Gyógyítás|v1.0|A felhasználó minden körben tud gyógyítani magán, ha van nála gyógyító karakter|
|Játékmenet|K6|Recruitolás|v1.0|A csata kezdetekor vaálaszthatsz egy új karaktert a seregedbe|
|Játékmenet|K7|Fejlődés|v1.0|A felhasználó csapatában lévő karakterek minden csata után tapasztalati pontokat kapnak melyekből fejlődni tudnak|
|Felület|K8|Csata vége|v1.0|Minden csata után egy kijelzés, hogy győztes vagy vesztes volt az adott csata|
|Felület|K9|Játék vége|v1.0|A teljes játék végeztével bejön egy gratuláció és köszönetnyilvánítás, hogy végigvitte és játszott a játékkal|

### Igényelt üzleti folyamatok

A felhasználó a játékba lépést követően, kezdésként kap egy alap karakterekt tartalmazó sereget. A csata végeztével láthatja a csata eredményét és tud felvenni egy új karaktert a seregébe.

### Riportok

#### Hogyan lehet új játékot kezdeni?

    * A felhasználó belép a játékba, majd csatáról csatára halad előre a játékban

#### Hogyan lehet csatát kezdeni?

    * A lejátszott csata után automatikusan indul a következő

#### Hogyan lehet csatázni?

    * A felhasználó minden körben eldönthet, hogy mit szeretne csinálni karaktereivel. Miután vége a körének, az ellenfél következik

#### Hogyan lehet a karakterünket fejleszteni?

    * Győztes csaták után, a csatában lévő összes saját karakter automatikusan szintet lép

#### Hogyan lehet végigjátszani a játékot?

    * Az összes csatát végigcsinálva győztesen.

### Fogalomtár

* Stratégiai játék: A stratégiai játék egy videojáték-műfaj, ami gondolkodást és megfontolt tervezést igényel a győzelem eléréséhez.
* Szerepjáték: A szerepjáték olyan tevékenységek megnevezése, amelyben a résztvevők egyénként vagy csoportban különböző szerepeket játszanak el, a tevékenység időtartama alatt a játékok lényegét jelentő szerepvállalásoknak megfelelően viselkednek.
