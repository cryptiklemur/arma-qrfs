#include "script_component.hpp"

_this spawn {
	params ["_type", "_vehicle", "_targetPos", "_grp1", "_grp2", "_vehicleCrewCount", "_pos", "_targetMarker", "_distance", "_land", "_waitUntil"];
	private ["_wp1", "_wp2"];

	_vehicle setBehaviour "CARELESS";
	(driver _vehicle) setBehaviour "CARELESS";
	_vehicle disableAI "TARGET";
	_vehicle disableAI "AUTOTARGET";
	_vehicle allowFleeing 0;
	_vehicle doMove _targetPos;

	// Wait for position to be the same for 5 seconds
	private _successes = 0;
	private _previousPos = getPosATL _vehicle;
	waitUntil {
		sleep 1;
		private _currentPos = getPosATL _vehicle;
		private _checkDistance = 260;
		if (_type == "land") then {
			_checkDistance = 10;
		};
		if (_vehicle distance _targetPos <= _checkDistance) exitWith {true};

		if (_previousPos distance _currentPos < 3) then {
			_vehicle doMove _targetPos;
			_successes = _successes + 1;
		} else {
			_successes = 0;
		};
		_previousPos = _currentPos;

		_successes >= 5;
	};

	doStop _vehicle;
	_vehicle land _land;
	waitUntil { sleep 2; call _waitUntil };
	_vehicle setFuel 0;

	_grp2 leaveVehicle _vehicle;
	{
		unassignVehicle _x;
		moveOut _x;
		_x setBehaviour "COMBAT";
		_x setUnitPos "UP";
	} forEach units _grp2;

	_grp2 setCombatMode "RED";

	waitUntil { sleep 2; count (crew _vehicle) <= _vehicleCrewCount };

	if (_type == "land") then {
		private _newDir = (direction _vehicle) - 180;
		_vehicle setDir _newDir;
		_vehicle setFormDir _newDir;
		_grp1 setFormDir _newDir;
	};
	_vehicle doMove _pos;

	if (alive _vehicle) then {
		_vehicle setFuel 1;
	};

	_wp2 = _grp2 addWaypoint [_targetMarker getPos [0, 0], 0];
	_wp2 setWaypointType "SAD";
	_wp2 setWaypointBehaviour "COMBAT";
	_wp2 setWaypointCombatMode "RED";
	_wp2 setWaypointFormation "DIAMOND";
	_wp2 setWaypointSpeed "FULL";
	_wp2 setWaypointVisible true;

	waitUntil { sleep 5; _vehicle distance _pos <= 50 };

	if (!isNil "REKA60padArray" && {(_vehicle distance _targetPos) > 50}) then {
		REKA60padArray = REKA60padArray - [_targetPos];
	};

	{ _vehicle deleteVehicleCrew _x } forEach crew _vehicle;
	deleteVehicle _vehicle;
	waitUntil { sleep 1; (count units _grp1) == 0 };
	deleteGroup _grp1;
};
