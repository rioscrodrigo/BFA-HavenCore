-- EN: Add a SpellClick fallback for the Azerite Wound (entry 141870, "Infusing the Heart"
-- minigame). Server-side, spell 267913 (the Heart of Azeroth extra action button ability)
-- now works completely correctly (confirmed live via `.cast 267913` and via SpellHit/AfterHit
-- firing) after all the earlier fixes (unit_flags, unit_flags2, scene id, QuestType, the
-- missing implicit-target `conditions` row) - but the real client still refuses to send the
-- cast when pressing the actual extra action button, seemingly pre-validating the spell's
-- TARGET_UNIT_NEARBY_ENTRY implicit target itself and finding nothing (the auto-target
-- `conditions` row is server-only data the client has no visibility into). Rather than fight
-- further with client-side pre-validation, players can now also just click the wound directly
-- (same UNIT_NPC_FLAG_SPELLCLICK + npc_spellclick_spells pattern already used by the working
-- "Countermeasures" NPCs in zone_vault_of_wardens.cpp, reusing the same generic trigger spell
-- 204588).
--
-- ES: Agrega un respaldo por SpellClick para la Azerite Wound (entry 141870, minijuego de
-- "Infusing the Heart"). Del lado del servidor, el hechizo 267913 (la habilidad del boton de
-- accion extra del Heart of Azeroth) ya funciona perfectamente (confirmado en vivo via
-- `.cast 267913` y viendo disparar SpellHit/AfterHit) despues de todos los fixes anteriores
-- (unit_flags, unit_flags2, scene id, QuestType, la fila faltante de `conditions` para el
-- target implicito) - pero el cliente real se sigue negando a mandar el cast al presionar el
-- boton de accion extra real, aparentemente pre-validando el mismo el target implicito
-- TARGET_UNIT_NEARBY_ENTRY del hechizo y no encontrando nada (la fila de `conditions` de
-- auto-target es un dato exclusivo del servidor que el cliente no puede ver). En vez de
-- seguir peleando con la prevalidacion del cliente, los jugadores ahora tambien pueden
-- simplemente clickear la herida directo (mismo patron UNIT_NPC_FLAG_SPELLCLICK +
-- npc_spellclick_spells que ya usan los NPCs "Countermeasures" que funcionan en
-- zone_vault_of_wardens.cpp, reusando el mismo hechizo trigger generico 204588).

UPDATE `creature_template` SET `npcflag` = 16777216 WHERE `entry` = 141870;
INSERT INTO `npc_spellclick_spells` (`npc_entry`, `spell_id`, `cast_flags`, `user_type`) VALUES (141870, 204588, 0, 0);
