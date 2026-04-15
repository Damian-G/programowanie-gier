import pyray as rl

class Explosion:
    def __init__(self, x, y):
        self.pos = rl.Vector2(x, y)
        self.radius = 2.0
        self.max_radius = 45.0
        self.alive = True
        self.timer = 0.0
        self.duration = 0.5

    def update(self, dt):
        self.timer += dt
        #postęp
        progress = self.timer / self.duration
        
        #rosnący promień
        self.radius = progress * self.max_radius
        
        #jak czas minął to oznaczamy jako martwy
        if self.timer >= self.duration:
            self.alive = False

    def draw(self):
        #zanikanie
        alpha = int(255 * (1.0 - self.timer / self.duration))
        color = rl.Color(255, 160, 50, alpha)
        
        #kontur wybuchu
        rl.draw_circle_lines(int(self.pos.x), int(self.pos.y), self.radius, color)