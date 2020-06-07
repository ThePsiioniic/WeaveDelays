
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
	
    local statistics = {}
	
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
	
	function self.analyze()
	
		--local t, barIndex, slotId, boundId, channeled, castTime, channelTime = unpack(playerAction)
		
		local lastSkillTime = -1
		local lastSkillEndTime = -1
		local lastSkillBarIndex = -1
		local lastSkillSlotId = -1
		
		local lastActionType = -1
		
		for i=1,#playerActions do
			local t, barIndex, slotId, boundId, channeled, castTime, channelTime = unpack(playerActions[i])
			
			if self.isLightAttack(slotId) then
				lastActionType = 1
			elseif self.isSkill(slotId) then
				if lastActionType == 1 and lastSkillTime > 0 then
					local delta = t - lastSkillEndTime
					
					local skillIndex = 1
					if (activeBarIndexReversed and lastSkillBarIndex == 0) or (not activeBarIndexReversed and lastSkillBarIndex == 1) then
						skillIndex = skillIndex + 6
					end
					skillIndex = skillIndex + (lastSkillSlotId-3)
					
					local skillIndexNew = 1
					if (activeBarIndexReversed and barIndex == 0) or (not activeBarIndexReversed and barIndex == 1) then
						skillIndexNew = skillIndexNew + 6
					end
					skillIndexNew = skillIndexNew + (slotId-3)
					if skillIndex > 0 and skillIndex < 13 and skillIndexNew > 0 and skillIndexNew < 13 then
						table.insert(statistics.delayS1_x_S2[skillIndex][skillIndexNew], delta)
					end
					
					if statistics.missingLightAttacksS1_x_S2[skillIndex] ~= nil and statistics.missingLightAttacksS1_x_S2[skillIndex][skillIndexNew] ~= nil then
						if statistics.missingLightAttacksS1_x_S2[skillIndex][skillIndexNew] < 0 then
							statistics.missingLightAttacksS1_x_S2[skillIndex][skillIndexNew] = 0
						end		
					end		
					
					if lastSkillTime > 0 then
						if statistics.transitionsS1_x_S2[skillIndex] ~= nil and statistics.transitionsS1_x_S2[skillIndex][skillIndexNew] ~= nil then
							statistics.transitionsS1_x_S2[skillIndex][skillIndexNew] = statistics.transitionsS1_x_S2[skillIndex][skillIndexNew] + 1	
						end		
					end			
					
				elseif lastActionType == 2 then

					local skillIndex = 1
					if (activeBarIndexReversed and lastSkillBarIndex == 0) or (not activeBarIndexReversed and lastSkillBarIndex == 1) then
						skillIndex = skillIndex + 6
					end
					skillIndex = skillIndex + (lastSkillSlotId-3)
					
					local skillIndexNew = 1
					if (activeBarIndexReversed and barIndex == 0) or (not activeBarIndexReversed and barIndex == 1) then
						skillIndexNew = skillIndexNew + 6
					end
					skillIndexNew = skillIndexNew + (slotId-3)
					
					if statistics.missingLightAttacksS1_x_S2[skillIndex] ~= nil and statistics.missingLightAttacksS1_x_S2[skillIndex][skillIndexNew] ~= nil then
						if statistics.missingLightAttacksS1_x_S2[skillIndex][skillIndexNew] < 0 then
							statistics.missingLightAttacksS1_x_S2[skillIndex][skillIndexNew] = 0
						end
						statistics.missingLightAttacksS1_x_S2[skillIndex][skillIndexNew] = statistics.missingLightAttacksS1_x_S2[skillIndex][skillIndexNew] + 1
					end
					
					if lastSkillTime > 0 then
						if statistics.transitionsS1_x_S2[skillIndex] ~= nil and statistics.transitionsS1_x_S2[skillIndex][skillIndexNew] ~= nil then
							statistics.transitionsS1_x_S2[skillIndex][skillIndexNew] = statistics.transitionsS1_x_S2[skillIndex][skillIndexNew] + 1	
						end		
					end
				end
				
				
				lastSkillBarIndex = barIndex
				lastSkillSlotId = slotId
				lastSkillTime = t
				local duration = castTime + channelTime
				if duration < settings.GCD then
					duration = settings.GCD
				end
				lastSkillEndTime = t + duration
				lastActionType = 2
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
        local t, barIndex, slotId, boundId, channeled, castTime, channelTime = unpack(playerAction)

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
		    timerLastSkill          = t
			timerLastSkillEndTime = t + duration
			lastSkillSlotId         = slotId
			lastSkillBarIndex      = barIndex
			
			local delta = t - timerLastLightAttack
			if delta < settings.delayLightAttackSkillMax then
			    table.insert(statistics.delaySinceLastLightAttack[activeBarIndex][slotId], delta)
			end
			
			-- detect missing light attacks
			local previousAction = self.getLastAction()
			if previousAction ~= nil then
				local previousTime , previousBarIndex, previousSlotId, _, _, _, _ = unpack(previousAction)
				if previousBarIndex ~= nil and activeBarIndex ~= nil then
					if (t - previousTime) < settings.delayBetweenSkillsMax and self.isSkill(previousSlotId) then
						table.insert(statistics.missedLightAttacksAfter[previousBarIndex][previousSlotId], 1)
						table.insert(statistics.missedLightAttacksBefore[activeBarIndex][slotId], 1)
					else
						table.insert(statistics.missedLightAttacksAfter[previousBarIndex][previousSlotId], 0)
						table.insert(statistics.missedLightAttacksBefore[activeBarIndex][slotId], 0)
					end
				end
			end
		end

		if activeBarIndex ~= nil then
			table.insert(playerActions, playerAction)
		end
		
    end
   
    function self.slotUsed(slotId)
	   local t = GetGameTimeMilliseconds() 
	   local boundId = GetSlotBoundId(slotId)
	   local channeled, castTime, channelTime = GetAbilityCastInfo(boundId)
       local action = {t, activeBarIndex, slotId, boundId, channeled, castTime, channelTime}
	   self.registerAction(action)
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
	
	return self
end