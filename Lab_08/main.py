import pyray as rl
import math
import random
from ship import Ship
from asteroid import Asteroid
from bullet import Bullet
import config as cfg
from utils import check_collision_circles, cleanup_dead
from explosion import Explosion
from enum import Enum, auto

class State(Enum):
    MENU = auto()
    GAME = auto()
    GAME_OVER = auto()

#rysowanie napisów na ekranie podczas gry
def draw_hud(score, best, speed, ast_count, ammo):
    rl.draw_text(f"SCORE: {score}", 10, 10, cfg.FONT_SIZE_SMALL, rl.RAYWHITE)
    rl.draw_text(f"BEST: {best}", 10, 35, cfg.FONT_SIZE_SMALL, rl.GOLD)
    rl.draw_text(f"Speed: {speed:.2f}", 10, cfg.SCREENH - 60, cfg.FONT_SIZE_SMALL, rl.GREEN)
    rl.draw_text(f"Asteroids: {ast_count}", 10, cfg.SCREENH - 40, cfg.FONT_SIZE_SMALL, rl.GRAY)
    
    #zmiana koloru amunicji na czerwony jak pusto
    color = rl.YELLOW if ammo > 0 else rl.RED
    rl.draw_text(f"AMMO: {ammo}", 10, cfg.SCREENH - 20, cfg.FONT_SIZE_SMALL, color)

#sprawdzanie czy pociski trafily w asteroidy
def handle_collisions(bullets, asteroids, explosions, explode_snd):
    added_score = 0
    for bullet in bullets:
        for asteroid in asteroids:
            if bullet.alive and asteroid.alive and check_collision_circles(bullet.pos, bullet.radius, asteroid.pos, asteroid.radius):
                bullet.alive = False
                asteroid.alive = False
                rl.play_sound(explode_snd)
                
                #naliczanie punktow za konkretny rozmiar
                if asteroid.level == 3: added_score += cfg.ASTEROID_L3_SCORE
                elif asteroid.level == 2: added_score += cfg.ASTEROID_L2_SCORE
                elif asteroid.level == 1: added_score += cfg.ASTEROID_L1_SCORE
                
                #rozpad i wybuch
                asteroids.extend(asteroid.split())
                explosions.append(Explosion(asteroid.pos.x, asteroid.pos.y))
    return added_score

#napisy w menu glownym
def draw_menu_screen(font):
    alpha = int(127 + 127 * math.sin(rl.get_time() * 5))
    pulse_color = rl.Color(255, 255, 255, alpha)
    
    t1 = "ASTEROIDS"
    t2 = "SPACJA - START"

    size1 = rl.measure_text_ex(font, t1, cfg.FONT_SIZE_BIG, 2)
    size2 = rl.measure_text_ex(font, t2, cfg.FONT_PULSE, 2)
    
    #rysowanie napisu głównego
    rl.draw_text_ex(font, t1, 
                    rl.Vector2(cfg.SCREENW//2 - size1.x//2, cfg.SCREENH//2 - cfg.MENU_Y_OFFSET), 
                    cfg.FONT_SIZE_BIG, 2, rl.WHITE)
    
    #rysowanie pulsującego napisu
    rl.draw_text_ex(font, t2, 
                    rl.Vector2(cfg.SCREENW//2 - size2.x//2, cfg.SCREENH//2 + cfg.MENU_PROMPT_OFFSET), 
                    cfg.FONT_PULSE, 2, pulse_color)

    footer = "v1.0 | Project by DamianG"
    rl.draw_text(footer, 10, cfg.SCREENH - 35, 30, rl.DARKGRAY)

#logika-
def update_game(dt, player, bullets, asteroids, explosions, engine_snd, shoot_snd, explode_snd, spawn_time):
    added_score = 0
    next_state = State.GAME
    game_win = False

    player.update(dt)
    
    #jeśli gaz wciśnięty
    if rl.is_key_down(rl.KeyboardKey.KEY_UP) or rl.is_key_down(rl.KeyboardKey.KEY_W):
        rl.set_sound_volume(engine_snd, 0.5)
        if not rl.is_sound_playing(engine_snd):
            rl.play_sound(engine_snd)
    else:
        rl.set_sound_volume(engine_snd, 0.0)
    
    #strzelanie
    if rl.is_key_pressed(rl.KeyboardKey.KEY_SPACE) and len(bullets) < cfg.BULLET_LIMIT:
        nose = player.get_nose_position()
        bullets.append(Bullet(nose.x, nose.y, player.rotation))
        rl.play_sound(shoot_snd)
    
    #ruszanie obiektami
    for obj in asteroids + bullets + explosions:
        obj.update(dt)

    #punkty i kolizje
    added_score = handle_collisions(bullets, asteroids, explosions, explode_snd)

    #czy asteroida walnela w gracza (niesmiertelnosc 1s na start)
    for a in asteroids:
        if (rl.get_time() - spawn_time) > 1.0:
            if a.alive and check_collision_circles(player.pos, cfg.SHIP_RADIUS, a.pos, a.radius):
                explosions.append(Explosion(player.pos.x, player.pos.y))
                rl.play_sound(explode_snd)
                rl.set_sound_volume(engine_snd, 0.0)
                game_win = False
                next_state = State.GAME_OVER

    #czy zniszczylsimy wszystkie asteroidy
    if len(asteroids) == 0:
        rl.set_sound_volume(engine_snd, 0.0)
        game_win = True
        next_state = State.GAME_OVER
    
    return added_score, next_state, game_win

#rysowanie
def draw_game_scene(player, bullets, asteroids, explosions, score, best):
    for obj in asteroids + bullets + explosions: 
        obj.draw()
    
    if player is not None:
        player.draw()
        # HUD rysujemy tylko jak gracz istnieje, żeby nie było błędu z .vel
        draw_hud(score, best, math.hypot(player.vel.x, player.vel.y), len(asteroids), cfg.BULLET_LIMIT - len(bullets))

def main():
    #start rayliba i ladowanie dzwiekow/tekstur
    rl.init_window(cfg.SCREENW, cfg.SCREENH, "Giereczka")
    rl.init_audio_device()
    
    custom_font = rl.load_font_ex("assets/czcionka1.ttf", 90, None, 0)
    shoot_snd = rl.load_sound("assets/shoot.wav")
    explode_snd = rl.load_sound("assets/explosion.wav")
    bg_tex = rl.load_texture("assets/stars.png")
    engine_snd = rl.load_sound("assets/fsss.wav")
    rl.play_sound(engine_snd) 
    rl.set_sound_volume(engine_snd, 0.0)
    
    rl.set_target_fps(cfg.TARGET_FPS)

    current_state = State.MENU
    score, best = 0, 0
    spawn_time = 0.0
    win = False
    
    #inicjalizacja list i gracza
    player = None
    bullets = []
    explosions = []
    #tworzymy asteroidy od razu, żeby latały w menu
    asteroids = [Asteroid(random.randint(0, cfg.SCREENW), random.randint(0, cfg.SCREENH), 3) for _ in range(cfg.COUNT)]

    #resetowanie wszystkiego do nowej rundy
    def init_game():
        nonlocal player, asteroids, bullets, explosions, score, spawn_time
        player = Ship(cfg.SCREENW // 2, cfg.SCREENH // 2)
        asteroids[:] = [Asteroid(random.randint(0, cfg.SCREENW), random.randint(0, cfg.SCREENH), 3) for _ in range(cfg.COUNT)]
        bullets.clear()
        explosions.clear()
        spawn_time = rl.get_time()
        score = 0

    while not rl.window_should_close():
        dt = rl.get_frame_time()

        if current_state == State.MENU:
            #ruch asteroid w menu
            for a in asteroids:
                a.update(dt)
            
            if rl.is_key_pressed(rl.KeyboardKey.KEY_SPACE):
                init_game()
                current_state = State.GAME

        elif current_state == State.GAME:
            added, next_st, is_win = update_game(dt, player, bullets, asteroids, explosions, engine_snd, shoot_snd, explode_snd, spawn_time)
            score += added
            if score > best: best = score
            current_state = next_st
            win = is_win
            
            #usuwanie zniszczonych rzeczy
            bullets = cleanup_dead(bullets)
            asteroids = cleanup_dead(asteroids)
            explosions = cleanup_dead(explosions)

        elif current_state == State.GAME_OVER:
            if rl.is_key_pressed(rl.KeyboardKey.KEY_R):
                current_state = State.MENU

        #draw
        rl.begin_drawing()
        rl.clear_background(rl.BLACK)
        
        #tlo na caly ekran
        rl.draw_texture_pro(bg_tex, rl.Rectangle(0,0,bg_tex.width, bg_tex.height), 
                            rl.Rectangle(0,0,cfg.SCREENW, cfg.SCREENH), rl.Vector2(0,0), 0, rl.WHITE)

        if current_state == State.MENU:
            for a in asteroids: 
                a.draw()
            draw_menu_screen(custom_font)
            
        elif current_state == State.GAME:
            draw_game_scene(player, bullets, asteroids, explosions, score, best)
            
        elif current_state == State.GAME_OVER:
            #tlo pulsujące przy game over
            pulse_val = int(50 + 50 * math.sin(rl.get_time() * 3.0))
            bg_color = rl.Color(pulse_val, 0, 0, 255)
            rl.draw_rectangle(0, 0, cfg.SCREENW, cfg.SCREENH, bg_color)

            msg = "ZWYCIESTWO!" if win else "GAME OVER"
            clr = rl.GREEN if win else rl.RED
            
            #wyswietlanie wyniku koncowego
            size_msg = rl.measure_text_ex(custom_font, msg, 100, 2)
            rl.draw_text_ex(custom_font, msg, rl.Vector2(cfg.SCREENW//2 - size_msg.x//2, cfg.SCREENH//2 - 150), 100, 2, clr)
            
            rl.draw_text(f"SCORE: {score}", cfg.SCREENW//2 - rl.measure_text(f"SCORE: {score}", 40)//2, cfg.SCREENH//2 - 50, 40, rl.WHITE)
            rl.draw_text(f"HIGHSCORE: {best}", cfg.SCREENW//2 - rl.measure_text(f"HIGHSCORE: {best}", 40)//2, cfg.SCREENH//2, 40, rl.YELLOW)
        
            #pulsowanie napisu powrotu
            alpha = int(127 + 127 * math.sin(rl.get_time() * 5.0))
            pulse_color = rl.Color(255, 255, 255, alpha)
            rl.draw_text_ex(custom_font, "R - POWROT",  rl.Vector2(cfg.SCREENW//2 - rl.measure_text_ex(custom_font, "R - POWROT", 50, 2).x//2, cfg.SCREENH//2 + 80), 50, 2, pulse_color)

        rl.end_drawing()

    #sprzatanie pamieci przed wyjsciem
    rl.unload_sound(shoot_snd)
    rl.unload_sound(explode_snd)
    rl.unload_texture(bg_tex)
    rl.unload_sound(engine_snd)
    rl.unload_font(custom_font)
    rl.close_audio_device()
    rl.close_window()

if __name__ == "__main__":
    main()