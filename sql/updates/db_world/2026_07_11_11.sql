-- EN: Same icon gap as "A Dying World" (see 2026_07_11_10.sql) - "Infusing the Heart" (52428)
-- also needs the exclamation-mark-with-shield "Legendary"/Campaign quest icon on the NPC, world
-- map, and quest log. quest_template.QuestInfoID was 0 (no special type); set to 83
-- ("Legendary" per wago.tools/db2), same as its sibling War Campaign quests.
--
-- ES: Mismo hueco de icono que "A Dying World" (ver 2026_07_11_10.sql) - "Infusing the Heart"
-- (52428) tambien necesita el icono de "Legendary"/Campaign (exclamacion+escudo) en el NPC, el
-- mapa del mundo y el log de misiones. quest_template.QuestInfoID estaba en 0 (sin tipo
-- especial); se puso en 83 ("Legendary" segun wago.tools/db2), igual que sus quests hermanas de
-- la War Campaign.

UPDATE `quest_template` SET `QuestInfoID` = 83 WHERE `ID` = 52428;
