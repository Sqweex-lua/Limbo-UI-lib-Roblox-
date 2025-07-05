
Roblox UI executor Library 

🧰 Usage
```lua
local window = UI:CreateWindow("My Menu")

UI:AddCheckbox(window, "Enable Feature", false, function(state)
    print("Checkbox:", state)
end)

UI:AddSlider(window, "Volume", 0, 100, 50, function(value)
    print("Slider value:", value)
end)
```
#  Roblox Limbo UI



---

##  Features

-  Draggable and resizable window  
-  Collapse / expand toggle    
-  Checkboxes  
-  Sliders  
-  Auto layout system  

---

##  Getting Started

```lua
local UI = loadstring(game:HttpGet("https://github.com/Sqweex-lua/Limbo-UI-lib-Roblox-"))()
```
