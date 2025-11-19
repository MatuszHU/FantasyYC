# Funkcionális specifikáció

## Áttekintés

Az alkalmazás célja egy olyan felülnézetes körökre osztott 2D stratégiai szerepjáték, ahol a játékosok egy nehéz nap után, egy jót tudnak játszani, egy izgalmas játékkal, és úgy tudjanak felállni a számítógépük elől, hogy egy jót szórakoztak játék közben.

## Jelenlegi helyzet

Jelenleg kevés 2D-s stratégiai játék található a piacon

## Funkciólista

|Modul|Követelmény ID|ID|Név|Verzió|Kifejtés|
|-----|--------------|--|---|------|--------|
|Felület|K1|F1|Főmenü|v1.0|A játék indítása, új játék kezdése és beállítások elérése|
|Felület|K2|F2|Pálya|v1.0|A játéktér megjelenítése, ahol a felhasználó játszhat|
|Felület|K3|F3|Karakter|v1.0|Különböző típusú/fajú/kinézetű karakterek megjelenítése és irányítása csatákban|
|Játékmenet|K4|F4|Támadás|v1.0|A felhasználó minden körben támadást tud indítani meghatározott erősséggel|
|Játékmenet|K5|F5|Gyógyítás|v1.0|Ha a csapatban van gyógyító karakter, gyógyítás végrehajtása körönként|
|Játékmenet|K6|F6|Recruitolás|v1.0|A csata elején új karakter választható a csapatba|
|Játékmenet|K7|F7|Fejlődés|v1.0|A csata utáni tapasztalati pontok kiosztása és karakterek fejlődése|
|Játékmenet|K8|F8|Képességek|v1.0|A karakter egyedi képességek használatára képes|
|Felület|K9|F9|Csata vége|v1.0|A csata győzelem/vesztés kijelzése a felhasználónak|
|Felület|K10|F10|Játék vége|v1.0|A teljes játék végén gratuláció és köszönet megjelenítése.|

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
