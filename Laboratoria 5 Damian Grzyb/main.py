import pyray as rl
from ship import Ship
import math

def main():
    rl.init_window(800, 600, "Giereczka")
    rl.set_target_fps(60)

    player = Ship(400, 300)

    while not rl.window_should_close():
        dt = rl.get_frame_time()
        
        player.update(dt)

        rl.begin_drawing()
        rl.clear_background(rl.BLACK)       
       
        player.draw()
        
        #oblcizanie i wyświetlanei aktualnej prędkości
        rl.draw_text(f"Speed: {math.hypot(player.vel.x, player.vel.y):.2f}", 10, 10, 20, rl.GREEN)
        
        rl.end_drawing()

    rl.close_window()

if __name__ == "__main__":
    main()