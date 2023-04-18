--[[
                              _         _             
                             | |       | |            
     _ __ _____   ___ __ ___ | |_      | |_   _  __ _ 
    | '_ ` _ \ \ / / '_ ` _ \| __|     | | | | |/ _` |
    | | | | | \ V /| | | | | | |_   _  | | |_| | (_| |
    |_| |_| |_|\_/ |_| |_| |_|\__| (_) |_|\__,_|\__,_|
                                                   
    mvmt.lua - ComputerCraft turtle utility library.
    1.0.0
]]

-- module: mvmt
mvmt = {}
mvmt.__index = mvmt




--- Checks if a string is in a list.
-- Some description, can be over several lines.
-- @param a first parameter
-- @param l second parameter
-- @return a string value
local __is_in_list_str = function (a,l)
    for i,v in pairs(l) do
        if string.match(a,v) ~= nil then return true end
    end
    return false
end

--- Checks if a value is in a list.
-- Checks if something is in list
-- @param a value
-- @param l list
-- @return Boolean
local __is_in_list = function (a,l)
    for i,v in pairs(l) do
        if a == v then return true end
    end
    return false
end

table.insert_unique = function(t,l) if not __is_in_list(l,t) then table.insert(t,l) end end

--- mvmt constructor.
-- Initializes the mvmt library.
-- @int x the x coordinate
-- @int y the y coordinate
-- @int z the z coordinate
-- @string d The direction of the turtle.
-- Possible values are 'n'/'z-', 's'/'z+', 'e'/'x+', and 'w'/'x-'.
-- @return mvmt library instance
function mvmt:create(x,y,z,d)
    local m = {}             -- our new object
    setmetatable(m,mvmt)  -- make mvmt handle lookup
    m.pos = vector.new(x,y,z)
    d = d:lower()
    if d == "n" or d == "z-" then
        m.dir = 0
    elseif d == "s" or d == "z+" then
        m.dir = 2
    elseif d == "e" or d == "x+" then
        m.dir = 1
    elseif d == "w" or d == "x-" then
        m.dir = 3
    end
    return m
end


--   _______                 ______                _   _                 
--  |__   __|               |  ____|              | | (_)                
--     | |_   _ _ __ _ __   | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
--     | | | | | '__| '_ \  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--     | | |_| | |  | | | | | |  | |_| | | | | (__| |_| | (_) | | | \__ \
--     |_|\__,_|_|  |_| |_| |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

--- Turn left.
-- Turns the turtle left.
-- @int[opt=1] n Number of times to turn.
function mvmt:turn_left(n)
    if n == nil then n = 1 end
    for i=1,n do
        self.dir = (self.dir - 1) % 4
        turtle.turnLeft()
    end
end

function mvmt:turnLeft(n) self:turn_left(n) end

--- Turn right.
-- Turns the turtle right.
-- @int[opt=1] n Number of times to turn.
function mvmt:turn_right(n)
    if n == nil then n = 1 end
    for i=1,n do
        self.dir = (self.dir + 1) % 4
        turtle.turnRight()
    end
end

function mvmt:turnRight(n) self:turn_right(n) end

--  __      __       _               ______                _   _                 
--  \ \    / /      | |             |  ____|              | | (_)                
--   \ \  / /__  ___| |_ ___  _ __  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
--    \ \/ / _ \/ __| __/ _ \| '__| |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--     \  /  __/ (__| || (_) | |    | |  | |_| | | | | (__| |_| | (_) | | | \__ \
--      \/ \___|\___|\__\___/|_|    |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
                                                                              

-- Block vector functions.
-- Returns vectors of blocks in front, behind, left, right.
function mvmt:__adjacent_block_vector(n)
    local ndir = (self.dir + n) % 4
    return self.pos + self:get_dir_vector(ndir)
end

--- Get vector of block to the left.
-- @return a vector representing the position of the block to the left of the turtle.
function mvmt:vector_left() return self:__adjacent_block_vector(-1) end

--- Get vector of block to the right.
-- @return a vector representing the position of the block to the right of the turtle.
function mvmt:vector_right() return self:__adjacent_block_vector(1) end

--- Get vector of block in front.
-- @return a vector representing the position of the block in front of the turtle.
function mvmt:vector_front() return self:__adjacent_block_vector(0) end

--- Get vector of block behind.
-- @return a vector representing the position of the block behind the turtle.
function mvmt:vector_behind() return self:__adjacent_block_vector(2) end

--- Get vector of block above.
-- @return a vector representing the position of the block above the turtle.
function mvmt:vector_above() return self.pos + vector.new(0,1,0) end

--- Get vector of block below.
-- @return a vector representing the position of the block below the turtle.
function mvmt:vector_below() return self.pos + vector.new(0,-1,0) end

function turn_distance(current, next)
    local distance_right = (next-current)%4
    local distance_left = (3-(next-current-1))%4
    return math.min(distance_left, distance_right)
end

-- Abstract Move Function
function mvmt:move(n,dig,num_tries, func_inspect, func_dig, func_move, v)
    -- Moves 'n' times unsing the 'func_move' function.
    -- If 'dig' is true, the turtle will detect blocks in front using
    -- 'func_inspect', and dig them using 'func_dig'.

    -- Returns 'true' if move operation succeeds, 'false' if failed.

    -- See also: mvmt:up, mvmt:down, and mvmt:forward
    for i = 1,n do
        if dig == true then 
            for j = 1,num_tries do
                if func_inspect() then func_dig() else break end
            end
        end

        local r = false

        for k = 1,num_tries do
            if func_move() then 
                r = true
                break
            end
        end

        if r then
            self.pos = self.pos + v
        else
            return false
        end
    end
    return true
end

--- Move forward.
-- Moves the turtle forward.
-- Optionally digs out the blocks in front.
-- @int[opt=1] n Number of times to move.
-- @bool[opt=true] dig Whether to dig blocks in front.
-- @int[opt=20] num_tries The number of digs the turtle will execute on each block before giving up.
function mvmt:forward(n, dig, num_tries)
    if n == nil then n = 1 end
    if dig == nil then dig = true end
    if num_tries == nil then num_tries = 20 end

    return self:move(n, dig, num_tries, turtle.inspect, turtle.dig, turtle.forward, self:get_dir_vector(self.dir))
end

--- Move up.
-- Moves the turtle upwards.
-- Optionally digs out the blocks above.
-- @int[opt=1] n Number of times to move.
-- @bool[opt=true] dig Whether to dig blocks above.
-- @int[opt=20] num_tries The number of digs the turtle will execute on each block before giving up.
function mvmt:up(n, dig, num_tries)
    if n == nil then n = 1 end
    if dig == nil then dig = true end
    if num_tries == nil then num_tries = 20 end

    return self:move(n, dig, num_tries, turtle.inspectUp, turtle.digUp, turtle.up, vector.new(0,1,0))
end

--- Move down.
-- Moves the turtle downwards.
-- Optionally digs out the blocks below.
-- @int[opt=1] n Number of times to move.
-- @bool[opt=true] dig Whether to dig blocks below.
-- @int[opt=20] num_tries The number of digs the turtle will execute on each block before giving up.
function mvmt:down(n, dig, num_tries)
    if n == nil then n = 1 end
    if dig == nil then dig = true end
    if num_tries == nil then num_tries = 20 end

    return self:move(n, dig, num_tries, turtle.inspectDown, turtle.digDown, turtle.down, vector.new(0,-1,0))
end

--- Move to specified position.
-- Move to specified position, digging blocks in the way.
-- Uses a simple heuristic to try and not break too many blocks.
-- @param p The position to move to.
function mvmt:goto(p)
    local d = p - self.pos
    local dx = d.x
    local dy = d.y
    local dz = d.z
    local directions_to_move = {}
    if dx > 0 then table.insert(directions_to_move,'x+') elseif dx < 0 then table.insert(directions_to_move,'x-') end
    if dy > 0 then table.insert(directions_to_move,'y+') elseif dy < 0 then table.insert(directions_to_move,'y-') end
    if dz > 0 then table.insert(directions_to_move,'z+') elseif dz < 0 then table.insert(directions_to_move,'z-') end
    
    local h = "Directions "
    for i,v in pairs(directions_to_move) do h = h .. v .. ", " end


    -- First Pass
    -- This will move in the directions that are CLEAR
    for i,v in pairs(directions_to_move) do
        if v ~= nil then 
            local v2 = string.sub(v,1,1)

            if v2 == 'x' then
                if not self:inspect(v) then
                    self:face(v)
                    self:forward(math.abs(dx))
                    directions_to_move[i] = nil
                end
            elseif v2 == 'z' then
                if not self:inspect(v) then
                    self:face(v)
                    self:forward(math.abs(dz))
                    directions_to_move[i] = nil
                end
            elseif v2 == 'y' then
                if not self:inspect(v) then
                    if dy > 0 then self:up(math.abs(dy)) else self:down(math.abs(dy)) end
                    directions_to_move[i] = nil
                end
            end
        end
    end
    h = "Directions "
    for i,v in pairs(directions_to_move) do h = h .. v .. ", " end

    -- 2nd Pass
    -- This will move in the directions that weren't clear initially
    for i,v in pairs(directions_to_move) do
        if v ~= nil then

            local v2 = string.sub(v,1,1)
            if v2 == 'x' then
                self:face(v)
                self:forward(math.abs(dx))
                directions_to_move[i] = nil
            elseif v2 == 'z' then
                self:face(v)
                self:forward(math.abs(dz))
                directions_to_move[i] = nil
            elseif v2 == 'y' then
                if dy > 0 then self:up(math.abs(dy)) else self:down(math.abs(dy)) end
                directions_to_move[i] = nil
            end
        end
    end
end

function mvmt:face(d)
    if d == "E" or d == "e" or d == "x+" then d = 1 end
    if d == "W" or d == "w" or d == "x-" then d = 3 end
    if d == "N" or d == "n" or d == "z-" then d = 0 end
    if d == "S" or d == "s" or d == "z+" then d = 2 end

    if ((self.dir + 1) % 4) == d then
        self:turn_right()
    elseif ((self.dir - 1) % 4) == d then
        self:turn_left()
    elseif (self.dir == d) then
        return nil
    else
        self:turn_left(2)
    end
end

function mvmt:inspect(d)
    d = d:lower()
    if d == 'u' or d == 'y+' then return turtle.inspectUp() end
    if d == 'd' or d == 'y-' then return turtle.inspectDown() end
    self:face(d)
    return turtle.inspect()
end

function mvmt:get_dir_vector(d)
    if d == nil then d = self.dir end
    if d == 0 or d == "N" or d == "n" then
        return vector.new(0,0,-1)
    elseif d == 2 or d == "S" or d == "s" then
        return vector.new(0,0,1)
    elseif d == 1 or d == "E" or d == "e" then
        return vector.new(1,0,0)
    elseif d == 3 or d == "W" or d == "w" then
        return vector.new(-1,0,0)
    end
end

-- TODO: Make better distance weighting function.
--       Account for roations.
function mvmt:taxi_distance(v,p)
    if p == nil then p = self.pos end
    d = v - p
    return math.abs(d.x) + math.abs(d.y) + math.abs(d.z)
end




-- minecraft:obsidian
function mvmt:mine_out(blocks, inspect, whitelist)
    if inspect == nil then inspect = false end
    if whitelist == nil then whitelist = {} end
    local blocks_inspected = {self.pos}
    while #blocks > 0 do
        local target = self:pop_closest(blocks, self:get_state())
        -- local li = 1
        -- local lv = self:taxi_distance(blocks[1])
        -- for i,v in ipairs(blocks) do
        --     v2 = self:taxi_distance(v)
        --     if v2 < lv then
        --         lv = v2
        --         li = i
        --     end
        -- end
        -- local target = blocks[li]

        -- TODO: Remove all the blocks along the way to that block
        self:goto(target)
        -- Add the current block to the 'inspected' table
        table.insert_unique(blocks_inspected, target)
        --table.remove(blocks,li)

        -- If inspect, check all directions.
        if inspect then

            local ajacent_blocks_to_inspect = {}
            for i=1,4 do
                local adj_vec = self:__adjacent_block_vector(i)
                if not __is_in_list(adj_vec, blocks_inspected) then
                    -- Insert tuple: (vector, absolute direction)
                    table.insert(ajacent_blocks_to_inspect, table.pack(adj_vec,(self.dir+i)%4))
                end
            end

            f = function(x)
                local _,d = table.unpack(x)
                return turn_distance(self.dir,d)
            end

            while #ajacent_blocks_to_inspect > 0 do
                -- Find the closest 
                local li = 1
                local lv = f(ajacent_blocks_to_inspect[1])
                for i,v in ipairs(ajacent_blocks_to_inspect) do
                    local v2 = f(v)
                    if v2 < lv then
                        lv = v2
                        li = i
                    end
                end

                local adj_vec,closest_direction = table.unpack(ajacent_blocks_to_inspect[li])
                self:face(closest_direction)
                local a,b = turtle.inspect()
                table.insert(blocks_inspected, adj_vec)
                if a then
                    local t = self.pos + self:get_dir_vector()
                    if __is_in_list_str(b.name, whitelist) and not __is_in_list(t, blocks) then
                        table.insert(blocks,t)
                    end
                end
                table.remove(ajacent_blocks_to_inspect,li)
            end




            a,b = turtle.inspectUp()
            table.insert_unique(blocks_inspected, self.pos + vector.new(0,1,0))
            if a then
                local t = self.pos + vector.new(0,1,0)
                if __is_in_list_str(b.name, whitelist) and not __is_in_list(t, blocks) then
                    table.insert(blocks, t)
                end
            end
            a,b = turtle.inspectDown()
            table.insert_unique(blocks_inspected, self.pos + vector.new(0,-1,0))
            if a then
                local t = self.pos + vector.new(0,-1,0)
                if __is_in_list_str(b.name, whitelist) and not __is_in_list(t, blocks) then
                    table.insert(blocks, t)
                end
            end
        end
    end
end

--- Finds closest block in table and removes it from table.
-- This function pops the closest block in a group of blocks by calculating the taxicab distance between each block and the current position.
-- It then returns the closest block and removes that block from the table.
-- @param blocks A table of blocks.
-- @param state The current state.
-- @return The closest block.
function mvmt:pop_closest(blocks, state)
    pos = state.pos
    li = 1
    lv = self:taxi_distance(blocks[1],pos)
    for i,v in ipairs(blocks) do
        local v2 = self:taxi_distance(v,pos)
        if v2 < lv then
            lv = v2
            li = i
        end
    end
    local target = blocks[li]
    table.remove(blocks,li)
    return target
end

function mvmt:build_with_callback(blocks, callback)
    sort_func = function(a,b) if a.y == b.y then 
        da = math.abs(self.pos.x - a.x) + math.abs(self.pos.z - a.z)
        db = math.abs(self.pos.x - b.x) + math.abs(self.pos.z - b.z)
        return da < db
    else
        return a.y < b.y
    end end

    -- Sort all blocks into groups by y level
    y_levels = {}
    y_groups = {}
    for i,v in ipairs(blocks) do
        if not __is_in_list(v.y,y_levels) then
            table.insert(y_levels,v.y)
            y_groups[v.y] = {}
        end
        table.insert(y_groups[v.y],v)
    end
    table.sort(y_levels)
    print("Y levels:")
    for i,v in ipairs(y_levels) do print(v); print(#y_groups[v]) end

    for _,y in ipairs(y_levels) do
        print("Executing y group")
        print(y)
        local group = y_groups[y]
        while #group > 0 do
            -- Find closest block in group
            -- local li = 1
            -- local lv = self:taxi_distance(group[1])
            -- for i,v in ipairs(group) do
            --     v2 = self:taxi_distance(v)
            --     if v2 < lv then
            --         lv = v2
            --         li = i
            --     end
            -- end
            local target = self:pop_closest(group, self:get_state())
            self:goto(target + vector.new(0,1,0))
            --table.remove(group,li)
            callback()
        end
    end
    -- -- Sort by y-level.
    -- table.sort(blocks, sort_func)
    
    -- for i,v in ipairs(blocks) do
    --     -- Go to the block ABOVE the target.
    --     self:goto(v + vector.new(0,1,0))

    --     -- Do callback.
    --     callback()
    --     table.sort(blocks, sort_func)
    -- end
end

--- Get the state of the object.
-- @return A table containing the position and direction of the object.
function mvmt:get_state() 
    return {pos = self.pos, dir = self.dir}
end

--- Restore the state of the object.
-- @param state A table containing the position and direction of the object.
function mvmt:restore_state(state)
    self:goto(state.pos)
    self:face(state.dir)
end



function mvmt:__inspect_whitelist(inspect_function, whitelist)
    local has_block, data = inspect_function()
    if has_block then
        return __is_in_list_str(data.name, whitelist)
    end
    return false
end

--- Check if an object below the turtle is in a whitelist.
-- @param whitelist A table containing the names of objects that are allowed.
-- @return True if the object is in the whitelist, false otherwise.
function mvmt:inspect_down_whitelist(whitelist)
    return self:__inspect_whitelist(turtle.inspectDown, whitelist)
end

--- Check if an object above the turtle is in a whitelist.
-- @param whitelist A table containing the names of objects that are allowed.
-- @return True if the object is in the whitelist, false otherwise.
function mvmt:inspect_up_whitelist(whitelist)
    return self:__inspect_whitelist(turtle.inspectUp, whitelist)
end

--- Check if an object in front of the turtle is in a whitelist.
-- @param whitelist A table containing the names of objects that are allowed.
-- @return True if the object is in the whitelist, false otherwise.
function mvmt:inspect_whitelist(whitelist)
    return self:__inspect_whitelist(turtle.inspect, whitelist)
end


return mvmt