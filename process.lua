-- Global variables required by tilemaker to determine which keys to index
node_keys = { "landuse", "building", "bridge", "foot", "highway", "tourism", "amenity", "shelter_type" }

/**
 * Initializes the Lua generation environment. Required lifecycle hook.
 */
function init_function()
end

/**
 * Clean up function executed after tile processing completes. Required lifecycle hook.
 */
function exit_function()
end

/**
 * Evaluates OSM tags to determine the station name and its chronological itinerary order.
 * @param obj The OpenStreetMap object (node or way) containing the tags.
 * @return string, number The determined station name and its sequential travel order.
 */
local function determineStationName(obj)
    local landuse = obj:Find("landuse")
    local building = obj:Find("building")
    local bridge = obj:Find("bridge")
    local foot = obj:Find("foot")
    local highway = obj:Find("highway")
    local tourism = obj:Find("tourism")
    local amenity = obj:Find("amenity")
    local shelter_type = obj:Find("shelter_type")

    -- 1. Maggot Hof (First stop of the journey)
    if landuse == "farmyard" then
        return "Maggot Hof", 1
    end
    if building == "farm" or building == "barn" or building == "stable" or building == "sty" or building == "cowshed" then
        return "Maggot Hof", 1
    end

    -- 2. Brandywine Ferry (Second stop of the journey)
    if bridge ~= "" and bridge ~= "no" then
        if foot == "yes" or foot == "designated" or foot == "use_sidepath" then
            return "Brandywine Ferry", 2
        end
        if highway == "foot" or highway == "track" or highway == "path" or highway == "pedestrian" then
            return "Brandywine Ferry", 2
        end
    end

    -- 3. Tom Bombadil House (Third stop of the journey)
    if tourism == "wilderness_hut" or tourism == "alpine_hut" or tourism == "cabin" or tourism == "hut" then
        return "Tom Bombadil House", 3
    end
    if amenity == "shelter" and shelter_type ~= "public_transport" then
        return "Tom Bombadil House", 3
    end

    return "Unknown", -1
end

/**
 * Processing logic applied to every OSM node.
 * Stores the station name and the chronological journey order inside the tile features.
 * @param node The current OSM node being evaluated.
 */
function node_function(node)
    local name, order = determineStationName(node)
    if name ~= "Unknown" then
        node:Layer("journey", false)
        node:Attribute("station_name", name)
        node:Attribute("order", order)
    end
end

/**
 * Processing logic applied to every OSM way (Lines and Polygons).
 * Stores the station name and the chronological journey order inside the tile features.
 * @param way The current OSM way being evaluated.
 */
function way_function(way)
    local name, order = determineStationName(way)
    if name ~= "Unknown" then
        -- Second parameter marks if the geometry is closed (Polygon area) or open (Line)
        way:Layer("journey", way:IsClosed())
        way:Attribute("station_name", name)
        way:Attribute("order", order)
    end
end