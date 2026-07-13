-- EN: Remove a redundant, unscripted duplicate spawn of "Lady Sylvanas Windrunner"
-- (creature guid 300001888, entry 134711) in Orgrimmar. It was spawned less than 1 yard
-- from the properly scripted Sylvanas used by the Battle for Azeroth intro campaign
-- (entry 135201 "Talk to Sylvanas", ScriptName npc_orgri_mission_orders_speak_sylvanas,
-- at 1661.5,-4347.05,26.4 vs this one at 1661.68,-4347.1,26.4), had no ScriptName, no
-- creature_queststarter/questender relations, and no creature_addon/linked_respawn
-- dependencies - a leftover placeholder spawn with no purpose, reported as "Sylvanas
-- appears twice" in Orgrimmar.
--
-- ES: Elimina un spawn duplicado y sin scriptear de "Lady Sylvanas Windrunner" (creature
-- guid 300001888, entry 134711) en Orgrimmar. Estaba a menos de 1 yarda de la Sylvanas
-- correctamente scripteada que usa la campana de introduccion de Battle for Azeroth
-- (entry 135201 "Talk to Sylvanas", ScriptName npc_orgri_mission_orders_speak_sylvanas,
-- en 1661.5,-4347.05,26.4 contra esta en 1661.68,-4347.1,26.4), no tenia ScriptName, ni
-- relaciones de creature_queststarter/questender, ni dependencias en
-- creature_addon/linked_respawn - un spawn sobrante sin ningun proposito, reportado como
-- "Sylvanas aparece dos veces" en Orgrimmar.

DELETE FROM `creature` WHERE `guid` = 300001888;
