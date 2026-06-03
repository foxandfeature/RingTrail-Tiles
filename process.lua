-- Key definitions for Tilemaker indexing
node_keys = { "building", "bridge", "foot", "highway", "tourism", "amenity", "shelter_type" }
way_keys =  { "building", "bridge", "foot", "highway", "tourism", "amenity", "shelter_type" }

-- Match tables for fast lookups (optimizes performance by replacing long 'or' chains)
local farm_buildings = { farm = true, barn = true, stable = true, sty = true, cowshed = true }
local ferry_feet = { yes = true, designated = true, use_sidepath = true }
local ferry_highways = { foot = true, track = true, path = true, pedestrian = true }
local huts = { wilderness_hut = true, alpine_hut = true, cabin = true, hut = true }

function init_function() end
function exit_function() end

-- Central logic to determine station order based on OSM tags
local function determineStationOrder()
    -- Maggot Hof
    local building = Find("building")
    if farm_buildings[building] then return "1" end

    -- Brandywine Ferry
    local bridge = Find("bridge")
    if bridge and bridge ~= "" and bridge ~= "no" then
        if ferry_feet[Find("foot")] or ferry_highways[Find("highway")] then
            return "2"
        end
    end

    -- Tom Bombadil House
    if huts[Find("tourism")] then return "3" end

    if Find("amenity") == "shelter" and Find("shelter_type") ~= "public_transport" then
        return "3"
    end

    return nil
end

-- Process node elements (points) - No arguments in new API
function node_function()
    local order = determineStationOrder()
    if order then
        Layer("journey", false)
        Attribute("order", order)
    end
end

-- Process way elements (lines/polygons) - No arguments in new API
function way_function()
    local order = determineStationOrder()
    if order then
        -- Converts the way geometry into a single point at its center (centroid)
        LayerAsCentroid("journey")
        Attribute("order", order)
    end
end

function relation_function() end