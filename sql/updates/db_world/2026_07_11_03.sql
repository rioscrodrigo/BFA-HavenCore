-- EN: The "Infusing the Heart" (quest 52428, Chamber of Heart) wound-absorbing minigame
-- never started - the scene it depends on (Player casts spell 268798 -> SPELL_AURA_PLAY_SCENE
-- effect, EffectMiscValue = 1946 = the real SceneId, confirmed via `.debug spelleffects
-- 268798` and cross-checked on wago.tools/db2) had NO ScriptName in scene_template at all.
-- The scene_get_heart_of_azeroth C++ script (zone_silithus.cpp) already existed with the
-- right logic (opens a 38s window, then removes the 268798 aura and cancels the scene) but
-- was wired to scene_template.SceneId = 3046 instead - a different, unrelated scene entry
-- that spell 268798 never actually triggers. Moves the ScriptName to the correct SceneId
-- (1946) and clears it from the wrong one (3046).
--
-- ES: El minijuego de absorber heridas de "Infusing the Heart" (quest 52428, Camara del
-- Corazon) nunca arrancaba - la escena de la que depende (el jugador castea el hechizo
-- 268798 -> efecto SPELL_AURA_PLAY_SCENE, EffectMiscValue = 1946 = el SceneId real,
-- confirmado con `.debug spelleffects 268798` y cruzado en wago.tools/db2) no tenia NINGUN
-- ScriptName en scene_template. El script C++ scene_get_heart_of_azeroth (zone_silithus.cpp)
-- ya existia con la logica correcta (abre una ventana de 38s, despues saca el aura de 268798
-- y cancela la escena) pero estaba conectado al SceneId 3046 en vez de eso - una entrada de
-- escena distinta y sin relacion que el hechizo 268798 nunca dispara en realidad. Mueve el
-- ScriptName al SceneId correcto (1946) y lo saca del equivocado (3046).

UPDATE `scene_template` SET `ScriptName` = 'scene_get_heart_of_azeroth' WHERE `SceneId` = 1946;
UPDATE `scene_template` SET `ScriptName` = '' WHERE `SceneId` = 3046;
