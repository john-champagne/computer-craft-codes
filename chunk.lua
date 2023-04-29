require("mvmt")

function get_int_triple(S)
    local t = {}
    for num in S:gmatch("-?%d+") do
        table.insert(t, tonumber(num))
    end
    return t[1], t[2], t[3]
end

function read_table_from_file(filename)
    local file = fs.open(filename, "r")
    local contents = textutils.unserialize(file.readAll())
    file.close()
    return contents
end

function save_table_to_file(tableToSave, filename)
    local file = fs.open(filename, "w")
    file.write(textutils.serialize(tableToSave))
    file.close()
end

function __is_in_list(a,l)
    for i,v in pairs(l) do
        if a == v then return true end
    end
    return false
end

-- Get current position
term.clear()
term.setCursorPos(1,1)
print("What is my position? (x,y,z)")
io.write(">")
local S = io.read()
local x_init, y_surface, z_init = get_int_triple(S)

-- Get in-chunk coords
local x_chunk = math.floor(x_init / 16)
local z_chunk = math.floor(z_init / 16)
x_init = x_init % 16
z_init = z_init % 16

-- Get direction
term.clear()
term.setCursorPos(1,1)
print("What is my direction? (z+, z-, x+, x-)")
io.write(">")
local S_dir = io.read()

-- Get min y level
term.clear()
term.setCursorPos(1,1)
print("How deep should I go? [-60]")
io.write(">")
S = io.read()
local y_min = -60

if S ~= "" and tonumber(S) > -60 then
    y_min = tonumber(S)
end

-- Init
local mvmt = mvmt:create(x_init, y_surface, z_init, S_dir)

-- Init cache and load data
local y_levels_completed = {}
local filename = ".int/chunk/" .. x_chunk .. "_" .. z_chunk .. ".json"
if fs.exists(".int/chunk/") then
    if fs.exists(filename) then
        y_levels_completed = read_table_from_file(filename)
    end
else
    fs.makeDir(".int/chunk")
    print("Initializing cache directory...")
end

-- Check for chests
local adjacent_chests = {}
for j = 1,3 do
    for i =1,4 do
        if mvmt:inspect_whitelist({'minecraft:chest'}) then 
            table.insert(adjacent_chests, mvmt:get_state())
        end
        mvmt:turn_left()
    end
    -- Move up if nothing is above
    if not mvmt:up(1, false) then break end
end

print("Found " .. #adjacent_chests .. " chests.")

function put_inv_in_chest()
    for i=1,16 do
        turtle.select(i)
        mvmt:restore_state(adjacent_chests[1+i % (#adjacent_chests)])
        turtle.drop()
    end
end

local whitelist = {'ore', 'mekanism'}
for y =-59,(y_surface-2),2 do
    if not __is_in_list(y, y_levels_completed) and y > y_min then
        -- Go to the y level
        mvmt:goto(vector.new(x_init,y,z_init))
        local offset = math.floor((y%6) / 2)

        local blocks = {}
        for x=0,15 do
            for z=offset,15,3 do
                table.insert(blocks, vector.new(x,y,z))
            end
        end

        -- Dig the y-level out
        mvmt:mine_out(blocks, true, whitelist)

        -- Return to surface
        mvmt:goto(vector.new(x_init, y, z_init))
        mvmt:goto(vector.new(x_init, y_surface, z_init))

        -- Put inventory in chest
        put_inv_in_chest()

        -- Save
        table.insert(y_levels_completed, y)
        save_table_to_file(y_levels_completed, filename)
        print("Finished " .. y .. ".")
        print("Saved to log.")
    end
end
