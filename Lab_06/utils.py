import pyray as rl

#stałe wymiary okna gry
SCREENW = 800
SCREENH = 600

def get_ghost_positions(pos, size):

    #oryginalna pozycja obiektu na liście
    positions = [pos]
    
    #sprawdzamy krawędzie czy obiekt wystaje za lewo/prawo
    if pos.x < size:
        #dodanie ducha z prawej strony ekranu
        positions.append(rl.Vector2(pos.x + SCREENW, pos.y))
    elif pos.x > SCREENW - size:
        #dodanie ducha z lewej strony ekranu
        positions.append(rl.Vector2(pos.x - SCREENW, pos.y))
        
    #sprawdzamy krawędzie pionowe dla wszystkich pozycji, obsługa rogów
    extra_positions = []
    for p in positions:
        if p.y < size:
            #dodanie ducha na dole ekranu
            extra_positions.append(rl.Vector2(p.x, p.y + SCREENH))
        elif p.y > SCREENH - size:
            #dodanie ducha na górze ekranu
            extra_positions.append(rl.Vector2(p.x, p.y - SCREENH))
    
    #połączenie wszystkich wyliczonych kopii w jedną listę do rysowania
    positions.extend(extra_positions)
    return positions