-- EN: Second "Nathanos duplicated" report, this time in Dazar'alor harbor (same root-cause
-- family as the earlier Orgrimmar case). Two separate spawns of "Nathanos Blightcaller" sit at
-- the same spot: entry 121210 (guid 210401198, only offers the early arrival quests 50769/
-- 51443) and entry 135691 (the real ongoing War Campaign hub, ~50 quests). Neither had a
-- PhaseId, so both always showed together. Gives the arrival-only spawn (121210) a PhaseId so
-- it can be gated - see OnZuldazarHarborArrival in zone_zuldazar.cpp for the condition
-- (PHASE_NATHANOS_ZULDAZAR_HARBOR_ARRIVAL = 10402).
--
-- ES: Segundo reporte de "Nathanos duplicado", esta vez en el puerto de Dazar'alor (misma
-- familia de causa raiz que el caso anterior de Orgrimmar). Hay dos spawns separados de
-- "Nathanos Blightcaller" en el mismo lugar: entry 121210 (guid 210401198, solo ofrece las
-- quests de llegada temprana 50769/51443) y entry 135691 (el verdadero hub de la War Campaign
-- en curso, ~50 quests). Ninguno tenia PhaseId, asi que ambos aparecian siempre juntos. Se le
-- da al spawn de solo-llegada (121210) un PhaseId para poder gatearlo - ver
-- OnZuldazarHarborArrival en zone_zuldazar.cpp para la condicion
-- (PHASE_NATHANOS_ZULDAZAR_HARBOR_ARRIVAL = 10402).

UPDATE `creature` SET `PhaseId` = 10402 WHERE `guid` = 210401198;
