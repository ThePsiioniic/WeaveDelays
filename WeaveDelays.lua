WeaveDelays = WeaveDelays or { }
local WeaveDelays = WeaveDelays
local self = WeaveDelays

self.name                = 'WeaveDelays'
self.slash               = "/weavedelays"
self.version             = "0.8.6"
self.DefaultSavedVars    = {["accountWide"]=false,["delayBarOffsetX"]=300,["delayBarOffsetY"]=400,["delayBarAlpha"]=0.9,["delayBar2OffsetX"]=300,["delayBar2OffsetY"]=500,["numDelayBarSlots"]=10,["numDelayBarRows"]=1,["showDelayBar"]=true,["showAbilityRecastBar"]=false,["showSkillsInDelayBar"]=true,["showDelayBarOnlyInCombat"]=false,["showDelayBarAfterCombat"]=10,["unlockUI"]=false,["showActionBarAddon"]=true,["showActionBarUptimes"]=true,["abilityRecastBarFontFace"]="ZoFontGamepad25",["abilityRecastBarNumSlots"]=10,["fontFaceList"]={},["actionBarFontFace"]="ZoFontGameSmall",["delayBarFontFace"]="ZoFontGameSmall",["delayBarPalette"]="greenred",["abilityDurations"]={[20660]=14000,[20779]=20000,[20930]=14000,[21729]=14000,[21765]=6000,[22240]=20000,[22095]=10000,[22259]=12000,[23205]=10000,[23213]=23000,[23231]=15000,[24165]=40000,[24328]=6000,[26768]=10000,[26869]=10000,[32673]=6000,[32710]=18000,[32853]=15000,[35434]=20000,[36049]=12000,[36891]=20000,[36935]=20000,[36957]=10000,[36967]=20000,[38660]=10000,[38689]=14000,[38695]=10000,[38839]=10000,[38906]=10000,[39053]=10000,[39073]=10000,[39095]=23000,[39475]=15000,[40058]=12000,[40079]=8000,[40094]=8000,[40317]=10000,[40328]=10000,[40382]=18000,[40452]=12000,[40457]=12000,[40465]=16000,[41958]=30000,[42028]=10000,[42038]=8000,[50079]=10000,[61500]=8000,[61919]=40000,[61927]=60000,[86019]=6500,[86031]=10000,[86058]=25000,[103706]=36000,[117850]=10000,[118008]=12000,[118726]=16000},["textLightAttackMissed"]="M",["textLightAttackDisappeared"]="X",["textLightAttackQueued"]="Q",["textBashed"]="B",["abilityRecastBarAlpha"]=0.9,["abilityRecastBarUpdateInterval"]=200,["compatibilityRaiseDefaultUIHealthBar"]=0,["compatibilityRepositionDefaultUIHealthBar"]=true,["compatibilityDetectBandits"]=true,["compatibilityDetectADR"]=true,["compatibilityDetectFAB"]=true,["actionBarRaiseTopBar"]=0,["showActionBarBottomBar"]=true,["frontBarSkills"]={nil,nil,nil,nil,nil,nil},["backBarSkills"]={nil,nil,nil,nil,nil,nil},["delayBarFrameR"]=0.8,["delayBarFrameG"]=0.8,["delayBarFrameB"]=0.8,["delayBarFrameA"]=1.0,["recastBarFrameR"]=0.8,["recastBarFrameG"]=0.8,["recastBarFrameB"]=1.0,["recastBarFrameA"]=1.0,["itemSetMechanicalAcuity"]=true,["acuityFrameR"]=0.1,["acuityFrameG"]=0.1,["acuityFrameB"]=0.9,["acuityFrameA"]=1.0,["scale"]=50.0,["recastBarScale"]=50.0,["delayBarFrameThickness"]=1,["recastBarFrameThickness"]=1,["highLatencyMode"]=false}
self.displayTimeMax      = 999
self.displayTimeMin      = -99.
self.historySize 	     = 99999
self.historySizeInCombat = 5
self.playerName          = GetRawUnitName("player")
self.visible             = false
self.abilityRecastBarSpammableText = " -"

-- combat
self.inCombat           = false
self.combatCounter      = 0
self.lastSkillTime      = GetGameTimeMilliseconds()
self.frontBarSkills     = {}
self.backBarSkills      = {}

-- compatibility
self.banditsFound                = false
self.actionDurationReminderFound = false
self.fancyActionBarFound         = false

-- UI
self.controlRightLabelOffsetX   = 0.6
self.controlBoxHeight           = 0.33
self.controlBoxWidth            = 0.95
self.controlTopLabelOffsetY     = -3
self.controlRightLabelOffsetY   = -4
self.barMarkerScale             = 450

-- fixes
self.textureCache = {}
self.textureCache[114716] = "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds" -- crystal fragments
self.textureCache[61930]  = "/esoui/art/icons/ability_rogue_058.dds"                  -- assassins will

-- constants
self.abilityIdBash = 21970

self.abilityPriorities = {
	[117850] = 100,
	[39053] = 1000,
	[118726] = 500,
	[40457] = 50,
	[40382] = 18000,
	[118008] = 12000,
	[42028] = 9000,
	[117749] = 2900,
	[40465] = 16000,
	}
self.trackedAbilities = {}

	
self.palettes = {
	["uptime"] = {
		[1] = {0,         0, 1.0, 1.0},
		[2] = {80.0,   60.0, 1.0, 1.0},
		[3] = {101.0, 180.0, 1.0, 1.0}
	},
	["delay"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  90.0, 1.0, 1.0},
		[4] = {100,  60.0, 1.0, 1.0},
		[5] = {150,  33.0, 1.0, 1.0},
		[6] = {200,  18.0, 1.0, 1.0},
		[7] = {400,  10.0, 1.0, 1.0},
		[8] = {9999,  0.0, 1.0, 1.0}
	},
	["greenred"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  90.0, 1.0, 1.0},
		[4] = {100,  60.0, 1.0, 1.0},
		[5] = {150,  33.0, 1.0, 1.0},
		[6] = {200,  18.0, 1.0, 1.0},
		[7] = {400,  10.0, 1.0, 1.0},
		[8] = {9999,  1.0, 1.0, 1.0},
	},
	["greenred2"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  120.0, 1.0, 1.0},
		[4] = {100,  90.0, 1.0, 1.0},
		[5] = {150,  60.0, 1.0, 1.0},
		[6] = {200,  30.0, 1.0, 1.0},
		[7] = {400,  20.0, 1.0, 1.0},
		[8] = {9999,  0.0, 1.0, 1.0}
	},
	["greenredpink"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  90.0, 1.0, 1.0},
		[4] = {100,  60.0, 1.0, 1.0},
		[5] = {150,  33.0, 1.0, 1.0},
		[6] = {200,  18.0, 1.0, 1.0},
		[7] = {400,  10.0, 1.0, 1.0},
		[8] = {950,  1.0, 1.0, 1.0},
		[9] = {1000,  300.0, 1.0, 1.0},
		[10] = {9999,  310.0, 1.0, 1.0}
	},
	["rainbow"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  120.0, 1.0, 1.0},
		[4] = {100,  90.0, 1.0, 1.0},
		[5] = {150,  60.0, 1.0, 1.0},
		[6] = {200,  30.0, 1.0, 1.0},
		[7] = {250,  0.0, 1.0, 1.0},
		[8] = {300,  330.0, 1.0, 1.0},
		[9] = {400,  270.0, 1.0, 1.0},
		[10] = {950,  240.0, 1.0, 1.0},
		[11] = {1000,  300.0, 1.0, 1.0},
		[12] = {9999,  320.0, 1.0, 1.0},
	},
	["purplegreenyellow"] = {
		[1] = {-9999, 265.0, 0.63, 0.14},
		[2] = {0,    263.0, 0.79, 0.25},
		[3] = {50,  235.0, 0.61, 0.41},
		[4] = {100,  198.0, 0.63, 0.45},
		[5] = {150,  172.0, 0.68, 0.44},
		[6] = {200,  139.0, 0.68, 0.72},
		[7] = {250,  67.0 , 0.75, 0.77},
		[8] = {450,  49.0, 0.97, 1.0},
		[9] = {950,  40.0, 1.0, 1.0},
		[10] = {1000,  10.0, 1.0, 1.0},
		[11] = {9999,  0.0, 1.0, 1.0},
	},
	
}
function WeaveDelays.Reset()
	self.log.reset()
	self.frontBarSkills = {}
	self.backBarSkills = {}
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 UI
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays_ToggleWindow()
	self.visible = not self.visible
	if self.visible then
		self.ShowDelayBar()
	else
		self.HideDelayBar()
	end
end

function WeaveDelays.ShowDelayBar()
	self.visible = true
	self.UpdateDelayBarVisibility()
end

function WeaveDelays.HideDelayBar()
	self.visible = false
	self.UpdateDelayBarVisibility()
end

function WeaveDelays.HideDelayBarIfNotInCombat(counter)
	if self.savedVariables.showDelayBarOnlyInCombat then
		if not self.inCombat and counter >= self.combatCounter then
			self.visible = false
			self.UpdateDelayBarVisibility()
		end
	end
end

function WeaveDelays.UpdateDelayBarVisibility()
	local reticleHidden = IsReticleHidden()
	if reticleHidden and not self.savedVariables.unlockUI then
		if self.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(true)
		end
		if self.savedVariables.showAbilityRecastBar then
			WEAVEDELAYSBAR2:SetHidden(true)
		end
	elseif reticleHidden and self.savedVariables.unlockUI and not self.visible then
		if self.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(true)
		end
		if self.savedVariables.showAbilityRecastBar then
			WEAVEDELAYSBAR2:SetHidden(true)
		end
	elseif not reticleHidden then
		if self.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(not self.visible)
		end
		if self.savedVariables.showAbilityRecastBar then
			WEAVEDELAYSBAR2:SetHidden(not self.visible)
		end
	end
end

function WeaveDelaysSaveDelayBarPosition()
	self.savedVariables.delayBarOffsetX = WEAVEDELAYSBAR:GetLeft()
	self.savedVariables.delayBarOffsetY = WEAVEDELAYSBAR:GetTop()
end


function WeaveDelays.restoreDelayBarPosition()
	WEAVEDELAYSBAR:ClearAnchors()
	WEAVEDELAYSBAR:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.savedVariables.delayBarOffsetX, self.savedVariables.delayBarOffsetY)
end

function WeaveDelaysSaveDelayBar2Position()
	self.savedVariables.delayBar2OffsetX = WEAVEDELAYSBAR2:GetLeft()
	self.savedVariables.delayBar2OffsetY = WEAVEDELAYSBAR2:GetTop()
end

function WeaveDelays.restoreDelayBar2Position()
	WEAVEDELAYSBAR2:ClearAnchors()
	WEAVEDELAYSBAR2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.savedVariables.delayBar2OffsetX, self.savedVariables.delayBar2OffsetY)
end

function WeaveDelays.OnReticleHiddenUpdate()
	WeaveDelays.UpdateDelayBarVisibility()

end

function WeaveDelays.updateAbilityRecastBarFontFace()
	local ctl
	for i=1, self.savedVariables.abilityRecastBarNumSlots do
		ctl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSBAR2T"..i)
		ctl:SetFont(self.savedVariables.abilityRecastBarFontFace)
	end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 helper functions
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.SetColor(c, delay, n, palette)
	if palette == nil then
		palette = "greenred"
	end
	if c ~= nil then
		if n > 0 then
			local h,s,v = self.GetPaletteColor(self.palettes[palette], delay)
			local r,g,b = HSVToRGB(h,s,v)
			c:SetColor(r, g, b, 1.0)
		elseif delay == -1 then
			c:SetColor(0.8,0.8,0.8,0.4)
		else
			c:SetColor(1.0,1.0,1.0,0.2)
		end
	end
end

function WeaveDelays.SetColorN(c, s)
	if c ~= nil then
		if s > 20 then
			c:SetColor(1.0,0.0,0.0,1.0)
		elseif s > 10 then
			c:SetColor(0.8,0.2,0.0,1.0)
		elseif s > 5 then
			c:SetColor(0.8,0.6,0.2,1.0)
		elseif s > 4 then
			c:SetColor(0.7,0.7,0.2,1.0)
		elseif s > 3 then
			c:SetColor(0.4,0.9,0.2,1.0)
		elseif s > 1 then
			c:SetColor(0.3,1.0,0.0,1.0)
		elseif s > 0 then
			c:SetColor(0.1,1.0,0.4,1.0)
		elseif s == 0 then
			c:SetColor(0.1,0.2,0.8,0.3)
		else
			c:SetColor(0.8,0.8,0.8,0.4)
		end
	end
end

function WeaveDelays.GetPaletteColor(p, v)
	local nPoints = #p
	for i=1,nPoints-1 do
		if v > p[i][1] and v <= p[i+1][1] then
			local r = (v-p[i][1])/(p[i+1][1]-p[i][1])
			local deltaH = (p[i+1][2]-p[i][2])
			if deltaH > 180.0 then
				deltaH = deltaH - 360.0
			end
			local h = p[i][2]+r*deltaH
			if h < 0 then
				h = h + 360.0
			end
			return h,p[i][3]+r*(p[i+1][3]-p[i][3]),p[i][4]+r*(p[i+1][4]-p[i][4])
		end
	end
	return 0,0,0
end

function WeaveDelays.SetColorR(c, s)
	if c ~= nil then
		if s > 0 then
			local h,s,v = self.GetPaletteColor(self.palettes["uptime"], s)
			local r,g,b = HSVToRGB(h,s,v)
			c:SetColor(r,g,b,1.0)
		else
			c:SetColor(0.8,0.8,0.8,0.4)
		end
	end
end

function HSVToRGB(h,s,v)
	if s == 0 then
		return v
	end
	local c = math.floor( h / 60 );
	local d = ( h / 60 ) - c;
	local p = v * ( 1 - s );
	local q = v * ( 1 - s * d );
	local t = v * ( 1 - s * ( 1 - d ) );
	if c == 0 then
		return v, t, p
	elseif c == 1 then
		return q, v, p
	elseif c == 2 then
		return p, v, t
	elseif c == 3 then
		return p, q, v
	elseif c == 4 then
		return t, p, v
	elseif c == 5 then
		return v, p, q
	end
end


function WeaveDelays.ClipRange(s, s_min, s_max)
	return math.max(math.min(s, s_max), s_min)
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function WeaveDelays.getFontFaceList()
	if #self.savedVariables.fontFaceList < 1 then
		local fonts = {}
		local k, v
		for k, v in zo_insecurePairs(_G) do
			if(type(v) == "userdata" and v.GetFontInfo) then
				table.insert(fonts, k)
			end
		end
		table.sort(fonts)
		self.savedVariables.fontFaceList = fonts
	end
	return self.savedVariables.fontFaceList
end

function WeaveDelays.getPalettesList()
	local palettes = {}
	table.insert(palettes, "greenred")
	table.insert(palettes, "greenred2")
	table.insert(palettes, "rainbow")
	table.insert(palettes, "greenredpink")
	table.insert(palettes, "purplegreenyellow")
	return palettes
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 string formatting
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.FormatTimeMilliseconds(timeMilliseconds)
	if timeMilliseconds ~= nil then
		return ""..math.floor(timeMilliseconds)
	else
		return "-"
	end
end

function WeaveDelays.FormatTimePercent(timePercent)
	if timePercent ~= nil then
		return ""..math.floor(timePercent).."%"
	else
		return "-"
	end
end


function WeaveDelays.FormatTimeSeconds(timeMilliseconds)
	if timeMilliseconds < 10000 then
		return ""..math.floor(timeMilliseconds*0.01)*0.1
	else
		return ""..math.floor(timeMilliseconds*0.001)
	end
	
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 draw UI
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function WeaveDelays.UiLoop()
	if self.inCombat then
		self.UpdateAbilityRecastBar()
	end
end


function WeaveDelays.Update(fullCombat)
	self.UpdateActionBar(fullCombat)
	self.UpdateDelayBar()
	self.UpdateAbilityRecastBar()
end

function WeaveDelays.UpdateActionBar(fullCombat)

	-- actionBar
	local historySize = self.savedVariables.numDelayBarSlots * self.savedVariables.numDelayBarRows
	if fullCombat ~= nil and fullCombat then
		historySize = self.historySize
    end
	
	local combos = self.log.getLastCombos(historySize)
	
	local activeBarIndex = self.log.getActiveBarIndex()
	
	local delays = {}
	local missedLightAttacks = {}
	local missedLightAttacksAfterSkill = {}

	for i = 1, ACTION_BAR_SLOTS_PER_PAGE do
		table.insert(delays, {})
		table.insert(missedLightAttacks, 0)
		table.insert(missedLightAttacksAfterSkill, 0)
	end
		
	-- analysis
	for i=1,#combos do
		local combo = combos[i]
		if combo[8] == activeBarIndex then
			if combo[3] < 2500 then
				table.insert(delays[combo[1]], combo[3])
			end
			if (not combo[4] or not combo[5]) and not (i==1) then
				missedLightAttacks[combo[1]] = missedLightAttacks[combo[1]] + 1
			end
		end
		
		if combos[i+1] ~= nil and combos[i+1][8] == activeBarIndex and (not combo[4] or not combo[5]) then
			missedLightAttacksAfterSkill[combos[i+1][1]] = missedLightAttacksAfterSkill[combos[i+1][1]] + 1
		end
			
	end
	
	-- action bar
	for i = 1, ACTION_BAR_SLOTS_PER_PAGE do
	
		local uptime = self.log.getUptime(activeBarIndex, ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+i, historySize)
		self.SetColorR(self.slotTopBar2[i], uptime)
		self.slotTop2LeftLabel[i]:SetText(self.FormatTimePercent(uptime))
		
		local meanDelay, n_total = self.log.getMean(delays[i], #delays[i])
		self.slotTopLeftLabel[i]:SetText(self.FormatTimeMilliseconds(self.ClipRange(meanDelay, self.displayTimeMin, self.displayTimeMax)))
		
		self.slotTopRightLabel[i]:SetText(tostring(missedLightAttacks[i]))
		self.slotBottomRightLabel[i]:SetText(tostring(missedLightAttacksAfterSkill[i]))
		
		self.slotBottomLeftLabel[i]:SetText("")
		
		self.SetColor(self.slotTopBar[i], meanDelay, n_total)
		self.SetColor(self.slotBottomBar[i], meanDelay, n_total)

	end
end

function WeaveDelays.UpdateDelayBar()

	if not self.savedVariables.showDelayBar then
		return
	end
	
	-- delay bar
	local bg = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARBG')
	local n  = self.savedVariables.numDelayBarSlots * self.savedVariables.numDelayBarRows
	
	local lastCombos 
	
	if historySize == n then
		lastCombos = combos
	else
		lastCombos = self.log.getLastCombos(n)
	end
	
	local gameTime = GetGameTimeMilliseconds() 

	
	for i = 1, n do
		local barBox     = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARL'..i)
		local barMarker  = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARB'..i)
		local barPicture = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARS'..i)
		local barStatusFlag = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARQ'..i)
		
		if barBox ~= nil then
			if lastCombos[n+1-i] ~= nil then
				local combo             = lastCombos[n+1-i]
				local lightAttackMissed = not (combo[4] and combo[5])
				local t                 = combo[3]
				
				if combo[7]~= nil and gameTime - combo[7] > 100 then
					if not lightAttackMissed then
						if combo[9] then
							barStatusFlag:SetText(self.savedVariables.textBashed)
						else
							barStatusFlag:SetText("")
						end
					elseif not combo[4] then
						barStatusFlag:SetText(self.savedVariables.textLightAttackMissed)
					elseif combo[6] then
						barStatusFlag:SetText(self.savedVariables.textLightAttackQueued)
					else
						barStatusFlag:SetText(self.savedVariables.textLightAttackDisappeared)
					end
				else
					barStatusFlag:SetText("")
				end
				
				if lightAttackMissed ~= nil and lightAttackMissed then
					barMarker:SetColor(1.0,1.0,1.0,0.0)
				else
					barMarker:SetColor(1.0,1.0,1.0,1.0)
				end
				
				t = math.max(math.min(t,950),1)
				
				if lightAttackMissed ~= nil and lightAttackMissed then
					t = 1000
				end
				
				if combo[7]~= nil and gameTime - combo[7] > 100 then
					self.SetColor(barBox, t, 1, self.savedVariables.delayBarPalette)
				else
					barBox:SetColor(1.0,1.0,1.0,0.1)
				end
				
				barMarker:SetAnchor(TOPLEFT, barBox, TOPLEFT, math.ceil(math.min(t,self.barMarkerScale) * self.savedVariables.scale * 0.002), -math.ceil(0.08*self.savedVariables.scale))
				
				if self.savedVariables.showSkillsInDelayBar then
					local boundId  = combo[2]
					barPicture:SetColor(1.0,1.0,1.0,1.0)
					barPicture:SetTexture(self.GetTextureFromAbilityId(boundId))
				end
			else
				barMarker:SetColor(1.0,1.0,1.0,0.2)
				barBox:SetColor(1.0,1.0,1.0,0.2)
				if self.savedVariables.showSkillsInDelayBar then
					barPicture:SetTexture(nil)
					barPicture:SetColor(1.0,1.0,1.0,0.1)
				end
				barStatusFlag:SetText("")
			end
		end
	end
end

function WeaveDelays.GetRemainingGlobalCooldownMilliseconds()
	return 1000 - zo_min(GetGameTimeMilliseconds() - self.lastSkillTime, 1000)
end


-- t = gametime in seconds
function WeaveDelays.AcuityProcIsActiveAt(t)
	if self.savedVariables.itemSetMechanicalAcuity then
		-- buff active
		if self.acuityProcBeginTime ~= nil and self.acuityProcEndTime ~= nil then
			if t > self.acuityProcBeginTime and t < self.acuityProcEndTime then
				return true
			end
		end
		-- buff will be activated again after direct damage
		if self.acuityProcCooldownEndTime ~= nil and t > self.acuityProcCooldownEndTime and t < self.acuityProcCooldownEndTime + 5.0 then
			return true
		end
	end
	return false
end

function WeaveDelays.UpdateAbilityRecastBar()

	if not self.savedVariables.showAbilityRecastBar then
		return
	end
	
	-- tracked ability bar
	local gameTime = GetGameTimeMilliseconds() 
	local bg = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2BG')
	
	local abilityIndex = 1
	local abilitiesSortedByPriority = {}
	local abilitiesTimeoutPassed = {}
	for k,v in pairs(self.trackedAbilities) do
		table.insert(abilitiesSortedByPriority, {k,v[1]})
		table.insert(abilitiesSortedByPriority, {k,v[1]+v[2]})
	end
	table.sort(abilitiesSortedByPriority, function(a,b) return a[2] < b[2] end)
	
	local minimumTimeToNextCast = self.GetRemainingGlobalCooldownMilliseconds()

	for i,p in ipairs(abilitiesSortedByPriority) do
		local abilityId, abilityTimeout = unpack(p)
		
		-- if cast has already been missed at the next possible slot, suppress future casts
		if abilitiesTimeoutPassed[abilityId] == nil then
			local abilityIcon  = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2S'..abilityIndex)
			local abilityTimer = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2T'..abilityIndex)
			local abilityFrame = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2B'..abilityIndex)
			
			local timeToCast = abilityTimeout-gameTime
			local t0 = timeToCast-(abilityIndex-1)*1000
			-- can fit a spammable before it needs to be recasted!
			while t0 > 1000 do
				abilityIcon:SetTexture(nil)
				abilityIcon:SetColor(1.0,1.0,1.0,0.2)
				abilityTimer:SetColor(1.0,1.0,1.0,1.0)
				abilityTimer:SetText(self.abilityRecastBarSpammableText)
				-- TODO: estimate real delay between skills and time of next cast
				if self.AcuityProcIsActiveAt((gameTime+minimumTimeToNextCast)*0.001 + (abilityIndex-1)) then
					abilityFrame:SetEdgeColor(self.savedVariables.acuityFrameR,self.savedVariables.acuityFrameG,self.savedVariables.acuityFrameB,self.savedVariables.acuityFrameA)
				else
					abilityFrame:SetEdgeColor(1.0,1.0,1.0,0.0)
				end
				abilityIndex = abilityIndex + 1
				if abilityIndex > self.savedVariables.abilityRecastBarNumSlots then 
					break
				end
				abilityIcon  = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2S'..abilityIndex)
				abilityTimer = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2T'..abilityIndex)
				abilityFrame = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2B'..abilityIndex)
				t0 = t0 - 1000
			end
			if abilityIndex > self.savedVariables.abilityRecastBarNumSlots then 
				break
			end
			if timeToCast > 0 or abilitiesTimeoutPassed[abilityId] == nil then
				abilityIcon:SetColor(1.0,1.0,1.0,1.0)
				abilityIcon:SetTexture(self.GetTextureFromAbilityId(abilityId))
				if timeToCast < 0 then
					abilityTimer:SetText(""..math.floor((timeToCast)*0.001))
					abilityTimer:SetColor(1.0,0.0,0.0,1.0)
					abilitiesTimeoutPassed[abilityId] = true
				else
					abilityTimer:SetText(""..math.floor((timeToCast)*0.01)*0.1)
					abilityTimer:SetColor(1.0,1.0,1.0,1.0)
				end
				
				-- TODO: estimate real delay between skills and time of next cast
				if self.AcuityProcIsActiveAt((gameTime+minimumTimeToNextCast)*0.001 + (abilityIndex-1)) then
					abilityFrame:SetEdgeColor(self.savedVariables.acuityFrameR,self.savedVariables.acuityFrameG,self.savedVariables.acuityFrameB,self.savedVariables.acuityFrameA)
				else
					abilityFrame:SetEdgeColor(1.0,1.0,1.0,0.0)
				end
			
				abilityIndex = abilityIndex + 1
			end
			

		end
		if abilityIndex > self.savedVariables.abilityRecastBarNumSlots then 
			break
		end
	end
	while abilityIndex <= self.savedVariables.abilityRecastBarNumSlots do
		local abilityIcon  = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2S'..abilityIndex)
		local abilityTimer = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2T'..abilityIndex)
		local abilityFrame = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2B'..abilityIndex)
		abilityIcon:SetTexture(nil)
		abilityIcon:SetColor(1.0,1.0,1.0,0.1)
		abilityTimer:SetText("")
		-- TODO: estimate real delay between skills and time of next cast
		if self.AcuityProcIsActiveAt((gameTime+minimumTimeToNextCast)*0.001 + (abilityIndex-1)) then
			abilityFrame:SetEdgeColor(self.savedVariables.acuityFrameR,self.savedVariables.acuityFrameG,self.savedVariables.acuityFrameB,self.savedVariables.acuityFrameA)
		else
			abilityFrame:SetEdgeColor(1.0,1.0,1.0,0.0)
		end
		abilityIndex = abilityIndex + 1
	end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 combat events
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.OnCombatEvent(eventCode,  result, isError,  abilityName,  abilityGraphic,  abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,  powerType,  damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	if abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK and sourceName == self.playerName then
		if result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or results == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL then
			self.log.confirmLightAttack()
			self.Update()
		elseif result == ACTION_RESULT_QUEUED then
			self.log.flagLightAttackQueued()
		end
	end
	if abilityActionSlotType == ACTION_SLOT_TYPE_BLOCK and abilityId == self.abilityIdBash and (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE) and sourceName == self.playerName then
		self.log.confirmBash()
		self.Update()
	end
end

function WeaveDelays.EventEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if sourceType == COMBAT_UNIT_TYPE_PLAYER then
		if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_FADED or changeType == EFFECT_RESULT_UPDATED then
			local matched = false
			for i =1,#self.frontBarSkills do
				if self.frontBarSkills[i] == abilityId then
					matched = true
					break
				end
			end
			for i =1,#self.backBarSkills do
				if self.backBarSkills[i] == abilityId then
					matched = true
					break
				end
			end
			if matched and (endTime - beginTime) > 0 then	
				self.log.updateAbilityDuration(abilityId, 1000 * (endTime - beginTime))
			end
		end
	end
end

function WeaveDelays.playerActionSlotAbilityUsed(e, slotId)
	local t = GetGameTimeMilliseconds()
	self.lastSkillTime = t
	self.log.slotUsed(slotId)
	if self.inCombat then
		self.Update()
	end
	local abilityId = GetSlotBoundId(slotId)
	if self.savedVariables.abilityDurations[abilityId] ~= nil and self.savedVariables.abilityDurations[abilityId] > 0 then
		self.trackedAbilities[abilityId] = {t + self.savedVariables.abilityDurations[abilityId], self.savedVariables.abilityDurations[abilityId]}
	end

end

function WeaveDelays.UpdateBarAssignement()
	self.frontBarSkills = {}
	self.backBarSkills = {}
	for i=1,ACTION_BAR_SLOTS_PER_PAGE do
		table.insert(self.frontBarSkills, GetSlotBoundId(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+i, HOTBAR_CATEGORY_PRIMARY))
		table.insert(self.backBarSkills, GetSlotBoundId(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+i, HOTBAR_CATEGORY_BACKUP))
	end
	self.savedVariables.frontBarSkills = self.frontBarSkills
	self.savedVariables.backBarSkills = self.backBarSkills
end

function WeaveDelays.OnWeaponSwap(_, activeWeaponPair, locked)
	self.log.weaponSwap(activeWeaponPair)
	if self.inCombat then
		self.UpdateActionBar()
		self.UpdateDelayBar()
	else
		self.UpdateActionBar(true)
	end
	if #self.frontBarSkills < 1 or #self.backBarSkills < 1 then
		self.UpdateBarAssignement()
	end

	if self.fancyActionBarFound then
		local slot = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+1).slot
		local fwidth,fheight = slot:GetDimensions()
		local topBarOffsetHeight = -self.savedVariables.actionBarRaiseTopBar
		local bottomBarOffsetHeight = 0
		if activeWeaponPair == 2 then
			topBarOffsetHeight = topBarOffsetHeight - fheight - 4
		else
			bottomBarOffsetHeight = bottomBarOffsetHeight + fheight + 4
		end
		self.top2Label:SetAnchor(BOTTOMLEFT, slot, TOPLEFT,-1.1*fwidth, topBarOffsetHeight+self.controlTopLabelOffsetY-fheight*self.controlBoxHeight)
		self.topLabel:SetAnchor(BOTTOMLEFT, slot, TOPLEFT,-1.1*fwidth, topBarOffsetHeight+self.controlTopLabelOffsetY+2)
		self.bottomLabel:SetAnchor(TOPLEFT, slot, BOTTOMLEFT,-1.1*fwidth, bottomBarOffsetHeight)
		for i = 1, ACTION_BAR_SLOTS_PER_PAGE do
			slot = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+i).slot
			local width,height = slot:GetDimensions()
			height = height * self.controlBoxHeight
			width  = width  * self.controlBoxWidth
			
			if i == ACTION_BAR_SLOTS_PER_PAGE then
				topBarOffsetHeight = -self.savedVariables.actionBarRaiseTopBar - 4
				bottomBarOffsetHeight = 0
			end
			
			self.slotTopBar[i]:SetAnchor(BOTTOMLEFT, slot,TOPLEFT,0,topBarOffsetHeight-1)
			self.slotTopLeftLabel[i]:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,1,topBarOffsetHeight+self.controlTopLabelOffsetY)
			self.slotTopRightLabel[i]:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,width*self.controlRightLabelOffsetX,topBarOffsetHeight+self.controlRightLabelOffsetY)
			self.slotTopBar2[i]:SetAnchor(BOTTOMLEFT, slot,TOPLEFT,0,topBarOffsetHeight-1-height-2)
			self.slotTop2LeftLabel[i]:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,1,topBarOffsetHeight+self.controlTopLabelOffsetY-height-2)
			self.slotTop2RightLabel[i]:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,width*self.controlRightLabelOffsetX,topBarOffsetHeight+self.controlRightLabelOffsetY-height-2)

			self.slotBottomBar[i]:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,0,bottomBarOffsetHeight+1)
			self.slotBottomLeftLabel[i]:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,1,bottomBarOffsetHeight-2)
			self.slotBottomRightLabel[i]:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,width*self.controlRightLabelOffsetX,bottomBarOffsetHeight-2)
		end
	end
end

function WeaveDelays.OnPlayerCombatState(event, inCombat)
	if inCombat and not self.inCombat then
		self.inCombat = inCombat
		self.enterCombat()
	elseif not inCombat and self.inCombat then
		self.Update(true)
		self.inCombat = inCombat
		self.leaveCombat()
	end
end

function WeaveDelays.enterCombat()
	self.log.startCombat()
	self.Update()
	if self.savedVariables.showDelayBarOnlyInCombat then
		WeaveDelays.ShowDelayBar()
	end
end

function WeaveDelays.leaveCombat()
	self.log.endCombat()
	self.trackedAbilities = {}
	
	if self.savedVariables.showDelayBarOnlyInCombat then
		self.combatCounter = self.combatCounter + 1
		local counter = self.combatCounter
		if self.visible then
			zo_callLater(function () WeaveDelays.HideDelayBarIfNotInCombat(counter) end, 50 + self.savedVariables.showDelayBarAfterCombat*1000)
		end
	end
		
end

function WeaveDelays.GetAbilityIndexFromAbilityId(abilityId)
    local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
    if hasProgression then
		local _, morph, rank = GetAbilityProgressionInfo(progressionIndex)
        local name, texture, abilityIndex = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)
		return abilityIndex
	else
	    return 0
    end
end


function WeaveDelays.GetTextureFromAbilityId(abilityId)
	if abilityId == nil then
		return nil
	end
	if self.textureCache[abilityId] ~= nil then
		return self.textureCache[abilityId]
	else
		local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
		if hasProgression then
			local _, morph, rank = GetAbilityProgressionInfo(progressionIndex)
			local name, texture, abilityIndex = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)
			self.textureCache[abilityId] = texture
			return texture
		else
			return 0
		end
	end
end

function WeaveDelays.GetAbilityIndicesFromAbilityId(abilityId)
    local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
    if not hasProgression then
        return false
    end
    local skillType, skillLineIndex, skillIndex = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
    if skillType > 0 then 
        return skillType, skillLineIndex, skillIndex
	else
		return false
	end
end

function WeaveDelays.PlayerIsWearingAcuity()
	local numEquipped = 0
	_, _, _, numEquipped = GetItemLinkSetInfo("|H1:item:131165:370:50:26582:370:50:0:0:0:0:0:0:0:0:1:26:1:1:0:9400:0|h|h", true)
	return numEquipped>2
end

function WeaveDelays.DetectAcuity()
	if self.PlayerIsWearingAcuity() then
		EVENT_MANAGER:RegisterForEvent(self.name.."AcuityProc",  EVENT_EFFECT_CHANGED, self.HandleAcuityProc)
		EVENT_MANAGER:AddFilterForEvent(self.name.."AcuityProc", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 99204)
		EVENT_MANAGER:AddFilterForEvent(self.name.."AcuityProc", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	else
		EVENT_MANAGER:UnregisterForEvent(self.name.."AcuityProc", EVENT_EFFECT_CHANGED)
		self.acuityProcBeginTime = nil
		self.acuityProcEndTime = nil
	end
end

function WeaveDelays.HandleAcuityProc(_, changeType, _, _, _, beginTime, endTime)
	if changeType == EFFECT_RESULT_GAINED then
		self.acuityProcBeginTime = beginTime
		self.acuityProcEndTime = endTime
	elseif changeType == EFFECT_RESULT_FADED then
		self.acuityProcCooldownEndTime = GetGameTimeMilliseconds()/1000 + 16
	end
end


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 init
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays:LoadSavedVariables()
	self.characterSavedVariables = ZO_SavedVars:NewCharacterNameSettings("WeaveDelaysVars", 1, nil, self.DefaultSavedVars)
	if self.characterSavedVariables.accountWide then
		self.accountWideSavedVariables = ZO_SavedVars:NewAccountWide("WeaveDelaysVars", 1, nil, self.DefaultSavedVars)
		self.savedVariables = self.accountWideSavedVariables
		self.savedVariables.accountWide = true
	else
		self.savedVariables = self.characterSavedVariables
	end
end

function WeaveDelays.UpdateActionBarVisibility()
	local showDelays    = self.savedVariables.showActionBarAddon
	local showUptimes   = self.savedVariables.showActionBarUptimes
	local showBottomBar = self.savedVariables.showActionBarBottomBar
	
	self.topLabel:SetHidden(not showDelays)
	for _, v in ipairs(self.slotTopBar) do
		v:SetHidden(not showDelays)
	end
	for _, v in ipairs(self.slotTopLeftLabel) do
		v:SetHidden(not showDelays)
	end
	for _, v in ipairs(self.slotTopRightLabel) do
		v:SetHidden(not showDelays)
	end
	
	self.top2Label:SetHidden(not showUptimes)
	for _, v in ipairs(self.slotTopBar2) do
		v:SetHidden(not showUptimes)
	end
	for _, v in ipairs(self.slotTop2LeftLabel) do
		v:SetHidden(not showUptimes)
	end
	for _, v in ipairs(self.slotTop2RightLabel) do
		v:SetHidden(not showUptimes)
	end
	
	self.bottomLabel:SetHidden(not showBottomBar)
	for _, v in ipairs(self.slotBottomBar) do
		v:SetHidden(not showBottomBar)
	end
	for _, v in ipairs(self.slotBottomLeftLabel) do
		v:SetHidden(not showBottomBar)
	end
	for _, v in ipairs(self.slotBottomRightLabel) do
		v:SetHidden(not showBottomBar)
	end

end

function WeaveDelays:Initialize()
	WeaveDelays:LoadSavedVariables()
	self.frontBarSkills = self.savedVariables.frontBarSkills
	self.backBarSkills = self.savedVariables.backBarSkills
	
	-- turn off automatic detection of other addons
	if not self.savedVariables.compatibilityDetectBandits then
		self.banditsFound = false
	end
	if not self.savedVariables.compatibilityDetectADR then
		self.actionDurationReminderFound = false
	end
	if not self.savedVariables.compatibilityDetectFAB then
		self.fancyActionBarFound = false
	end
	
	if self.savedVariables.numDelayBarSlots == nil or self.savedVariables.numDelayBarSlots < 1 then
		self.savedVariables.numDelayBarSlots = 1
	end
	self.log = WeaveDelayLog.new()
	self.log.reset()
	
	-- Events
	EVENT_MANAGER:RegisterForEvent(self.name.."playerActionSlotAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED, self.playerActionSlotAbilityUsed)
	EVENT_MANAGER:RegisterForEvent(self.name.."WeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, self.OnWeaponSwap)
	EVENT_MANAGER:RegisterForEvent(self.name.."PlayerCombatState", EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(self.name.."EventEffectChanged", EVENT_EFFECT_CHANGED, self.EventEffectChanged)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnCombatEvent)
	EVENT_MANAGER:RegisterForEvent(self.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, self.OnReticleHiddenUpdate)
	EVENT_MANAGER:RegisterForUpdate("WeaveDelaysUiLoop", self.savedVariables.abilityRecastBarUpdateInterval, self.UiLoop)

    ACTION_BAR_ASSIGNMENT_MANAGER:RegisterCallback("SlotUpdated", function(hotbarCategory, actionSlotIndex, isChangedByPlayer)
		zo_callLater(function () self.UpdateBarAssignement() end, 500)
    end)

	-- Controls
	self.slotTopBar = {}
	self.slotTopBar2 = {}
	self.slotBottomBar = {}
	self.slotTopLeftLabel = {}
	self.slotTopRightLabel = {}
	self.slotTop2LeftLabel = {}
	self.slotTop2RightLabel = {}
	self.slotBottomLeftLabel = {}
	self.slotBottomRightLabel = {}

	-- shift top bar if bandits is found
	if self.savedVariables.compatibilityDetectBandits and BUI and BUI.Vars then
		self.banditsFound = true
	end

	local topBarOffsetHeight = -self.savedVariables.actionBarRaiseTopBar
	if self.actionDurationReminderFound then
		local slot = ZO_ActionBar_GetButton(3).slot
		local width,height = slot:GetDimensions()
		topBarOffsetHeight = topBarOffsetHeight-height
	elseif self.banditsFound then
		local slot = ZO_ActionBar_GetButton(3).slot
		local width,height = slot:GetDimensions()
		topBarOffsetHeight = topBarOffsetHeight-height/2
	end

	local drawTier = DT_HIGH
	local drawLevel = 5
	local slot = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+1).slot
	local width,height = slot:GetDimensions()
	height = height * self.controlBoxHeight
	width  = width  * self.controlBoxWidth

	self.top2Label =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
	self.top2Label:SetFont(self.savedVariables.actionBarFontFace)
	self.top2Label:SetDimensions(width, height)
	self.top2Label:SetDrawTier(drawTier)
	self.top2Label:SetDrawLayer(drawLevel+1)
	self.top2Label:SetText("uptime")
	self.top2Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	self.top2Label:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,-1.1*width,topBarOffsetHeight+self.controlTopLabelOffsetY-height)

	self.topLabel =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
	self.topLabel:SetFont(self.savedVariables.actionBarFontFace)
	self.topLabel:SetDimensions(width, height)
	self.topLabel:SetDrawTier(drawTier)
	self.topLabel:SetDrawLayer(drawLevel+1)
	self.topLabel:SetText("delay")
	self.topLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	self.topLabel:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,-1.1*width,topBarOffsetHeight+self.controlTopLabelOffsetY+2)

	self.bottomLabel = WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
	self.bottomLabel:SetDimensions(width, height)
	self.bottomLabel:SetFont(self.savedVariables.actionBarFontFace)
	self.bottomLabel:SetDrawTier(drawTier)
	self.bottomLabel:SetDrawLayer(drawLevel+1)
	self.bottomLabel:SetText("")
	self.bottomLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	self.bottomLabel:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,-1.1*width,0)

	for i = 1, ACTION_BAR_SLOTS_PER_PAGE do
		slot = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+i).slot
		
		width,height = slot:GetDimensions()
		height = height * self.controlBoxHeight
		width  = width  * self.controlBoxWidth
		local t1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
		t1:SetDimensions(width, height)
		t1:SetDrawTier(drawTier)
		t1:SetDrawLayer(drawLevel)
		t1:SetColor(1.0,1.0,1.0,0.2)
		t1:SetAnchor(BOTTOMLEFT, slot,TOPLEFT,0,topBarOffsetHeight-1)
		table.insert(self.slotTopBar, t1)
		
		local lt1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lt1:SetFont(self.savedVariables.actionBarFontFace)
		lt1:SetDimensions(width, height)
		lt1:SetDrawTier(drawTier)
		lt1:SetDrawLayer(drawLevel+1)
		lt1:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,1,topBarOffsetHeight+self.controlTopLabelOffsetY)
		table.insert(self.slotTopLeftLabel, lt1)
		
		local ltw1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		ltw1:SetFont(self.savedVariables.actionBarFontFace)
		ltw1:SetDimensions(width*(1.0-self.controlRightLabelOffsetX), height)
		ltw1:SetDrawTier(drawTier)
		ltw1:SetDrawLayer(drawLevel+1)
		ltw1:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,width*self.controlRightLabelOffsetX,topBarOffsetHeight+self.controlRightLabelOffsetY)
		table.insert(self.slotTopRightLabel, ltw1)
		
		local t2 = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
		t2:SetDimensions(width, height)
		t2:SetDrawTier(drawTier)
		t2:SetDrawLayer(drawLevel)
		t2:SetColor(1.0,1.0,1.0,0.2)
		t2:SetAnchor(BOTTOMLEFT, slot,TOPLEFT,0,topBarOffsetHeight-1-height-2)
		table.insert(self.slotTopBar2, t2)
		
		local lt2 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lt2:SetFont(self.savedVariables.actionBarFontFace)
		lt2:SetDimensions(width, height)
		lt2:SetDrawTier(drawTier)
		lt2:SetDrawLayer(drawLevel+1)
		lt2:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,1,topBarOffsetHeight+self.controlTopLabelOffsetY-height-2)
		table.insert(self.slotTop2LeftLabel, lt2)
		
		local ltw2 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		ltw2:SetFont(self.savedVariables.actionBarFontFace)
		ltw2:SetDimensions(width*(1.0-self.controlRightLabelOffsetX), height)
		ltw2:SetDrawTier(drawTier)
		ltw2:SetDrawLayer(drawLevel+1)
		ltw2:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,width*self.controlRightLabelOffsetX,topBarOffsetHeight+self.controlRightLabelOffsetY-height-2)
		table.insert(self.slotTop2RightLabel, ltw2)
		
		local b1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
		b1:SetDimensions(width, height)
		b1:SetDrawTier(drawTier)
		b1:SetDrawLayer(drawLevel)
		b1:SetColor(1.0,1.0,1.0,0.2)
		b1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,0,1)
		table.insert(self.slotBottomBar, b1)

		local lb1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lb1:SetDimensions(width, height)
		lb1:SetFont(self.savedVariables.actionBarFontFace)
		lb1:SetDrawTier(drawTier)
		lb1:SetDrawLayer(drawLevel+1)
		lb1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,1,-2)
		table.insert(self.slotBottomLeftLabel, lb1)
		
		local lbw1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lbw1:SetFont(self.savedVariables.actionBarFontFace)
		lbw1:SetDimensions(width*(1.0-self.controlRightLabelOffsetX), height)
		lbw1:SetDrawTier(drawTier)
		lbw1:SetDrawLayer(drawLevel+1)
		lbw1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,width*self.controlRightLabelOffsetX,-2)
		table.insert(self.slotBottomRightLabel, lbw1)
		
	end

	ZO_CreateStringId("SI_BINDING_NAME_WD_TOGGLE", "Toggle WeaveDelays window")

	-- compatibility with other addons/default UI
	self.repositionHealthBar()

	--- delay bar
	local bg = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARBG')
	local n = self.savedVariables.numDelayBarSlots
	local r = self.savedVariables.numDelayBarRows
	local w = self.savedVariables.scale
	local m = 2
	local h = 2+math.ceil(w*0.4)

	if self.savedVariables.showSkillsInDelayBar then
		h = h + w + 3
	end

	if self.savedVariables.showDelayBar then
		self.restoreDelayBarPosition()
		WEAVEDELAYSBAR:SetDimensions((w+m)*n+2, h*r)
		bg:SetDimensions((w+m)*n+2, h*r)
		
		if not self.savedVariables.showDelayBarOnlyInCombat then
			self.visible = true
		else
			self.visible = false
		end
		WeaveDelays.UpdateDelayBarVisibility()
		
		bg:SetAlpha(self.savedVariables.delayBarAlpha)
		
		local textureControl,markerTextureControl,skillTextureControl,labelControl
		local k=1
		for j=1, r do
			for i=1, n do
				textureControl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBARL"..k, bg, CT_TEXTURE)
				textureControl:SetDimensions(w, math.ceil(w*0.28))
				textureControl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, math.max(math.ceil(w/10.0),1)+(j-1)*h)
				textureControl:SetColor(1.0,1.0,1.0,0.2)
				markerTextureControl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBARB"..k, bg, CT_TEXTURE)
				markerTextureControl:SetDimensions(math.max(math.ceil(w/10.0),1), math.ceil(w*0.4))
				markerTextureControl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, math.max(math.ceil(w*0.02),1)+(j-1)*h)
				markerTextureControl:SetColor(1.0,1.0,1.0,0.3)
				if self.savedVariables.showSkillsInDelayBar then
					skillTextureControl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBARS"..k, bg, CT_TEXTURE)
					skillTextureControl:SetDimensions(w, w)
					skillTextureControl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, math.max(math.ceil(w*0.4),1)+(j-1)*h)
					skillTextureControl:SetColor(1.0,1.0,1.0,0.1)
				end
				labelControl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBARQ"..k, bg, CT_LABEL)
				labelControl:SetFont(self.savedVariables.delayBarFontFace)
				labelControl:SetDimensions(math.ceil(w*0.28), math.ceil(w*0.28))
				labelControl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+math.max(math.ceil(w*0.7),1), math.max(math.ceil(w*0.08),1)+(j-1)*h)
				k = k+1
			end
		end
	end

	--- ability recast bar 

	if self.savedVariables.showAbilityRecastBar then
		self.restoreDelayBar2Position()
		
		w = self.savedVariables.recastBarScale
	    m = 2
		n = self.savedVariables.abilityRecastBarNumSlots
		WEAVEDELAYSBAR2:SetDimensions((w+m)*n+2, 1.08*w)

		local bg = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2BG')
		for i=1, self.savedVariables.abilityRecastBarNumSlots do
		
			local b = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBAR2B"..i, bg, CT_BACKDROP)
			
			b:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, w*0.04)
			b:SetDimensions(w, w)
			b:SetCenterColor(0, 0, 0, 0)
			b:SetEdgeTexture('', 1, 1, 6)
			b:SetEdgeColor(0, 0, 0, 0)
			b:SetDrawLevel(1)
			
			ctl3 = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBAR2S"..i, b, CT_TEXTURE)
			ctl3:SetDimensions(w, w)
			ctl3:SetAnchor(CENTER, b, CENTER, 0, 0)
			ctl3:SetColor(1.0,1.0,1.0,0.1)
			
			ctl4 = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBAR2T"..i, bg, CT_LABEL)
			ctl4:SetDimensions(w, w)
			ctl4:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+w*0.02, w*0.04)
			ctl4:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			ctl4:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

		end
		self.updateAbilityRecastBarFontFace()
		
		WEAVEDELAYSBAR2BG:SetAlpha(self.savedVariables.abilityRecastBarAlpha)
	end

	self.UpdateUIcustomizations()
	self.UpdateDelayBarVisibility()
	self.UpdateActionBarVisibility()
	zo_callLater(function () self.UpdateBarAssignement() end, 500)

	--- menu
	self.InitializeMenu()

	if self.fancyActionBarFound then
		local activeWeaponPair = GetActiveWeaponPairInfo()
		WeaveDelays.OnWeaponSwap(nil, activeWeaponPair, false)
	end


	--- mechanical acuity set
	zo_callLater(function () WeaveDelays.DetectAcuity()	 end, 1500)
	EVENT_MANAGER:RegisterForEvent(self.name.."DetectAcuity", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.DetectAcuity)
	EVENT_MANAGER:AddFilterForEvent(self.name.."DetectAcuity", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	
	--- compatibility settings
	self.log.SetHighLatencyMode(self.savedVariables.highLatencyMode)

end

function WeaveDelays.UpdateUIcustomizations()
	WEAVEDELAYSBARBG:SetEdgeColor(self.savedVariables.delayBarFrameR,self.savedVariables.delayBarFrameG,self.savedVariables.delayBarFrameB,self.savedVariables.delayBarFrameA)
	WEAVEDELAYSBAR2BG:SetEdgeColor(self.savedVariables.recastBarFrameR,self.savedVariables.recastBarFrameG,self.savedVariables.recastBarFrameB,self.savedVariables.recastBarFrameA)
	
	WEAVEDELAYSBARBG:SetEdgeTexture(nil, 1, 1, self.savedVariables.delayBarFrameThickness, 0) 
	WEAVEDELAYSBAR2BG:SetEdgeTexture(nil, 1, 1, self.savedVariables.recastBarFrameThickness, 0)
end

function WeaveDelays.repositionHealthBar()

	if self.savedVariables.compatibilityRepositionDefaultUIHealthBar then
	
		local raiseBy = self.savedVariables.compatibilityRaiseDefaultUIHealthBar		
		local slot = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+1).slot
		local width,height = slot:GetDimensions()
		
		if not self.banditsFound then
			raiseBy = raiseBy + 0.5*height
		end
		
		if self.actionDurationReminderFound then
			raiseBy = raiseBy + height
		end
		
		if raiseBy ~= 0 then
			local _, point, relativeTo, relativePoint, offsetX, offsetY = ZO_PlayerAttributeHealth:GetAnchor(0)
			if self.defaultUIHealtBarOffsetX == nil then
				self.defaultUIHealtBarOffsetX = offsetX
				self.defaultUIHealtBarOffsetY = offsetY
			end
			ZO_PlayerAttributeHealth:SetAnchor(point, relativeTo, relativePoint, self.defaultUIHealtBarOffsetX, self.defaultUIHealtBarOffsetY-raiseBy)
		end
		
	end
end

function WeaveDelays.updateTooltip(c, abilityId)
	if abilityId == nil or abilityId == 0 then
        if c.text == nil then return end
        ClearTooltip(c.text)
        c.text:SetHidden(true)
        c.text = nil
	else
		local skillType, skillLineIndex, skillIndex = WeaveDelays.GetAbilityIndicesFromAbilityId(abilityId)
		if skillType and skillLineIndex and skillIndex then
			c.text = SkillTooltip
			InitializeTooltip(c.text,c,TOPRIGHT,0,0,TOPLEFT)
			c.text:SetSkillAbility(skillType, skillLineIndex, skillIndex)
			c.text:SetHidden(false)
		end
	end
end

function WeaveDelays.callUpdateSkillsInMenu(p)
	zo_callLater(function () WeaveDelays.updateSkillsInMenu(p) end, 500)
end

function WeaveDelays.updateSkillsInMenu(p)
	if p.data.name == self.name then
		if #self.frontBarSkills > 0 then
			for i=1,5 do
				if self.frontBarSkills[i] ~= nil then
					local tc = _G["weaveDelays_arb_fbT"..tostring(i)]
					local sc = _G["weaveDelays_arb_fbS"..tostring(i)]
					if tc ~= nil then
						tc.texture:SetTexture(self.GetTextureFromAbilityId(self.frontBarSkills[i]))
						if self.savedVariables.abilityDurations[self.frontBarSkills[i]] ~= nil then 
							sc.slider:SetValue(self.savedVariables.abilityDurations[self.frontBarSkills[i]])
							sc.slidervalue:SetText(self.savedVariables.abilityDurations[self.frontBarSkills[i]])
						end
						tc.texture:SetMouseEnabled(true)
						tc.texture:SetHandler('OnMouseEnter',function(self) WeaveDelays.updateTooltip(self, WeaveDelays.frontBarSkills[i]) end)
						tc.texture:SetHandler('OnMouseExit',function(self) WeaveDelays.updateTooltip(self, 0) end)
					end
				end
			end
		end
		if #self.backBarSkills > 0 then
			for i=1,5 do
				if self.backBarSkills[i] ~= nil then
					local tc = _G["weaveDelays_arb_bbT"..tostring(i)]
					local sc = _G["weaveDelays_arb_bbS"..tostring(i)]
					if tc ~= nil then
						tc.texture:SetTexture(self.GetTextureFromAbilityId(self.backBarSkills[i]))
						if self.savedVariables.abilityDurations[self.backBarSkills[i]] ~= nil then 
							sc.slider:SetValue(self.savedVariables.abilityDurations[self.backBarSkills[i]])
							sc.slidervalue:SetText(self.savedVariables.abilityDurations[self.backBarSkills[i]])
						end
						tc.texture:SetMouseEnabled(true)
						tc.texture:SetHandler('OnMouseEnter',function(self) WeaveDelays.updateTooltip(self, WeaveDelays.backBarSkills[i]) end)
						tc.texture:SetHandler('OnMouseExit',function(self) WeaveDelays.updateTooltip(self, 0) end)
					end
				end
			end
		end
	end
end

function WeaveDelays.InitializeMenu()

	local fontFaceList = self.getFontFaceList()
	local palettesList = self.getPalettesList()
	
    local panelData = {
        type = "panel",
        name = self.name,
        displayName = self.name,
        author = "Psiioniic",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(self.name, panelData)
	
	local optionsTable = {
	{
		type = "header",
		name = "WeaveDelays",
		width = "full",
	},
	{
		type = "description",
		text = "If account wide settings are enabled, the character specific settings are preserved and can be restored by disabling account wide settings.",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Account wide settings",
		tooltip = "",
		getFunc = function()
			return self.savedVariables.accountWide
		end,
		setFunc = function(value)
			self.characterSavedVariables.accountWide = value
			self.savedVariables.accountWide = value
		end,
		width = "full",
		default = false,
		requiresReload = true,
	},
	{
		type = "description",
		text = "Unlock the UI to move around the bars. If enabled, bars are not hidden automatically.",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Unlock UI",
		tooltip = "",
		getFunc = function()
			return self.savedVariables.unlockUI
		end,
		setFunc = function(value)
			self.savedVariables.unlockUI = value
			self.OnReticleHiddenUpdate()
			-- always show it when toggeled from menu and activated
			if self.savedVariables.unlockUI and self.savedVariables.showDelayBar then
				WeaveDelays.ShowDelayBar()
			end
		end,
		width = "full",
		default = false,
	},
	{
		type = "header",
		name = "Action bar additions",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Show delays and missed LA's before skill in action bar",
		tooltip = "",
		getFunc = function()
			return self.savedVariables.showActionBarAddon
		end,
		setFunc = function(value)
			self.savedVariables.showActionBarAddon = value
			self.UpdateActionBarVisibility()
		end,
		width = "full",
		default = false,
		requiresReload = false,
	},
	{
		type = "checkbox",
		name = "Show uptimes in action bar",
		tooltip = "",
		getFunc = function()
			return self.savedVariables.showActionBarUptimes
		end,
		setFunc = function(value)
			self.savedVariables.showActionBarUptimes = value
			self.UpdateActionBarVisibility()
		end,
		width = "full",
		default = false,
		requiresReload = false,
	},
	{
		type = "checkbox",
		name = "Show missed LA's after skill",
		tooltip = "",
		getFunc = function()
			return self.savedVariables.showActionBarBottomBar
		end,
		setFunc = function(value)
			self.savedVariables.showActionBarBottomBar = value
			self.UpdateActionBarVisibility()
		end,
		width = "full",
		default = false,
		requiresReload = false,
	},
	{
		type = "slider",
		name = "Raise upper action bar boxes",
		min = -100,
		max = 100,
		step = 1,
		getFunc = function()
			return self.savedVariables.actionBarRaiseTopBar
		end,
		setFunc = function(value)
			self.savedVariables.actionBarRaiseTopBar = tonumber(value)
		end,
		width = "full",
		default = 0,
		requiresReload = true,
	},
	{
		type = "header",
		name = "Cast delay bar",
		width = "full",
	},
	{
		type = "description",
		text = "The cast delay bar shows the time wasted between skill casts and if light attacks have been correctly weaved. The number of skills to be kept in the history can be chosen with rows and columns settings.",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Show delay bar",
		tooltip = "",
		getFunc = function()
			return self.savedVariables.showDelayBar
		end,
		setFunc = function(value)
			self.savedVariables.showDelayBar = value
		end,
		width = "full",
		default = false,
		requiresReload = true,
	},
	{
	  type = "colorpicker",
	  name = "Frame color",
	  disabled = function()
		return (not self.savedVariables.showDelayBar)
	  end,
	  getFunc = function() return self.savedVariables.delayBarFrameR,self.savedVariables.delayBarFrameG,self.savedVariables.delayBarFrameB,self.savedVariables.delayBarFrameA end,	
	  setFunc = function(r,g,b,a) 
		self.savedVariables.delayBarFrameR,self.savedVariables.delayBarFrameG,self.savedVariables.delayBarFrameB,self.savedVariables.delayBarFrameA = r, g, b, a 
		WeaveDelays.UpdateUIcustomizations()
		end,
	  width = "full",
	},
	{
		type = "slider",
		name = "Delay bar frame thickness",
		tooltip = "Delay bar frame thickness",
		min = 0,
		max = 10,
		step = 1,
		getFunc = function()
			return self.savedVariables.delayBarFrameThickness
		end,
		setFunc = function(value)
			self.savedVariables.delayBarFrameThickness = tonumber(value)
			WeaveDelays.UpdateUIcustomizations()
		end,
		width = "full",
		default = 1,
	},
	{
		type = "slider",
		name = "Delay bar opacity",
		tooltip = "Opacity for delay bar (0=transparent)",
		min = 0,
		max = 100,
		step = 1,
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.delayBarAlpha*100
		end,
		setFunc = function(value)
			self.savedVariables.delayBarAlpha = 0.01*tonumber(value)
			if self.savedVariables.showDelayBar then
				WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARBG'):SetAlpha(self.savedVariables.delayBarAlpha)
			end
		end,
		width = "full",
		default = 0.9,
	},
	{
		type = "slider",
		name = "UI scaling 50=default",
		min = 25,
		max = 100,
		step = 1,
		getFunc = function()
			return self.savedVariables.scale
		end,
		setFunc = function(value)
			self.savedVariables.scale = tonumber(value)
		end,
		width = "full",
		default = 50,
		requiresReload = true,
	},
	{
		type = "slider",
		name = "Delay bar slots (columns)",
		tooltip = "Number of slots (columns)",
		min = 1,
		max = 40,
		step = 1,
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.numDelayBarSlots
		end,
		setFunc = function(value)
			self.savedVariables.numDelayBarSlots = tonumber(value)
		end,
		width = "full",
		default = 5,
		requiresReload = true,
	},
	{
		type = "slider",
		name = "Delay bar rows",
		tooltip = "Number of rows",
		min = 1,
		max = 20,
		step = 1,
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.numDelayBarRows
		end,
		setFunc = function(value)
			self.savedVariables.numDelayBarRows = tonumber(value)
		end,
		width = "full",
		default = 1,
		requiresReload = true,
	},
	{
		type = "editbox",
		name = "Text (light attack not pressed)",
		tooltip = "shown if the light attack button was not pressed before this skill",
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.textLightAttackMissed
		end,
		setFunc = function(value)
			self.savedVariables.textLightAttackMissed = value
		end,
		width = "full",
	},
	{
		type = "editbox",
		name = "Text (light attack disappeared)",
		tooltip = "shown if the light attack button was pressed before this skill, but the light attack was not registered, e.g. when casting too rapidly",
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.textLightAttackDisappeared
		end,
		setFunc = function(value)
			self.savedVariables.textLightAttackDisappeared = value
		end,
		width = "full",
	},
	{
		type = "editbox",
		name = "Text (light attack queued)",
		tooltip = "shown if the light attack button was pressed before this skill, the light attack was queued, but did not succeed, e.g. because of range/hit box or the enemy died before",
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.textLightAttackQueued
		end,
		setFunc = function(value)
			self.savedVariables.textLightAttackQueued = value
		end,
		width = "full",
	},
	{
		type = "editbox",
		name = "Text (bash cancelled)",
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.textBashed
		end,
		setFunc = function(value)
			self.savedVariables.textBashed = value
		end,
		width = "full",
	},
	--showDelayBarOnlyInCombat
	{
		type = "checkbox",
		name = "Show delay bar only in combat",
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.showDelayBarOnlyInCombat
		end,
		setFunc = function(value)
			self.savedVariables.showDelayBarOnlyInCombat = value
			if value then
				WeaveDelays.HideDelayBarIfNotInCombat(9999999)
			else
				WeaveDelays.ShowDelayBar()
			end
		end,
		width = "full",
		default = false,
	},
	{
		type = "slider",
		name = "Show delay bar for number of seconds after combat",
		min = 1,
		max = 60,
		step = 1,
		disabled = function()
			return (not self.savedVariables.showDelayBarOnlyInCombat) or (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.showDelayBarAfterCombat
		end,
		setFunc = function(value)
			self.savedVariables.showDelayBarAfterCombat = tonumber(value)
		end,
		width = "full",
		default = 10,
	},
	{
		type = "checkbox",
		name = "Show skills in delay bar",
		tooltip = "Show skill symbols below delay indicator.",
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return self.savedVariables.showSkillsInDelayBar
		end,
		setFunc = function(value)
			self.savedVariables.showSkillsInDelayBar = value
		end,
		width = "full",
		default = false,
		requiresReload = true,
	},
	{
		type = "dropdown",
		name = "Palette",
		tooltip = "Color palette to use for delay indicator.",
		choices = palettesList,
		choicesValues = palettesList,
		scrollable = true,
		sort = "name-up",
		disabled = function()
			return (not self.savedVariables.showDelayBar)
		end,
		getFunc = function() return (self.savedVariables.delayBarPalette or "greenred") end,
		setFunc = function( choice )
			self.savedVariables.delayBarPalette = choice
			self.UpdateDelayBar()
		end
	},
	{
		type = "header",
		name = "Recast timer bar",
		width = "full",
	},			
	{
		type = "description",
		text = "Show abilities with duration in the order they need to be recasted. Empty spaces can be used for spammables. To disable tracking for an ability, set the duration to 0.",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Show ability recast bar",
		tooltip = "",
		getFunc = function()
			return self.savedVariables.showAbilityRecastBar
		end,
		setFunc = function(value)
			self.savedVariables.showAbilityRecastBar = value
		end,
		width = "full",
		default = false,
		requiresReload = true,
	},
	{
		type = "slider",
		name = "Update interval (ms)",
		min = 50,
		max = 1000,
		step = 50,
		disabled = function()
			return (not self.savedVariables.showAbilityRecastBar)
		end,
		getFunc = function()
			return self.savedVariables.abilityRecastBarUpdateInterval
		end,
		setFunc = function(value)
			self.savedVariables.abilityRecastBarUpdateInterval = tonumber(value)
			EVENT_MANAGER:UnregisterForUpdate("WeaveDelaysUiLoop")
			EVENT_MANAGER:RegisterForUpdate("WeaveDelaysUiLoop", self.savedVariables.abilityRecastBarUpdateInterval, self.UiLoop)
		end,
		width = "full",
		default = 200,
		requiresReload = false,
	},

	{
	  type = "colorpicker",
	  name = "Frame color",
	  disabled = function()
		return (not self.savedVariables.showAbilityRecastBar)
	  end,
	  getFunc = function() return self.savedVariables.recastBarFrameR,self.savedVariables.recastBarFrameG,self.savedVariables.recastBarFrameB,self.savedVariables.recastBarFrameA end,	
	  setFunc = function(r,g,b,a) 
		self.savedVariables.recastBarFrameR,self.savedVariables.recastBarFrameG,self.savedVariables.recastBarFrameB,self.savedVariables.recastBarFrameA = r, g, b, a 
		WeaveDelays.UpdateUIcustomizations()
		end,
	  width = "full",
	},
	{
		type = "slider",
		name = "Frame thickness",
		tooltip = "Frame thickness",
		min = 0,
		max = 10,
		step = 1,
		getFunc = function()
			return self.savedVariables.recastBarFrameThickness
		end,
		setFunc = function(value)
			self.savedVariables.recastBarFrameThickness = tonumber(value)
			WeaveDelays.UpdateUIcustomizations()
		end,
		width = "full",
		default = 1,
	},
	{
		type = "slider",
		name = "Number of slots",
		tooltip = "Number of slots (columns)",
		min = 1,
		max = 40,
		step = 1,
		disabled = function()
			return (not self.savedVariables.showAbilityRecastBar)
		end,
		getFunc = function()
			return self.savedVariables.abilityRecastBarNumSlots
		end,
		setFunc = function(value)
			self.savedVariables.abilityRecastBarNumSlots = tonumber(value)
		end,
		width = "full",
		default = 10,
		requiresReload = true,
	},
	{
		type = "dropdown",
		name = "Font Face",
		tooltip = "Font face for ability recast bar timers, it's recommended to use game fonts starting with Zo.",
		choices = fontFaceList,
		choicesValues = fontFaceList,
		scrollable = true,
		sort = "name-up",
		disabled = function()
			return (not self.savedVariables.showAbilityRecastBar)
		end,
		getFunc = function() return (self.savedVariables.abilityRecastBarFontFace or "ZoFontGamepad25") end,
		setFunc = function( choice )
			self.savedVariables.abilityRecastBarFontFace = choice
			self.updateAbilityRecastBarFontFace()
		end
	},
	{
		type = "slider",
		name = "Ability recast bar opacity",
		tooltip = "Opacity for ability recast bar (0=transparent)",
		min = 0,
		max = 100,
		step = 1,
		disabled = function()
			return (not self.savedVariables.showAbilityRecastBar)
		end,
		getFunc = function()
			return self.savedVariables.abilityRecastBarAlpha*100
		end,
		setFunc = function(value)
			self.savedVariables.abilityRecastBarAlpha = 0.01*tonumber(value)
			if self.savedVariables.showAbilityRecastBar then
				WEAVEDELAYSBAR2BG:SetAlpha(self.savedVariables.abilityRecastBarAlpha)
			end
		end,
		width = "full",
		default = 100,
	},
	{
		type = "slider",
		name = "UI scaling 50=default",
		min = 25,
		max = 100,
		step = 1,
		getFunc = function()
			return self.savedVariables.recastBarScale
		end,
		setFunc = function(value)
			self.savedVariables.recastBarScale = tonumber(value)
		end,
		width = "full",
		default = 50,
		requiresReload = true,
	},
	--{
	--	type = "submenu",
	--	name = "Select tracked abilities",
	--	tooltip = "Select tracked abilities and adjust durations.",
	--	controls = {
			{
				type = "description",
				text = "Set skill durations (in ms). If skills are not shown, weapon-swap twice and reopen the settings panel.",
				width = "full",
			},
			{
				type = "description",
				text = "Front bar",
				width = "full",
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_fbT1",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 1",
				reference = "weaveDelays_arb_fbS1",
				step = 100,
				disabled = function()
					return self.frontBarSkills[1]==nil
				end,
				getFunc = function()
					if self.frontBarSkills[1] ~= nil and self.savedVariables.abilityDurations[self.frontBarSkills[1]] ~= nil then
						return self.savedVariables.abilityDurations[self.frontBarSkills[1]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.frontBarSkills[1] ~= nil then
						self.savedVariables.abilityDurations[self.frontBarSkills[1]] = value
					end
				end,
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_fbT2",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 2",
				reference = "weaveDelays_arb_fbS2",
				step = 100,
				disabled = function()
					return self.frontBarSkills[2]==nil
				end,
				getFunc = function()
					if self.frontBarSkills[2] ~= nil and self.savedVariables.abilityDurations[self.frontBarSkills[2]] ~= nil then
						return self.savedVariables.abilityDurations[self.frontBarSkills[2]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.frontBarSkills[2] ~= nil then
						self.savedVariables.abilityDurations[self.frontBarSkills[2]] = value
					end
				end,
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_fbT3",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 3",
				reference = "weaveDelays_arb_fbS3",
				step = 100,
				disabled = function()
					return self.frontBarSkills[3]==nil
				end,
				getFunc = function()
					if self.frontBarSkills[3] ~= nil and self.savedVariables.abilityDurations[self.frontBarSkills[3]] ~= nil then
						return self.savedVariables.abilityDurations[self.frontBarSkills[3]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.frontBarSkills[3] ~= nil then
						self.savedVariables.abilityDurations[self.frontBarSkills[3]] = value
					end
				end,
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_fbT4",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 4",
				reference = "weaveDelays_arb_fbS4",
				step = 100,
				disabled = function()
					return self.frontBarSkills[4]==nil
				end,
				getFunc = function()
					if self.frontBarSkills[4] ~= nil and self.savedVariables.abilityDurations[self.frontBarSkills[4]] ~= nil then
						return self.savedVariables.abilityDurations[self.frontBarSkills[4]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.frontBarSkills[4] ~= nil then
						self.savedVariables.abilityDurations[self.frontBarSkills[4]] = value
					end
				end,
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_fbT5",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 5",
				reference = "weaveDelays_arb_fbS5",
				step = 100,
				disabled = function()
					return self.frontBarSkills[5]==nil
				end,
				getFunc = function()
					if self.frontBarSkills[5] ~= nil and self.savedVariables.abilityDurations[self.frontBarSkills[5]] ~= nil then
						return self.savedVariables.abilityDurations[self.frontBarSkills[5]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.frontBarSkills[5] ~= nil then
						self.savedVariables.abilityDurations[self.frontBarSkills[5]] = value
					end
				end,
			},
			{
				type = "description",
				text = "Back bar",
				width = "full",
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_bbT1",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 1",
				reference = "weaveDelays_arb_bbS1",
				step = 100,
				disabled = function()
					return self.backBarSkills[1]==nil
				end,
				getFunc = function()
					if self.backBarSkills[1] ~= nil and self.savedVariables.abilityDurations[self.backBarSkills[1]] ~= nil then
						return self.savedVariables.abilityDurations[self.backBarSkills[1]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.backBarSkills[1] ~= nil then
						self.savedVariables.abilityDurations[self.backBarSkills[1]] = value
					end
				end,
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_bbT2",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 2",
				reference = "weaveDelays_arb_bbS2",
				step = 100,
				disabled = function()
					return self.backBarSkills[2]==nil
				end,
				getFunc = function()
					if self.backBarSkills[2] ~= nil and self.savedVariables.abilityDurations[self.backBarSkills[2]] ~= nil then
						return self.savedVariables.abilityDurations[self.backBarSkills[2]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.backBarSkills[2] ~= nil then
						self.savedVariables.abilityDurations[self.backBarSkills[2]] = value
					end
				end,
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_bbT3",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 3",
				reference = "weaveDelays_arb_bbS3",
				step = 100,
				disabled = function()
					return self.backBarSkills[3]==nil
				end,
				getFunc = function()
					if self.backBarSkills[3] ~= nil and self.savedVariables.abilityDurations[self.backBarSkills[3]] ~= nil then
						return self.savedVariables.abilityDurations[self.backBarSkills[3]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.backBarSkills[3] ~= nil then
						self.savedVariables.abilityDurations[self.backBarSkills[3]] = value
					end
				end,
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_bbT4",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 4",
				reference = "weaveDelays_arb_bbS4",
				step = 100,
				disabled = function()
					return self.backBarSkills[4]==nil
				end,
				getFunc = function()
					if self.backBarSkills[4] ~= nil and self.savedVariables.abilityDurations[self.backBarSkills[4]] ~= nil then
						return self.savedVariables.abilityDurations[self.backBarSkills[4]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.backBarSkills[4] ~= nil then
						self.savedVariables.abilityDurations[self.backBarSkills[4]] = value
					end
				end,
			},
			{
				type = "texture",
				image= "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds",
				reference = "weaveDelays_arb_bbT5",
				imageWidth = 50,
				imageHeight = 50,
				width = "half",
			},
			{
				type = "slider",
				min = 0,
				max = 60000,
				default = 0,
				width = "half",
				name = "Skill 5",
				reference = "weaveDelays_arb_bbS5",
				step = 100,
				disabled = function()
					return self.backBarSkills[5]==nil
				end,
				getFunc = function()
					if self.backBarSkills[5] ~= nil and self.savedVariables.abilityDurations[self.backBarSkills[5]] ~= nil then
						return self.savedVariables.abilityDurations[self.backBarSkills[5]]
					else
						return 0
					end
				end,
				setFunc = function(value)
					if self.backBarSkills[5] ~= nil then
						self.savedVariables.abilityDurations[self.backBarSkills[5]] = value
					end
				end,
			},
		--}
	--}
	{
		type = "header",
		name = "Item sets and effects",
		width = "full",
	},			
	{
		type = "description",
		text = "Enable/disable tracking of item/ability effects",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Mechanical acuity (set)",
		getFunc = function()
			return self.savedVariables.itemSetMechanicalAcuity
		end,
		setFunc = function(value)
			self.savedVariables.itemSetMechanicalAcuity = value
		end,
		width = "full",
		default = true,
	},
	{
	  type = "colorpicker",
	  name = "Mechanical acuity color",
	  disabled = function()
		return (not self.savedVariables.itemSetMechanicalAcuity)
	  end,
	  getFunc = function() return self.savedVariables.acuityFrameR,self.savedVariables.acuityFrameG,self.savedVariables.acuityFrameB,self.savedVariables.acuityFrameA end,	
	  setFunc = function(r,g,b,a) 
		self.savedVariables.acuityFrameR,self.savedVariables.acuityFrameG,self.savedVariables.acuityFrameB,self.savedVariables.acuityFrameA = r, g, b, a 
		end,
	  width = "full",
	},
	{
		type = "header",
		name = "Compatibility",
		width = "full",
	},			
	{
		type = "description",
		text = "Settings for compatibility with other Addons",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Detect Bandits UI",
		tooltip = "Enable the automatic detection of Bandits UI",
		getFunc = function()
			return self.savedVariables.compatibilityDetectBandits
		end,
		setFunc = function(value)
			self.savedVariables.compatibilityDetectBandits = value
		end,
		width = "full",
		default = true,
		requiresReload = true,
	},
	{
		type = "checkbox",
		name = "Detect Fancy Action Bar",
		tooltip = "Enable the automatic detection of Fancy Action Bar",
		getFunc = function()
			return self.savedVariables.compatibilityDetectFAB
		end,
		setFunc = function(value)
			self.savedVariables.compatibilityDetectFAB = value
		end,
		width = "full",
		default = true,
		requiresReload = true,
	},
	{
		type = "checkbox",
		name = "Detect Action Duration Reminder",
		tooltip = "Enable the automatic detection of Action Duration Reminder",
		getFunc = function()
			return self.savedVariables.compatibilityDetectADR
		end,
		setFunc = function(value)
			self.savedVariables.compatibilityDetectADR = value
		end,
		width = "full",
		default = true,
		requiresReload = true,
	},
	{
		type = "checkbox",
		name = "Reposition default UI health bar",
		tooltip = "Reposition the default UI health bar automatically if some other addons are found, can be tuned with the setting below.",
		getFunc = function()
			return self.savedVariables.compatibilityRepositionDefaultUIHealthBar
		end,
		setFunc = function(value)
			self.savedVariables.compatibilityRepositionDefaultUIHealthBar = value
		end,
		width = "full",
		default = true,
		requiresReload = true,
	},
	{
		type = "slider",
		name = "Raise default UI health bar",
		tooltip = "Raise default UI health bar by this amount, in addition to the automatic setting.",
		min = -100,
		max = 100,
		step = 1,
		getFunc = function()
			return self.savedVariables.compatibilityRaiseDefaultUIHealthBar
		end,
		setFunc = function(value)
			self.savedVariables.compatibilityRaiseDefaultUIHealthBar = tonumber(value)
			self.repositionHealthBar()
			
		end,
		width = "full",
		default = 0,
		requiresReload = false,
	},
	{
		type = "header",
		name = "Experimental features",
		width = "full",
	},		
	{
		type = "checkbox",
		name = "Increase latency tolerance",
		tooltip = "If you have a high latency and problems with this addon, try to enable this setting.",
		getFunc = function()
			return self.savedVariables.highLatencyMode
		end,
		setFunc = function(value)
			self.savedVariables.highLatencyMode = value
			self.log.SetHighLatencyMode(self.savedVariables.highLatencyMode)
		end,
		width = "full",
		default = true,
		requiresReload = false,
	},
	}
	LibAddonMenu2:RegisterOptionControls(self.name, optionsTable)
	
	--
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", self.callUpdateSkillsInMenu)
	
end

function WeaveDelays.OnAddOnLoaded(eventCode, addonName)
	if addonName == "BanditsUserInterface" then
		self.banditsFound = true
	end
	if addonName == "ActionDurationReminder" then
		self.actionDurationReminderFound = true
	end
	if addonName == "FancyActionBar" then
		self.fancyActionBarFound = true
	end
	
	if addonName == self.name then
		WeaveDelays:Initialize()
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
	end
end



SLASH_COMMANDS[self.slash] = function (cmd)
    local commands = {}
    local index = 1
	local num = 0
	
    for i in string.gmatch(cmd, "%S+") do
        if (i ~= nil and i ~= "") then
            commands[index] = i
            index = index + 1
        end
    end

    if #commands == 0 then
        self.ToggleWindow()
    end

    if #commands == 1 then
		if commands[1] == "reset" then
			self.Reset()
		elseif commands[1] == "skills" then
			d("----------")
			d(GetSlotBoundId(3))
			d(GetSlotBoundId(4))
			d(GetSlotBoundId(5))
			d(GetSlotBoundId(6))
			d(GetSlotBoundId(7))
			d(GetSlotBoundId(8))
			d("----------")
		elseif commands[1] == "update" then
			self.Update()
		end
	end
end

EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, self.OnAddOnLoaded)


