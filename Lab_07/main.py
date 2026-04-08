import pyray as rl
import math
import random
from ship import Ship
from asteroid import Asteroid
from bullet import Bullet
import config as cfg
from utils import check_collision_circles
from explosion import Explosion
from utils import get_ghost_positions

def main():
    #inicjalizacja okna gry i fps
    rl.init_window(cfg.SCREENW, cfg.SCREENH, "Giereczka")
    
    rl.init_audio_device()
    shoot_snd = rl.load_sound("assets/shoot.wav")
    explode_snd = rl.load_sound("assets/explosion.wav")
    
    background_tex = rl.load_texture("assets/stars.png")
    
    rl.set_target_fps(cfg.TARGET_FPS)

    #tworzenie gracza na środku ekranu
    player = Ship(cfg.SCREENW // 2, cfg.SCREENH // 2)
    
    #lista 5 asteroid o losowych pozycjach i rozmiarach
    asteroids = [
        Asteroid(random.randint(0, cfg.SCREENW), random.randint(0, cfg.SCREENH), random.choice(cfg.SIZES)) 
        for _ in range(cfg.COUNT)
    ]

    bullets = []
    explosions = []

    while not rl.window_should_close():
        dt = rl.get_frame_time() #czas od ostatniej klatki
    
        #aktualizacja logiki statku i wszystkich asteroid
        player.update(dt)
        
        if rl.is_key_pressed(rl.KeyboardKey.KEY_SPACE):
            if len(bullets) < cfg.BULLET_LIMIT:
                nose = player.get_nose_position()
                #tworzymy pocisk przekazując mu pozycję nosa i kąt statku
                new_bullet = Bullet(nose.x, nose.y, player.rotation)
                bullets.append(new_bullet)
                #dźwięk
                rl.play_sound(shoot_snd)
            else:
                pass
            
        
        for a in asteroids:
            a.update(dt)
            
        for b in bullets:
            b.update(dt)
            
        for e in explosions:
            e.update(dt)
  
        for b in bullets:
            for a in asteroids:
                #kolizja pocisku z asteroida
                if b.alive and a.alive:
                    if check_collision_circles(b.pos, b.radius, a.pos, a.radius):
                        #trafienie
                        b.alive = False  #pocisk znika
                        a.alive = False  #asteroida znika
                        rl.play_sound(explode_snd) #dźwięk
                        
                        explosions.append(Explosion(a.pos.x, a.pos.y))
                        
        #kolizja statku z pociskiem 
        for b in bullets:
            if b.alive and b.timer > 0.1:
                bullet_ghosts = get_ghost_positions(b.pos, b.radius)
                
                for ghost_pos in bullet_ghosts:
                    if check_collision_circles(player.pos, cfg.SHIP_RADIUS, ghost_pos, b.radius):
                        b.alive = False
                        explosions.append(Explosion(player.pos.x, player.pos.y))
                        rl.play_sound(explode_snd)
                        player.reset()
                        break             
        
        #kolizja statku z asteroida
        for a in asteroids:
            if a.alive:
                if check_collision_circles(player.pos, cfg.SHIP_RADIUS, a.pos, a.radius):
                    explosions.append(Explosion(player.pos.x, player.pos.y))
                    rl.play_sound(explode_snd)
                    player.reset()
                    
                    a.alive = False

        #czyszczenie list
        bullets = [b for b in bullets if b.alive]
        asteroids = [a for a in asteroids if a.alive]    
        explosions = [e for e in explosions if e.alive]

        rl.begin_drawing()
        rl.clear_background(rl.BLACK)
        
        #tysowanie tł a
        rl.draw_texture_pro(
            background_tex,
            rl.Rectangle(0, 0, background_tex.width, background_tex.height),
            rl.Rectangle(0, 0, cfg.SCREENW, cfg.SCREENH),
            rl.Vector2(0, 0),
            0.0,
            rl.WHITE
        )
        
        #rysowanie wszystkich obiektów na ekranie
        for a in asteroids:
            a.draw()
            
        for b in bullets:
            b.draw()
            
        for e in explosions:
            e.draw()
            
        player.draw()
        
        #obliczanie i wyświetlanie aktualnej prędkości statku
        current_speed = math.hypot(player.vel.x, player.vel.y)
        rl.draw_text(f"Speed: {current_speed:.2f}", 10, 10, 20, rl.GREEN)
        
        #licznik aktywnych asteroid
        rl.draw_text(f"Asteroids: {len(asteroids)}", 10, 40, 20, rl.GRAY)

        #licznik pociskow
        rl.draw_text(f"Bullets: {len(bullets)}", 10, 70, 20, rl.YELLOW)
        
        ammo_left = cfg.BULLET_LIMIT - len(bullets)
        color = rl.YELLOW if ammo_left > 0 else rl.RED
        rl.draw_text(f"AMMO: {ammo_left}", 10, 100, 20, color)
        
        rl.end_drawing()
        
    rl.unload_sound(shoot_snd)
    rl.unload_sound(explode_snd)
    rl.unload_texture(background_tex)
    rl.close_audio_device()
    rl.close_window()

if __name__ == "__main__":
    main()