-- dig_vein
-- Digs out a vein or connected block

require("mvmt")

local mvmt = mvmt:create(0,0,0,'x+')

term.clear() 
term.setCursorPos(1,1)
print("Hi! I'm ready to dig a vein, Boss.")

-- 1st Prompt: Where is vein?
r = ""
local dirs = {}
while next(dirs) == nil do
    print("Is the vein below (b), forward (f), or above (a)?")
    r = io.read()
    r = r:lower()
    term.clear() 
    term.setCursorPos(1,1)

    if string.find(r, 'f') then dirs['f'] = true end
    if string.find(r, 'b') then dirs['b'] = true end
    if string.find(r, 'a') then dirs['a'] = true end
end

local blocks = {}
if dirs['f'] ~= nil then table.insert(blocks, vector.new(1,0,0)) end
if dirs['b'] ~= nil then table.insert(blocks, vector.new(0,-1,0)) end
if dirs['a'] ~= nil then table.insert(blocks, vector.new(0,1,0)) end

-- 2st Prompt: What are we looking for?
r = ""
local whitelist = {}
while (r ~= 'done') do
    term.clear() 
    term.setCursorPos(1,1)
    print("What am I looking for?")
    print("Type 'done' when finished.")
    r = io.read()
    r = r:gsub("%s+","")
    r = r:lower()
    if r ~= 'done' then 
        table.insert(whitelist, r)
    end
end

mvmt:mine_out(blocks, true, whitelist)
mvmt:goto(vector.new(0,0,0))