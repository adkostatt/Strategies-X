local SendRequest = http_request or request or HttpPost or syn.request
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MatchGui = LocalPlayer.PlayerGui.RoactGame.Rewards.content.gameOver
local Info = MatchGui.content.info
local Stats = Info.stats
local Rewards = Info.rewards
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Executor = identifyexecutor and identifyexecutor() or "Not Identify"
local UtilitiesConfig = StratXLibrary.UtilitiesConfig
local PlayerInfo = StratXLibrary.UI.PlayerInfo.Property

local CommaText = function(string)
   local String = tostring(string):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
   return String
end
local TimeFormat = function(string)
   local Time = string.gsub(string,"%D+",":"):gsub(".?$","")
   return Time
end

local GameInfo
local GetGameSate = getgenv().GetGameSate or function()
   if GameInfo then
      return GameInfo
   end
   repeat
      for i,v in next, ReplicatedStorage.StateReplicators:GetChildren() do
         if v:GetAttribute("TimeScale") then
               GameInfo = v
               return v
         end
      end
      task.wait()
   until GameInfo
end

--[[local function CheckStatus()
   return MatchGui.banner.textLabel.Text
end]]
local function CheckReward()
   local RewardType
   repeat task.wait() until Rewards[1] and Rewards[2]
   if Rewards[2].content.icon.Image == "rbxassetid://5870325376" then
      RewardType = "Coins"
   else
      RewardType = "Gems"
   end
   return {RewardType, Rewards[2].content.textLabel.Text..((RewardType == "Coins" and " :coin:") or (RewardType == "Gems" and " :gem:") or "")}
end

local function CheckTower()
   local str = ""
   local TowerInfo = StratXLibrary.TowerInfo or {}
   for i,v in next, TowerInfo do
      str = `{str}\n{v[3]}: {v[2]}`
   end
   return str
end

local CheckColor = {
   ["TRIUMPH!"] = tonumber(65280),
   ["YOU LOST"] = tonumber(16711680),
   [true] = tonumber(65280),
   [false] = tonumber(16711680),
}

local GetReward = CheckReward()

local Data = {
   ["content"] = "", --Msg
   ["embeds"] = {
      {
         ["title"] = `**Strategies X Webhook**`,
         ["color"] = CheckColor[GetGameSate():GetAttribute("Won")], --decimal
         ["footer"] = {
            ["text"] = `{os.date("%X")} {os.date("%x")}`,
         },
      }
   }
}
local WebhookData = {}
if UtilitiesConfig.Webhook.UseNewFormat then
   Data.embeds[1].fields = {}
   WebhookData.PlayerInfo = if UtilitiesConfig.Webhook.PlayerInfo then 
      {
         {
            ["name"] = "----------------- PLAYER INFO ---------------",
            ["value"] = "",
         },
         {
            ["name"] = "Username:",
            ["value"] = (UtilitiesConfig.Webhook.HideUser and "Anonymous") or LocalPlayer.Name,
            ["inline"] = true
         },
         {
            ["name"] = "Display Name:",
            ["value"] = (UtilitiesConfig.Webhook.HideUser and "Anonymous") or LocalPlayer.DisplayName,
            ["inline"] = true
         },
         {
            ["name"] = "Executor Used:",
            ["value"] = Executor,
            ["inline"] = true
         },
         {
            ["name"] = "Level:",
            ["value"] = CommaText(LocalPlayer.Level.Value).." :chart_with_upwards_trend:",
            ["inline"] = true
         },
         {
            ["name"] = "Coins:",
            ["value"] = CommaText(PlayerInfo.Coins).." :coin:", --LocalPlayer.Coins.Value
            ["inline"] = true
         },
         {
            ["name"] = "Gems:",
            ["value"] = CommaText(PlayerInfo.Gems).." :gem:", --LocalPlayer.Gems.Value
            ["inline"] = true
         },
         {
            ["name"] = "Triumphs:",
            ["value"] = CommaText(PlayerInfo.Triumphs).." :trophy:", --LocalPlayer.Triumphs.Value
            ["inline"] = true
         },
         {
            ["name"] = "Loses:",
            ["value"] = CommaText(PlayerInfo.Loses).." :skull:", --LocalPlayer.Loses.Value
            ["inline"] = true
         },
         {
            ["name"] = "Exp:",
            ["value"] = CommaText(LocalPlayer.Experience.Value).." :star:",
            ["inline"] = true
         },
      }
      else {}
   WebhookData.GameInfo = if UtilitiesConfig.Webhook.GameInfo then
      {
         {
            ["name"] = "------------------ GAME INFO ----------------",
            ["value"] = "",
         },
         {
            ["name"] = "Map:",
            ["value"] = ReplicatedStorage.State.Map.Value,
            ["inline"] = true
         },
         {
            ["name"] = "Mode:",
            ["value"] = ReplicatedStorage.State.Difficulty.Value,
            ["inline"] = true
         },
         {
            ["name"] = "Wave / Health:",
            ["value"] = GetGameSate():GetAttribute("Wave").." / "..tostring(ReplicatedStorage.State.Health.Current.Value).." ("..tostring(ReplicatedStorage.State.Health.Max.Value)..")",
            ["inline"] = true
         },
         {
            ["name"] = "Game Time:",
            ["value"] = TimeFormat(Stats.duration.Text),
            ["inline"] = true
         },
         {
            ["name"] = "Won "..GetReward[1]..":",
            ["value"] = GetReward[2],
            ["inline"] = true
         },
         {
            ["name"] = "Won Experiences:",
            ["value"] = string.split(Rewards[1].content.textLabel.Text," XP")[1].." :star:",
            ["inline"] = true
         }, 
      }
      else {}
   WebhookData.TroopsInfo = if UtilitiesConfig.Webhook.TroopsInfo then
      {
         {
            ["name"] = "----------------- TROOPS INFO ---------------",
            ["value"] = "```m\n"..CheckTower().."```",
            ["inline"] = false
         },
      }
   else {}
   for i,v in next, WebhookData do
      for i2,v2 in next, v do
         table.insert(Data.embeds[1].fields,v2)
      end
   end
else
   Data.embeds.description = ""
   local PlayerInfo = if UtilitiesConfig.Webhook.PlayerInfo then
   "**--------------- ACCOUNT INFO --------------**"..
   "\n**Name : **" ..((UtilitiesConfig.Webhook.HideUser and "Anonymous") or LocalPlayer.Name).."** | DisplayName : **" ..((UtilitiesConfig.Webhook.HideUser and "Anony") or LocalPlayer.DisplayName)..
  "\n**Coins : **" ..PlayerInfo.Coins.." :coin:** | Gems : **" ..PlayerInfo.Gems.." :gem:"..
   "\n**Level : **" ..LocalPlayer.Level.Value.." :chart_with_upwards_trend: ** | Exp : **" ..LocalPlayer.Experience.Value.." :star:"..
   "\n**Triumphs : **" ..PlayerInfo.Triumphs.." :trophy: ** | Loses : **" ..PlayerInfo.Loses.." :skull:"..
   "\n**Executor Used : **"..Executor.."\n"
   else ""
   local GameInfo = if UtilitiesConfig.Webhook.GameInfo then
      "**------------------ GAME INFO ----------------**"..
     "\n**Map : ** "..ReplicatedStorage.State.Map.Value.."** | Mode : **"..ReplicatedStorage.State.Difficulty.Value..
      "\n**Wave : **" ..GetGameSate():GetAttribute("Wave").."** | Health : **"..tostring(ReplicatedStorage.State.Health.Current.Value).." ("..tostring(ReplicatedStorage.State.Health.Max.Value)..")".."** | Game Time : **" ..TimeFormat(Stats.duration.Text)..
     "\n**Won " ..GetReward[1]..": **" ..GetReward[2].."** | Won Experience : **" ..string.split(Rewards[1].content.textLabel.Text," XP")[1].." :star:\n"
   else ""
   local TroopsInfo = if UtilitiesConfig.Webhook.TroopsInfo then 
      "**-------------- TROOPS INFO -----------------**".."```m\n"..CheckTower().."```"
   else ""
   Data.embeds[1].description = PlayerInfo..GameInfo..TroopsInfo
end
if #UtilitiesConfig.Webhook.Link ~= 0 then
   getgenv().SendCheck = SendRequest({
      Url = UtilitiesConfig.Webhook.Link, 
      Body = game:GetService("HttpService"):JSONEncode(Data), 
      Method = "POST", 
      Headers = {
          ["content-type"] = "application/json"
      }
   })
end