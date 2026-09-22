#include "script_component.hpp"

// [_classname] call FUNC(cargoSeats) -> how many passengers the vehicle can carry
params ["_classname"];

private _cfg = configFile >> "CfgVehicles" >> _classname;

count (
	"if (isText (_x >> 'proxyType') && {getText (_x >> 'proxyType') isEqualTo 'CPCargo'}) then {true};"
	configClasses (_cfg >> "Turrets")
) + getNumber (_cfg >> "transportSoldier")
