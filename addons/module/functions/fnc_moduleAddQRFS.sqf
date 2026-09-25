#include "script_component.hpp"

[{
	params ["_logic", "_synced"];
	private _position = getPos _logic;
	disableSerialization;
	if (isNull (findDisplay 312)) then {
    	if (!isServer) exitWith {};

    	// 3den
    	private _requireSpotted = _logic getVariable "requireSpotted";
    	private _classname = _logic getVariable "classname";
    	private _units = _logic getVariable "units";
    	private _classnameOverride = _logic getVariable ["classnameOverride", ""];
    	private _size = _logic getVariable "objectarea";
    	private _triggerTimeout = _logic getVariable "triggertimeout";
    	private _origin = _logic getVariable "origin";
    	private _spawnDistance = _logic getVariable "spawnDistance";
    	private _dropoffDistance = _logic getVariable "dropoffDistance";
    	private _condition = _logic getVariable "condition";
    	private _triggerArea = _logic getVariable "objectarea";
    	private _sideId = _logic getVariable ["side", 0];
    	private _targetSideId = _logic getVariable ["targetSide", 1];
    	private _side = SIDE_FROM_ID(_sideId);
    	private _targetSide = SIDE_FROM_ID(_targetSideId);
    	_triggerTimeout = [(_triggerTimeout select 0), (_triggerTimeout select 1), (_triggerTimeout select 2), true];

    	if (_classnameOverride != "") then {
    		if (isClass (configFile >> "CfgVehicles" >> _classnameOverride)) then {
    			_classname = _classnameOverride;
    		} else {
    			QRFS_ERROR_1("No such vehicle class: %1", _classnameOverride);
    		};
    	};

		if (_requireSpotted) then {
			private _area = [_position];
			_area append _triggerArea;
			_condition = format [
				"%1 && [thisList, %2, %3] call %4;",
				_condition,
				_area,
				_side,
				DFUNC(isSpotted)
			];
		};

		/**
    	private _antenna = createSimpleObject ["OmniDirectionalAntenna_01_black_F", _position];
    	_antenna setPosATL _position;
    	//*/

    	/*
    		Trigger Logic
    	*/
    	private _channel = "[playerSide, ""HQ""] commandChat";
    	private _qrfTrigger = createTrigger ["EmptyDetector", _position, true];
    	private _notificationTrigger = createTrigger ["EmptyDetector", _position, true];

    	if (count _synced > 0) then {
    		_qrfTrigger triggerAttachVehicle _synced;
    		_notificationTrigger triggerAttachVehicle _synced;
    		_qrfTrigger setTriggerActivation ["GROUP", "PRESENT", true];
    		_notificationTrigger setTriggerActivation ["GROUP", "PRESENT", true];
    	} else {
    		private _activation = SIDE_TRIGGER_NAME(_targetSide);
    		_qrfTrigger setTriggerActivation [_activation, "PRESENT", true];
    		_notificationTrigger setTriggerActivation [_activation, "PRESENT", true];
    	};

    	_qrfTrigger setTriggerArea _triggerArea;
    	_notificationTrigger setTriggerArea _triggerArea;

    	_qrfTrigger setTriggerTimeout _triggerTimeout;

    	_notificationTrigger setTriggerStatements [
    		_condition,
    		format ["%1 ""You are in danger of having QRFs called in!"";", _channel],
    		format ["%1 ""You are no longer in danger of having QRFs called in."";", _channel]
    	];

    	_qrfTrigger setTriggerStatements [
    		_condition,
    		format [
    			"%1 ""A QRF has been called to your location."";
    	[(thisList select 0), ""%2"", %3, ""%4"", %5, %6, %7] call %8;",
    			_channel,
    			_classname,
    			_units,
    			_origin,
    			_spawnDistance,
    			_dropoffDistance,
    			_side,
    			DFUNC(callInQRF)
    		],
    		""
    	];

    	/*
    		End Trigger Logic
    	*/
    } else {
    	if (!local _logic) exitWith {};
    	private _sideLabels = ["OPFOR", "BLUFOR", "IND", "CIV"];
    	private _vehClasses = [];
    	private _vehSides = [];
    	private _unitClasses = [[], [], [], []];
    	private _numCargo = [];
        {
            if (getNumber (_x >> "scope") != 2) then {continue};
            private _sideId = getNumber (_x >> "side");
            if (_sideId < 0 || _sideId > 3) then {continue};

            private _class = configName _x;

            if (_class isKindOf "CAManBase") then {
                (_unitClasses select _sideId) pushBack _class;
            };
            if (_class isKindOf "Helicopter" || _class isKindOf "Tank" || _class isKindOf "Car") then {
				private _num = [_class] call FUNC(cargoSeats);
				if (_num <= 0) then {continue};

                _vehClasses pushBack _class;
                _vehSides pushBack _sideId;
				_numCargo pushBack _num;
            };
        } forEach configProperties [configFile >> "CfgVehicles","isClass _x"];

        private _vehItems = [];
        {
            _vehItems pushBack [
                format ["%1 (%2)", getText (configFile >> "CfgVehicles" >> _x >> "displayName"), _sideLabels select (_vehSides select _forEachIndex)],
                _x
            ];
        } forEach _vehClasses;

    	[
    		"Add QRF",
    		[
				[
					"COMBOBOX",
					"Side",
					[_sideLabels apply { [_x] }, 0]
				],
				[
					"COMBOBOX",
					"Class Name",
					[_vehItems, _vehClasses find "O_Heli_Transport_04_bench_F"]
				],
				["EDITBOX", "Vehicle Override", ""],
				["EDITBOX", "Origin", "random"],
				["SLIDER", "Distance", [[300, 2000, 100], 1500]],
				["SLIDER", "Landing Distance", [[0, 1000, 10], 300]]
			],
			{
				params ["_values", "_custom"];
				_custom params ["_position", "_unitClasses", "_vehClasses", "_numCargo"];
				_values params ["_sideIndex", "_classnameIndex", "_override", "_origin", "_spawnDistance", "_dropoffDistance"];

				private _side = SIDE_FROM_ID(_sideIndex);
				private _classname = _vehClasses select _classnameIndex;
				private _seats = _numCargo select _classnameIndex;
				private _badOverride = false;

				if (_override != "") then {
					if (isClass (configFile >> "CfgVehicles" >> _override)) then {
						_classname = _override;
						_seats = [_override] call FUNC(cargoSeats);
					} else {
						private _msg = format ["No such vehicle class: %1", _override];
						ZEUS_MESSAGE(_msg);
						_badOverride = true;
					};
				};

				if (_badOverride) exitWith {};

				[
					"Add QRF",
					[
						[
							"CARGOBOX",
							"Units",
							[
								(_unitClasses select _sideIndex) apply { [getText (configFile >> "CfgVehicles" >> _x >> "displayName"), _x]},
								8,
								_seats
							]
						]
					],
					{
						params ["_values", "_custom"];
						_custom params ["_position", "_classname", "_origin", "_spawnDistance", "_dropoffDistance", "_side"];
						_values params ["_units"];

						[_position, _classname, _units, _origin, _spawnDistance, _dropoffDistance, _side] call DFUNC(callInQRF);
						ZEUS_MESSAGE("QRF Spawned");
					},
					[_position, _classname, _origin, _spawnDistance, _dropoffDistance, _side]
				] call qrfs_sdf_fnc_dialog;
			},
			[_position, _unitClasses, _vehClasses, _numCargo]
		] call qrfs_sdf_fnc_dialog;

	    deleteVehicle _logic;
    };
}, _this] call CBA_fnc_directCall;



