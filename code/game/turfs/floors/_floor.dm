/turf/floor
	name = "plating"
	icon = 'icons/turf/flooring/plating.dmi'
	icon_state = "plating"
	permit_ao = TRUE
	thermal_conductivity = 0.040
	heat_capacity = 10000
	explosion_resistance = 1
	turf_flags = TURF_IS_HOLOMAP_PATH
	initial_gas = list(
		/decl/material/gas/oxygen = MOLES_O2STANDARD,
		/decl/material/gas/nitrogen = MOLES_N2STANDARD
	)
	zone_membership_candidate = TRUE

	// Damage to flooring.
	// These are icon state suffixes, NOT booleans!
	var/broken
	var/burnt
	// Plating data.
	var/base_name = "plating"
	var/base_desc = "The naked hull."
	var/base_icon = 'icons/turf/flooring/plating.dmi'
	var/base_icon_state = "plating"
	var/base_color = COLOR_WHITE
	// Flooring data.
	var/flooring_override
	var/initial_flooring
	var/decl/flooring/flooring
	var/lava = 0

/turf/floor/can_climb_from_below(var/mob/climber)
	return TRUE

/turf/floor/is_plating()
	return !flooring

/turf/floor/get_base_movement_delay(var/travel_dir, var/mob/mover)
	return flooring?.get_movement_delay(travel_dir, mover) || ..()

/turf/floor/protects_atom(var/atom/A)
	return (A.level <= LEVEL_BELOW_PLATING && !is_plating()) || ..()

/turf/floor/Initialize(var/ml, var/floortype)
	. = ..(ml)
	if(!floortype && initial_flooring)
		floortype = initial_flooring
	if(floortype)
		set_flooring(GET_DECL(floortype))
	if(!ml)
		RemoveLattice()

/turf/floor/proc/set_flooring(var/decl/flooring/newflooring)
	if(flooring == newflooring)
		return
	make_plating(defer_icon_update = 1)
	flooring = newflooring

	var/check_z_flags
	if(flooring)
		check_z_flags = flooring.z_flags
	else
		check_z_flags = initial(z_flags)

	if(check_z_flags & ZM_MIMIC_BELOW)
		enable_zmimic(check_z_flags)
	else
		disable_zmimic()

	queue_icon_update(SSatoms.initialized) // only update neighbors if we're setting flooring after SSatoms has finished
	levelupdate()
	if(flooring)
		layer = TURF_LAYER

//This proc will set floor_type to null and the update_icon() proc will then change the icon_state of the turf
//This proc auto corrects the grass tiles' siding.
/turf/floor/proc/make_plating(var/place_product, var/defer_icon_update)

	LAZYCLEARLIST(decals)
	for(var/obj/effect/decal/writing/W in src)
		qdel(W)

	SetName(base_name)
	desc = base_desc
	icon = base_icon
	icon_state = base_icon_state
	color = base_color
	layer = PLATING_LAYER

	if(flooring)
		flooring.on_remove()
		if(flooring.build_type && place_product)
			// If build type uses material stack, check for it
			// Because material stack uses different arguments
			// And we need to use build material to spawn stack
			if(ispath(flooring.build_type, /obj/item/stack/material))
				var/decl/material/M = GET_DECL(flooring.build_material)
				if(!M)
					CRASH("[src] at ([x], [y], [z]) cannot create stack because it has a bad build_material path: '[flooring.build_material]'")
				M.create_object(src, flooring.build_cost, flooring.build_type)
			else
				new flooring.build_type(src)
		flooring = null

	set_light(0)
	broken = null
	burnt = null
	flooring_override = null
	levelupdate()

	if(!defer_icon_update)
		update_icon(1)

/turf/floor/can_engrave()
	return (!flooring || flooring.can_engrave)

/turf/floor/shuttle_ceiling
	name = "hull plating"
	icon = 'icons/turf/flooring/tiles.dmi'
	icon_state = "reinforced_light"
	initial_gas = null

/turf/floor/shuttle_ceiling/air
	initial_gas = list(/decl/material/gas/oxygen = MOLES_O2STANDARD, /decl/material/gas/nitrogen = MOLES_N2STANDARD)

/turf/floor/is_floor()
	return TRUE

/turf/floor/on_defilement()
	if(flooring?.type != /decl/flooring/reinforced/cult)
		..()
		set_flooring(GET_DECL(/decl/flooring/reinforced/cult))

/turf/floor/is_defiled()
	return flooring?.type == /decl/flooring/reinforced/cult || ..()

/turf/floor/get_physical_height()
	return flooring?.height || 0

/turf/floor/handle_universal_decay()
	if(!burnt)
		burn_tile()
	else if(flooring)
		break_tile_to_plating()
	else
		ReplaceWithLattice()

/turf/floor/get_footstep_sound(var/mob/caller)
	. = ..() || get_footstep_for_mob(flooring?.footstep_type || /decl/footsteps/blank, caller)
