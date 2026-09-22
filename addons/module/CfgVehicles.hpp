class CfgVehicles {
	class Logic;
	class Module_F: Logic {
		class AttributesBase
		{
			class Default;
			class Edit;
			class Combo;
			class Moduletooltip;
		};
        class ModuleDescription
        {
            class AnyBrain;
            class Curator_F;
        };
	};

	class GVAR(Base): Module_F {
		category = "qrfs_module";
		author = "CryptikLemur";
		scope = 1;
		scopeCurator = 1;
		canSetArea = 1;
		canSetAreaHeight = 1;
		canSetAreaShape = 1;
		functionPriority = 1;
		isGlobal = 0;
		isTriggerActivated = 1;
		isDisposable = 0;
		is3DEN = 0;

		class AttributeValues {
			size3[] = {250, 250, -1};
		};
	};

	class GVAR(AddQRFS): GVAR(Base) {
		displayName = "Add QRFS";
		function = QFUNC(moduleAddQRFS);
		scope = 2;
		scopeCurator = 2;

		class Attributes: AttributesBase {
			class RequireSpotted: Default {
				control = "Checkbox";
				displayName = "Require Spotted";
				tooltip = "Does someone inside the radius have to be spotted by the enemy before a QRF can be called in?";
				defaultValue = "true";
			};
			class Classname: Default {
				control = QGVAR(OPForVehicleList);
				displayName = "Vehicle";
				tooltip = "What Vehicle is used to transport the QRF";
				defaultValue = """O_Heli_Transport_04_bench_F""";
			};
			class ClassnameOverride: Default {
				control = "EditShort";
				displayName = "Vehicle Override";
				tooltip = "Classname to use instead of the Vehicle dropdown. Leave empty to use the dropdown.";
				typeName = "STRING";
				defaultValue = """""";
			};
			class Units: Default {
				control = "EditMulti3";
				displayName = "Units";
				tooltip = "Classnames of the units that will be in each qrf";
				defaultValue = "[""O_G_Soldier_SL_F"", ""O_G_medic_F"", ""O_G_Soldier_AR_F"", ""O_G_Soldier_M_F"", ""O_G_Soldier_LAT_F"", ""O_G_Soldier_A_F"", ""O_G_Soldier_F"", ""O_G_Soldier_F""]";
			};
			class TriggerTimeout: Default {
				control = "Timeout";
			    displayName = "Trigger Timeout";
			    tooltip = "Time required for enemy units to be in the AO (in seconds)";
			    typeName = "ARRAY";
			    defaultValue = "[60, 90, 120]";
			};
			class Origin: Default {
				control = "EditShort";
				displayName = "Origin";
				tooltip = "Where does the QRF come from in regards to the point, as a bearing? 'random' will do a random direction.";
				typeName = "STRING";
				defaultValue = """random""";
			};
			class Condition: Default {
				control = "EditCodeMulti5";
				displayName = "Condition";
				tooltip = "Condition for the qrf trigger to fire";
				typeName = "STRING";
				defaultValue = """this""";
				size = 5;
			};
			class SpawnDistance: Default {
				control = "DynSimDist";
				displayName = "Spawn Distance";
				tooltip = "How far away does the QRF spawn?";
				defaultValue = "1500";
			};
			class DropoffDistance: Default {
				control = "DynSimDist";
				displayName = "Dropoff Distance";
				tooltip = "How far away does the QRF land?";
				defaultValue = "100";
			};

			class ModuleDescription: ModuleDescription{}; // Module Description should be shown last
		};

		class ModuleDescription: ModuleDescription {
			description = "Quick Reaction Force Spawner";
			sync[] = {};

			class Curator_F {
				description[] = {
					"Spawns a QRF team that descends down on the players in the zone.",
					"Can place as many of these as you want."
				};
				position = 1;
				direction = 1;
				size = 1;
				optional = 1;
				duplicate = 1;
				synced[] = {};
			};
		};
	};
};
