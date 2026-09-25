#include "script_component.hpp"

// Example [(thisList select 0), _classname, _units, _origin, _distance, _dropoffDistance, _side] call QFUNC(callInQRF);
if (!isServer) exitWith {};
private ["_dir", "_e1", "_vehSpots", "_man", "_type", "_special", "_land", "_waitUntil"];

private _tPos = param [0];
private _classname = param [1];
private _units = param [2];
private _origin = param [3];
private _distance = param [4];
private _dropoffDistance = param [5];
private _side = param [6, east];
private _grpSize = count _units;
private _targetMarker = param [0];

if (typeName _origin == "STRING") then {
	_dir = random 360;
} else {
	_dir = _origin;
};

//Side related group creation:
private _grp1 = createGroup _side;
private _grp2 = createGroup _side;

if (_classname isKindOf "Helicopter") then {
	_type = "air";
	_special = "FLY";
	_land = "LAND";
	_waitUntil = {(getPos _vehicle) select 2 <= 7};
} else {
	if (_classname isKindOf "Car" || _classname isKindOf "Tank") then {
		_type = "land";
		_special = "NONE";
		_land = "GET OUT";
		_waitUntil = {true};
	} else {
		if (true) exitWith {
			["Invalid classname: %1", _classname] call BIS_fnc_error;

			false
		};
	};
};

private _targetPos = [_tPos, _dropoffDistance, _dir, _type] call FUNC(getTargetPosition);
if (_targetPos isEqualTo objNull) exitWith {
	["Could not find valid %1 position to drop units off within %2m of %3 at bearing %4", _type, _dropoffDistance, _tPos, _dir] call BIS_fnc_error;

	false
};

[_targetPos, _distance] call FUNC(spawnSmoke);
[_type, _classname, _units, _targetPos, _dir, _distance, _special, _grp1, _grp2] call FUNC(spawnVehicle) params ["_vehicle", "_vehicleCrewCount", "_pos"];
[_type, _vehicle, _targetPos, _grp1, _grp2, _vehicleCrewCount, _pos, _targetMarker, _distance, _land, _waitUntil] call FUNC(moveVehicleAndDismount);
