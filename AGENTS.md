# AGENTS.md

## Language

All documentation in this repository (README, AGENTS.md, code comments, commit messages) is written in **English**.

## Project

WoW addon `QuestieDropSources`: a companion to [Questie](https://github.com/Questie/Questie). Questie shows one drop rate per quest item in NPC tooltips and picks it from three sources in a fixed order (manual corrections, then private server data like CMaNGOS, then Wowhead). This addon replaces that single value with all three sources, each with Questie's source icon. The source Questie used is white, the others grey.

- `QuestieDropSources.toc`: addon manifest, interface `11509` (Classic Era) and `16001` (Classic Forever), `Dependencies: Questie` so it loads after Questie
- `QuestieDropSources.lua`: everything else

How it hooks into Questie (all via the global `QuestieLoader:ImportModule`):

- `DropDB.GetItemDroprate` is wrapped to record `{itemId, npcId, rate, source}` for every lookup while a tooltip is being built. Questie calls it through `QuestieDB.GetItemDroprate`, which looks up the module field at call time.
- `QuestieTooltips.GetTooltip` is wrapped. After Questie built the lines, every drop text (`|cFF999999` + optional debug icon + `[NN%]|r`, see `Modules/Tooltips/Tooltip.lua`) is replaced with the three-source text.
- The raw values come from `DropDB.tableCorrections`, `DropDB.tablePserver` and `DropDB.tableWowhead`; `DropDB.sourcePserver` names the private server source (`cmangos` or `mangos3`). Negative correction values are references to another table, not rates.
- A line is matched to its item by the item name in the line; if that is ambiguous, by the displayed rate. Lines that cannot be matched keep Questie's original text.

These hooks depend on Questie internals. After a Questie update, check that the function names, the drop text format and the table names above still exist in `Questie/Database/DropTables/dropDB.lua` and `Questie/Modules/Tooltips/Tooltip.lua`.

## Installed copies

The addon is installed as a plain copy (not a clone) in:

- `C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\QuestieDropSources`
- `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\QuestieDropSources`

After changing the `.toc` or the `.lua`, copy them to both installations. The folder name must stay `QuestieDropSources`.

## Testing

There is no automated test setup. Changes are verified in game with `/reload` on an NPC that drops an item for an active quest; Lua errors show up with `/console scriptErrors 1`. A syntax check is possible with `luajit -bl QuestieDropSources.lua`.
