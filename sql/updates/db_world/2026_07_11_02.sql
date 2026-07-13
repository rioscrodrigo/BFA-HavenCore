-- EN: "Infusing the Heart" (quest 52428, Chamber of Heart) minigame wasn't progressing -
-- the "Azerite Wound" creature (entry 141870, the 5 targets you're supposed to hit with the
-- Heart of Azeroth's temporary ability to absorb them) had UNIT_FLAG_NOT_SELECTABLE
-- (0x02000000) set, so the client never let the player target/select it at all - no target,
-- no cast, no SpellHit, no progress. Cleared just that bit (unit_flags 33555200 -> 768),
-- keeping UNIT_FLAG_IMMUNE_TO_PC|IMMUNE_TO_NPC so it still can't be attacked/tabbed into
-- combat normally, only selectable for the quest ability.
--
-- ES: El minijuego de "Infusing the Heart" (quest 52428, Camara del Corazon) no avanzaba -
-- la criatura "Azerite Wound" (entry 141870, los 5 objetivos a los que hay que pegarles con
-- la habilidad temporal del Corazon de Azeroth para absorberlos) tenia
-- UNIT_FLAG_NOT_SELECTABLE (0x02000000) puesto, asi que el cliente nunca dejaba
-- seleccionarla/targetearla en absoluto - sin target, no hay cast, no dispara SpellHit, no
-- hay progreso. Se saco solo ese bit (unit_flags 33555200 -> 768), dejando
-- UNIT_FLAG_IMMUNE_TO_PC|IMMUNE_TO_NPC para que siga sin poder atacarse/entrar en combate
-- normal, solo que ahora se puede seleccionar para la habilidad de la quest.

UPDATE `creature_template` SET `unit_flags` = 768 WHERE `entry` = 141870;
