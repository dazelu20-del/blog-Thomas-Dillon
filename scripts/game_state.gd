extends Node

enum ReturnReason { FRESH, DIED, QUIT }

var return_reason := ReturnReason.FRESH

func set_died() -> void:
	return_reason = ReturnReason.DIED

func set_quit() -> void:
	return_reason = ReturnReason.QUIT

func set_fresh() -> void:
	return_reason = ReturnReason.FRESH
