import pyray as rl
import math
import random
from ship import Ship
from asteroid import Asteroid
import config as cfg

def main():
    #inicjalizacja okna gry i fps
    rl.init_window(cfg.SCREENW, cfg.SCREENH, "Giereczka")
    rl.set_target_fps(cfg.TARGET_FPS)

    #tworzenie gracza na środku ekranu
    player = Ship(cfg.SCREENW // 2, cfg.SCREENH // 2)
    
    #lista 5 asteroid o losowych pozycjach i rozmiarach
    asteroids = [
        Asteroid(random.randint(0, cfg.SCREENW), random.randint(0, cfg.SCREENH), random.choice(cfg.SIZES)) 
        for _ in range(cfg.COUNT)
    ]

    while not rl.window_should_close():
        dt = rl.get_frame_time() #czas od ostatniej klatki
    
        #aktualizacja logiki statku i wszystkich asteroid
        player.update(dt)
        for a in asteroids:
            a.update(dt)

        rl.begin_drawing()
        rl.clear_background(rl.BLACK)
        
        #rysowanie wszystkich obiektów na ekranie
        for a in asteroids:
            a.draw()
            
        player.draw()
        
        #obliczanie i wyświetlanie aktualnej prędkości statku
        current_speed = math.hypot(player.vel.x, player.vel.y)
        rl.draw_text(f"Speed: {current_speed:.2f}", 10, 10, 20, rl.GREEN)
        
        #licznik aktywnych asteroid
        rl.draw_text(f"Asteroids: {len(asteroids)}", 10, 40, 20, rl.GRAY)
        
        rl.end_drawing()

    rl.close_window()

if __name__ == "__main__":
    main()