## Global Script
This is **NOT** made for softcoding, it is really for general purpose scripting.
Global scripts are independent of stages and states.

### Script Example
```lua
-- The `game` variable provides direct access to the PlayState.
function on_ready()
    local boyfriend = game.find_child("boyfriend")
    boyfriend.position.y += 500;
end

function on_process(delta)
    local gf = game.find_child("gf")
    gf.rotation += delta*100
end
```