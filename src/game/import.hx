#if !macro
// ImGui
#if hlimgui
import imgui.ImGui;
import imgui.ImGuiMacro;
#end
// Libs
import dn.M;
import dn.Lib;
import dn.Col;
import dn.Tweenie;
import dn.data.GetText;
import dn.struct.*;
import dn.heaps.input.*;
import dn.heaps.slib.*;
// Project classes
import Types;
import ui.Console;
import ui.Bar;
import ui.win.Modal;
import tools.*;
import tools.Point.FPoint;
import tools.Point.IPoint;
import tools.Path.*;
import tools.Path.FPath;
import tools.Path.IPath;
import assets.*;
import en.*;
import snd.SoundManager;
// Castle DB
import assets.CastleDb;
// LDtk
import assets.World;
// Aliases
import dn.RandomTools as R;
import assets.Assets as A;
import assets.AssetsDictionaries as D;
import hxd.Key as K;
import tools.LPoint as P;
import assets.Lang.t as L;
import Const.db as DB;
import dn.debug.MemTrack.measure as MM;

// Usings
using assets.Assets;
using tools.ObjectTools;
using tools.TweenieTools;
using tools.CooldownTools;
using tools.DelayerTools;
using tools.ProcessTools;
using tools.NumberTools;
using tools.ArrayTools;
#end