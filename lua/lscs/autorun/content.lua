local blade = {}
blade.PrintName = "Sapphire"
blade.Author = "Blu-x92 / Luna"
blade.id = "sapphire"
blade.color_blur = Color(0,65,255)
blade.color_core = Color(255,255,255)
blade.length = 45
blade.width = 0.9
blade.widthWiggle = 0.6
blade.material_core_tip = Material( "lscs/effects/lightsaber_tip" )
blade.material_core = Material( "lscs/effects/lightsaber_core" )
blade.material_glow_start = Material( "lscs/effects/lightsaber_glow" )
blade.material_glow = Material( "lscs/effects/lightsaber_blade" )
blade.material_trail = Material( "lscs/effects/lightsaber_trail" )
blade.dynamic_light = true
blade.sounds = {
	Attack = "saber_hup",
	Activate = "saber_turnon",
	Disable = "saber_turnoff",
	Idle =  "saber/saberhum4.wav",
}
LSCS:RegisterBlade( blade )

local hilt = {}
hilt.PrintName = "Katarn"
hilt.Author = "Blu-x92 / Luna"
hilt.id = "katarn"
hilt.mdl = "models/lscs/weapons/katarn.mdl"
hilt.info = {
	ParentData = {
		["RH"] = {
			bone = "ValveBiped.Bip01_R_Hand",
			pos = Vector(4.25, -1.5, -1),
			ang = Angle(172, 0, 10),
		},
		["LH"] = {
			bone = "ValveBiped.Bip01_L_Hand",
			pos = Vector(4.25, -1.5, 1),
			ang = Angle(8, 0, -10),
		},
	},
	GetBladePos = function( ent )
		if not ent.BladeID then
			ent.BladeID = ent:LookupAttachment( "primary_blade" )
		end

		local att = ent:GetAttachment( ent.BladeID )

		local blades = {
			[1] = {
				pos = att.Pos,
				dir = att.Ang:Up(),
			}
		}
		return blades
	end,
}
LSCS:RegisterHilt( hilt )