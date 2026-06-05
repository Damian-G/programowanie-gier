# Galaxy Cleaner 🚀

![Godot Engine](https://img.shields.io/badge/Godot-4.x-blue?logo=godotengine&logoColor=white)
![GDScript](https://img.shields.io/badge/Language-GDScript-green)
![Status](https://img.shields.io/badge/Status-Zakończony-success)

![Ekran z gry](gra.png)

> **Galaxy Cleaner** to dynamiczna gra zręcznościowa 2D osadzona w przestrzeni kosmicznej. Gracz wciela się w postać robota-sprzątacza, którego celem jest oczyszczenie planety z zalegających odpadów. Rozgrywka polega na zbieraniu śmieci i dostarczaniu ich do wyznaczonego kosza. Na drodze gracza stoją przeciwnicy oraz pułapki terenowe. Gra oferuje trzy poziomy trudności (**łatwy**, **średni**, **trudny**), które różnią się intensywnością spawnienia obiektów oraz liczbą przeciwników.

---

## Jak się gra?
* **Cel:** Posprzątaj planetę, zbierając śmieci i wyrzucając je do kosza. Uważaj na wrogów i pułapki!
* **Plecak:** Masz limit 4 śmieci w plecaku. Musisz wracać do kosza, aby go opróżnić.
* **Życia:** Masz 3 życia. Możesz je odzyskać, zbierając apteczki.

### Sterowanie:
| Klawisz / Akcja | Działanie |
| :--- | :--- |
| `← / →` | Ruch postaci |
| `↑` | Skok |
| `E` | Wyrzucenie śmieci do kosza |
| `Ctrl Lewy` | Ślizg |
| `Spacja` | Strzelanie do wrogów |

---

## Silnik i uruchomienie
* **Silnik:** Godot 4.x
* **Język:** GDScript

### Jak uruchomić?
1. Pobierz repozytorium projektu.
2. Otwórz projekt w edytorze Godot 4.x.
3. Naciśnij F5 lub przycisk Play, aby uruchomić grę.

---

## Własne mechanizmy
## ⚙️ Własne mechanizmy
Projekt zawiera autorskie rozwiązania strukturalne i algorytmiczne, które wykraczają poza standardowe założenia projektowe:

* **Dynamiczny System Proceduralnego Spawnowania:** Obiekty (śmieci, wrogowie, apteczki) nie są rozmieszczane statycznie na scenie. Autorski system menedżerów losuje pozycje z elastycznej puli węzłów `Marker2D` przy każdym uruchomieniu poziomu, co zapewnia wysoką regrywalność. Dodatkowo intensywność oraz limity obiektów skalują się w czasie rzeczywistym na podstawie wybranego poziomu trudności.
* **Logistyka Odpadów:** System plecaka (ograniczenie do max 4 sztuk) wymusza na graczu planowanie optymalnej trasy między strefami zanieczyszczeń a punktem zrzutu.
* **FSM (Maszyna Stanów) i Sztuczna Inteligencja:** Logika postaci została oparta na architekturze maszyny stanów, co gwarantuje płynne przejścia animacji oraz pełną kontrolę nad zachowaniem obiektów:
  * **Gracz (`gracz.gd`):** Zarządza stanami `IDLE`, `RUN`, `JUMP`, `FALL`, `DEAD`, `SLIDE` oraz `SHOOT` z bezpieczną, dynamiczną manipulacją kształtami kolizji za pomocą metody `set_deferred`.
  * **Przeciwnik (`wrog.gd`):** Autonomiczne AI operujące w stanach `PATROL`, `POGON`, `POWROT` i `DEAD`. Do wykrywania gracza i sprawdzania linii wzroku (Dynamic Vision) wykorzystuje zaawansowany raycasting za pomocą klasy `PhysicsRayQueryParameters2D`.

---

## System shaderów
Gra wykorzystuje zaawansowane efekty wizualne stworzone w języku shaderów:
1. **Proceduralne tło:** Shader kosmosu z gwiazdami i mgławicami generowany w czasie rzeczywistym.
2. **Efekty Vertex:** Organiczne bujanie trawy i pulsowanie apteczek (dodatkowych żyć).
3. **Custom Bloom:** Autorski algorytm poświaty dla obiektów typu "śmieć".
4. **Dystorsja:** Shader bagna zniekształcający obraz w niebezpiecznych strefach.
5. **Shader interaktywny kapsuły:** Efekt wizualny wyróżniający kluczowy element fabularny na mapie.
6. **Shader przepływu w rurach:** Efekt symulujące ruch substancji wewnątrz elementów otoczenia.

---

## Wykorzystane zasoby
| Typ | Źródło |
| :--- | :--- |
| **Grafiki** | [itch.io](https://itch.io) |
| **Dźwięki / BGM** | [Pixabay](https://pixabay.com) |

---

## Znane bugi
* **Kolizja podczas ślizgu:** Podczas gdy gracz aktywuje ślizg bezpośrednio przy kolizji z kafelkiem, może dojść do zablokowania mechaniki ślizgu.

---

## Czy projekt jest klonem?
**Nie, jest to projekt w 100% autorski.** Gra nie jest oparta na żadnym konkretnym tutorialu ani gotowym projekcie.
