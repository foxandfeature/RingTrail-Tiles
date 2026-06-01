-- Initializes the Lua generation environment.
function init_function()
end

-- Clean up function executed after tile processing completes.
function exit_function()
end

-- Evaluates OSM tags to determine the station name
-- and its chronological itinerary order.
local function determineStationName(obj)
    local landuse = obj:Find("landuse") or ""
    local building = obj:Find("building") or ""
    local bridge = obj:Find("bridge") or ""
    local foot = obj:Find("foot") or ""
    local highway = obj:Find("highway") or ""
    local tourism = obj:Find("tourism") or ""
    local amenity = obj:Find("amenity") or ""
    local shelter_type = obj:Find("shelter_type") or ""

    -- 1. Maggot Hof (First stop of the journey)
    if landuse == "farmyard" then
        return "Maggot Hof", 1
    end

    if building == "farm"
        or building == "barn"
        or building == "stable"
        or building == "sty"
        or building == "cowshed" then
        return "Maggot Hof", 1
    end

    -- 2. Brandywine Ferry (Second stop of the journey)
    if bridge ~= "" and bridge ~= "no" then
        if foot == "yes"
            or foot == "designated"
            or foot == "use_sidepath" then
            return "Brandywine Ferry", 2
        end

        if highway == "foot"
            or highway == "track"
            or highway == "path"
            or highway == "pedestrian" then
            return "Brandywine Ferry", 2
        end
    end

    -- 3. Tom Bombadil House (Third stop of the journey)
    if tourism == "wilderness_hut"
        or tourism == "alpine_hut"
        or tourism == "cabin"
        or tourism == "hut" then
        return "Tom Bombadil House", 3
    end

    if amenity == "shelter" and shelter_type ~= "public_transport" then
        return "Tom Bombadil House", 3
    end

    return "Unknown", -1
end

-- Processing logic applied to every OSM node.
function node_function(node)
    local name, order = determineStationName(node)

    if name ~= "Unknown" then
        node:Layer("journey", false)
        node:Attribute("station_name", name)
        node:AttributeNumeric("order", order)
    end
end

-- Processing logic applied to every OSM way.
function way_function(way)
    local name, order = determineStationName(way)

    if name ~= "Unknown" then
        way:Layer("journey", way:IsClosed())
        way:Attribute("station_name", name)
        way:AttributeNumeric("order", order)
    end
end