# Funkcionális specifikáció

## Áttekintés

Az alkalmazás célja egy olyan felülnézetes körökre osztott 2D stratégiai szerepjáték, ahol a játékosok egy nehéz nap után, egy jót tudnak játszani, egy izgalmas játékkal, és úgy tudjanak felállni a számítógépük elől, hogy egy jót szórakoztak játék közben.

## Jelenlegi helyzet

Jelenleg kevés 2D-s stratégiai játék található a piacon

## Követelménylista

|Modul|ID|Név|Verzió|Kifejtés|
|-----|--|---|------|--------|
|Felület|K1|Főmenü|v1.0|Új játék kezdése és a beállítások módosítása|
|Felület|K2|Pálya|v1.0|A felhasználó egy pályán tud játszani|
|Felület|K3|Karakter|v1.0|A felhasználó képes különböző típusú, fajú  és kinézetű karaktereket irányítani csaták során|
|Játékmenet|K4|Gyógyítás|v1.0|A felhasználó minden körben tud gyógyítani magán, ha van nála gyógyító karakter|
|Játékmenet|K5|Támadás|v1.0|A felhasználó minden körben tud bizonyos erősségű támadás intézni az ellenség felé|
|Játékmenet|K6|Fejlődés|v1.0|A felhasználó csapatában lévő karakterek minden csata után tapasztalati pontokat kapnak melyekből fejlődni tudnak|
|Játékmenet|K7|Képességek|v1.0|A felhasználó tud különböző képességeket használni|
|Felület|K8|Csata vége|v1.0|Minden csata után egy kijelzés, hogy győztes vagy vesztes volt az adott csata|
|Felület|K9|Játék vége|v1.0|A teljes játék végeztével bejön egy gratuláció és köszönetnyilvánítás, hogy végigvitte és játszott a játékkal|

## Használati esetek

* Játékos:
  * Feldata, hogy karaktereit irányítva legyőzze az ellenséges csapatot, ezzel megnyerve a csatákat és idővel kivigye a játékot
* Karakter:
  * Feladata, hogy segítse a játékost az ellenfelek legyőzésében. Egy karaktert a játékos irányítja
* Ellenfél:
  * Feladata, hogy gátolja a játékost a csaták megnyerésében

## Képernyőtervek

  * Főmenü
       * ![Főmenü](./Képek/MainMenu.png)
     * Toborzó képernyő
       * ![Toborzó képernyő](./Képek/Recruiting.png)
     * Játék vége képernyő
       * ![Játék vége](./Képek/End.png)
     * Beállítások képernyő
       * ![Beállítások](./Képek/End.png)

## Forgatókönyv

* A folyamtban 2 szereplő figyelhető meg. Elsőkén ott van maga a játék, mely biztosítja a játékmenetet és a felhasználói felületet. Ezzel van inerakcióban a második szereplő a játékos, aki játszik a játékkal, ezálltal befolyásolja annak állapotát

### Fogalomszótár
  
* Stratégiai játék: A stratégiai játék egy videojáték-műfaj, ami gondolkodást és megfontolt tervezést igényel a győzelem eléréséhez.
* Szerepjáték: A szerepjáték olyan tevékenységek megnevezése, amelyben a résztvevők egyénként vagy csoportban különböző szerepeket játszanak el, a tevékenység időtartama alatt a játékok lényegét jelentő szerepvállalásoknak megfelelően viselkednek.
