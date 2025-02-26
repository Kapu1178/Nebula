/datum/event/minispasm
	startWhen = 60
	endWhen = 90
	var/static/list/psi_operancy_messages = list(
		"There's something in your skull!",
		"Something is eating your thoughts!",
		"You can feel your brain being rewritten!",
		"Something is crawling over your frontal lobe!",
		"<b>THE SIGNAL THE SIGNAL THE SIGNAL THE SIGNAL THE</b>"
		)

/datum/event/minispasm/announce()
	priority_announcement.Announce( \
		"PRIORITY ALERT: SIGMA-[rand(50,80)] PSIONIC SIGNAL LOCAL TRAMISSION DETECTED (97% MATCH, NONVARIANT) \
		(SIGNAL SOURCE TRIANGULATED ADJACENT LOCAL SITE): All personnel are advised to avoid \
		exposure to active audio transmission equipment including radio headsets and intercoms \
		for the duration of the signal broadcast.", \
		"Cuchulain Sensor Array Automated Message" \
		)

/datum/event/minispasm/start()
	var/list/victims = list()
	for(var/obj/item/radio/radio in global.listening_objects)
		if(radio.on)
			for(var/mob/living/victim in range(radio.canhear_range, radio.loc))
				if(isnull(victims[victim]) && victim.stat == CONSCIOUS && !GET_STATUS(victim, STAT_DEAF))
					victims[victim] = radio
	for(var/thing in victims)
		var/mob/living/victim = thing
		var/obj/item/radio/source = victims[victim]
		do_spasm(victim, source)

/datum/event/minispasm/proc/do_spasm(var/mob/living/victim, var/obj/item/radio/source)
	set waitfor = FALSE

	if(isliving(victim) && !victim.isSynthetic())
		var/list/disabilities = list(NEARSIGHTED, EPILEPSY, TOURETTES, NERVOUS)
		for(var/disability in disabilities)
			if(victim.disabilities & disability)
				disabilities -= disability
		if(disabilities.len)
			victim.disabilities |= pick(disabilities)

	var/datum/ability_handler/psionics/psi = victim.get_ability_handler(/datum/ability_handler/psionics, FALSE)
	if(psi)
		to_chat(victim, SPAN_DANGER("A hauntingly familiar sound hisses from [html_icon(source)] \the [source], and your vision flickers!"))
		psi.backblast(rand(5,15))
		SET_STATUS_MAX(victim, STAT_PARA, 5)
		ADJ_STATUS(victim, STAT_JITTER, 100)
	else
		to_chat(victim, SPAN_DANGER("An indescribable, brain-tearing sound hisses from [html_icon(source)] \the [source], and you collapse in a seizure!"))
		victim.seizure()
		var/new_latencies = rand(2,4)
		var/list/faculties = list(PSI_COERCION, PSI_REDACTION, PSI_ENERGISTICS, PSI_PSYCHOKINESIS)
		for(var/i = 1 to new_latencies)
			to_chat(victim, SPAN_DANGER("<font size = 3>[pick(psi_operancy_messages)]</font>"))
			victim.adjustBrainLoss(rand(10,20))
			victim.set_psi_rank(pick_n_take(faculties), 1)
			sleep(30)
		psi = victim.get_ability_handler(/datum/ability_handler/psionics, FALSE)
		psi?.update()
	sleep(45)
	psi?.check_latency_trigger(100, "a psionic scream", redactive = TRUE)

/datum/event/minispasm/end()
	priority_announcement.Announce( \
		"PRIORITY ALERT: SIGNAL BROADCAST HAS CEASED. Personnel are cleared to resume use of non-hardened radio transmission equipment. Have a nice day.", \
		"Cuchulain Sensor Array Automated Message" \
		)
