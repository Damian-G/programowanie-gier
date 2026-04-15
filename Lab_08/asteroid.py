import pyray as rl
import math
import random
from utils import get_ghost_positions
import config as cfg

class Asteroid:
    def __init__(self, x, y, level):
        self.pos = rl.Vector2(x, y)
        self.level = level # 3, 2 lub 1
        self.alive = True
        
        #promien i predkosc zalezne od poziomu
        if level == 3:
            self.radius = cfg.ASTEROID_L3_RAD
            speed_mult = 1.0
        elif level == 2:
            self.radius = cfg.ASTEROID_L2_RAD
            speed_mult = 1.6
        else:
            self.radius = cfg.ASTEROID_L1_RAD
            speed_mult = 2.4

        speed = random.uniform(cfg.ASTEROID_MIN_SPEED, cfg.ASTEROID_MAX_SPEED) * speed_mult
        angle = random.uniform(0, math.tau)
        self.vel = rl.Vector2(math.cos(angle) * speed, math.sin(angle) * speed)
        
        self.rotation = 0
        self.rot_speed = random.uniform(-1, 1)
        self.points = []
        num_points = cfg.POINTS_COUNT
        for i in range(num_points):
            a = (i / num_points) * math.tau
            #efekt skały bazujący na self.radius
            dist = self.radius * random.uniform(cfg.SHAPE_VARIATION[0], cfg.SHAPE_VARIATION[1])
            self.points.append(rl.Vector2(math.cos(a) * dist, math.sin(a) * dist))

    def split(self):
        #lista nowych mniejszych asteroid
        if self.level <= 1:
            return [] # Najmniejsza już się nie dzieli
        
        #dwie nowe asteroidy o jeden poziom niższe
        return [
            Asteroid(self.pos.x, self.pos.y, self.level - 1),
            Asteroid(self.pos.x, self.pos.y, self.level - 1)
        ]

    #zawijanie pozycji
    def wrap(self):
        self.pos.x %= cfg.SCREENW
        self.pos.y %= cfg.SCREENH

    def update(self, dt):
        #ruch liniowy asteroidy
        self.pos.x += self.vel.x * dt
        self.pos.y += self.vel.y * dt

        #obrót własny skały
        self.rotation += self.rot_speed * dt
        self.wrap()

    def draw(self):
        #pobieramy pozycje duchów dla płynnego przechodzenia przez krawędzie
        draw_positions = get_ghost_positions(self.pos, self.radius)
        
        for p in draw_positions:
            #transformacja punktów, rotacja i przesunięcie do pozycji p
            transformed = []
            for pt in self.points:
                #rotacja każdego wierzchołka o aktualny kąt
                rx = pt.x * math.cos(self.rotation) - pt.y * math.sin(self.rotation)
                ry = pt.x * math.sin(self.rotation) + pt.y * math.cos(self.rotation)
                transformed.append(rl.Vector2(rx + p.x, ry + p.y))
            
            #rysowanie linii między punktami
            for i in range(len(transformed)):
                p1 = transformed[i]
                p2 = transformed[(i + 1) % len(transformed)]
                rl.draw_line_v(p1, p2, rl.LIGHTGRAY)