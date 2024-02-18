DIM = 10;
TILE_SIZE = 50;

BLANK = 1
UP = 2
RIGHT = 3
DOWN = 4
LEFT = 5

local tiles
local grid = {}
local utils = {}

function utils:copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[self:copy(k, s)] = self:copy(v, s) end
    return res
end

function utils:filter(t, filterIter)
    local out = {}

    for k, v in pairs(t) do
        if filterIter(v, k, t) then table.insert(out,v) end
    end

    return out
end

local getSmallestEntropy = function(grid)
    local smallestEntropy = #tiles
    for _, cell in pairs(grid) do
        if #cell.options <= smallestEntropy and cell.collapsed == false then
            return #cell.options
        end
    end
end

function love.load()
    if arg[2] == "debug" then require("lldebugger").start() end
    math.randomseed(os.time())

    tiles = {
        love.graphics.newImage("/sprites/demo/blank.png"),
        love.graphics.newImage("/sprites/demo/down.png"),
        love.graphics.newImage("/sprites/demo/left.png"),
        love.graphics.newImage("/sprites/demo/right.png"),
        love.graphics.newImage("/sprites/demo/up.png"),
    }

    for i = 1, DIM * DIM do
        table.insert(grid, {
            index = i,
            collapsed = false,
            options = { BLANK, UP, RIGHT, DOWN, LEFT }
        })
    end
    
    for _ = 1, DIM * DIM do
        -- Sort the grid by least entropy
        local gridCopy = utils:copy(grid)
    
        table.sort(gridCopy, function(a, b) return #a.options < #b.options end)
    
        -- pick one of the cells with the least entropy and collapse it
        local entropy = getSmallestEntropy(gridCopy)
        local cellsSmallestEntropy = utils:filter(gridCopy,
            function(v, k, t) return #v.options == entropy and v.collapsed == false end)
        local chosenCell = cellsSmallestEntropy[math.random(#cellsSmallestEntropy)]
    
        -- collapse the chosen cell
        if chosenCell then
            chosenCell.collapsed = true
            chosenCell.options = { chosenCell.options[math.random(#chosenCell.options)] }
    
            grid[chosenCell.index] = chosenCell
        end

        local nextTiles = {}
        for i = 1, DIM do
            for j = 1, DIM do
                local index = j + i * DIM
            end
        end
    end
end

function love.update(dt)
end

function love.draw()
    for i = 0, DIM - 1 do
        for j = 0, DIM - 1 do
            local cell = grid[(j + i * DIM) + 1]
            if cell.collapsed then
                love.graphics.draw(tiles[cell.options[1]], i * TILE_SIZE, j * TILE_SIZE)
            else
                love.graphics.print(i .. " " .. j .. " - " .. ((j + i * DIM) + 1), i * TILE_SIZE, j * TILE_SIZE)
                love.graphics.rectangle("line", i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            end
        end
    end
end
