import pyray as rl
import math
import random
from utils import SCREENW, SCREENH, get_ghost_positions
import config as cfg

class Ship:
    def __init__(self, x, y):
        self.pos = rl.Vector2(x, y) #pozycja startu statku
        self.vel = rl.Vector2(0, 0) #aktualna prędkość
        self.rotation = -math.pi / 2 #początkowy kąt obrotu
        
        #wierzchołki statku
        self.verts = [
            rl.Vector2(0, -35),
            rl.Vector2(-15, 15),
            rl.Vector2(15, 15)
        ]

        #tył statku, poprzeczka
        self.bar_points = [
            rl.Vector2(-11, 5),
            rl.Vector2(11, 5)
        ]

        self.size = 35

    #rotacja o dany kąt
    def rotate_point(self, p, angle):
        nx = p.x * math.cos(angle) - p.y * math.sin(angle)
        ny = p.x * math.sin(angle) + p.y * math.cos(angle)
        return rl.Vector2(nx, ny)

    #zawijanie pozycji
    def wrap(self):
        self.pos.x %= SCREENW
        self.pos.y %= SCREENH

    def update(self, dt):

        #obrót lewo prawo
        if rl.is_key_down(rl.KeyboardKey.KEY_LEFT) or rl.is_key_down(rl.KeyboardKey.KEY_A):
            self.rotation -= cfg.ROT_SPEED * dt
        if rl.is_key_down(rl.KeyboardKey.KEY_RIGHT) or rl.is_key_down(rl.KeyboardKey.KEY_D):
            self.rotation += cfg.ROT_SPEED * dt

        #jazda w przód
        if rl.is_key_down(rl.KeyboardKey.KEY_UP) or rl.is_key_down(rl.KeyboardKey.KEY_W):
            direction = rl.Vector2(math.cos(self.rotation), math.sin(self.rotation))
            self.vel.x += direction.x * cfg.THRUST * dt
            self.vel.y += direction.y * cfg.THRUST * dt

        #aktualna prędkość
        speed = math.hypot(self.vel.x, self.vel.y)

        #tarcie i hamulec
        if speed > 0:
            current_force = cfg.BRAKE_FORCE if rl.is_key_down(rl.KeyboardKey.KEY_Z) else cfg.FRICTION
            loss = current_force * dt
                
            if loss > speed:
                self.vel = rl.Vector2(0, 0)
            else:
                self.vel.x -= (self.vel.x / speed) * loss
                self.vel.y -= (self.vel.y / speed) * loss

        #ograniczenie prędkości max
        if speed > cfg.MAX_SPEED:
            self.vel.x = (self.vel.x / speed) * cfg.MAX_SPEED
            self.vel.y = (self.vel.y / speed) * cfg.MAX_SPEED

        #aktualizacja pozycji
        self.pos.x += self.vel.x * dt
        self.pos.y += self.vel.y * dt

        self.wrap()
        
    #pozycja nosa statku
    def get_nose_position(self):
        rotated = self.rotate_point(rl.Vector2(0, -35), self.rotation + math.pi/2)
        return rl.Vector2(rotated.x + self.pos.x, rotated.y + self.pos.y)
    
    #resetowanie statku
    def reset(self):
        self.pos = rl.Vector2(cfg.SCREENW // 2, cfg.SCREENH // 2)
        self.vel = rl.Vector2(0, 0)
        self.rotation = -math.pi / 2

    def draw(self):
        draw_positions = get_ghost_positions(self.pos, self.size)

        for p in draw_positions:
            
            #rysowanie kadłuba
            t_verts = []
            for v in self.verts:
                rotated = self.rotate_point(v, self.rotation + math.pi/2)
                t_verts.append(rl.Vector2(rotated.x + p.x, rotated.y + p.y))

            rl.draw_line_v(t_verts[0], t_verts[1], rl.WHITE)
            rl.draw_line_v(t_verts[2], t_verts[0], rl.WHITE)

            #rysowanie poprzeczki statku
            t_bar = []
            for v in self.bar_points:
                rot_bar = self.rotate_point(v, self.rotation + math.pi/2)
                t_bar.append(rl.Vector2(rot_bar.x + p.x, rot_bar.y + p.y))
            rl.draw_line_v(t_bar[0], t_bar[1], rl.WHITE)

            #rysowanie płomienia jak jedziemy, migotanie co 2 klatke, losowa długość płomienia
            if rl.is_key_down(rl.KeyboardKey.KEY_UP) or rl.is_key_down(rl.KeyboardKey.KEY_W):
                if (int(rl.get_time() * 20) % 2 == 0):
                    flame_len = random.uniform(20, 40)
                    
                    f_points = [
                        rl.Vector2(-7, 15),
                        rl.Vector2(0, flame_len),
                        rl.Vector2(7, 15)
                    ]
                    
                    t_flame = []
                    for v in f_points:
                        rot_f = self.rotate_point(v, self.rotation + math.pi/2)
                        t_flame.append(rl.Vector2(rot_f.x + p.x, rot_f.y + p.y))
                    
                    rl.draw_line_v(t_flame[0], t_flame[1], rl.GOLD)
                    rl.draw_line_v(t_flame[1], t_flame[2], rl.GOLD)

            #rysowanie świateł hamowania
            if rl.is_key_down(rl.KeyboardKey.KEY_Z):
                p1_rot = self.rotate_point(rl.Vector2(-18, 24), self.rotation + math.pi/2)
                p2_rot = self.rotate_point(rl.Vector2(18, 24), self.rotation + math.pi/2)
                rl.draw_circle_v(rl.Vector2(p1_rot.x + p.x, p1_rot.y + p.y), 3, rl.RED)
                rl.draw_circle_v(rl.Vector2(p2_rot.x + p.x, p2_rot.y + p.y), 3, rl.RED)