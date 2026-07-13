-- EN: Reverts 2026_07_11_14.sql. The popup-based delivery it supported (SendQuestGiverQuestDetails)
-- was abandoned - the client itself rejects offering "The Warchief's Order"/"The Wolf's
-- Offensive" out of sequence with a "War Campaign" message demanding the "Lost Honor"
-- questline (starting with "The Dark Lady Calls" in Dazar'alor) be completed first, and that
-- content doesn't exist in this world DB. Back to the original silent player->AddQuest()
-- delivery in custom_player_script.cpp (On120Arrival), which needs this flag cleared again
-- (see 2026_07_11_09.sql for why).
--
-- ES: Revierte 2026_07_11_14.sql. La entrega basada en popup que soportaba
-- (SendQuestGiverQuestDetails) se abandono - el cliente mismo rechaza ofrecer "The Warchief's
-- Order"/"The Wolf's Offensive" fuera de secuencia con un mensaje de "War Campaign" que exige
-- completar primero la questline "Lost Honor" (empezando por "The Dark Lady Calls" en
-- Dazar'alor), y ese contenido no existe en esta world DB. Se vuelve a la entrega original con
-- player->AddQuest() silencioso en custom_player_script.cpp (On120Arrival), que necesita este
-- flag limpio de nuevo (ver 2026_07_11_09.sql para el por que).

UPDATE `quest_template` SET `Flags` = `Flags` & ~0x00080000 WHERE `ID` IN (56030, 56031);
