function HasFlag(flags, flag)
   	return ((flags & flag) == flag) 
end

function PlayerHasFlag(player, flag)
   	 return HasFlag(player:vars():Get("admin.flags"), flag)
end

function IsValidWeapon(weapon)
	local weaponlist = {
			"weapon_ak47",
			"weapon_aug",
			"weapon_awp",
			"weapon_bizon",
			"weapon_cz75a",
			"weapon_deagle",
			"weapon_elite",
			"weapon_famas",
			"weapon_fiveseven",
			"weapon_g3sg1",
			"weapon_galilar",
			"weapon_glock",
			"weapon_m249",
			"weapon_m4a1",
			"weapon_mac10",
			"weapon_mag7",
			"weapon_mp5sd",
			"weapon_mp7",
			"weapon_mp9",
			"weapon_negev",
			"weapon_nova",
			"weapon_p2000",
			"weapon_p250",
			"weapon_p90",
			"weapon_sawedoff",
			"weapon_scar20",
			"weapon_sg556",
			"weapon_ssg08",
			"weapon_tec9",
			"weapon_ump45",
			"weapon_usp_silencer",
			"weapon_xm1014",
			"weapon_knife",
			"weapon_flashbang",
			"weapon_hegrenade",
			"weapon_smokegrenade",
			"weapon_molotov",
			"weapon_decoy",
			"weapon_incgrenade",
			"weapon_c4",
			"weapon_healthshot"
	}

	for _, v in ipairs(weaponlist) do
			if weapon == v then return true end
	end

	return false
end