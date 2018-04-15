# Global_Player.gd

extends Node

var url_PlayerData = "user://PlayerData.bin"
var inventory = {}
var inventory_maxSlots = 45
onready var playerData = Global_DataParser.load_data(url_PlayerData)


func _ready():
	load_data()


func load_data():
	if (playerData == null):
		var dict = {"inventory":{}}
		for slot in range (0, inventory_maxSlots):
			dict["inventory"][String(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_PlayerData, dict)
		inventory = dict["inventory"]
	else:
		inventory = playerData["inventory"]


func save_data():
	Global_DataParser.write_data(url_PlayerData, {"inventory": inventory})

func inventory_getItem(slot):
	return inventory[String(slot)]

func inventory_getEmptySlot():
	for slot in range(0, inventory_maxSlots):
		if (inventory[String(slot)]["id"] == "0"): 
			return int(slot)
	print ("Inventory is full!")
	return -1

func inventory_splitItem(slot, split_amount):
	var emptySlot = inventory_getEmptySlot()
	if emptySlot < 0:
		return emptySlot
		
	var new_amount = int(inventory_getItem(slot)["amount"]) - split_amount
	inventory[String(slot)]["amount"] = new_amount
	inventory[String(emptySlot)] = {"id": inventory[String(slot)]["id"], "amount": split_amount}
	return emptySlot

func inventory_addItem(itemId):
	var itemData = Global_ItemDatabase.get_item(String(itemId))
	if (itemData == null): 
		return -1
	if (int(itemData["stack_limit"]) <= 1):
		var slot = inventory_getEmptySlot()
		if (slot < 0): 
			return -1
		inventory[String(slot)] = {"id": String(itemId), "amount": 1}
		return slot
		
	
	for slot in range (0, inventory_maxSlots):
		if (inventory[String(slot)]["id"] == String(itemId)):
			if (int(itemData["stack_limit"]) > int(inventory[String(slot)]["amount"])):
				inventory[String(slot)]["amount"] = int(inventory[String(slot)]["amount"] + 1)
				return slot

	var slot = inventory_getEmptySlot()
	if (slot < 0): 
		return -1
	inventory[String(slot)] = {"id": String(itemId), "amount": 1}
	return slot


func inventory_removeItem(slot):
	var newAmount = inventory[String(slot)]["amount"] - 1
	if (newAmount < 1):
		inventory[String(slot)] = {"id": "0", "amount": 0}
		return 0
	inventory[String(slot)]["amount"] = newAmount
	return newAmount


func inventory_moveItem(fromSlot, toSlot):
	var temp_ToSlotItem = inventory[String(toSlot)]
	inventory[String(toSlot)] = inventory[String(fromSlot)]
	inventory[String(fromSlot)] = temp_ToSlotItem
