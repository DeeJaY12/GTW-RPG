--[[ 
********************************************************************************
	Project owner:		GTWGames												
	Project name:		GTW-RPG	
	Developers:			GTWCode
	
	Source code:		https://github.com/GTWCode/GTW-RPG/
	Bugtracker:			http://forum.albonius.com/bug-reports/
	Suggestions:		http://forum.albonius.com/mta-servers-development/
	
	Version:			Open source
	License:			GPL v.3 or later
	Status:				Stable release
********************************************************************************
]]--

-- On accepting the job
function onAcceptJob( ID, skinID )
	-- Get job data
    local team, max_wl, description, skins = unpack(work_items[ID])
    
    -- Check if a skin was passed
    if not skinID then return end
    
    -- Note that -1 means default player skin
    if skinID > -1 then
    	setElementModel( client, skinID )
    elseif skinID == -1 then
    	skinID = exports.GTWclothes:getBoughtSkin( client ) or getElementModel( client ) or 0
    	setElementModel( client, skinID )
    else
    	exports.GTWtopbar:dm( "Select a skin before applying for the job!", client, 255, 0, 0 )
    	return
    end
    
    -- Check if a player already have the job or not
    if getElementData(client, "Occupation") ~= ID then
    	setElementData(client, "Occupation", ID)
        setPlayerTeam(client, getTeamFromName(team))
        local r,g,b = 255,255,255
        if getTeamFromName(team) then
        	r,g,b = getTeamColor(getTeamFromName(team))
        else
        	outputServerLog("GTWcivilians: Team: '"..team.."' does not exist!")
        end
        setPlayerNametagColor(client, r, g, b)
        setElementData(client, "admin", nil)
        exports.GTWtopbar:dm("("..ID..") Welcome to your new job!", client, 0, 255, 0)
    end
end
addEvent( "GTWcivilians.accept", true )
addEventHandler( "GTWcivilians.accept", root, onAcceptJob )

-- Manage job tools
function onBuyTool(name, ammo, price, weapon_id)
	if not name or not ammo or not price or not weapon_id then return end
	if getPlayerMoney(client) >= tonumber(price) then
		giveWeapon(client, weapon_id, ammo, true)
		takePlayerMoney(client, price)
	else
		exports.GTWtopbar:dm("You cannot afford this tool!", client, 255, 0, 0)
	end
end
addEvent( "GTWcivilians.buyTools", true )
addEventHandler( "GTWcivilians.buyTools", root, onBuyTool )

-- Team service and scoreboard
function addTeamData ( )
	-- Add info columns to scoreboard
	exports.scoreboard_2015:scoreboardAddColumn("Occupation", root, 100)
	exports.scoreboard_2015:scoreboardAddColumn("Group", root, 100)
	exports.scoreboard_2015:scoreboardAddColumn("Money", root, 75)
	exports.scoreboard_2015:scoreboardAddColumn("Playtime", root, 50)
	--exports.scoreboard_2015:scoreboardAddColumn("Jailed", root, 35)
	
	-- Create teams
	staffTeam = createTeam( "Staff", 255, 255, 255 )
	govTeam = createTeam( "Government", 110, 110, 110 )
	emergencyTeam = createTeam( "Emergency service", 0, 150, 200 )
   	civilianTeam = createTeam( "Civilians", 200, 150, 0 )
	gangstersTeam = createTeam( "Gangsters", 135, 0, 135 )
	criminalTeam = createTeam( "Criminals", 170, 0, 0 )
	unemployedTeam = createTeam( "Unemployed", 255, 255, 0 )
	
	-- Restore teams
	for i,p in pairs(getElementsByType( "player" )) do
		if not getElementData(p, "teamsystem_team") then
			setPlayerTeam(p, getTeamFromName("Unemployed"))
			setElementData(p, "Occupation", "")
		else
			setPlayerTeam(p, getTeamFromName( getElementData(p, "teamsystem_team")))
			setElementData(p, "teamsystem_team", nil)
		end
	end
end
addEventHandler( "onResourceStart", getResourceRootElement(), addTeamData )

addEventHandler( "onResourceStop", getResourceRootElement(), 
function ( resource )
	for i,p in pairs(getElementsByType( "player" )) do
		if getPlayerTeam(p) then
			setElementData(p, "teamsystem_team", getTeamName(getPlayerTeam(p)))
		end
	end
end)