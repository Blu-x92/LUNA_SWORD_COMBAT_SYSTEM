--[[

heavily modified version of GVP's Lightsaber System for public use

please dont reupload, dont resell

best regards luna

]]--

LSCS = istable( LSCS ) and LSCS or { Hilt = {}, Blade = {}, Stance = {}, Force = {},BulletTracerDeflectable = {} }

LSCS.VERSION = 194
LSCS.VERSION_GITHUB = 0
LSCS.VERSION_TYPE = ".GIT"

function LSCS:GetVersion()
	return LSCS.VERSION
end

function LSCS:CheckUpdates()
	http.Fetch("https://raw.githubusercontent.com/SpaxscE/lscs_public/main/lua/autorun/lscs_best_regards_from_luna.lua", function(contents,size) 
		local Entry = string.match( contents, "LSCS.VERSION%s=%s%d+" )

		if Entry then
			LSCS.VERSION_GITHUB = tonumber( string.match( Entry , "%d+" ) ) or 0
		else
			LSCS.VERSION_GITHUB = 0
		end

		if LSCS.VERSION_GITHUB == 0 then
			print("[LSCS] latest version could not be detected, You have Version: "..LSCS:GetVersion())
		else
			if  LSCS:GetVersion() >= LSCS.VERSION_GITHUB then
				print("[LSCS] is up to date, Version: "..LSCS:GetVersion())
			else
				print("[LSCS] a newer version is available! Version: "..LSCS.VERSION_GITHUB..", You have Version: "..LSCS:GetVersion())

				if LSCS.VERSION_TYPE == ".GIT" then
					print("[LSCS] get the latest version at https://github.com/SpaxscE/lscs_public")
				else
					print("[LSCS] restart your game/server to get the latest version!")
				end

				if CLIENT then 
					timer.Simple(18, function() 
						chat.AddText( Color( 255, 0, 0 ), "[LSCS] a newer version is available!" )
					end)
				end
			end
		end
	end)
end

AddCSLuaFile("lscs/init.lua")
include("lscs/init.lua")

if SERVER then
	resource.AddWorkshop( "2837856621" )
end

if CLIENT then
	list.Set( "ContentCategoryIcons", "[LSCS]", "icon16/lscs.png" )
	list.Set( "ContentCategoryIcons", "[LSCS] - Hilts", "icon16/lscs.png" )
	list.Set( "ContentCategoryIcons", "[LSCS] - Force", "icon16/lscs.png" )
	list.Set( "ContentCategoryIcons", "[LSCS] - Crystals", "icon16/lscs.png" )
	list.Set( "ContentCategoryIcons", "[LSCS] - Stances", "icon16/lscs.png" )
end

hook.Add( "InitPostEntity", "!!!lscscheckupdates", function()
	timer.Simple(20, function() LSCS:CheckUpdates() end)
end )
