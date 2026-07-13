/*
 * 2026 BFA-HavenCore
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "GameObject.h"
#include "ScriptedCreature.h"
#include "WorldSession.h"

enum OrgrimmarQuests
{
    QUEST_MISSION_ORDERS                    = 51443,
    QUEST_STORMWIND_EXTRACTION              = 50769,

    OBJECTIVE_STORMWIND_EXTRACTION_POTION   = 333785,
};

enum OrgrimmarGameObjects
{
    GOB_BLIGHTCALLER_EASY_DEATH = 289645
};

enum OrgrimmarQuestObjectives
{
    OBJECTIVE_MISSION_ORDERS_TAlk_SYLVANAS  = 335883,
};

enum OrgrimmarSpells
{
    SPELL_SCENE_SECRET_WEAPON   = 281294,
    SPELL_TALK_TO_SYLVANAS_KC   = 265586,

    // invisibility_detection_27 100616
    SPELL_START_SE_SCENARIO     = 265595,

    // Client-data-chained secondary effect of SPELL_TALK_TO_SYLVANAS_KC (265586) - casting
    // that kill-credit spell also applies this SPELL_AURA_PLAY_SCENE aura for scene 2107,
    // outside our own script's control (no EffectTriggerSpell/spell_linked_spell row locally -
    // confirmed via live PlaySceneByTemplate logging that it fires immediately after 265586).
    // scene_template for SceneId 2107 has an empty ScriptName, so nothing server-side cleans
    // this up if the scene never naturally completes (e.g. player disconnects while it's
    // playing) - see cleanup in OnMissionOrdersLogin below.
    SPELL_SCENE_AFTER_SYLVANAS_KC = 278009,
};

enum OrgrimmarConversations
{
    CONVERSATION_MISSION_STATEMENT_ALL_HERE     = 7170,
    CONVERSATION_STORMWIND_EXTRACTION_LETS_MOVE = 8399,
};

 // 135201 - Talk to Sylvanas
struct npc_orgri_mission_orders_speak_sylvanas : public ScriptedAI
{
    npc_orgri_mission_orders_speak_sylvanas(Creature* creature) : ScriptedAI(creature) { }

    // EN: MoveInLineOfSight fires repeatedly (many times per second) while the player stays
    // in view, not just once. Without the HasAura guard below, every one of those calls
    // re-cast SPELL_SCENE_SECRET_WEAPON (281294, applies a SPELL_AURA_PLAY_SCENE aura for
    // scene 2136) - restarting the scene over and over before it could ever end cleanly and
    // grant the kill credit (SPELL_TALK_TO_SYLVANAS_KC) that would clear
    // OBJECTIVE_MISSION_ORDERS_TAlk_SYLVANAS and stop the re-triggering. This left the client
    // stuck in a broken camera/scene state - reported as the mouse cursor becoming invisible
    // for the rest of the session while anywhere near this NPC, only fixed by teleporting far
    // away. Guard with HasAura so the spell is only cast once, while the scene aura isn't
    // already active.
    // ES: MoveInLineOfSight se dispara repetidamente (muchas veces por segundo) mientras el
    // jugador sigue a la vista, no una sola vez. Sin la guarda de HasAura de abajo, cada una
    // de esas llamadas volvia a castear SPELL_SCENE_SECRET_WEAPON (281294, aplica un aura
    // SPELL_AURA_PLAY_SCENE para la escena 2136) - reiniciando la escena una y otra vez antes
    // de que pudiera terminar limpiamente y otorgar el credito (SPELL_TALK_TO_SYLVANAS_KC) que
    // limpiaria OBJECTIVE_MISSION_ORDERS_TAlk_SYLVANAS y frenaria el retrigger. Esto dejaba al
    // cliente atascado en un estado de camara/escena roto - reportado como que el cursor del
    // mouse se volvia invisible por el resto de la sesion estando cerca de este NPC, y solo se
    // arreglaba teletransportandose lejos. Se agrega la guarda con HasAura para que el hechizo
    // se castee una sola vez, mientras el aura de la escena no este ya activa.
    //
    // EN: A second, related case of the same bug: a player who logs out (or disconnects) while
    // standing near this NPC with the objective still incomplete gets teleported right back
    // into LOS of it on the next login, while their client is still on the loading
    // screen/finishing its transition into the world. PlayerLoading() was still true at that
    // point, so this recast the scene while the client wasn't ready to properly display it,
    // reproducing the exact same broken camera/invisible cursor state (and blocking unrelated
    // addon UI, e.g. GPSToTele's save-name dialog, since the client considers itself mid-scene).
    // Guard against firing while the session is still loading so the scene only (re)plays once
    // the player is fully in world.
    // ES: Un segundo caso, relacionado, del mismo bug: un jugador que cierra sesion (o se
    // desconecta) parado cerca de este NPC con el objetivo aun incompleto vuelve a aparecer
    // justo dentro de la linea de vision al iniciar sesion de nuevo, mientras su cliente todavia
    // esta en la pantalla de carga/terminando de entrar al mundo. PlayerLoading() seguia siendo
    // true en ese momento, asi que esto volvia a castear la escena mientras el cliente no estaba
    // listo para mostrarla, reproduciendo el mismo estado roto de camara/cursor invisible (y
    // bloqueando UI de addons no relacionados, ej. el dialogo de guardar nombre de GPSToTele, ya
    // que el cliente se considera a si mismo en medio de una escena). Se agrega la guarda para
    // que no se dispare mientras la sesion todavia esta cargando, asi la escena solo se
    // (re)reproduce una vez que el jugador esta completamente en el mundo.
    void MoveInLineOfSight(Unit* unit) override
    {
        if (Player* player = unit->ToPlayer())
            if (!player->GetSession()->PlayerLoading())
                if (player->GetQuestStatus(QUEST_MISSION_ORDERS) == QUEST_STATUS_INCOMPLETE)
                    if (player->GetQuestObjectiveCounter(OBJECTIVE_MISSION_ORDERS_TAlk_SYLVANAS) == 0)
                        if (player->GetDistance(me) < 40.f)
                            if (!player->HasAura(SPELL_SCENE_SECRET_WEAPON))
                                player->CastSpell(player, SPELL_SCENE_SECRET_WEAPON);
    }
};

// EN: If a player disconnects mid-scene (after SPELL_SCENE_SECRET_WEAPON was cast but before
// OnSceneEnd removed it), the SPELL_AURA_PLAY_SCENE aura can survive the logout and get
// reapplied on the next login without a matching client-side scene ever being (re)started -
// the SceneMgr that tracked it lived only in memory and is gone. That leaves the HasAura guard
// above permanently true, so the scene can never be recast and OBJECTIVE_MISSION_ORDERS_TAlk_
// SYLVANAS can never complete. Clean it up on login so the next approach to the NPC starts a
// fresh scene instead of getting stuck.
// ES: Si un jugador se desconecta en medio de la escena (despues de castear
// SPELL_SCENE_SECRET_WEAPON pero antes de que OnSceneEnd la quitara), el aura
// SPELL_AURA_PLAY_SCENE puede sobrevivir al cierre de sesion y volver a aplicarse en el
// siguiente login sin que se (re)inicie ninguna escena del lado del cliente - el SceneMgr que
// la rastreaba vivia solo en memoria y ya no existe. Eso deja la guarda de HasAura de arriba en
// true para siempre, asi que la escena nunca se puede volver a castear y
// OBJECTIVE_MISSION_ORDERS_TAlk_SYLVANAS nunca se puede completar. Se limpia al iniciar sesion
// para que el siguiente acercamiento al NPC inicie una escena nueva en vez de quedar atascado.
class OnMissionOrdersLogin : public PlayerScript
{
public:
    OnMissionOrdersLogin() : PlayerScript("OnMissionOrdersLogin") { }

    void OnLogin(Player* player, bool /*firstLogin*/) override
    {
        if (player->GetQuestStatus(QUEST_MISSION_ORDERS) == QUEST_STATUS_INCOMPLETE)
            if (player->GetQuestObjectiveCounter(OBJECTIVE_MISSION_ORDERS_TAlk_SYLVANAS) == 0)
                if (player->HasAura(SPELL_SCENE_SECRET_WEAPON))
                    player->RemoveAura(SPELL_SCENE_SECRET_WEAPON);

        // Same stuck-scene class of bug as SPELL_SCENE_SECRET_WEAPON above, one narrative beat
        // later: SPELL_SCENE_AFTER_SYLVANAS_KC (278009, scene 2107) has no legitimate reason to
        // still be active by the time a player logs in - it's a short chained cinematic, not a
        // quest-tracked state. Unconditional cleanup (no quest/objective gate needed).
        if (player->HasAura(SPELL_SCENE_AFTER_SYLVANAS_KC))
            player->RemoveAura(SPELL_SCENE_AFTER_SYLVANAS_KC);
    }
};

// 2136
class scene_orgri_secret_weapon : public SceneScript
{
public:
    scene_orgri_secret_weapon() : SceneScript("scene_orgri_secret_weapon") { }

    void OnSceneEnd(Player* player, uint32 /*sceneInstanceID*/, SceneTemplate const* /*sceneTemplate*/) override
    {
        player->CastSpell(player, SPELL_TALK_TO_SYLVANAS_KC, true);
    }
};

// 134202 - Meet your team
struct  npc_orgri_mission_orders_meet_team : public ScriptedAI
{
    npc_orgri_mission_orders_meet_team(Creature* creature) : ScriptedAI(creature) { }

    void MoveInLineOfSight(Unit* unit) override
    {
        if (Player* player = unit->ToPlayer())
            if (player->GetQuestStatus(QUEST_MISSION_ORDERS) == QUEST_STATUS_INCOMPLETE)
                if (player->GetQuestObjectiveCounter(OBJECTIVE_MISSION_ORDERS_TAlk_SYLVANAS) == 1)
                    if (player->GetDistance(me) < 5.0f)
                    {
                        player->PlayConversation(CONVERSATION_MISSION_STATEMENT_ALL_HERE);
                        KillCreditMe(player);
                    }
    }
};

// 135205 - Nathanos (At team meeting)
struct  npc_nathanos_team_meeting : public ScriptedAI
{
    npc_nathanos_team_meeting(Creature* creature) : ScriptedAI(creature) { }

    void sQuestAccept(Player* player, Quest const* /*quest*/) override
    {
        Talk(0);
        player->SummonGameObject(GOB_BLIGHTCALLER_EASY_DEATH, 1577.965f, -4455.622f, 16.55939f, 0.f, QuaternionData(0.f, 0.f, 0.f, 1.f), 0, true);
    }
    
    // EN: This handler is shared by every gossip option on this NPC, but the only one wired
    // in gossip_menu_option (menu 23141) is "I have heard this story before. (Skip the
    // Scenario and port to Zuldazar Harbor in Zandalar)" - a shortcut meant to work whether or
    // not the player currently has quest 50769 ("Stormwind Extraction") active. Requiring
    // GetQuestStatus(50769) == QUEST_STATUS_INCOMPLETE contradicted that: a player who never
    // picked up 50769 (status NONE) - the exact case this "already know the story" option is
    // for - got nothing at all when clicking it. Level gate kept, quest-status gate dropped.
    // ES: Este handler es compartido por cualquier opcion de gossip de este NPC, pero la unica
    // conectada en gossip_menu_option (menu 23141) es "I have heard this story before. (Skip
    // the Scenario and port to Zuldazar Harbor in Zandalar)" - un atajo pensado para funcionar
    // tenga o no el jugador la quest 50769 ("Stormwind Extraction") activa en ese momento.
    // Exigir GetQuestStatus(50769) == QUEST_STATUS_INCOMPLETE contradecia eso: un jugador que
    // nunca tomo la 50769 (status NONE) - el caso exacto para el que existe esta opcion de "ya
    // conozco la historia" - no obtenia nada al clickearla. Se mantiene el chequeo de nivel, se
    // saca el de estado de quest.
    void sGossipSelect(Player* player, uint32 /*menuId*/, uint32 /*gossipListId*/)
    {
        if (player->getLevel() >= 110)
        {
            player->AddItem(160251, 1);
            player->KilledMonsterCredit(135211);
            player->KilledMonsterCredit(135203);
            player->CastSpell(player, 263948);
        }
    }
};

// 50769
struct quest_stormwind_extraction : public QuestScript
{
    quest_stormwind_extraction() : QuestScript("quest_stormwind_extraction") { }

    // Called when a quest objective data change
    void OnQuestObjectiveChange(Player* player, Quest const* /*quest*/, QuestObjective const& objective, int32 /*oldAmount*/, int32 /*newAmount*/) override
    {
        if (objective.ID == OBJECTIVE_STORMWIND_EXTRACTION_POTION)
            player->PlayConversation(CONVERSATION_STORMWIND_EXTRACTION_LETS_MOVE);
    }
};

// 135211 - Stormwind Extraction skyhorn eagle
struct npc_skyhorn_eagle : public ScriptedAI
{
    npc_skyhorn_eagle(Creature* creature) : ScriptedAI(creature) { }

    void OnSpellClick(Unit* clicker, bool& result) override
    {
        Player* player = clicker->ToPlayer();
        if (!player || player->GetQuestStatus(QUEST_STORMWIND_EXTRACTION) != QUEST_STATUS_INCOMPLETE)
        {
            result = false;
            return;
        }

        KillCreditMe(player);
        player->CastSpell(player, SPELL_START_SE_SCENARIO);
    }
};

class npc_general_nazgrim_55054 : public ScriptedAI
{
public:
    npc_general_nazgrim_55054(Creature* creature) : ScriptedAI(creature) { }

    void sGossipSelect(Player* player, uint32 /*menuId*/, uint32 /*gossipListId*/) override
    {
        if (player->GetQuestStatus(29690) == QUEST_STATUS_INCOMPLETE) //Into the Mists
        {
            player->ForceCompleteQuest(29690);
            player->TeleportTo(870, 3169.132f, -689.578f, 230.825f, 5.635f);
        }
    }
};

void AddSC_orgrimmar()
{
    RegisterCreatureAI(npc_orgri_mission_orders_speak_sylvanas);
    RegisterPlayerScript(OnMissionOrdersLogin);
    RegisterSceneScript(scene_orgri_secret_weapon);
    RegisterCreatureAI(npc_orgri_mission_orders_meet_team);
    RegisterCreatureAI(npc_nathanos_team_meeting);
    RegisterQuestScript(quest_stormwind_extraction);
    RegisterCreatureAI(npc_skyhorn_eagle);
    RegisterCreatureAI(npc_general_nazgrim_55054);
}
