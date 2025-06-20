class_name Player
extends Node

var player_name: String
var resources: Dictionary = {
	"wood": 0,
	"brick": 0,
	"sheep": 0,
	"wheat": 0,
	"ore": 0,
}
var victory_points: int = 0

func increment_resource(resource_type: String, amount: int):
	resources[resource_type] += amount

func decrement_resource(resource_type: String, amount: int):
	if resources[resource_type] >= amount:
		resources[resource_type] -= amount

func increment_vp():
	victory_points += 1;
