-- Key definitions for Tilemaker indexing
node_keys = { 
    "building", "bridge", "foot", "highway", "tourism", "amenity", "shelter_type",
    "archaeological_site", "historic", "cemetery", "man_made", "tomb", "landuse", "memorial",
    "ruins", "tower:type" 
}
way_keys =  { 
    "building", "bridge", "foot", "highway", "tourism", "amenity", "shelter_type",
    "archaeological_site", "historic", "cemetery", "man_made", "tomb", "landuse", "memorial",
    "ruins", "tower:type" 
}

local farm_buildings = { farm = true, barn = true, stable = true, sty = true, cowshed = true }

local ferry_feet = { yes = true, designated = true, use_sidepath = true }
local ferry_highways = { foot = true, track = true, path = true, pedestrian = true }

local huts = { wilderness_hut = true, alpine_hut = true, cabin = true, hut = true }

local arch_sites = { tumulus = true, megalith = true, necropolis = true, tomb = true, earthwork = true, grave_field = true }
local historic_tombs = { tomb = true, cemetery = true }
local man_made_tombs = { grave = true, tomb = true }
local memorials = { war_memorial = true, cross = true, cenotaph = true }

function init_function() end
function exit_function() end

-- Central logic to determine station order based on OSM tags
local function determineStationOrder()
    -- 1. Maggot Hof
    local building = Find("building")
    if farm_buildings[building] then return "1" end

    -- 2. Brandywine Ferry
    -- Maybe add real ferryies later
    local bridge = Find("bridge")
    if bridge and bridge ~= "" and bridge ~= "no" then
        if ferry_feet[Find("foot")] or ferry_highways[Find("highway")] then
            return "2"
        end
    end

    -- 3. Tom Bombadil House
    if huts[Find("tourism")] then return "3" end

    if Find("amenity") == "shelter" and Find("shelter_type") ~= "public_transport" then
        return "3"
    end

    -- 4. Barrow-downs
    if arch_sites[Find("archaeological_site")] then return "4" end
    if historic_tombs[Find("historic")] then return "4" end
    if man_made_tombs[Find("man_made")] then return "4" end
    if memorials[Find("memorial")] then return "4" end
    
    if Find("landuse") == "cemetery" or Find("amenity") == "grave_yard" then return "4" end
    
    local cemetery = Find("cemetery")
    if cemetery ~= "" then return "4" end
    
    local tomb = Find("tomb")
    if tomb ~= "" then return "4" end

    -- 5. Amon Sûl
    local ruins = Find("ruins")
    if ruins == "castle" or ruins == "tower" then return "5" end
    if Find("historic") == "castle" then return "5" end
    if Find("tourism") == "viewpoint" then return "5" end
    if Find("tower:type") == "observation" then return "5" end

    return nil
end

-- Process node elements (points)
function node_function()
    local order = determineStationOrder()
    if order then
        Layer("journey", false)
        Attribute("order", order)
    end
end

-- Process way elements (lines/polygons)
function way_function()
    local order = determineStationOrder()
    if order then
        -- Converts the way geometry into a single point at its center (centroid)
        LayerAsCentroid("journey")
        Attribute("order", order)
    end
end

function relation_function() end