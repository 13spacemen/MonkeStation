/mob/living/carbon/monkey/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-m")

/mob/living/carbon/monkey/dust_animation()
	new /obj/effect/temp_visual/dust_animation(loc, "dust-m")

/mob/living/carbon/monkey/death(gibbed)
	SSmove_manager.stop_looping(src) // Stops dead monkeys from fleeing their attacker or climbing out from inside His Grace
	. = ..()
