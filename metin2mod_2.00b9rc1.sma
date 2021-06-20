/*================================================================================
#if is_loaded _metin2_core
   #pragma AMXX – Application Message and eXception Handling Mod X
#else
   #pragma AMXX – Abstract Machine eXecutor Mod X
#endif
******************************************************
***************** [Metin2 Mod 2.00] ******************
******************************************************

----------------------
--*- Licencja GNU -*--
----------------------

Metin2 Mod
Copyright© 2009-2010 by Ortega


"This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

In addition, as a special exception, the author gives permission to
link the code of this program with the Half-Life Game Engine ("HL
Engine") and Modified Game Libraries ("MODs") developed by Valve,
L.L.C ("Valve"). You must obey the GNU General Public License in all
respects for all of the code used other than the HL Engine and MODs
from Valve. If you modify this file, you may extend this exception
to your version of the file, but you are not obligated to do so. If
you do not wish to do so, delete this exception statement from your
version."

--------------------
-*- Streszczenie -*-
--------------------

Mod ten jest oparty na grze MMORPG -Metin2. Popularna gra wymaga dobrego moda rowniez w Counter-Strike.
Mod zrobiony pod bandera Team'u Amxx.pl. Wiekszosc pomyslow zostalo zaczerpnietych z gry Metin2.
System LVLi,Klas oraz wielu innych prosto z orientalnej gry Metin2.	

---------------------
---*- Wymagania -*---
---------------------
* Gra: Counter-Strike 1.6
* AMXX: Wersja 1.8.1

--------------------
----*- Moduly -*----
--------------------

* <cstrike>
* <fun>
* <nvault>
* <fakemeta>
* <hamsandwich>
* <engine>
* <csx>

--------------------------------
----------*- CVAR'y -*----------
--------------------------------

* mt2_mod 1 // wlaczenie moda(1), (0) off
* mt2_XP_kill 20 // ile dostajesz expa za 1 kill
* mt2_XP_team_kill //ile zabrac expa za zabicie swojego lub hosta
* mt2_SaveXP 1 // czy ma zapisywac doswiadczenie postaci
* mt2_SaveXP_mode //zapisywanie na steamid lub nick jest tez 3 tryb gdy gracz ma ns zapisuje na nick a gdy steam na steam_id
* mt2_hp_add //ile hp ma dodawaæ 1 punkt hp
* mt2_mana_add //ile many dostaje gracz
* mt2_mana_time //co ile czasu dostaje mane
* mt2_mod_gamename //czy jako rodzaj gry ma byc wyswietlane Metin2 Mod
* mt2_xp_bonus //ile dostaje sie expa za podlozenie/rozbrojenie bomby/doprowadzenie zak³adnikow
* mt2_xp_bonus2 //ile dostaja expa pozostali gracze
* mt2_csdm // wlacza wylacza tryb deathmatch
* mt2_csdm_hp_add // ile ma regenerowac hp w trybie DM
* mt2_csdm_hp_time // po jakim czasie gracz ma sie odrodzic
* mt2_kill_for_item // po ilu zabiciach gracz ma dostawac zwykly item
* mt2_poison_damage // ile hp ma zabierac trucizna
* mt2_poison_time_reciving // kiedy konczy sie otrucie

-------------------------------
--*- Zasluzeni/Wspoltworcy -*--
-------------------------------

* AMXX Dev Team: za AMXX
* AMXX.PL TEAM: za pomoc w pisaniu pluginu
* DarkGL - wspoltworca

------------------
---*- Zmiany -*---
------------------
1.1 - System klas i lvli
1.2 - Zapisywanie exp'a oraz ladowanie exp'a ; punkty statystyk charakteru ciage udoskonalane z gra ; forward nazwy gry ; poprawa tablicy LVLi
1.3 - Optymalizacja i wp³yw statystyk na gre
1.4 - System itemow
1.5 - Odesjcie od cvar na rzecz pcvar ; System zapisu SQLx
1.6 - Optymalizacja ; Poprawienie estetyki kodu ; Dokonczenie oraz poprawa menu itemow
=================================================================================*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <nvault>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <csx> 
#include <fakemeta_util>

#pragma dynamic 32768

#define g_isalive(%1) is_user_alive(%1)

#define Semi 1 //Declare pragma semicolon(1/0)

#if Semi 1
#pragma semicolon 1 //Semi_on
#else
#pragma semicolon 0 //Semi_off
#endif


#define MAXSLOTS 32

#define CLASS_NONE 0
#define CLASS_WAR 1
#define CLASS_NINJA 2
#define CLASS_SURA 3
#define CLASS_MAGE 4

#define KINGDOM_NONE 0
#define KINGDOM_SHINSOO 1
#define KINGDOM_CHUNJO 2
#define KINGDOM_JINNO 3

#define reload_task 222
#define time_task 111
#define show_skills_task 333
#define csdm_task 444
#define subtract_hp_task 555
#define antidote_task 666
#define kingdom_task 777
#define mana_task 888
#define faint_task 999
#define slowdown_task 1111
#define welcome 1222
#define godmode_task 1333

#define item_color_name "#e5e8df"
#define item_color_level "#9e9e9"
#define item_color_bonus_up "#b28687"
#define item_color_bonus_down "#90b498"
#define item_color_wearing "#9e9e9"
#define item_color_class "#f4f4f4"
#define item_color_unavailable "#e05353"

#define choosekingdom_keys MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_0
#define chooseclass_keys MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_0

// Plugin Version
new const PLUGIN_VERSION[] = "2.00";


const FFADE_STAYOUT = 0x0004;


new max_hp[5][33];
new max_mp[5][33];
new add_con[5][33];
new add_int[5][33];
new add_str[5][33];
new add_dex[5][33];
new add_speed[5][33];
new mana_regeneration[5][33];
new chance_poisoning[5][33];
new chance_faint[5][33];
new chance_slowdown[5][33];
new chance_critical[5][33];
new chance_pierce[5][33];
new chance_stealing_mana[5][33];
new poison_resistance[5][33];
new bonus_exp[5][33];
new dual_drop[5][33];
new faint_no[5][33];
new strong_against_warrior[5][33];
new strong_against_sura[5][33];
new strong_against_shaman[5][33];
new strong_against_ninja[5][33];
new resistant_to_warrior[5][33];
new resistant_to_sura[5][33];
new resistant_to_shaman[5][33];
new resistant_to_ninja[5][33];
new def_array[5][33];
new dmg[5][33];

new weapon[33];

//ID wiadomosci
new g_msgHealth, g_msgScreenFade, g_msgDeathMsg, g_msgScoreInfo

//CVAR(p)	
new cvar_toggle, cvar_xpkill, cvar_xpteamkill, cvar_savexp, cvar_savexpmode,  cvar_hpadd, cvar_manaadd,
cvar_manatime, cvar_modgamename, cvar_xpbonus, cvar_xpbonus2, cvar_showhealth, cvar_csdm, 
cvar_csdmresptime, cvar_killforitem, cvar_poisondmg, cvar_poisontimerec, cvar_poisontimeantidote, cvar_arrowspeed, cvar_empire,
cvar_gravity, cvar_arrowreload


new shift_class[33];
new bow[33];	
new reload[33];
new armor_skills[5][33][34];
new helmet_skills[5][33][34];
new shoes_skills[5][33][34];
new weapon_skill[5][33][34];
new bracelet_skills[5][34][34];
new necklace_skills[5][33][34];
new earrings_skills[5][33][34];
new shield_skills[5][33][34];
new menu_option[33];
new amxbasedir[64];

new faint[33];
new slowdown_player[33];
new poison[33][2];
new how_many_kills[33];
new change_stats[33];
new Player_mana[33];
new Player_Class[33];
new Player_XP[5][33];
new Player_Level[5][33];
new player_point[5][33];
new player_hp[5][33];
new player_int[5][33];
new player_str[5][33];
new player_dex[5][33];
new Player_Kingdom[33];
new armor_name[5][33][128];
new weapon_name[5][33][128];
new bracelet_name[5][33][128];
new helmet_name[5][33][128];
new shoes_name[5][33][128];
new necklace_name[5][33][128];
new earrings_name[5][33][128];
new shield_name[5][33][128];
new id_targeted_player[33];

new g_maxplayers;
new bool:g_modname[32];


new Float:UPDATEINTERVAL = 1.0;
new g_vault;
new defuser;
new has_bomb;
new rank[5][33];
new nvault_rank;
new nvault_time_played;
new nvault_kingdom;
new time_played[5][33];

enum Color{
	YELLOW = 1, // Yellow
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}
new TeamName[][] = {
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

// nazwy klas 4 + nic
new const CLASSES[5][] = {
	"None",
	"Wojownik",
	"Ninja",
	"Sura",
	"Szaman"
};
// nazwy 3 krolestw + nic
new const KINGDOMS[4][] = {
	"None",
	"Shinsoo",
	"Chunjo",
	"Jinno"
};

new const Float:gfCSSpeeds[]={ 
	000.0,
	250.0, 000.0, 260.0, 250.0, 240.0, 
	250.0, 250.0, 240.0, 250.0, 250.0,                
	250.0, 250.0, 210.0, 240.0, 240.0,    
	250.0, 250.0, 210.0, 250.0, 220.0,              
	230.0, 230.0, 250.0, 210.0, 250.0,            
	250.0, 235.0, 221.0, 250.0, 245.0
};

new link_shinsoo, link_chunjo, link_jinno;

new msgtext;

/*new nvault_armor; Dotyczy koncowych funkcji
new nvault_bron;
new nvault_buty;
new nvault_helm;
new nvault_kolczyki;
new nvault_necklace;
new nvault_tarcza;
new nvault_bracelet;*/ 

// exp do poszczegolnych lvli
new const LEVELS[99] = {
	101,225,325,440,610,965,1150,1500,1950,2550,3300,4000,4800,5800,7000,8500,9500,10500,11750,13000,
	14300,15730,17300,19030,20900,23000,24000,25200,26400,27700,29000,30500,32000,33600,35300,37000,39000,41000,43000,45100,
	47400,49800,52300,55000,57800,60700,63700,66900,70200,73700,77400,80000,82400,84900,87500,90000,92700,95500,98300,101000,
	104000,107000,110000,113000,116000,120000,123000,126700,130000,134000,138000,142000,146000,150000,154000,158000,163000,168000,173000,178000,
	183000,188000,194000,200000,206000,212000,218000,225000,232000,239000,246000,253000,261000,269000,277000,285000,294000,500000,750000
};


public plugin_init()
{
	register_plugin("Metin2 Mod", PLUGIN_VERSION , "Ortega & DarkGL");
	
	cvar_toggle = register_cvar("mt2_mod","1");
	
	register_event("ResetHUD","ResetHud", "b");
	register_event("Damage", "Damage", "b", "2!=0");
	register_event("HLTV", "Nowa_Runda", "a", "1=0", "2=0");
	register_event("Health", "Health", "be", "1!255");
	register_event("DeathMsg", "DeathMsg", "a");
	register_event("CurWeapon", "Event_Change_Weapon", "be", "1=1" ); 
	register_event("BarTime", "bomb_defusing", "be", "1=10", "1=5");
	register_event("StatusIcon", "got_bomb", "be", "1=1", "1=2", "2=c4");
	register_event("SendAudio", "award_defuse", "a", "2&%!MRAD_BOMBDEF");
	register_event("TextMsg", "award_hostageALL", "a", "2&#All_Hostages_R" ); 
	register_event("TextMsg","host_killed","b","2&#Killed_Hostage");
	register_event("StatusValue", "on_ShowStatus", "be", "1=2", "2!0");
	register_event("StatusValue", "on_HideStatus", "be", "1=1", "2=0");
	register_logevent("award_plant", 3, "2=Planted_The_Bomb");
	
	register_touch("strzala", "player", "knife_touch");
	register_touch("strzala", "worldspawn", "touchWorld");
	register_touch("strzala", "func_wall", "touchWorld");
	register_touch("strzala", "func_wall_toggle", "touchWorld");
	register_touch("strzala", "dbmod_shild", "touchWorld");
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled");
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage", 0);
	RegisterHam(Ham_Spawn, "player", "ustaw_hp", 1);
	
	register_forward(FM_GetGameDescription, "fw_GameDescription");
	
	register_clcmd("say /changeclass","chooseclass");
	register_clcmd("say_team /klasa", "chooseclass");
	register_clcmd("say /Klasa","chooseclass");
	register_clcmd("say klasa","chooseclass");
	register_clcmd("klasa","chooseclass");
	register_clcmd("say /klasa","chooseclass");
	register_clcmd("say /reset","skillmenureset");
	register_clcmd("say_team /reset","skillmenureset");
	register_clcmd("say reset","skillmenureset");
	register_clcmd("say_team reset","skillmenureset");
	register_clcmd("say /staty","pokazstaty");
	register_clcmd("say_team /staty","pokazstaty");
	register_clcmd("say staty","pokazstaty");
	register_clcmd("say_team staty","pokazstaty");
	register_clcmd("say /komendy","pokazkomendy");
	register_clcmd("say_team /komendy","pokazkomendy");
	register_clcmd("/komendy","pokazkomendy");
	register_clcmd("say komendy","pokazkomendy");
	register_clcmd("say_team komendy","pokazkomendy");
	register_clcmd("komendy","pokazkomendy");
	register_clcmd("say /komendy","pokazkomendy");
	register_clcmd("say_team /komendy","pokazkomendy");
	register_clcmd("/komendy","pokazkomendy");
	register_clcmd("say /help","pokazkomendy");
	register_clcmd("say /pomoc","pokazkomendy");
	register_clcmd("say /itemy","itemy_menu");
	register_clcmd("say /item","itemy_menu");
	register_clcmd("say_team /itemy","itemy_menu");
	register_clcmd("say_team /item","itemy_menu");
	register_clcmd("say /postac","postac");
	register_clcmd("say_team /postac","postac");
	register_clcmd("say /respawn","csdm_respawn");
	register_clcmd("mt2_menu","mt2_menu");
	register_clcmd("say /menu","mt2_menu");
	register_clcmd("say_team /menu","mt2_menu");
	
	
	register_menu("chooseclass",chooseclass_keys,"dochooseclass");
	register_menu("choosekingdom",choosekingdom_keys,"dochoosekingdom");
	register_menucmd(register_menuid("Statystyki Charakteru"), 1023, "skillmenu2");
	
	register_concmd("klasa","chooseclass");
	register_concmd("menu","mt2_menu");
	
	g_msgHealth =  get_user_msgid("Health");
	g_msgScreenFade = get_user_msgid("ScreenFade");
	g_msgDeathMsg = get_user_msgid("DeathMsg");
	g_msgScoreInfo = get_user_msgid("ScoreInfo");
	
	cvar_xpkill = register_cvar("mt2_XP_kill", "20");
	cvar_xpteamkill = register_cvar("mt2_XP_team_kill","90");
	cvar_savexp = register_cvar("mt2_SaveXP", "1");
	cvar_savexpmode = register_cvar("mt2_SaveXP_mode","0");
	cvar_hpadd = register_cvar("mt2_hp_add","2");
	cvar_manaadd = register_cvar("mt2_mana_add","10");
	cvar_manatime = register_cvar("mt2_mana_time","1.0");
	cvar_modgamename = register_cvar("mt2_mod_gamename","1");
	cvar_xpbonus = register_cvar("mt2_xp_bonus","100");
	cvar_xpbonus2 = register_cvar("mt2_xp_bonus2","50");
	cvar_showhealth = register_cvar("mt2_show_health","1");
	cvar_csdm = register_cvar("mt2_csdm","1");
	cvar_csdmresptime = register_cvar("mt2_csdm_respawn_time","2.0");
	cvar_killforitem = register_cvar("mt2_kill_for_item","10");
	cvar_poisondmg = register_cvar("mt2_poison_damage","4");
	cvar_poisontimerec = register_cvar("mt2_poison_time_reciving","2.0");
	cvar_poisontimeantidote = register_cvar("mt2_poison_time_antidote","10.0");
	cvar_arrowspeed = register_cvar("mt2_arrow_speed","1000");
	cvar_empire = register_cvar("mt2_empire","3");
	cvar_gravity = register_cvar("mt2_arrow_gravity","0.4");
	cvar_arrowreload = register_cvar("mt2_arrow_reload","9.0");
	
	
	g_maxplayers = get_maxplayers();
	
	set_msg_block( g_msgDeathMsg, BLOCK_SET );
	
	g_vault = nvault_open("Metin2_Stats");
	nvault_rank = nvault_open("Metin2_Ranga"); 
	nvault_time_played = nvault_open("Metin2_Minuty"); 
	nvault_kingdom = nvault_open("Metin2_Kindgom");
	/*nvault_armor = nvault_open("Metin2_Armor"); Dotyczy koncowych funkcji
	nvault_bron = nvault_open("Metin2_Bron");
	nvault_buty = nvault_open("Metin2_Buty");
	nvault_helm = nvault_open("Metin2_Helm");
	nvault_kolczyki = nvault_open("Metin2_Kolczyki");
	nvault_necklace = nvault_open("Metin2_Necklace");
	nvault_tarcza = nvault_open("Metin2_Tarcza");
	nvault_bracelet = nvault_open("Metin2_Bracelet");*/
	msgtext = get_user_msgid("StatusText");
	
	formatex(g_modname, charsmax(g_modname), "Metin2 Mod %s", PLUGIN_VERSION);
	register_cvar("mt2_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	set_cvar_string("mt2_version", PLUGIN_VERSION);
	
	set_task(UPDATEINTERVAL, "tskShowSkills",show_skills_task, "", 0, "b");
	load_modules();
}

public plugin_precache(){
	precache_sound("metin2/assassin_select.wav");
	precache_sound("metin2/shaman_select.wav");
	precache_sound("metin2/sura_select.wav");
	precache_sound("metin2/warrior_select.wav");
	precache_sound("metin2/levelup1_1.wav");
	precache_sound("metin2/levelup1_2.wav");
	precache_sound("metin2/stats_add.wav");
	precache_sound("metin2/pick.wav");
	precache_sound("metin2/drop.wav");
	precache_sound("metin2/equip_bow.wav");
	precache_sound("metin2/equip_metal_armor.wav");
	precache_sound("metin2/equip_metal_weapon.wav");
	precache_sound("metin2/equip_ring_amulet.wav");
	precache_model("models/metin2/v_bow.mdl");
	precache_model("models/metin2/w_strzala.mdl");
	link_shinsoo = precache_model("sprites/schinsoo.spr");
	link_chunjo = precache_model("sprites/chunjo.spr");
	link_jinno = precache_model("sprites/jinno.spr");
	return PLUGIN_CONTINUE;
}

public mt2_menu(id){
	new MyMenu = menu_create("Metin2 Mod Menu","mt2_menu_handle")
	
	menu_additem(MyMenu,"Klasa")
	menu_additem(MyMenu,"Reset")
	menu_additem(MyMenu,"Staty")
	menu_additem(MyMenu,"Postac")
	menu_additem(MyMenu,"Itemy")
	menu_additem(MyMenu,"Komendy")
	
	menu_setprop(MyMenu,MPROP_EXITNAME,"Wyjscie");
	
	menu_setprop(MyMenu,MPROP_BACKNAME,"Wroc")
	menu_setprop(MyMenu,MPROP_NEXTNAME,"Nastepne")
	
	//zawsze poka¿ opcjê wyjœcia
	menu_setprop(MyMenu,MPROP_EXIT,MEXIT_ALL);
	
	menu_display(id, MyMenu,0);
	return PLUGIN_HANDLED;
}

public mt2_menu_handle(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:
		{
			chooseclass(id);
		}
		case 1:
		{
			skillmenureset(id);
		}
		case 2:
		{
			pokazstaty(id);
		}
		case 3:
		{
			postac(id);
		}
		case 4:
		{
			itemy_menu(id);
		}
		case 5:
		{
			pokazkomendy(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}


public csdm_respawn(id){
	if( get_pcvar_num(cvar_csdm) == 1 ){
		if(task_exists(id+csdm_task)){
			remove_task(id+csdm_task)
		}
		set_task( get_pcvar_float(cvar_csdmresptime),"respawn_player",id+csdm_task);
	}
}


//Forward nazwy gry
public fw_GameDescription(){
	if( get_pcvar_num(cvar_modgamename) == 1){ 
		forward_return(FMV_STRING, g_modname);
		return FMRES_SUPERCEDE;
	}
	return FMRES_SUPERCEDE;
	
}

public load_modules(){
	if(!is_module_loaded("engine")){
		log_amx("Engine module is not loaded properly or turned on.");
	}
	if(!is_module_loaded("nvault")){
		log_amx("Nvault module is not loaded properly or turned on.");
	}
	if(!is_module_loaded("cstrike")){
		log_amx("Cstrike module is not loaded properly or turned on.");
	}
	if(!is_module_loaded("csx")){
		log_amx("Csx module is not loaded properly or turned on.");
	}
	if(!is_module_loaded("fakemeta")){
		log_amx("Fakemeta module is not loaded properly or turned on.");
	}
	if(!is_module_loaded("hamsandwich")){
		log_amx("Hamsandwich module is not loaded properly or turned on.");
	}
	if(!is_module_loaded("fun")){
		log_amx("Fun module is not loaded properly or turned on.");
	}
}

public save_time_played(id){
	if( get_pcvar_num(cvar_savexp) == 1){   
		new authid[32];   
		switch(get_pcvar_num(cvar_savexpmode)){
			case 0:
			{
				get_user_authid(id,authid,31);
			}
			case 1:
			{
				get_user_name(id,authid,31);
			}
			case 2:
			{
				get_user_authid(id,authid,31);
				if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
					get_user_name(id,authid,31);
				}
			}
		}
		replace_all(authid, 31, " ", "'");
		new vaultkey[64],vaultdata[1024];
		format(vaultkey,63,"%s-time_played",authid);
		format(vaultdata,1023,"%i#%i#%i#%i",time_played[1][id],time_played[2][id],time_played[3][id],time_played[4][id]);
		nvault_set(nvault_time_played,vaultkey,vaultdata);
	}
}

public load_time_played(id){
	if( get_pcvar_num(cvar_savexp) == 1){   
		new authid[32];  
		switch(get_pcvar_num(cvar_savexpmode)){
			case 0:
			{
				get_user_authid(id,authid,31);
			}
			case 1:
			{
				get_user_name(id,authid,31);
			}
			case 2:
			{
				get_user_authid(id,authid,31);
				if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
					get_user_name(id,authid,31);
				}
			}
		}
		replace_all(authid, 31, " ", "'");
		new vaultkey[64],vaultdata[64];
		format(vaultkey,63,"%s-time_played",authid);
		nvault_get(nvault_time_played,vaultkey,vaultdata,64);
		replace_all(vaultdata, 1024, "#", " ");
		new przydzial_time_played1[33],przydzial_time_played2[33],przydzial_time_played3[33],przydzial_time_played4[33];
		parse(vaultdata, przydzial_time_played1,32, przydzial_time_played2,32, przydzial_time_played3,32, przydzial_time_played4,32);
		time_played[1][id] = str_to_num(przydzial_time_played1);
		time_played[2][id] = str_to_num(przydzial_time_played2);
		time_played[3][id] = str_to_num(przydzial_time_played3);
		time_played[4][id] = str_to_num(przydzial_time_played4);
	}
}


public save_rank(id){
	if( get_pcvar_num(cvar_savexp) == 1){   
		new authid[32];   
		switch(get_pcvar_num(cvar_savexpmode)){
			case 0:
			{
				get_user_authid(id,authid,31);
			}
			case 1:
			{
				get_user_name(id,authid,31);
			}
			case 2:
			{
				get_user_authid(id,authid,31);
				if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
					get_user_name(id,authid,31);
				}
			}
		}
		
		replace_all(authid, 31, " ", "'");
		new vaultkey[64],vaultdata[1024];
		format(vaultkey,63,"%s-RANGA",authid);
		format(vaultdata,1023,"%i#%i#%i#%i",rank[1][id],rank[2][id],rank[3][id],rank[4][id]);
		nvault_set(nvault_rank,vaultkey,vaultdata);
	}
}

public load_rank(id){
	if( get_pcvar_num(cvar_savexp) == 1){   
		new authid[32];  
		switch(get_pcvar_num(cvar_savexpmode)){
			case 0:
			{
				get_user_authid(id,authid,31);
			}
			case 1:
			{
				get_user_name(id,authid,31);
			}
			case 2:
			{
				get_user_authid(id,authid,31);
				if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
					get_user_name(id,authid,31);
				}
			}
		}
		replace_all(authid, 31, " ", "'");
		new vaultkey[64],vaultdata[64];
		format(vaultkey,63,"%s-RANGA",authid);
		nvault_get(nvault_rank,vaultkey,vaultdata,64);
		replace_all(vaultdata, 1024, "#", " ");
		new przydzial_rang1[33],przydzial_rang2[33],przydzial_rang3[33],przydzial_rang4[33];
		parse(vaultdata, przydzial_rang1,32, przydzial_rang2,32, przydzial_rang3,32, przydzial_rang4,32);
		rank[1][id] = str_to_num(przydzial_rang1);
		rank[2][id] = str_to_num(przydzial_rang2);
		rank[3][id] = str_to_num(przydzial_rang3);
		rank[4][id] = str_to_num(przydzial_rang4);
	}
}



public SaveXP(id){
	if( get_pcvar_num(cvar_savexp) == 1){   
		new authid[32];   
		switch(get_pcvar_num(cvar_savexpmode)){
			case 0:
			{
				get_user_authid(id,authid,31);
			}
			case 1:
			{
				get_user_name(id,authid,31);
			}
			case 2:
			{
				get_user_authid(id,authid,31);
				if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
					get_user_name(id,authid,31);
				}
			}
		}
		
		replace_all(authid, 31, " ", "'");
		
		new vaultkey[64],vaultdata[1024];
		format(vaultkey,63,"%s-MT2MOD",authid);
		format(vaultdata,1023,"%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i#%i",Player_XP[1][id],Player_Level[1][id],player_hp[1][id],player_int[1][id],player_str[1][id],player_dex[1][id],player_point[1][id],Player_XP[2][id],Player_Level[2][id],player_hp[2][id]
		,player_int[2][id],player_str[2][id],player_dex[2][id],player_point[2][id],Player_XP[3][id],Player_Level[3][id],player_hp[3][id],player_int[3][id],player_str[3][id],player_dex[3][id],player_point[3][id],Player_XP[4][id],Player_Level[4][id],player_hp[4][id],player_int[4][id],player_str[4][id],player_dex[4][id],player_point[4][id]);
		nvault_set(g_vault,vaultkey,vaultdata);
	}
	return PLUGIN_HANDLED;
}

public LoadXP(id){
	if( get_pcvar_num(cvar_savexp) == 1){   
		new authid[32];  
		switch(get_pcvar_num(cvar_savexpmode)){
			case 0:
			{
				get_user_authid(id,authid,31);
			}
			case 1:
			{
				get_user_name(id,authid,31);
			}
			case 2:
			{
				get_user_authid(id,authid,31);
				if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
					get_user_name(id,authid,31);
				}
			}
		}
		replace_all(authid, 31, " ", "'");
		
		new vaultkey[64],vaultdata[1024];
		format(vaultkey,63,"%s-MT2MOD",authid);
		nvault_get(g_vault,vaultkey,vaultdata,1024);
		
		replace_all(vaultdata, 1024, "#", " ");
		
		new  PlayerXP_1[33],PlayerLevel_1[33],playerhp_1[33],playerint_1[33],playerstr_1[33],playerdex_1[33],playerpoint_1[33],PlayerXP_2[33],PlayerLevel_2[33],playerhp_2[33],playerint_2[33],playerstr_2[33],playerdex_2[33],playerpoint_2[33],PlayerXP_3[33],PlayerLevel_3[33],playerhp_3[33],playerint_3[33],playerstr_3[33],playerdex_3[33],playerpoint_3[33],PlayerXP_4[33],PlayerLevel_4[33],playerhp_4[33],playerint_4[33],playerstr_4[33],playerdex_4[33],playerpoint_4[33];
		
		parse(vaultdata, PlayerXP_1, 32, PlayerLevel_1, 32, playerhp_1, 32, playerint_1, 32, playerstr_1, 32, playerdex_1, 32, playerpoint_1, 32, PlayerXP_2, 32, PlayerLevel_2, 32, playerhp_2, 32, playerint_2, 32, playerstr_2, 32, playerdex_2, 32, playerpoint_2, 32, PlayerXP_3, 32, PlayerLevel_3, 32, playerhp_3, 32, playerint_3, 32, playerstr_3, 32, playerdex_3, 32, playerpoint_3, 32, PlayerXP_4, 32, PlayerLevel_4, 32, playerhp_4, 32, playerint_4, 32, playerstr_4, 32, playerdex_4, 32, playerpoint_4, 32);
		
		Player_XP[1][id] = str_to_num(PlayerXP_1);
		Player_Level[1][id] = str_to_num(PlayerLevel_1);
		player_hp[1][id] = str_to_num(playerhp_1);
		player_int[1][id] = str_to_num(playerint_1);
		player_str[1][id] = str_to_num(playerstr_1);
		player_dex[1][id] = str_to_num(playerdex_1);
		player_point[1][id] = str_to_num(playerpoint_1);
		
		Player_XP[2][id] = str_to_num(PlayerXP_2);
		Player_Level[2][id] = str_to_num(PlayerLevel_2);
		player_hp[2][id] = str_to_num(playerhp_2);
		player_int[2][id] = str_to_num(playerint_2);
		player_str[2][id] = str_to_num(playerstr_2);
		player_dex[2][id] = str_to_num(playerdex_2);
		player_point[2][id] = str_to_num(playerpoint_2);
		
		Player_XP[3][id] = str_to_num(PlayerXP_3);
		Player_Level[3][id] = str_to_num(PlayerLevel_3);
		player_hp[3][id] = str_to_num(playerhp_3);
		player_int[3][id] = str_to_num(playerint_3);
		player_str[3][id] = str_to_num(playerstr_3);
		player_dex[3][id] = str_to_num(playerdex_3);
		player_point[3][id] = str_to_num(playerpoint_3);
		
		Player_XP[4][id] = str_to_num(PlayerXP_4);
		Player_Level[4][id] = str_to_num(PlayerLevel_4);
		player_hp[4][id] = str_to_num(playerhp_4);
		player_int[4][id] = str_to_num(playerint_4);
		player_str[4][id] = str_to_num(playerstr_4);
		player_dex[4][id] = str_to_num(playerdex_4);
		player_point[4][id] = str_to_num(playerpoint_4);
	}
	return PLUGIN_HANDLED;
} 

public wczytaj_krolestwo(id){
	if( get_pcvar_num(cvar_savexp) == 1){   
		new authid[32];  
		switch(get_pcvar_num(cvar_savexpmode)){
			case 0:
			{
				get_user_authid(id,authid,31);
			}
			case 1:
			{
				get_user_name(id,authid,31);
			}
			case 2:
			{
				get_user_authid(id,authid,31);
				if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
					get_user_name(id,authid,31);
				}
			}
		}
		replace_all(authid, 31, " ", "'");
		new vaultkey[64],vaultdata[64];
		format(vaultkey,63,"%s-time_played",authid);
		nvault_get(nvault_kingdom,vaultkey,vaultdata,64);
		if(equal(vaultdata,"")){
			Player_Kingdom[id] = KINGDOM_NONE;
		}
		else
		{
			switch(str_to_num(vaultdata)){
				case 1:{
					Player_Kingdom[id] = KINGDOM_SHINSOO;
				}
				case 2:{ 
					Player_Kingdom[id] = KINGDOM_CHUNJO;
				}
				case 3:{
					Player_Kingdom[id] = KINGDOM_JINNO;
				}
			}
		}
	}
}

public zapis_krolestwo(id){
	if( get_pcvar_num(cvar_savexp) == 1 && Player_Kingdom[id] != KINGDOM_NONE){   
		new authid[32];   
		switch(get_pcvar_num(cvar_savexpmode)){
			case 0:
			{
				get_user_authid(id,authid,31);
			}
			case 1:
			{
				get_user_name(id,authid,31);
			}
			case 2:
			{
				get_user_authid(id,authid,31);
				if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
					get_user_name(id,authid,31);
				}
			}
		}
		
		replace_all(authid, 31, " ", "'");
		new vaultkey[64],vaultdata[1024];
		format(vaultkey,63,"%s-time_played",authid);
		format(vaultdata,1023,"%i",Player_Kingdom[id]);
		nvault_set(nvault_kingdom,vaultkey,vaultdata);
	}
}

public client_connect(id){
	id_targeted_player[id]=0;
	new i;
	new j;
	menu_option[id] = 0;
	how_many_kills[id] = 0;
	shift_class[id] = 0;
	reload[id] = 0;
	for(i=0;i<5;i++){
		rank[i][id] = 0;
	}
	for(i=0;i<5;i++){
		time_played[i][id] = 0;
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			armor_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			helmet_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			shoes_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			weapon_skill[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			bracelet_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			necklace_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			earrings_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			shield_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		max_hp[i][id]=0;
	}
	for(i = 0;i<5;i++){
		max_mp[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_con[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_int[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_str[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_dex[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_speed[i][id]=0;
	}
	for(i = 0;i<5;i++){
		mana_regeneration[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_poisoning[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_faint[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_slowdown[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_critical[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_pierce[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_stealing_mana[i][id]=0;
	}
	for(i = 0;i<5;i++){
		poison_resistance[i][id]=0;
	}
	for(i = 0;i<5;i++){
		bonus_exp[i][id]=0;
	}
	for(i = 0;i<5;i++){
		dual_drop[i][id]=0;
	}
	for(i = 0;i<5;i++){
		faint_no[i][id]=0;
	}
	for(i = 0;i<5;i++){
		strong_against_warrior[i][id]=0;
	}
	for(i = 0;i<5;i++){
		strong_against_sura[i][id]=0;
	}
	for(i = 0;i<5;i++){
		strong_against_shaman[i][id]=0;
	}
	
	for(i = 0;i<5;i++){
		strong_against_ninja[i][id]=0;
	}
	
	for(i = 0;i<5;i++){
		resistant_to_warrior[i][id]=0;
	}
	for(i = 0;i<5;i++){
		resistant_to_sura[i][id]=0;
	}
	for(i = 0;i<5;i++){
		resistant_to_shaman[i][id]=0;
	}
	for(i = 0;i<5;i++){
		resistant_to_ninja[i][id]=0;
	}
	for(i = 0;i<5;i++){
		def_array[i][id]=0;
	}
	for(i = 0;i<5;i++){
		dmg[i][id]=0;
	}
	if( get_pcvar_num(cvar_savexp) == 1) {
		wczytaj_krolestwo(id);
		load_rank(id);
		Player_Class[id] = 0;
		how_many_kills[id] = 0;
		LoadXP(id);
		load_time_played(id);
		//wczytaj_itemy(id); Dotyczy koncowych funkcji
		set_task(60.0,"time_played_odliczanie",id+time_task,_,_,"b");
	}
}

public client_putinserver(id){
	set_task(5.0, "welcome_msg", id+welcome);
	//client_cmd(id,"bind c mt2_menu")
}

public time_played_odliczanie(id){
	id-=time_task;
	time_played[Player_Class[id]][id]++;
	rank[Player_Class[id]][id]++;
	
}

public client_disconnect(id){
	if( get_pcvar_num(cvar_savexp) == 1) {
		save_rank(id);
		SaveXP(id);
		if(task_exists(id+time_task)){
			remove_task(id+time_task);
		}
		save_time_played(id);
		zapis_krolestwo(id);
		//zapis_itemow(id); Dotyczy koncowych funkcji
	}
	Player_XP[1][id] = 0;
	Player_Level[1][id] = 0;
	player_hp[1][id] = 0;
	player_int[1][id] = 0;
	player_str[1][id] = 0;
	player_dex[1][id] = 0;
	player_point[1][id] = 0;
	
	Player_XP[2][id] = 0;
	Player_Level[2][id] = 0;
	player_hp[2][id] = 0;
	player_int[2][id] = 0;
	player_str[2][id] = 0;
	player_dex[2][id] = 0;
	player_point[2][id] = 0;
	
	Player_XP[3][id] = 0;
	Player_Level[3][id] = 0;
	player_hp[3][id] = 0;
	player_int[3][id] = 0;
	player_str[3][id] = 0;
	player_dex[3][id] = 0;
	player_point[3][id] = 0;
	
	Player_XP[4][id] = 0;
	Player_Level[4][id] = 0;
	player_hp[4][id] = 0;
	player_int[4][id] = 0;
	player_str[4][id] = 0;
	player_dex[4][id] = 0;
	player_point[4][id] = 0;
	reload[id] = 0;
	new i;
	new j;
	menu_option[id] = 0;
	how_many_kills[id] = 0;
	shift_class[id] = 0;
	reload[id] = 0;
	for(i=0;i<5;i++){
		rank[i][id] = 0;
	}
	for(i=0;i<5;i++){
		time_played[i][id] = 0;
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			armor_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			helmet_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			shoes_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			weapon_skill[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			bracelet_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			necklace_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			earrings_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		for(j = 0;j<34;j++){
			shield_skills[i][id][j]=0;
		}
	}
	for(i = 0;i<5;i++){
		max_hp[i][id]=0;
	}
	for(i = 0;i<5;i++){
		max_mp[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_con[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_int[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_str[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_dex[i][id]=0;
	}
	for(i = 0;i<5;i++){
		add_speed[i][id]=0;
	}
	for(i = 0;i<5;i++){
		mana_regeneration[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_poisoning[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_faint[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_slowdown[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_critical[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_pierce[i][id]=0;
	}
	for(i = 0;i<5;i++){
		chance_stealing_mana[i][id]=0;
	}
	for(i = 0;i<5;i++){
		poison_resistance[i][id]=0;
	}
	for(i = 0;i<5;i++){
		bonus_exp[i][id]=0;
	}
	for(i = 0;i<5;i++){
		dual_drop[i][id]=0;
	}
	for(i = 0;i<5;i++){
		faint_no[i][id]=0;
	}
	for(i = 0;i<5;i++){
		strong_against_warrior[i][id]=0;
	}
	for(i = 0;i<5;i++){
		strong_against_sura[i][id]=0;
	}
	for(i = 0;i<5;i++){
		strong_against_shaman[i][id]=0;
	}
	
	for(i = 0;i<5;i++){
		strong_against_ninja[i][id]=0;
	}
	
	for(i = 0;i<5;i++){
		resistant_to_warrior[i][id]=0;
	}
	for(i = 0;i<5;i++){
		resistant_to_sura[i][id]=0;
	}
	for(i = 0;i<5;i++){
		resistant_to_shaman[i][id]=0;
	}
	for(i = 0;i<5;i++){
		resistant_to_ninja[i][id]=0;
	}
	for(i = 0;i<5;i++){
		def_array[i][id]=0;
	}
	for(i = 0;i<5;i++){
		dmg[i][id]=0;
	}
}

public choosekingdom(id){
	new menu[256];
	
	format(menu, 255, "\rMetin2 Mod: \yWybierz Krolestwo^n^n Zastanow sie dobrze nie ma mozliwosci^n zmiany KINGDOMS w pozniejszej grze^n\r1. \wShinsoo - Krolestwo Religii ^n\r2. \wChunjo - Krolestwo Handlu^n\r3. \wJinno - Krolestwo Armii \r^n^n0. \wCancel"); 
	show_menu(id, choosekingdom_keys, menu, -1, "dochoosekingdom");  
	return PLUGIN_CONTINUE;
}

public dochoosekingdom(id, key){
	switch(key){
		case 0:
		{
			Player_Kingdom[id] = KINGDOM_SHINSOO;
			ColorChat(id,GREEN, "[Metin2 Mod]^x01 Krolestwo zostalo ustawione");
		}
		case 1:
		{
			
			Player_Kingdom[id] = KINGDOM_CHUNJO;
			ColorChat(id,GREEN, "[Metin2 Mod]^x01 Krolestwo zostalo ustawione");
		}
		
		case 2:
		{
			
			Player_Kingdom[id] = KINGDOM_JINNO;
			ColorChat(id,GREEN, "[Metin2 Mod]^x01 Krolestwo zostalo ustawione");
		}    
		
		case 9:
		{
			menu_cancel(id);
			//show_menu(id,MENU_KEY_0,"", -1, "");  
			
		}
	}
	
	return PLUGIN_HANDLED;
}

public chooseclass(id){
	new menu[192];
	
	format(menu, 191, "\rMetin2 Mod: \yWybierz klase^n^n\r1. \wWojownik [%d]^n\r2. \wNinja [%d]^n\r3. \wSura [%d]^n\r4. \wSzaman [%d]^n^n\r0. \wCancel",Player_Level[1][id],Player_Level[2][id],Player_Level[3][id],Player_Level[4][id]); 
	show_menu(id, chooseclass_keys, menu, -1, "dochooseclass");  
	return PLUGIN_CONTINUE;
}


public dochooseclass(id, key){
	switch(key){
		case 0:
		{
			if(Player_Class[id] == CLASS_WAR) {
				
				
				ColorChat(id,GREEN,"[Metin2 Mod]^x01 Jestes juz Wojownikiem. Wybierz inna klase.");
				chooseclass(id);         
				return PLUGIN_HANDLED;
			}
			
			change_stats[id] = 1;
			shift_class[id] = 1;
			ColorChat(id,GREEN, "[Metin2 Mod]^x01 Klasa zostanie zmieniona w nastepnej rundzie");
		}
		case 1:
		{
			
			if(Player_Class[id] == CLASS_NINJA) {
				
				ColorChat(id,GREEN,"[Metin2 Mod]^x01 Jestes juz Ninja. Wybierz inna klase.");
				chooseclass(id);
				return PLUGIN_HANDLED;
			}
			
			change_stats[id] = 1;
			shift_class[id] = 2;
			ColorChat(id,GREEN, "[Metin2 Mod]^x01 Klasa zostanie zmieniona w nastepnej rundzie");
		}
		
		case 2:
		{
			
			if(Player_Class[id] == CLASS_SURA) {
				
				ColorChat(id,GREEN,"[Metin2 Mod]^x01Jestes juz Sura. Wybierz inna klase.");
				chooseclass(id);
				return PLUGIN_HANDLED;
			}
			
			change_stats[id] = 1;
			shift_class[id] = 3;
			ColorChat(id,GREEN, "[Metin2 Mod]^x01 Klasa zostanie zmieniona w nastepnej rundzie");
		}    
		
		case 3:
		{
			
			if(Player_Class[id] == CLASS_MAGE) {
				
				ColorChat(id,GREEN,"[Metin2 Mod]^x01 Jestes juz Szamanem. Wybierz inna klase.");
				chooseclass(id);
				return PLUGIN_HANDLED;
			}
			
			change_stats[id] = 1;
			shift_class[id] = 4;
			ColorChat(id,GREEN, "[Metin2 Mod]^x01 Klasa zostanie zmieniona w nastepnej rundzie");
		}
		case 9:
		{
			menu_cancel(id);
		}
	}
	
	return PLUGIN_HANDLED;
}

public ShowHUD(id)    { 
	new HUD[51];
	new Float:procenty;
	new Float:ile_xp;
	new Float:ile_potrzebuje_xp;
	
	if(Player_Level[Player_Class[id]][id] == 0){
		ile_xp = float(Player_XP[Player_Class[id]][id]);
		ile_potrzebuje_xp = float(LEVELS[Player_Level[Player_Class[id]][id]]);
		procenty = (100.0/ile_potrzebuje_xp) * ile_xp;
	}
	else
	{
		ile_xp = float(Player_XP[Player_Class[id]][id] - LEVELS[Player_Level[Player_Class[id]][id]-1]);
		ile_potrzebuje_xp = float(LEVELS[Player_Level[Player_Class[id]][id]] - LEVELS[Player_Level[Player_Class[id]][id]-1]);
		procenty = (100.0/ile_potrzebuje_xp) * ile_xp;
	}
	format(HUD, 50,"[%s]Level: %i XP: %i | %0.2f%s Mana: %i", CLASSES[Player_Class[id]], Player_Level[Player_Class[id]][id], Player_XP[Player_Class[id]][id],procenty,"%%",Player_mana[id]);
	
	message_begin(MSG_ONE, msgtext, {0,0,0}, id);
	write_byte(0);
	write_string(HUD); 
	message_end();
	return;
}

public Health(id){
	
	if( get_pcvar_num(cvar_showhealth) == 1)
	{
		new jakies_hp_ma = read_data(1); 
		if(jakies_hp_ma>255)
		{
			message_begin( MSG_ONE, g_msgHealth, {0,0,0}, id );
			write_byte(255);
			message_end();
			set_hudmessage(255, 0, 0, 0.01, 0.89, 0, 6.0, 999.0, 0.0, 0.0, -1);
			show_hudmessage(id, "HP:%d",jakies_hp_ma);
		} 
	}
}
public skillmenureset(id){
	change_stats[id] = 1;
	player_point[Player_Class[id]][id]+=player_hp[Player_Class[id]][id];
	player_hp[Player_Class[id]][id]=0;
	player_point[Player_Class[id]][id]+=player_int[Player_Class[id]][id];
	player_int[Player_Class[id]][id]=0;
	player_point[Player_Class[id]][id]+=player_str[Player_Class[id]][id];
	player_str[Player_Class[id]][id]=0;
	player_point[Player_Class[id]][id]+=player_dex[Player_Class[id]][id];
	player_dex[Player_Class[id]][id]=0;
	skillmenu(id);
	return PLUGIN_HANDLED; 
}
public skillmenu(id){
	new text[513];
	new keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6);
	
	
	format(text, 512, "\yStatystyki Charakteru- \rPunkty: %i^n^n\w1. HP [Zycie] [%i] ^n\w2. INT [Inteligencja] [%i] ^n\w3. STR [Sila] [%i] ^n\w4. DEX [Zrecznosc] [%i]",player_point[Player_Class[id]][id],player_hp[Player_Class[id]][id],player_int[Player_Class[id]][id],player_str[Player_Class[id]][id],player_dex[Player_Class[id]][id]);
	
	keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6);
	show_menu(id, keys, text);
	return PLUGIN_HANDLED;
} 

public skillmenu2(id, key) { 
	switch(key) 
	{ 
		case 0: 
		{	
			if (player_hp[Player_Class[id]][id]<90){
				player_point[Player_Class[id]][id]-=1
				player_hp[Player_Class[id]][id]+=1
				play_sound(id,"metin2/stats_add.wav");
				ShowHUD(id);
			}
			else client_print(id,print_center,"Osiagnales maksymalny poziom HP")
			
		}
		case 1: 
		{	
			if (player_int[Player_Class[id]][id]<90){
				player_point[Player_Class[id]][id]-=1
				player_int[Player_Class[id]][id]+=1
				play_sound(id,"metin2/stats_add.wav");
				ShowHUD(id);
			}
			else client_print(id,print_center,"Osiagnales maksymalny poziom INT")
		}
		case 2: 
		{	
			if (player_str[Player_Class[id]][id]<90){
				player_point[Player_Class[id]][id]-=1
				player_str[Player_Class[id]][id]+=1
				play_sound(id,"metin2/stats_add.wav");
				ShowHUD(id);
			}
			else client_print(id,print_center,"Osiagnales maksymalny poziom STR")
			
		}
		case 3: 
		{	
			if (player_dex[Player_Class[id]][id]<90){
				player_point[Player_Class[id]][id]-=1
				player_dex[Player_Class[id]][id]+=1
				play_sound(id,"metin2/stats_add.wav");
				ShowHUD(id);
			}
			else client_print(id,print_center,"Osiagnales maksymalny poziom DEX")
		}
	}
	if (player_point[Player_Class[id]][id] > 0) {
		skillmenu(id)
	}
	ShowHUD(id);
	return PLUGIN_HANDLED
}

public play_sound(id,sound[]) { 
	if(!is_user_connected(id) ){
		return PLUGIN_HANDLED 
	}
	
	if( containi(sound,".wav") > 0) {
		client_cmd(id,"spk %s",sound) 
	}
	else if( containi(sound,".mp3") >0){
		client_cmd(id,"mp3 play %s",sound) 
	}
	
	return PLUGIN_CONTINUE 
}

public pokazkomendy(id){
	new path_to_file[64]
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/help.txt",amxbasedir)
	
	show_motd(id, path_to_file, "Pomoc")
	
	return PLUGIN_HANDLED
	
}

public pokazstaty(id){
	new statyinfo[1024]
	format(statyinfo,1023,"<br />Masz dodatkowo %i zycia<br />Masz %i inteligencji co daje ci dodatkowo %i many<br />Masz %i sily co daje ci dodatkowo %i obrazen<br />Masz %i zrecznosci co daje ci szanse 1 do %i ze unikniesz pocisku<br />Masz %i defense co zmniejsza obrazenia jakie dostajesz o %i",
	player_hp[Player_Class[id]][id]* get_pcvar_num(cvar_hpadd),
	player_int[Player_Class[id]][id],
	player_int[Player_Class[id]][id],
	player_str[Player_Class[id]][id],
	player_str[Player_Class[id]][id]/3,
	player_dex[Player_Class[id]][id],
	95-player_dex[Player_Class[id]][id],
	player_hp[Player_Class[id]][id]/2,
	player_hp[Player_Class[id]][id]/4)
	motd_player_stats(id,statyinfo)	
	
}

public aktywna_func(id, menu, item){
	return ITEM_ENABLED;
}

public nieaktywna_func(id, menu, item){
	return ITEM_DISABLED;
}

public itemy_menu(id){
	new MyMenu=menu_create("Itemy","itemy_menu_handle");
	
	new aktywna=menu_makecallback("aktywna_func");
	
	new nieaktywna=menu_makecallback("nieaktywna_func");
	
	new name[256];
	
	
	if(armor_skills[Player_Class[id]][id][0] == 1){
		menu_additem(MyMenu,armor_name[Player_Class[id]][id],"",0,aktywna);
	}
	else if(armor_skills[Player_Class[id]][id][0] == 2){
		format(name,255,"%s - \r[jestes za slaby]",armor_name[Player_Class[id]][id])
		menu_additem(MyMenu,name,"",0,aktywna);
	}
	else
	{
		menu_additem(MyMenu,"None","",0,nieaktywna);
	}
	
	
	if(helmet_skills[Player_Class[id]][id][0] == 1){
		menu_additem(MyMenu,helmet_name[Player_Class[id]][id],"",0,aktywna);
	}
	else if(helmet_skills[Player_Class[id]][id][0] == 2){
		format(name,255,"%s - \r[jestes za slaby]",helmet_name[Player_Class[id]][id])
		menu_additem(MyMenu,name,"",0,aktywna);
	}
	else
	{
		menu_additem(MyMenu,"None","",0,nieaktywna);
	}
	
	
	if(weapon_skill[Player_Class[id]][id][0] == 1){
		menu_additem(MyMenu,weapon_name[Player_Class[id]][id],"",0,aktywna);
	}
	else if(weapon_skill[Player_Class[id]][id][0] == 2){
		format(name,255,"%s - \r[jestes za slaby]",weapon_name[Player_Class[id]][id])
		menu_additem(MyMenu,name,"",0,aktywna);
	}
	else
	{
		menu_additem(MyMenu,"None","",0,nieaktywna);
	}
	
	
	if(bracelet_skills[Player_Class[id]][id][0] == 1){
		menu_additem(MyMenu,bracelet_name[Player_Class[id]][id],"",0,aktywna);
	}
	else if(bracelet_skills[Player_Class[id]][id][0] == 2){
		format(name,255,"%s - \r[jestes za slaby]",bracelet_name[Player_Class[id]][id])
		menu_additem(MyMenu,name,"",0,aktywna);
	}
	else
	{
		menu_additem(MyMenu,"None","",0,nieaktywna);
	}
	
	
	if(necklace_skills[Player_Class[id]][id][0] == 1){
		menu_additem(MyMenu,necklace_name[Player_Class[id]][id],"",0,aktywna);
		
	}
	else if(necklace_skills[Player_Class[id]][id][0] == 2){
		format(name,255,"%s - \r[jestes za slaby]",necklace_name[Player_Class[id]][id])
		menu_additem(MyMenu,name,"",0,aktywna);
	}
	else
	{
		menu_additem(MyMenu,"None","",0,nieaktywna);
	}
	
	
	if(earrings_skills[Player_Class[id]][id][0] == 1){
		menu_additem(MyMenu,earrings_name[Player_Class[id]][id],"",0,aktywna);
	}
	else if(earrings_skills[Player_Class[id]][id][0] == 2){
		format(name,255,"%s - \r[jestes za slaby]",earrings_name[Player_Class[id]][id])
		menu_additem(MyMenu,name,"",0,aktywna);
	}
	else
	{
		menu_additem(MyMenu,"None","",0,nieaktywna);
	}
	
	
	if(shield_skills[Player_Class[id]][id][0] == 1){
		menu_additem(MyMenu,shield_name[Player_Class[id]][id],"",0,aktywna);
	}
	else if(shield_skills[Player_Class[id]][id][0] == 2){
		format(name,255,"%s - \r[jestes za slaby]",shield_name[Player_Class[id]][id])
		menu_additem(MyMenu,name,"",0,aktywna);
		
	}
	else
	{
		menu_additem(MyMenu,"None","",0,nieaktywna);
	}
	
	
	if(shoes_skills[Player_Class[id]][id][0] == 1){
		menu_additem(MyMenu,shoes_name[Player_Class[id]][id],"",0,aktywna);
	}
	else if(shoes_skills[Player_Class[id]][id][0] == 2){
		format(name,255,"%s - \r[jestes za slaby]",shoes_name[Player_Class[id]][id])
		menu_additem(MyMenu,name,"",0,aktywna);
	}
	else
	{
		menu_additem(MyMenu,"None","",0,nieaktywna);
	}
	
	
	if(menu_option[id] == 0){
		menu_additem(MyMenu,"Informacje","",0,aktywna);
	}
	else if(menu_option[id] == 1){
		menu_additem(MyMenu,"Wyrzuc","",0,aktywna);
	}
	
	menu_setprop(MyMenu,MPROP_EXITNAME,"Wyjscie");
	
	menu_setprop(MyMenu,MPROP_BACKNAME,"Wroc")
	menu_setprop(MyMenu,MPROP_NEXTNAME,"Nastepne")
	
	//zawsze poka¿ opcjê wyjœcia
	menu_setprop(MyMenu,MPROP_EXIT,MEXIT_ALL);
	
	menu_setprop(MyMenu,MPROP_PERPAGE,7)
	
	//kolor cyfry przycisku zmieñ na ¿ó³ty
	//menu_setprop(MyMenu,MPROP_NUMBER_COLOR,"r");
	
	menu_display(id, MyMenu,0);
	return PLUGIN_HANDLED;
}

public itemy_menu_handle(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			if(menu_option[id] == 1){
				drop_armor(id)
				itemy_menu(id)
			}
			else if(menu_option[id] == 0){
				info_armor(id);
				itemy_menu(id)
			}
		}
		case 1:{
			if(menu_option[id] == 1){
				drop_helmet(id)
				itemy_menu(id)
			}
			else if(menu_option[id] == 0){
				info_helmet(id);
				itemy_menu(id)
			}
		}
		case 2:{
			if(menu_option[id] == 1){
				drop_weapon(id);
				itemy_menu(id)
			}
			else if(menu_option[id] == 0){
				info_weapon(id);
				itemy_menu(id)
			}
		}
		case 3:{
			if(menu_option[id] == 1){
				drop_branclet(id);
				itemy_menu(id)
			}
			else if(menu_option[id] == 0){
				info_branclet(id);
				itemy_menu(id)
			}
		}
		case 4:{
			if(menu_option[id] == 1){
				drop_necklace(id);
				itemy_menu(id)
			}
			else if(menu_option[id] == 0){
				info_necklace(id);
				itemy_menu(id)
			}
			
		}
		case 5:{
			if(menu_option[id] == 1){
				drop_earrings(id);
				itemy_menu(id)
			}
			else if(menu_option[id] == 0){
				info_earrings(id);
				itemy_menu(id)
			}
		}
		case 6:{
			if(menu_option[id] == 1){
				drop_shield(id);
				itemy_menu(id)
				
			}
			else if(menu_option[id] == 0){
				info_shield(id);
				itemy_menu(id)
			}
		}
		case 7:{
			if(menu_option[id] == 1){
				drop_shoes(id);
				itemy_menu(id)
				
			}
			else if(menu_option[id] == 0){
				info_shoes(id);
				itemy_menu(id)
			}
		}
		case 8:{
			if(menu_option[id] == 1){
				menu_option[id] = 0;
				itemy_menu(id)
			}
			else if(menu_option[id] == 0){
				menu_option[id] = 1;
				itemy_menu(id)
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public info_shoes(id){
	new path_to_file[64]
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/item.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o Broni</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body bgcolor = black>")
	write_file(path_to_file,Data,-1)
	
	switch(shoes_skills[Player_Class[id]][id][0]){
		case 1:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_name,shoes_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_level,shoes_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(shoes_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_bonus_down,shoes_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_bonus_up,shoes_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(shoes_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		case 2:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_unavailable,shoes_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(shoes_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(shoes_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_unavailable,shoes_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(shoes_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shoes_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		
	}
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1);
	show_motd(id,path_to_file,"Item")
}
public info_shield(id){
	new path_to_file[64]
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/item.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o Broni</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body bgcolor = black>")
	write_file(path_to_file,Data,-1)
	
	switch(shield_skills[Player_Class[id]][id][0]){
		case 1:
		{
			format(Data,1024,"<center><font color=%s>%s</font><br />",item_color_name,shield_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<center><font color=%s>Od Poziomu:%d</font><br />",item_color_level,shield_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(shield_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_bonus_down,shield_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_bonus_up,shield_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(shield_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		case 2:
		{
			format(Data,1024,"<center><font color=%s>%s</font><br />",item_color_unavailable,shield_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<center><font color=%s>Od Poziomu:%d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(shield_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(shield_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_unavailable,shield_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(shield_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(shield_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		
	}
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1);
	show_motd(id,path_to_file,"Item")
}
public info_earrings(id){
	new path_to_file[64]
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/item.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o Broni</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body bgcolor = black>")
	write_file(path_to_file,Data,-1)
	
	switch(earrings_skills[Player_Class[id]][id][0]){
		case 1:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_name,earrings_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_level,earrings_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(earrings_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_bonus_down,earrings_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_bonus_up,earrings_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(earrings_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		case 2:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_unavailable,earrings_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(earrings_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(earrings_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_unavailable,earrings_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(earrings_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(earrings_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		
	}
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1);
	show_motd(id,path_to_file,"Item")
}

public info_branclet(id){
	new path_to_file[64]
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/item.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o Broni</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body bgcolor = black>")
	write_file(path_to_file,Data,-1)
	
	switch(bracelet_skills[Player_Class[id]][id][0]){
		case 1:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_name,bracelet_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_level,bracelet_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(bracelet_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_bonus_down,bracelet_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_bonus_up,bracelet_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(bracelet_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		case 2:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_unavailable,bracelet_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(bracelet_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(bracelet_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_unavailable,bracelet_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(bracelet_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(bracelet_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		
	}
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1);
	show_motd(id,path_to_file,"Item")
}

public info_weapon(id){
	new path_to_file[64]
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/item.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o Broni</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body bgcolor = black>")
	write_file(path_to_file,Data,-1)
	
	switch(weapon_skill[Player_Class[id]][id][0]){
		case 1:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_name,weapon_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_level,weapon_skill[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(weapon_skill[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_bonus_down,weapon_skill[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_bonus_up,weapon_skill[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(weapon_skill[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		case 2:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_unavailable,weapon_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(weapon_skill[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(weapon_skill[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_unavailable,weapon_skill[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(weapon_skill[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(weapon_skill[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		
	}
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1);
	show_motd(id,path_to_file,"Item")
}

public info_helmet(id){
	new path_to_file[64] 
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/item.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o Broni</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body bgcolor = black>")
	write_file(path_to_file,Data,-1)
	
	switch(helmet_skills[Player_Class[id]][id][0]){
		case 1:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_name,helmet_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_level,helmet_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(helmet_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_bonus_down,helmet_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_bonus_up,helmet_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(helmet_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		case 2:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_unavailable,helmet_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(helmet_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(helmet_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_unavailable,helmet_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(helmet_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(helmet_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		
	}
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1);
	show_motd(id,path_to_file,"Item")
}

public info_necklace(id){
	new path_to_file[64] 
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/item.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o Broni</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body bgcolor = black>")
	write_file(path_to_file,Data,-1)
	
	switch(necklace_skills[Player_Class[id]][id][0]){
		case 1:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_name,necklace_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_level,necklace_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(necklace_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_bonus_down,necklace_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_bonus_up,necklace_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(necklace_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		case 2:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_unavailable,necklace_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(necklace_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(necklace_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_unavailable,necklace_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(necklace_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(necklace_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		
	}
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1);
	show_motd(id,path_to_file,"Item")
}

public info_armor(id){
	new path_to_file[64] 
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/item.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o Broni</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body bgcolor = black>")
	write_file(path_to_file,Data,-1)
	
	switch(armor_skills[Player_Class[id]][id][0]){
		case 1:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_name,armor_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_level,armor_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(armor_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][33])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_bonus_down,armor_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_bonus_up,armor_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(armor_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		case 2:
		{
			format(Data,1024,"<center><br /><font color=%s>%s</font><br />",item_color_unavailable,armor_name[Player_Class[id]][id])
			write_file(path_to_file,Data,-1);
			format(Data,1024,"<font color=%s>Od Poziomu:%d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][27])
			write_file(path_to_file,Data,-1);
			
			if(armor_skills[Player_Class[id]][id][33] < 0){
				format(Data,1024,"<font color=#%s>Dmg : %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][33] != 0)
			{
				format(Data,1024,"<font color=%s>Dmg : + %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][1] < 0){
				format(Data,1024,"<font color=#%s>Maks. P¯ : %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][1] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. P¯ : + %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][1])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][2] < 0){
				format(Data,1024,"<font color=%s>Maks. PE : %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][2] != 0)
			{
				format(Data,1024,"<font color=%s>Maks. PE : + %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][2])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][3] < 0){
				format(Data,1024,"<font color=%s>HP : %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][3] != 0)
			{
				format(Data,1024,"<font color=%s>HP : + %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][3])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][4] < 0){
				format(Data,1024,"<font color=%s>INT : %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][4] != 0)
			{
				format(Data,1024,"<font color=%s>INT : + %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][4])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][5] < 0){
				format(Data,1024,"<font color=%s>STR : %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][5] != 0)
			{
				format(Data,1024,"<font color=%s>STR : + %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][5])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][6] < 0){
				format(Data,1024,"<font color=%s>Zwinnosc : %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][6] != 0)
			{
				format(Data,1024,"<font color=%s>Zwinnosc : + %d</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][6])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][7] < 0){
				format(Data,1024,"<font color=%s>Szybkosc : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][7] != 0)
			{
				format(Data,1024,"<font color=%s>Szybkosc : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][7])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][8] < 0){
				format(Data,1024,"<font color=%s>Regeneracja PE : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][8] != 0)
			{
				format(Data,1024,"<font color=%s>Regeneracja PE : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][8])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][9] < 0){
				format(Data,1024,"<font color=%s>Szansa na otrucie : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][9] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na otrucie : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][9])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][10] < 0){
				format(Data,1024,"<font color=%s>Szansa na omdlenie : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][10] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na omdlenie : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][10])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][11] < 0){
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][11] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na spowoleninie : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][11])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][12] < 0){
				format(Data,1024,"<font color=%s>Szansa na krytyka : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][12] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na krytyka : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][12])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][13] < 0){
				format(Data,1024,"<font color=%s>Szansa na przeszywke : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][13] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na przeszywke  : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][13])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][14] < 0){
				format(Data,1024,"<font color=%s>Szansa na kradziez PE : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][14] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na kradziez PE  : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][14])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][15] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na trucizny : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][15] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na trucizny  : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][15])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][16] < 0){
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][16] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na bonus doswiadczenia  : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][16])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][17] < 0){
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][17] != 0)
			{
				format(Data,1024,"<font color=%s>Szansa na podwoja ilosc przediomotow  : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][17])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][18] != 0)
			{
				format(Data,1024,"<font color=%s>niewrazliwy na omdlenia</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][18])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][19] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko wojownikom : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][19] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko wojownikom  : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][19])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][20] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko surze : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][20] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko surze  : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][20])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][21] < 0){
				format(Data,1024,"<font color=%s>silny przeciwko szamanom  : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][21] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko szamanom   : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][21])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][22] < 0){
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom  : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][22] != 0)
			{
				format(Data,1024,"<font color=%s>Silny przeciwko ninjom   : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][22])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][23] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na wojownika  : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][23] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na wojownika   : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][23])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][24] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na ninja  : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][24] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na ninja   : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][24])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][25] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na sura  : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][25] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na sura   : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][25])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][26] < 0){
				format(Data,1024,"<font color=%s>Odpornosc na szaman   : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			else if(armor_skills[Player_Class[id]][id][26] != 0)
			{
				format(Data,1024,"<font color=%s>Odpornosc na szaman    : + %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][26])
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][32] != 0){
				format(Data,1024,"<font color=%s>Def  : %d %</font><br />",item_color_unavailable,armor_skills[Player_Class[id]][id][32])
				write_file(path_to_file,Data,-1);
			}
			
			
			format(Data,1024,"<font color=%s>[Do ubrania]</font><br />",item_color_wearing)
			write_file(path_to_file,Data,-1);
			
			if(armor_skills[Player_Class[id]][id][28] != 0){
				format(Data,1024,"<font color=%s>Wojownik</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][29] != 0){
				format(Data,1024,"<font color=%s>Ninja</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][30] != 0){
				format(Data,1024,"<font color=%s>Sura</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
			
			if(armor_skills[Player_Class[id]][id][31] != 0){
				format(Data,1024,"<font color=%s>Szaman</font>",item_color_class)
				write_file(path_to_file,Data,-1);
			}
		}
		
	}
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1);
	show_motd(id,path_to_file,"Item")
}



public drop_armor(id){
	if(armor_skills[Player_Class[id]][id][0] == 0) return PLUGIN_CONTINUE;
	
	if(Player_Level[Player_Class[id]][id] < armor_skills[Player_Class[id]][id][27]){
		for(new j = 0;j<34;j++){
			armor_skills[Player_Class[id]][id][j]=0;
		}
		armor_name[Player_Class[id]][id] = "";
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(armor_skills[Player_Class[id]][id][28] == 0){
				for(new j = 0;j<34;j++){
					armor_skills[Player_Class[id]][id][j]=0;
				}
				armor_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(armor_skills[Player_Class[id]][id][29] == 0){
				for(new j = 0;j<34;j++){
					armor_skills[Player_Class[id]][id][j]=0;
				}
				armor_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(armor_skills[Player_Class[id]][id][30] == 0){
				for(new j = 0;j<34;j++){
					armor_skills[Player_Class[id]][id][j]=0;
				}
				armor_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(armor_skills[Player_Class[id]][id][31] == 0){
				for(new j = 0;j<34;j++){
					armor_skills[Player_Class[id]][id][j]=0;
				}
				armor_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
	}
	armor_name[Player_Class[id]][id] = "";
	armor_skills[Player_Class[id]][id][0] = 0;
	max_hp[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id]-= armor_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id]-= armor_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][17];
	faint_no[Player_Class[id]][id] = 0;
	if(helmet_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 || weapon_skill[Player_Class[id]][id][18] == 1 || necklace_skills[Player_Class[id]][id][18] == 1 || earrings_skills[Player_Class[id]][id][18] == 1 || shield_skills[Player_Class[id]][id][18] == 1 ){
		faint_no[Player_Class[id]][id] = 1;
	}
	strong_against_warrior[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id] -= armor_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]-= armor_skills[Player_Class[id]][id][33]
	for(new j = 0;j<34;j++){
		armor_skills[Player_Class[id]][id][j]=0;
	}
	emit_sound( id, CHAN_STATIC, "metin2/drop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	return PLUGIN_CONTINUE;
}

public drop_helmet(id){
	if(helmet_skills[Player_Class[id]][id][0] == 0) return PLUGIN_CONTINUE;
	
	if(Player_Level[Player_Class[id]][id] < helmet_skills[Player_Class[id]][id][27]){
		for(new j = 0;j<34;j++){
			helmet_skills[Player_Class[id]][id][j]=0;
		}
		helmet_name[Player_Class[id]][id] = "";
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(helmet_skills[Player_Class[id]][id][28] == 0){
				for(new j = 0;j<34;j++){
					helmet_skills[Player_Class[id]][id][j]=0;
				}
				helmet_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(helmet_skills[Player_Class[id]][id][29] == 0){
				for(new j = 0;j<34;j++){
					helmet_skills[Player_Class[id]][id][j]=0;
				}
				helmet_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(helmet_skills[Player_Class[id]][id][30] == 0){
				for(new j = 0;j<34;j++){
					helmet_skills[Player_Class[id]][id][j]=0;
				}
				helmet_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(helmet_skills[Player_Class[id]][id][31] == 0){
				for(new j = 0;j<34;j++){
					helmet_skills[Player_Class[id]][id][j]=0;
				}
				helmet_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
	}
	helmet_name[Player_Class[id]][id] = "";
	helmet_skills[Player_Class[id]][id][0] = 0;
	max_hp[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id]-= helmet_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id]-= helmet_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][17];
	faint_no[Player_Class[id]][id] = 0;
	if(armor_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 || weapon_skill[Player_Class[id]][id][18] == 1 || necklace_skills[Player_Class[id]][id][18] == 1 || earrings_skills[Player_Class[id]][id][18] == 1 || shield_skills[Player_Class[id]][id][18] == 1 ){
		faint_no[Player_Class[id]][id] = 1;
	}
	strong_against_warrior[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id] -= helmet_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]-= helmet_skills[Player_Class[id]][id][33]
	for(new j = 0;j<34;j++){
		helmet_skills[Player_Class[id]][id][j]=0;
	}
	emit_sound( id, CHAN_STATIC, "metin2/drop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	return PLUGIN_CONTINUE;
}

public drop_weapon(id){
	if(weapon_skill[Player_Class[id]][id][0] == 0) return PLUGIN_CONTINUE;
	
	if(Player_Level[Player_Class[id]][id] < weapon_skill[Player_Class[id]][id][27]){
		for(new j = 0;j<34;j++){
			weapon_skill[Player_Class[id]][id][j]=0;
		}
		weapon_name[Player_Class[id]][id] = "";
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(weapon_skill[Player_Class[id]][id][28] == 0){
				for(new j = 0;j<34;j++){
					weapon_skill[Player_Class[id]][id][j]=0;
				}
				weapon_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(weapon_skill[Player_Class[id]][id][29] == 0){
				for(new j = 0;j<34;j++){
					weapon_skill[Player_Class[id]][id][j]=0;
				}
				weapon_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(weapon_skill[Player_Class[id]][id][30] == 0){
				for(new j = 0;j<34;j++){
					weapon_skill[Player_Class[id]][id][j]=0;
				}
				weapon_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(weapon_skill[Player_Class[id]][id][31] == 0){
				for(new j = 0;j<34;j++){
					weapon_skill[Player_Class[id]][id][j]=0;
				}
				weapon_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
	}
	weapon_name[Player_Class[id]][id] = "";
	weapon_skill[Player_Class[id]][id][0] = 0;
	max_hp[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id]-= weapon_skill[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id]-= weapon_skill[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][17];
	faint_no[Player_Class[id]][id] = 0;
	if(helmet_skills[Player_Class[id]][id][18] == 1 || armor_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 ||  necklace_skills[Player_Class[id]][id][18] == 1 || earrings_skills[Player_Class[id]][id][18] == 1 || shield_skills[Player_Class[id]][id][18] == 1 ){
		faint_no[Player_Class[id]][id] = 1;
	}
	strong_against_warrior[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id] -= weapon_skill[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]-= weapon_skill[Player_Class[id]][id][33]
	for(new j = 0;j<34;j++){
		weapon_skill[Player_Class[id]][id][j]=0;
	}
	emit_sound( id, CHAN_STATIC, "metin2/drop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	return PLUGIN_CONTINUE;
}

public drop_branclet(id){
	if(bracelet_skills[Player_Class[id]][id][0] == 0) return PLUGIN_CONTINUE;
	
	if(Player_Level[Player_Class[id]][id] < bracelet_skills[Player_Class[id]][id][27]){
		for(new j = 0;j<34;j++){
			bracelet_skills[Player_Class[id]][id][j]=0;
		}
		bracelet_name[Player_Class[id]][id] = "";
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(bracelet_skills[Player_Class[id]][id][28] == 0){
				for(new j = 0;j<34;j++){
					bracelet_skills[Player_Class[id]][id][j]=0;
				}
				bracelet_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(bracelet_skills[Player_Class[id]][id][29] == 0){
				for(new j = 0;j<34;j++){
					bracelet_skills[Player_Class[id]][id][j]=0;
				}
				bracelet_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(bracelet_skills[Player_Class[id]][id][30] == 0){
				for(new j = 0;j<34;j++){
					bracelet_skills[Player_Class[id]][id][j]=0;
				}
				bracelet_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(bracelet_skills[Player_Class[id]][id][31] == 0){
				for(new j = 0;j<34;j++){
					bracelet_skills[Player_Class[id]][id][j]=0;
				}
				bracelet_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
	}
	bracelet_name[Player_Class[id]][id] = "";
	bracelet_skills[Player_Class[id]][id][0] = 0;
	max_hp[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id]-= bracelet_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id]-= bracelet_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][17];
	faint_no[Player_Class[id]][id] = 0;
	if(helmet_skills[Player_Class[id]][id][18] == 1 || armor_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 || necklace_skills[Player_Class[id]][id][18] == 1 || earrings_skills[Player_Class[id]][id][18] == 1 || shield_skills[Player_Class[id]][id][18] == 1 ){
		faint_no[Player_Class[id]][id] = 1;
	}
	strong_against_warrior[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id] -= bracelet_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]-= bracelet_skills[Player_Class[id]][id][33]
	for(new j = 0;j<34;j++){
		bracelet_skills[Player_Class[id]][id][j]=0;
	}
	emit_sound( id, CHAN_STATIC, "metin2/drop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	return PLUGIN_CONTINUE;
}


public drop_necklace(id){
	if(necklace_skills[Player_Class[id]][id][0] == 0) return PLUGIN_CONTINUE;
	
	if(Player_Level[Player_Class[id]][id] < necklace_skills[Player_Class[id]][id][27]){
		for(new j = 0;j<34;j++){
			necklace_skills[Player_Class[id]][id][j]=0;
		}
		necklace_name[Player_Class[id]][id] = "";
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(necklace_skills[Player_Class[id]][id][28] == 0){
				for(new j = 0;j<34;j++){
					necklace_skills[Player_Class[id]][id][j]=0;
				}
				necklace_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(necklace_skills[Player_Class[id]][id][29] == 0){
				for(new j = 0;j<34;j++){
					necklace_skills[Player_Class[id]][id][j]=0;
				}
				necklace_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(necklace_skills[Player_Class[id]][id][30] == 0){
				for(new j = 0;j<34;j++){
					necklace_skills[Player_Class[id]][id][j]=0;
				}
				necklace_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(necklace_skills[Player_Class[id]][id][31] == 0){
				for(new j = 0;j<34;j++){
					necklace_skills[Player_Class[id]][id][j]=0;
				}
				necklace_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
	}
	necklace_name[Player_Class[id]][id] = "";
	necklace_skills[Player_Class[id]][id][0] = 0;
	max_hp[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id]-= necklace_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id]-= necklace_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][17];
	faint_no[Player_Class[id]][id] = 0;
	if( helmet_skills[Player_Class[id]][id][18] == 1 || armor_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 ||  necklace_skills[Player_Class[id]][id][18] == 1 || earrings_skills[Player_Class[id]][id][18] == 1 || shield_skills[Player_Class[id]][id][18] == 1 ){
		faint_no[Player_Class[id]][id] = 1;
	}
	strong_against_warrior[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id] -= necklace_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]-= necklace_skills[Player_Class[id]][id][33]
	for(new j = 0;j<34;j++){
		necklace_skills[Player_Class[id]][id][j]=0;
	}
	emit_sound( id, CHAN_STATIC, "metin2/drop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	return PLUGIN_CONTINUE;
}

public drop_earrings(id){
	if(earrings_skills[Player_Class[id]][id][0] == 0) return PLUGIN_CONTINUE;
	
	if(Player_Level[Player_Class[id]][id] < earrings_skills[Player_Class[id]][id][27]){
		for(new j = 0;j<34;j++){
			earrings_skills[Player_Class[id]][id][j]=0;
		}
		earrings_name[Player_Class[id]][id] = "";
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(earrings_skills[Player_Class[id]][id][28] == 0){
				for(new j = 0;j<34;j++){
					earrings_skills[Player_Class[id]][id][j]=0;
				}
				earrings_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(earrings_skills[Player_Class[id]][id][29] == 0){
				for(new j = 0;j<34;j++){
					earrings_skills[Player_Class[id]][id][j]=0;
				}
				earrings_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(earrings_skills[Player_Class[id]][id][30] == 0){
				for(new j = 0;j<34;j++){
					earrings_skills[Player_Class[id]][id][j]=0;
				}
				earrings_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(earrings_skills[Player_Class[id]][id][31] == 0){
				for(new j = 0;j<34;j++){
					earrings_skills[Player_Class[id]][id][j]=0;
				}
				earrings_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
	}
	earrings_name[Player_Class[id]][id] = "";
	earrings_skills[Player_Class[id]][id][0] = 0;
	max_hp[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id]-= earrings_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id]-= earrings_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][17];
	faint_no[Player_Class[id]][id] = 0;
	if( helmet_skills[Player_Class[id]][id][18] == 1 || armor_skills[Player_Class[id]][id][18] == 1 ||  shoes_skills[Player_Class[id]][id][18] == 1 || earrings_skills[Player_Class[id]][id][18] == 1 || shield_skills[Player_Class[id]][id][18] == 1 || necklace_skills[Player_Class[id]][id][18] == 1){
		faint_no[Player_Class[id]][id] = 1;
	}
	strong_against_warrior[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id] -= earrings_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]-= earrings_skills[Player_Class[id]][id][33]
	for(new j = 0;j<34;j++){
		earrings_skills[Player_Class[id]][id][j]=0;
	}
	emit_sound( id, CHAN_STATIC, "metin2/drop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	return PLUGIN_CONTINUE;
}

public drop_shield(id){
	if(shield_skills[Player_Class[id]][id][0] == 0) return PLUGIN_CONTINUE;
	
	if(Player_Level[Player_Class[id]][id] < shield_skills[Player_Class[id]][id][27]){
		for(new j = 0;j<34;j++){
			shield_skills[Player_Class[id]][id][j]=0;
		}
		shield_name[Player_Class[id]][id] = "";
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(shield_skills[Player_Class[id]][id][28] == 0){
				for(new j = 0;j<34;j++){
					shield_skills[Player_Class[id]][id][j]=0;
				}
				shield_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(shield_skills[Player_Class[id]][id][29] == 0){
				for(new j = 0;j<34;j++){
					shield_skills[Player_Class[id]][id][j]=0;
				}
				shield_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(shield_skills[Player_Class[id]][id][30] == 0){
				for(new j = 0;j<34;j++){
					shield_skills[Player_Class[id]][id][j]=0;
				}
				shield_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(shield_skills[Player_Class[id]][id][31] == 0){
				for(new j = 0;j<34;j++){
					shield_skills[Player_Class[id]][id][j]=0;
				}
				shield_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
	}
	shield_name[Player_Class[id]][id] = "";
	shield_skills[Player_Class[id]][id][0] = 0;
	max_hp[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id]-= shield_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id]-= shield_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][17];
	faint_no[Player_Class[id]][id] = 0;
	if(shield_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 || helmet_skills[Player_Class[id]][id][18] == 1 || armor_skills[Player_Class[id]][id][18] == 1 || earrings_skills[Player_Class[id]][id][18] == 1 || necklace_skills[Player_Class[id]][id][18] == 1 ) {
		faint_no[Player_Class[id]][id] = 1;
	}
	strong_against_warrior[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id] -= shield_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]-= shield_skills[Player_Class[id]][id][33]
	for(new j = 0;j<34;j++){
		shield_skills[Player_Class[id]][id][j]=0;
	}
	emit_sound( id, CHAN_STATIC, "metin2/drop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	return PLUGIN_CONTINUE;
}

public drop_shoes(id){
	if(shoes_skills[Player_Class[id]][id][0] == 0) return PLUGIN_CONTINUE;
	
	if(Player_Level[Player_Class[id]][id] < shoes_skills[Player_Class[id]][id][27]){
		for(new j = 0;j<34;j++){
			shoes_skills[Player_Class[id]][id][j]=0;
			shoes_name[Player_Class[id]][id] = "";
		}
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(shoes_skills[Player_Class[id]][id][28] == 0){
				for(new j = 0;j<34;j++){
					shoes_skills[Player_Class[id]][id][j]=0;
				}
				shoes_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(shoes_skills[Player_Class[id]][id][29] == 0){
				for(new j = 0;j<34;j++){
					shoes_skills[Player_Class[id]][id][j]=0;
				}
				shoes_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(shoes_skills[Player_Class[id]][id][30] == 0){
				for(new j = 0;j<34;j++){
					shoes_skills[Player_Class[id]][id][j]=0;
				}
				shoes_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(shoes_skills[Player_Class[id]][id][31] == 0){
				for(new j = 0;j<34;j++){
					shoes_skills[Player_Class[id]][id][j]=0;
				}
				shoes_name[Player_Class[id]][id] = "";
				return PLUGIN_CONTINUE;
			}
		}
	}
	shoes_name[Player_Class[id]][id] = "";
	shoes_skills[Player_Class[id]][id][0] = 0;
	max_hp[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id]-= shoes_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id]-= shoes_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][17];
	faint_no[Player_Class[id]][id] = 0;
	if(shoes_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 || shoes_skills[Player_Class[id]][id][18] == 1 ){
		faint_no[Player_Class[id]][id] = 1;
	}
	strong_against_warrior[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id] -= shoes_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]-= shoes_skills[Player_Class[id]][id][33]
	for(new j = 0;j<34;j++){
		shoes_skills[Player_Class[id]][id][j]=0;
	}
	emit_sound( id, CHAN_STATIC, "metin2/drop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	return PLUGIN_CONTINUE;
}



public postac(id){
	new path_to_file[64]
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,63,"%s/metin2/postac.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	new name[64];
	get_user_name(id,name,63);
	new klasa[64];
	if(Player_Class[id] == 1){
		format(klasa,63,"Wojownik");
	}
	else if(Player_Class[id] == 2){
		format(klasa,63,"Ninja");
	}
	else if(Player_Class[id] == 3){
		format(klasa,63,"Sura");
	}
	else if(Player_Class[id] == 4){
		format(klasa,63,"Szaman");
	}
	
	new nazwa_rangi[64]
	if(rank[Player_Class[id]][id] > 12000){
		format(nazwa_rangi,63,"<font color=#00FFFF>Rycerski</font>")
	}
	else if(rank[Player_Class[id]][id] > 8000){
		format(nazwa_rangi,63,"<font color=blue>Szlachetny</font>")
	}
	else if(rank[Player_Class[id]][id]> 4000){
		format(nazwa_rangi,63,"<font color=#3366FF>Dobry</font>")
	}
	else if(rank[Player_Class[id]][id] > 1000){
		format(nazwa_rangi,63,"<font color=#333399>Przyjazny</font>")
	}
	else if(rank[Player_Class[id]][id] > -999){
		format(nazwa_rangi,63,"<font color=white>Neutralny</font>")
	}
	else if(rank[Player_Class[id]][id] < -999){
		format(nazwa_rangi,63,"<font color=#FF9900>Agresywny</font>")
	}
	else if(rank[Player_Class[id]][id]< -4000){
		format(nazwa_rangi,63,"<font color=#FF6600>Nieuczciwy</font>")
	}
	else if(rank[Player_Class[id]][id]< -8000){
		format(nazwa_rangi,63,"<font color=#800000>Zlosliwy</font>")
	}
	else if(rank[Player_Class[id]][id] < -16000){
		format(nazwa_rangi,63,"<font color=red>Okrutny</font>")
	}
	new rank_motd[64];
	
	
	
	format(rank_motd,63,"Ranga: %d || %s",rank[Player_Class[id]][id],nazwa_rangi)
	
	format(Data,1023,"<html><head><title>Informacje o postaci</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1023,"<body bgcolor=black><center></center></body>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1023,"<p align=center><font color=yellow>Nick:%s<br />Klasa:%s<br />Krolestwo:%s<br />Level:%d<br />%s<br />Czas gry:%d<br />Obecnie posiadany exp:%d<br />EXP wymagany na nastêpny level:%d<br />",name,klasa,KINGDOMS[Player_Kingdom[id]],Player_Level[Player_Class[id]][id],rank_motd,time_played[Player_Class[id]][id],Player_XP[Player_Class[id]][id],LEVELS[Player_Level[Player_Class[id]][id]]);
	write_file(path_to_file,Data,-1)
	
	format(Data,1023,"HP:%d<br />MP:%d<br />STR:%d<br />DEX:%d<br />Szybkosc ruchu:%f<br />Uniki:</p>",player_hp[Player_Class[id]][id]+add_con[Player_Class[id]][id],player_int[Player_Class[id]][id],player_str[Player_Class[id]][id]+add_str[Player_Class[id]][id],player_dex[Player_Class[id]][id]+add_dex[Player_Class[id]][id],gfCSSpeeds[get_user_weapon(id)]+add_speed[Player_Class[id]][id],((player_dex[Player_Class[id]][id] + add_dex[Player_Class[id]][id]) / 2));
	write_file(path_to_file,Data,-1)
	
	format(Data,1023,"<br />%s<br />%s<br />%s<br />%s<br />%s<br />%s<br />%s<br />%s",armor_name[Player_Class[id]][id],helmet_name[Player_Class[id]][id],weapon_name[Player_Class[id]][id],bracelet_name[Player_Class[id]][id],necklace_name[Player_Class[id]][id],earrings_name[Player_Class[id]][id],shield_name[Player_Class[id]][id],shoes_name[Player_Class[id]][id])
	write_file(path_to_file,Data,-1)
	
	format(Data,1023,"</html>")
	write_file(path_to_file,Data,-1)
	
	show_motd(id, path_to_file, "Informacje o postaci")
	
	return PLUGIN_HANDLED
	
}

public motd_player_stats(id,tresc[]){
	new path_to_file[128]
	new sciezka_do_obrazku[64]	
	
	get_basedir(amxbasedir,63)
	
	format(path_to_file,127,"%s/metin2/stats.txt",amxbasedir)
	
	if(file_exists(path_to_file)){
		delete_file(path_to_file)
	}
	new Data[1024];
	
	format(Data,1024,"<html><head><title>Informacje o postaci</title></head>")
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<body text=white bgcolor=black>",sciezka_do_obrazku)
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"<b>%s</b>",tresc)
	write_file(path_to_file,Data,-1)
	
	format(Data,1024,"</body></html>")
	write_file(path_to_file,Data,-1)
	
	show_motd(id, path_to_file, "Informacje o postaci")
	
	return PLUGIN_HANDLED
	
}

public tskShowSkills(){
	for( new i = 1; i <= g_maxplayers; i++ )
	{
		
		if(g_isalive(i) )
		{
			continue;
		}
		
		if( get_pcvar_num(cvar_csdm) == 1 && is_user_connected(i) && cs_get_user_team(i) != CS_TEAM_SPECTATOR){
			if(task_exists(i+csdm_task)){
				continue;
			}
			else
			{
				set_task( get_pcvar_float(cvar_csdmresptime),"respawn_player",i+csdm_task);
				continue;
			}
		}
		
		new sendTo[33];
		
		for( new j = 1; j <= g_maxplayers; j++ )
		{
			if( is_user_connected(j) )
			{
				if( pev(i, pev_iuser2) == j ){
					sendTo[i] = j;
				}
			}
		}
		for( new look = 1; look <= g_maxplayers; look++ ){
			if(sendTo[look] > 0 && sendTo[look] < 33 ){
				set_hudmessage(255, 255, 255, 0.8, 0.3, 0, 0.0, UPDATEINTERVAL+0.1, 0.0, 0.0, -1)
				show_hudmessage(look, "Statystyki:^nHP: %i^nInteligencja: %i^nSila: %i^nZrecznosc: %i",player_hp[Player_Class[sendTo[look]]][sendTo[look]],player_int[Player_Class[sendTo[look]]][sendTo[look]],player_str[Player_Class[sendTo[look]]][sendTo[look]],player_dex[Player_Class[sendTo[look]]][sendTo[look]])
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public ResetHud(id){
	if (Player_Class[id] == CLASS_NONE && shift_class[id] == 0) {
		chooseclass(id)
		return PLUGIN_HANDLED;
	}
	if (Player_Kingdom[id] == KINGDOM_NONE){
		choosekingdom(id);
		return PLUGIN_HANDLED;
	}
	if (player_point[Player_Class[id]][id] > 0 ){
		skillmenu(id);
		return PLUGIN_HANDLED;
	}
	ShowHUD(id)
	return PLUGIN_HANDLED;
}

public Nowa_Runda(){
	if(task_exists(1)){
		remove_task(1);
	}
	
}

public off_kingomflag(id){
	id-=kingdom_task;
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(125)
	write_byte(id)
	message_end()
}

public ustaw_hp(id){
	if(get_pcvar_num(cvar_empire) == 1){
		switch(Player_Kingdom[id]){
			case 1:
			{
				message_begin(MSG_ALL, SVC_TEMPENTITY)
				write_byte(124)
				write_byte(id)
				write_coord(35)
				write_short(link_shinsoo)
				write_short(100)
				message_end()
			}
			case 2:
			{
				message_begin(MSG_ALL, SVC_TEMPENTITY)
				write_byte(124)
				write_byte(id)
				write_coord(35)
				write_short(link_chunjo)
				write_short(100)
				message_end()
			}
			case 3:
			{
				message_begin(MSG_ALL, SVC_TEMPENTITY)
				write_byte(124)
				write_byte(id)
				write_coord(35)
				write_short(link_jinno)
				write_short(100)
				message_end()
			}
		}
	}
	else if(get_pcvar_num(cvar_empire) == 2 || get_pcvar_num(cvar_empire) == 4){
		switch(Player_Kingdom[id]){
			case 1:
			{
				message_begin(MSG_ALL, SVC_TEMPENTITY)
				write_byte(124)
				write_byte(id)
				write_coord(35)
				write_short(link_shinsoo)
				write_short(100)
				message_end()
			}
			case 2:
			{
				message_begin(MSG_ALL, SVC_TEMPENTITY)
				write_byte(124)
				write_byte(id)
				write_coord(35)
				write_short(link_chunjo)
				write_short(100)
				message_end()
			}
			case 3:
			{
				message_begin(MSG_ALL, SVC_TEMPENTITY)
				write_byte(124)
				write_byte(id)
				write_coord(35)
				write_short(link_jinno)
				write_short(100)
				message_end()
			}
		}
		set_task(5.0,"off_kingomflag",id+kingdom_task);
	}
	
	if(task_exists(id+mana_task)){
		remove_task(id+mana_task);
		set_task( get_pcvar_float(cvar_manatime),"dodawanie_many",id+mana_task)
	}
	if(task_exists(id+slowdown_task)){
		remove_task(id+slowdown_task);
		slowdown_player[id] = 0;
	}
	if(task_exists(id + subtract_hp_task)){
		remove_task(id + subtract_hp_task);
	}
	if(task_exists(id+antidote_task)){
		remove_task(id+antidote_task)
		poison[id][0] = 0;
	}
	change_stats[id] = 0;
	if(g_isalive(id)){
		set_user_health(id,((player_hp[Player_Class[id]][id]+add_con[Player_Class[id]][id])* get_pcvar_num(cvar_hpadd))+get_user_health(id) + max_hp[Player_Class[id]][id])
	}
	Player_mana[id] = 100 + player_int[Player_Class[id]][id]
	if(Player_XP[Player_Class[id]][id] >= LEVELS[Player_Level[Player_Class[id]][id]]) {
		DajXp(id,0)
	}
	if(shift_class[id] != 0){
		switch(shift_class[id]){
			case 1:
			{
				
				Player_Class[id] = CLASS_WAR;
				Player_Class[id] = 1;
				shift_class[id] = 0;
				play_sound(id,"metin2/warrior_select.wav");
				ColorChat(id,GREEN, "[Metin2 Mod]^x01 Twoja klasa to Wojownik.");
			}
			case 2:
			{
				
				
				Player_Class[id] = 2
				Player_Class[id] = CLASS_NINJA
				shift_class[id] = 0;
				play_sound(id,"metin2/assassin_select.wav")
				ColorChat(id,GREEN, "[Metin2 Mod]^x01 Twoja klasa to Ninja.")
			}
			
			case 3:
			{
				
				Player_Class[id] = 3
				Player_Class[id] = CLASS_SURA
				shift_class[id] = 0;
				play_sound(id,"metin2/sura_select.wav")
				ColorChat(id,GREEN, "[Metin2 Mod]^x01 Twoja klasa to Sura.")
			}    
			
			case 4:
			{
				
				
				Player_Class[id] = 4
				Player_Class[id] = CLASS_MAGE
				shift_class[id] = 0;
				play_sound(id,"metin2/shaman_select.wav")
				ColorChat(id,GREEN, "[Metin2 Mod]^x01 Twoja klasa to Szaman.")
			}
		}
	}
}


public Event_Change_Weapon(id){
	new bron=read_data(2)
	bow[id] = 0;
	if(task_exists(reload_task+id)){
		remove_task(reload_task+id);
	}
	set_bartime(id,0,0)
	new Float:ile_dodac = (float(add_speed[Player_Class[id]][id])*100)/gfCSSpeeds[bron];
	if(slowdown_player[id] == 1){
		set_user_maxspeed(id,(gfCSSpeeds[bron]+ile_dodac)-30.0);
	}
	else
	{
		set_user_maxspeed(id,gfCSSpeeds[bron]+ile_dodac);
	}
	
	if(faint[id] == 1){
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
		set_pev(id, pev_maxspeed, 1.0)
		message_begin(MSG_ONE, g_msgScreenFade, _, id)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(FFADE_STAYOUT) // fade type
		write_byte(0) // red
		write_byte(50) // green
		write_byte(200) // blue
		write_byte(100) // alpha
		message_end()
	}
	weapon[id] = bron;
	
}


public dodawanie_many(id){
	id -= mana_task;
	new j = id
	if(g_isalive(j)){
		if(Player_mana[j] < 100 + player_int[Player_Class[j]][j] + max_mp[Player_Class[j]][j] + add_int[Player_Class[j]][j]){
			if(((100 + player_int[Player_Class[j]][j]) + max_mp[Player_Class[j]][j] + add_int[Player_Class[j]][j]) - Player_mana[j] <  get_pcvar_num(cvar_manaadd)){
				Player_mana[j] = 100 + player_int[Player_Class[j]][j] + max_mp[Player_Class[j]][j] +  add_int[Player_Class[j]][j]
			}
			else
			{
				Player_mana[j]+= get_pcvar_num(cvar_manaadd);
			}
		}
	}
	set_task( get_pcvar_float(cvar_manatime)-(float(mana_regeneration[Player_Class[j]][j]*100)/ get_pcvar_float(cvar_manatime)),"dodawanie_many",id + mana_task);
}

public bomb_defusing(id){
	defuser = id;
	return PLUGIN_CONTINUE;
}

public got_bomb(id){
	has_bomb = id
	return PLUGIN_CONTINUE;
}

public award_defuse(){
	for(new i = 1;i <=g_maxplayers;i++){
		if(g_isalive(i)){
			if(get_user_team(i) == 2 && i != defuser){
				DajXp(i, get_pcvar_num(cvar_xpbonus2));
				ColorChat(i,GREEN,"Dostales %i expa za rozbrojenie bomby przez twoj team", get_pcvar_num(cvar_xpbonus2))
			}
			else if(get_user_team(i) == 2 && i == defuser){
				DajXp(i, get_pcvar_num(cvar_xpbonus));
				ColorChat(i,GREEN,"Dostales %i expa za rozbrojenie bomby", get_pcvar_num(cvar_xpbonus))
			}
		}
	}
}

public award_plant(){
	for(new i = 1;i < g_maxplayers;i++){
		if(g_isalive(i)){
			if(get_user_team(i) == 1 && i != has_bomb){
				DajXp(i, get_pcvar_num(cvar_xpbonus2));
				ColorChat(i,GREEN,"Dostales %i expa za pod³ozenie bomby przez twoj team", get_pcvar_num(cvar_xpbonus2))
			}
			else if(get_user_team(i) == 1 && i == has_bomb){
				DajXp(i, get_pcvar_num(cvar_xpbonus));
				ColorChat(i,GREEN,"Dostales %i expa za pod³ozenie bomby", get_pcvar_num(cvar_xpbonus))
			}
		}
	}
}

public award_hostageALL(id){
	if(is_user_connected(id)){
		DajXp(id, get_pcvar_num(cvar_xpbonus2));
		ColorChat(id,GREEN,"Dostales %i expa za uratowanie zak³adnikow", get_pcvar_num(cvar_xpbonus2))
	}
}

public host_killed(id){
	if(is_user_connected(id)){
		OdejmijXp(id, get_pcvar_num(cvar_xpteamkill));
		ColorChat(id,GREEN,"Straciles %i expa za zabicie zak³adnika", get_pcvar_num(cvar_xpteamkill))
	}
}

public Damage(id) { 
	new kid = get_user_attacker(id)
	zatruc_go_czy_nie(kid,id);
	spowolnic_go_o_to_jest_ptanie(kid,id);
	omdlenie(kid,id);
	if(przekazanie_many_losowanie(kid,id)){
		przekaz_mane(id,kid,get_cvar_num("mt2_mana_przekazanie"));
	}
}

public przekazanie_many_losowanie(id,kid){
	if(random_num(1,100) <= chance_stealing_mana[Player_Class[id]][id]){
		return true;
	}
	return false;
}

public omdlenie(id,omdleniec_lol){
	if(random_num(1,100) <= chance_faint[Player_Class[id]][id]){
		if(faint_no[Player_Class[omdleniec_lol]][omdleniec_lol] == 0){
			faint[omdleniec_lol] = 1;
			set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
			set_pev(id, pev_maxspeed, 1.0)
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(0) // duration
			write_short(10) // hold time
			write_short(FFADE_STAYOUT) // fade type
			write_byte(0) // red
			write_byte(0) // green
			write_byte(0) // blue
			write_byte(255) // alpha
			message_end()
			set_task(5.0,"omdelnij_lol_dziwne_to",omdleniec_lol+faint_task);
		}
	}
}

public omdelnij_lol_dziwne_to(id){
	faint[id] = 0;
}	

public spowolnic_go_o_to_jest_ptanie(id,kogo_spowolnic){
	if(random_num(1,100) <= chance_slowdown[Player_Class[id]][id]){
		slowdown_player[kogo_spowolnic]  = 1;
		set_task(5.0,"odspowolnij_dziwna_nazwa",kogo_spowolnic+slowdown_task);
	}
}

public odspowolnij_dziwna_nazwa(id){
	slowdown_player[id] = 0;
}

public zatruc_go_czy_nie(id,kogo_otruc){
	if(random_num(1,100) <= chance_poisoning[Player_Class[id]][id]){
		if(random_num(1,100) > poison_resistance[Player_Class[kogo_otruc]][kogo_otruc]){
			poison[kogo_otruc][0]  = 1;
			poison[kogo_otruc][1]  = id;
			message_begin(MSG_ONE, g_msgScreenFade, _, kogo_otruc)
			write_short(10) // duration
			write_short(5) // hold time
			write_short(FFADE_STAYOUT) // fade type
			write_byte(0) // red
			write_byte(80) // green
			write_byte(0) // blue
			write_byte(100) // alpha
			message_end()
			set_task( get_pcvar_float(cvar_poisontimeantidote),"odtruj",kogo_otruc+antidote_task);
			set_task( get_pcvar_float(cvar_poisontimerec),"trucizna_zabieranie_hp",kogo_otruc + subtract_hp_task);
		}
	}
}

public odtruj(id){
	id -=antidote_task;
	poison[id][0] = 0;
	if(task_exists(id+subtract_hp_task)){
		remove_task(id+subtract_hp_task);
	}
}

public trucizna_zabieranie_hp(id){
	id-=subtract_hp_task;
	if(g_isalive(id)){
		if(poison[id][0] == 1 && get_user_health(id) -  get_pcvar_num(cvar_poisondmg) > 0){
			set_user_health(id,get_user_health(id) -  get_pcvar_num(cvar_poisondmg))
		}
		else
		{
			UTIL_Kill(poison[id][1],id,"CSW_KNIFE");
		}
	}
	set_task( get_pcvar_float(cvar_poisontimerec),"trucizna_zabieranie_hp",id+subtract_hp_task);
}

public UTIL_Kill(attacker,id,weapon[]){
	
	if(get_user_team(attacker)!=get_user_team(id)){
		if(attacker < 33 && attacker > 0 && id < 33 && id > 0){
			set_user_frags(attacker,get_user_frags(attacker) +1);
		}
	}
	else if(get_user_team(attacker)==get_user_team(id)){
		if(attacker < 33 && attacker > 0 && id < 33 && id > 0){
			set_user_frags(attacker,get_user_frags(attacker) -1); 
		}
	}
	if (attacker < 33 && attacker > 0 && id < 33 && is_user_connected(attacker) && cs_get_user_money(attacker) + 150 <= 16000){
		if(attacker < 33 && attacker > 0 && id < 33){
			cs_set_user_money(attacker,cs_get_user_money(attacker)+150) 
		}
	}
	else{ 
		if(attacker < 33 && attacker > 0 && id < 33 && id > 0){
			cs_set_user_money(attacker,16000) 
		}
	}
	
	user_kill(id,1) 
	message_begin( MSG_ALL, g_msgDeathMsg,{0,0,0},0) 
	write_byte(attacker) 
	write_byte(id) 
	write_byte(0) 
	write_string(weapon) 
	message_end() 
	
	message_begin(MSG_ALL,g_msgScoreInfo) 
	write_byte(attacker) 
	write_short(get_user_frags(attacker)) 
	write_short(get_user_deaths(attacker)) 
	write_short(0) 
	write_short(get_user_team(attacker)) 
	message_end() 
	
	message_begin(MSG_ALL,g_msgScoreInfo) 
	write_byte(id) 
	write_short(get_user_frags(id)) 
	write_short(get_user_deaths(id)) 
	write_short(0) 
	write_short(get_user_team(id)) 
	message_end() 
}

public show_deadmessage(killer_id,victim_id,headshot,weaponname[]) 
{ 
	if (!(killer_id==victim_id && !headshot && equal(weaponname,"world"))) 
	{ 
		message_begin( MSG_ALL, g_msgDeathMsg,{0,0,0},0) 
		write_byte(killer_id) 
		write_byte(victim_id) 
		write_byte(headshot) 
		write_string(weaponname) 
		message_end() 
	} 
}

public touchWorld(Toucher, Touched){
	remove_entity(Toucher);
}

public knife_touch(Toucher, Touched){
	new kid = entity_get_edict(Toucher, EV_ENT_owner)
	new vic = entity_get_edict(Toucher, EV_ENT_enemy)
	if(g_isalive(Touched)) 
	{
		new bool:zyje = true;
		if(kid == Touched || vic == Touched)
		{
			return ;
		}
		if(get_cvar_num("mp_friendlyfire") == 0 && get_user_team(Touched) == get_user_team(kid)) 
		{
			return ;
		}
		
		message_begin(MSG_ONE,get_user_msgid("ScreenShake"),{0,0,0},Touched); 
		write_short(7<<14); 
		write_short(1<<13); 
		write_short(1<<14); 
		message_end();
		
		if(weapon_skill[Player_Class[kid]][kid][33] >= get_user_health(Touched)){
			zyje = false;
		}
		if(zyje == true){
			if(get_user_team(Touched) == get_user_team(kid)) 
			{
				new name[33]
				get_user_name(kid,name,32)
				client_print(0,print_chat,"%s attacked a teammate",name)
			}
			set_user_health(Touched, get_user_health(Touched) - weapon_skill[Player_Class[kid]][kid][33])
			emit_sound(Touched, CHAN_ITEM, "weapons/knife_hit4.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		else
		{
			if(get_user_team(Touched) == get_user_team(kid)) {
				set_user_frags(kid, get_user_frags(kid) - 1)
				client_print(kid,print_center,"You killed a teammate")
			}
			else {
				set_user_frags(kid, get_user_frags(kid) + 1)
			}
			
			new g_msgScoreInfo = get_user_msgid("ScoreInfo")
			new g_msgDeathMsg = get_user_msgid("DeathMsg")
			
			
			set_msg_block(g_msgDeathMsg,BLOCK_ONCE)
			set_msg_block(g_msgScoreInfo,BLOCK_ONCE)
			user_kill(Touched,1)
			
			
			message_begin(MSG_ALL,g_msgScoreInfo)
			write_byte(kid)
			write_short(get_user_frags(kid))
			write_short(get_user_deaths(kid))
			write_short(0)
			write_short(get_user_team(kid))
			message_end()
			
			
			message_begin(MSG_ALL,g_msgScoreInfo)
			write_byte(Touched)
			write_short(get_user_frags(Touched))
			write_short(get_user_deaths(Touched))
			write_short(0)
			write_short(get_user_team(Touched))
			message_end()
			
			
			message_begin(MSG_ALL,g_msgDeathMsg,{0,0,0},0)
			write_byte(kid)
			write_byte(Touched)
			write_byte(0)
			write_string("knife")
			message_end()
		}
		
		remove_entity(Toucher)
	}
}


public DeathMsg()
{
	if(get_pcvar_num(cvar_toggle) == 0) {
		return PLUGIN_HANDLED
	}
	
	new attacker = read_data(1)
	new victim = read_data(2)
	
	if(!g_isalive(attacker)){
		return PLUGIN_HANDLED;
	}
	
	if(Player_Class[attacker] == CLASS_NONE) {
		return PLUGIN_HANDLED
	}
	
	if(Player_Level[Player_Class[attacker]][attacker] == 99) {
		return PLUGIN_HANDLED
	}
	if(get_user_team(attacker) == get_user_team(victim)){
		PrzekazXP(attacker,victim, get_pcvar_num(cvar_xpteamkill))
		rank[Player_Class[attacker]][attacker]-=100;
		return PLUGIN_HANDLED
	}
	Player_XP[Player_Class[attacker]][attacker] +=  get_pcvar_num(cvar_xpkill) 
	if(Player_XP[Player_Class[attacker]][attacker] >= LEVELS[Player_Level[Player_Class[attacker]][attacker]]) {
		DajXp(attacker,0)
	}
	how_many_kills[attacker]++;
	rank[Player_Class[attacker]][attacker]++;
	if((how_many_kills[attacker]% get_pcvar_num(cvar_killforitem)) == 0){
		daj_mu_item(attacker);
		if(drugi_item(attacker) == 1){
			daj_mu_item(attacker);
		}
	}
	if(bonus_exp[Player_Class[attacker]][attacker] != 0){
		DajXp(attacker, get_pcvar_num(cvar_xpkill) * (bonus_exp[Player_Class[attacker]][attacker] / 100))
	}
	
	if( get_pcvar_num(cvar_csdm) == 1 ){
		if(task_exists(victim+csdm_task)){
			remove_task(victim+csdm_task)
		}
		server_cmd("mp_buytime 9999999")
		set_task( get_pcvar_float(cvar_csdmresptime),"respawn_player",victim+csdm_task);
	}
	
	ShowHUD(attacker)
	new weaponname[20] 
	new headshot = read_data(3) 
	read_data(4,weaponname,31) 
	
	show_deadmessage(attacker,victim,headshot,weaponname) 
	
	return PLUGIN_CONTINUE
}


public drugi_item(id){
	if(random_num(1,100) <= dual_drop[Player_Class[id]][id]){
		return 1;
	}
	return 0;
}

public daj_mu_item(id){
	new rodzaj = random_num(1,8);
	switch(rodzaj){
		case 1:
		{
			if(armor_skills[Player_Class[id]][id][0] == 1){
				return PLUGIN_HANDLED
			}
			else
			{
				
				daj_mu_armor(id);
			}
		}
		case 2:
		{
			if(helmet_skills[Player_Class[id]][id][0] == 1){
				return PLUGIN_HANDLED
			}
			else
			{
				daj_mu_helm(id);
			}
		}
		case 3:
		{
			if(shoes_skills[Player_Class[id]][id][0] == 1){
				return PLUGIN_HANDLED
			}
			else
			{
				
				daj_mu_buty(id);
			}
		}
		case 4:
		{
			if(weapon_skill[Player_Class[id]][id][0] == 1){
				return PLUGIN_HANDLED
			}
			else
			{
				
				daj_mu_bron(id);
			}
		}
		case 5:
		{
			if(bracelet_skills[Player_Class[id]][id][0] == 1){
				return PLUGIN_HANDLED
			}
			else
			{
				
				daj_mu_bransoletke(id);
			}
		}
		case 6:
		{
			if(necklace_skills[Player_Class[id]][id][0] == 1){
				return PLUGIN_HANDLED
			}
			else
			{
				daj_mu_necklace(id);
			}
		}
		case 7:
		{
			if(earrings_skills[Player_Class[id]][id][0] == 1){
				return PLUGIN_HANDLED
			}
			else
			{
				daj_mu_kolczyki(id);
			}
		}
		case 8:
		{
			if(shield_skills[Player_Class[id]][id][0] == 1){
				return PLUGIN_HANDLED
			}
			else
			{
				daj_mu_tarcze(id);
			}
		}
	}
	return PLUGIN_HANDLED
}

public daj_mu_armor( id ){
	new which_item;	
	if( 15 > Player_Level[Player_Class[id]][id] >= 0){
		which_item = random_num( 1,12 );
	}
	else if( 35 > Player_Level[Player_Class[id]][id] >= 15){
		which_item = random_num( 1,24 );	
	}
	else if( 61 > Player_Level[Player_Class[id]][id] >= 35){
		which_item = random_num( 1,32 );
	}
	else if( 89 > Player_Level[Player_Class[id]][id] >= 61){
		which_item = random_num( 1,40 );
	}
	switch( which_item ){
		case 1:
		{
			armor_name[Player_Class[id]][id] = "Mnisia Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][27] = 0;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 12;//def
			
		}
		case 2:
		{
			armor_name[Player_Class[id]][id] = "Zalobna Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][27] = 0;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 12;//def
			
		}
		case 3:
		{
			armor_name[Player_Class[id]][id] = "Blekitne Ubranie";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][27] = 0;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 12;//def
			
		}
		case 4:
		{
			armor_name[Player_Class[id]][id] = "Blekitna Szata";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][27] = 0;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 12;//def
			
		}
		case 5:
		{
			armor_name[Player_Class[id]][id] = "Zelazna Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -2;//speed
			armor_skills[Player_Class[id]][id][27] = 9;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 21;//def
			
		}
		case 6:
		{
			armor_name[Player_Class[id]][id] = "Zbroja Plytowa Maga";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -2;//speed
			armor_skills[Player_Class[id]][id][27] = 9;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 21;//def
			
		}
		case 7:
		{
			armor_name[Player_Class[id]][id] = "Kremowe Ubranie";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -2;//speed
			armor_skills[Player_Class[id]][id][27] = 9;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 21;//def
			
		}
		case 8:
		{
			armor_name[Player_Class[id]][id] = "Turkusowa Szata";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -2;//speed
			armor_skills[Player_Class[id]][id][27] = 9;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 21;//def
			
		}
		case 9:
		{
			armor_name[Player_Class[id]][id] = "Zbroja Plytowa Tygrysa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -3;//speed
			armor_skills[Player_Class[id]][id][27] = 18;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 29;//def
			
		}
		case 10:
		{
			armor_name[Player_Class[id]][id] = "Nieszczesna Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -3;//speed
			armor_skills[Player_Class[id]][id][27] = 18;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 29;//def
			
		}
		case 11:
		{
			armor_name[Player_Class[id]][id] = "Czerwone Ubranie";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -3;//speed
			armor_skills[Player_Class[id]][id][27] = 18;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 29;//def
			
		}
		case 12:
		{
			armor_name[Player_Class[id]][id] = "Rozowa Szata";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -3;//speed
			armor_skills[Player_Class[id]][id][27] = 18;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 29;//def
			
		}
		case 13:
		{
			armor_name[Player_Class[id]][id] = "Lwia Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -5;//speed
			armor_skills[Player_Class[id]][id][27] = 26;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 38;//def
			
		}
		case 14:
		{
			armor_name[Player_Class[id]][id] = "Upiorna Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -5;//speed
			armor_skills[Player_Class[id]][id][27] = 26;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 38;//def
			
		}
		case 15:
		{
			armor_name[Player_Class[id]][id] = "Ubranie Czerwonej Mrowki";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -5;//speed
			armor_skills[Player_Class[id]][id][27] = 26;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 38;//def
			
		}
		case 16:
		{
			armor_name[Player_Class[id]][id] = "Milosna Szata";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -5;//speed
			armor_skills[Player_Class[id]][id][27] = 26;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 38;//def
			
		}
		case 17:
		{
			armor_name[Player_Class[id]][id] = "Smiertelna Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -7;//speed
			armor_skills[Player_Class[id]][id][27] = 34;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 47;//def
			
		}
		case 18:
		{
			armor_name[Player_Class[id]][id] = "Zbroja Plytowa Yin-Yang";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -7;//speed
			armor_skills[Player_Class[id]][id][27] = 34;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 47;//def
			
		}
		case 19:
		{
			armor_name[Player_Class[id]][id] = "Ubranie Lwiej Mrowki";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -7;//speed
			armor_skills[Player_Class[id]][id][27] = 34;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 47;//def
			
		}
		case 20:
		{
			armor_name[Player_Class[id]][id] = "Szata Zachodniego Nieba";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -7;//speed
			armor_skills[Player_Class[id]][id][27] = 34;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 47;//def
			
		}
		case 21:
		{
			armor_name[Player_Class[id]][id] = "Smocza Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -8;//speed
			armor_skills[Player_Class[id]][id][27] = 42;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 55;//def
			
		}
		case 22:
		{
			armor_name[Player_Class[id]][id] = "Mistyczna Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -8;//speed
			armor_skills[Player_Class[id]][id][27] = 42;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 55;//def
			
		}
		case 23:
		{
			armor_name[Player_Class[id]][id] = "Ubranie Zabojcy";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -8;//speed
			armor_skills[Player_Class[id]][id][27] = 42;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 55;//def
			
		}
		case 24:
		{
			armor_name[Player_Class[id]][id] = "Szata Slonca";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -8;//speed
			armor_skills[Player_Class[id]][id][27] = 42;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 55;//def
			
		}
		case 25:
		{
			armor_name[Player_Class[id]][id] = "Zbroja Plytowa Z Lusek";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -10;//speed
			armor_skills[Player_Class[id]][id][27] = 48;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 64;//def
			
		}
		case 26:
		{
			armor_name[Player_Class[id]][id] = "Mglista Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -10;//speed
			armor_skills[Player_Class[id]][id][27] = 48;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 64;//def
			
		}
		case 27:
		{
			armor_name[Player_Class[id]][id] = "Ubranie Mlodego Smoka";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -10;//speed
			armor_skills[Player_Class[id]][id][27] = 48;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 64;//def
			
		}
		case 28:
		{
			armor_name[Player_Class[id]][id] = "Szata Moralnosci";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -10;//speed
			armor_skills[Player_Class[id]][id][27] = 48;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 64;//def
			
		}
		case 29:
		{
			armor_name[Player_Class[id]][id] = "Zlota Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -12;//speed
			armor_skills[Player_Class[id]][id][27] = 54;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 72;//def
			
		}
		case 30:
		{
			armor_name[Player_Class[id]][id] = "Zbroja Twarzy Ducha";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -12;//speed
			armor_skills[Player_Class[id]][id][27] = 54;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 72;//def
			
		}
		case 31:
		{
			armor_name[Player_Class[id]][id] = "Ubranie Zabojcy Wiatru";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -12;//speed
			armor_skills[Player_Class[id]][id][27] = 54;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 72;//def
			
		}
		case 32:
		{
			armor_name[Player_Class[id]][id] = "Szata Pomaranczowego Kota";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -12;//speed
			armor_skills[Player_Class[id]][id][27] = 54;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 72;//def
		}
		case 33:
		{
			armor_name[Player_Class[id]][id] = "Zbroja Boga Smokow";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -13;//speed
			armor_skills[Player_Class[id]][id][27] = 61;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 81;//def
			
		}
		case 34:
		{
			armor_name[Player_Class[id]][id] = "Duchowa Zbroja Plytowa";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -13;//speed
			armor_skills[Player_Class[id]][id][27] = 61;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 81;//def
			
		}
		case 35:
		{
			armor_name[Player_Class[id]][id] = "Ubranie Fukcyjne";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -13;//speed
			armor_skills[Player_Class[id]][id][27] = 61;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 81;//def
			
		}
		case 36:
		{
			armor_name[Player_Class[id]][id] = "Szata Baronow";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -13;//speed
			armor_skills[Player_Class[id]][id][27] = 61;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 81;//def
			
		}
		case 37:
		{
			armor_name[Player_Class[id]][id] = "Zbroja Z Czarnej Stali";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -15;//speed
			armor_skills[Player_Class[id]][id][27] = 66;//lvl
			armor_skills[Player_Class[id]][id][28] = 1;//woj
			armor_skills[Player_Class[id]][id][32] = 90;//def
			
		}
		case 38:
		{
			armor_name[Player_Class[id]][id] = "Zbroja Plytowa Czarnej Magii";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -15;//speed
			armor_skills[Player_Class[id]][id][27] = 66;//lvl
			armor_skills[Player_Class[id]][id][30] = 1;//sura
			armor_skills[Player_Class[id]][id][32] = 90;//def
			
		}
		case 39:
		{
			armor_name[Player_Class[id]][id] = "Ubranie Czarnego Wiatru";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -15;//speed
			armor_skills[Player_Class[id]][id][27] = 66;//lvl
			armor_skills[Player_Class[id]][id][29] = 1;//ninja
			armor_skills[Player_Class[id]][id][32] = 90;//def
			
		}
		case 40:
		{
			armor_name[Player_Class[id]][id] = "Czarna Szata";
			armor_skills[Player_Class[id]][id][0] = 1;
			armor_skills[Player_Class[id]][id][7] = -15;//speed
			armor_skills[Player_Class[id]][id][27] = 66;//lvl
			armor_skills[Player_Class[id]][id][31] = 1;//szaman
			armor_skills[Player_Class[id]][id][32] = 90;//def
			
		}
	}
	check_armor(id);
	emit_sound( id, CHAN_STATIC, "metin2/equip_metal_armor.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
	show_hudmessage(id, "Zdobyles item %s",armor_name[Player_Class[id]][id])
}

public check_armor(id){
	if(Player_Level[Player_Class[id]][id] < armor_skills[Player_Class[id]][id][27]){
		armor_skills[Player_Class[id]][id][0] = 2;
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(armor_skills[Player_Class[id]][id][28] == 0){
				armor_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(armor_skills[Player_Class[id]][id][29] == 0){
				armor_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(armor_skills[Player_Class[id]][id][30] == 0){
				armor_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(armor_skills[Player_Class[id]][id][31] == 0){
				armor_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
	}
	armor_skills[Player_Class[id]][id][0] = 1;
	max_hp[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][17];
	if(faint_no[Player_Class[id]][id] == 0){
		faint_no[Player_Class[id]][id] = armor_skills[Player_Class[id]][id][18];
	}
	strong_against_warrior[Player_Class[id]][id] += armor_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]+= armor_skills[Player_Class[id]][id][33]
	return PLUGIN_CONTINUE;
}


public daj_mu_helm( id ){
	new which_item;	
	if( 10 > Player_Level[Player_Class[id]][id] >= 0){
		which_item = random_num( 1,4 );
	}
	else if( 22 > Player_Level[Player_Class[id]][id] >= 10){
		which_item = random_num( 1,8 );	
	}
	else if( 89 > Player_Level[Player_Class[id]][id] >= 22){
		which_item = random_num( 1,12 );
	}
	switch( which_item ){
		case 1:
		{
			helmet_name[Player_Class[id]][id] = "Tradycyjny Helm";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 0;//lvl
			helmet_skills[Player_Class[id]][id][28] = 1;//woj
			helmet_skills[Player_Class[id]][id][32] = 5;//def
			
		}
		case 2:
		{
			helmet_name[Player_Class[id]][id] = "Krwawy Helm";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 0;//lvl
			helmet_skills[Player_Class[id]][id][30] = 1;//sura
			helmet_skills[Player_Class[id]][id][32] = 5;//def
			
		}
		case 3:
		{
			helmet_name[Player_Class[id]][id] = "Skorzana Maska";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 0;//lvl
			helmet_skills[Player_Class[id]][id][29] = 1;//ninja
			helmet_skills[Player_Class[id]][id][32] = 5;//def
			
		}
		case 4:
		{
			helmet_name[Player_Class[id]][id] = "Czapka Mnicha";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 0;//lvl
			helmet_skills[Player_Class[id]][id][31] = 1;//sura
			helmet_skills[Player_Class[id]][id][32] = 5;//def
			
		}
		case 5:
		{
			helmet_name[Player_Class[id]][id]= "Zelazny Helm";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 21;//lvl
			helmet_skills[Player_Class[id]][id][28] = 1;//woj
			helmet_skills[Player_Class[id]][id][32] = 9;//def
			
		}
		case 6:
		{
			helmet_name[Player_Class[id]][id] = "Wyzywajšcy Helm";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 21;//lvl
			helmet_skills[Player_Class[id]][id][30] = 1;//sura
			helmet_skills[Player_Class[id]][id][32] = 9;//def
			
		}
		case 7:
		{
			helmet_name[Player_Class[id]][id] = "Maska Kolcza";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 21;//lvl
			helmet_skills[Player_Class[id]][id][29] = 1;//ninja
			helmet_skills[Player_Class[id]][id][32] = 9;//def
			
		}
		case 8:
		{
			helmet_name[Player_Class[id]][id] = "Czapka Feniksa";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 21;//lvl
			helmet_skills[Player_Class[id]][id][31] = 1;//szaman
			helmet_skills[Player_Class[id]][id][32] = 9;//def
			
		}
		case 9:
		{
			helmet_name[Player_Class[id]][id] = "Upiorna Maska";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 41;//lvl
			helmet_skills[Player_Class[id]][id][28] = 1;//woj
			helmet_skills[Player_Class[id]][id][32] = 13;//def
			
		}
		case 10:
		{
			helmet_name[Player_Class[id]][id] = "Zamkowy Helm";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 41;//lvl
			helmet_skills[Player_Class[id]][id][30] = 1;//sura
			helmet_skills[Player_Class[id]][id][32] = 13;//def
			
		}
		case 11:
		{
			helmet_name[Player_Class[id]][id] = "Stalowa Maska";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 41;//lvl
			helmet_skills[Player_Class[id]][id][29] = 1;//ninja
			helmet_skills[Player_Class[id]][id][32] = 13;//def
			
		}
		case 12:
		{
			helmet_name[Player_Class[id]][id] = "Swietlista Czapka";
			helmet_skills[Player_Class[id]][id][0] = 1;
			helmet_skills[Player_Class[id]][id][27] = 41;//lvl
			helmet_skills[Player_Class[id]][id][31] = 1;//szaman
			helmet_skills[Player_Class[id]][id][32] = 13;//def
			
		}
	}
	check_helm(id);
	emit_sound( id, CHAN_STATIC, "metin2/pick.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
	show_hudmessage(id, "Zdobyles item %s",helmet_name[Player_Class[id]][id])
}

public check_helm(id){
	if(Player_Level[Player_Class[id]][id] < helmet_skills[Player_Class[id]][id][27]){
		helmet_skills[Player_Class[id]][id][0] = 2;
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(helmet_skills[Player_Class[id]][id][28] == 0){
				helmet_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(helmet_skills[Player_Class[id]][id][29] == 0){
				helmet_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(helmet_skills[Player_Class[id]][id][30] == 0){
				helmet_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(helmet_skills[Player_Class[id]][id][31] == 0){
				helmet_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
	}
	helmet_skills[Player_Class[id]][id][0] = 1;
	max_hp[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][17];
	if(faint_no[Player_Class[id]][id] == 0){
		faint_no[Player_Class[id]][id] = helmet_skills[Player_Class[id]][id][18];
	}
	strong_against_warrior[Player_Class[id]][id] += helmet_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]+= helmet_skills[Player_Class[id]][id][33]
	return PLUGIN_CONTINUE;
}

public daj_mu_buty( id ){
	new which_item;	
	if( 18 > Player_Level[Player_Class[id]][id] >= 0){
		which_item = random_num( 1,3 );
	}
	else if( 44 > Player_Level[Player_Class[id]][id] >= 18){
		which_item = random_num( 1,8 );	
	}
	else if( 89 > Player_Level[Player_Class[id]][id] >= 44){
		which_item = random_num( 1,12 );
	}
	switch( which_item ){
		case 1:
		{
			shoes_name[Player_Class[id]][id] = "Skorzane Buty";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 0;//lvl
			shoes_skills[Player_Class[id]][id][7] = 2;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 1;//def
			
		}
		case 2:
		{
			shoes_name[Player_Class[id]][id] = "Bambusowe Buty";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 9;//lvl
			shoes_skills[Player_Class[id]][id][7] = 2;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 2;//def
			
		}
		case 3:
		{
			shoes_name[Player_Class[id]][id] = "Drewniane Buty";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 17;//lvl
			shoes_skills[Player_Class[id]][id][7] = 2;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 2;//def
			
		}
		case 4:
		{
			shoes_name[Player_Class[id]][id]= "Buty Wyszywane Zlotem";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 23;//lvl
			shoes_skills[Player_Class[id]][id][7] = 2;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 3;//def
			
		}
		case 5:
		{
			shoes_name[Player_Class[id]][id] = "Skorzane Kozaki";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 29;//lvl
			shoes_skills[Player_Class[id]][id][7] = 3;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 3;//def
			
		}
		case 6:
		{
			shoes_name[Player_Class[id]][id] = "Zlote Buty";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 34;//lvl
			shoes_skills[Player_Class[id]][id][7] = 3;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 4;//def
			
		}
		case 7:
		{
			shoes_name[Player_Class[id]][id]= "Buty Z Brazu";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 39;//lvl
			shoes_skills[Player_Class[id]][id][7] = 3;//speed
			shoes_skills[Player_Class[id]][id][15] = 1;//odp.trucizny
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 4;//def
			
		}
		case 8:
		{
			shoes_name[Player_Class[id]][id]= "Jadeitowe Buty";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 43;//lvl
			shoes_skills[Player_Class[id]][id][7] = 3;//speed
			shoes_skills[Player_Class[id]][id][16] = 1;//exp.bon
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 4;//def
			
		}
		case 9:
		{
			shoes_name[Player_Class[id]][id] = "Ekstazyjne Buty";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 47;//lvl
			shoes_skills[Player_Class[id]][id][7] = 5;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 5;//def
			
		}
		case 10:
		{
			shoes_name[Player_Class[id]][id] = "Deszczowe Buty";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 51;//lvl
			shoes_skills[Player_Class[id]][id][7] = 5;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 5;//def
			
		}
		case 11:
		{
			shoes_name[Player_Class[id]][id]= "Buty Feniksa";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 55;//lvl
			shoes_skills[Player_Class[id]][id][7] = 5;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 5;//def
			
		}
		case 12:
		{
			shoes_name[Player_Class[id]][id] = "Buty Ognistego Ptaka";
			shoes_skills[Player_Class[id]][id][0] = 1;
			shoes_skills[Player_Class[id]][id][27] = 59;//lvl
			shoes_skills[Player_Class[id]][id][7] = 5;//speed
			shoes_skills[Player_Class[id]][id][28] = 1;//woj
			shoes_skills[Player_Class[id]][id][29] = 1;//ninja
			shoes_skills[Player_Class[id]][id][30] = 1;//sura
			shoes_skills[Player_Class[id]][id][31] = 1;//szaman
			shoes_skills[Player_Class[id]][id][32] = 6;//def
			
		}
		
	}
	check_buty(id);
	emit_sound( id, CHAN_STATIC, "metin2/pick.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
	show_hudmessage(id, "Zdobyles item %s",shoes_name[Player_Class[id]][id])
}

public check_buty(id){
	if(Player_Level[Player_Class[id]][id] < shoes_skills[Player_Class[id]][id][27]){
		shoes_skills[Player_Class[id]][id][0] = 2;
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(shoes_skills[Player_Class[id]][id][28] == 0){
				shoes_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(shoes_skills[Player_Class[id]][id][29] == 0){
				shoes_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(shoes_skills[Player_Class[id]][id][30] == 0){
				shoes_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(shoes_skills[Player_Class[id]][id][31] == 0){
				shoes_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
	}
	shoes_skills[Player_Class[id]][id][0] = 1;
	max_hp[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][17];
	if(faint_no[Player_Class[id]][id] == 0){
		faint_no[Player_Class[id]][id] = shoes_skills[Player_Class[id]][id][18];
	}
	strong_against_warrior[Player_Class[id]][id] += shoes_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]+= shoes_skills[Player_Class[id]][id][33]
	return PLUGIN_CONTINUE;
}
public daj_mu_bron( id ){
	new chck_name;
	new which_item;	
	if( 11 > Player_Level[Player_Class[id]][id] >= 0){
		which_item = random_num( 1,16 );
	}
	else if( 26 > Player_Level[Player_Class[id]][id] >= 11){
		which_item = random_num( 1,33 );	
	}
	else if( 41 > Player_Level[Player_Class[id]][id] >= 26){
		which_item = random_num( 1,57 );
	}
	else if( 61 > Player_Level[Player_Class[id]][id] >= 41){
		which_item = random_num( 1,80 );
	}
	else if( 89 > Player_Level[Player_Class[id]][id] >= 61){
		which_item = random_num( 1,106 );
	}
	switch( which_item ){
		case 1:
		{
			weapon_name[Player_Class[id]][id] = "Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 1;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 15;//dmg
			
		}
		case 2:
		{
			weapon_name[Player_Class[id]][id] = "Luk";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 1;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 29;//dmg
			
		}
		case 3:
		{
			weapon_name[Player_Class[id]][id] = "Sztylet";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 1;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 11;//dmg
			
		}
		case 4:
		{
			weapon_name[Player_Class[id]][id] = "Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 1;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 15;//dmg
			
		}
		case 5:
		{
			weapon_name[Player_Class[id]][id] = "Glewia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 1;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 22;//dmg
			
		}
		case 6:
		{
			weapon_name[Player_Class[id]][id] = "Dlugi Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 5;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 19;//dmg
			
		}
		case 7:
		{
			weapon_name[Player_Class[id]][id] = "Wlocznia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 5;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 33;//dmg
			
		}
		case 8:
		{
			weapon_name[Player_Class[id]][id] = "Dlugi Luk";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 5;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 51;//dmg
			
		}
		case 9:
		{
			weapon_name[Player_Class[id]][id] = "Amija";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 5;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 14;//dmg
			
		}
		case 10:
		{
			weapon_name[Player_Class[id]][id] = "Semijtar";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 10;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 24;//dmg
			
		}
		case 11:
		{
			weapon_name[Player_Class[id]][id] = "Gilotynowe Ostrze";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 10;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 42;//dmg
			
		}
		case 12:
		{
			weapon_name[Player_Class[id]][id] = "Kompozytowy Luk";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 10;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 57;//dmg
			
		}
		case 13:
		{
			weapon_name[Player_Class[id]][id] = "Sztylet Kobry";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 10;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 15;//dmg
			
		}
		case 14:
		{
			weapon_name[Player_Class[id]][id] = "Miedziany Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 10;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 15;//dmg
			
		}
		case 15:
		{
			weapon_name[Player_Class[id]][id] = "Zelazny Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 5;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 17;//dmg
			
		}
		case 16:
		{
			weapon_name[Player_Class[id]][id] = "Wachlarz Czarnego Tygrysa";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 10;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 19;//dmg
			
		}
		case 17:
		{
			weapon_name[Player_Class[id]][id] = "Stozkowy Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 15;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 26;//dmg
			
		}
		case 18:
		{
			weapon_name[Player_Class[id]][id] = "Pajecza Wlocznia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 15;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 44;//dmg
			
		}
		case 19:
		{
			weapon_name[Player_Class[id]][id] = "Bojowy Luk";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 15;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 70;//dmg
			
		}
		case 20:
		{
			weapon_name[Player_Class[id]][id] = "Dziewiec Ostrzy";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 15;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 16;//dmg
			
		}
		case 21:
		{
			weapon_name[Player_Class[id]][id] = "Srebrny Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 15;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 26;//dmg
			
		}
		case 22:
		{
			weapon_name[Player_Class[id]][id] = "Zurawi Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 15;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 21;//dmg
			
		}
		case 23:
		{
			weapon_name[Player_Class[id]][id] = "Szeroki Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 20;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 35;//dmg
			
		}
		case 24:
		{
			weapon_name[Player_Class[id]][id] = "Gizarma";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 20;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 52;//dmg
			
		}
		case 25:
		{
			weapon_name[Player_Class[id]][id] = "Dlugi Luk Jezdzcy";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 20;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 88;//dmg
			
		}
		case 26:
		{
			weapon_name[Player_Class[id]][id] = "Sztylet Nozycowy";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 20;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 19;//dmg
			
		}
		case 27:
		{
			weapon_name[Player_Class[id]][id] = "Zloty Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 20;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 35;//dmg
			
		}
		case 28:
		{
			weapon_name[Player_Class[id]][id] = "Pawi Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 20;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 24;//dmg
			
		}
		case 29:
		{
			weapon_name[Player_Class[id]][id] = "Srebrny Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 25;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 46;//dmg
			
		}
		case 30:
		{
			weapon_name[Player_Class[id]][id] = "Kosa Bojowa";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 25;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 86;//dmg
			
		}
		case 31:
		{
			weapon_name[Player_Class[id]][id] = "Bojowy Luk Jezdzcy";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 25;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 118;//dmg
			
		}
		case 32:
		{
			weapon_name[Player_Class[id]][id] = "Krotki Noz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 25;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 32;//dmg
			
		}
		case 33:
		{
			weapon_name[Player_Class[id]][id] = "Wodny Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 25;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 41;//dmg
			
		}
		case 34:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Pelni Ksiezyca";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 30;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 73;//dmg
			//unique
		}
		case 35:
		{
			weapon_name[Player_Class[id]][id] = "Ostrze Z Czerwonej Stali";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 30;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 109;//dmg
			//unique
		}
		case 36:
		{
			weapon_name[Player_Class[id]][id] = "Luk z Rogu Jelenia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 30;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 178;//dmg
			//unique
		}
		case 37:
		{
			weapon_name[Player_Class[id]][id] = "Kozik Czarnego Liscia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 30;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 44;//dmg
			//unique
		}
		case 38:
		{
			weapon_name[Player_Class[id]][id] = "Antyczny Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 30;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 70;//dmg
			//unique
		}
		case 39:
		{
			weapon_name[Player_Class[id]][id] = "Wachlarz Jesiennego Wiatru";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 30;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 55;//dmg
			//unique
		}
		case 40:
		{
			weapon_name[Player_Class[id]][id] = "Storczykowy Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 32;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 52;//dmg
			
		}
		case 41:
		{
			weapon_name[Player_Class[id]][id] = "Trojzab";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 32;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 88;//dmg
			
		}
		case 42:
		{
			weapon_name[Player_Class[id]][id] = "Miedziany Luk";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 32;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 128;//dmg
			
		}
		case 43:
		{
			weapon_name[Player_Class[id]][id] = "Noz Szczescia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 32;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 36;//dmg
			
		}
		case 44:
		{
			weapon_name[Player_Class[id]][id] = "Jadeitowy Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 32;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 39;//dmg
			
		}
		case 45:
		{
			weapon_name[Player_Class[id]][id] = "Kamienny Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 32;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 46;//dmg
			
		}
		case 46:
		{
			weapon_name[Player_Class[id]][id] = "Poltorareczny Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 36;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 58;//dmg
			
		}
		case 47:
		{
			weapon_name[Player_Class[id]][id] = "Halabarda";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 36;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 96;//dmg
			
		}
		case 48:
		{
			weapon_name[Player_Class[id]][id] = "Luk Czarnych Ruin";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 36;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 150;//dmg
			
		}
		case 49:
		{
			weapon_name[Player_Class[id]][id] = "Ukaszenie Kota";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 36;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 37;//dmg
			
		}
		case 50:
		{
			weapon_name[Player_Class[id]][id] = "Dzwon Fontanny";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 36;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 51;//dmg
			
		}
		case 51:
		{
			weapon_name[Player_Class[id]][id] = "Oceaniczny Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 36;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 45;//dmg
			
		}
		case 52:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Barbarzyncy";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 40;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 68;//dmg
			
		}
		case 53:
		{
			weapon_name[Player_Class[id]][id] = "Olbrzymi Topor";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 40;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 103;//dmg
			
		}
		case 54:
		{
			weapon_name[Player_Class[id]][id] = "Luk Czerwonego Oka";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 40;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 194;//dmg
			
		}
		case 55:
		{
			weapon_name[Player_Class[id]][id] = "Twarz Diabla";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 40;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 40;//dmg
			
		}
		case 56:
		{
			weapon_name[Player_Class[id]][id] = "Morelowy Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 40;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 60;//dmg
			
		}
		case 57:
		{
			weapon_name[Player_Class[id]][id] = "Zadlowy Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 40;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 53;//dmg
			
		}
		case 58:
		{
			weapon_name[Player_Class[id]][id] = "Krwawy Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 45;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 87;//dmg
			
		}
		case 59:
		{
			weapon_name[Player_Class[id]][id] = "Lodowa Iglica";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 45;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 122;//dmg
			
		}
		case 60:
		{
			weapon_name[Player_Class[id]][id] = "Luk Kolczastego Liscia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 45;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 206;//dmg
			
		}
		case 61:
		{
			weapon_name[Player_Class[id]][id] = "Sztylet Piesci Diabla";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 45;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 51;//dmg
			
		}
		case 62:
		{
			weapon_name[Player_Class[id]][id] = "Wachlarz Feniksa";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 45;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 64;//dmg
			
		}
		case 63:
		{
			weapon_name[Player_Class[id]][id] = "Wielki Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 50;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 91;//dmg
			
		}
		case 64:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Dwunastu Duchow";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 50;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 139;//dmg
			
		}
		case 65:
		{
			weapon_name[Player_Class[id]][id] = "Luk z Rogu Byka";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 50;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 216;//dmg
			
		}
		case 66:
		{
			weapon_name[Player_Class[id]][id] = "Krwawy Sztylet";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 50;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 56;//dmg
			
		}
		case 67:
		{
			weapon_name[Player_Class[id]][id] = "Magiczny Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 50;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 89;//dmg
			
		}
		case 68:
		{
			weapon_name[Player_Class[id]][id] = "Potrojny Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 50;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 73;//dmg
			
		}
		case 69:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Latajacego Maga";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 55;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 100;//dmg
			
		}
		case 70:
		{
			weapon_name[Player_Class[id]][id] = "Ostrze Zbawienia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 55;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 154;//dmg
			
		}
		case 71:
		{
			weapon_name[Player_Class[id]][id] = "Luk Jednorozca";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 55;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 213;//dmg
			
		}
		case 72:
		{
			weapon_name[Player_Class[id]][id] = "Zebrowy Noz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 55;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 59;//dmg
			
		}
		case 73:
		{
			weapon_name[Player_Class[id]][id] = "Zloty Robaczy Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 55;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 90;//dmg
			
		}
		case 74:
		{
			weapon_name[Player_Class[id]][id] = "Brwisty Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 55;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 78;//dmg
			
		}
		case 75:
		{
			weapon_name[Player_Class[id]][id] = "Polksiezycowy Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 60;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 108;//dmg
			
		}
		case 76:
		{
			weapon_name[Player_Class[id]][id] = "Zabojca Lwow";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 60;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 156;//dmg
			
		}
		case 77:
		{
			weapon_name[Player_Class[id]][id] = "Olbrzymi Skrzydlaty Luk";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 60;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 251;//dmg
			
		}
		case 78:
		{
			weapon_name[Player_Class[id]][id] = "Chakram";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 60;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 65;//dmg
			
		}
		case 79:
		{
			weapon_name[Player_Class[id]][id] = "Stalowy Robaczy Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 60;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 104;//dmg
			
		}
		case 80:
		{
			weapon_name[Player_Class[id]][id] = "Wachlarz Czarnego Slonca";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 60;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 83;//dmg
			
		}
		case 81:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Nimfy";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 138;//dmg
			//excelent
		}
		case 82:
		{
			weapon_name[Player_Class[id]][id] = "Bojowy Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 140;//dmg
			//excelent
		}
		case 83:
		{
			weapon_name[Player_Class[id]][id] = "Magnetyczne Ostrze";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 194;//dmg
			//excelent
		}
		case 84:
		{
			weapon_name[Player_Class[id]][id] = "Partyzana";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 184;//dmg
			//excelent
		}
		case 85:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Egzorcysty";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 142;//dmg
			//excelent
		}
		case 86:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Szponu Ducha";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 105;//dmg
			//excelent
		}
		case 87:
		{
			weapon_name[Player_Class[id]][id] = "Boski Luk Moreli";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 290;//dmg
			//excelent
		}
		case 88:
		{
			weapon_name[Player_Class[id]][id] = "Olbrzymi Luk Zoltego Smoka";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 293;//dmg
			//excelent
		}
		case 89:
		{
			weapon_name[Player_Class[id]][id] = "Noz Blyskawicy";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 86;//dmg
			//excelent
		}
		case 90:
		{
			weapon_name[Player_Class[id]][id] = "Smoczy Noz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 86;//dmg
			//excelent
		}
		case 91:
		{
			weapon_name[Player_Class[id]][id] = "Dzwon Nieba I Ziemi";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 108;//dmg
			//excelent
		}
		case 92:
		{
			weapon_name[Player_Class[id]][id] = "Dzwon Burzowego Ptaka";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 129;//dmg
			//excelent
		}
		case 93:
		{
			weapon_name[Player_Class[id]][id] = "Wachlarz Zbawienia";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 91;//dmg
			//excelent
		}
		case 94:
		{
			weapon_name[Player_Class[id]][id] = "Boski Ptasi Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 65;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 96;//dmg
			//excelent
		}
		case 95:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Zadla";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][1] = 50;//max.pz
			weapon_skill[Player_Class[id]][id][27] = 70;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 138;//dmg
			//legendary
		}
		case 96:
		{
			weapon_name[Player_Class[id]][id] = "Zlodziej Dusz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 70;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 194;//dmg
			//legendary
		}
		case 97:
		{
			weapon_name[Player_Class[id]][id] = "Demoniczne Ostrze";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 70;//lvl
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 105;//dmg
			//legendary
		}
		case 98:
		{
			weapon_name[Player_Class[id]][id] = "Luk Niebieskiego Smoka";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 70;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 293;//dmg
			//legendary
		}
		case 99:
		{
			weapon_name[Player_Class[id]][id] = "Noz Siamese";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 70;//lvl
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 86;//dmg
			//legendary
		}
		case 100:
		{
			weapon_name[Player_Class[id]][id] = "Zatruty Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 75;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][29] = 1;//ninja
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 140;//dmg
			//extra_legendary
		}
		case 101:
		{
			weapon_name[Player_Class[id]][id] = "Miecz Zalu";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 75;//lvl
			weapon_skill[Player_Class[id]][id][28] = 1;//woj
			weapon_skill[Player_Class[id]][id][33] = 184;//dmg
			//extra_legendary
		}
		case 102:
		{
			weapon_name[Player_Class[id]][id] = "Lwi Miecz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 75;//lvl
			weapon_skill[Player_Class[id]][id][30] = 1;//sura
			weapon_skill[Player_Class[id]][id][33] = 110;//dmg
			//extra_legendary
		}
		case 103:
		{
			weapon_name[Player_Class[id]][id] = "Stalowy Luk Kruka";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 75;//lvl
			weapon_skill[Player_Class[id]][id][30] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 290;//dmg
			//extra_legendary
		}
		case 104:
		{
			weapon_name[Player_Class[id]][id] = "Skrzydla Demona Chakram";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 75;//lvl
			weapon_skill[Player_Class[id]][id][30] = 1;//ninja
			weapon_skill[Player_Class[id]][id][33] = 92;//dmg
			//extra_legendary
		}
		case 105:
		{
			weapon_name[Player_Class[id]][id] = "Bambusowy Dzwon";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 75;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 108;//dmg
			//extra_legendary
		}
		case 106:
		{
			weapon_name[Player_Class[id]][id] = "Ekstazyjny Wachlarz";
			weapon_skill[Player_Class[id]][id][0] = 1;
			weapon_skill[Player_Class[id]][id][27] = 70;//lvl
			weapon_skill[Player_Class[id]][id][31] = 1;//szaman
			weapon_skill[Player_Class[id]][id][33] = 92;//dmg
			//legendary
		}
	}
	check_bron(id);
	((chck_name = containi(weapon_name[Player_Class[id]][id],"luk")) != -1) ? emit_sound( id, CHAN_STATIC, "metin2/equip_bow.wav", 1.0, ATTN_NORM, 0, PITCH_NORM ) : emit_sound( id, CHAN_STATIC, "metin2/equip_metal_weapon.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
	show_hudmessage(id, "Zdobyles item %s",weapon_name[Player_Class[id]][id])
}	

public check_bron(id){
	if(Player_Level[Player_Class[id]][id] < weapon_skill[Player_Class[id]][id][27]){
		weapon_skill[Player_Class[id]][id][0] = 2;
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(weapon_skill[Player_Class[id]][id][28] == 0){
				weapon_skill[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(weapon_skill[Player_Class[id]][id][29] == 0){
				weapon_skill[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(weapon_skill[Player_Class[id]][id][30] == 0){
				weapon_skill[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(weapon_skill[Player_Class[id]][id][31] == 0){
				weapon_skill[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
	}
	weapon_skill[Player_Class[id]][id][0] = 1;
	max_hp[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] += weapon_skill[Player_Class[id]][id][17];
	if(faint_no[Player_Class[id]][id] == 0){
		faint_no[Player_Class[id]][id] = weapon_skill[Player_Class[id]][id][18];
	}
	strong_against_warrior[Player_Class[id]][id] +=weapon_skill[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]+= weapon_skill[Player_Class[id]][id][33]
	return PLUGIN_CONTINUE;
}

public daj_mu_bransoletke( id ){
	new which_item;	
	if( 16 > Player_Level[Player_Class[id]][id] >= 0){
		which_item = random_num( 1,3 );
	}
	else if( 39 > Player_Level[Player_Class[id]][id] >= 16){
		which_item = random_num( 1,7 );	
	}
	else if( 41 > Player_Level[Player_Class[id]][id] >= 39){
		which_item = random_num( 1,57 );
	}
	else if( 89 > Player_Level[Player_Class[id]][id] >= 41){
		which_item = random_num( 1,11 );
	}
	switch( which_item ){
		case 1:
		{
			bracelet_name[Player_Class[id]][id] = "Drewniana Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 1;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][2] = 10;//max.pm
			
		}
		case 2:
		{
			bracelet_name[Player_Class[id]][id] = "Miedziana Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 8;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][7] = 5;//speed
			
		}
		case 3:
		{
			bracelet_name[Player_Class[id]][id] = "Srebrna Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 15;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][1] = 20;//max.pz
			
		}
		case 4:
		{
			bracelet_name[Player_Class[id]][id] = "Zlota Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 22;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][15] = 1;//odp.truc.
			
		}
		case 5:
		{
			bracelet_name[Player_Class[id]][id] = "Jadeitowa Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 28;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][16] = 1;//exp.bon.
			
		}
		case 6:
		{
			bracelet_name[Player_Class[id]][id] = "Ebonitowa Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 33;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][3] = 1;//pkt.hp
			
		}
		case 7:
		{
			bracelet_name[Player_Class[id]][id] = "Perlowa Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 38;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][2] = 10;//max.pm
			
		}
		case 8:
		{
			bracelet_name[Player_Class[id]][id] = "Bransoleta Z Bialego Zlota";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 42;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][1] = 25;//max.pz
			
		}
		case 9:
		{
			bracelet_name[Player_Class[id]][id] = "Krysztalowa Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 42;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			//////////////regeneracjaHP!!!!
		}
		case 10:
		{
			bracelet_name[Player_Class[id]][id] = "Ametystowa Bransoleta";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 50;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][8] = 8;//reg.pm
			
		}
		case 11:
		{
			bracelet_name[Player_Class[id]][id] = "Bransoleta Z Niebianskich Lez";
			bracelet_skills[Player_Class[id]][id][0] = 1;
			bracelet_skills[Player_Class[id]][id][27] = 54;//lvl
			bracelet_skills[Player_Class[id]][id][28] = 1;//woj
			bracelet_skills[Player_Class[id]][id][29] = 1;//ninja
			bracelet_skills[Player_Class[id]][id][30] = 1;//sura
			bracelet_skills[Player_Class[id]][id][31] = 1;//szaman
			bracelet_skills[Player_Class[id]][id][12] = 1;//krytyk
			
		}
	}
	check_bracelet(id);
	emit_sound( id, CHAN_STATIC, "metin2/equip_ring_amulet.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
	show_hudmessage(id, "Zdobyles item %s",bracelet_name[Player_Class[id]][id])
}	

public check_bracelet(id){
	if(Player_Level[Player_Class[id]][id] < bracelet_skills[Player_Class[id]][id][27]){
		bracelet_skills[Player_Class[id]][id][0] = 2;
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(bracelet_skills[Player_Class[id]][id][28] == 0){
				bracelet_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(bracelet_skills[Player_Class[id]][id][29] == 0){
				bracelet_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(bracelet_skills[Player_Class[id]][id][30] == 0){
				bracelet_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(bracelet_skills[Player_Class[id]][id][31] == 0){
				bracelet_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
	}
	bracelet_skills[Player_Class[id]][id][0] = 1;
	max_hp[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] += bracelet_skills[Player_Class[id]][id][17];
	if(faint_no[Player_Class[id]][id] == 0){
		faint_no[Player_Class[id]][id] = bracelet_skills[Player_Class[id]][id][18];
	}
	strong_against_warrior[Player_Class[id]][id] +=bracelet_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]+= bracelet_skills[Player_Class[id]][id][33]
	return PLUGIN_CONTINUE;
}

public daj_mu_necklace( id ){
	new which_item;	
	if( 16 > Player_Level[Player_Class[id]][id] >= 0){
		which_item = random_num( 1,3 );
	}
	else if( 39 > Player_Level[Player_Class[id]][id] >= 16){
		which_item = random_num( 1,7 );	
	}
	else if( 41 > Player_Level[Player_Class[id]][id] >= 39){
		which_item = random_num( 1,57 );
	}
	else if( 89 > Player_Level[Player_Class[id]][id] >= 41){
		which_item = random_num( 1,11 );
	}
	switch( which_item ){
		case 1:
		{
			necklace_name[Player_Class[id]][id] = "Drewniany Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 1;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			//////////////szybkosc zaklec 2
		}
		case 2:
		{
			necklace_name[Player_Class[id]][id] = "Miedziany Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 8;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			//////////////szybkosc zaklec 2
		}
		case 3:
		{
			necklace_name[Player_Class[id]][id] = "Srebrny Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 15;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			//////////////szybkosc zaklec 2
		}
		case 4:
		{
			necklace_name[Player_Class[id]][id] = "Zloty Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 22;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			//////////////szybkosc zaklec 2
			//////////////odp.na strzaly 1
		}
		case 5:
		{
			necklace_name[Player_Class[id]][id] = "Jadeitowy Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 28;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			necklace_skills[Player_Class[id]][id][6] = 1;//zwinnosc
			//////////////szybkosc zaklec 4
			
		}
		case 6:
		{
			necklace_name[Player_Class[id]][id] = "Ebonitowy Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 33;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			necklace_skills[Player_Class[id]][id][3] = 1;//hp+
			//////////////szybkosc zaklec 4
			
		}
		case 7:
		{
			necklace_name[Player_Class[id]][id] = "Perlowy Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 38;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			necklace_skills[Player_Class[id]][id][4] = 1;//int+
			//////////////szybkosc zaklec 4
			
		}
		case 8:
		{
			necklace_name[Player_Class[id]][id] = "Naszyjnik Z Bialego Zlota";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 42;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			necklace_skills[Player_Class[id]][id][5] = 1;//str+
			//////////////szybkosc zaklec 4
			
		}
		case 9:
		{
			necklace_name[Player_Class[id]][id] = "Krysztalowy Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 46;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			necklace_skills[Player_Class[id]][id][8] = 8;//reg.pm
			//////////////szybkosc zaklec 6
			
		}
		case 10:
		{
			necklace_name[Player_Class[id]][id] = "Ametystowy Naszyjnik";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 50;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			//////////////REG!HP!
			//////////////szybkosc zaklec 6
			
		}
		case 11:
		{
			necklace_name[Player_Class[id]][id] = "Naszyjnik Z Niebianskich Lez";
			necklace_skills[Player_Class[id]][id][0] = 1;
			necklace_skills[Player_Class[id]][id][27] = 54;//lvl
			necklace_skills[Player_Class[id]][id][28] = 1;//woj
			necklace_skills[Player_Class[id]][id][29] = 1;//ninja
			necklace_skills[Player_Class[id]][id][30] = 1;//sura
			necklace_skills[Player_Class[id]][id][31] = 1;//szaman
			necklace_skills[Player_Class[id]][id][13] = 1;//przeszywka
			//////////////szybkosc zaklec 6
			
		}
	}
	check_necklace(id);
	emit_sound( id, CHAN_STATIC, "metin2/equip_ring_amulet.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
	show_hudmessage(id, "Zdobyles item %s",necklace_name[Player_Class[id]][id])
}

public check_necklace(id){
	if(Player_Level[Player_Class[id]][id] < necklace_skills[Player_Class[id]][id][27]){
		necklace_skills[Player_Class[id]][id][0] = 2;
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(necklace_skills[Player_Class[id]][id][28] == 0){
				necklace_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(necklace_skills[Player_Class[id]][id][29] == 0){
				necklace_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(necklace_skills[Player_Class[id]][id][30] == 0){
				necklace_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(necklace_skills[Player_Class[id]][id][31] == 0){
				necklace_skills[Player_Class[id]][id][0] = 2;
				return PLUGIN_CONTINUE;
			}
		}
	}
	necklace_skills[Player_Class[id]][id][0] = 1;
	max_hp[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][17];
	if(faint_no[Player_Class[id]][id] == 0){
		faint_no[Player_Class[id]][id] = necklace_skills[Player_Class[id]][id][18];
	}
	strong_against_warrior[Player_Class[id]][id] +=necklace_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]+= necklace_skills[Player_Class[id]][id][33]
	return PLUGIN_CONTINUE;
}


public daj_mu_kolczyki( id ){
	new which_item;	
	if( 16 > Player_Level[Player_Class[id]][id] >= 0){
		which_item = random_num( 1,3 );
	}
	else if( 39 > Player_Level[Player_Class[id]][id] >= 16){
		which_item = random_num( 1,6 );	
	}
	else if( 41 > Player_Level[Player_Class[id]][id] >= 39){
		which_item = random_num( 1,9 );
	}
	else if( 89 > Player_Level[Player_Class[id]][id] >= 41){
		which_item = random_num( 1,11 );
	}
	switch( which_item ){
		case 1:
		{
			earrings_name[Player_Class[id]][id] = "Drewniane Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 1;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][6] = 1;//zwinnosc
			
		}
		case 2:
		{
			earrings_name[Player_Class[id]][id] = "Miedziane Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 8;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][5] = 1;//str+
			
		}
		case 3:
		{
			earrings_name[Player_Class[id]][id] = "Srebrne Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 15;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][3] = 1;//hp+
			
		}
		case 4:
		{
			earrings_name[Player_Class[id]][id] = "Zlote Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 22;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][4] = 1;//int+
			
		}
		case 5:
		{
			earrings_name[Player_Class[id]][id] = "Jadeitowe Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 28;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][6] = 3;//zwinnosc
			earrings_skills[Player_Class[id]][id][2] = 10;//max.pm
			
		}
		case 6:
		{
			earrings_name[Player_Class[id]][id] = "Ebonitowe Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 33;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][5] = 3;//str+
			earrings_skills[Player_Class[id]][id][1] = 25;//max.hp
			
		}
		case 7:
		{
			earrings_name[Player_Class[id]][id] = "Perlowe Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 38;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][3] = 3;//hp+
			earrings_skills[Player_Class[id]][id][8] = 4;//reg.pm
			
		}
		case 8:
		{
			earrings_name[Player_Class[id]][id] = "Kolczyki Z Bialego Zlota";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 42;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][4] = 3;//int+
			///////////////REG!HP!
			
		}
		case 9:
		{
			earrings_name[Player_Class[id]][id] = "Krysztalowe Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 46;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][6] = 5;//zwinnosc
			earrings_skills[Player_Class[id]][id][32] = 1;//def
			
		}
		case 10:
		{
			earrings_name[Player_Class[id]][id] = "Ametystowe Kolczyki";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 50;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][3] = 5;//hp+
			earrings_skills[Player_Class[id]][id][33] = 1;//dmg
			
		}
		case 11:
		{
			earrings_name[Player_Class[id]][id] = "Kolczyki Z Niebianskich Lez";
			earrings_skills[Player_Class[id]][id][0] = 1
			earrings_skills[Player_Class[id]][id][27] = 54;//lvl
			earrings_skills[Player_Class[id]][id][28] = 1;//woj
			earrings_skills[Player_Class[id]][id][29] = 1;//ninja
			earrings_skills[Player_Class[id]][id][30] = 1;//sura
			earrings_skills[Player_Class[id]][id][31] = 1;//szaman
			earrings_skills[Player_Class[id]][id][4] = 5;//int+
			earrings_skills[Player_Class[id]][id][12] = 1;//krytyk
			
		}
	}
	check_earrings(id);
	emit_sound( id, CHAN_STATIC, "metin2/equip_ring_amulet.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
	show_hudmessage(id, "Zdobyles item %s",earrings_name[Player_Class[id]][id])
}

public check_earrings(id){
	if(Player_Level[Player_Class[id]][id] < earrings_skills[Player_Class[id]][id][27]){
		earrings_skills[Player_Class[id]][id][0] = 2
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(earrings_skills[Player_Class[id]][id][28] == 0){
				earrings_skills[Player_Class[id]][id][0] = 2
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(earrings_skills[Player_Class[id]][id][29] == 0){
				earrings_skills[Player_Class[id]][id][0] = 2
				return PLUGIN_CONTINUE;
			}
		}
		case 3:
		{
			if(earrings_skills[Player_Class[id]][id][30] == 0){
				earrings_skills[Player_Class[id]][id][0] = 2
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(earrings_skills[Player_Class[id]][id][31] == 0){
				earrings_skills[Player_Class[id]][id][0] = 2
				return PLUGIN_CONTINUE;
			}
		}
	}
	earrings_skills[Player_Class[id]][id][0] = 1;
	max_hp[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id] += necklace_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] += earrings_skills[Player_Class[id]][id][17];
	if(faint_no[Player_Class[id]][id] == 0){
		faint_no[Player_Class[id]][id] = earrings_skills[Player_Class[id]][id][18];
	}
	strong_against_warrior[Player_Class[id]][id] +=earrings_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]+= earrings_skills[Player_Class[id]][id][33]
	return PLUGIN_CONTINUE;
}

public daj_mu_tarcze( id ){
	new which_item;	
	if( 12 > Player_Level[Player_Class[id]][id] >= 0){
		which_item = random_num( 1,1 );
	}
	else if( 22 > Player_Level[Player_Class[id]][id] >= 12){
		which_item = random_num( 1,2 );	
	}
	else if( 62 > Player_Level[Player_Class[id]][id] >= 22){
		which_item = random_num( 1,3 );
	}
	else if( 89 > Player_Level[Player_Class[id]][id] >= 62){
		which_item = random_num( 1,7 );
	}
	switch( which_item ){
		case 1:
		{
			shield_name[Player_Class[id]][id] = "Bojowa Tarcza";
			shield_skills[Player_Class[id]][id][0] = 1;
			shield_skills[Player_Class[id]][id][27] = 1;//lvl
			shield_skills[Player_Class[id]][id][28] = 1;//woj
			shield_skills[Player_Class[id]][id][29] = 1;//ninja
			shield_skills[Player_Class[id]][id][30] = 1;//sura
			shield_skills[Player_Class[id]][id][31] = 1;//szaman
			shield_skills[Player_Class[id]][id][7] = -2;//speed
			shield_skills[Player_Class[id]][id][32] = 3;//def
			
		}
		case 2:
		{
			shield_name[Player_Class[id]][id] = "Pieciokatna Tarcza";
			shield_skills[Player_Class[id]][id][0] = 1;
			shield_skills[Player_Class[id]][id][27] = 21;//lvl
			shield_skills[Player_Class[id]][id][28] = 1;//woj
			shield_skills[Player_Class[id]][id][29] = 1;//ninja
			shield_skills[Player_Class[id]][id][30] = 1;//sura
			shield_skills[Player_Class[id]][id][31] = 1;//szaman
			shield_skills[Player_Class[id]][id][7] = -6;//speed
			shield_skills[Player_Class[id]][id][32] = 5;//def
			
		}
		case 3:
		{
			shield_name[Player_Class[id]][id] = "Czarna Okršgla Tarcza";
			shield_skills[Player_Class[id]][id][0] = 1;
			shield_skills[Player_Class[id]][id][27] = 41;//lvl
			shield_skills[Player_Class[id]][id][28] = 1;//woj
			shield_skills[Player_Class[id]][id][29] = 1;//ninja
			shield_skills[Player_Class[id]][id][30] = 1;//sura
			shield_skills[Player_Class[id]][id][31] = 1;//szaman
			shield_skills[Player_Class[id]][id][7] = -10;//speed
			shield_skills[Player_Class[id]][id][32] = 7;//def
			
		}
		case 4:
		{
			shield_name[Player_Class[id]][id]  = "Sokola Tarcza";
			shield_skills[Player_Class[id]][id][0] = 1;
			shield_skills[Player_Class[id]][id][27] = 61;//lvl
			shield_skills[Player_Class[id]][id][28] = 1;//woj
			shield_skills[Player_Class[id]][id][29] = 1;//ninja
			shield_skills[Player_Class[id]][id][30] = 1;//sura
			shield_skills[Player_Class[id]][id][31] = 1;//szaman
			shield_skills[Player_Class[id]][id][7] = -6;//speed
			shield_skills[Player_Class[id]][id][32] = 7;//def
			shield_skills[Player_Class[id]][id][23] = 1;//odp.woj
			//excelent		
		}
		case 5:
		{
			shield_name[Player_Class[id]][id]  = "Lwia Tarcza";
			shield_skills[Player_Class[id]][id][0] = 1;
			shield_skills[Player_Class[id]][id][27] = 61;//lvl
			shield_skills[Player_Class[id]][id][28] = 1;//woj
			shield_skills[Player_Class[id]][id][29] = 1;//ninja
			shield_skills[Player_Class[id]][id][30] = 1;//sura
			shield_skills[Player_Class[id]][id][31] = 1;//szaman
			shield_skills[Player_Class[id]][id][7] = -6;//speed
			shield_skills[Player_Class[id]][id][32] = 7;//def
			shield_skills[Player_Class[id]][id][25] = 1;//odp.sura
			//excelent		
		}
		case 6:
		{
			shield_name[Player_Class[id]][id] = "Buddyjska Tarcza Tygrysa";
			shield_skills[Player_Class[id]][id][0] = 1;
			shield_skills[Player_Class[id]][id][27] = 61;//lvl
			shield_skills[Player_Class[id]][id][28] = 1;//woj
			shield_skills[Player_Class[id]][id][29] = 1;//ninja
			shield_skills[Player_Class[id]][id][30] = 1;//sura
			shield_skills[Player_Class[id]][id][31] = 1;//szaman
			shield_skills[Player_Class[id]][id][7] = -6;//speed
			shield_skills[Player_Class[id]][id][32] = 7;//def
			shield_skills[Player_Class[id]][id][24] = 1;//odp.ninja
			//excelent		
		}
		case 7:
		{
			shield_name[Player_Class[id]][id]  = "Tarcza Smoka";
			shield_skills[Player_Class[id]][id][0] = 1;
			shield_skills[Player_Class[id]][id][27] = 61;//lvl
			shield_skills[Player_Class[id]][id][28] = 1;//woj
			shield_skills[Player_Class[id]][id][29] = 1;//ninja
			shield_skills[Player_Class[id]][id][30] = 1;//sura
			shield_skills[Player_Class[id]][id][31] = 1;//szaman
			shield_skills[Player_Class[id]][id][7] = -6;//speed
			shield_skills[Player_Class[id]][id][32] = 7;//def
			shield_skills[Player_Class[id]][id][26] = 1;//odp.szaman
			//excelent		
		}
	}
	check_shield(id);
	emit_sound( id, CHAN_STATIC, "metin2/pick.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
	show_hudmessage(id, "Zdobyles item %s",shield_name[Player_Class[id]][id] )
}

public check_shield(id){
	if(Player_Level[Player_Class[id]][id] < shield_skills[Player_Class[id]][id][27]){
		shield_skills[Player_Class[id]][id][0] = 2
		return PLUGIN_CONTINUE;
	}
	switch(Player_Class[id]){
		case 1:
		{
			if(shield_skills[Player_Class[id]][id][28] == 0){
				shield_skills[Player_Class[id]][id][0] = 2
				return PLUGIN_CONTINUE;
			}
		}
		case 2:
		{
			if(shield_skills[Player_Class[id]][id][29] == 0){
				shield_skills[Player_Class[id]][id][0] = 2
				return PLUGIN_HANDLED
			}
		}
		case 3:
		{
			if(shield_skills[Player_Class[id]][id][30] == 0){
				shield_skills[Player_Class[id]][id][0] = 2
				return PLUGIN_CONTINUE;
			}
		}
		case 4:
		{
			if(shield_skills[Player_Class[id]][id][31] == 0){
				shield_skills[Player_Class[id]][id][0] = 2
				return PLUGIN_CONTINUE;
			}
		}
	}
	shield_skills[Player_Class[id]][id][0] = 1;
	max_hp[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][1];
	max_mp[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][2];
	add_con[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][3];
	add_int[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][4];
	add_str[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][5];
	add_dex[Player_Class[id]][id] +=shield_skills[Player_Class[id]][id][6];
	add_speed[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][7];
	mana_regeneration[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][8];
	chance_poisoning[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][9];
	chance_faint[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][10];
	chance_slowdown[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][11];
	chance_critical[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][12];
	chance_pierce[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][13];
	chance_stealing_mana[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][14];
	poison_resistance[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][15];
	bonus_exp[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][16];
	dual_drop[Player_Class[id]][id] += shield_skills[Player_Class[id]][id][17];
	if(faint_no[Player_Class[id]][id] == 0){
		faint_no[Player_Class[id]][id] = shield_skills[Player_Class[id]][id][18];
	}
	strong_against_warrior[Player_Class[id]][id] +=shield_skills[Player_Class[id]][id][19];
	strong_against_sura[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][20]
	strong_against_shaman[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][21]
	strong_against_ninja[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][22]
	resistant_to_warrior[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][23]
	resistant_to_sura[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][24]
	resistant_to_shaman[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][25]
	resistant_to_ninja[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][26]
	def_array[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][32]
	dmg[Player_Class[id]][id]+= shield_skills[Player_Class[id]][id][33]
	return PLUGIN_CONTINUE;
}

public respawn_player(id) 
{      
	id -=csdm_task;
	if (!is_user_connected(id) || g_isalive(id) || cs_get_user_team(id) == CS_TEAM_SPECTATOR){
		return;
	}
	
	set_pev(id, pev_deadflag, DEAD_RESPAWNABLE) 
	dllfunc(DLLFunc_Think, id) 
	
	if(pev(id, pev_deadflag) == DEAD_RESPAWNABLE)
	{ 
		dllfunc(DLLFunc_Spawn, id) 
	}
	set_task(0.5,"add_respawn",id+1999)
}

public add_respawn(id){
	id-=1999;
	set_user_godmode(id,1)
	set_task(5.0,"godmodeoff",id+godmode_task)
	cs_set_user_money(id,cs_get_user_money(id)+3000)
}


public godmodeoff(id){
	id-=godmode_task;
	set_user_godmode(id,0)
}

public DajXp(id_gracza,ile_expa){
	if( get_pcvar_num(cvar_toggle) == 0) {
		return PLUGIN_HANDLED
	}
	
	if(Player_Class[id_gracza] == CLASS_NONE) {
		return PLUGIN_HANDLED
	}
	
	if(Player_Level[Player_Class[id_gracza]][id_gracza] == 99) {
		return PLUGIN_HANDLED
	}
	
	Player_XP[Player_Class[id_gracza]][id_gracza] += ile_expa
	
	for( ; ; ){
		if(Player_XP[Player_Class[id_gracza]][id_gracza] >= LEVELS[Player_Level[Player_Class[id_gracza]][id_gracza]]) {
			
			Player_Level[Player_Class[id_gracza]][id_gracza]+= 1
			player_point[Player_Class[id_gracza]][id_gracza]+= 3
			
			ColorChat(id_gracza,GREEN,"[Metin2 Mod]^x01 Gratulacje! Awansowales do levela %i!", Player_Level[Player_Class[id_gracza]][id_gracza])
			//hud + print
			set_hudmessage(60, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
			show_hudmessage(id_gracza, "Awans do poziomu: %i", Player_Level[Player_Class[id_gracza]][id_gracza])
			
			if(Player_Level[Player_Class[id_gracza]][id_gracza] % 10 == 0){
				emit_sound( id_gracza, CHAN_STATIC, "metin2/levelup1_2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
			}
			else
			{
				emit_sound( id_gracza, CHAN_STATIC, "metin2/levelup1_1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
			}
			if( get_pcvar_num(cvar_savexp) == 1) {
				
				SaveXP(id_gracza)
			}
			
			
			ShowHUD(id_gracza)
		}
		else
		{
			break;
		}
	}
	
	new id = id_gracza;
	
	if(necklace_skills[Player_Class[id]][id][0] == 2){
		check_necklace(id);
	}
	if(armor_skills[Player_Class[id]][id][0] == 2){
		check_armor(id);
	}
	if(bracelet_skills[Player_Class[id]][id][0] == 2){
		check_bracelet(id);
	}
	if(weapon_skill[Player_Class[id]][id][0] == 2){
		check_bron(id);
	}
	if(shoes_skills[Player_Class[id]][id][0] == 2){
		check_buty(id);
	}
	if(helmet_skills[Player_Class[id]][id][0] == 2){
		check_helm(id);
	}
	if(earrings_skills[Player_Class[id]][id][0] == 2){
		check_earrings(id);
	}
	if(shield_skills[Player_Class[id]][id][0] == 2){
		check_shield(id);
	}
	
	ShowHUD(id_gracza)
	
	return PLUGIN_CONTINUE
}
public OdejmijXp(id_gracza,ile_expa){
	if( get_pcvar_num(cvar_toggle) == 0) {
		return PLUGIN_HANDLED
	}
	
	if(Player_Class[id_gracza] == CLASS_NONE) {
		return PLUGIN_HANDLED
	}
	if(Player_Level[Player_Class[id_gracza]][id_gracza] == 0 || Player_Level[Player_Class[id_gracza]][id_gracza] == 1){
		return PLUGIN_HANDLED;
	}
	if(Player_XP[Player_Class[id_gracza]][id_gracza] < ile_expa){
		Player_XP[Player_Class[id_gracza]][id_gracza] = 0;
	}
	else
	{
		Player_XP[Player_Class[id_gracza]][id_gracza] -= ile_expa
	}
	
	new bool:level_spadl = false;
	for( ; ; ){
		if(Player_XP[Player_Class[id_gracza]][id_gracza] <= LEVELS[Player_Level[Player_Class[id_gracza]][id_gracza]]) {
			
			Player_Level[Player_Class[id_gracza]][id_gracza]-= 1
			player_point[Player_Class[id_gracza]][id_gracza]-= 3
			
			level_spadl =true;
			ColorChat(id_gracza,GREEN,"[Metin2 Mod]^x01 Spadles do levela %i!", Player_Level[Player_Class[id_gracza]][id_gracza])
			//hud + print
			set_hudmessage(25, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2)
			show_hudmessage(id_gracza, "Spadles do levela: %i", Player_Level[Player_Class[id_gracza]][id_gracza])
			
			if( get_pcvar_num(cvar_savexp) == 1) {
				
				SaveXP(id_gracza)
			}
			
			ShowHUD(id_gracza)
		}
		else
		{
			break;
		}
	}
	if(level_spadl == true){
		skillmenureset(id_gracza);
	}
	
	ShowHUD(id_gracza)
	
	return PLUGIN_CONTINUE
}

public DajMane(komu,ile){
	if((player_int[Player_Class[komu]][komu] + 100 + max_mp[Player_Class[komu]][komu] + add_int[Player_Class[komu]][komu]) - Player_mana[komu] < ile){
		Player_mana[komu] = player_int[Player_Class[komu]][komu] + 100 + max_mp[Player_Class[komu]][komu] + add_int[Player_Class[komu]][komu];
	}
	else
	{
		Player_mana[komu] += ile;
	}
}

public OdejmijMane(komu,ile){
	if(Player_mana[komu] - ile < 0){
		Player_mana[komu] = 0;
	}
	else
	{
		Player_mana[komu] -= ile;
	}
}

public PrzekazXP(komu_zabrac,komu_dac,ile_dac){
	OdejmijXp(komu_zabrac,ile_dac)
	DajXp(komu_dac,ile_dac)
}

public przekaz_mane(id,kid,ile){
	OdejmijMane(id,ile);
	DajMane(kid,ile);
}

public on_HideStatus(id)
{
	message_begin(MSG_ONE, SVC_TEMPENTITY,_,id)
	write_byte(125)
	write_byte(id_targeted_player[id])
	message_end()
}

public on_ShowStatus(id)
{
	new cel, body 
	get_user_aiming(id, cel, body)
	if(cel != 0 && g_isalive(id) && g_isalive(cel) && get_pcvar_num(cvar_empire) == 3 || get_pcvar_num(cvar_empire) == 4 && cs_get_user_team(id) == cs_get_user_team(cel)) { 
		switch(Player_Kingdom[cel]){
			case 1:
			{
				message_begin(MSG_ONE, SVC_TEMPENTITY,_,id)
				write_byte(124)
				write_byte(cel)
				write_coord(35)
				write_short(link_shinsoo)
				write_short(100)
				message_end()
			}
			case 2:
			{
				message_begin(MSG_ONE, SVC_TEMPENTITY,_,id)
				write_byte(124)
				write_byte(cel)
				write_coord(35)
				write_short(link_chunjo)
				write_short(100)
				message_end()
			}
			case 3:
			{
				message_begin(MSG_ONE, SVC_TEMPENTITY,_,id)
				write_byte(124)
				write_byte(cel)
				write_coord(35)
				write_short(link_jinno)
				write_short(100)
				message_end()
			}
		}
	}
	id_targeted_player[id] = cel;
}

public client_PreThink(id) 
{ 
	new cel, body 
	get_user_aiming(id, cel, body)
	if(cel != 0 && g_isalive(id)) 
	{ 
		ShowHUD(id)
	}
	new button = get_user_button(id)
	if(button&IN_RELOAD && Player_Class[id] == 2 && bow[id] == 0 && g_isalive(id)  && weapon[id]==CSW_KNIFE){
		new pos;
		if((pos = containi(weapon_name[Player_Class[id]][id],"luk")) != -1){
			bow[id] = 1;
			entity_set_string(id, EV_SZ_viewmodel, "models/metin2/v_bow.mdl")
		}
	}
	if(button&IN_ATTACK && Player_Class[id] == 2 && bow[id] == 1 && reload[id] == 0  && g_isalive(id) && weapon[id]==CSW_KNIFE){
		luk_strzel(id);
	}
	else if(reload[id] == 1){
		set_task(get_pcvar_float(cvar_arrowreload),"reload_funkcja",reload_task+id)
		set_bartime(id,get_pcvar_num(cvar_arrowreload),0)
	}
	if(button&IN_USE && g_isalive(id) && weapon[id]==CSW_C4 && get_pcvar_num(cvar_csdm) == 1 ){
		client_cmd(id,"-use")
	}
}

public set_bartime(id, czas, startprogress)
{
	message_begin((id)?MSG_ONE:MSG_ALL, get_user_msgid("BarTime2"), _, id)
	write_short(czas);
	write_short(startprogress);
	message_end();   
	
} 

public luk_strzel(id){
	new ent = create_entity("info_target")
	if (pev_valid(ent) && g_isalive(id))
	{
		new weapon_id = find_ent_by_owner(-1, "weapon_knife", id)
		if(weapon_id)
		{
			set_pev(weapon_id,pev_sequence,1)
			set_pev(weapon_id,pev_gaitsequence,1)
			set_pev(weapon_id,pev_framerate,1.0)
		}
		new Float: nvelocity[3], Float:voriginf[3],Float: vangles[3], vorigin[3];
		
		set_pev(ent, pev_owner, id);
		set_pev(ent, pev_classname, "strzala");
		engfunc(EngFunc_SetModel, ent, "models/metin2/w_strzala.mdl");
		set_pev(ent, pev_gravity, get_pcvar_float(cvar_gravity));	
		get_user_origin(id, vorigin, 1);
		
		IVecFVec(vorigin, voriginf);
		engfunc(EngFunc_SetOrigin, ent, voriginf);
		
		static Float:player_angles[3]
		pev(id, pev_angles, player_angles)
		player_angles[2] = 0.0
		
		set_pev(ent, pev_angles, player_angles);
		
		pev(id, pev_v_angle, vangles);
		set_pev(ent, pev_v_angle, vangles);
		pev(id, pev_view_ofs, vangles);
		set_pev(ent, pev_view_ofs, vangles);
		
		new veloc = get_pcvar_num(cvar_arrowspeed);
		
		set_pev(ent, pev_movetype, MOVETYPE_TOSS);
		set_pev(ent, pev_solid, 2);
		velocity_by_aim(id, veloc, nvelocity);	
		
		set_pev(ent, pev_velocity, nvelocity);
		set_pev(ent,pev_sequence,1)
		set_pev(ent,pev_gaitsequence,1)
		set_pev(ent,pev_framerate,1.0)
		entity_set_edict(ent, EV_ENT_owner, id)
		reload[id] = 1;
		set_task(get_pcvar_float(cvar_arrowreload),"reload_funkcja",reload_task+id)
		set_bartime(id,get_pcvar_num(cvar_arrowreload),0)
	}
	return ent;
}

public reload_funkcja(id){
	id-=reload_task;
	reload[id] = 0;
}

public welcome_msg(id) {
	id-=welcome;
	ColorChat(id, GREEN, "***[%s]***",g_modname);
	ColorChat(id, GREEN, "by Ortega & DarkGL - 2010Â©");
}


public fw_PlayerKilled(victim, attacker, shouldgib)
{
	
	if (player_dex[Player_Class[victim]][victim] >= 90)	
	{
		static Float:FOrigin3[3] 
		pev(victim, pev_origin, FOrigin3)
		
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, FOrigin3, 0)
		write_byte(TE_IMPLOSION) 
		engfunc(EngFunc_WriteCoord, FOrigin3[0])
		engfunc(EngFunc_WriteCoord, FOrigin3[1]) 
		engfunc(EngFunc_WriteCoord, FOrigin3[2]) 
		write_byte(200)
		write_byte(100)
		write_byte(5)  
		message_end()
		
		static Float:FOrigin2[3]
		pev(victim, pev_origin, FOrigin2)
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, FOrigin2, 0)
		write_byte(TE_PARTICLEBURST)
		engfunc(EngFunc_WriteCoord, FOrigin2[0]) // os x
		engfunc(EngFunc_WriteCoord, FOrigin2[1]) // os y
		engfunc(EngFunc_WriteCoord, FOrigin2[2]) // os z
		write_short(200) // zasieg
		write_byte(72) // kolor
		write_byte(8) // czas trwania 
		message_end()
	}
} 

public szansa_na_krytyka(id){
	if(random_num(1,100) <= chance_critical[Player_Class[id]][id]){
		return true;
	}
	return false;
}

public ominiecie_obrony_losowanie(id){
	if(random_num(1,100) <= chance_pierce[Player_Class[id]][id]){
		return 1;
	}
	return 0;
}

public odporny_przeciwko(dostajacy,atakujacy){
	switch(Player_Class[atakujacy]){
		case 1:
		{
			return resistant_to_warrior[Player_Class[dostajacy]][dostajacy];
		}
		case 2:
		{
			return resistant_to_sura[Player_Class[dostajacy]][dostajacy];
		}
		case 3:
		{
			return resistant_to_shaman[Player_Class[dostajacy]][dostajacy];
		}
		case 4:
		{
			return resistant_to_ninja[Player_Class[dostajacy]][dostajacy];
		}
	}
	return 0;
}

public silny_przeciwko(dostajacy,atakujacy){
	switch(Player_Class[dostajacy]){
		case 1:
		{
			return strong_against_warrior[Player_Class[atakujacy]][atakujacy];
		}
		case 2:
		{
			return strong_against_sura[Player_Class[atakujacy]][atakujacy];
		}
		case 3:
		{
			return strong_against_shaman[Player_Class[atakujacy]][atakujacy];
		}
		case 4:
		{
			return strong_against_ninja[Player_Class[atakujacy]][atakujacy];
		}
	}
	return 0;
}

public fwTakeDamage(this, idinflictor, idattacker,Float:damage, damagebits){
	if(damagebits&DMG_BULLET){
		if(random_num(1,100) <= ((player_dex[Player_Class[this]][this] + add_dex[Player_Class[this]][this]) / 2)){
			client_print(this,print_chat,"Dzieki swojej zwinnosc uniknales pocisku!!");
			return HAM_SUPERCEDE;
		}
	}
	
	new Float:damage2 = damage;
	new Float:str
	new Float:def
	
	if(change_stats[idattacker] == 0){
		str = float((player_str[Player_Class[idattacker]][idattacker] + add_str[Player_Class[idattacker]][idattacker]) /3);
	}
	else
	{
		str = 0.0
	}
	
	
	
	if(change_stats[this] == 0){
		
		def = float((player_hp[Player_Class[this]][this] + add_con[Player_Class[this]][this])/4);
	}
	else
	{
		def = 0.0
	}
	def +=float(def_array[Player_Class[this]][this]);
	if(szansa_na_krytyka(idattacker)){
		damage2 *= 2.0;
	}
	new ominiecie_obrony = ominiecie_obrony_losowanie(idattacker)
	if(ominiecie_obrony == 0 && (damage2 +str)-def >= 0){
		SetHamParamFloat(4,(damage2+str)-def)
	} 
	else if(ominiecie_obrony == 1){
		SetHamParamFloat(4,damage2+str)
	}
	
	new asd = silny_przeciwko(this,idattacker)
	damage2 = damage;
	SetHamParamFloat(4,damage2+(damage2 *(asd * 0.01)))
	new asd2 = odporny_przeciwko(this,idattacker)
	damage2 = damage;
	SetHamParamFloat(4,damage2-(damage2 *(asd2 * 0.01)))
	damage2 = damage;
	SetHamParamFloat(4,damage2+float(dmg[Player_Class[idattacker]][idattacker]))
	return HAM_HANDLED;
}

public ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
static message[256];

switch(type)
{
	case YELLOW:{
		
		message[0] = 0x01;
	}
	case GREEN:{
		
		message[0] = 0x04;
	}
	default:{
		message[0] = 0x03;
	}
}
vformat(message[1], 251, msg, 4);

message[192] = '^0';
new team, ColorChange, index, MSG_Type;
if(!id)	{
	index = FindPlayer();
	MSG_Type = MSG_ALL;
	} else {
	MSG_Type = MSG_ONE;
	index = id;
}
team = get_user_team(index);	
ColorChange = ColorSelection(index, MSG_Type, type);
ShowColorMessage(index, MSG_Type, message);
if(ColorChange){
	Team_Info(index, MSG_Type, TeamName[team]);
}
}

ShowColorMessage(id, type, message[]){
message_begin(type, 76, _, id);
write_byte(id)		
write_string(message);
message_end();	
}

Team_Info(id, type, team[]){
message_begin(type, 86, _, id);
write_byte(id);
write_string(team);
message_end();
return 1;
}

ColorSelection(index, type, Color:Type){
switch(Type)	{
	case RED:		{
		return Team_Info(index, type, TeamName[1]);
	}
	case BLUE:		{
		return Team_Info(index, type, TeamName[2]);
	}
	case GREY:		{
		return Team_Info(index, type, TeamName[0]);
	}
}
return 0;
}

stock FindPlayer(){
new i = -1;
while(i <= MAXSLOTS){
	if(is_user_connected(++i)){
		return i;
	}
}

return -1;
}
//Odkomentuj jesli umiesz naprawic te funkcje
/*public zapis_itemow(id){
if( get_pcvar_num(cvar_savexp) == 1){   
new authid[32];   
switch(get_pcvar_num(cvar_savexpmode)){
	case 0:
	{
		get_user_authid(id,authid,31);
	}
	case 1:
	{
		get_user_name(id,authid,31);
	}
	case 2:
	{
		get_user_authid(id,authid,31);
		if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
			get_user_name(id,authid,31);
		}
	}
}

replace_all(authid, 31, " ", "'");
new vaultkey[64],vaultdata[1024],name[64];


for(new j = 0;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	format(name,63,"%s",armor_name[j][id])
	replace_all(name,63," ","_")
	format(vaultdata,1023,"%s%s#",vaultdata,name)
	for(new i = 0;i<36;i++){
		format(vaultdata,1023,"%s%d#",vaultdata,armor_skills[j][id][i])
	}
	nvault_set(nvault_armor,vaultkey,vaultdata)
	vaultdata = "";
}

for(new j = 0;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	format(name,63,"%s",bracelet_name[j][id])
	replace_all(name,63," ","_")
	format(vaultdata,1023,"%s%s#",vaultdata,name)
	for(new i = 0;i<36;i++){
		format(vaultdata,1023,"%s%d#",vaultdata,bracelet_skills[j][id][i])
	}
	nvault_set(nvault_bracelet,vaultkey,vaultdata)
	vaultdata = "";
}

for(new j = 0;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	format(name,63,"%s",earrings_name[j][id])
	replace_all(name,63," ","_")
	format(vaultdata,1023,"%s%s#",vaultdata,name)
	for(new i = 0;i<36;i++){
		format(vaultdata,1023,"%s%d#",vaultdata,earrings_skills[j][id][i])
	}
	nvault_set(nvault_kolczyki,vaultkey,vaultdata)
	vaultdata = "";
}

for(new j = 0;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	format(name,63,"%s",helmet_name[j][id])
	replace_all(name,63," ","_")
	format(vaultdata,1023,"%s%s#",vaultdata,name)
	for(new i = 0;i<36;i++){
		format(vaultdata,1023,"%s%d#",vaultdata,helmet_skills[j][id][i])
	}
	nvault_set(nvault_helm,vaultkey,vaultdata)
	vaultdata = "";
}

for(new j = 0;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	format(name,63,"%s",necklace_name[j][id])
	replace_all(name,63," ","_")
	format(vaultdata,1023,"%s%s#",vaultdata,name)
	for(new i = 0;i<36;i++){
		format(vaultdata,1023,"%s%d#",vaultdata,necklace_skills[j][id][i])
	}
	nvault_set(nvault_necklace,vaultkey,vaultdata)
	vaultdata = "";
}

for(new j = 0;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	format(name,63,"%s",shield_name[j][id])
	replace_all(name,63," ","_")
	format(vaultdata,1023,"%s%s#",vaultdata,name)
	for(new i = 0;i<36;i++){
		format(vaultdata,1023,"%s%d#",vaultdata,shield_skills[j][id][i])
	}
	nvault_set(nvault_tarcza,vaultkey,vaultdata)
	vaultdata = "";
}


for(new j = 0;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	format(name,63,"%s",shoes_name[j][id])
	replace_all(name,63," ","_")
	format(vaultdata,1023,"%s%s#",vaultdata,name)
	for(new i = 0;i<36;i++){
		format(vaultdata,1023,"%s%d#",vaultdata,shoes_skills[j][id][i])
	}
	nvault_set(nvault_buty,vaultkey,vaultdata)
	vaultdata = "";
}

for(new j = 0;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	format(name,63,"%s",weapon_name[j][id])
	replace_all(name,63," ","_")
	format(vaultdata,1023,"%s%s#",vaultdata,name)
	for(new i = 0;i<36;i++){
		format(vaultdata,1023,"%s%d#",vaultdata,weapon_skill[j][id][i])
	}
	nvault_set(nvault_bron,vaultkey,vaultdata)
	vaultdata = "";
}
}
}

public wczytaj_itemy(id){
if( get_pcvar_num(cvar_savexp) == 1){   
new authid[32];  
switch(get_pcvar_num(cvar_savexpmode)){
	case 0:
	{
		get_user_authid(id,authid,31);
	}
	case 1:
	{
		get_user_name(id,authid,31);
	}
	case 2:
	{
		get_user_authid(id,authid,31);
		if(equali(authid,"STEAM_ID_LAN",32) || equali(authid,"VALVE_ID_LAN",32)){
			get_user_name(id,authid,31);
		}
	}
}
replace_all(authid, 31, " ", "'");

new vaultkey[64],vaultdata[1024];

new name[64], numbers[37][64];


for(new j = 0 ;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	nvault_get(nvault_armor,vaultkey,vaultdata,1023);
	
	replace_all(vaultdata, 1023, "#", " ");
	
	parse_item(vaultdata,1023,name,numbers)
	
	armor_name[j][id] = name;
	
	for(new i= 0 ;i<36;i++){
		armor_skills[j][id][i] = str_to_num(numbers[i])
	}
}


for(new j = 0 ;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	nvault_get(nvault_bracelet,vaultkey,vaultdata,1023);
	
	replace_all(vaultdata, 1023, "#", " ");
	
	parse_item(vaultdata,1023,name,numbers)
	
	bracelet_name[j][id] = name;
	
	for(new i= 0 ;i<36;i++){
		bracelet_skills[j][id][i] = str_to_num(numbers[i])
	}
}

for(new j = 0 ;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	nvault_get(nvault_kolczyki,vaultkey,vaultdata,1023);
	
	replace_all(vaultdata, 1023, "#", " ");
	
	parse_item(vaultdata,1023,name,numbers)
	
	earrings_name[j][id] = name;
	
	for(new i= 0 ;i<36;i++){
		earrings_skills[j][id][i] = str_to_num(numbers[i])
	}
}

for(new j = 0 ;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	nvault_get(nvault_helm,vaultkey,vaultdata,1023);
	
	replace_all(vaultdata, 1023, "#", " ");
	
	parse_item(vaultdata,1023,name,numbers)
	
	helmet_name[j][id] = name;
	
	for(new i= 0 ;i<36;i++){
		helmet_skills[j][id][i] = str_to_num(numbers[i])
	}
}

for(new j = 0 ;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	nvault_get(nvault_necklace,vaultkey,vaultdata,1023);
	
	replace_all(vaultdata, 1023, "#", " ");
	
	parse_item(vaultdata,1023,name,numbers)
	
	necklace_name[j][id] = name;
	
	for(new i= 0 ;i<36;i++){
		necklace_skills[j][id][i] = str_to_num(numbers[i])
	}
}

for(new j = 0 ;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	nvault_get(nvault_tarcza,vaultkey,vaultdata,1023);
	
	replace_all(vaultdata, 1023, "#", " ");
	
	parse_item(vaultdata,1023,name,numbers)
	
	shield_name[j][id] = name;
	
	for(new i= 0 ;i<36;i++){
		shield_skills[j][id][i] = str_to_num(numbers[i])
	}
}

for(new j = 0 ;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	nvault_get(nvault_buty,vaultkey,vaultdata,1023);
	
	replace_all(vaultdata, 1023, "#", " ");
	
	parse_item(vaultdata,1023,name,numbers)
	
	shoes_name[j][id] = name;
	
	for(new i= 0 ;i<36;i++){
		shoes_skills[j][id][i] = str_to_num(numbers[i])
	}
}

for(new j = 0 ;j<4;j++){
	format(vaultkey,63,"%s-%s",authid,CLASSES[j+1]);
	nvault_get(nvault_bron,vaultkey,vaultdata,1023);
	
	replace_all(vaultdata, 1023, "#", " ");
	
	parse_item(vaultdata,1023,name,numbers)
	
	weapon_name[j][id] = name;
	
	for(new i= 0 ;i<36;i++){
		weapon_skill[j][id][i] = str_to_num(numbers[i])
	}
}		

}
}

parse_item(string[],len,name[],numbers[][]){
new bufor[1024];
new i = 0;
while(!equal(string[i]," ")){
format(bufor,1023,"%s%c",bufor,string[i]);
i++;
}
copy(name,63,bufor)
bufor = "";
new ile = 0;
for(i ;i<sizeof(string);i++){
if(!equal(string[i]," ")){
	format(bufor,1023,"%s%c",bufor,string[i]);
}
else
{
	copy(numbers[ile],63,bufor);
	bufor = "";
	ile++;
}
}
return PLUGIN_CONTINUE;
}*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
