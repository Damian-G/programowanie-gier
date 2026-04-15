import pyray as rl
import math
import config as cfg
from utils import get_ghost_positions

class Bullet:
    def __init__(self, x, y, angle):
        self.pos = rl.Vector2(x, y)
        self.radius = 2
        self.alive = True
        self.timer = 0.0
        self.ttl = cfg.BULLET_LIFE
        
        #prędkość pocisku
        speed = cfg.BULLETS_MAX_SPEED * 1.5
        self.vel = rl.Vector2(math.cos(angle) * speed, math.sin(angle) * speed)

    def wrap(self):
        self.pos.x %= cfg.SCREENW
        self.pos.y %= cfg.SCREENH

    def update(self, dt):
        #ruch pocisku
        self.pos.x += self.vel.x * dt
        self.pos.y += self.vel.y * dt
        
        self.timer += dt
        
        #skracanie czasu życia
        self.ttl -= dt
        if self.ttl <= 0:
            self.alive = False
            
        self.wrap()

    def draw(self):
        #rysowanie pocisku
        draw_positions = get_ghost_positions(self.pos, self.radius)
        for p in draw_positions:
            rl.draw_circle_v(p, self.radius, rl.YELLOW)