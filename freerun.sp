#include <tf2>
#include <tf2_stocks>

bool
	g_bRoundStarted = false,
	g_bFreerun = false;
	
public Plugin myinfo =
{
	name 		= 	"Deathrun: Freerun",
	author 		= 	"myst",
	description	=	"Adds the ability for Death to activate a freerun.",
	version 	= 	"1.0"
};

public void OnPluginStart()
{
	HookEvent("arena_round_start", Event_RoundStart);
	HookEvent("arena_win_panel", Event_RoundEnd);
	
	RegConsoleCmd("sm_fr", Command_Freerun);
	RegConsoleCmd("sm_free", Command_Freerun);
	RegConsoleCmd("sm_freer", Command_Freerun);
	RegConsoleCmd("sm_freerun", Command_Freerun);
}

public void OnMapStart()
{
	g_bRoundStarted = false;
	CreateTimer(1.0, Timer_HUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapEnd() {
	g_bRoundStarted = false;
}

public Action Event_RoundStart(Handle hEvent, char[] sEventName, bool bDontBroadcast)
{
	g_bRoundStarted = true;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (GetClientTeam(i) == view_as<int>(TFTeam_Blue) && IsPlayerAlive(i))
			{
				SetHudTextParamsEx(-1.0, -1.0, 1.0, {255,255,255,255}, {0,0,0,0}, 2, 0.1, 0.1, 0.1);
				ShowHudText(i, -1, "Freerun? Type !fr to grant runners a free round.");
				
				break;
			}
		}
	}
}

public Action Event_RoundEnd(Handle hEvent, char[] sEventName, bool bDontBroadcast)
{
	g_bRoundStarted = false;
	g_bFreerun = false;
}

public Action Command_Freerun(int iClient, int iArgs)
{
	if (g_bRoundStarted && GetClientTeam(iClient) == view_as<int>(TFTeam_Blue) && IsPlayerAlive(iClient))
	{
		g_bFreerun = true;
		TF2_RemoveAllWeapons(iClient);
		
		PrintHintTextToAll("FREERUN! Traps can no longer be activated.");
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				if (GetClientTeam(i) == view_as<int>(TFTeam_Blue) && IsPlayerAlive(i))
				{
					SetHudTextParamsEx(-1.0, -1.0, 2.0, {255,255,255,255}, {0,0,0,0}, 2, 0.1, 0.1, 0.1);
					ShowHudText(i, -1, "FREERUN! Traps can no longer be activated.");
					
					break;
				}
			}
		}
	}
	
	else
	{
		if (GetClientTeam(iClient) != view_as<int>(TFTeam_Blue))
			PrintToChat(iClient, "[SM] You have to be death to do a free run.");
		else if (GetClientTeam(iClient) == view_as<int>(TFTeam_Blue) && !IsPlayerAlive(iClient))
			PrintToChat(iClient, "[SM] You have to be alive to do this.");
		else if (!g_bRoundStarted)
			PrintToChat(iClient, "[SM] Please wait for the round to start first.");
	}
	
	return Plugin_Handled;
}

public Action Timer_HUD(Handle hTimer)
{
	if (g_bFreerun && g_bRoundStarted)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				SetHudTextParamsEx(-1.0, 0.88, 1.0, {255,255,255,255}, {255,255,255,200}, 2, 0.1, 0.1, 0.1);
				ShowHudText(i, -1, "Free Run");
			}
		}
	}
}

stock bool IsValidClient(int iClient, bool bReplay = true)
{
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient))
		return false;
	if (bReplay && (IsClientSourceTV(iClient) || IsClientReplay(iClient)))
		return false;
	return true;
}