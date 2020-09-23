extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
#var db_name = "user://test"
var db_name := "res://data/test"
var table_name := "blob_table"

signal output_received(text)
signal texture_received(texture)

func _ready():
	blob_testing()
	#example_of_in_memory_and_foreign_key_support()
	#example_of_call_external_functions()

func cprint(text : String) -> void:
	print(text)
	emit_signal("output_received", text)

func blob_testing():

	# Make a big table containing the variable types.
	var table_dict : Dictionary = Dictionary()
	table_dict["id"] = {"data_type":"int", "primary_key": true, "not_null": true}
	table_dict["data"] = {"data_type":"blob", "not_null": true}

	var texture := preload("res://icon.png")
	var tex_data := texture.get_data().save_png_to_buffer()

	db = SQLite.new()
	db.path = db_name
	db.verbose_mode = true
	# Open the database using the db_name found in the path variable
	db.open_db()
	# Throw away any table that was already present
	db.drop_table(table_name)
	# Create a table with the structure found in table_dict and add it to the database
	db.create_table(table_name, table_dict)

	# Insert a new row in the table
	db.insert_row(table_name, {"id": 1, "data": tex_data})

	var selected_array : Array = db.select_rows(table_name, "", ["data"])

	print(selected_array)

	for selected_row in selected_array:
		var selected_data = selected_row.get("data", PoolByteArray())

		var image := Image.new()
		var _error : int = image.load_png_from_buffer(selected_data)
		var loaded_texture := ImageTexture.new()
		loaded_texture.create_from_image(image)

		print(image)
		print(loaded_texture)

		emit_signal("texture_received", loaded_texture)

	# Close the current database
	db.close_db()
