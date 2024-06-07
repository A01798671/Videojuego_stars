local Vector2 = require("lib.vector2")

--This module must use Gopher Lua, Lua 5.3 or later as randomness in standard Lua
--before 5.3 is bad, if it must be used with earlier versions call math.random 
-- a couple of times before storing any random value for the first time.
math.randomseed(os.time())

local PoissonDiskSampling = {}
PoissonDiskSampling.__index = PoissonDiskSampling


function PoissonDiskSampling:new(width, height, radius, candidates)
    candidates = candidates or 30
    local cell_size = radius / math.sqrt(2)
    local ncells_width = math.ceil(width / cell_size)
    local ncells_height = math.ceil(height / cell_size)
    local new_poisson_disk_sampling = {
    width = width,
    height = height,
    radius = radius,
    candidates = candidates,
    cell_size = cell_size,
    ncells_width = ncells_width,
    ncells_height = ncells_height,
    }
    return setmetatable(new_poisson_disk_sampling, self)
end

-- Private Functions
local function _insert_point_to_grid(poisson_disk_sampling,grid,point)
    if (getmetatable(point) == Vector2)
    then
        local x_idx = math.floor(point.x / poisson_disk_sampling.cell_size)
        local y_idx = math.floor(point.y / poisson_disk_sampling.cell_size)
        grid[tostring(Vector2:new(x_idx,y_idx))] = point
    end
end

local function _is_valid_point(poisson_disk_sampling, candidate_point)
    if(0 <= candidate_point.x and candidate_point.x <= poisson_disk_sampling.width and 0 <= candidate_point.y and candidate_point.y <= poisson_disk_sampling.height)
    then
        local cell_x = math.floor(candidate_point.x / poisson_disk_sampling.cell_size)
        local cell_y = math.floor(candidate_point.y / poisson_disk_sampling.cell_size)
        local search_start_x = math.max(0, cell_x - 2)
        local search_end_x = math.min(cell_x + 2, poisson_disk_sampling.ncells_width - 1)
        local search_start_y = math.max(0, cell_y - 2)
        local search_end_y = math.min(cell_y + 2, poisson_disk_sampling.ncells_height - 1)
        for x = search_start_x, search_end_x do
            for y = search_start_y, search_end_y do
                local point = poisson_disk_sampling.grid[tostring(Vector2:new(x,y))]
                if (point ~= nil) then  
                    local distance = candidate_point:get_distance_to(point)
                    if (distance < poisson_disk_sampling.radius) then
                        return false
                    end
                end
            end
        end
        return true
    end
    return false
end
--Public Functions
function PoissonDiskSampling:generate_poisson_points()
    local points = {}
    local grid = {}
    local active_points = {}
    local initial_point = Vector2:new(math.random() * self.width,math.random() * self.height) --not ideal as it is not inclusive, but it shouldn't matter too much.
    table.insert(active_points,initial_point)
    table.insert(points,initial_point)
    _insert_point_to_grid(self,grid, initial_point)
    while #active_points > 0 do
        local random_active_point_idx = math.random(#active_points)
        local random_active_point = active_points[random_active_point_idx]
        local candidate_accepted = false
        local attempts = 0
        while attempts < self.candidates do
            attempts = attempts + 1
            local angle = math.random() * (math.pi * 2)
            local new_radius = self.radius * (1 + math.random())
            local candidate_x = random_active_point.x + new_radius * math.cos(angle)
            local candidate_y = random_active_point.y + new_radius * math.sin(angle)
            local candidate = Vector2:new(candidate_x,candidate_y)
            if (_is_valid_point(self,candidate))
            then
                table.insert(points,candidate)
                table.insert(active_points,candidate)
                _insert_point_to_grid(self,grid,candidate)
                candidate_accepted = true
                break
            end
        end
        if (candidate_accepted == false)
        then
            table.remove(active_points,random_active_point_idx)
        end
    end
    return true
end







return PoissonDiskSampling