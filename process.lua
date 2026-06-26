-- Shared indexing keys for Tilemaker
local common_keys = { 
    "building", "bridge", "foot", "highway", "tourism", "amenity", "shelter_type",
    "archaeological_site", "historic", "cemetery", "man_made", "tomb", "landuse", 
    "memorial", "ruins", "tower:type", "ford", "natural", "tunnel", "waterway",
    "leisure", "water", "barrier"
}
node_keys = common_keys
way_keys = common_keys

-- Lookup Sets (O(1) optimization)
local farm_buildings    = { farm = true, barn = true, stable = true, sty = true, cowshed = true }
local huts              = { wilderness_hut = true, cabin = true, hut = true }
local arch_sites        = { tumulus = true, megalith = true, necropolis = true, tomb = true, earthwork = true, grave_field = true }
local historic_tombs    = { tomb = true, cemetery = true }
local man_made_tombs    = { grave = true, tomb = true }
local memorials         = { war_memorial = true, cross = true, cenotaph = true }
local bree_amenities    = { pub = true, bar = true, biergarten = true, restaurant = true }
local bree_tourism      = { hotel = true, hostel = true, motel = true, alpine_hut = true }

-- General pedestrian lookups (used for Ferry, Moria, etc.)
local pedestrian_status   = { yes = true, designated = true, use_sidepath = true }
local pedestrian_highways = { foot = true, track = true, path = true, pedestrian = true, residential = true }

-- Station 8: Mines of Moria lookups
local moria_man_made = { mineshaft = true, adit = true, cellar_entrance = true }
local moria_historic = { mine_shaft = true }
local moria_natural  = { cave_entrance = true }
local moria_tunnels  = { yes = true }

function init_function() end
function exit_function() end

-- Central logic to determine station order based on OSM tags
local function determineStationOrder()
    local building     = Find("building")
    local bridge       = Find("bridge")
    local tourism      = Find("tourism")
    local amenity      = Find("amenity")
    local arch_site    = Find("archaeological_site")
    local historic     = Find("historic")
    local man_made     = Find("man_made")
    local memorial     = Find("memorial")
    local landuse      = Find("landuse")
    local cemetery     = Find("cemetery")
    local tomb         = Find("tomb")
    local ruins        = Find("ruins")
    local ford         = Find("ford")
    local natural      = Find("natural")
    local tunnel       = Find("tunnel")
    local shelter_type = Find("shelter_type")
    local highway      = Find("highway")
    local foot         = Find("foot")
    local waterway     = Find("waterway")
    local water        = Find("water")
    local barrier      = Find("barrier")

    -- 1. Maggot Hof
    if farm_buildings[building] then return "1" end

    -- 2. Brandywine Ferry (Placeholder for real ferries later)
    if bridge ~= "" and bridge ~= "no" then
        if pedestrian_status[foot] or pedestrian_highways[highway] then
            return "2"
        end
    end

    -- 3. Tom Bombadil House
    if huts[tourism] or (amenity == "shelter" and shelter_type ~= "public_transport" and shelter_type ~= "rock_shelter") then 
        return "3" 
    end

    -- 4. Barrow-downs
    if arch_sites[arch_site] or 
       historic_tombs[historic] or 
       man_made_tombs[man_made] or 
       memorials[memorial] or 
       landuse == "cemetery" or 
       amenity == "grave_yard" or 
       cemetery ~= "" or 
       tomb ~= "" then
        return "4"
    end

    -- 5. Bree (The Prancing Pony Inn)
    if bree_amenities[amenity] or bree_tourism[tourism] then 
        return "5" 
    end

    -- 6. Amon Sûl
    if arch_site == "fortification" or 
       ruins == "castle" or 
       ruins == "tower" or 
       (historic == "castle" and ruins == "yes") or 
       tourism == "viewpoint" or 
       Find("tower:type") == "observation" then 
        return "6" 
    end

    -- 7. Ford of Bruinen
    if ford == "yes" or ford == "stepping_stones" then 
        return "7" 
    end

    -- 8. Rivendell
    if building == "church" or
        building == "cathedral" or
        building == "mosque" or
        building == "synagogue" or
        building == "temple" or
        building == "monastery" or
        amenity == "place_of_worship" or
        amenity == "monastery" or
        Find("place_of_worship") ~= "" or
        historic == "monastery" then
        return "8"
    end

    -- 9. Mines of Moria
    if moria_man_made[man_made] or 
        moria_historic[historic] or 
       moria_natural[natural] or 
       shelter_type == "rock_shelter" or 
       (moria_tunnels[tunnel] and (pedestrian_status[foot] or pedestrian_highways[highway])) then
        return "9"
    end

    -- 10. Morannon
    if barrier == "gate" or 
        barrier == "wicket_gate" or 
        barrier == "entrance" or 
       barrier == "kissing_gate" or 
       barrier == "sally_port" or 
       building == "gatehouse" or 
       tunnel == "building_passage" then
        return "10"
    end

    -- 11. Henneth Annûn
    if waterway == "waterfall" or water == "pond" then
        return "11"

    -- 12. Stairs of Cirith Ungol
    if highway == "steps" then
        return "12"
    end

    -- 13. Mount Doom
    if natural == "peak" then
        return "13"
    end

    -- 14. Minas Tirith
    if historic == "castle" and ruins ~= "yes" or
        building == "townhall" or
        building == "government" or
        amenity == "townhall" or
        historic == "manor" or
        building == "manor" or
        building == "palace" then
        return "14"
    end

    -- 15. The Grey Havens
    if man_made == "pier" or 
       man_made == "quay" or 
       leisure == "slipway" then
        return "15"
    end

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
        LayerAsCentroid("journey")
        Attribute("order", order)
    end
end

function relation_function() end