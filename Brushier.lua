if app.apiVersion < 22 then
    return app.alert("This script requires Aseprite v1.3-rc2")
end


local dialog = Dialog{
    title="Brushier",
    notitlebar=false,
   
}

local previousSize = app.brush.size;
local brushType = app.brush.type;

local plt = app.sprite.palettes[1];
local clrs = {}

local current = 0

while current < #plt do
    clrs[current] = plt:getColor(current)
    current = current + 1
end

local function changeBrushType()
    local nBrush = Brush{
        size = previousSize,
        type = brushType
    }
    app.brush = nBrush
end

dialog
:button{ 
    id="brushTypeS",
    text="Square",
    onclick= function(ev)
        brushType = BrushType.SQUARE
        changeBrushType()

    end
}
:button{ 
    id="brushTypeC",
    text="Circle",
    onclick= function(ev)
        brushType = BrushType.CIRCLE
        changeBrushType()
    end
}
:separator{}
:slider{
    id = "brushSize",
    min=1,
    max=64,
    value=app.brush.size,
    onrelease = function(ev)
       local data = dialog.data.brushSize
       local nBrush = Brush{
        type = brushType,
        size = data
        }
        app.brush = nBrush

        local i = previousSize - data;
        local j = 0;
        if i < 0 then
            i = i * -1;
            while j < i do
                app.command.ChangeBrush{
                    change = "increment-size"
                }
                j = j + 1  
            end
        else 
            while j < i do
                app.command.ChangeBrush{
                    change = "decrement-size"
                }
                j = j + 1  
            end
        end

        previousSize = data;
    end
}
:separator{}

current = 0;
local shades = {table.unpack(clrs, current, 5)}

while #shades > 0 do
    dialog:shades{ 
        id="pallete",
        label="",
        mode="pick",
        colors=shades,
        onclick=function(ev)
            app.fgColor = ev.color
        end
    }
    current = current + 6;
    shades = {table.unpack(clrs, current, current + 5)}
    
    if shades == nil then
        break;
    end

end

dialog:separator{}
:button{ 
    id="close",
    text="Close (Esc)",
    onclick= function(ev)
        dialog:close()
    end
}

local bounds = dialog.bounds
dialog.bounds = Rectangle(app.editor.mousePos.x - (bounds.width / 2) - 6, app.editor.mousePos.y - (bounds.height / 2), bounds.width, bounds.height)

dialog:show()
