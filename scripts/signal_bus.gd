extends Node

enum Element {Water, Love, Light, Song}

signal update_poly(polygon : PackedVector2Array, percentage_area : float, element : Element)
signal select_spell(element : Element)
signal cast_spell(element : Element, castable : bool)
signal spell_error_message(element : Element)
signal update_prog_bars(water_prog : float, love_prog : float, light_prog : float, song_prog : float)
signal hurt_player(damage : int, g_position : Vector2)
signal unlock_spell(element : Element)
