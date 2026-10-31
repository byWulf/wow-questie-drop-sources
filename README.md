# Questie Drop Sources

A World of Warcraft addon for [Questie](https://github.com/Questie/Questie) users that shows where Questie's drop rates come from, and what the other sources say.

## Why

Questie shows a drop rate next to quest items in NPC tooltips, but it only shows one value. It takes that value from three sources in a fixed order:

1. **Questie corrections**: manual values by the Questie developers (rare)
2. **Private server data** (CMaNGOS): loot tables from a private server emulator, used for items that only drop while on the quest
3. **Wowhead**: a snapshot of Wowhead's crowdsourced drop rates, taken when Questie was built

Questie prefers the private server data for quest items because Wowhead also counts kills by players who don't have the quest, which would make quest-only drop rates look too low. In practice the private server values are often rough guesses. For example, the Woodpaw Gnoll Mane has 60% for all six Woodpaw gnoll types there, while Wowhead has about 10% for the Woodpaw Mystic.

This addon shows all three values side by side, so you can judge for yourself.

## What it looks like

```
Woodpaw Gnoll Mane: 9/10  [Q -  C 60%  W 9.6%]
```

- Each value has Questie's own source icon: Questie, CMaNGOS (or Mangos3) and Wowhead.
- **White** is the value Questie uses, **grey** are the other two.
- `-` means the source has no value for this item and NPC.

No configuration and no Questie debug mode needed. If you turn off drop rates in Questie's tooltip options, this addon shows nothing either.

## Supported game versions

| Version | Interface |
|---|---|
| WoW Classic Era | 11509 |
| WoW Classic Forever | 16001 |

Requires Questie. Tested with Questie 12.0.4 (Classic Era) and 12.3.1 (Forever). The addon hooks into Questie internals, so a future Questie update may break it; in that case the tooltip simply falls back to Questie's own drop rate.

## Installation

The folder in your AddOns directory **must** be named `QuestieDropSources`, otherwise WoW will not load the addon:

```bash
cd "C:/Program Files (x86)/World of Warcraft/_classic_era_/Interface/AddOns"
git clone https://github.com/byWulf/wow-questie-drop-sources.git QuestieDropSources
```

For Forever, use `_forever_/Interface/AddOns` instead. Alternatively, download the repository as a ZIP and extract its contents to `Interface/AddOns/QuestieDropSources/`.

Then restart WoW (or log out) and enable the addon in the AddOns list.

## Limitations

If an NPC drops several items for your active quests, each tooltip line is matched to its item by the item name in that line. If that doesn't work, the line keeps Questie's original drop rate.
