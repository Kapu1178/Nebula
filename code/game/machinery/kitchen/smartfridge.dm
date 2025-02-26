
/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "fridge_sci"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5
	active_power_usage = 100
	atom_flags = ATOM_FLAG_NO_CHEM_CHANGE
	obj_flags = OBJ_FLAG_ANCHORABLE | OBJ_FLAG_ROTATABLE
	atmos_canpass = CANPASS_NEVER
	required_interaction_dexterity = DEXTERITY_SIMPLE_MACHINES

	var/icon_base = "fridge_sci"
	var/icon_contents = "chem"
	var/list/item_records = list()
	var/seconds_electrified = 0;
	var/shoot_inventory = 0
	var/locked = 0
	var/scan_id = 1
	var/is_secure = 0

	construct_state = /decl/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0

/obj/machinery/smartfridge/secure
	is_secure = 1

/obj/machinery/smartfridge/Initialize()
	if(is_secure)
		wires = new/datum/wires/smartfridge/secure(src)
	else
		wires = new/datum/wires/smartfridge(src)
	. = ..()
	queue_icon_update()

/obj/machinery/smartfridge/Destroy()
	for(var/datum/stored_items/S in item_records)
		qdel(S)
	item_records = null
	return ..()

/obj/machinery/smartfridge/get_req_access()
	if(!scan_id)
		return list()
	return ..()

/obj/machinery/smartfridge/proc/accept_check(var/obj/item/O)
	if(istype(O,/obj/item/chems/food/grown/) || istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"

/obj/machinery/smartfridge/seeds/accept_check(var/obj/item/O)
	if(istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_contents = "chem"
	initial_access = list(list(access_medical, access_chemistry))

/obj/machinery/smartfridge/secure/medbay/accept_check(var/obj/item/O)
	if(istype(O,/obj/item/chems/glass))
		return 1
	if(istype(O,/obj/item/storage/pill_bottle))
		return 1
	if(istype(O,/obj/item/chems/pill))
		return 1
	return 0

/obj/machinery/smartfridge/produce
	name = "produce smartfridge"
	desc = "A refrigerated storage unit for fruits and vegetables."

/obj/machinery/smartfridge/produce/accept_check(var/obj/item/O)
	return istype(O, /obj/item/chems/food/grown)

/obj/machinery/smartfridge/sheets
	name = "raw material storage"
	desc = "A storage unit for bundles of material sheets, ingots and other shapes."

/obj/machinery/smartfridge/sheets/accept_check(var/obj/item/O)
	return istype(O, /obj/item/stack/material)

/obj/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."
	icon_contents = "chem"

/obj/machinery/smartfridge/chemistry/accept_check(var/obj/item/O)
	if(istype(O,/obj/item/storage/pill_bottle) || istype(O,/obj/item/chems))
		return 1
	return 0

/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."
	icon_state = "fridge_dark"
	icon_base = "fridge_dark"
	icon_contents = "drink"

/obj/machinery/smartfridge/drinks/accept_check(var/obj/item/O)
	if(istype(O,/obj/item/chems/glass) || istype(O,/obj/item/chems/drinks) || istype(O,/obj/item/chems/condiment))
		return 1

/obj/machinery/smartfridge/foods
	name = "\improper Hot Foods Display"
	desc = "A heated storage unit for piping hot meals."
	icon_state = "fridge_food"
	icon_state = "fridge_food"
	icon_contents = "food"

/obj/machinery/smartfridge/foods/accept_check(var/obj/item/O)
	if(istype(O,/obj/item/chems/food) || istype(O,/obj/item/utensil))
		return 1

/obj/machinery/smartfridge/Process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		src.throw_item()

/obj/machinery/smartfridge/on_update_icon()
	overlays.Cut()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "[icon_base]-off"
	else
		icon_state = icon_base

	if(is_secure)
		overlays += image(icon, "[icon_base]-sidepanel")

	if(panel_open)
		overlays += image(icon, "[icon_base]-panel")

	var/image/I
	var/is_off = ""
	if(inoperable())
		is_off = "-off"

	// Fridge contents
	switch(contents.len - LAZYLEN(component_parts))
		if(0)
			I = image(icon, "empty[is_off]")
		if(1 to 2)
			I = image(icon, "[icon_contents]-1[is_off]")
		if(3 to 5)
			I = image(icon, "[icon_contents]-2[is_off]")
		if(6 to 8)
			I = image(icon, "[icon_contents]-3[is_off]")
		else
			I = image(icon, "[icon_contents]-4[is_off]")
	overlays += I

	// Fridge top
	I = image(icon, "[icon_base]-top")
	I.pixel_z = 32
	I.layer = ABOVE_WINDOW_LAYER
	overlays += I

/obj/machinery/smartfridge/dismantle()
	for(var/datum/stored_items/I in item_records)
		while(I.amount > 0)
			I.get_product(get_turf(src)) // They'd get dumped anyway, but this makes things GC properly.
	..()

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/state_transition(decl/machine_construction/new_state, mob/user)
	. = ..()
	update_icon()

/obj/machinery/smartfridge/attackby(var/obj/item/O, var/mob/user)
	if(accept_check(O))
		if(!user.try_unequip(O))
			return
		stock_item(O)
		user.visible_message("<span class='notice'>\The [user] has added \the [O] to \the [src].</span>", "<span class='notice'>You add \the [O] to \the [src].</span>")
		update_icon()
		return TRUE

	if(istype(O, /obj/item/storage))
		var/obj/item/storage/bag/P = O
		var/plants_loaded = 0
		for(var/obj/G in P.contents)
			if(accept_check(G) && P.remove_from_storage(G, src, 1))
				plants_loaded++
				stock_item(G)
		P.finish_bulk_removal()

		if(plants_loaded)
			user.visible_message("<span class='notice'>\The [user] loads \the [src] with the contents of \the [P].</span>", "<span class='notice'>You load \the [src] with the contents of \the [P].</span>")
			if(P.contents.len > 0)
				to_chat(user, "<span class='notice'>Some items were refused.</span>")
		return TRUE
	return ..()

/obj/machinery/smartfridge/secure/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		emagged = 1
		locked = -1
		req_access.Cut()
		to_chat(user, "You short out the product lock on [src].")
		return 1

/obj/machinery/smartfridge/proc/stock_item(var/obj/item/O)
	for(var/datum/stored_items/I in item_records)
		if(istype(O, I.item_path) && O.name == I.item_name)
			stock(I, O)
			return

	var/datum/stored_items/I = new/datum/stored_items(src, O.type, O.name)
	dd_insertObjectList(item_records, I)
	stock(I, O)

/obj/machinery/smartfridge/proc/stock(var/datum/stored_items/I, var/obj/item/O)
	I.add_product(O)
	SSnano.update_uis(src)

/obj/machinery/smartfridge/interface_interact(mob/user)
	ui_interact(user)
	return TRUE

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["contents"] = null
	data["electrified"] = seconds_electrified > 0
	data["shoot_inventory"] = shoot_inventory
	data["locked"] = locked
	data["secure"] = is_secure

	var/list/items[0]
	for (var/i=1 to length(item_records))
		var/datum/stored_items/I = item_records[i]
		var/count = I.get_amount()
		if(count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(I.item_name)), "vend" = i, "quantity" = count)))

	if(items.len > 0)
		data["contents"] = items

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "smartfridge.tmpl", src.name, 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/smartfridge/Topic(href, href_list)
	if(..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = SSnano.get_open_ui(user, src, "main")

	if(href_list["close"])
		user.unset_machine()
		ui.close()
		return 0

	if(href_list["vend"])
		var/index = text2num(href_list["vend"])
		var/amount = text2num(href_list["amount"])
		var/datum/stored_items/I = item_records[index]
		var/count = I.get_amount()

		// Sanity check, there are probably ways to press the button when it shouldn't be possible.
		if(count > 0)
			if((count - amount) < 0)
				amount = count
			for(var/i = 1 to amount)
				I.get_product(get_turf(src))
				update_icon()

		return 1
	return 0

/obj/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/stored_items/I in src.item_records)
		throw_item = I.get_product(loc)
		if(!QDELETED(throw_item))
			break

	if(QDELETED(throw_item))
		return 0
	spawn(0)
		throw_item.throw_at(target,16,3)
	src.visible_message("<span class='warning'>[src] launches [throw_item.name] at [target.name]!</span>")
	update_icon()
	return 1

/************************
*   Secure SmartFridges
*************************/

/obj/machinery/smartfridge/secure/CanUseTopic(mob/user, datum/topic_state/state, href_list)
	if(!allowed(user) && !emagged && locked != -1 && href_list && href_list["vend"] && scan_id)
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return STATUS_CLOSE
	return ..()