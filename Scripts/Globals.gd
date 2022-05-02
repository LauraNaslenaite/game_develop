extends Node2D

#2D grid holding textual representation of constanly changing grid 
var grid = []

#grid measurements used for the grid 
var offset = 128
var column_num = 3
var row_num = 6
var x_start = 160
var y_start =900

#if true - difficult mode
#   false - easy mode
var level_difficulty = true
