function Bresenham3D(x1, y1, z1, x2, y2, z2)
    local ListOfPoints = {}
    table.insert(ListOfPoints, { x1, y1, z1 })
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local dz = math.abs(z2 - z1)
    local xs, ys, zs

    if x2 > x1 then
        xs = 1
    else
        xs = -1
    end

    if y2 > y1 then
        ys = 1
    else
        ys = -1
    end

    if z2 > z1 then
        zs = 1
    else
        zs = -1
    end

    -- Driving axis is X-axis
    if dx >= dy and dx >= dz then
        local p1 = 2 * dy - dx
        local p2 = 2 * dz - dx
        while x1 ~= x2 do
            x1 = x1 + xs
            if p1 >= 0 then
                y1 = y1 + ys
                p1 = p1 - 2 * dx
            end
            if p2 >= 0 then
                z1 = z1 + zs
                p2 = p2 - 2 * dx
            end
            p1 = p1 + 2 * dy
            p2 = p2 + 2 * dz
            table.insert(ListOfPoints, { x1, y1, z1 })
        end

        -- Driving axis is Y-axis
    elseif dy >= dx and dy >= dz then
        local p1 = 2 * dx - dy
        local p2 = 2 * dz - dy
        while y1 ~= y2 do
            y1 = y1 + ys
            if p1 >= 0 then
                x1 = x1 + xs
                p1 = p1 - 2 * dy
            end
            if p2 >= 0 then
                z1 = z1 + zs
                p2 = p2 - 2 * dy
            end
            p1 = p1 + 2 * dx
            p2 = p2 + 2 * dz
            table.insert(ListOfPoints, { x1, y1, z1 })
        end

        -- Driving axis is Z-axis
    else
        local p1 = 2 * dy - dz
        local p2 = 2 * dx - dz
        while z1 ~= z2 do
            z1 = z1 + zs
            if p1 >= 0 then
                y1 = y1 + ys
                p1 = p1 - 2 * dz
            end
            if p2 >= 0 then
                x1 = x1 + xs
                p2 = p2 - 2 * dz
            end
            p1 = p1 + 2 * dy
            p2 = p2 + 2 * dx
            table.insert(ListOfPoints, { x1, y1, z1 })
        end
    end

    return ListOfPoints
end

function main()
    local x1, y1, z1 = gps.locate()
    print("give x")
    local x2 = tonumber(read())
    print("give y")
    local y2 = tonumber(read())
    print("give z")
    local z2 = tonumber(read())
    local ListOfPoints = Bresenham3D(x1, y1, z1, x2, y2, z2)
    -- calibrate turtle
    for i, v in ipairs(ListOfPoints) do
        -- move to next point
        print(v[1], v[2], v[3])
    end
end

main()
