AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_effects.lua" )
AddCSLuaFile( "cl_worldmodel.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_combo.lua" )
AddCSLuaFile( "sh_animations.lua" )
AddCSLuaFile( "sh_blockpoints.lua" )
include( "shared.lua" )
include("sh_combo.lua")
include("sh_animations.lua")
include("sv_blocking.lua")
include("sh_blockpoints.lua")

function SWEP:Reload()
	if (self.NextReload or 0) > CurTime() then return end

	self.NextReload = CurTime() + 1

	self:SetActive( not self:GetActive() )
end

function SWEP:OnActiveChanged( oldActive, active )
	if oldActive == nil then return end

	if not self.IdleSound then return end

	if active then
		self.SaberHumSound = CreateSound(self, self.IdleSound)
		self.SaberHumSound:Play()
	else
		self:StopIdleSound()
	end
end

function SWEP:OnTick( active )
	local CurTime = CurTime()

	if (self.Next_Think or 0) > CurTime then return end

	if self.SaberHumSound then
		local go = self:GetDMGActive()

		self.SaberHumSound:ChangeVolume( go and 0 or 1, 0.4 )
		self.SaberHumSound:ChangePitch( go and 140 or 100, 0.2 )
	end

	self.Next_Think = CurTime + 0.05
end

function SWEP:StopIdleSound()
	if self.SaberHumSound then
		self.SaberHumSound:Stop()
		self.SaberHumSound = nil
	end
end

function SWEP:OnRemove()
	self:StopIdleSound()
end

function SWEP:OnDrop()
	self:FinishCombo()
	self:SetActive( false )
	self:SetLength( 0 )
	self:StopIdleSound()

	local ply = self:GetOwner()
	if IsValid( ply ) and ply:IsPlayer() then
		ply:lscsSetShouldBleed( true )
	end
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:EmitSoundUnpredicted( sound )
	--break default prediction because if client/server go slightly out of sync the sounds will not play at all or will play twice.
	--imo having serverside sounds with lag is better than having no sounds at all

	timer.Simple(0, function()
		if not IsValid( self ) then return end
		self:EmitSound( sound )
	end)
end