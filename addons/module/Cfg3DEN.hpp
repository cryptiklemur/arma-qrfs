
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
private _vehicles = [east, [""Helicopter"", ""Tank"", ""Car""], [""UAV""]] call qrfs_module_fnc_getVehicles;\
diag_log format [""Vehicles: %1"", _vehicles];\
{\
	_lbadd = _control lbadd gettext (_x >> 'displayname');\
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
