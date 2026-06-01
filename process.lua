-- Global variables required by tilemaker to determine which keys to index
node_keys = {
    "landuse",
    "building",
    "bridge",
    "foot",
    "highway",
    "tourism",
    "amenity",
    "shelter_type"
}

way_keys = {
    "landuse",
    "building",
    "bridge",
    "foot",
    "highway",
    "tourism",
    "amenity",
    "shelter_type"
}

function init_function(name, is_first)
end

function exit_function()
end

local function determineStationName()
    local landuse = Find("landuse")
    local building = Find("building")
    local bridge = Find("bridge")
    local foot = Find("foot")
    local highway = Find("highway")
    local tourism = Find("tourism")
    local amenity = Find("amenity")
    local shelter_type = Find("shelter_type")

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

    if tourism == "wilderness_hut"
        or tourism == "alpine_hut"
        or tourism == "cabin"
        or tourism == "hut" then
        return "Tom Bombadil House", 3
    end

    if amenity == "shelter" and shelter_type ~= "public_transport" then
        return "Tom Bombadil House", 3
    end

    return nil, nil
end

function node_function()
    local name, order = determineStationName()
    if name then
        Layer("journey", false)
        Attribute("station_name", name)
        AttributeInteger("order", order)
    end
end

function way_function()
    local name, order = determineStationName()
    if name then
        Layer("journey", IsClosed())
        Attribute("station_name", name)
        AttributeInteger("order", order)
    end
end