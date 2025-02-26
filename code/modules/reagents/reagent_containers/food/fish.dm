/obj/item/chems/food/fish
	name = "fillet"
	desc = "A fillet of fish."
	icon_state = "fishfillet"
	filling_color = "#ffdefe"
	center_of_mass = @'{"x":17,"y":13}'
	bitesize = 6
	nutriment_amt = 6
	nutriment_type = /decl/material/liquid/nutriment/protein
	drying_wetness = 60
	dried_type = /obj/item/chems/food/jerky/fish
	backyard_grilling_product = /obj/item/chems/food/fish/grilled
	backyard_grilling_announcement = "steams gently."
	var/fish_type = "fish"

/obj/item/chems/food/fish/Initialize()
	. = ..()
	name = "[fish_type] [initial(name)]"

// This will remove carp poison etc. Deliberate, meant to be similar to preparing pufferfish.
/obj/item/chems/food/fish/attackby(var/obj/item/W, var/mob/user)
	if(is_sharp(W) && (locate(/obj/structure/table) in loc))
		var/mob/M = loc
		if(istype(M) && !M.try_unequip(src))
			return

		var/toxin_amt = REAGENT_VOLUME(reagents, /decl/material/liquid/carpotoxin)
		if(toxin_amt && !prob(user.skill_fail_chance(SKILL_COOKING, 100, SKILL_PROF)))
			remove_from_reagents(/decl/material/liquid/carpotoxin, toxin_amt)
		user.visible_message("<span class='notice'>\The [user] slices \the [src] into thin strips.</span>")

		var/transfer_amt = FLOOR(reagents.total_volume * 0.3)
		for(var/i = 1 to 3)
			var/obj/item/chems/food/sashimi/sashimi = new(get_turf(src), fish_type)
			reagents.trans_to(sashimi, transfer_amt)
		qdel(src)

	else
		..()

/obj/item/chems/food/fish/grilled
	name = "grilled fish fillet"
	desc = "A lightly grilled fish fillet."
	icon_state = "grilledfish"
	nutriment_amt = 8
	bitesize = 2
	nutriment_desc = list("flaky grilled fish" = 5)
	fish_type = "grilled fish"
	drying_wetness = 0
	dried_type = null
	backyard_grilling_product = null
	backyard_grilling_announcement = null

/obj/item/chems/food/fish/poison
	fish_type = "space carp"

/obj/item/chems/food/fish/poison/populate_reagents()
	. = ..()
	add_to_reagents(/decl/material/liquid/carpotoxin, 6)

/obj/item/chems/food/fish/shark
	fish_type = "shark"

/obj/item/chems/food/fish/carp
	fish_type = "carp"

/obj/item/chems/food/fish/octopus
	fish_type = "tako"

/obj/item/chems/food/fish/mollusc
	name = "meat"
	desc = "Some slimy meat from clams or molluscs."
	fish_type = "mollusc"
	nutriment_type = /decl/material/liquid/nutriment/slime_meat

/obj/item/chems/food/fish/mollusc/clam
	fish_type = "clam"

/obj/item/chems/food/fish/mollusc/barnacle
	fish_type = "barnacle"


// Molluscs!
/obj/item/trash/mollusc_shell
	name = "mollusc shell"
	icon = 'icons/obj/molluscs.dmi'
	icon_state = "mollusc_shell"
	desc = "The cracked shell of an unfortunate mollusc."
	material = /decl/material/solid/organic/bone

/obj/item/trash/mollusc_shell/clam
	name = "clamshell"
	icon_state = "clam_shell"

/obj/item/trash/mollusc_shell/barnacle
	name = "barnacle shell"
	icon_state = "barnacle_shell"

/obj/item/mollusc
	name = "mollusc"
	desc = "A small slimy mollusc. Fresh!"
	icon = 'icons/obj/molluscs.dmi'
	icon_state = "mollusc"
	w_class = ITEM_SIZE_TINY
	material = /decl/material/liquid/nutriment/slime_meat
	matter = list(
		/decl/material/solid/organic/bone/fish = MATTER_AMOUNT_SECONDARY,
	)
	var/meat_type = /obj/item/chems/food/fish/mollusc
	var/shell_type = /obj/item/trash/mollusc_shell

/obj/item/mollusc/barnacle
	name = "barnacle"
	desc = "A hull barnacle, probably freshly scraped off a spaceship."
	icon_state = "barnacle"
	meat_type = /obj/item/chems/food/fish/mollusc/barnacle
	shell_type = /obj/item/trash/mollusc_shell/barnacle

/obj/item/mollusc/clam
	name = "clam"
	desc = "A free-ranging space clam."
	icon_state = "clam"
	meat_type = /obj/item/chems/food/fish/mollusc/clam
	shell_type = /obj/item/trash/mollusc_shell/clam

/obj/item/mollusc/proc/crack_shell(var/mob/user)
	playsound(loc, "fracture", 80, 1)
	if(user && loc == user)
		user.drop_from_inventory(src)
	if(meat_type)
		var/obj/item/meat = new meat_type(get_turf(src))
		if(user)
			user.put_in_hands(meat)
	if(shell_type)
		var/obj/item/shell = new shell_type(get_turf(src))
		if(user)
			user.put_in_hands(shell)
	qdel(src)

/obj/item/mollusc/attackby(var/obj/item/thing, var/mob/user)
	if(thing.sharp || thing.edge)
		user.visible_message(SPAN_NOTICE("\The [user] cracks open \the [src] with \the [thing]."))
		crack_shell(user)
		return
	. = ..()
