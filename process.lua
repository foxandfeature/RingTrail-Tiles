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

function init_function()
end

function exit_function()
end

local function determineStationName(obj)
    local landuse = obj:Find("landuse") or ""
    local building = obj:Find("building") or ""
    local bridge = obj:Find("bridge") or ""
    local foot = obj:Find("foot") or ""
    local highway = obj:Find("highway") or ""
    local tourism = obj:Find("tourism") or ""
    local amenity = obj:Find("amenity") or ""
    local shelter_type = obj:Find("shelter_type") or ""

    if landuse == "farmyard" then
        return "Maggot Hof", "1"
    end

    if building == "farm"
        or building == "barn"
        or building == "stable"
        or building == "sty"
        or building == "cowshed" then
        return "Maggot Hof", "1"
    end

    if bridge ~= "" and bridge ~= "no" then
        if foot == "yes"
            or foot == "designated"
            or foot == "use_sidepath" then
            return "Brandywine Ferry", "2"
        end

        if highway == "foot"
            or highway == "track"
            or highway == "path"
            or highway == "pedestrian" then
            return "Brandywine Ferry", "2"
        end
    end

    if tourism == "wilderness_hut"
        or tourism == "alpine_hut"
        or tourism == "cabin"
        or tourism == "hut" then
        return "Tom Bombadil House", "3"
    end

    if amenity == "shelter"
        and shelter_type ~= "public_transport" then
        return "Tom Bombadil House", "3"
    end

    return nil, nil
end

function node_function(node)
    local name, order = determineStationName(node)

    if name ~= nil then
        node:Layer("journey", false)
        node:Attribute("station_name", name)
        node:Attribute("order", order)
    end
end

function way_function(way)
    local name, order = determineStationName(way)

    if name ~= nil then
        way:Layer("journey", false)
        way:Attribute("station_name", name)
        way:Attribute("order", order)
    end
end

function relation_function(relation)
end