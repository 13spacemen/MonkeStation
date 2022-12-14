/*
        Ported from /vg/station:
        https://github.com/vgstation-coders/vgstation13/blob/Bleeding-Edge/code/game/objects/items/devices/sound_synth.dm
*/

/obj/item/soundsynth
    name = "sound synthesizer"
    desc = "A device that is able to create sounds."
    icon = 'icons/obj/radio.dmi'
    icon_state = "radio"
    item_state = "radio"
    w_class = WEIGHT_CLASS_TINY
    siemens_coefficient = 1

    var/tmp/spam_flag = 0 //To prevent mashing the button to cause annoyance like a huge idiot.
    var/selected_sound = "sound/items/bikehorn.ogg"
    var/shiftpitch = 1
    var/volume = 50

    var/list/sound_list = list( //How I would like to add tabbing to make this not as messy, but BYOND doesn't like that.
    "Honk" = "selected_sound=sound/items/bikehorn.ogg&shiftpitch=1&volume=50",
    "Applause" = "selected_sound=sound/effects/applause.ogg&shiftpitch=1&volume=65",
    "Laughter" = "selected_sound=sound/effects/laughtrack.ogg&shiftpitch=1&volume=65",
    "Rimshot" = "selected_sound=sound/effects/rimshot.ogg&shiftpitch=1&volume=65",
    "Trombone" = "selected_sound=sound/misc/sadtrombone.ogg&shiftpitch=1&volume=50",
    "Airhorn" = "selected_sound=sound/items/airhorn.ogg&shiftpitch=1&volume=50",
    "Alert" = "selected_sound=sound/effects/alert.ogg&shiftpitch=1&volume=50",
    "Boom" = "selected_sound=sound/effects/explosion1.ogg&shiftpitch=1&volume=50",
    "Boom from Afar" = "selected_sound=sound/effects/explosionfar.ogg&shiftpitch=1&volume=50",
    "Bubbles" = "selected_sound=sound/effects/bubbles.ogg&shiftpitch=1&volume=50",
    "Countdown" = "selected_sound=sound/ambience/countdown.ogg&shiftpitch=0&volume=55",
    "Creepy Whisper" = "selected_sound=sound/hallucinations/turn_around1.ogg&shiftpitch=1&volume=50",
    "Ding" = "selected_sound=sound/machines/ding.ogg&shiftpitch=1&volume=50",
    "Bwoink" = "selected_sound=sound/effects/adminhelp.ogg&shiftpitch=1&volume=50",
    "Double Beep" = "selected_sound=sound/machines/twobeep.ogg&shiftpitch=1&volume=50",
    "Flush" = "selected_sound=sound/machines/disposalflush.ogg&shiftpitch=1&volume=40",
    "Kawaii" = "selected_sound=sound/ai/default/animes.ogg&shiftpitch=0&volume=60",
    "Startup" = "selected_sound=sound/mecha/nominal.ogg&shiftpitch=0&volume=50",
    "Welding Noises" = "selected_sound=sound/items/welder.ogg&shiftpitch=1&volume=55",
    "Short Slide Whistle" = "selected_sound=sound/effects/slide_whistle_short.ogg&shiftpitch=1&volume=50",
    "Long Slide Whistle" = "selected_sound=sound/effects/slide_whistle_long.ogg&shiftpitch=1&volume=50",
    "YEET" = "selected_sound=sound/effects/yeet.ogg&shiftpitch=1&volume=50",
    "Time Stop" = "selected_sound=sound/magic/timeparadox2.ogg&shiftpitch=0&volume=80",
    "Click" = "selected_sound=sound/machines/click.ogg&shiftpitch=0&volume=80",
    "Booing" = "selected_sound=sound/effects/audience-boo.ogg&shiftpitch=0&volume=80",
    "Awwing" = "selected_sound=sound/effects/audience-aww.ogg&shiftpitch=0&volume=80",
    "Gasping" = "selected_sound=sound/effects/audience-gasp.ogg&shiftpitch=0&volume=80",
    "Oohing" = "selected_sound=sound/effects/audience-ooh.ogg&shiftpitch=0&volume=80"
    )

/obj/item/soundsynth/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/soundsynth()
	), SHELL_CAPACITY_SMALL)

/obj/item/soundsynth/verb/pick_sound()
    set category = "Object"
    set name = "Select Sound Playback"
    var/thesoundthatwewant = input("Pick a sound:", null) as null|anything in sound_list
    if(!thesoundthatwewant)
        return
    to_chat(usr, "Sound playback set to: [thesoundthatwewant]!")
    var/list/assblast = params2list(sound_list[thesoundthatwewant])
    selected_sound = assblast["selected_sound"]
    shiftpitch = text2num(assblast["shiftpitch"])
    volume = text2num(assblast["volume"])

/obj/item/soundsynth/attack_self(mob/user as mob)
	if(spam_flag + 2 SECONDS < world.timeofday)
		playsound(src, selected_sound, volume, shiftpitch)
		SEND_SIGNAL(src, COMSIG_SOUNDSYNTH_USED)
		spam_flag = world.timeofday


/obj/item/soundsynth/AltClick(mob/living/carbon/user)
	pick_sound()

/obj/item/soundsynth/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
    if(M == user)
        pick_sound()
    else if(spam_flag + 2 SECONDS < world.timeofday)
        M.playsound_local(get_turf(src), selected_sound, volume, shiftpitch)
        spam_flag = world.timeofday
        //to_chat(M, selected_sound) //this doesn't actually go to their chat very much at all.

/obj/item/circuit_component/soundsynth
	display_name = "Sound Synthesizer"
	display_desc = "Play funny sounds."

	var/datum/port/input/soundtoplay
	var/datum/port/input/play
	var/datum/port/output/played

/obj/item/circuit_component/soundsynth/Initialize(mapload)
	. = ..()
	soundtoplay = add_input_port("Sound", PORT_TYPE_STRING)
	play = add_input_port("Play Sound", PORT_TYPE_SIGNAL)
	played = add_output_port("Sound Played", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/soundsynth/Destroy()
	soundtoplay = null
	play = null
	played = null
	return ..()

/obj/item/circuit_component/soundsynth/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_SOUNDSYNTH_USED, .proc/on_soundsynth_used)

/obj/item/circuit_component/soundsynth/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_SOUNDSYNTH_USED)

/**
 * Called when the Sound Synth is used
 */
/obj/item/circuit_component/soundsynth/proc/on_soundsynth_used(atom/source, mob/user)
	SIGNAL_HANDLER
	played.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/soundsynth/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/obj/item/soundsynth/shell = parent.shell
	if(!shell)
		return
	if(COMPONENT_TRIGGERED_BY(play, port))
		if(shell.spam_flag + 2 SECONDS < world.timeofday)
			SEND_SIGNAL(src, COMSIG_SOUNDSYNTH_USED)
			var/list/sound_list_data = params2list(shell.sound_list[soundtoplay.input_value])
			shell.selected_sound = sound_list_data["selected_sound"]
			shell.shiftpitch = text2num(sound_list_data["shiftpitch"])
			shell.volume = text2num(sound_list_data["volume"])
			playsound(shell, shell.selected_sound, shell.volume, shell.shiftpitch)
			shell.spam_flag = world.timeofday
