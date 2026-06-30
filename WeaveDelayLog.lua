
WeaveDelayLog = {}
function WeaveDelayLog.new()
    local self = {}
    local playerActions = {}

    local ACTION_LIGHT_ATTACK       = 1
    local ACTION_SKILL_OFFSET       = 2
    local NORMAL_LATENCY_TIMEOUT_MS = 1000
    local HIGH_LATENCY_TIMEOUT_MS   = 1600

    local PA_IDX_TIME         = 1
    local PA_IDX_BAR_INDEX    = 2
    local PA_IDX_SLOT_ID      = 3
    local PA_IDX_BOUND_ID     = 4
    local PA_IDX_CHANNELED    = 5
    local PA_IDX_CAST_TIME    = 6
    local PA_IDX_CHANNEL_TIME = 7
    -- [8] unused
    local PA_IDX_LA_CONFIRMED = 9
    local PA_IDX_LA_QUEUED    = 10
    local PA_IDX_BASH         = 11

	-- index for weapon bar, 0 is the one active when addon is loaded
	local activeBarIndex         = 0
	local activeBarIndexReversed = false
	local skillBarIndex          = nil

	local settings = {}
	settings.GCD                = 1000
	settings.lightAttackTimeout = NORMAL_LATENCY_TIMEOUT_MS

	local combatEndMarkerPosition = -1

	-- this might register shortly after the first skill(s), so only remove everything until last combat end marker
	function self.startCombat()
		if combatEndMarkerPosition > 0 then
			local newPlayerActions = {}
			for i=combatEndMarkerPosition+1,#playerActions do
				table.insert(newPlayerActions, playerActions[i])
			end
			playerActions = newPlayerActions
			combatEndMarkerPosition = -1
		end
	end

	function self.endCombat()
		combatEndMarkerPosition = #playerActions
	end

	function self.reset()
		playerActions = {}
	end

    function self.registerAction(playerAction)
		if activeBarIndex ~= nil then
			table.insert(playerActions, playerAction)
		end
    end

	-- combo format:
	-- [1] skillIndex
	-- [2] boundID
	-- [3] delay
	-- [4] lightAttackRegistered
	-- [5] lightAttackConfirmed
	-- [6] lightAttackQueued
	-- [7] skillCastTime
	-- [8] barIndex
	-- [9] bashed
	function self.getLastCombos(numCombos)
		local combos = {}
		local skillCastTime, skillIndex, boundID, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, duration, bashed = nil,0,0,false,false,false,0,false
		local combo = nil
		local playerAction
		local n = #playerActions
		while n > 0 do
			playerAction = playerActions[n]
			if playerAction[PA_IDX_SLOT_ID] > ACTION_SKILL_OFFSET then
				if skillCastTime ~= nil then
					combo = {skillIndex, boundID, skillCastTime - playerAction[PA_IDX_TIME] - duration, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, skillCastTime, playerAction[PA_IDX_BAR_INDEX], bashed}
					table.insert(combos, combo)
					if #combos >= numCombos then
						break
					end
				end
				skillCastTime = playerAction[PA_IDX_TIME]
				skillIndex    = playerAction[PA_IDX_SLOT_ID] - ACTION_SKILL_OFFSET
				boundID       = playerAction[PA_IDX_BOUND_ID]
				duration      = math.max((playerAction[PA_IDX_CAST_TIME] or 0) + (playerAction[PA_IDX_CHANNEL_TIME] or 0), settings.GCD)

				lightAttackRegistered = false
				lightAttackConfirmed  = false
				lightAttackQueued     = false
				bashed                = playerAction[PA_IDX_BASH]
			elseif playerAction[PA_IDX_SLOT_ID] == ACTION_LIGHT_ATTACK then
				lightAttackRegistered = true
				lightAttackConfirmed  = playerAction[PA_IDX_LA_CONFIRMED]
				lightAttackQueued     = playerAction[PA_IDX_LA_QUEUED]
			end
			n = n - 1
		end
		if #combos < numCombos then
			if playerActions ~= nil and playerActions[n] ~= nil then
				playerAction = playerActions[n]
				combo = {skillIndex, boundID, 0, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, skillCastTime, playerAction[PA_IDX_BAR_INDEX], bashed}
				table.insert(combos, combo)
			end
		end

		return combos
	end

	-- player action format:
	-- [1] time
	-- [2] activeBarIndex
	-- [3] slotId
	-- [4] boundId
	-- [5] channeled
	-- [6] castTime
	-- [7] channelTime
	-- [8] (unused)
	-- [9] LA cast confirmed
	-- [10] LA queued
	-- [11] bash
    function self.slotUsed(slotId)
		local t = GetGameTimeMilliseconds()
		local boundId = GetSlotBoundId(slotId)
		local channeled, castTime, channelTime = GetAbilityCastInfo(boundId)
		local action = {t, activeBarIndex, slotId, boundId, channeled, castTime, channelTime, 0, false, false, false}
		self.registerAction(action)
	end

	function self.confirmLightAttack()
		local t = GetGameTimeMilliseconds()
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][PA_IDX_TIME] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][PA_IDX_SLOT_ID] == ACTION_LIGHT_ATTACK then
				playerActions[n][PA_IDX_LA_CONFIRMED] = true
				break
			end
			n = n - 1
		end
	end

	function self.flagLightAttackQueued()
		local t = GetGameTimeMilliseconds()
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][PA_IDX_TIME] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][PA_IDX_SLOT_ID] == ACTION_LIGHT_ATTACK then
				playerActions[n][PA_IDX_LA_QUEUED] = true
				break
			end
			n = n - 1
		end
	end

	function self.confirmBash()
		local t = GetGameTimeMilliseconds()
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][PA_IDX_TIME] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][PA_IDX_SLOT_ID] > ACTION_SKILL_OFFSET then
				playerActions[n][PA_IDX_BASH] = true
				break
			end
			n = n - 1
		end
	end

	function self.weaponSwap(activeWeaponPair)
		if skillBarIndex == nil then
			if activeWeaponPair == 2 then
				skillBarIndex = {[1]= 0, [2]= 1}
				activeBarIndexReversed = false
			else
				skillBarIndex = {[1]= 1, [2]= 0}
				activeBarIndexReversed = true
			end
		end
		activeBarIndex = skillBarIndex[activeWeaponPair]
	end

	function self.SetHighLatencyMode(enabled)
		if enabled then
			settings.lightAttackTimeout = HIGH_LATENCY_TIMEOUT_MS
		else
			settings.lightAttackTimeout = NORMAL_LATENCY_TIMEOUT_MS
		end
	end

	return self
end