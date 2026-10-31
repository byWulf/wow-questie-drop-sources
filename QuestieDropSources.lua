-- Replaces Questie's single drop rate in objective tooltips with all three sources
-- Questie knows about: manual corrections, private server data (CMaNGOS) and Wowhead.
-- The source Questie actually picked is white, the others are grey.

local QuestieLoader = QuestieLoader
if not QuestieLoader then return end

local DropDB = QuestieLoader:ImportModule("DropDB")
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
if not (DropDB.GetItemDroprate and QuestieTooltips.GetTooltip) then return end

local ICON_PATH = "Interface\\AddOns\\Questie\\Icons\\"
local ICONS = {
    questie = "|T" .. ICON_PATH .. "questie_flat.png:12|t",
    cmangos = "|T" .. ICON_PATH .. "cmangos.png:10|t",
    mangos3 = "|T" .. ICON_PATH .. "mangos3.png:12|t",
    wowhead = "|T" .. ICON_PATH .. "wowhead.png:12|t",
}
local WHITE = "|cFFFFFFFF"
local GREY = "|cFF999999"

-- Questie's drop text as built in Tooltip.lua: "|cFF999999" .. optional debug icon .. "[" .. rate .. "%]|r"
local DROP_TEXT_PATTERN = "|cFF999999[^%[]-%[([%d%.]+)%%%]|r"

local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo

-- Same rounding as Questie's FormatDropText
local function FormatRate(rate)
    if rate >= 10 then
        return string.format("%.0f", rate)
    elseif rate >= 2 then
        return string.format("%.1f", rate)
    elseif rate >= 0.01 then
        return string.format("%.2f", rate)
    end
    return string.format("%.3f", rate)
end

local function Lookup(tbl, itemId, npcId)
    local value = tbl and tbl[itemId] and tbl[itemId][npcId]
    -- Negative corrections are references to another table, not a rate of their own
    if value and value >= 0 then
        return value
    end
end

local function BuildDropText(itemId, npcId, usedSource)
    local pserverSource = DropDB.sourcePserver ~= "" and DropDB.sourcePserver or "cmangos"
    local sources = {
        { "questie", Lookup(DropDB.tableCorrections, itemId, npcId) },
        { pserverSource, Lookup(DropDB.tablePserver, itemId, npcId) },
        { "wowhead", Lookup(DropDB.tableWowhead, itemId, npcId) },
    }
    local parts = {}
    for _, source in ipairs(sources) do
        local name, rate = source[1], source[2]
        local color = (name == usedSource) and WHITE or GREY
        local value = rate and (FormatRate(rate) .. "%") or "-"
        parts[#parts + 1] = (ICONS[name] or "") .. " " .. color .. value .. "|r"
    end
    return GREY .. "[|r" .. table.concat(parts, "  ") .. GREY .. "]|r"
end

local function GetItemName(itemId)
    return (GetItemInfo and GetItemInfo(itemId)) or QuestieDB.QueryItemSingle(itemId, "name")
end

-- Finds which captured drop rate lookup a tooltip line belongs to
local function FindDropForLine(line, shownRate, drops)
    if #drops == 1 then
        return drops[1]
    end
    local match
    for _, drop in ipairs(drops) do
        local name = GetItemName(drop.itemId)
        if name and line:find(name, 1, true) then
            if match then match = nil break end
            match = drop
        end
    end
    if match then
        return match
    end
    -- Item names did not help, fall back to the displayed rate if it is unique
    for _, drop in ipairs(drops) do
        if FormatRate(drop.rate) == shownRate then
            if match then return nil end
            match = drop
        end
    end
    return match
end

-- Remember every drop rate Questie asks for while it builds a tooltip
local captured
local originalGetItemDroprate = DropDB.GetItemDroprate
DropDB.GetItemDroprate = function(itemId, npcId)
    local result = originalGetItemDroprate(itemId, npcId)
    if captured and result and result[1] then
        local key = tostring(itemId) .. ":" .. tostring(npcId)
        if not captured[key] then
            captured[key] = true
            captured[#captured + 1] = { itemId = itemId, npcId = npcId, rate = result[1], source = result[2] }
        end
    end
    return result
end

local originalGetTooltip = QuestieTooltips.GetTooltip
QuestieTooltips.GetTooltip = function(key, playerZone)
    captured = {}
    local lines = originalGetTooltip(key, playerZone)
    local drops = captured
    captured = nil

    if lines and #drops > 0 then
        for index, line in pairs(lines) do
            if type(line) == "string" then
                local startPos, endPos, shownRate = line:find(DROP_TEXT_PATTERN)
                if startPos then
                    local drop = FindDropForLine(line, shownRate, drops)
                    if drop then
                        lines[index] = line:sub(1, startPos - 1) .. BuildDropText(drop.itemId, drop.npcId, drop.source) .. line:sub(endPos + 1)
                    end
                end
            end
        end
    end
    return lines
end
