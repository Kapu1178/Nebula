/obj/item/tool/pickaxe
	name                      = "pickaxe"
	desc                      = "A heavy tool with a pick head for prospecting for minerals, and an axe head for dealing with anyone with a prior claim."
	icon_state                = "preview"
	icon                      = 'icons/obj/items/tool/pickaxe.dmi'
	sharp                     = TRUE
	edge                      = TRUE
	force                     = 15
	handle_material           = /decl/material/solid/organic/wood
	material_force_multiplier = 0.3

/obj/item/tool/pickaxe/get_initial_tool_qualities()
	var/static/list/tool_qualities = list(
		TOOL_PICK   = TOOL_QUALITY_DEFAULT,
		TOOL_SHOVEL = TOOL_QUALITY_MEDIOCRE
	)

/obj/item/tool/pickaxe/titanium
	origin_tech               = @'{"materials":3}'
	material                  = /decl/material/solid/metal/titanium

/obj/item/tool/pickaxe/titanium/get_initial_tool_qualities()
	var/static/list/tool_qualities = list(
		TOOL_PICK   = TOOL_QUALITY_DECENT,
		TOOL_SHOVEL = TOOL_QUALITY_DEFAULT
	)
	return tool_qualities

/obj/item/tool/pickaxe/plasteel
	origin_tech               = @'{"materials":4}'
	material                  = /decl/material/solid/metal/plasteel

/obj/item/tool/pickaxe/plasteel/get_initial_tool_qualities()
	var/static/list/tool_qualities = list(
		TOOL_PICK   = TOOL_QUALITY_GOOD,
		TOOL_SHOVEL = TOOL_QUALITY_DECENT
	)
	return tool_qualities

/obj/item/tool/pickaxe/ocp
	origin_tech               = @'{"materials":6,"engineering":4}'
	material                  = /decl/material/solid/metal/plasteel/ocp

/obj/item/tool/pickaxe/ocp/get_initial_tool_qualities()
	var/static/list/tool_qualities = list(
		TOOL_PICK   = TOOL_QUALITY_BEST,
		TOOL_SHOVEL = TOOL_QUALITY_GOOD
	)
	return tool_qualities
