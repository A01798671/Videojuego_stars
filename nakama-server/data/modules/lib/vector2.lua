local Vector2 = {}


Vector2.__index = Vector2
Vector2.__newindex = function ()
    error("Tried to add a new field to Vector2.",2)
end
Vector2.__tostring = function (self)
    return "Vector2(" .. self.x .. ", " .. self.y .. ")"
end
Vector2.__add = function (a,b)
    return Vector2:new(a.x + b.x, a.y + b.y)
end
Vector2.__sub = function (a,b)
    return Vector2:new(a.x - b.x, a.y - b.y)
end
Vector2.__mul = function (a,b)
    return Vector2:new(a.x * b.x, a.y * b.y)
end
Vector2.__div = function (a,b)
    return Vector2:new(a.x / b.x, a.y / b.y)
end

function Vector2:new(x,y)
    x = x or 0
    y = y or 0
    local new_vector = {x = x, y = y}
    return setmetatable(new_vector, self)
end

function Vector2:get_distance_to(vec2)
    if (getmetatable(vec2) == Vector2)
    then
        local x_dist = math.abs(self.x - vec2.x)
        local y_dist = math.abs(self.y - vec2.y)
        local distance = math.sqrt(x_dist^2 + y_dist^2)
        return distance
    end
end



return Vector2