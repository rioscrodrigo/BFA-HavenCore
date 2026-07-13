-- EN: Magni Bronzebeard's Heart-of-Azeroth-specific gossip lines (menu 22537, OptionIndex 0
-- "Magni, I'm ready for you to empower the Heart of Azeroth." and OptionIndex 1 "What does
-- Azeroth want of me, Magni?") had zero `conditions` rows, so they showed up regardless of
-- whether the player actually had quest 52428 ("Infusing the Heart") active - they don't make
-- narrative sense without it. Gate both on CONDITION_QUESTTAKEN (type 9, "true while quest
-- active") for quest 52428.
--
-- ES: Las lineas de gossip de Magni Bronzebeard especificas del Heart of Azeroth (menu 22537,
-- OptionIndex 0 "Magni, I'm ready for you to empower the Heart of Azeroth." y OptionIndex 1
-- "What does Azeroth want of me, Magni?") no tenian ninguna fila en `conditions`, asi que
-- aparecian sin importar si el jugador realmente tenia la quest 52428 ("Infusing the Heart")
-- activa - no tienen sentido narrativo sin ella. Se gatean ambas con CONDITION_QUESTTAKEN
-- (tipo 9, "true mientras la quest esta activa") para la quest 52428.

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 22537;

INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`)
VALUES
(15, 22537, 0, 0, 0, 9, 0, 52428, 0, 0, 0, 0, 0, '', 'Magni Heart Chamber - "I am ready..." only while Infusing the Heart (52428) is active'),
(15, 22537, 1, 0, 0, 9, 0, 52428, 0, 0, 0, 0, 0, '', 'Magni Heart Chamber - "What does Azeroth want..." only while Infusing the Heart (52428) is active');
