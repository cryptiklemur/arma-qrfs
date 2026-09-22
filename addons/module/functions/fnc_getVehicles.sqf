#include "script_component.hpp"

params ["_side", "_types", "_notTypes"];
private ["_cfg", "_classname", "_num", "_matchingTypes"];
private _sideId = _side call BIS_fnc_sideID;

[
	configProperties [configFile >> "CfgVehicles", "isClass _x"],
	{
		_cfg = _x;
		_classname = configName _cfg;
		if ("UAV" in _classname) exitWith {false};
		if ("UGV" in _classname) exitWith {false};
		if (getNumber (_cfg >> "scope") != 2) exitWith {false};
		if (count ([_types, {_classname isKindOf _x}] call BIS_fnc_conditionalSelect) <= 0) exitWith {false};
		if (count ([_notTypes, {_classname isKindOf _x}] call BIS_fnc_conditionalSelect) > 0) exitWith {false};
		if (getNumber (_x >> "side") != _sideId) exitWith {false};
		_num = [_classname] call FUNC(cargoSeats);

		if (true) exitWith {_num > 0};
	}
] call BIS_fnc_conditionalSelect;
