-- Nil-safe quest UI helpers. Prevents Gravity popups when a quest ID
-- is active on the server but missing from QuestInfoList.
function GetOngoingQuestInfoByID(questID)
	local info = QuestInfoList and QuestInfoList[questID]
	if info == nil then
		return GetOngoingSimpleView(questID), "", "", "", "", "", 0, 0, 0, 0
	end
	return GetOngoingSimpleView(questID), info.Title or "", info.IconName or "", info.Summary or "", info.NpcSpr or "", info.NpcNavi or "", info.RewardEXP or 0, info.RewardJEXP or 0, info.NpcPosX or 0, info.NpcPosY or 0
end

function GetOngoingDescription(questID)
	local info = QuestInfoList and QuestInfoList[questID]
	if info == nil then
		return
	end
	local desc = info.Description
	if desc == nil then
		return
	end
	for k, v in pairs(desc) do
		AddOngoingDescription(questID, v)
	end
end

function GetOngoingRewardInfo(questID)
	local info = QuestInfoList and QuestInfoList[questID]
	if info == nil then
		return
	end
	local reward = info.RewardItemList
	if reward == nil then
		return
	end
	for k, v in pairs(reward) do
		AddOngoingRewardInfo(questID, v.ItemID, v.ItemNum)
	end
end

function RecommendedQuestInfoLoad()
	if RecommendedQuestInfoList == nil then
		return
	end
	for questID, table in pairs(RecommendedQuestInfoList) do
		if table.Title == nil then
			table.Title = ""
		end
		if table.IconName == nil then
			table.IconName = ""
		end
		if table.Summary == nil then
			table.Summary = ""
		end
		if table.BgName == nil then
			table.BgName = ""
		end
		if table.NpcSpr == nil then
			table.NpcSpr = ""
		end
		if table.NpcNavi == nil then
			table.NpcNavi = ""
		end
		if table.NpcPosX == nil then
			table.NpcPosX = 0
		end
		if table.NpcPosY == nil then
			table.NpcPosY = 0
		end
		InsertRecommededQuestInfo(questID, table.Title, table.IconName, table.Summary, table.BgName, table.NpcSpr, table.NpcNavi, table.NpcPosX, table.NpcPosY)
		if table.QuestInfo1 ~= nil then
			for k, v in pairs(table.QuestInfo1) do
				AddRecommendedQuestInfo(questID, 0, v)
			end
		end
		if table.QuestInfo2 ~= nil then
			for k, v in pairs(table.QuestInfo2) do
				AddRecommendedQuestInfo(questID, 1, v)
			end
		end
		if table.QuestInfo3 ~= nil then
			for k, v in pairs(table.QuestInfo3) do
				AddRecommendedQuestInfo(questID, 2, v)
			end
		end
	end
end

function RecommendedQuestActiveLoad()
	if RecommendedActiveList == nil then
		return
	end
	for k, questID in pairs(RecommendedActiveList) do
		SetRecommendedQuestActive(questID)
	end
end

function GetOngoingSimpleView(in_questID)
	if OngoingSimpleViewList == nil then
		return true
	end
	for k, questID in pairs(OngoingSimpleViewList) do
		if questID == in_questID then
			return false
		end
	end
	return true
end
