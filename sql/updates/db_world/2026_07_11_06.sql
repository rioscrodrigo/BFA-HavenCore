-- EN: Final piece of the "Infusing the Heart" wound-targeting bug. Even after clearing
-- UNIT_FLAG_NOT_SELECTABLE (unit_flags) and IMMUNE_TO_PC/NPC, the Azerite Wound (entry
-- 141870) still couldn't be targeted - it also had UNIT_FLAG2_SELECTION_DISABLED
-- (unit_flags2 0x04000000) set, whose own comment in UnitDefines.h literally reads
-- "Cant select (even in GM mode)". Cleared that bit (unit_flags2 67143680 -> 34816),
-- leaving the harmless remaining bits (UNIT_FLAG2_DISABLE_TURN | UNIT_FLAG2_REGENERATE_POWER)
-- untouched.
--
-- ES: Ultima pieza del bug de no poder targetear la Azerite Wound de "Infusing the Heart".
-- Incluso despues de sacar UNIT_FLAG_NOT_SELECTABLE (unit_flags) e IMMUNE_TO_PC/NPC, la
-- Azerite Wound (entry 141870) seguia sin poder seleccionarse - tambien tenia
-- UNIT_FLAG2_SELECTION_DISABLED (unit_flags2 0x04000000) puesto, cuyo propio comentario en
-- UnitDefines.h dice literalmente "Cant select (even in GM mode)". Se saco ese bit
-- (unit_flags2 67143680 -> 34816), dejando intactos los bits restantes inofensivos
-- (UNIT_FLAG2_DISABLE_TURN | UNIT_FLAG2_REGENERATE_POWER).

UPDATE `creature_template` SET `unit_flags2` = 34816 WHERE `entry` = 141870;
