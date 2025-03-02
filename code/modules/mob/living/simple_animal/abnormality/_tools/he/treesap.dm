#define STATUS_EFFECT_TREESAP /datum/status_effect/treesap
#define STATUS_EFFECT_BOOMSAP /datum/status_effect/boomsap
/obj/structure/toolabnormality/treesap
	name = "giant tree sap"
	desc = "A small bottle of red liquid."
	icon_state = "treesap"
	var/list/used = list()

/obj/structure/toolabnormality/treesap/Initialize()
	..()
	addtimer(CALLBACK(src, .proc/reset), 20 MINUTES)

/obj/structure/toolabnormality/treesap/proc/reset()
	addtimer(CALLBACK(src, .proc/reset), 20 MINUTES)
	used = list()

	for(var/mob/living/carbon/human/L in GLOB.player_list)
		if(L.stat >= HARD_CRIT || L.sanity_lost || z != L.z) // Dead or in hard crit, insane, or on a different Z level.
			continue
		to_chat(L, "<span class='danger'>The Tree Sap is replenished.</span>")

/obj/structure/toolabnormality/treesap/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(!do_after(user, 6))
		return
	to_chat(user, "<span class='danger'>You sip of the sap.</span>")
	used+=user

	if(user in used)
		if(prob(20))
			user.apply_status_effect(STATUS_EFFECT_BOOMSAP)
		else
			user.apply_status_effect(STATUS_EFFECT_TREESAP)
	else
		user.apply_status_effect(STATUS_EFFECT_TREESAP)


// Status Effect
/datum/status_effect/treesap
	id = "treesap"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 60 SECONDS
	alert_type = null

/datum/status_effect/treesap/tick()
	. = ..()
	owner.adjustBruteLoss(-12) // Heals 10 HP per tick in LC, so this really should be 20


// Status Effect
/datum/status_effect/boomsap
	id = "boomsap"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 20 SECONDS
	alert_type = null

/datum/status_effect/boomsap/tick()
	. = ..()
	owner.adjustBruteLoss(-12) // Heals 10 HP per tick in LC, so this really should be 20

/datum/status_effect/boomsap/on_remove()
	. = ..()
	owner.gib()
	for(var/mob/living/carbon/human/L in livinginrange(10, src))
		L.apply_damage((60), WHITE_DAMAGE, null, L.run_armor_check(null, WHITE_DAMAGE), spread_damage = TRUE)
		to_chat(L, "<span class='danger'>Oh god, what the fuck was that!?</span>")

#undef STATUS_EFFECT_TREESAP
#undef STATUS_EFFECT_BOOMSAP
