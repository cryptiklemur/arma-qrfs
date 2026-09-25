
class Cfg3DEN {
	class Attributes {
		class Default;
        class Title: Default {
        	class Controls {
        		class Title;
        	};
        };
		class Combo: Title {
			class Controls: Controls {
				class Title: Title {};
				class Value;
			};
			class Value;
		};
		class GVAR(OPForVehicleList): Combo {
			control = QGVAR(OPForVehicleList);
			class Controls: Controls {
				class Title: Title {};
				class Value: Value {
					h = "6 * (pixelH * pixelGrid * 	0.50)";
					onload = "_control = _this select 0;\
private _vehicles = [];\
{\
	private _side = _x;\
	private _label = [""OPFOR"", ""BLUFOR"", ""IND"", ""CIV""] select ([east, west, resistance, civilian] find _side);\
	{ _vehicles pushBack [_x, _label] } forEach ([_side, [""Helicopter"", ""Tank"", ""Car""], [""UAV""]] call qrfs_module_fnc_getVehicles);\
} forEach [east, west, resistance, civilian];\
{\
	_x params ['_cfg', '_label'];\
	_x = _cfg;\
	_lbadd = _control lbadd format [""%1 (%2)"", gettext (_x >> 'displayname'), _label];\
	_control lbsetdata [_lbadd, configName _x];\
	_control lbsetpicture [_lbadd,gettext (_x >> 'picture')];\
	_dlcLogo = if (configsourcemod _x == '') then {''} else {modParams [configsourcemod  _x,['logo']] param [0,'']};\
	if (_dlcLogo != '') then {\
		_control lbsetpictureright [_lbadd,_dlcLogo];\
	};\
} forEach _vehicles;\
lbsort _control;";
				};
			};
		};
	};
};
