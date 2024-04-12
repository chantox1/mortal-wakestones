local sdk = sdk
local log = log

local max_hp = nil
local is_player_revive = true

local function get_player_character()
    local characterManager = sdk.get_managed_singleton("app.CharacterManager")
    return characterManager:get_ManualPlayer()
end

local function on_pre_revive(args)
    log.info("[Mortal Wakestones]: Run on_pre_revive")

    local this = sdk.to_managed_object(args[2])
    is_player_revive = this.IsPlayer
    if not is_player_revive then
        log.info("[Mortal Wakestones]: Not a player revive, ignored")
        return
    end

    local player = get_player_character()
    if player == nil then
        log.info("[Mortal Wakestones]: Failed to get player character")
        return
    end

    max_hp = player:get_ReducedMaxHp()
    log.info("[Mortal Wakestones]: Pre revive hp: " .. max_hp)
end

local function on_post_revive(retval)
    log.info("[Mortal Wakestones]: Run on_post_revive")

    if not is_player_revive then
        log.info("[Mortal Wakestones]: Not a player revive, ignored")
        return retval
    end

    local player = get_player_character()
    if player == nil then
        log.info("[Mortal Wakestones]: Failed to get player character")
        return retval
    end

    if max_hp == nil then
        log.info("[Mortal Wakestones]: Failed to get max hp value")
        return retval
    end

    local hit_controller = player:get_Hit()
    hit_controller:setReducedMaxHp(max_hp)

    log.info("[Mortal Wakestones]: Set max hp: " .. max_hp)
    return retval
end

local function init()
    local noop = function()
    end

    -- reviveIfNeeded calls app.HitController to fully restore the player's HP
    sdk.hook(sdk.find_type_definition("app.ReviveFromWakestone"):get_method("reviveIfNeeded"), on_pre_revive, on_post_revive)
end

return init
