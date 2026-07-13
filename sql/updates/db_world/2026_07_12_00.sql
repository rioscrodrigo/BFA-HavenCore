-- Quest 51443 "Mission Statement": turn-in NPC "Nathanos Blightcaller" (entry 135205, at the
-- team meeting spot) was missing UNIT_NPC_FLAG_QUESTGIVER (0x2) in npcflag - it only had
-- UNIT_NPC_FLAG_GOSSIP (0x1). The "Meet your team" objective completed fine (kill credit via
-- npc_orgri_mission_orders_meet_team), but the client never offered the turn-in because this
-- NPC wasn't flagged as a quest giver. The other two Nathanos spawns used for this quest
-- (121210, 140176, both quest starters) already have npcflag = 3 (Gossip + QuestGiver).
UPDATE `creature_template` SET `npcflag` = `npcflag` | 0x2 WHERE `entry` = 135205;
