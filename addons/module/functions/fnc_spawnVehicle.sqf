#include "script_component.hpp"

// [_type, _classname, _units, _targetPos, _dir, _distance, _units, _special, _grp1, _grp2] call FUNC(spawnVehicle) params ["_vehicle", "_vehicleCrewCount", "_pos"];
params ["_type", "_classname", "_units", "_targetPos", "_dir", "_distance", "_special", "_grp1", "_grp2"];
private _grpSize = count _units;


private _tPos = [
	(_targetPos select 0) + (sin _dir) * _distance,
	(_targetPos select 1) + (cos _dir) * _distance,
	500
];
private _pos = [_tPos, _type] call FUNC(getBestPosition);
if (_targetPos isEqualTo objNull) exitWith {
	["Could not find valid %1 position to spawn vehicle near %2m", _type, _tPos] call BIS_fnc_error;

	false
};


QRFS_LOG_FULL_2("Spawning %1 at %2", _classname, _pos);
private _vehicle = createVehicle [_classname, _pos, [], 0, _special];
_vehicle setDir (_vehicle getDir _targetPos);

// Set the speed in its current direction to 10 km/h;
_vel = velocity _vehicle;
_dir = direction _vehicle;
_speed = 10;
_vehicle setVelocity [
	(_vel select 0) + (sin _dir * _speed),
	(_vel select 1) + (cos _dir * _speed),
	(_vel select 2)
];

createVehicleCrew _vehicle;
crew _vehicle join _grp1;
private _numCargo = [_classname] call FUNC(cargoSeats);

if (_grpSize > _numCargo) then {
	_vehSpots = _numCargo;
} else {
	_vehSpots = _grpSize;
};

[_vehicle, _targetPos] spawn {
	params ["_vehicle", "_targetPos"];
	waitUntil {sleep 1; !isNil "_vehicle"};
	waitUntil {sleep 1; !canMove _vehicle || isNil "_vehicle"};
	if (true) exitWith {
		if (!isNil "_targetPos" && !isNil "REKA60padArray") then {
			if ((_vehicle distance _targetPos) > 50) then {
				REKA60padArray = REKA60padArray - [_targetPos];
			};
		};
		if (_vehicle distance _targetPos > 200) then {
			{ _vehicle deleteVehicleCrew _x } forEach crew _vehicle;
			sleep 5;
			deleteVehicle _vehicle;
		};
	};
};

private _vehicleCrewCount = count (crew _vehicle);
{
	if (_forEachIndex < _vehSpots) then {
		private _man = _grp2 createUnit [_x, _pos, [], 0, "NONE"];
		_man moveInCargo [_vehicle, _forEachIndex];
		{ _x addCuratorEditableObjects [[_man], true]; } forEach allCurators;
	};
} forEach _units;

{ _x addCuratorEditableObjects [[_vehicle], true]; } forEach allCurators;

[_vehicle, _vehicleCrewCount, _pos]
