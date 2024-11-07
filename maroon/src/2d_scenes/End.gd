extends Control

@export var credits: Array[Control] = []
var credits_index: int = 0

func kill() -> void:
	get_tree().quit()


func _on_credits_timer_timeout() -> void:
	if credits_index < credits.size()-1:
		credits[credits_index].hide()
		
		credits_index += 1
		credits[credits_index].show()
	else:
		kill()


func _on_end_lable_timer_timeout() -> void:
	if $EndLable.visible:
		$EndLable.hide()
		$EndLableTimer.stop()
		
		$CreditsTimer.start()
		credits[0].show()
	else:
		$EndLable.show()
