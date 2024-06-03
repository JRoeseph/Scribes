class_name ScoreAnimation
extends Node

## Reference to the board for getting tile locations
@export var board: Board

## Reference to the tile highlight that appears when tallying score
@export var tile_highlight: Node

## Reference to the score display
@export var score_display: Label

## The score for the current turn
var turn_score: float

## The scores for each word made this turn
var turn_scores: Array[float]


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_highlight.visible = false


## Called at the start of end of turn scoring
func start_turn_scoring() -> void:
	turn_scores.clear()
	turn_score = 0
	update_score_display()


## Called to wrap up scoring
func end_turn_scoring() -> void:
	tile_highlight.visible = false


## Called to iterate through the letters of a word to perform the scoring animations
func animate_word_scoring(animated_word: Word) -> void:
	turn_scores.append(0)
	var x_index = animated_word.start_location[0]
	var y_index = animated_word.start_location[1]
	for i in range(animated_word.length):
		tile_highlight.global_position = board.spaces[x_index][y_index].global_position
		tile_highlight.visible = true
		turn_scores[-1] += animated_word.tiles[i].value
		turn_score += animated_word.tiles[i].value
		update_score_display()
		await get_tree().create_timer(0.5).timeout
		x_index += 1 if animated_word.is_horizontal else 0
		y_index += 1 if !animated_word.is_horizontal else 0


## Called to update the score display
func update_score_display() -> void:
	score_display.text = "SCORE: " + str(turn_score)
	for word in turn_scores:
		score_display.text += "\n +" + str(word)
