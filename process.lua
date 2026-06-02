-- Key definitions for Tilemaker indexing
node_keys = { "landuse", "building", "bridge", "foot", "highway", "tourism", "amenity", "shelter_type" }
way_keys =  { "landuse", "building", "bridge", "foot", "highway", "tourism", "amenity", "shelter_type" }

-- Match tables for fast lookups (optimizes performance by replacing long 'or' chains)
local farm_buildings = { farm = true, barn = true, stable = true, sty = true, cowshed = true }
local ferry_feet = { yes = true, designated = true, use_sidepath = true }
local ferry_highways = { foot = true, track = true, path = true, pedestrian = true }
local huts = { wilderness_hut = true, alpine_hut = true, cabin = true, hut = true }

function init_function() end
function exit_function() end

-- Central logic to determine station order based on OSM tags
local function determineStationOrder(obj)
    -- Maggot Hof
    local landuse = obj:Find("landuse")
    if landuse == "farmyard" then return "1" end

    local building = obj:Find("building")
    if farm_buildings[building] then return "1" end

    -- Brandywine Ferry
    local bridge = obj:Find("bridge")
    if bridge and bridge ~= "" and bridge ~= "no" then
        if ferry_feet[obj:Find("foot")] or ferry_highways[obj:Find("highway")] then
            return "2"
        end
    end

    -- Tom Bombadil House"
    if huts[obj:Find("tourism")] then return "3" end

    if obj:Find("amenity") == "shelter" and obj:Find("shelter_type") ~= "public_transport" then
        return "3"
    end

    return nil
end

-- Process node elements (points)
function node_function(node)
    local order = determineStationOrder(node)
    if order then
        node:Layer("journey", false)
        node:Attribute("order", order)
    end
end

-- Process way elements (lines/polygons)
function way_function(way)
    local order = determineStationOrder(way)
    if order then
        -- Tilemaker built-in: Converts the way geometry into a single point at its center (centroid)
        way:Centroid()
        
        way:Layer("journey", false)
        way:Attribute("order", order)
    end
end

function relation_function(relation) end