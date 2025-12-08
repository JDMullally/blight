extends Node

enum Element {Water, Love, Light, Song}

signal update_poly(polygon : PackedVector2Array, percentage_area : float, element : Element)
signal select_spell(element : Element)
signal cast_spell(element : Element, castable : bool)
signal spell_error_message(element : Element)
signal update_prog_bars(water_prog : float, love_prog : float, light_prog : float, song_prog : float)
signal hurt_player(damage : int, g_position : Vector2)
signal unlock_spell(element : Element)
signal update_spell_stats(element : Element, damage : float, pierce : float, speed : float, duration : float, cooldown : float)
signal game_win_screen
signal game_over_screen
signal update_player_health(value : int)
signal complete_shrine
signal update_player_text
signal allow_spell_crafting
signal stop_spell_crafting
signal update_sprint_progress
signal scroll_up
signal scroll_down
signal increase_player_healing(value : int)
signal reduce_player_healing
signal update_survival_bar(value : float)
signal debuff_shrine(element : Element)
signal create_powerup_at_location(global_pos : Vector2)
