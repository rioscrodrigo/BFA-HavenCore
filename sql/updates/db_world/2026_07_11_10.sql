-- EN: "A Dying World" (52946 Alliance / 53028 Horde, the BFA War Campaign kickoff quest
-- granted by OnBfaArrival) was showing a plain quest icon (NPC head, world map, quest log)
-- instead of the exclamation-mark-with-shield "Legendary"/Campaign treatment retail uses for
-- War Campaign chapter quests. quest_template.QuestInfoID was 0 (no special type) for both;
-- confirmed via wago.tools/db2 that QuestInfoID 83 = "Legendary" client-side, which is what
-- drives that icon everywhere (NPC/map/log all read the same field, matching the report that
-- it looked wrong in all three places at once).
--
-- ES: "A Dying World" (52946 Alianza / 53028 Horda, la quest que arranca la War Campaign de
-- BFA, otorgada por OnBfaArrival) mostraba un icono de mision comun (cabeza del NPC, mapa del
-- mundo, log de misiones) en vez del tratamiento "Legendary"/Campaign con exclamacion+escudo
-- que usa retail para los capitulos de la War Campaign. quest_template.QuestInfoID estaba en 0
-- (sin tipo especial) para ambas; confirmado via wago.tools/db2 que QuestInfoID 83 = "Legendary"
-- del lado del cliente, que es lo que dispara ese icono en todos lados (NPC/mapa/log leen el
-- mismo campo, coincide con que se reportaba mal en los tres lugares a la vez).

UPDATE `quest_template` SET `QuestInfoID` = 83 WHERE `ID` IN (52946, 53028);
