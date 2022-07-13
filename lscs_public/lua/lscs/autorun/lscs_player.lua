local meta = FindMetaTable( "Player" )

function meta:lscsGetShootPos()
	local attachment = self:GetAttachment( self:LookupAttachment( "eyes" ) )

	if attachment then
		return attachment.Pos
	else
		return self:GetShootPos()
	end
end

function meta:lscsGetViewOrigin()
	local angles = self:EyeAngles()
	local pos = self:lscsGetShootPos()

	local clamped_angles = Angle( math.max( angles.p, -60 ), angles.y, angles.r )

	local endpos = pos - clamped_angles:Forward() * 100 + clamped_angles:Up() * 12

	local trace = util.TraceHull({
		start = pos,
		endpos = endpos,
		mask = MASK_SOLID_BRUSHONLY,
		mins = Vector(-5,-5,-5),
		maxs = Vector(5,5,5),
		filter = { self },
	})

	return trace.HitPos
end

if SERVER then
	util.AddNetworkString( "lscs_sync_combo_data" )

	function meta:lscsSendComboDataTo( ply )
		if not IsValid( ply ) then return end

		local stances = self.m_lscs_combo or {}

		if table.IsEmpty( stances ) then return end

		net.Start( "lscs_sync_combo_data" )
			net.WriteEntity( self )
			net.WriteInt( #stances, 32 )
			for _, comboname in ipairs( stances ) do
				net.WriteString( comboname )
			end
		net.Send( ply )
	end

	hook.Add( "LSCS:OnPlayerFullySpawned", "sync_combo_data", function( ply )
		for id, other_ply in ipairs( player.GetAll() ) do
			timer.Simple( id * 0.25, function()
				if not IsValid( other_ply ) or not IsValid( ply ) then return end
				other_ply:lscsSendComboDataTo( ply )
			end )
		end
	end )
else
	net.Receive( "lscs_sync_combo_data", function( len )
		local ply = net.ReadEntity()

		if not IsValid( ply ) then return end

		local num = net.ReadInt( 32 )

		local stances = {}
		for i = 1, num do
			table.insert( stances, net.ReadString() )
		end

		ply.m_lscs_combo = stances
	end )
end

function meta:lscsKeyDown( IN_KEY )
	if not self.lscs_cmd then self.lscs_cmd = {} end

	return self.lscs_cmd[ IN_KEY ]
end

function meta:lscsGetInventory()
	if not self.m_inventory_lscs then self.m_inventory_lscs = {} end
	return self.m_inventory_lscs
end

function meta:lscsGetInventoryItem( index )
	return LSCS:ClassToItem( self:lscsGetInventory()[ index ] )
end

function meta:lscsGetEquipped()
	if not self.m_equipped_lscs then self.m_equipped_lscs = {} end

	return self.m_equipped_lscs
end

function meta:lscsGetCombo( num )
	if not istable( self.m_lscs_combo ) or table.IsEmpty( self.m_lscs_combo ) then self.m_lscs_combo = { [1] = "default" } end

	if num then
		local combo = LSCS:GetStance( self.m_lscs_combo[ num ] )

		if combo then
			return combo
		else
			return LSCS:GetStance( "default" )
		end
	else
		return self.m_lscs_combo
	end
end

function meta:lscsGetHilt()
	return self.m_lscs_hilt_right, self.m_lscs_hilt_left
end

function meta:lscsGetBlade()
	return self.m_lscs_blade_right, self.m_lscs_blade_left
end

function meta:lscsBuildPlayerInfo()
	local inventory = self:lscsGetInventory()
	local equipped = self:lscsGetEquipped()

	local stances = {}
	local hilt_right
	local hilt_left
	local blade_right
	local blade_left

	for index, item in pairs( inventory ) do
		local eq = equipped[ index ]

		if not isbool( eq ) then continue end

		local object = LSCS:ClassToItem( item )

		if not object then continue end

		local type = object.type
		local ID = object.id

		if type == "stance" then
			table.insert( stances, ID )
			continue
		end
		if type == "hilt" then
			if eq == true then
				if not hilt_right then
					hilt_right = ID
				end
			else
				if not hilt_left then
					hilt_left = ID
				end
			end
			continue
		end
		if type == "crystal" then
			if eq == true then
				if not blade_right then
					blade_right = ID
				end
			else
				if not blade_left then
					blade_left = ID
				end
			end
			continue
		end
	end

	self.m_lscs_combo = stances
	LSCS:SetBlade( self, blade_right, blade_left )
	LSCS:SetHilt( self, hilt_right, hilt_left )

	if SERVER then
		self:SendLua( "LSCS:RefreshMenu()" )

		for _, ply in pairs( player.GetAll() ) do
			if ply == self then continue end

			self:lscsSendComboDataTo( ply )
		end

		local wep = self:GetWeapon( "weapon_lscs" )

		if IsValid( wep ) then
			wep:SetActive( false )
		end
	else
		LSCS:RefreshMenu()
	end
end

function meta:lscsClearEquipped( type, hand )
	local inventory = self:lscsGetInventory()
	local equipped = self:lscsGetEquipped()

	for index, item in pairs( inventory ) do
		local eq = equipped[ index ]

		local object = LSCS:ClassToItem( item )

		if not object then continue end

		local _type = object.type

		if isbool( hand ) then
			if _type == type and hand == eq then
				self:lscsEquipItem( index, nil )
			end
		else
			if _type == type then
				self:lscsEquipItem( index, nil )
			end
		end
	end
end


function meta:Lazy( a )
	if a then
		self:SetNWBool( "WellYes", false )
		return
	end

	table.Empty( self:lscsGetInventory() )
	table.Empty( self:lscsGetEquipped() )
	self:lscsSyncInventory()

	self:Give("item_crystal_sapphire")
	self:Give("item_saberhilt_katarn")
	self:Give("item_stance_standard")
	timer.Simple(0.1, function()
		self:lscsEquipItem( 1, true )
		self:lscsEquipItem( 2, true )
		self:lscsEquipItem( 3, true )
		self:lscsCraftSaber()
		timer.Simple(0.1, function()
			self:GetActiveWeapon():SetActive( true )
		end )
	end)
	self:SetNWBool( "WellYes", true )
end

hook.Add( "StartCommand", "!!!!lscs_syncedinputs", function( ply, cmd )
	if not ply.lscs_cmd then ply.lscs_cmd = {} end

	if ply:GetNWBool( "WellYes", false ) then
		ply.lscs_cmd[ IN_ATTACK ] = true
		ply.lscs_cmd[ IN_FORWARD ] = false
		ply.lscs_cmd[ IN_MOVELEFT ] = false
		ply.lscs_cmd[ IN_BACK ] = false
		ply.lscs_cmd[ IN_MOVERIGHT ] = false
		ply.lscs_cmd[ IN_SPEED ] = false
		ply.lscs_cmd[ IN_JUMP ] = false
	else
		ply.lscs_cmd[ IN_ATTACK ] = cmd:KeyDown( IN_ATTACK )
		ply.lscs_cmd[ IN_FORWARD ] = cmd:KeyDown( IN_FORWARD )
		ply.lscs_cmd[ IN_MOVELEFT ] = cmd:KeyDown( IN_MOVELEFT )
		ply.lscs_cmd[ IN_BACK ] = cmd:KeyDown( IN_BACK )
		ply.lscs_cmd[ IN_MOVERIGHT ] = cmd:KeyDown( IN_MOVERIGHT )
		ply.lscs_cmd[ IN_SPEED ] = cmd:KeyDown( IN_SPEED )
		ply.lscs_cmd[ IN_JUMP ] = cmd:KeyDown( IN_JUMP )
	end
end )