
WeaveDelayLog = {}
function WeaveDelayLog.new()
    local self = {}
    local playerActions = {}
	local initTime = GetGameTimeMilliseconds()
	
	local timerLastLightAttack  = initTime
	local timerLastSkill        = initTime
	local timerLastSkillEndTime = initTime
	local lastSkillSlotId       = 0
	
	-- index for weapon bar, 0 is the one active when addon is loaded
	local lastSkillBarIndex     = 0
	local activeBarIndex        = 0
	local activeBarIndexReversed = false
	local skillBarIndex         = nil
	
	local settings = {}
	settings.GCD = 1000
	settings.delaySkillLightAttackMax = 2500
	settings.delayLightAttackSkillMax = 2500
	settings.delayBetweenSkillsMax    = 2500
	settings.lightAttackTimeout       = 1000
	
    local statistics = {}
	local combatEndMarkerPosition = -1
	
	-- those durations are not taken from the ones provided by esoui events
	local customAbilityActiveTimes = {
		[40382]  = 19500.0,
		[103706] = 36000.0,
		[61919]  = 40000.0,
		[35434]  = 20000.0,
		[39095]  = 23000.0,
		[40058]  = 12000.0,
		[40094]  = 8000.0,
		[40079]  = 10000.0,
		[115093] = 7500.0,
		[85850] = 8000.0,
		[86031] = 10000.0,
		[118639] = 12000.0,
		[39475] = 12000.0,
		[42056] = 15000.0,
		[40328] = 15000.0,
		[38256] = 15000.0,
		[20944] = 14000.0,
		[38264] = 12000.0,
		[20251] = 4000.0,
		[39105] = 10000.0,
		[36508] = 6000.0,
		[86156] = 5000.0,
		[86130] = 24000.0,
		[86045] = 6000.0,
		[46324] = 4000.0,
		[36935] = 20000.0,
		[36957] = 10000.0,
		[11870] = 12000.0,
		[86027] = 10000.0,
		[40457] = 11000.0,
		[20930] = 14000.0,
		[20660] = 14000.0,
		[40317] = 1000660.0,
		[386606] = 10000.0,
		[38839] = 10000.0,
		[26869] = 10000.0,
	}
	
	local abilityActiveTimes = {}
	for k, v in pairs(customAbilityActiveTimes) do
		abilityActiveTimes[k] = v
	end

	-- this might register shortly after the first skill(s), so only remove everything unitl last combat end marker
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
	
	-- save a combat end marker
	function self.endCombat()
		combatEndMarkerPosition = #playerActions
	end
	
	function self.reset()
		playerActions = {}
		
		statistics = {}
		statistics.delaySinceLastSkill = {}
		statistics.delaySinceLastLightAttack = {}
		statistics.missedLightAttacksBefore = {}
		statistics.missedLightAttacksAfter = {}
		
		statistics.delayS1_x_LA_S2 = {}
		statistics.delayS1_LA_x_S2 = {}
		statistics.delayS1_x_S2 = {}
		statistics.missingLightAttacksS1_x_S2 = {}
		statistics.transitionsS1_x_S2 = {}
		for i=1,12 do
			table.insert(statistics.delayS1_x_LA_S2, {})
			table.insert(statistics.delayS1_LA_x_S2, {})
			table.insert(statistics.delayS1_x_S2, {})
			table.insert(statistics.missingLightAttacksS1_x_S2, {})
			table.insert(statistics.transitionsS1_x_S2, {})
			for j=1,12 do
				table.insert(statistics.delayS1_x_LA_S2[i], {})
				table.insert(statistics.delayS1_LA_x_S2[i], {})
				table.insert(statistics.delayS1_x_S2[i], {})
				table.insert(statistics.missingLightAttacksS1_x_S2[i], -1)
				table.insert(statistics.transitionsS1_x_S2[i], 0)
			end
		end

		for barIndex = 0, 1 do
			statistics.delaySinceLastSkill[barIndex] = {}
			statistics.delaySinceLastLightAttack[barIndex] = {}
			statistics.missedLightAttacksBefore[barIndex] = {}
			statistics.missedLightAttacksAfter[barIndex] = {}
			for slotIndex = 1, 8 do
				statistics.delaySinceLastSkill[barIndex][slotIndex] = {}
				statistics.delaySinceLastLightAttack[barIndex][slotIndex] = {}
				statistics.missedLightAttacksBefore[barIndex][slotIndex] = {}
				statistics.missedLightAttacksAfter[barIndex][slotIndex] = {}
			end
		end
		
	
	end
	
	function self.getDelayS1_x_S2(i,j)
		if #statistics.delayS1_x_S2[i][j] > 0 then
			local sum = 0.0
			for k=1,#statistics.delayS1_x_S2[i][j] do
				sum = sum + statistics.delayS1_x_S2[i][j][k]
			end
			sum = sum / #statistics.delayS1_x_S2[i][j]
			return sum
		else
			return nil
		end
	end
	
	function self.getMissingLightAttacksS1_x_S2(i,j)
		return statistics.missingLightAttacksS1_x_S2[i][j]
	end

	function self.getTransitionsS1_x_S2(i,j)
		return statistics.transitionsS1_x_S2[i][j]
	end

	
	function self.getMean(tbl, historySize)
		local endIndex = #tbl
		if endIndex < 1 then
			return 0, 0
		end
		local startIndex = endIndex-historySize
		if startIndex < 1 then
			startIndex = 1
		end
		local sum = 0
		for i = startIndex, endIndex do
			sum = sum + tbl[i]
		end
		if endIndex-startIndex > 0 then
			return sum/(endIndex-startIndex+1.0), endIndex-startIndex+1
		else
			return 0,0
		end
	end
	
	function self.getMeanDelaySinceLastSkill(barIndex, slotId, historySize)
		local v,n
		if barIndex ~= nil then
			if statistics.delaySinceLastSkill[barIndex] ~= nil and statistics.delaySinceLastSkill[barIndex][slotId] ~= nil then
				v,n = self.getMean(statistics.delaySinceLastSkill[barIndex][slotId], historySize)
			else
				v,n = 0,0
			end
		else
			return 0,1
		end
			
		return v,n
	end
	
	function self.getMeanDelaySinceLastLightAttack(barIndex, slotId, historySize)
		if barIndex ~= nil then
			local v,n = self.getMean(statistics.delaySinceLastLightAttack[barIndex][slotId], historySize)
			return v,n
		else
			return 0,1
		end
	end
	
	function self.getMissedLightAttacksBefore(barIndex, slotId, historySize)
		if barIndex ~= nil then
			local v,n = self.getMean(statistics.missedLightAttacksBefore[barIndex][slotId], historySize)
			return math.floor(0.1+v*n)
		else
			return 0,1
		end
	end
	
	function self.getMissedLightAttacksAfter(barIndex, slotId, historySize)
		if barIndex ~= nil then
			local v,n = self.getMean(statistics.missedLightAttacksAfter[barIndex][slotId], historySize)
			return math.floor(0.1+v*n)
		else
			return 0,1
		end
	end
	
	function self.getUptime(barIndex, slotId, historySize)
		if barIndex ~= nil and #playerActions > 0 then
			
			local i = #playerActions
			local numberOfCasts = 0
			local t_now = playerActions[#playerActions][1]
			local t = t_now
			local t_active = 0
			local t_firstCast = 0
			
			local t_maxIntervall = 100000
			
			while i>0 and numberOfCasts < historySize do
				local t_, barIndex_, slotId_, boundId_, channeled_, castTime_, channelTime_, activeTime_ = unpack(playerActions[i])
				if t_now - t_ > t_maxIntervall then
					break
				end
				if barIndex_ == barIndex and slotId_ == slotId then
					numberOfCasts = numberOfCasts + 1
					t_firstCast = t_
					t_active = t_active + math.min(t - t_, castTime_ + channelTime_ + activeTime_)
					t = t_
				end
			    i = i - 1
			end
			local uptime = math.min(math.max(math.floor(100 * t_active / (t_now - t_firstCast)),0),100)
			if t_firstCast == 0 or numberOfCasts < 2 then
				uptime = 0
			end
			return uptime
		else
			return 0
		end
	end
	
    function self.getLastAction()
        if #playerActions > 0 then
	        return playerActions[#playerActions]
	    else
			return nil
		end
    end
	
	function self.isSkill(slotId)
		return slotId ~= nil and (slotId > 2)
	end
	
	function self.isLightAttack(slotId)
		return slotId ~= nil and  (slotId == 1)
	end
	
	function self.isSkill(slotId)
		return slotId ~= nil and  (slotId > 2)
	end
	
	
	function self.isHeavyAttack(slotId)
		return slotId ~= nil and (slotId == 2)
	end
   
    function self.registerAction(playerAction)
        local t, barIndex, slotId, boundId, channeled, castTime, channelTime, activeTime, confirmed, queued = unpack(playerAction)
		if activeBarIndex ~= nil then
			-- LIGHT ATTACK
			-- -> display time since last skill cast+duration in bottom bar
			if self.isLightAttack(slotId) then
				timerLastLightAttack = t
				
				local delta = math.floor(t - timerLastSkillEndTime)
				if lastSkillBarIndex ~= nil and delta < settings.delaySkillLightAttackMax and lastSkillSlotId > 0 then
					table.insert(statistics.delaySinceLastSkill[lastSkillBarIndex][lastSkillSlotId], delta)
				end
				
			-- SKILL
			-- -> display time since last light attack in top bar
			elseif self.isSkill(slotId) then
				local duration = castTime + channelTime
				if duration < settings.GCD then
					duration = settings.GCD
				end
				
				local delta2 = math.floor(t - timerLastSkillEndTime)
				
				timerLastSkill          = t
				timerLastSkillEndTime = t + duration
				lastSkillSlotId         = slotId
				lastSkillBarIndex      = barIndex
				
				local delta = t - timerLastLightAttack
				local lightAttackMissed = false
				if delta < settings.delayLightAttackSkillMax then
					table.insert(statistics.delaySinceLastLightAttack[activeBarIndex][slotId], delta)
				end
				
				-- detect missing light attacks
				local previousAction = self.getLastAction()
				if previousAction ~= nil then
					local previousTime , previousBarIndex, previousSlotId, _, _, _, _, _ = unpack(previousAction)
					if previousBarIndex ~= nil and activeBarIndex ~= nil then
						if (t - previousTime) < settings.delayBetweenSkillsMax and self.isSkill(previousSlotId) then
							table.insert(statistics.missedLightAttacksAfter[previousBarIndex][previousSlotId], 1)
							table.insert(statistics.missedLightAttacksBefore[activeBarIndex][slotId], 1)
							lightAttackMissed = true
						else
							table.insert(statistics.missedLightAttacksAfter[previousBarIndex][previousSlotId], 0)
							table.insert(statistics.missedLightAttacksBefore[activeBarIndex][slotId], 0)
						end
					end
				end
				
			end
			table.insert(playerActions, playerAction)
		end
		
    end

	-- can be used to correct abilityId logged at time of key press based on combat event occurring later
	function self.updateAbilityIdMatchingTime(matchingTime, matchingTimeTolerance, abilityId, toAbilityId)
		local n = #playerActions
		while n > 0 do
			local playerAction = playerActions[n]
			if playerAction[1] < matchingTime - matchingTimeTolerance then
				break
			end
			if playerAction[1] < matchingTime + matchingTimeTolerance and playerAction[4] == abilityId then
				playerActions[n][4] = toAbilityId
				break
			end
			n = n - 1
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
	-- [8] duration
	-- [9] bashed
	function self.getLastCombos(numCombos)
		local combos = {}
		local skillCastTime, skillIndex, boundID, skillDelay, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, duration, bashed = nil,0,0,0,false,false,false,0,false
		local combo = nil
		local playerAction
		local n = #playerActions
		while n > 0 do
			playerAction = playerActions[n]
			if playerAction[3] > 2 then
				if skillCastTime ~= nil then
					combo = {skillIndex, boundID, skillCastTime - playerAction[1] - duration, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, skillCastTime, playerAction[2], bashed}
					table.insert(combos, combo)
					if #combos >= numCombos then
						break
					end
				end
				skillCastTime = playerAction[1]
				skillIndex    = playerAction[3] - 2
				boundID       = playerAction[4]
				duration      = math.max(playerAction[6] + playerAction[7], settings.GCD)

				lightAttackRegistered = false
				lightAttackConfirmed  = false
				lightAttackQueued     = false
				bashed                = playerAction[11]
			elseif playerAction[3] == 1 then
				lightAttackRegistered = true
				lightAttackConfirmed  = playerAction[9]
				lightAttackQueued     = playerAction[10]
			end
			n = n - 1
		end
		if #combos < numCombos then
			if playerActions ~= nil and playerActions[n] ~= nil then
				playerAction = playerActions[n]
				combo = {skillIndex, boundID, 0, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, skillCastTime, playerAction[2], bashed}
				table.insert(combos, combo)
			end
		end
		
		return combos
	end
	
	-- combat
	-- player action format:
	-- [1] time
	-- [2] activeBarIndex
	-- [3] slotId
	-- [4] boundId
	-- [5] channeled
	-- [6] castTime
	-- [7] channelTime
	-- [8] activeTime
	-- [9] LA cast
	-- [10] LA queued
	-- [11] bash
    function self.slotUsed(slotId)
		local t = GetGameTimeMilliseconds()
		local boundId = GetSlotBoundId(slotId)
		local channeled, castTime, channelTime = GetAbilityCastInfo(boundId)
		local activeTime = -1
		if abilityActiveTimes[boundId] ~= nil then
			activeTime = abilityActiveTimes[boundId]
		end
		local action = {t, activeBarIndex, slotId, boundId, channeled, castTime, channelTime, activeTime, false, false, false}
		self.registerAction(action)
	end
	
	function self.confirmLightAttack()
		local t = GetGameTimeMilliseconds() 
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][1] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][3] == 1 then
				playerActions[n][9] = true
				break
			end
			n = n - 1
		end
	end
	
	function self.flagLightAttackQueued()
		local t = GetGameTimeMilliseconds() 
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][1] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][3] == 1 then
				playerActions[n][10] = true
				break
			end
			n = n - 1
		end
	end
	
	function self.confirmBash()
		local t = GetGameTimeMilliseconds() 
		local n = #playerActions
		while n > 0 do
			if t - playerActions[n][1] > settings.lightAttackTimeout then
				break
			end
			if playerActions[n][3] > 2 then
				playerActions[n][11] = true
				break
			end
			n = n - 1
		end
	end
	
	function self.updateAbilityDuration(abilityId, activeTime)
		if customAbilityActiveTimes[abilityId] ~= nil then
			return
		end
		
		if abilityActiveTimes[abilityId] == nil then
			for i=1,#playerActions do
				if playerActions[i][4] == abilityId and playerActions[i][8] < 0 then
					playerActions[i][8] = activeTime
				end
			end
			abilityActiveTimes[abilityId] = -1
		end
		abilityActiveTimes[abilityId] = activeTime
	end
	
	function self.weaponSwap(activeWeaponPair)
	    -- first weapon swap
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
	
	function self.getActiveBarIndex()
		return activeBarIndex
	end
	
	function self.getActiveWeaponPair()
		if skillBarIndex == nil then
			return nil
		else
			if activeBarIndex ~= nil then
				if not activeBarIndexReversed then
					return 1 + activeBarIndex
				else
					return 2 - activeBarIndex
				end
			else
				return nil
			end
		end
	end
	
	function self.SetHighLatencyMode(enabled)
	if enabled then
		settings.lightAttackTimeout = 1600
	else
		settings.lightAttackTimeout = 1000
	end
end
	
	return self
end